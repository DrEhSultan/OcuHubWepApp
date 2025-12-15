-- =====================================================
-- COMPLETE BACKEND-DRIVEN ANNOUNCEMENT LOGIC
-- =====================================================
-- All filtering logic handled by backend:
-- - Targeting (profession, country, etc.)
-- - Repeat modes (once, per_app_open, interval_hours)
-- - Dismiss modes (yes, no, remind_later)
-- - CTA completion (disappear_after_cta)
-- - Survey completion tracking
-- =====================================================

-- 1. Main eligibility function with FULL logic
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
        COALESCE(uas.impression_count, 0) AS impression_count,
        COALESCE(uas.is_partially_completed, FALSE) AS is_partially_completed,
        COALESCE(uas.questions_answered, 0) AS questions_answered,
        a.display_sequence
    FROM public.announcements a
    LEFT JOIN public.user_announcement_state uas 
        ON uas.announcement_id = a.id 
        AND uas.user_id = v_effective_user_id
    WHERE 
        -- ==========================================
        -- BASIC FILTERS
        -- ==========================================
        a.is_active = TRUE
        AND a.is_deleted = FALSE
        AND a.status = 'live'
        AND a.start_at <= NOW()
        AND (a.end_at IS NULL OR a.end_at > NOW())
        
        -- ==========================================
        -- SURFACE FILTERING
        -- ==========================================
        AND (
            -- Inbox: show all eligible surfaces (history view)
            (p_surface = 'inbox' AND a.surface IN ('home_banner', 'modal', 'inbox'))
            -- Other surfaces: exact match or modal (modals can appear anywhere)
            OR a.surface = p_surface 
            OR a.surface = 'modal'
        )
        
        -- ==========================================
        -- ELIGIBILITY LOGIC (Repeat Mode + Dismiss Mode + CTA)
        -- ==========================================
        AND (
            -- INBOX: Show ALL eligible announcements (user's history)
            -- Including seen, dismissed, completed - let app display appropriately
            p_surface = 'inbox'
            
            -- CAROUSEL/HOME_BANNER/MODAL: Apply full eligibility logic
            OR (
                -- Case 1: Never seen - always eligible
                uas.status IS NULL
                
                -- Case 2: Surveys/Quizzes with remind_later mode
                -- Keep showing until COMPLETED (all questions answered)
                -- Only hide if explicitly dismissed AND defer period not passed
                OR (
                    a.kind IN ('survey', 'quiz', 'user_insights')
                    AND a.dismissible_mode = 'remind_later'
                    AND (
                        -- Not completed yet - show it
                        (uas.status IS DISTINCT FROM 'completed' AND uas.is_partially_completed = TRUE)
                        OR uas.status IS NULL
                        OR uas.status = 'eligible'
                        OR uas.status = 'seen'
                        -- Deferred but defer period passed - show again
                        OR (uas.status = 'deferred' AND (
                            uas.defer_until_session IS NULL 
                            OR uas.defer_until_session <= p_session_number
                        ))
                    )
                )
                
                -- Case 3: Regular announcements - apply repeat mode logic
                OR (
                    -- Not a survey with remind_later
                    NOT (a.kind IN ('survey', 'quiz', 'user_insights') AND a.dismissible_mode = 'remind_later')
                    AND (
                        -- Status checks
                        uas.status = 'eligible'
                        OR uas.status = 'seen'
                        
                        -- Deferred and ready to show again
                        OR (uas.status = 'deferred' AND (
                            uas.defer_until_session IS NULL 
                            OR uas.defer_until_session <= p_session_number
                        ))
                        
                        -- Completed but repeat_mode allows showing again
                        OR (uas.status = 'completed' AND a.repeat_mode != 'once')
                    )
                    -- Not permanently dismissed
                    AND uas.status IS DISTINCT FROM 'dismissed'
                    AND uas.status IS DISTINCT FROM 'expired'
                    
                    -- Max impressions check
                    AND (a.max_times_seen_per_user IS NULL 
                         OR COALESCE(uas.impression_count, 0) < a.max_times_seen_per_user)
                    
                    -- Repeat mode: once
                    AND (
                        a.repeat_mode != 'once' 
                        OR COALESCE(uas.impression_count, 0) = 0
                    )
                    
                    -- Repeat mode: per_app_open (session interval)
                    AND (
                        a.repeat_mode != 'per_app_open'
                        OR uas.last_seen_session IS NULL
                        OR (p_session_number - uas.last_seen_session) >= COALESCE(a.repeat_session_interval, 1)
                    )
                    
                    -- Repeat mode: interval_hours
                    AND (
                        a.repeat_mode != 'interval_hours'
                        OR uas.last_seen_at IS NULL
                        OR (NOW() - uas.last_seen_at) >= (COALESCE(a.repeat_interval_hours, 24) * INTERVAL '1 hour')
                    )
                    
                    -- CTA completion check (disappear_after_cta)
                    AND (
                        a.disappear_after_cta = FALSE
                        OR uas.status IS DISTINCT FROM 'completed'
                    )
                )
            )
        )
        
        -- ==========================================
        -- TARGETING FILTERS
        -- ==========================================
        -- Platform
        AND (a.target_platform IS NULL OR a.target_platform = 'all' OR a.target_platform = p_platform)
        
        -- Login state
        AND (
            (a.target_logged_in_only = FALSE AND a.target_anonymous_only = FALSE)
            OR (a.target_logged_in_only = TRUE AND p_is_logged_in = TRUE)
            OR (a.target_anonymous_only = TRUE AND p_is_logged_in = FALSE)
        )
        
        -- Incomplete profile targeting
        AND (
            a.target_incomplete_profile = FALSE
            OR (a.target_incomplete_profile = TRUE AND p_has_complete_profile = FALSE)
        )
        
        -- Country (with exclusion)
        AND (
            (a.target_country IS NULL OR a.target_country = '')
            OR (COALESCE(a.target_country_exclude, FALSE) = FALSE 
                AND p_country = ANY(string_to_array(a.target_country, ',')))
            OR (a.target_country_exclude = TRUE 
                AND (p_country IS NULL OR p_country NOT IN (SELECT unnest(string_to_array(a.target_country, ',')))))
        )
        
        -- City (with exclusion)
        AND (
            (a.target_city IS NULL OR a.target_city = '')
            OR (COALESCE(a.target_city_exclude, FALSE) = FALSE 
                AND p_city = ANY(string_to_array(a.target_city, ',')))
            OR (a.target_city_exclude = TRUE 
                AND (p_city IS NULL OR p_city NOT IN (SELECT unnest(string_to_array(a.target_city, ',')))))
        )
        
        -- Profession (with exclusion)
        AND (
            (a.target_profession IS NULL OR a.target_profession = '')
            OR (COALESCE(a.target_profession_exclude, FALSE) = FALSE 
                AND p_profession = ANY(string_to_array(a.target_profession, ',')))
            OR (a.target_profession_exclude = TRUE 
                AND (p_profession IS NULL OR p_profession NOT IN (SELECT unnest(string_to_array(a.target_profession, ',')))))
        )
        
        -- Speciality (with exclusion)
        AND (
            (a.target_speciality IS NULL OR a.target_speciality = '')
            OR (COALESCE(a.target_speciality_exclude, FALSE) = FALSE 
                AND p_speciality = ANY(string_to_array(a.target_speciality, ',')))
            OR (a.target_speciality_exclude = TRUE 
                AND (p_speciality IS NULL OR p_speciality NOT IN (SELECT unnest(string_to_array(a.target_speciality, ',')))))
        )
        
        -- Degree (with exclusion)
        AND (
            (a.target_degree IS NULL OR a.target_degree = '')
            OR (COALESCE(a.target_degree_exclude, FALSE) = FALSE 
                AND p_degree = ANY(string_to_array(a.target_degree, ',')))
            OR (a.target_degree_exclude = TRUE 
                AND (p_degree IS NULL OR p_degree NOT IN (SELECT unnest(string_to_array(a.target_degree, ',')))))
        )
        
        -- Experience (with exclusion)
        AND (
            (a.target_years_experience IS NULL OR a.target_years_experience = '')
            OR (COALESCE(a.target_experience_exclude, FALSE) = FALSE 
                AND p_experience = ANY(string_to_array(a.target_years_experience, ',')))
            OR (a.target_experience_exclude = TRUE 
                AND (p_experience IS NULL OR p_experience NOT IN (SELECT unnest(string_to_array(a.target_years_experience, ',')))))
        )
        
    ORDER BY 
        CASE a.importance WHEN 'high' THEN 1 WHEN 'medium' THEN 2 WHEN 'low' THEN 3 END,
        a.display_sequence ASC NULLS LAST,
        a.created_at DESC
    LIMIT p_limit
    OFFSET p_offset;
END;
$func$;


-- 2. Carousel function (uses get_eligible_announcements)
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
        eligible.carousel_position::INTEGER
    FROM eligible
    WHERE eligible.carousel_position <= v_max_items;
END;
$func$;


-- 3. Inbox function (uses get_eligible_announcements with 'inbox' surface)
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


-- Grant permissions
GRANT EXECUTE ON FUNCTION get_eligible_announcements TO authenticated, anon;
GRANT EXECUTE ON FUNCTION get_carousel_announcements TO authenticated, anon;
GRANT EXECUTE ON FUNCTION get_inbox_announcements TO authenticated, anon;


-- 4. Create update_announcement_state function (MISSING!)
-- This function updates user state when they interact with announcements
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
    v_result JSONB;
    v_defer_until_session INTEGER;
    v_defer_until_time TIMESTAMPTZ;
    v_is_partially_completed BOOLEAN;
    v_total_questions INTEGER;
BEGIN
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
        NOW(),
        p_session_number,
        v_defer_until_session,
        v_defer_until_time,
        CASE WHEN p_status = 'deferred' THEN 1 ELSE 0 END,
        COALESCE(v_is_partially_completed, FALSE),
        COALESCE(p_questions_answered, 0),
        1,
        CASE WHEN p_status = 'completed' THEN NOW() ELSE NULL END,
        CASE WHEN p_status = 'dismissed' THEN NOW() ELSE NULL END,
        CASE WHEN p_status = 'deferred' THEN NOW() ELSE NULL END,
        NOW()
    )
    ON CONFLICT (announcement_id, user_id) DO UPDATE SET
        status = EXCLUDED.status,
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
        impression_count = user_announcement_state.impression_count + 1,
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
$func$;


-- 5. Create record_announcement_impression function (for lightweight impression tracking)
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
        announcement_id,
        user_id,
        status,
        impression_count,
        first_seen_at,
        last_seen_at,
        updated_at
    ) VALUES (
        p_announcement_id,
        p_user_id,
        'seen',
        1,
        NOW(),
        NOW(),
        NOW()
    )
    ON CONFLICT (announcement_id, user_id) DO UPDATE SET
        impression_count = user_announcement_state.impression_count + 1,
        last_seen_at = NOW(),
        updated_at = NOW();
END;
$func$;

-- Grant permissions
GRANT EXECUTE ON FUNCTION update_announcement_state TO authenticated, anon;
GRANT EXECUTE ON FUNCTION record_announcement_impression TO authenticated, anon;