-- Migration: Fix defer_count to start at 0
-- Date: 2025-12-20
-- 
-- ISSUE: When user clicks "Remind Later", defer_count was set to 1, counting the 
-- current view. This caused the announcement to stop 1 view early.
--
-- FIX: Set defer_count = 0 when user clicks "Remind Later" for the first time.
-- The count starts AFTER the click, not including the view where they clicked.
--
-- Example with remind_later_count=3:
-- Session 3: User sees, clicks "Remind Later" → defer_count=0 (doesn't count this)
-- Session 4: Shows → defer_count=1
-- Session 5: Shows → defer_count=2
-- Session 6: Shows → defer_count=3
-- Session 7+: STOPS (defer_count >= remind_later_count)

-- Drop existing function
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
BEGIN
    -- Only increment impression count for 'seen' status (actual views)
    v_should_increment_impression := (p_status = 'seen');
    
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
        -- CRITICAL FIX: Start defer_count at 0, not 1
        -- The view where user clicks "Remind Later" doesn't count
        CASE WHEN p_status = 'deferred' THEN 0 ELSE 0 END,
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
        -- When user clicks "Remind Later" again, keep incrementing from current count
        defer_count = CASE 
            WHEN EXCLUDED.status = 'deferred' THEN user_announcement_state.defer_count
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
    
    -- Return the updated state
    SELECT jsonb_build_object(
        'announcement_id', p_announcement_id,
        'user_id', p_user_id,
        'status', p_status,
        'defer_count', CASE WHEN p_status = 'deferred' THEN 0 ELSE NULL END,
        'defer_until_session', v_defer_until_session,
        'is_remind_later_mode', (p_status = 'deferred')
    ) INTO v_result;
    
    RETURN v_result;
END;
$function$;

GRANT ALL ON FUNCTION public.update_announcement_state(uuid, text, text, integer, integer, integer, integer) TO anon;
GRANT ALL ON FUNCTION public.update_announcement_state(uuid, text, text, integer, integer, integer, integer) TO authenticated;
GRANT ALL ON FUNCTION public.update_announcement_state(uuid, text, text, integer, integer, integer, integer) TO service_role;

-- ============================================================================
-- SUMMARY:
-- ============================================================================
-- 
-- Changed defer_count initialization from 1 to 0 when user clicks "Remind Later"
-- 
-- This ensures the view where user clicks "Remind Later" doesn't count toward
-- the remind_later_count limit.
--
-- With remind_later_count=3, the announcement will now show 3 times AFTER
-- the "Remind Later" click, not including the click itself.
--
-- ============================================================================
