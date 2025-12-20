-- Migration: Add Device Type Filtering
-- Date: 2025-12-20
-- 
-- ISSUE: Device type filter (Real Devices vs Emulators) is not working.
-- The get_eligible_announcements function is missing the p_is_real_device parameter
-- and the target_is_real_device filtering logic.
--
-- FIX: Add p_is_real_device parameter and filtering logic to respect
-- target_is_real_device setting in announcements.

DROP FUNCTION IF EXISTS public.get_eligible_announcements(text,text,text,text,text,text,text,boolean,text,text,text,text,boolean,integer,text,integer,integer);

CREATE OR REPLACE FUNCTION public.get_eligible_announcements(
    p_user_id text,
    p_device_id text DEFAULT NULL::text,
    p_auth_uid text DEFAULT NULL::text,
    p_platform text DEFAULT NULL::text,
    p_app_version text DEFAULT NULL::text,
    p_country text DEFAULT NULL::text,
    p_city text DEFAULT NULL::text,
    p_is_logged_in boolean DEFAULT false,
    p_profession text DEFAULT NULL::text,
    p_speciality text DEFAULT NULL::text,
    p_degree text DEFAULT NULL::text,
    p_experience text DEFAULT NULL::text,
    p_has_complete_profile boolean DEFAULT false,
    p_session_number integer DEFAULT 1,
    p_surface text DEFAULT 'home_banner'::text,
    p_is_real_device boolean DEFAULT NULL::boolean,
    p_limit integer DEFAULT 10,
    p_offset integer DEFAULT 0
) RETURNS TABLE(
    id uuid,
    title text,
    message text,
    body text,
    surface text,
    importance text,
    kind text,
    priority text,
    action_type text,
    action_value text,
    dismissible boolean,
    dismissible_mode text,
    remind_later_count integer,
    remind_later_sessions integer,
    repeat_mode text,
    repeat_interval_hours integer,
    repeat_session_interval integer,
    first_view_session_delay integer,
    max_times_seen_per_user integer,
    metadata jsonb,
    questions jsonb,
    user_status text,
    impression_count integer,
    is_partially_completed boolean,
    questions_answered integer,
    display_sequence integer,
    disappear_after_cta boolean,
    last_seen_session integer,
    defer_count integer,
    defer_until_session integer,
    first_seen_at timestamp with time zone,
    last_seen_at timestamp with time zone,
    is_read boolean
)
LANGUAGE plpgsql SECURITY DEFINER
AS $function$
DECLARE
    v_effective_user_id TEXT;
BEGIN
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
        COALESCE(a.remind_later_count, 3) AS remind_later_count,
        COALESCE(a.remind_later_sessions, 1) AS remind_later_sessions,
        COALESCE(a.repeat_mode, 'once') AS repeat_mode,
        a.repeat_interval_hours,
        COALESCE(a.repeat_session_interval, 1) AS repeat_session_interval,
        COALESCE(a.first_view_session_delay, 0) AS first_view_session_delay,
        a.max_times_seen_per_user,
        a.metadata,
        a.questions,
        COALESCE(uas.status, 'eligible') AS user_status,
        COALESCE(uas.impression_count, 0) AS impression_count,
        COALESCE(uas.is_partially_completed, FALSE) AS is_partially_completed,
        COALESCE(uas.questions_answered, 0) AS questions_answered,
        a.display_sequence,
        COALESCE(a.disappear_after_cta, TRUE) AS disappear_after_cta,
        COALESCE(uas.last_seen_session, 0) AS last_seen_session,
        COALESCE(uas.defer_count, 0) AS defer_count,
        uas.defer_until_session,
        uas.first_seen_at,
        uas.last_seen_at,
        -- CRITICAL FIX: For keep showing mode, only mark as read when dismissed
        CASE 
            WHEN COALESCE(a.disappear_after_cta, TRUE) = FALSE THEN 
                (uas.status = 'dismissed')
            ELSE 
                (COALESCE(uas.impression_count, 0) > 0)
        END AS is_read
    FROM public.announcements a
    LEFT JOIN public.user_announcement_state uas 
        ON uas.announcement_id = a.id 
        AND uas.user_id = v_effective_user_id
    WHERE 
        a.is_deleted = FALSE
        AND (
            -- INBOX
            (
                p_surface = 'inbox' 
                AND a.surface IN ('home_banner', 'modal', 'inbox')
                AND (
                    uas.status IS NOT NULL
                    OR (
                        a.is_active = TRUE
                        AND (a.status = 'live' OR a.status = 'published' OR a.status IS NULL)
                        AND a.start_at <= NOW()
                        AND (a.end_at IS NULL OR a.end_at > NOW())
                    )
                )
            )
            -- OTHER SURFACES
            OR (
                p_surface != 'inbox'
                AND a.is_active = TRUE
                AND (a.status = 'live' OR a.status = 'published' OR a.status IS NULL)
                AND a.start_at <= NOW()
                AND (a.end_at IS NULL OR a.end_at > NOW())
                AND (a.surface = p_surface OR a.surface = 'modal')
            )
        )
        
        -- TARGETING FILTERS
        AND (a.target_logged_in_only = FALSE OR p_is_logged_in = TRUE)
        AND (a.target_anonymous_only = FALSE OR p_is_logged_in = FALSE)
        AND (a.target_incomplete_profile = FALSE OR p_has_complete_profile = FALSE)
        AND (
            (a.target_country IS NULL OR a.target_country = '')
            OR (COALESCE(a.target_country_exclude, FALSE) = FALSE AND p_country = ANY(string_to_array(a.target_country, ',')))
            OR (a.target_country_exclude = TRUE AND (p_country IS NULL OR p_country NOT IN (SELECT unnest(string_to_array(a.target_country, ',')))))
        )
        AND (
            (a.target_city IS NULL OR a.target_city = '')
            OR (COALESCE(a.target_city_exclude, FALSE) = FALSE AND p_city = ANY(string_to_array(a.target_city, ',')))
            OR (a.target_city_exclude = TRUE AND (p_city IS NULL OR p_city NOT IN (SELECT unnest(string_to_array(a.target_city, ',')))))
        )
        AND (
            (a.target_profession IS NULL OR a.target_profession = '')
            OR (COALESCE(a.target_profession_exclude, FALSE) = FALSE AND p_profession = ANY(string_to_array(a.target_profession, ',')))
            OR (a.target_profession_exclude = TRUE AND (p_profession IS NULL OR p_profession NOT IN (SELECT unnest(string_to_array(a.target_profession, ',')))))
        )
        AND (
            (a.target_speciality IS NULL OR a.target_speciality = '')
            OR (COALESCE(a.target_speciality_exclude, FALSE) = FALSE AND p_speciality = ANY(string_to_array(a.target_speciality, ',')))
            OR (a.target_speciality_exclude = TRUE AND (p_speciality IS NULL OR p_speciality NOT IN (SELECT unnest(string_to_array(a.target_speciality, ',')))))
        )
        AND (
            (a.target_degree IS NULL OR a.target_degree = '')
            OR (COALESCE(a.target_degree_exclude, FALSE) = FALSE AND p_degree = ANY(string_to_array(a.target_degree, ',')))
            OR (a.target_degree_exclude = TRUE AND (p_degree IS NULL OR p_degree NOT IN (SELECT unnest(string_to_array(a.target_degree, ',')))))
        )
        AND (
            (a.target_years_experience IS NULL OR a.target_years_experience = '')
            OR (COALESCE(a.target_experience_exclude, FALSE) = FALSE AND p_experience = ANY(string_to_array(a.target_years_experience, ',')))
            OR (a.target_experience_exclude = TRUE AND (p_experience IS NULL OR p_experience NOT IN (SELECT unnest(string_to_array(a.target_years_experience, ',')))))
        )
        AND (a.target_platform IS NULL OR a.target_platform = '' OR p_platform = ANY(string_to_array(a.target_platform, ',')))
        
        -- DEVICE TYPE FILTER (skip for inbox - inbox shows all announcements)
        -- If announcement has device type targeting AND we know user's device type, apply filter
        -- If we don't know user's device type (NULL), only show announcements without device targeting
        AND (
            p_surface = 'inbox'
            OR a.target_is_real_device IS NULL
            OR (p_is_real_device IS NOT NULL AND a.target_is_real_device = p_is_real_device)
        )
        
        -- FIRST VIEW SESSION DELAY
        AND (
            p_surface = 'inbox'
            OR uas.status IS NOT NULL
            OR COALESCE(a.first_view_session_delay, 0) = 0
            OR p_session_number >= COALESCE(a.first_view_session_delay, 0)
        )
        
        -- ELIGIBILITY LOGIC
        AND (
            p_surface = 'inbox'
            OR uas.status IS NULL
            OR uas.status = 'eligible'
            -- SEEN: normal repeat mode (NOT for remind_later with defer_count > 0)
            OR (
                uas.status = 'seen'
                AND NOT (a.dismissible_mode = 'remind_later' AND COALESCE(uas.defer_count, 0) > 0)
                AND COALESCE(a.repeat_mode, 'once') = 'per_app_open'
                AND (p_session_number - COALESCE(uas.last_seen_session, 0)) >= COALESCE(a.repeat_session_interval, 1)
            )
            OR (
                uas.status = 'seen'
                AND NOT (a.dismissible_mode = 'remind_later' AND COALESCE(uas.defer_count, 0) > 0)
                AND COALESCE(a.repeat_mode, 'once') = 'interval_hours'
                AND (uas.last_seen_at IS NULL OR (NOW() - uas.last_seen_at) >= (COALESCE(a.repeat_interval_hours, 24) * INTERVAL '1 hour'))
            )
            -- DEFERRED: show when session >= defer_until_session AND defer_count < remind_later_count
            OR (
                uas.status = 'deferred'
                AND COALESCE(uas.defer_count, 0) < COALESCE(a.remind_later_count, 3)
                AND (uas.defer_until_session IS NULL OR p_session_number >= uas.defer_until_session)
            )
        )
        
        -- MAX VIEWS CHECK - Skip for remind_later mode
        AND (
            p_surface = 'inbox'
            OR (a.dismissible_mode = 'remind_later' AND uas.status = 'deferred')
            OR a.max_times_seen_per_user IS NULL
            OR a.max_times_seen_per_user = 0
            OR COALESCE(uas.impression_count, 0) < a.max_times_seen_per_user
        )
        
        -- REMIND LATER EXHAUSTED - Stop when defer_count >= remind_later_count
        AND (
            p_surface = 'inbox'
            OR a.dismissible_mode != 'remind_later'
            OR uas.status != 'deferred'
            OR COALESCE(uas.defer_count, 0) < COALESCE(a.remind_later_count, 3)
        )
        
        -- DISAPPEAR AFTER CTA
        AND (
            p_surface = 'inbox'
            OR COALESCE(a.disappear_after_cta, TRUE) = FALSE
            OR uas.status IS NULL
            OR uas.status != 'completed'
        )
        
        -- EXCLUDE DISMISSED
        AND (
            p_surface = 'inbox'
            OR uas.status IS NULL
            OR uas.status != 'dismissed'
        )
        
    ORDER BY 
        CASE WHEN p_surface = 'inbox' THEN 
            CASE WHEN COALESCE(uas.impression_count, 0) = 0 THEN 0 ELSE 1 END
        ELSE 0 END,
        CASE a.importance WHEN 'high' THEN 1 WHEN 'medium' THEN 2 WHEN 'low' THEN 3 END,
        a.display_sequence ASC NULLS LAST,
        a.created_at DESC
    LIMIT p_limit
    OFFSET p_offset;
END;
$function$;

GRANT ALL ON FUNCTION public.get_eligible_announcements(text,text,text,text,text,text,text,boolean,text,text,text,text,boolean,integer,text,boolean,integer,integer) TO anon;
GRANT ALL ON FUNCTION public.get_eligible_announcements(text,text,text,text,text,text,text,boolean,text,text,text,text,boolean,integer,text,boolean,integer,integer) TO authenticated;
GRANT ALL ON FUNCTION public.get_eligible_announcements(text,text,text,text,text,text,text,boolean,text,text,text,text,boolean,integer,text,boolean,integer,integer) TO service_role;

-- ============================================================================
-- SUMMARY:
-- ============================================================================
-- 
-- CHANGES:
-- 1. Added p_is_real_device parameter (boolean) after p_surface
-- 2. Added device type filtering logic (line 195-200):
--    - If target_is_real_device is NULL: show to all devices
--    - If p_is_real_device is NULL: show announcement (can't determine device type)
--    - Otherwise: only show if target_is_real_device matches p_is_real_device
--
-- BEHAVIOR:
-- - Announcements with target_is_real_device = true: only show on real devices
-- - Announcements with target_is_real_device = false: only show on emulators
-- - Announcements with target_is_real_device = NULL: show on all devices
--
-- ============================================================================


-- ============================================================================
-- UPDATE get_carousel_announcements to pass is_real_device parameter
-- ============================================================================

DROP FUNCTION IF EXISTS public.get_carousel_announcements(text,text,text,text,text,text,text,boolean,text,text,text,text,boolean,integer);

CREATE OR REPLACE FUNCTION public.get_carousel_announcements(
    p_user_id text,
    p_device_id text DEFAULT NULL::text,
    p_auth_uid text DEFAULT NULL::text,
    p_platform text DEFAULT NULL::text,
    p_app_version text DEFAULT NULL::text,
    p_country text DEFAULT NULL::text,
    p_city text DEFAULT NULL::text,
    p_is_logged_in boolean DEFAULT false,
    p_profession text DEFAULT NULL::text,
    p_speciality text DEFAULT NULL::text,
    p_degree text DEFAULT NULL::text,
    p_experience text DEFAULT NULL::text,
    p_has_complete_profile boolean DEFAULT false,
    p_session_number integer DEFAULT 1,
    p_is_real_device boolean DEFAULT NULL::boolean
) RETURNS TABLE(
    id uuid,
    title text,
    message text,
    body text,
    surface text,
    importance text,
    kind text,
    priority text,
    action_type text,
    action_value text,
    dismissible boolean,
    dismissible_mode text,
    remind_later_count integer,
    remind_later_sessions integer,
    repeat_mode text,
    repeat_interval_hours integer,
    repeat_session_interval integer,
    first_view_session_delay integer,
    max_times_seen_per_user integer,
    metadata jsonb,
    questions jsonb,
    user_status text,
    impression_count integer,
    is_partially_completed boolean,
    questions_answered integer,
    display_sequence integer,
    disappear_after_cta boolean,
    last_seen_session integer,
    defer_count integer,
    defer_until_session integer,
    first_seen_at timestamp with time zone,
    last_seen_at timestamp with time zone,
    is_read boolean,
    carousel_position integer
)
LANGUAGE plpgsql SECURITY DEFINER
AS $function$
DECLARE
    v_max_items INTEGER;
BEGIN
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
                    CASE e.importance WHEN 'high' THEN 1 WHEN 'medium' THEN 2 WHEN 'low' THEN 3 END,
                    e.display_sequence ASC NULLS LAST,
                    CASE WHEN e.is_partially_completed THEN 0 ELSE 1 END,
                    e.id DESC
            ) AS pos
        FROM get_eligible_announcements(
            p_user_id, p_device_id, p_auth_uid, p_platform, p_app_version,
            p_country, p_city, p_is_logged_in, p_profession, p_speciality,
            p_degree, p_experience, p_has_complete_profile, p_session_number,
            'home_banner', p_is_real_device, 100, 0
        ) e
        WHERE e.surface IN ('home_banner', 'modal')
    )
    SELECT 
        eligible.id, eligible.title, eligible.message, eligible.body,
        eligible.surface, eligible.importance, eligible.kind, eligible.priority,
        eligible.action_type, eligible.action_value, eligible.dismissible,
        eligible.dismissible_mode, eligible.remind_later_count, eligible.remind_later_sessions,
        eligible.repeat_mode, eligible.repeat_interval_hours, eligible.repeat_session_interval,
        eligible.first_view_session_delay, eligible.max_times_seen_per_user,
        eligible.metadata, eligible.questions,
        eligible.user_status, eligible.impression_count, eligible.is_partially_completed,
        eligible.questions_answered, eligible.display_sequence,
        eligible.disappear_after_cta, eligible.last_seen_session, eligible.defer_count,
        eligible.defer_until_session, eligible.first_seen_at, eligible.last_seen_at,
        eligible.is_read, eligible.pos::INTEGER AS carousel_position
    FROM eligible
    WHERE eligible.pos <= v_max_items;
END;
$function$;

GRANT ALL ON FUNCTION public.get_carousel_announcements(text,text,text,text,text,text,text,boolean,text,text,text,text,boolean,integer,boolean) TO anon;
GRANT ALL ON FUNCTION public.get_carousel_announcements(text,text,text,text,text,text,text,boolean,text,text,text,text,boolean,integer,boolean) TO authenticated;
GRANT ALL ON FUNCTION public.get_carousel_announcements(text,text,text,text,text,text,text,boolean,text,text,text,text,boolean,integer,boolean) TO service_role;


-- ============================================================================
-- UPDATE get_inbox_announcements to pass is_real_device parameter
-- ============================================================================

DROP FUNCTION IF EXISTS public.get_inbox_announcements(text,text,text,text,text,text,boolean,text,text,text,text,boolean,integer,integer,integer);

CREATE OR REPLACE FUNCTION public.get_inbox_announcements(
    p_user_id text,
    p_device_id text DEFAULT NULL::text,
    p_auth_uid text DEFAULT NULL::text,
    p_platform text DEFAULT NULL::text,
    p_country text DEFAULT NULL::text,
    p_city text DEFAULT NULL::text,
    p_is_logged_in boolean DEFAULT false,
    p_profession text DEFAULT NULL::text,
    p_speciality text DEFAULT NULL::text,
    p_degree text DEFAULT NULL::text,
    p_experience text DEFAULT NULL::text,
    p_has_complete_profile boolean DEFAULT false,
    p_session_number integer DEFAULT 1,
    p_page integer DEFAULT 1,
    p_page_size integer DEFAULT 20
) RETURNS TABLE(
    id uuid,
    title text,
    message text,
    body text,
    surface text,
    importance text,
    kind text,
    priority text,
    action_type text,
    action_value text,
    dismissible boolean,
    dismissible_mode text,
    remind_later_count integer,
    remind_later_sessions integer,
    repeat_mode text,
    repeat_interval_hours integer,
    repeat_session_interval integer,
    first_view_session_delay integer,
    max_times_seen_per_user integer,
    metadata jsonb,
    questions jsonb,
    user_status text,
    impression_count integer,
    is_partially_completed boolean,
    questions_answered integer,
    display_sequence integer,
    disappear_after_cta boolean,
    last_seen_session integer,
    defer_count integer,
    defer_until_session integer,
    first_seen_at timestamp with time zone,
    last_seen_at timestamp with time zone,
    is_read boolean,
    total_count bigint
)
LANGUAGE plpgsql SECURITY DEFINER
AS $function$
DECLARE
    v_offset INTEGER;
    v_total BIGINT;
BEGIN
    v_offset := (p_page - 1) * p_page_size;
    
    -- Get total count (pass NULL for is_real_device - inbox shows all)
    SELECT COUNT(*) INTO v_total
    FROM get_eligible_announcements(
        p_user_id, p_device_id, p_auth_uid, p_platform, NULL,
        p_country, p_city, p_is_logged_in, p_profession, p_speciality,
        p_degree, p_experience, p_has_complete_profile,
        p_session_number, 'inbox', NULL, 1000, 0
    );
    
    -- Get paginated results (pass NULL for is_real_device - inbox shows all)
    RETURN QUERY
    SELECT 
        e.id, e.title, e.message, e.body, e.surface, e.importance,
        e.kind, e.priority, e.action_type, e.action_value, e.dismissible,
        e.dismissible_mode, e.remind_later_count, e.remind_later_sessions,
        e.repeat_mode, e.repeat_interval_hours, e.repeat_session_interval,
        e.first_view_session_delay, e.max_times_seen_per_user,
        e.metadata, e.questions, e.user_status,
        e.impression_count, e.is_partially_completed, e.questions_answered,
        e.display_sequence, e.disappear_after_cta, e.last_seen_session,
        e.defer_count, e.defer_until_session, e.first_seen_at, e.last_seen_at,
        e.is_read, v_total AS total_count
    FROM get_eligible_announcements(
        p_user_id, p_device_id, p_auth_uid, p_platform, NULL,
        p_country, p_city, p_is_logged_in, p_profession, p_speciality,
        p_degree, p_experience, p_has_complete_profile,
        p_session_number, 'inbox', NULL, p_page_size, v_offset
    ) e
    ORDER BY
        -- Unread first (is_read = false first)
        e.is_read ASC,
        -- Then by importance
        CASE e.importance WHEN 'high' THEN 1 WHEN 'medium' THEN 2 WHEN 'low' THEN 3 END,
        -- Then by most recently seen
        e.last_seen_at DESC NULLS LAST;
END;
$function$;

GRANT ALL ON FUNCTION public.get_inbox_announcements(text,text,text,text,text,text,boolean,text,text,text,text,boolean,integer,integer,integer) TO anon;
GRANT ALL ON FUNCTION public.get_inbox_announcements(text,text,text,text,text,text,boolean,text,text,text,text,boolean,integer,integer,integer) TO authenticated;
GRANT ALL ON FUNCTION public.get_inbox_announcements(text,text,text,text,text,text,boolean,text,text,text,text,boolean,integer,integer,integer) TO service_role;
