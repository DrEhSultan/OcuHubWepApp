-- =====================================================
-- Performance Optimization for Announcement Filtering
-- =====================================================
-- Add indexes to speed up the new exclusion targeting queries
-- =====================================================

-- 1. COMPOSITE INDEXES FOR ANNOUNCEMENT FILTERING
-- These indexes will speed up the WHERE clauses in get_eligible_announcements

-- Main filtering index (most selective filters first)
CREATE INDEX IF NOT EXISTS idx_announcements_active_filtering 
ON public.announcements (is_active, is_deleted, status, start_at, end_at) 
WHERE is_active = TRUE AND is_deleted = FALSE AND status = 'live';

-- Targeting indexes for faster exclusion logic
CREATE INDEX IF NOT EXISTS idx_announcements_profession_targeting 
ON public.announcements (target_profession, target_profession_exclude) 
WHERE target_profession IS NOT NULL AND target_profession != '';

CREATE INDEX IF NOT EXISTS idx_announcements_speciality_targeting 
ON public.announcements (target_speciality, target_speciality_exclude) 
WHERE target_speciality IS NOT NULL AND target_speciality != '';

CREATE INDEX IF NOT EXISTS idx_announcements_degree_targeting 
ON public.announcements (target_degree, target_degree_exclude) 
WHERE target_degree IS NOT NULL AND target_degree != '';

CREATE INDEX IF NOT EXISTS idx_announcements_country_targeting 
ON public.announcements (target_country, target_country_exclude) 
WHERE target_country IS NOT NULL AND target_country != '';

CREATE INDEX IF NOT EXISTS idx_announcements_city_targeting 
ON public.announcements (target_city, target_city_exclude) 
WHERE target_city IS NOT NULL AND target_city != '';

-- Ordering index for final sort
CREATE INDEX IF NOT EXISTS idx_announcements_ordering 
ON public.announcements (importance, display_sequence, created_at DESC);

-- 2. USER_ANNOUNCEMENT_STATE INDEXES (already exist but ensuring they're optimal)
-- These should already exist from the previous migration, but let's ensure they're there

CREATE INDEX IF NOT EXISTS idx_user_announcement_state_user_status_fast 
ON public.user_announcement_state (user_id, status, announcement_id);

CREATE INDEX IF NOT EXISTS idx_user_announcement_state_deferred 
ON public.user_announcement_state (status, defer_until_session, defer_until_time) 
WHERE status = 'deferred';

-- 3. ANALYZE TABLES TO UPDATE STATISTICS
-- This helps PostgreSQL choose better query plans
ANALYZE public.announcements;
ANALYZE public.user_announcement_state;

-- 4. OPTIMIZE get_eligible_announcements FUNCTION
-- Add a faster version with better query planning
CREATE OR REPLACE FUNCTION get_eligible_announcements_fast(
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
    WITH filtered_announcements AS (
        SELECT a.*
        FROM public.announcements a
        WHERE 
            -- Use the optimized index
            a.is_active = TRUE
            AND a.is_deleted = FALSE
            AND a.status = 'live'
            AND (a.surface = p_surface OR a.surface = 'modal')
            AND a.start_at <= NOW()
            AND (a.end_at IS NULL OR a.end_at > NOW())
            
            -- Platform targeting (simple check first)
            AND (a.target_platform IS NULL OR a.target_platform = 'all' OR a.target_platform = p_platform)
            
            -- Login state targeting (simple boolean check)
            AND (
                (a.target_logged_in_only = FALSE AND a.target_anonymous_only = FALSE)
                OR (a.target_logged_in_only = TRUE AND p_is_logged_in = TRUE)
                OR (a.target_anonymous_only = TRUE AND p_is_logged_in = FALSE)
            )
            
            -- Incomplete profile targeting (simple boolean check)
            AND (
                a.target_incomplete_profile = FALSE
                OR (a.target_incomplete_profile = TRUE AND p_has_complete_profile = FALSE)
            )
    ),
    user_state_filtered AS (
        SELECT 
            fa.*,
            uas.status,
            uas.impression_count,
            uas.is_partially_completed,
            uas.questions_answered,
            uas.defer_until_session,
            uas.defer_until_time
        FROM filtered_announcements fa
        LEFT JOIN public.user_announcement_state uas 
            ON uas.announcement_id = fa.id 
            AND uas.user_id = v_effective_user_id
        WHERE 
            -- User state filtering
            (
                uas.status IS NULL  -- Never seen
                OR uas.status = 'eligible'
                OR uas.status = 'seen'
                OR (uas.status = 'deferred' AND (
                    (uas.defer_until_session IS NOT NULL AND uas.defer_until_session <= p_session_number)
                    OR (uas.defer_until_time IS NOT NULL AND uas.defer_until_time <= NOW())
                ))
                OR (uas.status = 'completed' AND fa.repeat_mode != 'once')
            )
            AND uas.status IS DISTINCT FROM 'dismissed'
            AND uas.status IS DISTINCT FROM 'expired'
            
            -- Max impressions check
            AND (fa.max_times_seen_per_user IS NULL OR COALESCE(uas.impression_count, 0) < fa.max_times_seen_per_user)
    ),
    targeting_filtered AS (
        SELECT usf.*
        FROM user_state_filtered usf
        WHERE 
            -- Country targeting (with exclusion support)
            (
                (usf.target_country IS NULL OR usf.target_country = '')
                OR (
                    usf.target_country_exclude = FALSE 
                    AND p_country = ANY(string_to_array(usf.target_country, ','))
                )
                OR (
                    usf.target_country_exclude = TRUE 
                    AND (p_country IS NULL OR p_country NOT IN (SELECT unnest(string_to_array(usf.target_country, ','))))
                )
            )
            
            -- City targeting (with exclusion support)
            AND (
                (usf.target_city IS NULL OR usf.target_city = '')
                OR (
                    usf.target_city_exclude = FALSE 
                    AND p_city = ANY(string_to_array(usf.target_city, ','))
                )
                OR (
                    usf.target_city_exclude = TRUE 
                    AND (p_city IS NULL OR p_city NOT IN (SELECT unnest(string_to_array(usf.target_city, ','))))
                )
            )
            
            -- Profession targeting (with exclusion support)
            AND (
                (usf.target_profession IS NULL OR usf.target_profession = '')
                OR (
                    usf.target_profession_exclude = FALSE 
                    AND p_profession = ANY(string_to_array(usf.target_profession, ','))
                )
                OR (
                    usf.target_profession_exclude = TRUE 
                    AND (p_profession IS NULL OR p_profession NOT IN (SELECT unnest(string_to_array(usf.target_profession, ','))))
                )
            )
            
            -- Speciality targeting (with exclusion support)
            AND (
                (usf.target_speciality IS NULL OR usf.target_speciality = '')
                OR (
                    usf.target_speciality_exclude = FALSE 
                    AND p_speciality = ANY(string_to_array(usf.target_speciality, ','))
                )
                OR (
                    usf.target_speciality_exclude = TRUE 
                    AND (p_speciality IS NULL OR p_speciality NOT IN (SELECT unnest(string_to_array(usf.target_speciality, ','))))
                )
            )
            
            -- Degree targeting (with exclusion support)
            AND (
                (usf.target_degree IS NULL OR usf.target_degree = '')
                OR (
                    COALESCE(usf.target_degree_exclude, FALSE) = FALSE 
                    AND p_degree = ANY(string_to_array(usf.target_degree, ','))
                )
                OR (
                    usf.target_degree_exclude = TRUE 
                    AND (p_degree IS NULL OR p_degree NOT IN (SELECT unnest(string_to_array(usf.target_degree, ','))))
                )
            )
            
            -- Experience targeting (with exclusion support)
            AND (
                (usf.target_experience IS NULL OR usf.target_experience = '')
                OR (
                    COALESCE(usf.target_experience_exclude, FALSE) = FALSE 
                    AND p_experience = ANY(string_to_array(usf.target_experience, ','))
                )
                OR (
                    usf.target_experience_exclude = TRUE 
                    AND (p_experience IS NULL OR p_experience NOT IN (SELECT unnest(string_to_array(usf.target_experience, ','))))
                )
            )
    )
    SELECT 
        tf.id,
        tf.title,
        tf.message,
        tf.body,
        tf.surface,
        tf.importance,
        tf.kind,
        tf.priority,
        tf.action_type,
        tf.action_value,
        tf.dismissible,
        tf.dismissible_mode,
        tf.metadata,
        tf.questions,
        COALESCE(tf.status, 'eligible') AS user_status,
        COALESCE(tf.impression_count, 0) AS impression_count,
        COALESCE(tf.is_partially_completed, FALSE) AS is_partially_completed,
        COALESCE(tf.questions_answered, 0) AS questions_answered,
        tf.display_sequence
    FROM targeting_filtered tf
    ORDER BY 
        -- Priority ordering: high > medium > low importance
        CASE tf.importance 
            WHEN 'high' THEN 1 
            WHEN 'medium' THEN 2 
            WHEN 'low' THEN 3 
        END,
        -- Within same importance, use display_sequence (admin-controlled)
        tf.display_sequence ASC NULLS LAST,
        -- Then by creation date (newest first for low importance)
        tf.created_at DESC
    LIMIT p_limit
    OFFSET p_offset;
END;
$func$;

-- Grant execute permissions
GRANT EXECUTE ON FUNCTION get_eligible_announcements_fast TO authenticated, anon;