-- Migration: Fix impression count and defer logic
-- Date: 2025-12-19
-- Purpose: Fix two issues:
--   1. impression_count was being incremented on EVERY state update (including defer/dismiss)
--      This caused max_times_seen_per_user to be exceeded too quickly
--   2. Ensure defer logic works correctly for remind_later mode
--
-- The fix: Only increment impression_count when action is 'seen' or 'impression', not on defer/dismiss/complete

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
    -- NOT for 'deferred', 'dismissed', or 'completed' actions
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
        -- Get total questions from announcement
        SELECT jsonb_array_length(COALESCE(questions, '[]'::jsonb)) INTO v_total_questions
        FROM public.announcements
        WHERE id = p_announcement_id;
        
        v_is_partially_completed := p_questions_answered < COALESCE(v_total_questions, 0);
        
        -- If all questions answered, mark as completed
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
        CASE WHEN p_status = 'seen' THEN NOW() ELSE NULL END,  -- Set first_seen_at only on first 'seen'
        NOW(),
        p_session_number,
        v_defer_until_session,
        v_defer_until_time,
        CASE WHEN p_status = 'deferred' THEN 1 ELSE 0 END,
        COALESCE(v_is_partially_completed, FALSE),
        COALESCE(p_questions_answered, 0),
        CASE WHEN v_should_increment_impression THEN 1 ELSE 0 END,  -- Only count if 'seen'
        CASE WHEN p_status = 'completed' THEN NOW() ELSE NULL END,
        CASE WHEN p_status = 'dismissed' THEN NOW() ELSE NULL END,
        CASE WHEN p_status = 'deferred' THEN NOW() ELSE NULL END,
        NOW()
    )
    ON CONFLICT (announcement_id, user_id) DO UPDATE SET
        status = EXCLUDED.status,
        -- Set first_seen_at only if not already set
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
        defer_count = CASE 
            WHEN EXCLUDED.status = 'deferred' THEN user_announcement_state.defer_count + 1 
            ELSE user_announcement_state.defer_count 
        END,
        is_partially_completed = COALESCE(EXCLUDED.is_partially_completed, user_announcement_state.is_partially_completed),
        questions_answered = GREATEST(COALESCE(EXCLUDED.questions_answered, 0), COALESCE(user_announcement_state.questions_answered, 0)),
        -- FIXED: Only increment impression_count when status is 'seen'
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
        'is_partially_completed', COALESCE(v_is_partially_completed, FALSE),
        'questions_answered', COALESCE(p_questions_answered, 0)
    ) INTO v_result;
    
    RETURN v_result;
END;
$function$;

GRANT ALL ON FUNCTION public.update_announcement_state(uuid, text, text, integer, integer, integer, integer) TO anon;
GRANT ALL ON FUNCTION public.update_announcement_state(uuid, text, text, integer, integer, integer, integer) TO authenticated;
GRANT ALL ON FUNCTION public.update_announcement_state(uuid, text, text, integer, integer, integer, integer) TO service_role;

-- ============================================================================
-- SUMMARY OF FIXES:
-- ============================================================================
-- 
-- 1. IMPRESSION COUNT FIX:
--    - Previously: impression_count was incremented on EVERY state update
--    - Now: impression_count is ONLY incremented when status = 'seen'
--    - This prevents max_times_seen_per_user from being exceeded too quickly
--
-- 2. FIRST_SEEN_AT FIX:
--    - Previously: first_seen_at was not being set
--    - Now: first_seen_at is set on first 'seen' status and preserved thereafter
--
-- 3. DEFER LOGIC (unchanged but verified):
--    - defer_count increments by 1 each time user clicks "remind later"
--    - defer_until_session = current_session + defer_sessions
--    - Announcement shows again when session >= defer_until_session AND defer_count < remind_later_count
--
-- ============================================================================


-- ============================================================================
-- DEBUG: Query to check announcement state for a specific user
-- Run this in Supabase SQL Editor to debug:
-- ============================================================================
-- 
-- SELECT 
--     a.id,
--     a.title,
--     a.remind_later_count,
--     a.remind_later_sessions,
--     a.max_times_seen_per_user,
--     a.repeat_mode,
--     a.repeat_session_interval,
--     uas.status,
--     uas.defer_count,
--     uas.defer_until_session,
--     uas.impression_count,
--     uas.last_seen_session,
--     uas.first_seen_at,
--     uas.last_seen_at
-- FROM announcements a
-- LEFT JOIN user_announcement_state uas ON uas.announcement_id = a.id
-- WHERE a.id = '3a26dcb0-f1c7-4656-95da-daaf90a8d449'  -- Your test announcement
-- ORDER BY uas.user_id;
--
-- ============================================================================
-- To reset state for testing, run:
-- ============================================================================
--
-- DELETE FROM user_announcement_state 
-- WHERE announcement_id = '3a26dcb0-f1c7-4656-95da-daaf90a8d449';
--
-- ============================================================================
