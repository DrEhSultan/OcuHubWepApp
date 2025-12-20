-- ============================================
-- ADD SUBSPECIALTY EXCLUDE SUPPORT
-- ============================================
-- This migration ONLY adds exclude flag for subspecialty
-- Does NOT modify any other logic or filters
-- Safe to run - only adds new column and updates one filter condition
-- ============================================

-- Step 1: Add the exclude column to announcements table
ALTER TABLE public.announcements 
ADD COLUMN IF NOT EXISTS target_subspecialty_exclude boolean DEFAULT false;

-- Step 2: Update ONLY the subspecialty filter in get_eligible_announcements
-- This replaces ONLY the subspecialty section, nothing else
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
    p_device_brand text DEFAULT NULL::text,
    p_subspecialty text DEFAULT NULL::text,
    p_hospital text DEFAULT NULL::text,
    p_ip_address text DEFAULT NULL::text,
    p_limit integer DEFAULT 10, 
    p_offset integer DEFAULT 0
) 
RETURNS TABLE(
    id uuid, title text, message text, body text, surface text, importance text, kind text, priority text, 
    action_type text, action_value text, dismissible boolean, dismissible_mode text, remind_later_count integer, 
    remind_later_sessions integer, repeat_mode text, repeat_interval_hours integer, repeat_session_interval integer, 
    first_view_session_delay integer, max_times_seen_per_user integer, metadata jsonb, questions jsonb, 
    user_status text, impression_count integer, is_partially_completed boolean, questions_answered integer, 
    display_sequence integer, disappear_after_cta boolean, last_seen_session integer, defer_count integer, 
    defer_until_session integer, first_seen_at timestamp with time zone, last_seen_at timestamp with time zone, 
    is_read boolean
)
LANGUAGE plpgsql 
SECURITY DEFINER
AS $function$
DECLARE
    v_effective_user_id TEXT;
BEGIN
    v_effective_user_id := COALESCE(p_auth_uid, p_device_id, p_user_id);
    
    RETURN QUERY
    SELECT 
        a.id, a.title, a.message, a.body, a.surface, a.importance, a.kind, a.priority,
        a.action_type, a.action_value, a.dismissible, a.dismissible_mode,
        COALESCE(a.remind_later_count, 3) AS remind_later_count,
        COALESCE(a.remind_later_sessions, 1) AS remind_later_sessions,
        COALESCE(a.repeat_mode, 'once') AS repeat_mode,
        a.repeat_interval_hours,
        COALESCE(a.repeat_session_interval, 1) AS repeat_session_interval,
        COALESCE(a.first_view_session_delay, 0) AS first_view_session_delay,
        a.max_times_seen_per_user, a.metadata, a.questions,
        COALESCE(uas.status, 'eligible') AS user_status,
        COALESCE(uas.impression_count, 0) AS impression_count,
        COALESCE(uas.is_partially_completed, FALSE) AS is_partially_completed,
        COALESCE(uas.questions_answered, 0) AS questions_answered,
        a.display_sequence,
        COALESCE(a.disappear_after_cta, TRUE) AS disappear_after_cta,
        COALESCE(uas.last_seen_session, 0) AS last_seen_session,
        COALESCE(uas.defer_count, 0) AS defer_count,
        uas.defer_until_session, uas.first_seen_at, uas.last_seen_at,
        CASE 
            WHEN COALESCE(a.disappear_after_cta, TRUE) = FALSE THEN (uas.status = 'dismissed')
            ELSE (COALESCE(uas.impression_count, 0) > 0)
        END AS is_read
    FROM public.announcements a
    LEFT JOIN public.user_announcement_state uas 
        ON uas.announcement_id = a.id AND uas.user_id = v_effective_user_id
    WHERE 
        a.is_deleted = FALSE
        AND (
            (p_surface = 'inbox' AND a.surface IN ('home_banner', 'modal', 'inbox')
             AND (uas.status IS NOT NULL OR (a.is_active = TRUE AND (a.status = 'live' OR a.status = 'published' OR a.status IS NULL)
                  AND a.start_at <= NOW() AND (a.end_at IS NULL OR a.end_at > NOW()))))
            OR (p_surface != 'inbox' AND a.is_active = TRUE AND (a.status = 'live' OR a.status = 'published' OR a.status IS NULL)
                AND a.start_at <= NOW() AND (a.end_at IS NULL OR a.end_at > NOW()) AND (a.surface = p_surface OR a.surface = 'modal'))
        )
        AND (a.target_logged_in_only = FALSE OR p_is_logged_in = TRUE)
        AND (a.target_anonymous_only = FALSE OR p_is_logged_in = FALSE)
        AND (a.target_incomplete_profile = FALSE OR p_has_complete_profile = FALSE)
        AND ((a.target_country IS NULL OR a.target_country = '')
             OR (COALESCE(a.target_country_exclude, FALSE) = FALSE AND p_country = ANY(SELECT TRIM(unnest(string_to_array(a.target_country, ',')))))
             OR (a.target_country_exclude = TRUE AND (p_country IS NULL OR p_country NOT IN (SELECT TRIM(unnest(string_to_array(a.target_country, ',')))))))
        AND ((a.target_city IS NULL OR a.target_city = '')
             OR (COALESCE(a.target_city_exclude, FALSE) = FALSE AND p_city = ANY(SELECT TRIM(unnest(string_to_array(a.target_city, ',')))))
             OR (a.target_city_exclude = TRUE AND (p_city IS NULL OR p_city NOT IN (SELECT TRIM(unnest(string_to_array(a.target_city, ',')))))))
        AND ((a.target_profession IS NULL OR a.target_profession = '')
             OR (COALESCE(a.target_profession_exclude, FALSE) = FALSE AND p_profession = ANY(SELECT TRIM(unnest(string_to_array(a.target_profession, ',')))))
             OR (a.target_profession_exclude = TRUE AND (p_profession IS NULL OR p_profession NOT IN (SELECT TRIM(unnest(string_to_array(a.target_profession, ',')))))))
        AND ((a.target_speciality IS NULL OR a.target_speciality = '')
             OR (COALESCE(a.target_speciality_exclude, FALSE) = FALSE AND p_speciality = ANY(SELECT TRIM(unnest(string_to_array(a.target_speciality, ',')))))
             OR (a.target_speciality_exclude = TRUE AND (p_speciality IS NULL OR p_speciality NOT IN (SELECT TRIM(unnest(string_to_array(a.target_speciality, ',')))))))
        AND ((a.target_degree IS NULL OR a.target_degree = '')
             OR (COALESCE(a.target_degree_exclude, FALSE) = FALSE AND p_degree = ANY(SELECT TRIM(unnest(string_to_array(a.target_degree, ',')))))
             OR (a.target_degree_exclude = TRUE AND (p_degree IS NULL OR p_degree NOT IN (SELECT TRIM(unnest(string_to_array(a.target_degree, ',')))))))
        AND ((a.target_years_experience IS NULL OR a.target_years_experience = '')
             OR (COALESCE(a.target_experience_exclude, FALSE) = FALSE AND p_experience = ANY(SELECT TRIM(unnest(string_to_array(a.target_years_experience, ',')))))
             OR (a.target_experience_exclude = TRUE AND (p_experience IS NULL OR p_experience NOT IN (SELECT TRIM(unnest(string_to_array(a.target_years_experience, ',')))))))
        AND (a.target_platform IS NULL OR a.target_platform = '' OR p_platform = ANY(SELECT TRIM(unnest(string_to_array(a.target_platform, ',')))))
        AND ((p_surface = 'inbox' AND uas.status IS NOT NULL) OR a.target_is_real_device IS NULL
             OR (p_is_real_device IS NOT NULL AND a.target_is_real_device = p_is_real_device))
        AND (a.target_min_app_version IS NULL OR a.target_min_app_version = '' OR p_app_version IS NULL
             OR compare_semver(p_app_version, a.target_min_app_version) >= 0)
        AND (a.target_max_app_version IS NULL OR a.target_max_app_version = '' OR p_app_version IS NULL
             OR compare_semver(p_app_version, a.target_max_app_version) <= 0)
        AND ((a.target_device_brand IS NULL OR a.target_device_brand = '') OR p_device_brand IS NULL
             OR EXISTS (SELECT 1 FROM unnest(string_to_array(p_device_brand, ',')) AS user_brand
                        WHERE TRIM(LOWER(user_brand)) = ANY(SELECT TRIM(LOWER(b)) FROM unnest(string_to_array(a.target_device_brand, ',')) b)))
        -- ⭐ UPDATED: Subspecialty filtering with EXCLUDE support
        AND ((a.target_subspecialty IS NULL OR a.target_subspecialty = '')
             OR (COALESCE(a.target_subspecialty_exclude, FALSE) = FALSE AND p_subspecialty = ANY(SELECT TRIM(unnest(string_to_array(a.target_subspecialty, ',')))))
             OR (a.target_subspecialty_exclude = TRUE AND (p_subspecialty IS NULL OR p_subspecialty NOT IN (SELECT TRIM(unnest(string_to_array(a.target_subspecialty, ',')))))))
        -- Hospital filtering (unchanged - include only)
        AND ((a.target_hospital IS NULL OR a.target_hospital = '')
             OR p_hospital = ANY(SELECT TRIM(unnest(string_to_array(a.target_hospital, ',')))))
        AND ((a.target_ip_addresses IS NULL OR a.target_ip_addresses = '') OR p_ip_address IS NULL
             OR EXISTS (SELECT 1 FROM unnest(string_to_array(p_ip_address, ',')) AS user_ip
                        WHERE TRIM(user_ip) = ANY(SELECT TRIM(ip) FROM unnest(string_to_array(a.target_ip_addresses, ',')) ip)))
        AND (p_surface = 'inbox' OR uas.status IS NOT NULL OR COALESCE(a.first_view_session_delay, 0) = 0
             OR p_session_number >= COALESCE(a.first_view_session_delay, 0))
        AND (p_surface = 'inbox' OR uas.status IS NULL OR uas.status = 'eligible'
             OR (uas.status = 'seen' AND NOT (a.dismissible_mode = 'remind_later' AND COALESCE(uas.defer_count, 0) > 0)
                 AND COALESCE(a.repeat_mode, 'once') = 'per_app_open'
                 AND (p_session_number - COALESCE(uas.last_seen_session, 0)) >= COALESCE(a.repeat_session_interval, 1))
             OR (uas.status = 'seen' AND NOT (a.dismissible_mode = 'remind_later' AND COALESCE(uas.defer_count, 0) > 0)
                 AND COALESCE(a.repeat_mode, 'once') = 'interval_hours'
                 AND (uas.last_seen_at IS NULL OR (NOW() - uas.last_seen_at) >= (COALESCE(a.repeat_interval_hours, 24) * INTERVAL '1 hour')))
             OR (uas.status = 'deferred' AND COALESCE(uas.defer_count, 0) < COALESCE(a.remind_later_count, 3)
                 AND (uas.defer_until_session IS NULL OR p_session_number >= uas.defer_until_session)))
        AND (p_surface = 'inbox' OR (a.dismissible_mode = 'remind_later' AND uas.status = 'deferred')
             OR a.max_times_seen_per_user IS NULL OR a.max_times_seen_per_user = 0
             OR COALESCE(uas.impression_count, 0) < a.max_times_seen_per_user)
        AND (p_surface = 'inbox' OR a.dismissible_mode != 'remind_later' OR uas.status != 'deferred'
             OR COALESCE(uas.defer_count, 0) < COALESCE(a.remind_later_count, 3))
        AND (p_surface = 'inbox' OR COALESCE(a.disappear_after_cta, TRUE) = FALSE OR uas.status IS NULL OR uas.status != 'completed')
        AND (p_surface = 'inbox' OR uas.status IS NULL OR uas.status != 'dismissed')
    ORDER BY 
        CASE WHEN p_surface = 'inbox' THEN CASE WHEN COALESCE(uas.impression_count, 0) = 0 THEN 0 ELSE 1 END ELSE 0 END,
        CASE a.importance WHEN 'high' THEN 1 WHEN 'medium' THEN 2 WHEN 'low' THEN 3 END,
        a.display_sequence ASC NULLS LAST, a.created_at DESC
    LIMIT p_limit OFFSET p_offset;
END;
$function$;

-- ============================================
-- ✅ MIGRATION COMPLETE!
-- ============================================
-- Added: target_subspecialty_exclude column
-- Updated: Subspecialty filter now supports include/exclude
-- Unchanged: All other filters remain exactly the same
-- Works on: Carousel, Modal, Inbox, Unread Count
-- ============================================
