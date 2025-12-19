-- Migration: Fix Impression Session Tracking
-- Date: 2025-12-19
-- Purpose: The record_announcement_impression function was not updating last_seen_session
--          which is required for per_app_open repeat mode to work correctly.
--
-- The session interval check: (p_session_number - last_seen_session) >= repeat_session_interval
-- requires last_seen_session to be updated on each impression.

-- Drop existing function
DROP FUNCTION IF EXISTS public.record_announcement_impression(uuid, text);

-- Create new function with session tracking
CREATE OR REPLACE FUNCTION public.record_announcement_impression(
    p_announcement_id uuid, 
    p_user_id text,
    p_session_number integer DEFAULT NULL
) RETURNS void
LANGUAGE plpgsql SECURITY DEFINER
AS $function$
BEGIN
    INSERT INTO public.user_announcement_state (
        announcement_id,
        user_id,
        status,
        impression_count,
        first_seen_at,
        last_seen_at,
        last_seen_session,
        updated_at
    ) VALUES (
        p_announcement_id,
        p_user_id,
        'seen',
        1,
        NOW(),
        NOW(),
        p_session_number,
        NOW()
    )
    ON CONFLICT (announcement_id, user_id) DO UPDATE SET
        -- Only update status to 'seen' if not already dismissed/completed/deferred
        status = CASE 
            WHEN user_announcement_state.status IN ('dismissed', 'completed') THEN user_announcement_state.status
            ELSE 'seen'
        END,
        impression_count = user_announcement_state.impression_count + 1,
        last_seen_at = NOW(),
        last_seen_session = COALESCE(p_session_number, user_announcement_state.last_seen_session),
        updated_at = NOW();
END;
$function$;

GRANT ALL ON FUNCTION public.record_announcement_impression(uuid, text, integer) TO anon;
GRANT ALL ON FUNCTION public.record_announcement_impression(uuid, text, integer) TO authenticated;
GRANT ALL ON FUNCTION public.record_announcement_impression(uuid, text, integer) TO service_role;

-- Also keep the old signature for backward compatibility (without session)
CREATE OR REPLACE FUNCTION public.record_announcement_impression(
    p_announcement_id uuid, 
    p_user_id text
) RETURNS void
LANGUAGE plpgsql SECURITY DEFINER
AS $function$
BEGIN
    -- Call the new function with NULL session (will preserve existing session)
    PERFORM public.record_announcement_impression(p_announcement_id, p_user_id, NULL);
END;
$function$;

GRANT ALL ON FUNCTION public.record_announcement_impression(uuid, text) TO anon;
GRANT ALL ON FUNCTION public.record_announcement_impression(uuid, text) TO authenticated;
GRANT ALL ON FUNCTION public.record_announcement_impression(uuid, text) TO service_role;

-- ============================================================================
-- SUMMARY OF FIX:
-- ============================================================================
-- 
-- record_announcement_impression now:
-- 1. Accepts optional p_session_number parameter
-- 2. Updates last_seen_session on each impression
-- 3. Preserves status if already dismissed/completed (doesn't overwrite to 'seen')
--
-- This enables the per_app_open repeat mode session interval check to work:
-- (p_session_number - last_seen_session) >= repeat_session_interval
--
-- ============================================================================
