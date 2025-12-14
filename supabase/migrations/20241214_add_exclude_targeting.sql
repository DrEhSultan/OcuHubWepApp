-- =====================================================
-- Exclusion Targeting Migration
-- =====================================================
-- Adds ability to target users by EXCLUDING certain values
-- e.g., "Show to users who are NOT ophthalmologists"
-- =====================================================

-- 1. ADD EXCLUSION MODE COLUMNS TO ANNOUNCEMENTS
-- Each targeting field gets a corresponding exclusion flag

-- Profession exclusion
ALTER TABLE public.announcements 
ADD COLUMN IF NOT EXISTS target_profession_exclude BOOLEAN DEFAULT FALSE;

-- Speciality exclusion
ALTER TABLE public.announcements 
ADD COLUMN IF NOT EXISTS target_speciality_exclude BOOLEAN DEFAULT FALSE;

-- Degree exclusion
ALTER TABLE public.announcements 
ADD COLUMN IF NOT EXISTS target_degree_exclude BOOLEAN DEFAULT FALSE;

-- Experience level exclusion
ALTER TABLE public.announcements 
ADD COLUMN IF NOT EXISTS target_experience_exclude BOOLEAN DEFAULT FALSE;

-- Country exclusion
ALTER TABLE public.announcements 
ADD COLUMN IF NOT EXISTS target_country_exclude BOOLEAN DEFAULT FALSE;

-- City exclusion
ALTER TABLE public.announcements 
ADD COLUMN IF NOT EXISTS target_city_exclude BOOLEAN DEFAULT FALSE;

-- 2. ADD "INCOMPLETE PROFILE" TARGETING
-- Target users who haven't completed their profile/insights
ALTER TABLE public.announcements 
ADD COLUMN IF NOT EXISTS target_incomplete_profile BOOLEAN DEFAULT FALSE;

-- 3. DROP AND RECREATE get_eligible_announcements FUNCTION WITH EXCLUSION LOGIC
-- Drop existing function first to avoid parameter conflicts
DROP FUNCTION IF EXISTS get_eligible_announcements;

CREATE OR REPLACE FUNCTION get_eligible_announcements(
    p_user_id TEXT,
    p_device_id TEXT DEFAULT NULL,
    p_auth_uid TEXT DEFAULT NULL,
    p_platform TEXT DEFAULT NULL,
    p_app_version TEXT DEFAULT NULL,
    p_country TEXT DEFAULT NULL,
    p_city TEXT DEFAULT NULL,
    p_is_logged_in BOOLEAN DEFAULT FALSE,
    p_profession TEXT DEFAULT NULL,
    p_speciality TEXT DEFAULT NULL,
    p_degree TEXT DEFAULT NULL,
    p_experience TEXT DEFAULT NULL,
    p_has_complete_profile BOOLEAN DEFAULT FALSE,
    p_session_number INTEGER DEFAULT 1,
    p_surface TEXT DEFAULT 'home_banner',
    p_limit INTEGER DEFAULT 10,
    p_offset INTEGER DEFAULT 0
)
RETURNS TABLE (
    id UUID,
    title TEXT,
    message TEXT,
    body TEXT,
    surface TEXT,
    importance TEXT,
    kind TEXT,
    priority TEXT,
    action_type TEXT,
    action_value TEXT,
    dismissible BOOLEAN,
    dismissible_mode TEXT,
    metadata JSONB,
    questions JSONB,
    user_status TEXT,
    impression_count INTEGER,
    is_partially_completed BOOLEAN,
    questions_answered INTEGER,
    display_sequence INTEGER
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $func$
DECLARE
    v_effective_user_id TEXT;
BEGIN
    -- Determine effective user ID (prefer auth_uid, fallback to device_id)
    v_effective_user_id := COALESCE(p_auth_uid, p_device_id, p_user_id);
    
    RETURN QUERY
    SELECT 
        a.id,
        a.title,
        a.message,
        a.body,
        a.surface,
        a.importance,
        a.kind,
        a.priority,
        a.action_type,
        a.action_value,
        a.dismissible,
        a.dismissible_mode,
        a.metadata,
        a.questions,
        COALESCE(uas.status, 'eligible') AS user_status,
        COALESCE(uas.impression_count, 0) AS impression_count,
        COALESCE(uas.is_partially_completed, FALSE) AS is_partially_completed,
        COALESCE(uas.questions_answered, 0) AS questions_answered,
        a.display_sequence
    FROM public.announcements a
    LEFT JOIN public.user_announcement_state uas 
        ON uas.announcement_id = a.id 
        AND uas.user_id = v_effective_user_id
    WHERE 
        -- Basic filters
        a.is_active = TRUE
        AND a.is_deleted = FALSE
        AND a.status = 'live'
        AND (a.surface = p_surface OR a.surface = 'modal')
        
        -- Date range
        AND a.start_at <= NOW()
        AND (a.end_at IS NULL OR a.end_at > NOW())
        
        -- User hasn't completed/dismissed (unless deferred and ready to show)
        AND (
            uas.status IS NULL  -- Never seen
            OR uas.status = 'eligible'
            OR uas.status = 'seen'
            OR (uas.status = 'deferred' AND (
                (uas.defer_until_session IS NOT NULL AND uas.defer_until_session <= p_session_number)
                OR (uas.defer_until_time IS NOT NULL AND uas.defer_until_time <= NOW())
            ))
            OR (uas.status = 'completed' AND a.repeat_mode != 'once')
        )
        AND uas.status IS DISTINCT FROM 'dismissed'
        AND uas.status IS DISTINCT FROM 'expired'
        
        -- Max impressions check
        AND (a.max_times_seen_per_user IS NULL OR COALESCE(uas.impression_count, 0) < a.max_times_seen_per_user)
        
        -- Platform targeting
        AND (a.target_platform IS NULL OR a.target_platform = 'all' OR a.target_platform = p_platform)
        
        -- Login state targeting
        AND (
            (a.target_logged_in_only = FALSE AND a.target_anonymous_only = FALSE)
            OR (a.target_logged_in_only = TRUE AND p_is_logged_in = TRUE)
            OR (a.target_anonymous_only = TRUE AND p_is_logged_in = FALSE)
        )
        
        -- Incomplete profile targeting
        AND (
            a.target_incomplete_profile = FALSE
            OR (a.target_incomplete_profile = TRUE AND p_has_complete_profile = FALSE)
        )
        
        -- Country targeting (with exclusion support)
        AND (
            (a.target_country IS NULL OR a.target_country = '')
            OR (
                a.target_country_exclude = FALSE 
                AND p_country = ANY(string_to_array(a.target_country, ','))
            )
            OR (
                a.target_country_exclude = TRUE 
                AND (p_country IS NULL OR p_country NOT IN (SELECT unnest(string_to_array(a.target_country, ','))))
            )
        )
        
        -- City targeting (with exclusion support)
        AND (
            (a.target_city IS NULL OR a.target_city = '')
            OR (
                a.target_city_exclude = FALSE 
                AND p_city = ANY(string_to_array(a.target_city, ','))
            )
            OR (
                a.target_city_exclude = TRUE 
                AND (p_city IS NULL OR p_city NOT IN (SELECT unnest(string_to_array(a.target_city, ','))))
            )
        )
        
        -- Profession targeting (with exclusion support)
        AND (
            (a.target_profession IS NULL OR a.target_profession = '')
            OR (
                a.target_profession_exclude = FALSE 
                AND p_profession = ANY(string_to_array(a.target_profession, ','))
            )
            OR (
                a.target_profession_exclude = TRUE 
                AND (p_profession IS NULL OR p_profession NOT IN (SELECT unnest(string_to_array(a.target_profession, ','))))
            )
        )
        
        -- Speciality targeting (with exclusion support)
        AND (
            (a.target_speciality IS NULL OR a.target_speciality = '')
            OR (
                a.target_speciality_exclude = FALSE 
                AND p_speciality = ANY(string_to_array(a.target_speciality, ','))
            )
            OR (
                a.target_speciality_exclude = TRUE 
                AND (p_speciality IS NULL OR p_speciality NOT IN (SELECT unnest(string_to_array(a.target_speciality, ','))))
            )
        )
        
        -- Degree targeting (with exclusion support)
        AND (
            (a.target_degree IS NULL OR a.target_degree = '')
            OR (
                COALESCE(a.target_degree_exclude, FALSE) = FALSE 
                AND p_degree = ANY(string_to_array(a.target_degree, ','))
            )
            OR (
                a.target_degree_exclude = TRUE 
                AND (p_degree IS NULL OR p_degree NOT IN (SELECT unnest(string_to_array(a.target_degree, ','))))
            )
        )
        
        -- Experience targeting (with exclusion support)
        AND (
            (a.target_experience IS NULL OR a.target_experience = '')
            OR (
                COALESCE(a.target_experience_exclude, FALSE) = FALSE 
                AND p_experience = ANY(string_to_array(a.target_experience, ','))
            )
            OR (
                a.target_experience_exclude = TRUE 
                AND (p_experience IS NULL OR p_experience NOT IN (SELECT unnest(string_to_array(a.target_experience, ','))))
            )
        )
        
    ORDER BY 
        -- Priority ordering: high > medium > low importance
        CASE a.importance 
            WHEN 'high' THEN 1 
            WHEN 'medium' THEN 2 
            WHEN 'low' THEN 3 
        END,
        -- Within same importance, use display_sequence (admin-controlled)
        a.display_sequence ASC NULLS LAST,
        -- Then by creation date (newest first for low importance)
        a.created_at DESC
    LIMIT p_limit
    OFFSET p_offset;
END;
$func$;


-- 4. DROP AND RECREATE get_carousel_announcements to pass new parameters
DROP FUNCTION IF EXISTS get_carousel_announcements;

CREATE OR REPLACE FUNCTION get_carousel_announcements(
    p_user_id TEXT,
    p_device_id TEXT DEFAULT NULL,
    p_auth_uid TEXT DEFAULT NULL,
    p_platform TEXT DEFAULT NULL,
    p_app_version TEXT DEFAULT NULL,
    p_country TEXT DEFAULT NULL,
    p_city TEXT DEFAULT NULL,
    p_is_logged_in BOOLEAN DEFAULT FALSE,
    p_profession TEXT DEFAULT NULL,
    p_speciality TEXT DEFAULT NULL,
    p_degree TEXT DEFAULT NULL,
    p_experience TEXT DEFAULT NULL,
    p_has_complete_profile BOOLEAN DEFAULT FALSE,
    p_session_number INTEGER DEFAULT 1
)
RETURNS TABLE (
    id UUID,
    title TEXT,
    message TEXT,
    body TEXT,
    surface TEXT,
    importance TEXT,
    kind TEXT,
    priority TEXT,
    action_type TEXT,
    action_value TEXT,
    dismissible BOOLEAN,
    dismissible_mode TEXT,
    metadata JSONB,
    questions JSONB,
    user_status TEXT,
    impression_count INTEGER,
    is_partially_completed BOOLEAN,
    questions_answered INTEGER,
    display_sequence INTEGER,
    carousel_position INTEGER
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $func$
DECLARE
    v_max_items INTEGER;
BEGIN
    -- Get max carousel items from config
    SELECT (config_value::TEXT)::INTEGER INTO v_max_items 
    FROM public.announcement_config 
    WHERE config_key = 'carousel_max_items';
    
    v_max_items := COALESCE(v_max_items, 5);
    
    RETURN QUERY
    WITH eligible AS (
        SELECT 
            e.*,
            ROW_NUMBER() OVER (
                ORDER BY 
                    CASE e.importance 
                        WHEN 'high' THEN 1 
                        WHEN 'medium' THEN 2 
                        WHEN 'low' THEN 3 
                    END,
                    e.display_sequence ASC NULLS LAST,
                    CASE WHEN e.is_partially_completed THEN 0 ELSE 1 END,
                    e.id DESC
            ) AS carousel_position
        FROM get_eligible_announcements(
            p_user_id,
            p_device_id,
            p_auth_uid,
            p_platform,
            p_app_version,
            p_country,
            p_city,
            p_is_logged_in,
            p_profession,
            p_speciality,
            p_degree,
            p_experience,
            p_has_complete_profile,
            p_session_number,
            'home_banner',
            100,
            0
        ) e
        WHERE e.surface IN ('home_banner', 'modal')
    )
    SELECT 
        eligible.id,
        eligible.title,
        eligible.message,
        eligible.body,
        eligible.surface,
        eligible.importance,
        eligible.kind,
        eligible.priority,
        eligible.action_type,
        eligible.action_value,
        eligible.dismissible,
        eligible.dismissible_mode,
        eligible.metadata,
        eligible.questions,
        eligible.user_status,
        eligible.impression_count,
        eligible.is_partially_completed,
        eligible.questions_answered,
        eligible.display_sequence,
        eligible.carousel_position::INTEGER
    FROM eligible
    WHERE eligible.carousel_position <= v_max_items;
END;
$func$;


-- 5. DROP AND RECREATE get_inbox_announcements to pass new parameters
DROP FUNCTION IF EXISTS get_inbox_announcements;

CREATE OR REPLACE FUNCTION get_inbox_announcements(
    p_user_id TEXT,
    p_device_id TEXT DEFAULT NULL,
    p_auth_uid TEXT DEFAULT NULL,
    p_platform TEXT DEFAULT NULL,
    p_is_logged_in BOOLEAN DEFAULT FALSE,
    p_profession TEXT DEFAULT NULL,
    p_speciality TEXT DEFAULT NULL,
    p_degree TEXT DEFAULT NULL,
    p_experience TEXT DEFAULT NULL,
    p_has_complete_profile BOOLEAN DEFAULT FALSE,
    p_session_number INTEGER DEFAULT 1,
    p_page INTEGER DEFAULT 1,
    p_page_size INTEGER DEFAULT 20
)
RETURNS TABLE (
    id UUID,
    title TEXT,
    message TEXT,
    body TEXT,
    surface TEXT,
    importance TEXT,
    kind TEXT,
    priority TEXT,
    action_type TEXT,
    action_value TEXT,
    dismissible BOOLEAN,
    dismissible_mode TEXT,
    metadata JSONB,
    questions JSONB,
    user_status TEXT,
    impression_count INTEGER,
    is_partially_completed BOOLEAN,
    questions_answered INTEGER,
    display_sequence INTEGER,
    total_count BIGINT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $func$
DECLARE
    v_offset INTEGER;
    v_total BIGINT;
BEGIN
    v_offset := (p_page - 1) * p_page_size;
    
    -- Get total count first
    SELECT COUNT(*) INTO v_total
    FROM get_eligible_announcements(
        p_user_id, p_device_id, p_auth_uid, p_platform, NULL,
        NULL, NULL, p_is_logged_in, p_profession, p_speciality,
        p_degree, p_experience, p_has_complete_profile,
        p_session_number, 'inbox', 1000, 0
    );
    
    RETURN QUERY
    SELECT 
        e.id,
        e.title,
        e.message,
        e.body,
        e.surface,
        e.importance,
        e.kind,
        e.priority,
        e.action_type,
        e.action_value,
        e.dismissible,
        e.dismissible_mode,
        e.metadata,
        e.questions,
        e.user_status,
        e.impression_count,
        e.is_partially_completed,
        e.questions_answered,
        e.display_sequence,
        v_total AS total_count
    FROM get_eligible_announcements(
        p_user_id, p_device_id, p_auth_uid, p_platform, NULL,
        NULL, NULL, p_is_logged_in, p_profession, p_speciality,
        p_degree, p_experience, p_has_complete_profile,
        p_session_number, 'inbox', p_page_size, v_offset
    ) e;
END;
$func$;

-- Grant execute permissions
GRANT EXECUTE ON FUNCTION get_eligible_announcements TO authenticated, anon;
GRANT EXECUTE ON FUNCTION get_carousel_announcements TO authenticated, anon;
GRANT EXECUTE ON FUNCTION get_inbox_announcements TO authenticated, anon;