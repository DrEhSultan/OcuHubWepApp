-- BACKUP: Original get_eligible_announcements function
-- Date: 2025-12-17
-- Purpose: Restore point before adding disappear_after_cta column
-- 
-- To restore: Run this file to revert to original function without disappear_after_cta

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
    metadata jsonb,
    questions jsonb,
    user_status text,
    impression_count integer,
    is_partially_completed boolean,
    questions_answered integer,
    display_sequence integer
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
        AND (a.status = 'live' OR a.status = 'published' OR a.status IS NULL)
        AND a.start_at <= NOW()
        AND (a.end_at IS NULL OR a.end_at > NOW())
        
        -- Surface filtering
        AND (
            (p_surface = 'inbox' AND a.surface IN ('home_banner', 'modal', 'inbox'))
            OR a.surface = p_surface 
            OR a.surface = 'modal'
        )
        
        -- Login targeting
        AND (a.target_logged_in_only = FALSE OR p_is_logged_in = TRUE)
        AND (a.target_anonymous_only = FALSE OR p_is_logged_in = FALSE)
        
        -- Incomplete profile targeting
        AND (a.target_incomplete_profile = FALSE OR p_has_complete_profile = FALSE)
        
        -- Country targeting (with exclude support)
        AND (
            (a.target_country IS NULL OR a.target_country = '')
            OR (a.target_country_exclude = FALSE AND p_country = ANY(string_to_array(a.target_country, ',')))
            OR (a.target_country_exclude = TRUE AND (p_country IS NULL OR p_country NOT IN (SELECT unnest(string_to_array(a.target_country, ',')))))
        )
        
        -- City targeting (with exclude support)
        AND (
            (a.target_city IS NULL OR a.target_city = '')
            OR (a.target_city_exclude = FALSE AND p_city = ANY(string_to_array(a.target_city, ',')))
            OR (a.target_city_exclude = TRUE AND (p_city IS NULL OR p_city NOT IN (SELECT unnest(string_to_array(a.target_city, ',')))))
        )
        
        -- Profession targeting (with exclude support)
        AND (
            (a.target_profession IS NULL OR a.target_profession = '')
            OR (a.target_profession_exclude = FALSE AND p_profession = ANY(string_to_array(a.target_profession, ',')))
            OR (a.target_profession_exclude = TRUE AND (p_profession IS NULL OR p_profession NOT IN (SELECT unnest(string_to_array(a.target_profession, ',')))))
        )
        
        -- Speciality targeting (with exclude support)
        AND (
            (a.target_speciality IS NULL OR a.target_speciality = '')
            OR (a.target_speciality_exclude = FALSE AND p_speciality = ANY(string_to_array(a.target_speciality, ',')))
            OR (a.target_speciality_exclude = TRUE AND (p_speciality IS NULL OR p_speciality NOT IN (SELECT unnest(string_to_array(a.target_speciality, ',')))))
        )
        
        -- Degree targeting (with exclude support)
        AND (
            (a.target_degree IS NULL OR a.target_degree = '')
            OR (a.target_degree_exclude = FALSE AND p_degree = ANY(string_to_array(a.target_degree, ',')))
            OR (a.target_degree_exclude = TRUE AND (p_degree IS NULL OR p_degree NOT IN (SELECT unnest(string_to_array(a.target_degree, ',')))))
        )
        
        -- Experience targeting (with exclude support)
        AND (
            (a.target_years_experience IS NULL OR a.target_years_experience = '')
            OR (a.target_experience_exclude = FALSE AND p_experience = ANY(string_to_array(a.target_years_experience, ',')))
            OR (a.target_experience_exclude = TRUE AND (p_experience IS NULL OR p_experience NOT IN (SELECT unnest(string_to_array(a.target_years_experience, ',')))))
        )
        
        -- Platform targeting
        AND (a.target_platform IS NULL OR a.target_platform = '' OR p_platform = ANY(string_to_array(a.target_platform, ',')))
        
        -- Eligibility logic
        AND (
            p_surface = 'inbox'
            OR uas.status IS NULL
            OR uas.status = 'eligible'
            OR uas.status = 'seen'
            OR (a.kind IN ('survey', 'quiz', 'user_insights') AND a.dismissible_mode = 'remind_later' AND uas.status != 'completed')
        )
        
    ORDER BY 
        CASE a.importance WHEN 'high' THEN 1 WHEN 'medium' THEN 2 WHEN 'low' THEN 3 END,
        a.display_sequence ASC NULLS LAST,
        a.created_at DESC
    LIMIT p_limit
    OFFSET p_offset;
END;
$function$;
