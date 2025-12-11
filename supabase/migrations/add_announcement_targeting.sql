-- =====================================================
-- ANNOUNCEMENT TARGETING MIGRATION
-- Adds comprehensive targeting fields for announcements
-- Date: December 2025
-- =====================================================

-- =====================================================
-- 1. ADD NEW TARGETING COLUMNS TO ANNOUNCEMENTS TABLE
-- =====================================================

-- User Insights Targeting (from survey responses)
ALTER TABLE public.announcements 
ADD COLUMN IF NOT EXISTS target_degree TEXT,
ADD COLUMN IF NOT EXISTS target_subspecialty TEXT,
ADD COLUMN IF NOT EXISTS target_profession TEXT,
ADD COLUMN IF NOT EXISTS target_hospital TEXT,
ADD COLUMN IF NOT EXISTS target_years_experience TEXT;

-- Device/Platform Targeting
ALTER TABLE public.announcements 
ADD COLUMN IF NOT EXISTS target_platform TEXT, -- 'ios', 'android', 'all'
ADD COLUMN IF NOT EXISTS target_is_real_device BOOLEAN, -- true = real device only, false = emulator only, null = all
ADD COLUMN IF NOT EXISTS target_device_brand TEXT, -- e.g., 'Apple', 'Samsung'
ADD COLUMN IF NOT EXISTS target_ip_addresses TEXT; -- comma-separated IPs for testing

-- Location Targeting (using ISO country codes)
ALTER TABLE public.announcements 
ADD COLUMN IF NOT EXISTS target_city TEXT; -- comma-separated city names

-- =====================================================
-- 2. ADD INSIGHTS COLUMN TO USERS TABLE (if not exists)
-- =====================================================

-- Ensure users table has insights column
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'users' 
        AND column_name = 'insights'
    ) THEN
        ALTER TABLE public.users ADD COLUMN insights JSONB DEFAULT '{}'::jsonb;
    END IF;
END $$;

-- =====================================================
-- 3. ADD LAST KNOWN LOCATION TO USERS TABLE
-- This stores the most recent location from app_sessions
-- for faster announcement filtering
-- =====================================================

ALTER TABLE public.users 
ADD COLUMN IF NOT EXISTS last_country TEXT,
ADD COLUMN IF NOT EXISTS last_city TEXT,
ADD COLUMN IF NOT EXISTS last_platform TEXT,
ADD COLUMN IF NOT EXISTS last_device_brand TEXT,
ADD COLUMN IF NOT EXISTS last_is_real_device BOOLEAN,
ADD COLUMN IF NOT EXISTS last_ip TEXT,
ADD COLUMN IF NOT EXISTS last_location_updated_at TIMESTAMPTZ;

-- =====================================================
-- 4. CREATE FUNCTION TO UPDATE USER LOCATION FROM SESSION
-- =====================================================

CREATE OR REPLACE FUNCTION update_user_location_from_session()
RETURNS TRIGGER AS $$
BEGIN
    -- Only update if we have location data and user exists
    IF NEW.country IS NOT NULL AND NEW.auth_uid IS NOT NULL THEN
        UPDATE public.users
        SET 
            last_country = NEW.country,
            last_city = NEW.city,
            last_platform = NEW.os_platform,
            last_device_brand = NEW.device_brand,
            last_is_real_device = NEW.is_device,
            last_ip = NEW.public_ip,
            last_location_updated_at = NOW(),
            updated_at = NOW()
        WHERE auth_uid = NEW.auth_uid;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to auto-update user location when session is created/updated
DROP TRIGGER IF EXISTS trigger_update_user_location ON public.app_sessions;
CREATE TRIGGER trigger_update_user_location
    AFTER INSERT OR UPDATE ON public.app_sessions
    FOR EACH ROW
    EXECUTE FUNCTION update_user_location_from_session();

-- =====================================================
-- 5. CREATE INDEXES FOR EFFICIENT TARGETING QUERIES
-- =====================================================

-- Announcement targeting indexes
CREATE INDEX IF NOT EXISTS idx_announcements_target_country ON public.announcements(target_country) WHERE target_country IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_announcements_target_platform ON public.announcements(target_platform) WHERE target_platform IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_announcements_target_degree ON public.announcements(target_degree) WHERE target_degree IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_announcements_target_profession ON public.announcements(target_profession) WHERE target_profession IS NOT NULL;

-- User location/insights indexes
CREATE INDEX IF NOT EXISTS idx_users_last_country ON public.users(last_country) WHERE last_country IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_users_last_platform ON public.users(last_platform) WHERE last_platform IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_users_insights_gin ON public.users USING gin(insights) WHERE insights IS NOT NULL AND insights != '{}'::jsonb;

-- =====================================================
-- 6. CREATE RPC FUNCTION FOR TARGETED ANNOUNCEMENTS
-- This is the main function called by the mobile app
-- =====================================================

CREATE OR REPLACE FUNCTION get_targeted_announcements(
    p_user_auth_uid TEXT,
    p_surface TEXT DEFAULT NULL,
    p_app_version TEXT DEFAULT NULL,
    p_platform TEXT DEFAULT NULL,
    p_country TEXT DEFAULT NULL,
    p_city TEXT DEFAULT NULL,
    p_is_real_device BOOLEAN DEFAULT NULL,
    p_device_brand TEXT DEFAULT NULL,
    p_ip_address TEXT DEFAULT NULL
)
RETURNS TABLE (
    id UUID,
    title TEXT,
    message TEXT,
    kind TEXT,
    surface TEXT,
    importance TEXT,
    action_type TEXT,
    action_value TEXT,
    dismissible BOOLEAN,
    dismissible_mode TEXT,
    remind_later_count INTEGER,
    remind_later_sessions INTEGER,
    repeat_mode TEXT,
    repeat_interval_hours INTEGER,
    max_times_seen_per_user INTEGER,
    metadata JSONB,
    questions JSONB,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    start_at TIMESTAMPTZ,
    end_at TIMESTAMPTZ,
    version INTEGER
) AS $$
DECLARE
    v_user RECORD;
    v_is_logged_in BOOLEAN;
BEGIN
    -- Get user data including insights and last location
    SELECT 
        u.is_anonymous,
        u.insights,
        COALESCE(p_country, u.last_country) as effective_country,
        COALESCE(p_city, u.last_city) as effective_city,
        COALESCE(p_platform, u.last_platform) as effective_platform,
        COALESCE(p_is_real_device, u.last_is_real_device) as effective_is_real_device,
        COALESCE(p_device_brand, u.last_device_brand) as effective_device_brand,
        COALESCE(p_ip_address, u.last_ip) as effective_ip
    INTO v_user
    FROM public.users u
    WHERE u.auth_uid = p_user_auth_uid;
    
    -- Determine login status
    v_is_logged_in := v_user IS NOT NULL AND NOT COALESCE(v_user.is_anonymous, true);
    
    RETURN QUERY
    SELECT 
        a.id,
        a.title,
        a.message,
        a.kind,
        a.surface,
        a.importance,
        a.action_type,
        a.action_value,
        a.dismissible,
        a.dismissible_mode,
        a.remind_later_count,
        a.remind_later_sessions,
        a.repeat_mode,
        a.repeat_interval_hours,
        a.max_times_seen_per_user,
        a.metadata,
        a.questions,
        a.created_at,
        a.updated_at,
        a.start_at,
        a.end_at,
        a.version
    FROM public.announcements a
    WHERE 
        -- Basic filters
        a.is_active = TRUE
        AND a.is_deleted = FALSE
        AND a.start_at <= NOW()
        AND (a.end_at IS NULL OR a.end_at > NOW())
        
        -- Surface filter (if specified)
        AND (p_surface IS NULL OR a.surface = p_surface)
        
        -- Login status targeting
        AND (
            (a.target_logged_in_only = FALSE AND a.target_anonymous_only = FALSE)
            OR (a.target_logged_in_only = TRUE AND v_is_logged_in = TRUE)
            OR (a.target_anonymous_only = TRUE AND v_is_logged_in = FALSE)
        )
        
        -- App version targeting
        AND (
            a.target_min_app_version IS NULL 
            OR a.target_min_app_version = '' 
            OR p_app_version IS NULL
            OR p_app_version >= a.target_min_app_version
        )
        AND (
            a.target_max_app_version IS NULL 
            OR a.target_max_app_version = '' 
            OR p_app_version IS NULL
            OR p_app_version <= a.target_max_app_version
        )
        
        -- Country targeting (using full country names from IP geolocation)
        AND (
            a.target_country IS NULL 
            OR a.target_country = ''
            OR v_user.effective_country IS NULL
            OR EXISTS (
                SELECT 1 FROM unnest(string_to_array(v_user.effective_country, ',')) AS user_country
                WHERE TRIM(LOWER(user_country)) = ANY(
                    SELECT TRIM(LOWER(c)) FROM unnest(string_to_array(a.target_country, ',')) c
                )
            )
        )
        
        -- City targeting (both target and user can have multiple values)
        AND (
            a.target_city IS NULL 
            OR a.target_city = ''
            OR v_user.effective_city IS NULL
            OR EXISTS (
                SELECT 1 FROM unnest(string_to_array(v_user.effective_city, ',')) AS user_city
                WHERE TRIM(LOWER(user_city)) = ANY(
                    SELECT TRIM(LOWER(c)) FROM unnest(string_to_array(a.target_city, ',')) c
                )
            )
        )
        
        -- Platform targeting (both target and user can have multiple values)
        AND (
            a.target_platform IS NULL 
            OR a.target_platform = '' 
            OR a.target_platform = 'all'
            OR v_user.effective_platform IS NULL
            OR EXISTS (
                SELECT 1 FROM unnest(string_to_array(v_user.effective_platform, ',')) AS user_platform
                WHERE TRIM(LOWER(user_platform)) = ANY(
                    SELECT TRIM(LOWER(p)) FROM unnest(string_to_array(a.target_platform, ',')) p
                )
            )
        )
        
        -- Real device targeting
        AND (
            a.target_is_real_device IS NULL
            OR v_user.effective_is_real_device IS NULL
            OR a.target_is_real_device = v_user.effective_is_real_device
        )
        
        -- Device brand targeting (both target and user can have multiple values)
        AND (
            a.target_device_brand IS NULL 
            OR a.target_device_brand = ''
            OR v_user.effective_device_brand IS NULL
            OR EXISTS (
                SELECT 1 FROM unnest(string_to_array(v_user.effective_device_brand, ',')) AS user_brand
                WHERE TRIM(LOWER(user_brand)) = ANY(
                    SELECT TRIM(LOWER(b)) FROM unnest(string_to_array(a.target_device_brand, ',')) b
                )
            )
        )
        
        -- IP address targeting (for testing, both target and user can have multiple values)
        AND (
            a.target_ip_addresses IS NULL 
            OR a.target_ip_addresses = ''
            OR v_user.effective_ip IS NULL
            OR EXISTS (
                SELECT 1 FROM unnest(string_to_array(v_user.effective_ip, ',')) AS user_ip
                WHERE TRIM(user_ip) = ANY(
                    SELECT TRIM(ip) FROM unnest(string_to_array(a.target_ip_addresses, ',')) ip
                )
            )
        )
        
        -- Specialty targeting (user can have multiple specialties, check if ANY match)
        AND (
            a.target_speciality IS NULL 
            OR a.target_speciality = ''
            OR v_user.insights IS NULL
            OR v_user.insights->>'specialty' IS NULL
            OR EXISTS (
                SELECT 1 FROM unnest(string_to_array(v_user.insights->>'specialty', ',')) AS user_spec
                WHERE TRIM(LOWER(user_spec)) = ANY(
                    SELECT TRIM(LOWER(s)) FROM unnest(string_to_array(a.target_speciality, ',')) s
                )
            )
        )
        
        -- Subspecialty targeting (user can have multiple subspecialties, check if ANY match)
        AND (
            a.target_subspecialty IS NULL 
            OR a.target_subspecialty = ''
            OR v_user.insights IS NULL
            OR v_user.insights->>'subspecialty' IS NULL
            OR EXISTS (
                SELECT 1 FROM unnest(string_to_array(v_user.insights->>'subspecialty', ',')) AS user_sub
                WHERE TRIM(LOWER(user_sub)) = ANY(
                    SELECT TRIM(LOWER(s)) FROM unnest(string_to_array(a.target_subspecialty, ',')) s
                )
            )
        )
        
        -- Degree targeting (user can have multiple degrees, check if ANY match)
        AND (
            a.target_degree IS NULL 
            OR a.target_degree = ''
            OR v_user.insights IS NULL
            OR v_user.insights->>'degree' IS NULL
            OR EXISTS (
                SELECT 1 FROM unnest(string_to_array(v_user.insights->>'degree', ',')) AS user_deg
                WHERE TRIM(LOWER(user_deg)) = ANY(
                    SELECT TRIM(LOWER(d)) FROM unnest(string_to_array(a.target_degree, ',')) d
                )
            )
        )
        
        -- Profession targeting (user can have multiple professions, check if ANY match)
        AND (
            a.target_profession IS NULL 
            OR a.target_profession = ''
            OR v_user.insights IS NULL
            OR v_user.insights->>'profession' IS NULL
            OR EXISTS (
                SELECT 1 FROM unnest(string_to_array(v_user.insights->>'profession', ',')) AS user_prof
                WHERE TRIM(LOWER(user_prof)) = ANY(
                    SELECT TRIM(LOWER(p)) FROM unnest(string_to_array(a.target_profession, ',')) p
                )
            )
        )
        
        -- Years Experience targeting (user can have multiple values, check if ANY match)
        AND (
            a.target_years_experience IS NULL 
            OR a.target_years_experience = ''
            OR v_user.insights IS NULL
            OR v_user.insights->>'years_experience' IS NULL
            OR EXISTS (
                SELECT 1 FROM unnest(string_to_array(v_user.insights->>'years_experience', ',')) AS user_exp
                WHERE TRIM(LOWER(user_exp)) = ANY(
                    SELECT TRIM(LOWER(e)) FROM unnest(string_to_array(a.target_years_experience, ',')) e
                )
            )
        )
        
        -- Hospital targeting (partial match - checks if ANY target hospital is contained in user's hospital)
        AND (
            a.target_hospital IS NULL 
            OR a.target_hospital = ''
            OR v_user.insights IS NULL
            OR v_user.insights->>'hospital' IS NULL
            OR EXISTS (
                SELECT 1 FROM unnest(string_to_array(a.target_hospital, ',')) AS target_hosp
                WHERE LOWER(v_user.insights->>'hospital') LIKE '%' || TRIM(LOWER(target_hosp)) || '%'
            )
        )
        
    ORDER BY 
        CASE a.importance 
            WHEN 'high' THEN 1 
            WHEN 'medium' THEN 2 
            ELSE 3 
        END,
        a.created_at DESC;
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER;

-- Grant execute permission
GRANT EXECUTE ON FUNCTION get_targeted_announcements TO authenticated;
GRANT EXECUTE ON FUNCTION get_targeted_announcements TO anon;

-- =====================================================
-- 7. CREATE VIEW FOR ADMIN DASHBOARD TARGETING STATS
-- =====================================================

CREATE OR REPLACE VIEW public.announcement_targeting_stats
WITH (security_invoker = true) AS
SELECT
    a.id,
    a.title,
    a.kind,
    a.surface,
    a.is_active,
    a.target_country,
    a.target_city,
    a.target_speciality,
    a.target_subspecialty,
    a.target_degree,
    a.target_profession,
    a.target_platform,
    a.target_is_real_device,
    a.target_logged_in_only,
    a.target_anonymous_only,
    -- Count potential audience
    (SELECT COUNT(*) FROM public.users u WHERE 
        (a.target_country IS NULL OR a.target_country = '' OR u.last_country = ANY(string_to_array(REPLACE(a.target_country, ' ', ''), ',')))
        AND (a.target_platform IS NULL OR a.target_platform = '' OR a.target_platform = 'all' OR LOWER(u.last_platform) = LOWER(a.target_platform))
    ) as potential_audience,
    a.created_at,
    a.updated_at
FROM public.announcements a
WHERE a.is_deleted = FALSE;

-- =====================================================
-- 8. BACKFILL USER LOCATIONS FROM EXISTING SESSIONS
-- =====================================================

-- Update users with their most recent session location data
UPDATE public.users u
SET 
    last_country = s.country,
    last_city = s.city,
    last_platform = s.os_platform,
    last_device_brand = s.device_brand,
    last_is_real_device = s.is_device,
    last_ip = s.public_ip,
    last_location_updated_at = s.start_time
FROM (
    SELECT DISTINCT ON (auth_uid) 
        auth_uid,
        country,
        city,
        os_platform,
        device_brand,
        is_device,
        public_ip,
        start_time
    FROM public.app_sessions
    WHERE auth_uid IS NOT NULL AND country IS NOT NULL
    ORDER BY auth_uid, start_time DESC
) s
WHERE u.auth_uid = s.auth_uid;

-- =====================================================
-- MIGRATION COMPLETE
-- =====================================================

SELECT 'Announcement Targeting Migration Complete!' as status;
