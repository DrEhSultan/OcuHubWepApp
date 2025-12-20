-- Migration: Fix Remind Later - Auto Show After First Click
-- Date: 2025-12-20
-- 
-- CORRECT LOGIC:
-- When user clicks "Remind Later" for the FIRST time:
-- - The announcement shows remind_later_count MORE times automatically
-- - With remind_later_sessions interval between each
-- - User does NOT need to click "Remind Later" again
-- - After remind_later_count views, it STOPS permanently
--
-- Example with remind_later_count=3, remind_later_sessions=1:
-- 1. Session 3: User sees announcement, clicks "Remind Later" → enters remind_later mode
-- 2. Session 4: Shows automatically (view 1 of 3), defer_count becomes 1
-- 3. Session 5: Shows automatically (view 2 of 3), defer_count becomes 2
-- 4. Session 6: Shows automatically (view 3 of 3), defer_count becomes 3
-- 5. Session 7+: STOPS - defer_count (3) >= remind_later_count (3)

-- Reset test data
DELETE FROM user_announcement_state 
WHERE announcement_id = '323a3835-1bc8-4449-b8ea-cb1a762a8bb1';

-- ============================================================================
-- STEP 1: Fix record_announcement_impression
-- When showing a deferred announcement:
-- - Increment defer_count (tracks views in remind_later mode)
-- - Set defer_until_session for next view based on remind_later_sessions
-- ============================================================================

DROP FUNCTION IF EXISTS public.record_announcement_impression(uuid, text, integer);
DROP FUNCTION IF EXISTS public.record_announcement_impression(uuid, text);

CREATE OR REPLACE FUNCTION public.record_announcement_impression(
    p_announcement_id uuid, 
    p_user_id text,
    p_session_number integer DEFAULT NULL
) RETURNS void
LANGUAGE plpgsql SECURITY DEFINER
AS $function$
DECLARE
    v_remind_later_sessions INTEGER := 1;
BEGIN
    -- Get remind_later_sessions from announcement
    SELECT COALESCE(remind_later_sessions, 1) INTO v_remind_later_sessions
    FROM public.announcements
    WHERE id = p_announcement_id;

    INSERT INTO public.user_announcement_state (
        announcement_id,
        user_id,
        status,
        impression_count,
        first_seen_at,
        last_seen_at,
        last_seen_session,
        defer_until_session,
        defer_count,
        updated_at
    ) VALUES (
        p_announcement_id,
        p_user_id,
        'seen',
        1,
        NOW(),
        NOW(),
        p_session_number,
        NULL,
        0,
        NOW()
    )
    ON CONFLICT (announcement_id, user_id) DO UPDATE SET
        -- Keep 'deferred' status if in remind_later mode
        status = CASE 
            WHEN user_announcement_state.status IN ('dismissed', 'completed') THEN user_announcement_state.status
            WHEN user_announcement_state.status = 'deferred' THEN 'deferred'
            ELSE 'seen'
        END,
        impression_count = user_announcement_state.impression_count + 1,
        last_seen_at = NOW(),
        last_seen_session = COALESCE(p_session_number, user_announcement_state.last_seen_session),
        -- For deferred: increment defer_count and set next defer_until_session
        defer_count = CASE 
            WHEN user_announcement_state.status = 'deferred' 
            THEN user_announcement_state.defer_count + 1
            ELSE user_announcement_state.defer_count
        END,
        defer_until_session = CASE 
            WHEN user_announcement_state.status = 'deferred' 
            THEN COALESCE(p_session_number, 0) + v_remind_later_sessions
            ELSE user_announcement_state.defer_until_session
        END,
        updated_at = NOW();
END;
$function$;

GRANT ALL ON FUNCTION public.record_announcement_impression(uuid, text, integer) TO anon;
GRANT ALL ON FUNCTION public.record_announcement_impression(uuid, text, integer) TO authenticated;
GRANT ALL ON FUNCTION public.record_announcement_impression(uuid, text, integer) TO service_role;

CREATE OR REPLACE FUNCTION public.record_announcement_impression(
    p_announcement_id uuid, 
    p_user_id text
) RETURNS void
LANGUAGE plpgsql SECURITY DEFINER
AS $function$
BEGIN
    PERFORM public.record_announcement_impression(p_announcement_id, p_user_id, NULL);
END;
$function$;

GRANT ALL ON FUNCTION public.record_announcement_impression(uuid, text) TO anon;
GRANT ALL ON FUNCTION public.record_announcement_impression(uuid, text) TO authenticated;
GRANT ALL ON FUNCTION public.record_announcement_impression(uuid, text) TO service_role;

-- ============================================================================
-- STEP 2: Fix get_eligible_announcements
-- For deferred announcements:
-- - Show when session >= defer_until_session AND defer_count < remind_later_count
-- - Skip max_times_seen_per_user check when in remind_later mode
-- ============================================================================

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
        (COALESCE(uas.impression_count, 0) > 0) AS is_read
    FROM public.announcements a
    LEFT JOIN public.user_announcement_state uas 
        ON uas.announcement_id = a.id 
        AND uas.user_id = v_effective_user_id
    WHERE 
        a.is_deleted = FALSE
        AND (
            -- INBOX: Show all
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
            -- COMPLETED with keep showing
            OR (
                uas.status = 'completed'
                AND COALESCE(a.disappear_after_cta, TRUE) = FALSE
                AND (p_session_number - COALESCE(uas.last_seen_session, 0)) >= COALESCE(a.repeat_session_interval, 1)
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

GRANT ALL ON FUNCTION public.get_eligible_announcements(text,text,text,text,text,text,text,boolean,text,text,text,text,boolean,integer,text,integer,integer) TO anon;
GRANT ALL ON FUNCTION public.get_eligible_announcements(text,text,text,text,text,text,text,boolean,text,text,text,text,boolean,integer,text,integer,integer) TO authenticated;
GRANT ALL ON FUNCTION public.get_eligible_announcements(text,text,text,text,text,text,text,boolean,text,text,text,text,boolean,integer,text,integer,integer) TO service_role;
