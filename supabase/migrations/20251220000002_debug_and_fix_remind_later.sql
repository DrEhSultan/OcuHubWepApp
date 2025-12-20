-- Migration: Debug and Fix Remind Later Logic
-- Date: 2025-12-20
-- 
-- This migration adds comprehensive fixes for the remind_later logic:
-- 1. Ensures defer_count is properly tracked
-- 2. Ensures defer_until_session is properly calculated
-- 3. Adds proper exclusion for exhausted remind_later
--
-- RUN THIS IN SUPABASE SQL EDITOR TO DEBUG:
-- 
-- SELECT 
--     a.id,
--     a.title,
--     a.dismissible_mode,
--     a.remind_later_count,
--     a.remind_later_sessions,
--     a.repeat_mode,
--     a.repeat_session_interval,
--     a.max_times_seen_per_user,
--     uas.status,
--     uas.defer_count,
--     uas.defer_until_session,
--     uas.impression_count,
--     uas.last_seen_session
-- FROM announcements a
-- LEFT JOIN user_announcement_state uas ON uas.announcement_id = a.id
-- WHERE a.dismissible_mode = 'remind_later'
-- ORDER BY a.created_at DESC;

-- ============================================================================
-- STEP 1: Fix update_announcement_state to properly handle deferred status
-- ============================================================================

DROP FUNCTION IF EXISTS public.update_announcement_state(uuid, text, text, integer, integer, integer, integer);

CREATE OR REPLACE FUNCTION public.update_announcement_state(
    p_announcement_id uuid, 
    p_user_id text, 
    p_status text, 
    p_session_number integer DEFAULT NULL::integer, 
    p_defer_sessions integer DEFAULT NULL::integer, 
    p_defer_hours integer DEFAULT NULL::integer, 
    p_questions_answered integer DEFAULT NULL::integer
) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER
AS $function$
DECLARE
    v_result JSONB;
    v_defer_until_session INTEGER;
    v_defer_until_time TIMESTAMPTZ;
    v_is_partially_completed BOOLEAN;
    v_total_questions INTEGER;
    v_should_increment_impression BOOLEAN;
    v_current_defer_count INTEGER;
    v_announcement_remind_later_count INTEGER;
    v_announcement_dismissible_mode TEXT;
BEGIN
    -- Only increment impression count for 'seen' status (actual views)
    v_should_increment_impression := (p_status = 'seen');
    
    -- Get current defer_count and announcement settings
    SELECT COALESCE(uas.defer_count, 0), a.remind_later_count, a.dismissible_mode
    INTO v_current_defer_count, v_announcement_remind_later_count, v_announcement_dismissible_mode
    FROM public.announcements a
    LEFT JOIN public.user_announcement_state uas 
        ON uas.announcement_id = a.id AND uas.user_id = p_user_id
    WHERE a.id = p_announcement_id;
    
    -- CRITICAL: If this is a 'seen' update for a remind_later announcement
    -- that has exhausted its defer_count, change status to 'dismissed' instead
    IF p_status = 'seen' 
       AND v_announcement_dismissible_mode = 'remind_later' 
       AND v_current_defer_count >= COALESCE(v_announcement_remind_later_count, 3) THEN
        -- Don't allow 'seen' status - keep it as dismissed
        p_status := 'dismissed';
    END IF;
    
    -- Calculate defer values if deferred
    IF p_status = 'deferred' THEN
        IF p_defer_sessions IS NOT NULL AND p_session_number IS NOT NULL THEN
            v_defer_until_session := p_session_number + p_defer_sessions;
        END IF;
        IF p_defer_hours IS NOT NULL THEN
            v_defer_until_time := NOW() + (p_defer_hours * INTERVAL '1 hour');
        END IF;
    END IF;
    
    -- Check if survey is partially completed
    IF p_questions_answered IS NOT NULL THEN
        SELECT jsonb_array_length(COALESCE(questions, '[]'::jsonb)) INTO v_total_questions
        FROM public.announcements
        WHERE id = p_announcement_id;
        
        v_is_partially_completed := p_questions_answered < COALESCE(v_total_questions, 0);
        
        IF p_questions_answered >= COALESCE(v_total_questions, 0) AND v_total_questions > 0 THEN
            p_status := 'completed';
            v_is_partially_completed := FALSE;
        END IF;
    END IF;
    
    -- Upsert user_announcement_state
    INSERT INTO public.user_announcement_state (
        announcement_id,
        user_id,
        status,
        first_seen_at,
        last_seen_at,
        last_seen_session,
        defer_until_session,
        defer_until_time,
        defer_count,
        is_partially_completed,
        questions_answered,
        impression_count,
        completed_at,
        dismissed_at,
        deferred_at,
        updated_at
    ) VALUES (
        p_announcement_id,
        p_user_id,
        p_status,
        CASE WHEN p_status = 'seen' THEN NOW() ELSE NULL END,
        NOW(),
        p_session_number,
        v_defer_until_session,
        v_defer_until_time,
        CASE WHEN p_status = 'deferred' THEN 1 ELSE 0 END,
        COALESCE(v_is_partially_completed, FALSE),
        COALESCE(p_questions_answered, 0),
        CASE WHEN v_should_increment_impression THEN 1 ELSE 0 END,
        CASE WHEN p_status = 'completed' THEN NOW() ELSE NULL END,
        CASE WHEN p_status = 'dismissed' THEN NOW() ELSE NULL END,
        CASE WHEN p_status = 'deferred' THEN NOW() ELSE NULL END,
        NOW()
    )
    ON CONFLICT (announcement_id, user_id) DO UPDATE SET
        status = EXCLUDED.status,
        first_seen_at = COALESCE(user_announcement_state.first_seen_at, 
            CASE WHEN EXCLUDED.status = 'seen' THEN NOW() ELSE NULL END),
        last_seen_at = NOW(),
        last_seen_session = COALESCE(EXCLUDED.last_seen_session, user_announcement_state.last_seen_session),
        defer_until_session = CASE 
            WHEN EXCLUDED.status = 'deferred' THEN EXCLUDED.defer_until_session 
            ELSE user_announcement_state.defer_until_session 
        END,
        defer_until_time = CASE 
            WHEN EXCLUDED.status = 'deferred' THEN EXCLUDED.defer_until_time 
            ELSE user_announcement_state.defer_until_time 
        END,
        -- CRITICAL: Only increment defer_count when status is 'deferred'
        defer_count = CASE 
            WHEN EXCLUDED.status = 'deferred' THEN user_announcement_state.defer_count + 1 
            ELSE user_announcement_state.defer_count 
        END,
        is_partially_completed = COALESCE(EXCLUDED.is_partially_completed, user_announcement_state.is_partially_completed),
        questions_answered = GREATEST(COALESCE(EXCLUDED.questions_answered, 0), COALESCE(user_announcement_state.questions_answered, 0)),
        impression_count = CASE 
            WHEN EXCLUDED.status = 'seen' THEN user_announcement_state.impression_count + 1 
            ELSE user_announcement_state.impression_count 
        END,
        completed_at = CASE 
            WHEN EXCLUDED.status = 'completed' THEN NOW() 
            ELSE user_announcement_state.completed_at 
        END,
        dismissed_at = CASE 
            WHEN EXCLUDED.status = 'dismissed' THEN NOW() 
            ELSE user_announcement_state.dismissed_at 
        END,
        deferred_at = CASE 
            WHEN EXCLUDED.status = 'deferred' THEN NOW() 
            ELSE user_announcement_state.deferred_at 
        END,
        updated_at = NOW();
    
    SELECT jsonb_build_object(
        'announcement_id', p_announcement_id,
        'user_id', p_user_id,
        'status', p_status,
        'defer_count', v_current_defer_count + CASE WHEN p_status = 'deferred' THEN 1 ELSE 0 END,
        'defer_until_session', v_defer_until_session
    ) INTO v_result;
    
    RETURN v_result;
END;
$function$;

GRANT ALL ON FUNCTION public.update_announcement_state(uuid, text, text, integer, integer, integer, integer) TO anon;
GRANT ALL ON FUNCTION public.update_announcement_state(uuid, text, text, integer, integer, integer, integer) TO authenticated;
GRANT ALL ON FUNCTION public.update_announcement_state(uuid, text, text, integer, integer, integer, integer) TO service_role;


-- ============================================================================
-- STEP 2: Fix get_eligible_announcements to properly exclude exhausted remind_later
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
        
        -- ============================================================================
        -- CRITICAL FIRST CHECK: Exclude exhausted remind_later announcements
        -- This must be checked BEFORE any other eligibility logic
        -- ============================================================================
        AND NOT (
            p_surface != 'inbox'
            AND a.dismissible_mode = 'remind_later'
            AND COALESCE(uas.defer_count, 0) >= COALESCE(a.remind_later_count, 3)
        )
        
        AND (
            -- INBOX: Show all announcements
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
            -- OTHER SURFACES: Only show active announcements
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
        
        -- ============================================================================
        -- ELIGIBILITY LOGIC
        -- ============================================================================
        AND (
            p_surface = 'inbox'
            OR uas.status IS NULL
            OR uas.status = 'eligible'
            
            -- SEEN status with NON-remind_later mode: normal repeat mode
            OR (
                uas.status = 'seen'
                AND (a.dismissible_mode IS NULL OR a.dismissible_mode != 'remind_later')
                AND (
                    (
                        COALESCE(a.repeat_mode, 'once') = 'per_app_open'
                        AND (p_session_number - COALESCE(uas.last_seen_session, 0)) >= COALESCE(a.repeat_session_interval, 1)
                    )
                    OR (
                        COALESCE(a.repeat_mode, 'once') = 'interval_hours'
                        AND (uas.last_seen_at IS NULL OR (NOW() - uas.last_seen_at) >= (COALESCE(a.repeat_interval_hours, 24) * INTERVAL '1 hour'))
                    )
                )
            )
            
            -- SEEN status with remind_later mode: ONLY show if defer_count < remind_later_count
            -- AND enough sessions have passed since last defer
            OR (
                uas.status = 'seen'
                AND a.dismissible_mode = 'remind_later'
                AND COALESCE(uas.defer_count, 0) < COALESCE(a.remind_later_count, 3)
                AND (
                    uas.defer_until_session IS NULL 
                    OR p_session_number >= uas.defer_until_session
                )
            )
            
            -- DEFERRED status: check remind later count and session interval
            OR (
                uas.status = 'deferred'
                AND COALESCE(uas.defer_count, 0) < COALESCE(a.remind_later_count, 3)
                AND (uas.defer_until_session IS NULL OR p_session_number >= uas.defer_until_session)
            )
            
            -- COMPLETED status with disappear_after_cta = false (non-remind_later only)
            OR (
                uas.status = 'completed'
                AND COALESCE(a.disappear_after_cta, TRUE) = FALSE
                AND (a.dismissible_mode IS NULL OR a.dismissible_mode != 'remind_later')
                AND (p_session_number - COALESCE(uas.last_seen_session, 0)) >= COALESCE(a.repeat_session_interval, 1)
            )
            
            -- Survey/Quiz with remind_later mode (not completed, not exhausted)
            OR (
                a.kind IN ('survey', 'quiz', 'user_insights') 
                AND a.dismissible_mode = 'remind_later' 
                AND uas.status != 'completed'
                AND COALESCE(uas.defer_count, 0) < COALESCE(a.remind_later_count, 3)
                AND (
                    uas.status != 'deferred'
                    OR (uas.defer_until_session IS NULL OR p_session_number >= uas.defer_until_session)
                )
            )
        )
        
        -- MAX VIEWS CHECK (only for non-remind_later mode)
        AND (
            p_surface = 'inbox'
            OR a.dismissible_mode = 'remind_later'  -- remind_later uses defer_count, not impression_count
            OR a.max_times_seen_per_user IS NULL
            OR a.max_times_seen_per_user = 0
            OR COALESCE(uas.impression_count, 0) < a.max_times_seen_per_user
        )
        
        -- DISAPPEAR AFTER CTA CHECK
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


-- ============================================================================
-- SUMMARY:
-- ============================================================================
-- 
-- For remind_later mode announcements:
-- 
-- 1. User sees announcement (normal repeat mode until first "Remind Later" click)
-- 2. User clicks "Remind Later" → status='deferred', defer_count=1, defer_until_session=current+interval
-- 3. After defer_until_session reached → announcement shows again
-- 4. User clicks "Remind Later" again → defer_count=2, defer_until_session updated
-- 5. Repeat until defer_count >= remind_later_count
-- 6. Once defer_count >= remind_later_count → PERMANENTLY HIDDEN (no fallback to repeat mode)
--
-- Key changes:
-- - Added early exclusion check for exhausted remind_later
-- - Separated SEEN status handling for remind_later vs non-remind_later
-- - update_announcement_state now prevents 'seen' status for exhausted remind_later
-- - MAX VIEWS check skipped for remind_later mode (uses defer_count instead)
--
-- ============================================================================

