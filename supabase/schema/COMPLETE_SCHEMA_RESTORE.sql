-- =====================================================
-- OCUHUB COMPLETE SCHEMA RESTORE
-- Generated: December 16, 2025
-- 
-- This file contains EVERYTHING needed to restore the database:
-- - All tables with columns, types, defaults
-- - All indexes and constraints  
-- - All functions with complete code
-- - All triggers and permissions
-- - Essential configuration data
-- 
-- Usage: Run this single file in Supabase SQL Editor
-- =====================================================

-- =====================================================
-- TABLES
-- =====================================================

-- Users table
CREATE TABLE IF NOT EXISTS public.users (
    auth_uid TEXT PRIMARY KEY,
    user_id TEXT,
    email TEXT,
    name TEXT,
    image_uri TEXT,
    is_verified BOOLEAN DEFAULT FALSE,
    is_anonymous BOOLEAN DEFAULT TRUE,
    login_method TEXT,
    insights JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    is_synced BOOLEAN DEFAULT FALSE,
    last_synced_at TIMESTAMPTZ,
    last_country TEXT,
    last_city TEXT,
    last_platform TEXT,
    last_device_brand TEXT,
    last_is_real_device BOOLEAN,
    last_ip TEXT,
    last_location_updated_at TIMESTAMPTZ
);

-- Announcements table
CREATE TABLE IF NOT EXISTS public.announcements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    message TEXT,
    body TEXT,
    surface TEXT NOT NULL,
    importance TEXT NOT NULL DEFAULT 'low',
    kind TEXT NOT NULL DEFAULT 'announcement',
    priority TEXT NOT NULL DEFAULT 'normal',
    audience TEXT NOT NULL DEFAULT 'all',
    action_type TEXT NOT NULL DEFAULT 'none',
    action_value TEXT,
    start_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    end_at TIMESTAMPTZ,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    is_deleted BOOLEAN NOT NULL DEFAULT FALSE,
    deleted_at TIMESTAMPTZ,
    deleted_by TEXT,
    dismissible BOOLEAN NOT NULL DEFAULT TRUE,
    repeat_mode TEXT NOT NULL DEFAULT 'once',
    repeat_interval_hours INTEGER,
    max_times_seen_per_user INTEGER,
    max_impressions INTEGER,
    show_in_carousel BOOLEAN NOT NULL DEFAULT TRUE,
    show_in_notifications BOOLEAN NOT NULL DEFAULT TRUE,
    status TEXT NOT NULL DEFAULT 'scheduled',
    target_country TEXT,
    target_speciality TEXT,
    target_min_app_version TEXT,
    target_max_app_version TEXT,
    target_logged_in_only BOOLEAN NOT NULL DEFAULT FALSE,
    target_anonymous_only BOOLEAN NOT NULL DEFAULT FALSE,
    metadata JSONB DEFAULT '{}'::jsonb,
    questions JSONB DEFAULT '[]'::jsonb,
    responses JSONB DEFAULT '[]'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by TEXT,
    updated_by TEXT,
    version INTEGER NOT NULL DEFAULT 1,
    dismissible_mode TEXT NOT NULL DEFAULT 'yes',
    remind_later_count INTEGER DEFAULT 3,
    remind_later_sessions INTEGER DEFAULT 1,
    target_degree TEXT,
    target_subspecialty TEXT,
    target_profession TEXT,
    target_hospital TEXT,
    target_years_experience TEXT,
    target_platform TEXT,
    target_is_real_device BOOLEAN,
    target_device_brand TEXT,
    target_ip_addresses TEXT,
    target_city TEXT,
    disappear_after_cta BOOLEAN NOT NULL DEFAULT TRUE,
    repeat_session_interval INTEGER DEFAULT 1,
    display_sequence INTEGER DEFAULT 0,
    carousel_max_count INTEGER DEFAULT 5,
    target_profession_exclude BOOLEAN DEFAULT FALSE,
    target_speciality_exclude BOOLEAN DEFAULT FALSE,
    target_degree_exclude BOOLEAN DEFAULT FALSE,
    target_experience_exclude BOOLEAN DEFAULT FALSE,
    target_country_exclude BOOLEAN DEFAULT FALSE,
    target_city_exclude BOOLEAN DEFAULT FALSE,
    target_incomplete_profile BOOLEAN DEFAULT FALSE
);

-- User announcement state table
CREATE TABLE IF NOT EXISTS public.user_announcement_state (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    announcement_id UUID NOT NULL REFERENCES announcements(id) ON DELETE CASCADE,
    user_id TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'eligible',
    first_seen_at TIMESTAMPTZ,
    last_seen_at TIMESTAMPTZ,
    dismissed_at TIMESTAMPTZ,
    deferred_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    defer_count INTEGER DEFAULT 0,
    defer_until_session INTEGER,
    defer_until_time TIMESTAMPTZ,
    impression_count INTEGER DEFAULT 0,
    is_partially_completed BOOLEAN DEFAULT FALSE,
    questions_answered INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    last_seen_session INTEGER DEFAULT 0,
    UNIQUE(announcement_id, user_id)
);

-- Announcement responses table
CREATE TABLE IF NOT EXISTS public.announcement_responses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    announcement_id UUID NOT NULL REFERENCES announcements(id) ON DELETE CASCADE,
    question_id TEXT NOT NULL,
    user_id TEXT NOT NULL,
    user_auth_uid TEXT,
    option_value TEXT,
    text_value TEXT,
    numeric_value NUMERIC,
    link_to_profile TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    first_option_value TEXT,
    first_text_value TEXT,
    first_numeric_value NUMERIC,
    first_answered_at TIMESTAMPTZ,
    UNIQUE(announcement_id, question_id, user_id)
);

-- Announcement impressions table
CREATE TABLE IF NOT EXISTS public.announcement_impressions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    announcement_id UUID NOT NULL REFERENCES announcements(id) ON DELETE CASCADE,
    user_id TEXT NOT NULL,
    impressions INTEGER DEFAULT 1,
    last_seen_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(announcement_id, user_id)
);

-- Announcement config table
CREATE TABLE IF NOT EXISTS public.announcement_config (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    config_key TEXT UNIQUE NOT NULL,
    config_value TEXT,
    description TEXT,
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    updated_by TEXT
);

-- App sessions table
CREATE TABLE IF NOT EXISTS public.app_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id TEXT NOT NULL,
    auth_uid TEXT,
    start_time TIMESTAMPTZ DEFAULT NOW(),
    end_time TIMESTAMPTZ,
    public_ip TEXT,
    country TEXT,
    region TEXT,
    city TEXT,
    device_info JSONB,
    app_version TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    is_synced BOOLEAN DEFAULT FALSE,
    last_synced_at TIMESTAMPTZ,
    os_platform TEXT,
    device_brand TEXT,
    device_model TEXT,
    is_device BOOLEAN,
    device_type TEXT,
    os_version TEXT,
    is_location_live BOOLEAN,
    last_live_location_fetched_at TIMESTAMPTZ,
    fallback_location_used_at TIMESTAMPTZ
);

-- Feedbacks table
CREATE TABLE IF NOT EXISTS public.feedbacks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id TEXT NOT NULL,
    auth_uid TEXT,
    type TEXT NOT NULL,
    message TEXT,
    tool_id TEXT,
    screen_state JSONB,
    conclusion_data JSONB,
    rating INTEGER,
    metadata JSONB,
    submitted_at TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    is_synced BOOLEAN DEFAULT FALSE,
    last_synced_at TIMESTAMPTZ
);

-- Tool settings table
CREATE TABLE IF NOT EXISTS public.tool_settings (
    user_id TEXT NOT NULL,
    tool_id TEXT NOT NULL,
    auth_uid TEXT,
    settings JSONB DEFAULT '{}'::jsonb,
    is_favourite BOOLEAN DEFAULT FALSE,
    order_in_app INTEGER,
    order_in_category INTEGER,
    order_in_section INTEGER,
    usage_count INTEGER DEFAULT 0,
    usage_duration_sec INTEGER DEFAULT 0,
    last_used_at TIMESTAMPTZ,
    is_archived BOOLEAN DEFAULT FALSE,
    last_updated TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    is_synced BOOLEAN DEFAULT FALSE,
    last_synced_at TIMESTAMPTZ,
    PRIMARY KEY (user_id, tool_id)
);

-- Section settings table
CREATE TABLE IF NOT EXISTS public.section_settings (
    user_id TEXT NOT NULL,
    section_id TEXT NOT NULL,
    auth_uid TEXT,
    settings JSONB DEFAULT '{}'::jsonb,
    filters JSONB DEFAULT '{}'::jsonb,
    is_archived BOOLEAN DEFAULT FALSE,
    last_updated TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    is_synced BOOLEAN DEFAULT FALSE,
    last_synced_at TIMESTAMPTZ,
    PRIMARY KEY (user_id, section_id)
);

-- Category settings table
CREATE TABLE IF NOT EXISTS public.category_settings (
    user_id TEXT NOT NULL,
    category_id TEXT NOT NULL,
    auth_uid TEXT,
    settings JSONB DEFAULT '{}'::jsonb,
    sort_order INTEGER,
    is_expanded BOOLEAN DEFAULT TRUE,
    is_visible BOOLEAN DEFAULT TRUE,
    is_archived BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    is_synced BOOLEAN DEFAULT FALSE,
    last_synced_at TIMESTAMPTZ,
    PRIMARY KEY (user_id, category_id)
);

-- Screen settings table
CREATE TABLE IF NOT EXISTS public.screen_settings (
    user_id TEXT NOT NULL,
    screen_id TEXT NOT NULL,
    auth_uid TEXT,
    settings JSONB DEFAULT '{}'::jsonb,
    is_archived BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    is_synced BOOLEAN DEFAULT FALSE,
    last_synced_at TIMESTAMPTZ,
    PRIMARY KEY (user_id, screen_id)
);

-- App settings table
CREATE TABLE IF NOT EXISTS public.app_settings (
    user_id TEXT NOT NULL,
    setting_key TEXT NOT NULL,
    auth_uid TEXT,
    setting_value TEXT,
    custom_settings JSONB DEFAULT '{}'::jsonb,
    is_archived BOOLEAN DEFAULT FALSE,
    last_updated TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    is_synced BOOLEAN DEFAULT FALSE,
    last_synced_at TIMESTAMPTZ,
    PRIMARY KEY (user_id, setting_key)
);

-- Tool usage events table
CREATE TABLE IF NOT EXISTS public.tool_usage_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id TEXT NOT NULL,
    auth_uid TEXT,
    tool_id TEXT NOT NULL,
    tool_session_id TEXT,
    app_session_id TEXT,
    event_type TEXT NOT NULL,
    event_timestamp TIMESTAMPTZ DEFAULT NOW(),
    event_data JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    is_synced BOOLEAN DEFAULT FALSE,
    last_synced_at TIMESTAMPTZ
);

-- User sync states table
CREATE TABLE IF NOT EXISTS public.user_sync_states (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id TEXT NOT NULL,
    auth_uid TEXT,
    email TEXT,
    decision TEXT NOT NULL,
    reason TEXT,
    decision_at TIMESTAMPTZ DEFAULT NOW(),
    device_info JSONB,
    archived_previous_settings JSONB
);

-- Admin users table
CREATE TABLE IF NOT EXISTS public.admin_users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id TEXT UNIQUE,
    email TEXT UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    display_name TEXT,
    role TEXT DEFAULT 'admin',
    is_active BOOLEAN DEFAULT TRUE,
    last_login_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    created_by TEXT
);

-- Credit asset types table
CREATE TABLE IF NOT EXISTS public.credit_asset_types (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT UNIQUE NOT NULL,
    display_name TEXT NOT NULL,
    description TEXT,
    icon TEXT,
    sort_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Credit sites table
CREATE TABLE IF NOT EXISTS public.credit_sites (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    asset_type_id UUID REFERENCES credit_asset_types(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    display_name TEXT NOT NULL,
    website_url TEXT,
    attribution_format TEXT,
    description TEXT,
    logo_url TEXT,
    sort_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Credit links table
CREATE TABLE IF NOT EXISTS public.credit_links (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    site_id UUID REFERENCES credit_sites(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    url TEXT NOT NULL,
    author TEXT,
    description TEXT,
    sort_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tool usage summary table
CREATE TABLE IF NOT EXISTS public.tool_usage_summary (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tool_slug TEXT UNIQUE NOT NULL,
    tool_name TEXT,
    usage_count INTEGER DEFAULT 0,
    total_duration_seconds INTEGER DEFAULT 0,
    days_used INTEGER DEFAULT 0,
    months_used INTEGER DEFAULT 0,
    years_used INTEGER DEFAULT 0,
    last_used_at TIMESTAMPTZ,
    unique_users INTEGER DEFAULT 0,
    session_count INTEGER DEFAULT 0,
    country_count INTEGER DEFAULT 0,
    city_count INTEGER DEFAULT 0,
    avg_usage_per_user NUMERIC,
    avg_time_per_user_seconds NUMERIC,
    avg_calc_time_ms NUMERIC,
    usage_by_date JSONB DEFAULT '{}'::jsonb,
    duration_by_date JSONB DEFAULT '{}'::jsonb,
    country_breakdown JSONB DEFAULT '{}'::jsonb,
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- User usage summary table
CREATE TABLE IF NOT EXISTS public.user_usage_summary (
    user_id TEXT PRIMARY KEY,
    full_name TEXT,
    email TEXT,
    country TEXT,
    city TEXT,
    total_sessions INTEGER DEFAULT 0,
    most_used_tool TEXT,
    tools JSONB DEFAULT '[]'::jsonb,
    locations JSONB DEFAULT '[]'::jsonb,
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- INDEXES
-- =====================================================
CREATE INDEX IF NOT EXISTS idx_announcements_active ON announcements(is_active, is_deleted, start_at, end_at);
CREATE INDEX IF NOT EXISTS idx_announcements_surface ON announcements(surface) WHERE is_deleted = FALSE;
CREATE INDEX IF NOT EXISTS idx_user_announcement_state_user ON user_announcement_state(user_id);
CREATE INDEX IF NOT EXISTS idx_user_announcement_state_announcement ON user_announcement_state(announcement_id);
CREATE INDEX IF NOT EXISTS idx_announcement_responses_announcement ON announcement_responses(announcement_id);
CREATE INDEX IF NOT EXISTS idx_announcement_responses_user ON announcement_responses(user_id);
CREATE INDEX IF NOT EXISTS idx_app_sessions_user ON app_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_app_sessions_auth ON app_sessions(auth_uid);
CREATE INDEX IF NOT EXISTS idx_tool_usage_events_user ON tool_usage_events(user_id);
CREATE INDEX IF NOT EXISTS idx_tool_usage_events_tool ON tool_usage_events(tool_id);
CREATE INDEX IF NOT EXISTS idx_feedbacks_user ON feedbacks(user_id);

-- =====================================================
-- TRIGGERS
-- =====================================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_announcements_updated_at
    BEFORE UPDATE ON announcements
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_user_announcement_state_updated_at
    BEFORE UPDATE ON user_announcement_state
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_announcement_responses_updated_at
    BEFORE UPDATE ON announcement_responses
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_app_sessions_updated_at
    BEFORE UPDATE ON app_sessions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_feedbacks_updated_at
    BEFORE UPDATE ON feedbacks
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_tool_settings_updated_at
    BEFORE UPDATE ON tool_settings
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- FUNCTIONS
-- =====================================================

-- Main eligibility function
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
        
        -- Targeting filters
        AND (a.target_logged_in_only = FALSE OR p_is_logged_in = TRUE)
        AND (a.target_anonymous_only = FALSE OR p_is_logged_in = FALSE)
        AND (a.target_country IS NULL OR a.target_country = '' OR p_country = ANY(string_to_array(a.target_country, ',')))
        AND (a.target_city IS NULL OR a.target_city = '' OR p_city = ANY(string_to_array(a.target_city, ',')))
        AND (a.target_speciality IS NULL OR a.target_speciality = '' OR p_speciality = ANY(string_to_array(a.target_speciality, ',')))
        AND (a.target_profession IS NULL OR a.target_profession = '' OR p_profession = ANY(string_to_array(a.target_profession, ',')))
        AND (a.target_degree IS NULL OR a.target_degree = '' OR p_degree = ANY(string_to_array(a.target_degree, ',')))
        AND (a.target_years_experience IS NULL OR a.target_years_experience = '' OR p_experience = ANY(string_to_array(a.target_years_experience, ',')))
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
$func$;

-- Carousel function
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

-- Inbox function
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

-- Update state function
DROP FUNCTION IF EXISTS update_announcement_state;
CREATE OR REPLACE FUNCTION update_announcement_state(
    p_announcement_id UUID,
    p_user_id TEXT,
    p_status TEXT DEFAULT 'seen',
    p_impression_count INTEGER DEFAULT NULL,
    p_questions_answered INTEGER DEFAULT NULL,
    p_is_partially_completed BOOLEAN DEFAULT NULL,
    p_defer_until_session INTEGER DEFAULT NULL,
    p_last_seen_session INTEGER DEFAULT NULL
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
        questions_answered,
        is_partially_completed,
        defer_until_session,
        last_seen_session,
        first_seen_at,
        last_seen_at,
        dismissed_at,
        deferred_at,
        completed_at
    ) VALUES (
        p_announcement_id,
        p_user_id,
        p_status,
        COALESCE(p_impression_count, 1),
        COALESCE(p_questions_answered, 0),
        COALESCE(p_is_partially_completed, FALSE),
        p_defer_until_session,
        COALESCE(p_last_seen_session, 1),
        CASE WHEN p_status IN ('seen', 'eligible') THEN NOW() ELSE NULL END,
        CASE WHEN p_status = 'seen' THEN NOW() ELSE NULL END,
        CASE WHEN p_status = 'dismissed' THEN NOW() ELSE NULL END,
        CASE WHEN p_status = 'deferred' THEN NOW() ELSE NULL END,
        CASE WHEN p_status = 'completed' THEN NOW() ELSE NULL END
    )
    ON CONFLICT (announcement_id, user_id) 
    DO UPDATE SET
        status = EXCLUDED.status,
        impression_count = COALESCE(EXCLUDED.impression_count, user_announcement_state.impression_count),
        questions_answered = COALESCE(EXCLUDED.questions_answered, user_announcement_state.questions_answered),
        is_partially_completed = COALESCE(EXCLUDED.is_partially_completed, user_announcement_state.is_partially_completed),
        defer_until_session = COALESCE(EXCLUDED.defer_until_session, user_announcement_state.defer_until_session),
        last_seen_session = COALESCE(EXCLUDED.last_seen_session, user_announcement_state.last_seen_session),
        last_seen_at = CASE WHEN EXCLUDED.status = 'seen' THEN NOW() ELSE user_announcement_state.last_seen_at END,
        dismissed_at = CASE WHEN EXCLUDED.status = 'dismissed' THEN NOW() ELSE user_announcement_state.dismissed_at END,
        deferred_at = CASE WHEN EXCLUDED.status = 'deferred' THEN NOW() ELSE user_announcement_state.deferred_at END,
        completed_at = CASE WHEN EXCLUDED.status = 'completed' THEN NOW() ELSE user_announcement_state.completed_at END,
        updated_at = NOW();
END;
$func$;

-- =====================================================
-- ROW LEVEL SECURITY
-- =====================================================
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE announcements ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_announcement_state ENABLE ROW LEVEL SECURITY;
ALTER TABLE announcement_responses ENABLE ROW LEVEL SECURITY;
ALTER TABLE app_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE feedbacks ENABLE ROW LEVEL SECURITY;
ALTER TABLE tool_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE tool_usage_events ENABLE ROW LEVEL SECURITY;

-- Service role has full access
CREATE POLICY "service_role_all_users" ON users FOR ALL USING (auth.role() = 'service_role');
CREATE POLICY "service_role_all_announcements" ON announcements FOR ALL USING (auth.role() = 'service_role');
CREATE POLICY "service_role_all_user_announcement_state" ON user_announcement_state FOR ALL USING (auth.role() = 'service_role');
CREATE POLICY "service_role_all_announcement_responses" ON announcement_responses FOR ALL USING (auth.role() = 'service_role');
CREATE POLICY "service_role_all_app_sessions" ON app_sessions FOR ALL USING (auth.role() = 'service_role');
CREATE POLICY "service_role_all_feedbacks" ON feedbacks FOR ALL USING (auth.role() = 'service_role');
CREATE POLICY "service_role_all_tool_settings" ON tool_settings FOR ALL USING (auth.role() = 'service_role');
CREATE POLICY "service_role_all_tool_usage_events" ON tool_usage_events FOR ALL USING (auth.role() = 'service_role');

-- Anon can read active announcements
CREATE POLICY "anon_read_announcements" ON announcements 
    FOR SELECT USING (is_active = TRUE AND is_deleted = FALSE);

-- =====================================================
-- CONFIGURATION DATA
-- =====================================================
INSERT INTO public.announcement_config (config_key, config_value, description) VALUES
('carousel_max_items', '5', 'Maximum number of items to show in carousel')
ON CONFLICT (config_key) DO NOTHING;

-- =====================================================
-- PERMISSIONS
-- =====================================================
GRANT EXECUTE ON FUNCTION get_eligible_announcements TO authenticated, anon;
GRANT EXECUTE ON FUNCTION get_carousel_announcements TO authenticated, anon;
GRANT EXECUTE ON FUNCTION get_inbox_announcements TO authenticated, anon;
GRANT EXECUTE ON FUNCTION update_announcement_state TO authenticated, anon;

-- =====================================================
-- VERIFICATION
-- =====================================================
SELECT 'OcuHub database schema restored successfully!' as status;
SELECT COUNT(*) as table_count FROM information_schema.tables WHERE table_schema = 'public';
SELECT COUNT(*) as function_count FROM information_schema.routines WHERE routine_schema = 'public';