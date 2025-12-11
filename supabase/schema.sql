-- =====================================================
-- SUPABASE COMPLETE SCHEMA - FRESH INSTALL
-- OcuHub Mobile App + Admin Dashboard
-- Date: December 2025
-- =====================================================

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Enable Row Level Security globally
ALTER DATABASE postgres SET row_security = on;

-- =====================================================
-- DROP EXISTING TABLES (for fresh install)
-- =====================================================
DROP TABLE IF EXISTS public.announcement_impressions CASCADE;
DROP TABLE IF EXISTS public.announcement_responses CASCADE;
DROP TABLE IF EXISTS public.admin_users CASCADE;
DROP TABLE IF EXISTS public.tool_usage_summary CASCADE;
DROP TABLE IF EXISTS public.user_usage_summary CASCADE;
DROP TABLE IF EXISTS public.announcements CASCADE;
DROP TABLE IF EXISTS public.feedbacks CASCADE;
DROP TABLE IF EXISTS public.tool_usage_events CASCADE;
DROP TABLE IF EXISTS public.user_sync_states CASCADE;
DROP TABLE IF EXISTS public.tool_settings CASCADE;
DROP TABLE IF EXISTS public.category_settings CASCADE;
DROP TABLE IF EXISTS public.section_settings CASCADE;
DROP TABLE IF EXISTS public.screen_settings CASCADE;
DROP TABLE IF EXISTS public.app_settings CASCADE;
DROP TABLE IF EXISTS public.app_sessions CASCADE;
DROP TABLE IF EXISTS public.users CASCADE;

DROP VIEW IF EXISTS public.tool_usage_events_enriched CASCADE;
DROP VIEW IF EXISTS public.dashboard_announcements CASCADE;
DROP VIEW IF EXISTS public.dashboard_feedbacks CASCADE;

DROP FUNCTION IF EXISTS update_updated_at_column() CASCADE;

-- =====================================================
-- TABLE DEFINITIONS
-- =====================================================

-- 1. USERS TABLE
CREATE TABLE public.users (
    auth_uid TEXT PRIMARY KEY,
    user_id TEXT UNIQUE NOT NULL,
    email TEXT,
    name TEXT,
    image_uri TEXT,
    is_verified BOOLEAN DEFAULT false,
    is_anonymous BOOLEAN DEFAULT false,
    login_method TEXT DEFAULT 'anonymous',
    insights JSONB DEFAULT '{}'::jsonb,  -- User profile insights from surveys (profession, specialty, etc.)
    -- Last known location/device info (auto-updated from app_sessions for faster targeting)
    last_country TEXT,                   -- ISO country code from most recent session
    last_city TEXT,                      -- City from most recent session
    last_platform TEXT,                  -- 'ios' or 'android' from most recent session
    last_device_brand TEXT,              -- Device brand from most recent session
    last_is_real_device BOOLEAN,         -- Whether last session was on real device
    last_ip TEXT,                        -- Last known IP address
    last_location_updated_at TIMESTAMPTZ,-- When location was last updated
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    is_synced BOOLEAN DEFAULT false,
    last_synced_at TIMESTAMPTZ,
    CONSTRAINT users_auth_user_match CHECK (user_id = auth_uid)
);

-- 2. APP_SESSIONS TABLE
CREATE TABLE public.app_sessions (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL,
    auth_uid TEXT NOT NULL,
    start_time TIMESTAMPTZ DEFAULT NOW(),
    end_time TIMESTAMPTZ,
    public_ip TEXT,
    country TEXT,
    region TEXT,
    city TEXT,
    device_info JSONB,
    app_version TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    is_synced BOOLEAN DEFAULT false,
    last_synced_at TIMESTAMPTZ,
    os_platform TEXT,
    device_brand TEXT,
    device_model TEXT,
    is_device BOOLEAN,
    device_type INTEGER,
    os_version TEXT,
    is_location_live BOOLEAN DEFAULT true,
    last_live_location_fetched_at TIMESTAMPTZ,
    fallback_location_used_at TIMESTAMPTZ,
    CONSTRAINT app_sessions_user_match CHECK (user_id = auth_uid)
);

-- 3. APP_SETTINGS TABLE
CREATE TABLE public.app_settings (
    user_id TEXT NOT NULL,
    setting_key TEXT NOT NULL,
    auth_uid TEXT NOT NULL,
    setting_value JSONB,
    custom_settings JSONB,
    is_archived BOOLEAN DEFAULT false,
    last_updated TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    is_synced BOOLEAN DEFAULT false,
    last_synced_at TIMESTAMPTZ,
    PRIMARY KEY (user_id, setting_key),
    CONSTRAINT app_settings_user_match CHECK (user_id = auth_uid)
);

-- 4. SCREEN_SETTINGS TABLE
CREATE TABLE public.screen_settings (
    user_id TEXT NOT NULL,
    screen_id TEXT NOT NULL,
    auth_uid TEXT NOT NULL,
    settings JSONB,
    is_archived BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    is_synced BOOLEAN DEFAULT false,
    last_synced_at TIMESTAMPTZ,
    PRIMARY KEY (user_id, screen_id),
    CONSTRAINT screen_settings_user_match CHECK (user_id = auth_uid)
);

-- 5. SECTION_SETTINGS TABLE
CREATE TABLE public.section_settings (
    user_id TEXT NOT NULL,
    section_id TEXT NOT NULL,
    auth_uid TEXT NOT NULL,
    settings JSONB,
    filters JSONB,
    is_archived BOOLEAN DEFAULT false,
    last_updated TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    is_synced BOOLEAN DEFAULT false,
    last_synced_at TIMESTAMPTZ,
    PRIMARY KEY (user_id, section_id),
    CONSTRAINT section_settings_user_match CHECK (user_id = auth_uid)
);

-- 6. CATEGORY_SETTINGS TABLE
CREATE TABLE public.category_settings (
    user_id TEXT NOT NULL,
    category_id TEXT NOT NULL,
    auth_uid TEXT NOT NULL,
    settings JSONB DEFAULT '{}'::jsonb,
    sort_order INTEGER DEFAULT 0,
    is_expanded BOOLEAN DEFAULT false,
    is_visible BOOLEAN DEFAULT true,
    is_archived BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    is_synced BOOLEAN DEFAULT false,
    last_synced_at TIMESTAMPTZ,
    PRIMARY KEY (user_id, category_id),
    CONSTRAINT category_settings_user_match CHECK (user_id = auth_uid)
);

-- 7. TOOL_SETTINGS TABLE
CREATE TABLE public.tool_settings (
    user_id TEXT NOT NULL,
    tool_id TEXT NOT NULL,
    auth_uid TEXT NOT NULL,
    settings JSONB,
    is_favourite BOOLEAN DEFAULT false,
    order_in_app INTEGER DEFAULT 0,
    order_in_category INTEGER DEFAULT 0,
    order_in_section INTEGER DEFAULT 0,
    usage_count INTEGER DEFAULT 0,
    usage_duration_sec INTEGER DEFAULT 0,
    last_used_at TIMESTAMPTZ,
    is_archived BOOLEAN DEFAULT false,
    last_updated TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    is_synced BOOLEAN DEFAULT false,
    last_synced_at TIMESTAMPTZ,
    PRIMARY KEY (user_id, tool_id),
    CONSTRAINT tool_settings_user_match CHECK (user_id = auth_uid)
);

-- 8. USER_SYNC_STATES TABLE
CREATE TABLE public.user_sync_states (
    id TEXT PRIMARY KEY,
    user_id TEXT,
    auth_uid TEXT NOT NULL,
    email TEXT,
    decision TEXT CHECK (decision IN ('restore','decline')),
    reason TEXT,
    decision_at TIMESTAMPTZ DEFAULT NOW(),
    device_info JSONB,
    archived_previous_settings BOOLEAN DEFAULT false,
    CONSTRAINT user_sync_states_user_match CHECK (user_id IS NULL OR user_id = auth_uid)
);

-- 9. TOOL_USAGE_EVENTS TABLE
CREATE TABLE public.tool_usage_events (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL,
    auth_uid TEXT NOT NULL,
    tool_id TEXT NOT NULL,
    tool_session_id TEXT,
    app_session_id TEXT,
    event_type TEXT NOT NULL,
    event_timestamp TIMESTAMPTZ DEFAULT NOW(),
    event_data JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    is_synced BOOLEAN DEFAULT false,
    last_synced_at TIMESTAMPTZ,
    CONSTRAINT tool_usage_events_user_match CHECK (user_id = auth_uid)
);

-- 10. FEEDBACKS TABLE
CREATE TABLE public.feedbacks (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL,
    auth_uid TEXT NOT NULL,
    type TEXT,
    message TEXT,
    tool_id TEXT,
    screen_state JSONB,
    conclusion_data JSONB,
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    metadata JSONB,
    submitted_at TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    is_synced BOOLEAN DEFAULT false,
    last_synced_at TIMESTAMPTZ,
    CONSTRAINT feedbacks_user_match CHECK (user_id = auth_uid)
);

-- 11. ANNOUNCEMENTS TABLE
CREATE TABLE public.announcements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    message TEXT,
    body TEXT,
    surface TEXT NOT NULL CHECK (surface IN ('home_banner', 'modal', 'inbox', 'tooltip')),
    importance TEXT NOT NULL DEFAULT 'low' CHECK (importance IN ('low', 'medium', 'high')),
    kind TEXT NOT NULL DEFAULT 'announcement' CHECK (kind IN ('announcement','survey')),
    priority TEXT NOT NULL DEFAULT 'normal' CHECK (priority IN ('low','normal','high')),
    audience TEXT NOT NULL DEFAULT 'all' CHECK (audience IN ('all','doctors','residents','students')),
    action_type TEXT NOT NULL DEFAULT 'none' CHECK (action_type IN ('none', 'open_link', 'open_screen', 'open_tool')),
    action_value TEXT,
    start_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    end_at TIMESTAMPTZ,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    is_deleted BOOLEAN NOT NULL DEFAULT FALSE,
    deleted_at TIMESTAMPTZ,
    deleted_by TEXT,
    dismissible BOOLEAN NOT NULL DEFAULT TRUE,
    dismissible_mode TEXT NOT NULL DEFAULT 'yes' CHECK (dismissible_mode IN ('yes', 'no', 'remind_later')),
    remind_later_count INTEGER DEFAULT 3,
    remind_later_sessions INTEGER DEFAULT 1,
    repeat_mode TEXT NOT NULL DEFAULT 'once' CHECK (repeat_mode IN ('once', 'per_app_open', 'interval_hours')),
    repeat_interval_hours INTEGER,
    max_times_seen_per_user INTEGER,
    max_impressions INTEGER,
    show_in_carousel BOOLEAN NOT NULL DEFAULT true,
    show_in_notifications BOOLEAN NOT NULL DEFAULT true,
    status TEXT NOT NULL DEFAULT 'scheduled' CHECK (status IN ('scheduled','live','ended')),
    -- Basic Targeting
    target_country TEXT,              -- ISO country codes, comma-separated (e.g., 'US,SA,EG')
    target_city TEXT,                 -- City names, comma-separated
    target_speciality TEXT,           -- Medical specialties, comma-separated
    target_min_app_version TEXT,
    target_max_app_version TEXT,
    target_logged_in_only BOOLEAN NOT NULL DEFAULT FALSE,
    target_anonymous_only BOOLEAN NOT NULL DEFAULT FALSE,
    -- User Insights Targeting (from survey responses)
    target_degree TEXT,               -- Degrees, comma-separated (e.g., 'MD,MBBS,PhD')
    target_subspecialty TEXT,         -- Subspecialties, comma-separated
    target_profession TEXT,           -- Professions, comma-separated (e.g., 'Doctor,Resident,Student')
    target_hospital TEXT,             -- Hospital/workplace name (partial match)
    target_years_experience TEXT,     -- Years of experience range
    -- Device/Platform Targeting
    target_platform TEXT,             -- 'ios', 'android', or NULL for all
    target_is_real_device BOOLEAN,    -- true = real device only, false = emulator only, NULL = all
    target_device_brand TEXT,         -- Device brands, comma-separated (e.g., 'Apple,Samsung')
    target_ip_addresses TEXT,         -- IP addresses for testing, comma-separated
    metadata JSONB DEFAULT '{}'::jsonb,
    questions JSONB DEFAULT '[]'::jsonb,
    responses JSONB DEFAULT '[]'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by TEXT,
    updated_by TEXT,
    version INTEGER NOT NULL DEFAULT 1,
    CONSTRAINT check_targeting_exclusive CHECK (
        NOT (target_logged_in_only = TRUE AND target_anonymous_only = TRUE)
    )
);


-- 12. ADMIN_USERS TABLE (for Admin Dashboard)
CREATE TABLE public.admin_users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id TEXT NOT NULL,
    email TEXT NOT NULL,
    password_hash TEXT,
    display_name TEXT,
    role TEXT NOT NULL DEFAULT 'admin' CHECK (role IN ('admin','superadmin')),
    is_active BOOLEAN NOT NULL DEFAULT true,
    last_login_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by TEXT
);

CREATE UNIQUE INDEX idx_admin_users_email ON public.admin_users(email);

-- 13. TOOL_USAGE_SUMMARY TABLE (Admin Analytics)
CREATE TABLE public.tool_usage_summary (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tool_slug TEXT NOT NULL,
    tool_name TEXT,
    usage_count BIGINT NOT NULL DEFAULT 0,
    total_duration_seconds BIGINT NOT NULL DEFAULT 0,
    days_used INTEGER NOT NULL DEFAULT 0,
    months_used INTEGER NOT NULL DEFAULT 0,
    years_used INTEGER NOT NULL DEFAULT 0,
    last_used_at TIMESTAMPTZ,
    unique_users INTEGER NOT NULL DEFAULT 0,
    session_count INTEGER NOT NULL DEFAULT 0,
    country_count INTEGER NOT NULL DEFAULT 0,
    city_count INTEGER NOT NULL DEFAULT 0,
    avg_usage_per_user NUMERIC NOT NULL DEFAULT 0,
    avg_time_per_user_seconds NUMERIC NOT NULL DEFAULT 0,
    avg_calc_time_ms NUMERIC,
    usage_by_date JSONB DEFAULT '[]'::jsonb,
    duration_by_date JSONB DEFAULT '[]'::jsonb,
    country_breakdown JSONB DEFAULT '[]'::jsonb,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_tool_usage_summary_slug ON public.tool_usage_summary(tool_slug);

-- 14. USER_USAGE_SUMMARY TABLE (Admin Analytics)
CREATE TABLE public.user_usage_summary (
    user_id UUID PRIMARY KEY,
    full_name TEXT,
    email TEXT,
    country TEXT,
    city TEXT,
    total_sessions INTEGER NOT NULL DEFAULT 0,
    most_used_tool TEXT,
    tools JSONB DEFAULT '[]'::jsonb,
    locations JSONB DEFAULT '[]'::jsonb,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 15. ANNOUNCEMENT_RESPONSES TABLE
CREATE TABLE public.announcement_responses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    announcement_id UUID REFERENCES public.announcements(id) ON DELETE CASCADE,
    question_id TEXT NOT NULL,
    user_id UUID,
    user_auth_uid TEXT,  -- For linking responses to users
    option_value TEXT,
    text_value TEXT,
    numeric_value NUMERIC,
    link_to_profile TEXT,  -- User profile field to update (e.g., profession, specialty)
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    -- Unique constraint: one response per user per question per announcement
    CONSTRAINT announcement_responses_unique_user_response UNIQUE (announcement_id, question_id, user_auth_uid)
);

CREATE INDEX idx_announcement_responses_question ON public.announcement_responses(question_id);
CREATE INDEX idx_announcement_responses_announcement ON public.announcement_responses(announcement_id);
CREATE INDEX idx_announcement_responses_user_auth ON public.announcement_responses(user_auth_uid);

-- 16. ANNOUNCEMENT_IMPRESSIONS TABLE
CREATE TABLE public.announcement_impressions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    announcement_id UUID REFERENCES public.announcements(id) ON DELETE CASCADE,
    user_id UUID,
    impressions INTEGER NOT NULL DEFAULT 0,
    last_seen_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT impressions_unique UNIQUE (announcement_id, user_id)
);

CREATE INDEX idx_announcement_impressions_user ON public.announcement_impressions(user_id);

-- =====================================================
-- ROW LEVEL SECURITY (RLS)
-- =====================================================

ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.app_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.app_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.screen_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.section_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.category_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tool_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tool_usage_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.feedbacks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_sync_states ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.announcements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.admin_users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tool_usage_summary ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_usage_summary ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.announcement_responses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.announcement_impressions ENABLE ROW LEVEL SECURITY;

-- App tables policies (user data)
CREATE POLICY "users_access_policy" ON public.users FOR ALL USING (
    (auth_uid IS NOT NULL AND auth_uid = auth.jwt() ->> 'sub') OR
    (auth_uid IS NULL) OR
    (auth.role() = 'service_role') OR
    (auth.jwt() ->> 'sub' IS NOT NULL)
);

CREATE POLICY "app_sessions_access_policy" ON public.app_sessions FOR ALL USING (
    (auth_uid IS NOT NULL AND auth_uid = auth.jwt() ->> 'sub') OR
    (auth_uid IS NULL) OR
    (auth.role() = 'service_role') OR
    (auth.jwt() ->> 'sub' IS NOT NULL)
);

CREATE POLICY "app_settings_access_policy" ON public.app_settings FOR ALL USING (
    (auth_uid IS NOT NULL AND auth_uid = auth.jwt() ->> 'sub') OR
    (auth_uid IS NULL) OR
    (auth.role() = 'service_role') OR
    (auth.jwt() ->> 'sub' IS NOT NULL)
);

CREATE POLICY "screen_settings_access_policy" ON public.screen_settings FOR ALL USING (
    (auth_uid IS NOT NULL AND auth_uid = auth.jwt() ->> 'sub') OR
    (auth_uid IS NULL) OR
    (auth.role() = 'service_role') OR
    (auth.jwt() ->> 'sub' IS NOT NULL)
);

CREATE POLICY "section_settings_access_policy" ON public.section_settings FOR ALL USING (
    (auth_uid IS NOT NULL AND auth_uid = auth.jwt() ->> 'sub') OR
    (auth_uid IS NULL) OR
    (auth.role() = 'service_role') OR
    (auth.jwt() ->> 'sub' IS NOT NULL)
);

CREATE POLICY "category_settings_access_policy" ON public.category_settings FOR ALL USING (
    (auth_uid IS NOT NULL AND auth_uid = auth.jwt() ->> 'sub') OR
    (auth_uid IS NULL) OR
    (auth.role() = 'service_role') OR
    (auth.jwt() ->> 'sub' IS NOT NULL)
);

CREATE POLICY "tool_settings_access_policy" ON public.tool_settings FOR ALL USING (
    (auth_uid IS NOT NULL AND auth_uid = auth.jwt() ->> 'sub') OR
    (auth_uid IS NULL) OR
    (auth.role() = 'service_role') OR
    (auth.jwt() ->> 'sub' IS NOT NULL)
);

CREATE POLICY "tool_usage_events_access_policy" ON public.tool_usage_events FOR ALL USING (
    (auth_uid IS NOT NULL AND auth_uid = auth.jwt() ->> 'sub') OR
    (auth_uid IS NULL) OR
    (auth.role() = 'service_role') OR
    (auth.jwt() ->> 'sub' IS NOT NULL)
);

CREATE POLICY "feedbacks_access_policy" ON public.feedbacks FOR ALL USING (
    (auth_uid IS NOT NULL AND auth_uid = auth.jwt() ->> 'sub') OR
    (auth_uid IS NULL) OR
    (auth.role() = 'service_role') OR
    (auth.jwt() ->> 'sub' IS NOT NULL)
);

CREATE POLICY "user_sync_states_access_policy" ON public.user_sync_states FOR ALL USING (
    (auth.role() = 'service_role') OR
    (auth.jwt() ->> 'sub' IS NOT NULL)
);

-- Announcements policies
CREATE POLICY "announcements_read_active" ON public.announcements FOR SELECT USING (
    is_active = TRUE AND is_deleted = FALSE
    AND start_at <= NOW()
    AND (end_at IS NULL OR end_at > NOW())
);

CREATE POLICY "announcements_service_role_all" ON public.announcements FOR ALL USING (
    auth.role() = 'service_role'
);

-- Admin users policies
CREATE POLICY "admin_users_read_active" ON public.admin_users FOR SELECT USING (is_active = true);

CREATE POLICY "admin_users_service_all" ON public.admin_users FOR ALL 
    USING (auth.role() = 'service_role')
    WITH CHECK (auth.role() = 'service_role');

-- Admin analytics policies
CREATE POLICY "tool_usage_summary_service" ON public.tool_usage_summary FOR ALL USING (auth.role() = 'service_role');
CREATE POLICY "user_usage_summary_service" ON public.user_usage_summary FOR ALL USING (auth.role() = 'service_role');

-- Announcement responses/impressions policies
-- Allow all operations for survey responses (insert, update, select)
CREATE POLICY "announcement_responses_all" ON public.announcement_responses 
FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "announcement_impressions_self" ON public.announcement_impressions FOR ALL 
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);
CREATE POLICY "announcement_impressions_service" ON public.announcement_impressions FOR ALL USING (auth.role() = 'service_role');


-- =====================================================
-- PERFORMANCE INDEXES
-- =====================================================

CREATE INDEX idx_users_auth_uid ON public.users(auth_uid) WHERE auth_uid IS NOT NULL;
CREATE INDEX idx_users_email ON public.users(email) WHERE email IS NOT NULL;
CREATE INDEX idx_users_is_synced ON public.users(is_synced) WHERE is_synced = false;
CREATE INDEX idx_users_insights ON public.users USING gin(insights);

CREATE INDEX idx_app_sessions_user_id ON public.app_sessions(user_id);
CREATE INDEX idx_app_sessions_auth_uid ON public.app_sessions(auth_uid) WHERE auth_uid IS NOT NULL;
CREATE INDEX idx_app_sessions_is_active ON public.app_sessions(is_active) WHERE is_active = true;
CREATE INDEX idx_app_sessions_is_synced ON public.app_sessions(is_synced) WHERE is_synced = false;
CREATE INDEX idx_app_sessions_start_time ON public.app_sessions(start_time);
CREATE INDEX idx_app_sessions_country ON public.app_sessions(country) WHERE country IS NOT NULL;

CREATE INDEX idx_app_settings_user_id ON public.app_settings(user_id);
CREATE INDEX idx_app_settings_is_synced ON public.app_settings(is_synced) WHERE is_synced = false;

CREATE INDEX idx_screen_settings_user_id ON public.screen_settings(user_id);
CREATE INDEX idx_section_settings_user_id ON public.section_settings(user_id);
CREATE INDEX idx_category_settings_user_id ON public.category_settings(user_id);

CREATE INDEX idx_tool_settings_user_id ON public.tool_settings(user_id);
CREATE INDEX idx_tool_settings_is_favourite ON public.tool_settings(is_favourite) WHERE is_favourite = true;

CREATE INDEX idx_tool_usage_events_user_id ON public.tool_usage_events(user_id);
CREATE INDEX idx_tool_usage_events_tool_id ON public.tool_usage_events(tool_id);
CREATE INDEX idx_tool_usage_events_event_timestamp ON public.tool_usage_events(event_timestamp);

CREATE INDEX idx_feedbacks_user_id ON public.feedbacks(user_id);
CREATE INDEX idx_feedbacks_tool_id ON public.feedbacks(tool_id) WHERE tool_id IS NOT NULL;
CREATE INDEX idx_feedbacks_submitted_at ON public.feedbacks(submitted_at);

CREATE INDEX idx_announcements_active_time ON public.announcements(is_active, is_deleted, start_at, end_at);
CREATE INDEX idx_announcements_surface ON public.announcements(surface) WHERE is_deleted = FALSE;

-- Announcement targeting indexes
CREATE INDEX idx_announcements_target_country ON public.announcements(target_country) WHERE target_country IS NOT NULL;
CREATE INDEX idx_announcements_target_platform ON public.announcements(target_platform) WHERE target_platform IS NOT NULL;
CREATE INDEX idx_announcements_target_degree ON public.announcements(target_degree) WHERE target_degree IS NOT NULL;
CREATE INDEX idx_announcements_target_profession ON public.announcements(target_profession) WHERE target_profession IS NOT NULL;

-- User location/insights indexes
CREATE INDEX idx_users_last_country ON public.users(last_country) WHERE last_country IS NOT NULL;
CREATE INDEX idx_users_last_platform ON public.users(last_platform) WHERE last_platform IS NOT NULL;

-- =====================================================
-- AUTOMATIC TIMESTAMP TRIGGERS
-- =====================================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_users_updated_at BEFORE UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER trigger_app_sessions_updated_at BEFORE UPDATE ON public.app_sessions FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER trigger_app_settings_updated_at BEFORE UPDATE ON public.app_settings FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER trigger_screen_settings_updated_at BEFORE UPDATE ON public.screen_settings FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER trigger_section_settings_updated_at BEFORE UPDATE ON public.section_settings FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER trigger_category_settings_updated_at BEFORE UPDATE ON public.category_settings FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER trigger_tool_settings_updated_at BEFORE UPDATE ON public.tool_settings FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER trigger_feedbacks_updated_at BEFORE UPDATE ON public.feedbacks FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER trigger_announcements_updated_at BEFORE UPDATE ON public.announcements FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- AUTO-UPDATE USER LOCATION FROM SESSION
-- =====================================================

-- Function to update user's last known location from app session
CREATE OR REPLACE FUNCTION update_user_location_from_session()
RETURNS TRIGGER AS $$
BEGIN
    -- Only update if we have location data and user exists
    IF NEW.country IS NOT NULL AND NEW.auth_uid IS NOT NULL THEN
        UPDATE public.users
        SET 
            last_country = NEW.country,
            last_city = NEW.city,
            last_platform = NEW.os_platform,
            last_device_brand = NEW.device_brand,
            last_is_real_device = NEW.is_device,
            last_ip = NEW.public_ip,
            last_location_updated_at = NOW(),
            updated_at = NOW()
        WHERE auth_uid = NEW.auth_uid;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to auto-update user location when session is created/updated
CREATE TRIGGER trigger_update_user_location
    AFTER INSERT OR UPDATE ON public.app_sessions
    FOR EACH ROW
    EXECUTE FUNCTION update_user_location_from_session();

-- =====================================================
-- VIEWS
-- =====================================================

CREATE OR REPLACE VIEW public.tool_usage_events_enriched 
WITH (security_invoker = true) AS
SELECT e.*,
       s.public_ip,
       s.country,
       s.region,
       s.city
FROM public.tool_usage_events e
LEFT JOIN public.app_sessions s ON e.app_session_id = s.id;

CREATE OR REPLACE VIEW public.dashboard_announcements
WITH (security_invoker = true) AS
SELECT
    id,
    title,
    COALESCE(body, message) as body,
    COALESCE(kind, 'announcement') as kind,
    COALESCE(priority, importance, 'normal') as priority,
    COALESCE(audience, 'all') as audience,
    start_at,
    end_at,
    COALESCE(show_in_carousel, true) as show_in_carousel,
    COALESCE(show_in_notifications, true) as show_in_notifications,
    max_impressions,
    COALESCE(status, 'live') as status,
    COALESCE(questions, '[]'::jsonb) as questions,
    COALESCE(responses, '[]'::jsonb) as responses
FROM public.announcements
WHERE is_deleted = false;

CREATE OR REPLACE VIEW public.dashboard_feedbacks
WITH (security_invoker = true) AS
SELECT
    id,
    message,
    tool_id as tool_slug,
    type as feedback_type,
    conclusion_data as conclusion,
    submitted_at as created_at
FROM public.feedbacks;

-- =====================================================
-- USER INSIGHTS FUNCTIONS & VIEWS
-- =====================================================

-- Function to update user insights from survey response
CREATE OR REPLACE FUNCTION update_user_insights_from_response()
RETURNS TRIGGER AS $$
DECLARE
    response_value TEXT;
BEGIN
    -- Only process if link_to_profile is set and user_auth_uid is provided
    IF NEW.link_to_profile IS NOT NULL AND NEW.user_auth_uid IS NOT NULL THEN
        -- Get the response value (prefer option_value, then text_value, then numeric_value)
        response_value := COALESCE(NEW.option_value, NEW.text_value, NEW.numeric_value::TEXT);
        
        IF response_value IS NOT NULL THEN
            -- Update the user's insights JSON
            UPDATE public.users
            SET insights = jsonb_set(
                jsonb_set(
                    COALESCE(insights, '{}'::jsonb),
                    ARRAY[NEW.link_to_profile],
                    to_jsonb(response_value)
                ),
                ARRAY[NEW.link_to_profile || '_updated_at'],
                to_jsonb(NOW()::TEXT)
            ),
            updated_at = NOW()
            WHERE auth_uid = NEW.user_auth_uid;
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to auto-update user insights when survey response is inserted
DROP TRIGGER IF EXISTS trigger_update_user_insights ON public.announcement_responses;
CREATE TRIGGER trigger_update_user_insights
    AFTER INSERT OR UPDATE ON public.announcement_responses
    FOR EACH ROW
    EXECUTE FUNCTION update_user_insights_from_response();

-- View for user insights summary (admin dashboard)
CREATE OR REPLACE VIEW public.user_insights_summary
WITH (security_invoker = true) AS
SELECT
    u.auth_uid,
    u.user_id,
    u.email,
    u.name,
    u.insights->>'profession' as profession,
    u.insights->>'specialty' as specialty,
    u.insights->>'subspecialty' as subspecialty,
    u.insights->>'country' as country,
    u.insights->>'city' as city,
    u.insights->>'hospital' as hospital,
    u.insights->>'years_experience' as years_experience,
    u.insights->>'degree' as degree,
    u.insights as all_insights,
    u.created_at,
    u.updated_at
FROM public.users u
WHERE u.insights IS NOT NULL AND u.insights != '{}'::jsonb;

-- =====================================================
-- TARGETED ANNOUNCEMENTS RPC FUNCTION
-- =====================================================

CREATE OR REPLACE FUNCTION get_targeted_announcements(
    p_user_auth_uid TEXT,
    p_surface TEXT DEFAULT NULL,
    p_app_version TEXT DEFAULT NULL,
    p_platform TEXT DEFAULT NULL,
    p_country TEXT DEFAULT NULL,
    p_city TEXT DEFAULT NULL,
    p_is_real_device BOOLEAN DEFAULT NULL,
    p_device_brand TEXT DEFAULT NULL,
    p_ip_address TEXT DEFAULT NULL
)
RETURNS TABLE (
    id UUID,
    title TEXT,
    message TEXT,
    kind TEXT,
    surface TEXT,
    importance TEXT,
    action_type TEXT,
    action_value TEXT,
    dismissible BOOLEAN,
    dismissible_mode TEXT,
    remind_later_count INTEGER,
    remind_later_sessions INTEGER,
    repeat_mode TEXT,
    repeat_interval_hours INTEGER,
    max_times_seen_per_user INTEGER,
    metadata JSONB,
    questions JSONB,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    start_at TIMESTAMPTZ,
    end_at TIMESTAMPTZ,
    version INTEGER
) AS $$
DECLARE
    v_user RECORD;
    v_is_logged_in BOOLEAN;
BEGIN
    -- Get user data including insights and last location
    SELECT 
        u.is_anonymous,
        u.insights,
        COALESCE(p_country, u.last_country) as effective_country,
        COALESCE(p_city, u.last_city) as effective_city,
        COALESCE(p_platform, u.last_platform) as effective_platform,
        COALESCE(p_is_real_device, u.last_is_real_device) as effective_is_real_device,
        COALESCE(p_device_brand, u.last_device_brand) as effective_device_brand,
        COALESCE(p_ip_address, u.last_ip) as effective_ip
    INTO v_user
    FROM public.users u
    WHERE u.auth_uid = p_user_auth_uid;
    
    -- Determine login status
    v_is_logged_in := v_user IS NOT NULL AND NOT COALESCE(v_user.is_anonymous, true);
    
    RETURN QUERY
    SELECT 
        a.id,
        a.title,
        a.message,
        a.kind,
        a.surface,
        a.importance,
        a.action_type,
        a.action_value,
        a.dismissible,
        a.dismissible_mode,
        a.remind_later_count,
        a.remind_later_sessions,
        a.repeat_mode,
        a.repeat_interval_hours,
        a.max_times_seen_per_user,
        a.metadata,
        a.questions,
        a.created_at,
        a.updated_at,
        a.start_at,
        a.end_at,
        a.version
    FROM public.announcements a
    WHERE 
        -- Basic filters
        a.is_active = TRUE
        AND a.is_deleted = FALSE
        AND a.start_at <= NOW()
        AND (a.end_at IS NULL OR a.end_at > NOW())
        
        -- Surface filter (if specified)
        AND (p_surface IS NULL OR a.surface = p_surface)
        
        -- Login status targeting
        AND (
            (a.target_logged_in_only = FALSE AND a.target_anonymous_only = FALSE)
            OR (a.target_logged_in_only = TRUE AND v_is_logged_in = TRUE)
            OR (a.target_anonymous_only = TRUE AND v_is_logged_in = FALSE)
        )
        
        -- App version targeting
        AND (
            a.target_min_app_version IS NULL 
            OR a.target_min_app_version = '' 
            OR p_app_version IS NULL
            OR p_app_version >= a.target_min_app_version
        )
        AND (
            a.target_max_app_version IS NULL 
            OR a.target_max_app_version = '' 
            OR p_app_version IS NULL
            OR p_app_version <= a.target_max_app_version
        )
        
        -- Country targeting (using full country names from IP geolocation)
        AND (
            a.target_country IS NULL 
            OR a.target_country = ''
            OR v_user.effective_country IS NULL
            OR EXISTS (
                SELECT 1 FROM unnest(string_to_array(v_user.effective_country, ',')) AS user_country
                WHERE TRIM(LOWER(user_country)) = ANY(
                    SELECT TRIM(LOWER(c)) FROM unnest(string_to_array(a.target_country, ',')) c
                )
            )
        )
        
        -- City targeting (both target and user can have multiple values)
        AND (
            a.target_city IS NULL 
            OR a.target_city = ''
            OR v_user.effective_city IS NULL
            OR EXISTS (
                SELECT 1 FROM unnest(string_to_array(v_user.effective_city, ',')) AS user_city
                WHERE TRIM(LOWER(user_city)) = ANY(
                    SELECT TRIM(LOWER(c)) FROM unnest(string_to_array(a.target_city, ',')) c
                )
            )
        )
        
        -- Platform targeting
        AND (
            a.target_platform IS NULL 
            OR a.target_platform = '' 
            OR a.target_platform = 'all'
            OR v_user.effective_platform IS NULL
            OR EXISTS (
                SELECT 1 FROM unnest(string_to_array(v_user.effective_platform, ',')) AS user_platform
                WHERE TRIM(LOWER(user_platform)) = ANY(
                    SELECT TRIM(LOWER(p)) FROM unnest(string_to_array(a.target_platform, ',')) p
                )
            )
        )
        
        -- Real device targeting
        AND (
            a.target_is_real_device IS NULL
            OR v_user.effective_is_real_device IS NULL
            OR a.target_is_real_device = v_user.effective_is_real_device
        )
        
        -- Device brand targeting (both target and user can have multiple values)
        AND (
            a.target_device_brand IS NULL 
            OR a.target_device_brand = ''
            OR v_user.effective_device_brand IS NULL
            OR EXISTS (
                SELECT 1 FROM unnest(string_to_array(v_user.effective_device_brand, ',')) AS user_brand
                WHERE TRIM(LOWER(user_brand)) = ANY(
                    SELECT TRIM(LOWER(b)) FROM unnest(string_to_array(a.target_device_brand, ',')) b
                )
            )
        )
        
        -- IP address targeting (for testing)
        AND (
            a.target_ip_addresses IS NULL 
            OR a.target_ip_addresses = ''
            OR v_user.effective_ip IS NULL
            OR EXISTS (
                SELECT 1 FROM unnest(string_to_array(v_user.effective_ip, ',')) AS user_ip
                WHERE TRIM(user_ip) = ANY(
                    SELECT TRIM(ip) FROM unnest(string_to_array(a.target_ip_addresses, ',')) ip
                )
            )
        )
        
        -- Specialty targeting (user can have multiple specialties)
        AND (
            a.target_speciality IS NULL 
            OR a.target_speciality = ''
            OR v_user.insights IS NULL
            OR v_user.insights->>'specialty' IS NULL
            OR EXISTS (
                SELECT 1 FROM unnest(string_to_array(v_user.insights->>'specialty', ',')) AS user_spec
                WHERE TRIM(LOWER(user_spec)) = ANY(
                    SELECT TRIM(LOWER(s)) FROM unnest(string_to_array(a.target_speciality, ',')) s
                )
            )
        )
        
        -- Subspecialty targeting (user can have multiple subspecialties)
        AND (
            a.target_subspecialty IS NULL 
            OR a.target_subspecialty = ''
            OR v_user.insights IS NULL
            OR v_user.insights->>'subspecialty' IS NULL
            OR EXISTS (
                SELECT 1 FROM unnest(string_to_array(v_user.insights->>'subspecialty', ',')) AS user_sub
                WHERE TRIM(LOWER(user_sub)) = ANY(
                    SELECT TRIM(LOWER(s)) FROM unnest(string_to_array(a.target_subspecialty, ',')) s
                )
            )
        )
        
        -- Degree targeting (user can have multiple degrees)
        AND (
            a.target_degree IS NULL 
            OR a.target_degree = ''
            OR v_user.insights IS NULL
            OR v_user.insights->>'degree' IS NULL
            OR EXISTS (
                SELECT 1 FROM unnest(string_to_array(v_user.insights->>'degree', ',')) AS user_deg
                WHERE TRIM(LOWER(user_deg)) = ANY(
                    SELECT TRIM(LOWER(d)) FROM unnest(string_to_array(a.target_degree, ',')) d
                )
            )
        )
        
        -- Profession targeting (user can have multiple professions)
        AND (
            a.target_profession IS NULL 
            OR a.target_profession = ''
            OR v_user.insights IS NULL
            OR v_user.insights->>'profession' IS NULL
            OR EXISTS (
                SELECT 1 FROM unnest(string_to_array(v_user.insights->>'profession', ',')) AS user_prof
                WHERE TRIM(LOWER(user_prof)) = ANY(
                    SELECT TRIM(LOWER(p)) FROM unnest(string_to_array(a.target_profession, ',')) p
                )
            )
        )
        
        -- Years Experience targeting (user can have multiple values)
        AND (
            a.target_years_experience IS NULL 
            OR a.target_years_experience = ''
            OR v_user.insights IS NULL
            OR v_user.insights->>'years_experience' IS NULL
            OR EXISTS (
                SELECT 1 FROM unnest(string_to_array(v_user.insights->>'years_experience', ',')) AS user_exp
                WHERE TRIM(LOWER(user_exp)) = ANY(
                    SELECT TRIM(LOWER(e)) FROM unnest(string_to_array(a.target_years_experience, ',')) e
                )
            )
        )
        
        -- Hospital targeting (partial match)
        AND (
            a.target_hospital IS NULL 
            OR a.target_hospital = ''
            OR v_user.insights IS NULL
            OR v_user.insights->>'hospital' IS NULL
            OR EXISTS (
                SELECT 1 FROM unnest(string_to_array(a.target_hospital, ',')) AS target_hosp
                WHERE LOWER(v_user.insights->>'hospital') LIKE '%' || TRIM(LOWER(target_hosp)) || '%'
            )
        )
        
    ORDER BY 
        CASE a.importance 
            WHEN 'high' THEN 1 
            WHEN 'medium' THEN 2 
            ELSE 3 
        END,
        a.created_at DESC;
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER;

-- Grant execute permission
GRANT EXECUTE ON FUNCTION get_targeted_announcements TO authenticated;
GRANT EXECUTE ON FUNCTION get_targeted_announcements TO anon;

-- =====================================================
-- SCHEMA COMPLETE
-- =====================================================
SELECT 'OcuHub Schema Created Successfully!' as status;
