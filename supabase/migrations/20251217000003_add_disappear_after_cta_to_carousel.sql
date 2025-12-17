-- Migration: Add disappear_after_cta to get_carousel_announcements return columns
-- Date: 2025-12-17
-- Purpose: Pass through disappear_after_cta from get_eligible_announcements
-- Depends on: 20251217000002_add_disappear_after_cta_to_eligible.sql
-- 
-- IMPORTANT: Must drop function first since we're changing return type

DROP FUNCTION IF EXISTS public.get_carousel_announcements(text,text,text,text,text,text,text,boolean,text,text,text,text,boolean,integer);

CREATE FUNCTION public.get_carousel_announcements(
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
    p_session_number integer DEFAULT 1
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
    carousel_position integer,
    disappear_after_cta boolean  -- NEW: Added for "Keep showing" mode
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
            ) AS carousel_position
        FROM get_eligible_announcements(
            p_user_id, p_device_id, p_auth_uid, p_platform, p_app_version,
            p_country, p_city, p_is_logged_in, p_profession, p_speciality,
            p_degree, p_experience, p_has_complete_profile, p_session_number,
            'home_banner', 100, 0
        ) e
        WHERE e.surface IN ('home_banner', 'modal')
    )
    SELECT 
        eligible.id, eligible.title, eligible.message, eligible.body,
        eligible.surface, eligible.importance, eligible.kind, eligible.priority,
        eligible.action_type, eligible.action_value, eligible.dismissible,
        eligible.dismissible_mode, eligible.metadata, eligible.questions,
        eligible.user_status, eligible.impression_count, eligible.is_partially_completed,
        eligible.questions_answered, eligible.display_sequence,
        eligible.carousel_position::INTEGER,
        eligible.disappear_after_cta  -- NEW: Pass through from get_eligible_announcements
    FROM eligible
    WHERE eligible.carousel_position <= v_max_items;
END;
$function$;
