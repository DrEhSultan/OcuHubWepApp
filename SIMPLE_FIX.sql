-- =====================================================
-- SIMPLIFIED BACKEND FIX
-- =====================================================
-- Simpler logic that's easier to debug
-- =====================================================

-- 1. Main eligibility function - SIMPLIFIED
DROP FUNCTION IF EXISTS get_eligible_announcements;

CREATE OR REPLACE FUNCTION get_eligible_announcements(
    p_user_id TEXT,
    p_device_id TEXT DEFAULT NULL,
    p_auth_uid TEXT DEFAULT NULL,
    p_platform TEXT DEFAULT NULL,
    p_app_version TEXT DEFAULT NULL,
    p_country TEXT DEFAULT NULL,
    p_city TEXT DEFAULT NULL,
    p_is_logged_in BOOLEAN DEFAULT FALSE,
    p_profession TEXT DEFAULT NULL,
    p_speciality TEXT DEFAULT NULL,
    p_degree TEXT DEFAULT NULL,
    p_experience TEXT DEFAULT NULL,
    p_has_complete_profile BOOLEAN DEFAULT FALSE,
    p_session_number INTEGER DEFAULT 1,
    p_surface TEXT DEFAULT 'home_banner',
    p_limit INTEGER DEFAULT 10,
    p_offset INTEGER DEFAULT 0
)
RETURNS TABLE (
    id UUID,
    title TEXT,
    message TEXT,
    body TEXT,
    surface TEXT,
    importance TEXT,
    kind TEXT,
    priority TEXT,
    action_type TEXT,
    action_value TEXT,
    dismissible BOOLEAN,
    dismissible_mode TEXT,
    metadata JSONB,
    questions JSONB,
    user_status TEXT,
    impression_count INTEGER,
    is_partially_completed BOOLEAN,
    questions_answered INTEGER,
    display_sequence INTEGER
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $func$
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
        COALESCE(uas.impression_count, 0)::INTEGER AS impression_count,
        COALESCE(uas.is_partially_completed, FALSE) AS is_partially_completed,
        COALESCE(uas.questions_answered, 0)::INTEGER AS questions_answered,
        a.display_sequence
    FROM public.announcements a
    LEFT JOIN public.user_announcement_state uas 
        ON uas.announcement_id = a.id 
        AND uas.user_id = v_effective_user_id
    WHERE 
        -- Basic filters
        a.is_active = TRUE
        AND a.is_deleted = FALSE
        AND a.status = 'live'
        AND a.start_at <= NOW()
        AND (a.end_at IS NULL OR a.end_at > NOW())
        
        -- Surface filtering
        AND (
            (p_surface = 'inbox' AND a.surface IN ('home_banner', 'modal', 'inbox'))
            OR a.surface = p_surface 
            OR a.surface = 'modal'
        )
        
        -- For INBOX: show everything (no status filtering)
        -- For other surfaces: filter out completed surveys and dismissed items
        AND (
            p_surface = 'inbox'
            OR uas.status IS NULL
            OR uas.status IN ('eligible', 'seen')
            OR (uas.status = 'deferred' AND COALESCE(uas.defer_until_session, 0) <= p_session_number)
            -- Don't show completed surveys on carousel
            OR (uas.status = 'completed' AND a.kind NOT IN ('survey', 'quiz', 'user_insights'))
        )
        -- Never show dismissed or expired
        AND (p_surface = 'inbox' OR uas.status IS NULL OR uas.status NOT IN ('dismissed', 'expired'))
        
        -- Platform targeting
        AND (a.target_platform IS NULL OR a.target_platform = 'all' OR a.target_platform = p_platform)
        
        -- Login state targeting
        AND (
            (a.target_logged_in_only = FALSE AND a.target_anonymous_only = FALSE)
            OR (a.target_logged_in_only = TRUE AND p_is_logged_in = TRUE)
            OR (a.target_anonymous_only = TRUE AND p_is_logged_in = FALSE)
        )
        
        -- Incomplete profile targeting
        AND (
            COALESCE(a.target_incomplete_profile, FALSE) = FALSE
            OR (a.target_incomplete_profile = TRUE AND p_has_complete_profile = FALSE)
        )
        
        -- Country targeting
        AND (
            a.target_country IS NULL OR a.target_country = ''
            OR (COALESCE(a.target_country_exclude, FALSE) = FALSE AND p_country = ANY(string_to_array(a.target_country, ',')))
            OR (a.target_country_exclude = TRUE AND (p_country IS NULL OR NOT p_country = ANY(string_to_array(a.target_country, ','))))
        )
        
        -- Profession targeting
        AND (
            a.target_profession IS NULL OR a.target_profession = ''
            OR (COALESCE(a.target_profession_exclude, FALSE) = FALSE AND p_profession = ANY(string_to_array(a.target_profession, ',')))
            OR (a.target_profession_exclude = TRUE AND (p_profession IS NULL OR NOT p_profession = ANY(string_to_array(a.target_profession, ','))))
        )
        
        -- Speciality targeting
        AND (
            a.target_speciality IS NULL OR a.target_speciality = ''
            OR (COALESCE(a.target_speciality_exclude, FALSE) = FALSE AND p_speciality = ANY(string_to_array(a.target_speciality, ',')))
            OR (a.target_speciality_exclude = TRUE AND (p_speciality IS NULL OR NOT p_speciality = ANY(string_to_array(a.target_speciality, ','))))
        )
        
        -- Degree targeting
        AND (
            a.target_degree IS NULL OR a.target_degree = ''
            OR (COALESCE(a.target_degree_exclude, FALSE) = FALSE AND p_degree = ANY(string_to_array(a.target_degree, ',')))
            OR (a.target_degree_exclude = TRUE AND (p_degree IS NULL OR NOT p_degree = ANY(string_to_array(a.target_degree, ','))))
        )
        
        -- Experience targeting
        AND (
            a.target_years_experience IS NULL OR a.target_years_experience = ''
            OR (COALESCE(a.target_experience_exclude, FALSE) = FALSE AND p_experience = ANY(string_to_array(a.target_years_experience, ',')))
            OR (a.target_experience_exclude = TRUE AND (p_experience IS NULL OR NOT p_experience = ANY(string_to_array(a.target_years_experience, ','))))
        )
        
    ORDER BY 
        CASE a.importance WHEN 'high' THEN 1 WHEN 'medium' THEN 2 WHEN 'low' THEN 3 END,
        a.display_sequence ASC NULLS LAST,
        a.created_at DESC
    LIMIT p_limit
    OFFSET p_offset;
END;
$func$;


-- 2. Carousel function
DROP FUNCTION IF EXISTS get_carousel_announcements;

CREATE OR REPLACE FUNCTION get_carousel_announcements(
    p_user_id TEXT,
    p_device_id TEXT DEFAULT NULL,
    p_auth_uid TEXT DEFAULT NULL,
    p_platform TEXT DEFAULT NULL,
    p_app_version TEXT DEFAULT NULL,
    p_country TEXT DEFAULT NULL,
    p_city TEXT DEFAULT NULL,
    p_is_logged_in BOOLEAN DEFAULT FALSE,
    p_profession TEXT DEFAULT NULL,
    p_speciality TEXT DEFAULT NULL,
    p_degree TEXT DEFAULT NULL,
    p_experience TEXT DEFAULT NULL,
    p_has_complete_profile BOOLEAN DEFAULT FALSE,
    p_session_number INTEGER DEFAULT 1
)
RETURNS TABLE (
    id UUID,
    title TEXT,
    message TEXT,
    body TEXT,
    surface TEXT,
    importance TEXT,
    kind TEXT,
    priority TEXT,
    action_type TEXT,
    action_value TEXT,
    dismissible BOOLEAN,
    dismissible_mode TEXT,
    metadata JSONB,
    questions JSONB,
    user_status TEXT,
    impression_count INTEGER,
    is_partially_completed BOOLEAN,
    questions_answered INTEGER,
    display_sequence INTEGER,
    carousel_position INTEGER
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $func$
DECLARE
    v_max_items INTEGER;
BEGIN
    SELECT COALESCE((config_value::TEXT)::INTEGER, 5) INTO v_max_items 
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
                    e.id DESC
            ) AS carousel_position
        FROM get_eligible_announcements(
            p_user_id, p_device_id, p_auth_uid, p_platform, p_app_version,
            p_country, p_city, p_is_logged_in, p_profession, p_speciality,
            p_degree, p_experience, p_has_complete_profile, p_session_number,
            'home_banner', 50, 0
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
        eligible.carousel_position::INTEGER
    FROM eligible
    WHERE eligible.carousel_position <= v_max_items;
END;
$func$;


-- 3. Inbox function
DROP FUNCTION IF EXISTS get_inbox_announcements;

CREATE OR REPLACE FUNCTION get_inbox_announcements(
    p_user_id TEXT,
    p_device_id TEXT DEFAULT NULL,
    p_auth_uid TEXT DEFAULT NULL,
    p_platform TEXT DEFAULT NULL,
    p_is_logged_in BOOLEAN DEFAULT FALSE,
    p_profession TEXT DEFAULT NULL,
    p_speciality TEXT DEFAULT NULL,
    p_degree TEXT DEFAULT NULL,
    p_experience TEXT DEFAULT NULL,
    p_has_complete_profile BOOLEAN DEFAULT FALSE,
    p_session_number INTEGER DEFAULT 1,
    p_page INTEGER DEFAULT 1,
    p_page_size INTEGER DEFAULT 20
)
RETURNS TABLE (
    id UUID,
    title TEXT,
    message TEXT,
    body TEXT,
    surface TEXT,
    importance TEXT,
    kind TEXT,
    priority TEXT,
    action_type TEXT,
    action_value TEXT,
    dismissible BOOLEAN,
    dismissible_mode TEXT,
    metadata JSONB,
    questions JSONB,
    user_status TEXT,
    impression_count INTEGER,
    is_partially_completed BOOLEAN,
    questions_answered INTEGER,
    display_sequence INTEGER,
    total_count BIGINT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $func$
DECLARE
    v_offset INTEGER;
    v_total BIGINT;
BEGIN
    v_offset := (p_page - 1) * p_page_size;
    
    SELECT COUNT(*) INTO v_total
    FROM get_eligible_announcements(
        p_user_id, p_device_id, p_auth_uid, p_platform, NULL,
        NULL, NULL, p_is_logged_in, p_profession, p_speciality,
        p_degree, p_experience, p_has_complete_profile,
        p_session_number, 'inbox', 1000, 0
    );
    
    RETURN QUERY
    SELECT 
        e.id, e.title, e.message, e.body, e.surface, e.importance,
        e.kind, e.priority, e.action_type, e.action_value, e.dismissible,
        e.dismissible_mode, e.metadata, e.questions, e.user_status,
        e.impression_count, e.is_partially_completed, e.questions_answered,
        e.display_sequence, v_total AS total_count
    FROM get_eligible_announcements(
        p_user_id, p_device_id, p_auth_uid, p_platform, NULL,
        NULL, NULL, p_is_logged_in, p_profession, p_speciality,
        p_degree, p_experience, p_has_complete_profile,
        p_session_number, 'inbox', p_page_size, v_offset
    ) e;
END;
$func$;


-- 4. Update state function
DROP FUNCTION IF EXISTS update_announcement_state;

CREATE OR REPLACE FUNCTION update_announcement_state(
    p_announcement_id UUID,
    p_user_id TEXT,
    p_status TEXT,
    p_session_number INTEGER DEFAULT NULL,
    p_defer_sessions INTEGER DEFAULT NULL,
    p_defer_hours INTEGER DEFAULT NULL,
    p_questions_answered INTEGER DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $func$
DECLARE
    v_defer_until_session INTEGER;
    v_total_questions INTEGER;
BEGIN
    -- Calculate defer session
    IF p_status = 'deferred' AND p_defer_sessions IS NOT NULL AND p_session_number IS NOT NULL THEN
        v_defer_until_session := p_session_number + p_defer_sessions;
    END IF;
    
    -- Check if survey is fully completed
    IF p_questions_answered IS NOT NULL THEN
        SELECT jsonb_array_length(COALESCE(questions, '[]'::jsonb)) INTO v_total_questions
        FROM public.announcements WHERE id = p_announcement_id;
        
        IF p_questions_answered >= COALESCE(v_total_questions, 0) AND v_total_questions > 0 THEN
            p_status := 'completed';
        END IF;
    END IF;
    
    -- Upsert state
    INSERT INTO public.user_announcement_state (
        announcement_id, user_id, status, last_seen_at,
        defer_until_session, impression_count, is_partially_completed, 
        questions_answered, completed_at, dismissed_at, deferred_at, updated_at
    ) VALUES (
        p_announcement_id, p_user_id, p_status, NOW(),
        v_defer_until_session, 1,
        CASE WHEN p_questions_answered IS NOT NULL AND p_status != 'completed' THEN TRUE ELSE FALSE END,
        COALESCE(p_questions_answered, 0),
        CASE WHEN p_status = 'completed' THEN NOW() ELSE NULL END,
        CASE WHEN p_status = 'dismissed' THEN NOW() ELSE NULL END,
        CASE WHEN p_status = 'deferred' THEN NOW() ELSE NULL END,
        NOW()
    )
    ON CONFLICT (announcement_id, user_id) DO UPDATE SET
        status = EXCLUDED.status,
        last_seen_at = NOW(),
        defer_until_session = COALESCE(EXCLUDED.defer_until_session, user_announcement_state.defer_until_session),
        impression_count = user_announcement_state.impression_count + 1,
        is_partially_completed = EXCLUDED.is_partially_completed,
        questions_answered = GREATEST(EXCLUDED.questions_answered, COALESCE(user_announcement_state.questions_answered, 0)),
        completed_at = COALESCE(EXCLUDED.completed_at, user_announcement_state.completed_at),
        dismissed_at = COALESCE(EXCLUDED.dismissed_at, user_announcement_state.dismissed_at),
        deferred_at = COALESCE(EXCLUDED.deferred_at, user_announcement_state.deferred_at),
        updated_at = NOW();
    
    RETURN jsonb_build_object('status', p_status, 'questions_answered', COALESCE(p_questions_answered, 0));
END;
$func$;


-- 5. Record impression function
DROP FUNCTION IF EXISTS record_announcement_impression;

CREATE OR REPLACE FUNCTION record_announcement_impression(
    p_announcement_id UUID,
    p_user_id TEXT
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $func$
BEGIN
    INSERT INTO public.user_announcement_state (
        announcement_id, user_id, status, impression_count, first_seen_at, last_seen_at, updated_at
    ) VALUES (
        p_announcement_id, p_user_id, 'seen', 1, NOW(), NOW(), NOW()
    )
    ON CONFLICT (announcement_id, user_id) DO UPDATE SET
        impression_count = user_announcement_state.impression_count + 1,
        last_seen_at = NOW(),
        updated_at = NOW();
END;
$func$;


-- Grant permissions
GRANT EXECUTE ON FUNCTION get_eligible_announcements TO authenticated, anon;
GRANT EXECUTE ON FUNCTION get_carousel_announcements TO authenticated, anon;
GRANT EXECUTE ON FUNCTION get_inbox_announcements TO authenticated, anon;
GRANT EXECUTE ON FUNCTION update_announcement_state TO authenticated, anon;
GRANT EXECUTE ON FUNCTION record_announcement_impression TO authenticated, anon;