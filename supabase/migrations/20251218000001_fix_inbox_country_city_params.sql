-- Migration: Fix get_inbox_announcements to pass country and city parameters
-- Date: 2025-12-18
-- Purpose: The get_inbox_announcements function was not passing country and city to get_eligible_announcements
--          This caused announcements with country/city targeting to not appear in inbox

DROP FUNCTION IF EXISTS public.get_inbox_announcements(text,text,text,text,boolean,text,text,text,text,boolean,integer,integer,integer);

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
    metadata jsonb,
    questions jsonb,
    user_status text,
    impression_count integer,
    is_partially_completed boolean,
    questions_answered integer,
    display_sequence integer,
    total_count bigint
)
LANGUAGE plpgsql SECURITY DEFINER
AS $$
DECLARE
    v_offset INTEGER;
    v_total BIGINT;
BEGIN
    v_offset := (p_page - 1) * p_page_size;
    
    -- Get total count
    SELECT COUNT(*) INTO v_total
    FROM get_eligible_announcements(
        p_user_id, p_device_id, p_auth_uid, p_platform, NULL,
        p_country, p_city, p_is_logged_in, p_profession, p_speciality,
        p_degree, p_experience, p_has_complete_profile,
        p_session_number, 'inbox', 1000, 0
    );
    
    -- Get paginated results
    RETURN QUERY
    SELECT 
        e.id, e.title, e.message, e.body, e.surface, e.importance,
        e.kind, e.priority, e.action_type, e.action_value, e.dismissible,
        e.dismissible_mode, e.metadata, e.questions, e.user_status,
        e.impression_count, e.is_partially_completed, e.questions_answered,
        e.display_sequence, v_total AS total_count
    FROM get_eligible_announcements(
        p_user_id, p_device_id, p_auth_uid, p_platform, NULL,
        p_country, p_city, p_is_logged_in, p_profession, p_speciality,
        p_degree, p_experience, p_has_complete_profile,
        p_session_number, 'inbox', p_page_size, v_offset
    ) e;
END;
$$;
