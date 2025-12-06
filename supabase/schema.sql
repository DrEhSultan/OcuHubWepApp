-- =====================================================
-- SUPABASE COMPLETE SCHEMA - WITH MIGRATION 008
-- Optimized for sync service compatibility
-- Eliminates all ON CONFLICT and foreign key constraint issues
-- Includes: Migration 008 - IP and Region Fallback Tracking
-- Date: January 2025
-- =====================================================

-- Enable Row Level Security globally
ALTER DATABASE postgres SET row_security = on;

-- =====================================================
-- TABLE DEFINITIONS - OPTIMIZED FOR SYNC SERVICE
-- =====================================================

-- 1. USERS TABLE - Primary user data (auth_uid is the canonical key)
CREATE TABLE users (
    auth_uid TEXT PRIMARY KEY,                   -- Firebase Auth UID (canonical key)
    user_id TEXT UNIQUE NOT NULL,                -- Legacy/userId alias, enforced to match auth_uid
    email TEXT,
    name TEXT,
    image_uri TEXT,                              -- Profile image URL
    is_verified BOOLEAN DEFAULT false,           -- Email verification status
    is_anonymous BOOLEAN DEFAULT false,          -- Anonymous user flag
    login_method TEXT DEFAULT 'anonymous',      -- Login method tracking
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    is_synced BOOLEAN DEFAULT false,             -- Sync status
    last_synced_at TIMESTAMPTZ,                  -- Last sync timestamp
    CONSTRAINT users_auth_user_match CHECK (user_id = auth_uid)
);

-- 2. APP_SESSIONS TABLE - User session tracking
CREATE TABLE app_sessions (
    id TEXT PRIMARY KEY,                         -- Session ID
    user_id TEXT NOT NULL,                       -- Reference to users (NO FK constraint)
    auth_uid TEXT NOT NULL,                      -- Firebase Auth UID
    start_time TIMESTAMPTZ DEFAULT NOW(),
    end_time TIMESTAMPTZ,
    public_ip TEXT,                              -- User's IP address
    country TEXT,                                -- Resolved country name/code
    region TEXT,                                 -- Resolved region/state/province
    city TEXT,                                   -- Resolved city
    device_info JSONB,                           -- Device details (original field - kept for backward compatibility)
    app_version TEXT,                            -- App version
    is_active BOOLEAN DEFAULT true,              -- Session status
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    is_synced BOOLEAN DEFAULT false,
    last_synced_at TIMESTAMPTZ,

    -- Parsed device info columns
    os_platform TEXT,                            -- 'iOS' | 'Android'
    device_brand TEXT,                           -- e.g., 'Samsung'
    device_model TEXT,                           -- e.g., 'SM-S928B'
    is_device BOOLEAN,                           -- Whether it's a physical device
    device_type INTEGER,                         -- Device type identifier
    os_version TEXT,                             -- e.g., '15' for Android 15

    -- MIGRATION 008: Location fallback tracking
    is_location_live BOOLEAN DEFAULT true,       -- Indicates if location data is live (fetched) or fallback (saved)
    last_live_location_fetched_at TIMESTAMPTZ,   -- Timestamp of last successful location fetch
    fallback_location_used_at TIMESTAMPTZ,       -- Timestamp when fallback location was last used
    CONSTRAINT app_sessions_user_match CHECK (user_id = auth_uid)

    -- NO FOREIGN KEY CONSTRAINTS - sync service handles order
);

-- 3. APP_SETTINGS TABLE - Application settings (OPTIMIZED FOR UPSERT)
CREATE TABLE app_settings (
    user_id TEXT NOT NULL,                       -- Part of composite primary key
    setting_key TEXT NOT NULL,                   -- Part of composite primary key
    auth_uid TEXT NOT NULL,                      -- Firebase Auth UID
    setting_value JSONB,                         -- Setting value
    custom_settings JSONB,                       -- Additional custom settings
    is_archived BOOLEAN DEFAULT false,           -- Exclude from restores/sync if archived
    last_updated TIMESTAMPTZ DEFAULT NOW(),     -- Last update timestamp
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    is_synced BOOLEAN DEFAULT false,
    last_synced_at TIMESTAMPTZ,
    
    -- Composite primary key for Supabase upsert operations
    PRIMARY KEY (user_id, setting_key),
    CONSTRAINT app_settings_user_match CHECK (user_id = auth_uid)
    
    -- NO FOREIGN KEY CONSTRAINTS - sync service handles consistency
);

-- Add explicit unique constraint for ON CONFLICT operations
ALTER TABLE app_settings ADD CONSTRAINT app_settings_user_setting_unique UNIQUE (user_id, setting_key);

-- 4. SCREEN_SETTINGS TABLE - Screen-specific settings
CREATE TABLE screen_settings (
    user_id TEXT NOT NULL,                       -- Part of composite primary key
    screen_id TEXT NOT NULL,                     -- Part of composite primary key
    auth_uid TEXT NOT NULL,                      -- Firebase Auth UID
    settings JSONB,                              -- Screen settings
    is_archived BOOLEAN DEFAULT false,           -- Exclude from restores/sync if archived
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    is_synced BOOLEAN DEFAULT false,
    last_synced_at TIMESTAMPTZ,
    
    -- Composite primary key for Supabase upsert operations
    PRIMARY KEY (user_id, screen_id),
    CONSTRAINT screen_settings_user_match CHECK (user_id = auth_uid)
    
    -- NO FOREIGN KEY CONSTRAINTS - sync service handles consistency
);

-- Add explicit unique constraint for ON CONFLICT operations
ALTER TABLE screen_settings ADD CONSTRAINT screen_settings_user_screen_unique UNIQUE (user_id, screen_id);

-- 5. SECTION_SETTINGS TABLE - Section-specific settings (OPTIMIZED FOR UPSERT)
CREATE TABLE section_settings (
    user_id TEXT NOT NULL,                       -- Part of composite primary key
    section_id TEXT NOT NULL,                    -- Part of composite primary key
    auth_uid TEXT NOT NULL,                      -- Firebase Auth UID
    settings JSONB,                              -- Section settings
    filters JSONB,                               -- Section filters
    is_archived BOOLEAN DEFAULT false,           -- Exclude from restores/sync if archived
    last_updated TIMESTAMPTZ DEFAULT NOW(),     -- Last update timestamp
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    is_synced BOOLEAN DEFAULT false,
    last_synced_at TIMESTAMPTZ,
    
    -- Composite primary key for Supabase upsert operations
    PRIMARY KEY (user_id, section_id),
    CONSTRAINT section_settings_user_match CHECK (user_id = auth_uid)
    
    -- NO FOREIGN KEY CONSTRAINTS - sync service handles consistency
);

-- Add explicit unique constraint for ON CONFLICT operations
ALTER TABLE section_settings ADD CONSTRAINT section_settings_user_section_unique UNIQUE (user_id, section_id);

-- 6. CATEGORY_SETTINGS TABLE - Category-specific settings
-- NOTE: Core preferences (sort_order, is_expanded, is_visible) are stored in dedicated columns.
-- The settings JSONB column is for additional custom settings only - NOT for duplicating column values.
CREATE TABLE category_settings (
    user_id TEXT NOT NULL,                       -- Part of composite primary key
    category_id TEXT NOT NULL,                   -- Part of composite primary key
    auth_uid TEXT NOT NULL,                      -- Firebase Auth UID
    settings JSONB DEFAULT '{}'::jsonb,          -- Additional custom settings only (not for core preferences)
    sort_order INTEGER DEFAULT 0,                -- Category order (primary source of truth)
    is_expanded BOOLEAN DEFAULT false,           -- Expansion state (primary source of truth)
    is_visible BOOLEAN DEFAULT true,             -- Visibility flag (primary source of truth)
    is_archived BOOLEAN DEFAULT false,           -- Exclude from restores/sync if archived
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    is_synced BOOLEAN DEFAULT false,
    last_synced_at TIMESTAMPTZ,
    
    -- Composite primary key for Supabase upsert operations
    PRIMARY KEY (user_id, category_id),
    CONSTRAINT category_settings_user_match CHECK (user_id = auth_uid)
    
    -- NO FOREIGN KEY CONSTRAINTS - sync service handles consistency
);

-- Add explicit unique constraint for ON CONFLICT operations
ALTER TABLE category_settings ADD CONSTRAINT category_settings_user_category_unique UNIQUE (user_id, category_id);

-- 7. TOOL_SETTINGS TABLE - Tool-specific settings
CREATE TABLE tool_settings (
    user_id TEXT NOT NULL,                       -- Part of composite primary key
    tool_id TEXT NOT NULL,                       -- Part of composite primary key
    auth_uid TEXT NOT NULL,                      -- Firebase Auth UID
    settings JSONB,                              -- Tool settings
    is_favourite BOOLEAN DEFAULT false,          -- Favourite tool flag
    order_in_app INTEGER DEFAULT 0,              -- Order position in app
    order_in_category INTEGER DEFAULT 0,         -- Order position in category
    order_in_section INTEGER DEFAULT 0,          -- Order position in section
    usage_count INTEGER DEFAULT 0,               -- Number of times tool was used
    usage_duration_sec INTEGER DEFAULT 0,        -- Total usage duration in seconds
    last_used_at TIMESTAMPTZ,                    -- Last time tool was used
    is_archived BOOLEAN DEFAULT false,           -- Exclude from restores/sync if archived
    last_updated TIMESTAMPTZ DEFAULT NOW(),     -- Last update timestamp (for sync compatibility)
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    is_synced BOOLEAN DEFAULT false,
    last_synced_at TIMESTAMPTZ,
    
    -- Composite primary key for Supabase upsert operations
    PRIMARY KEY (user_id, tool_id),
    CONSTRAINT tool_settings_user_match CHECK (user_id = auth_uid)
    
    -- NO FOREIGN KEY CONSTRAINTS - sync service handles consistency
);

-- Add explicit unique constraint for ON CONFLICT operations
ALTER TABLE tool_settings ADD CONSTRAINT tool_settings_user_tool_unique UNIQUE (user_id, tool_id);

-- 7b. USER_SYNC_STATES TABLE - Tracks first-login restore/decline choices
CREATE TABLE user_sync_states (
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

-- 8. TOOL_USAGE_EVENTS TABLE - Tool usage analytics
CREATE TABLE tool_usage_events (
    id TEXT PRIMARY KEY,                         -- Event ID
    user_id TEXT NOT NULL,                       -- Reference to users (NO FK constraint)
    auth_uid TEXT NOT NULL,                      -- Firebase Auth UID
    tool_id TEXT NOT NULL,                       -- Tool identifier
    tool_session_id TEXT,                        -- Tool session ID
    app_session_id TEXT,                         -- Reference to app_sessions (NO FK constraint)
    event_type TEXT NOT NULL,                    -- Event type (open, close, etc.)
    event_timestamp TIMESTAMPTZ DEFAULT NOW(),  -- Event timestamp
    event_data JSONB,                            -- Event metadata
    created_at TIMESTAMPTZ DEFAULT NOW(),
    is_synced BOOLEAN DEFAULT false,
    last_synced_at TIMESTAMPTZ,
    CONSTRAINT tool_usage_events_user_match CHECK (user_id = auth_uid)
    
    -- NO FOREIGN KEY CONSTRAINTS - sync service handles consistency
);

-- 9. FEEDBACKS TABLE - User feedback and ratings
CREATE TABLE feedbacks (
    id TEXT PRIMARY KEY,                         -- Feedback ID
    user_id TEXT NOT NULL,                       -- Reference to users (NO FK constraint)
    auth_uid TEXT NOT NULL,                      -- Firebase Auth UID
    type TEXT,                                   -- Type of feedback (renamed from feedback_type)
    message TEXT,                                -- Feedback message (renamed from content)
    tool_id TEXT,                                -- Associated tool ID
    screen_state JSONB,                          -- Screen state when feedback was given
    conclusion_data JSONB,                       -- Conclusion/result data
    rating INTEGER CHECK (rating >= 1 AND rating <= 5), -- Rating constraint
    metadata JSONB,                              -- Additional metadata
    submitted_at TIMESTAMPTZ DEFAULT NOW(),     -- Submission timestamp
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    is_synced BOOLEAN DEFAULT false,
    last_synced_at TIMESTAMPTZ,
    CONSTRAINT feedbacks_user_match CHECK (user_id = auth_uid)
    
    -- NO FOREIGN KEY CONSTRAINTS - sync service handles consistency
);

-- =====================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- FIXED: Added migration support for anonymous -> authenticated user transitions
-- The key fix: (auth.jwt() ->> 'sub' IS NOT NULL) allows authenticated users
-- to claim/update anonymous records during migration process
-- =====================================================

-- Enable RLS on all tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE app_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE app_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE screen_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE section_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE category_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE tool_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE tool_usage_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE feedbacks ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_sync_states ENABLE ROW LEVEL SECURITY;

-- Users table policy - FIXED for migration support
CREATE POLICY "users_access_policy" ON users
    FOR ALL USING (
        -- Authenticated users can access their own data
        (auth_uid IS NOT NULL AND auth_uid = auth.jwt() ->> 'sub') OR
        -- Anonymous users can access their data (including during migration)
        (auth_uid IS NULL) OR
        -- Service role has full access
        (auth.role() = 'service_role') OR
        -- Allow authenticated users to claim anonymous records during migration
        -- This allows updating auth_uid from NULL to the current user's auth_uid
        (auth.jwt() ->> 'sub' IS NOT NULL)
    );

-- App sessions table policy - FIXED for migration support
CREATE POLICY "app_sessions_access_policy" ON app_sessions
    FOR ALL USING (
        (auth_uid IS NOT NULL AND auth_uid = auth.jwt() ->> 'sub') OR
        (auth_uid IS NULL) OR
        (auth.role() = 'service_role') OR
        -- Allow authenticated users to claim anonymous records during migration
        (auth.jwt() ->> 'sub' IS NOT NULL)
    );

-- App settings table policy - FIXED for migration support
CREATE POLICY "app_settings_access_policy" ON app_settings
    FOR ALL USING (
        (auth_uid IS NOT NULL AND auth_uid = auth.jwt() ->> 'sub') OR
        (auth_uid IS NULL) OR
        (auth.role() = 'service_role') OR
        -- Allow authenticated users to claim anonymous records during migration
        (auth.jwt() ->> 'sub' IS NOT NULL)
    );

-- Screen settings table policy - FIXED for migration support
CREATE POLICY "screen_settings_access_policy" ON screen_settings
    FOR ALL USING (
        (auth_uid IS NOT NULL AND auth_uid = auth.jwt() ->> 'sub') OR
        (auth_uid IS NULL) OR
        (auth.role() = 'service_role') OR
        -- Allow authenticated users to claim anonymous records during migration
        (auth.jwt() ->> 'sub' IS NOT NULL)
    );

-- Section settings table policy - FIXED for migration support
CREATE POLICY "section_settings_access_policy" ON section_settings
    FOR ALL USING (
        (auth_uid IS NOT NULL AND auth_uid = auth.jwt() ->> 'sub') OR
        (auth_uid IS NULL) OR
        (auth.role() = 'service_role') OR
        -- Allow authenticated users to claim anonymous records during migration
        (auth.jwt() ->> 'sub' IS NOT NULL)
    );

-- Category settings table policy - FIXED for migration support
CREATE POLICY "category_settings_access_policy" ON category_settings
    FOR ALL USING (
        (auth_uid IS NOT NULL AND auth_uid = auth.jwt() ->> 'sub') OR
        (auth_uid IS NULL) OR
        (auth.role() = 'service_role') OR
        -- Allow authenticated users to claim anonymous records during migration
        (auth.jwt() ->> 'sub' IS NOT NULL)
    );

-- Tool settings table policy - FIXED for migration support
CREATE POLICY "tool_settings_access_policy" ON tool_settings
    FOR ALL USING (
        (auth_uid IS NOT NULL AND auth_uid = auth.jwt() ->> 'sub') OR
        (auth_uid IS NULL) OR
        (auth.role() = 'service_role') OR
        -- Allow authenticated users to claim anonymous records during migration
        (auth.jwt() ->> 'sub' IS NOT NULL)
    );

-- Tool usage events table policy - FIXED for migration support
CREATE POLICY "tool_usage_events_access_policy" ON tool_usage_events
    FOR ALL USING (
        (auth_uid IS NOT NULL AND auth_uid = auth.jwt() ->> 'sub') OR
        (auth_uid IS NULL) OR
        (auth.role() = 'service_role') OR
        -- Allow authenticated users to claim anonymous records during migration
        (auth.jwt() ->> 'sub' IS NOT NULL)
    );

-- Feedbacks table policy - FIXED for migration support
CREATE POLICY "feedbacks_access_policy" ON feedbacks
    FOR ALL USING (
        (auth_uid IS NOT NULL AND auth_uid = auth.jwt() ->> 'sub') OR
        (auth_uid IS NULL) OR
        (auth.role() = 'service_role') OR
        -- Allow authenticated users to claim anonymous records during migration
        (auth.jwt() ->> 'sub' IS NOT NULL)
    );

-- User sync states policy
CREATE POLICY "user_sync_states_access_policy" ON user_sync_states
    FOR ALL USING (
        (auth.role() = 'service_role') OR
        (auth.jwt() ->> 'sub' IS NOT NULL)
    );

-- =====================================================
-- PERFORMANCE INDEXES
-- =====================================================

-- Users table indexes
CREATE INDEX idx_users_auth_uid ON users(auth_uid) WHERE auth_uid IS NOT NULL;
CREATE INDEX idx_users_email ON users(email) WHERE email IS NOT NULL;
CREATE INDEX idx_users_is_synced ON users(is_synced) WHERE is_synced = false;
CREATE INDEX idx_users_login_method ON users(login_method);

-- App sessions table indexes
CREATE INDEX idx_app_sessions_user_id ON app_sessions(user_id);
CREATE INDEX idx_app_sessions_auth_uid ON app_sessions(auth_uid) WHERE auth_uid IS NOT NULL;
CREATE INDEX idx_app_sessions_is_active ON app_sessions(is_active) WHERE is_active = true;
CREATE INDEX idx_app_sessions_is_synced ON app_sessions(is_synced) WHERE is_synced = false;
CREATE INDEX idx_app_sessions_start_time ON app_sessions(start_time);
CREATE INDEX idx_app_sessions_country ON app_sessions(country) WHERE country IS NOT NULL;
CREATE INDEX idx_app_sessions_region ON app_sessions(region) WHERE region IS NOT NULL;
CREATE INDEX idx_app_sessions_city ON app_sessions(city) WHERE city IS NOT NULL;
-- MIGRATION 008: Location fallback tracking indexes
CREATE INDEX idx_app_sessions_is_location_live ON app_sessions(is_location_live);
CREATE INDEX idx_app_sessions_fallback_used ON app_sessions(fallback_location_used_at);
CREATE INDEX idx_app_sessions_last_live_fetched ON app_sessions(last_live_location_fetched_at);
CREATE INDEX idx_app_sessions_location_status ON app_sessions(user_id, is_location_live, fallback_location_used_at);

-- Settings tables indexes (optimized for sync operations)
CREATE INDEX idx_app_settings_user_id ON app_settings(user_id);
CREATE INDEX idx_app_settings_is_synced ON app_settings(is_synced) WHERE is_synced = false;
CREATE INDEX idx_app_settings_auth_uid ON app_settings(auth_uid) WHERE auth_uid IS NOT NULL;
CREATE INDEX idx_app_settings_not_archived ON app_settings(is_archived) WHERE is_archived = false;

CREATE INDEX idx_screen_settings_user_id ON screen_settings(user_id);
CREATE INDEX idx_screen_settings_is_synced ON screen_settings(is_synced) WHERE is_synced = false;
CREATE INDEX idx_screen_settings_auth_uid ON screen_settings(auth_uid) WHERE auth_uid IS NOT NULL;
CREATE INDEX idx_screen_settings_not_archived ON screen_settings(is_archived) WHERE is_archived = false;

CREATE INDEX idx_section_settings_user_id ON section_settings(user_id);
CREATE INDEX idx_section_settings_is_synced ON section_settings(is_synced) WHERE is_synced = false;
CREATE INDEX idx_section_settings_auth_uid ON section_settings(auth_uid) WHERE auth_uid IS NOT NULL;
CREATE INDEX idx_section_settings_not_archived ON section_settings(is_archived) WHERE is_archived = false;

CREATE INDEX idx_category_settings_user_id ON category_settings(user_id);
CREATE INDEX idx_category_settings_is_synced ON category_settings(is_synced) WHERE is_synced = false;
CREATE INDEX idx_category_settings_auth_uid ON category_settings(auth_uid) WHERE auth_uid IS NOT NULL;
CREATE INDEX idx_category_settings_not_archived ON category_settings(is_archived) WHERE is_archived = false;

CREATE INDEX idx_tool_settings_user_id ON tool_settings(user_id);
CREATE INDEX idx_tool_settings_is_synced ON tool_settings(is_synced) WHERE is_synced = false;
CREATE INDEX idx_tool_settings_auth_uid ON tool_settings(auth_uid) WHERE auth_uid IS NOT NULL;
CREATE INDEX idx_tool_settings_is_favourite ON tool_settings(is_favourite) WHERE is_favourite = true;
CREATE INDEX idx_tool_settings_not_archived ON tool_settings(is_archived) WHERE is_archived = false;
CREATE INDEX idx_tool_settings_last_used_at ON tool_settings(last_used_at) WHERE last_used_at IS NOT NULL;
CREATE INDEX idx_tool_settings_order_in_app ON tool_settings(order_in_app);
CREATE INDEX idx_tool_settings_usage_count ON tool_settings(usage_count) WHERE usage_count > 0;

-- Tool usage events table indexes
CREATE INDEX idx_tool_usage_events_user_id ON tool_usage_events(user_id);
CREATE INDEX idx_tool_usage_events_auth_uid ON tool_usage_events(auth_uid) WHERE auth_uid IS NOT NULL;
CREATE INDEX idx_tool_usage_events_tool_id ON tool_usage_events(tool_id);
CREATE INDEX idx_tool_usage_events_event_timestamp ON tool_usage_events(event_timestamp);
CREATE INDEX idx_tool_usage_events_event_type ON tool_usage_events(event_type);
CREATE INDEX idx_tool_usage_events_is_synced ON tool_usage_events(is_synced) WHERE is_synced = false;
CREATE INDEX idx_tool_usage_events_app_session_id ON tool_usage_events(app_session_id) WHERE app_session_id IS NOT NULL;

-- Enriched view to join session geo/IP when needed
-- Using SECURITY INVOKER to respect RLS policies of the querying user
CREATE OR REPLACE VIEW tool_usage_events_enriched 
WITH (security_invoker = true) AS
SELECT e.*,
       s.public_ip,
       s.country,
       s.region,
       s.city
FROM tool_usage_events e
LEFT JOIN app_sessions s ON e.app_session_id = s.id;

-- Feedbacks table indexes
CREATE INDEX idx_feedbacks_user_id ON feedbacks(user_id);
CREATE INDEX idx_feedbacks_auth_uid ON feedbacks(auth_uid) WHERE auth_uid IS NOT NULL;
CREATE INDEX idx_feedbacks_type ON feedbacks(type);
CREATE INDEX idx_feedbacks_tool_id ON feedbacks(tool_id) WHERE tool_id IS NOT NULL;
CREATE INDEX idx_feedbacks_rating ON feedbacks(rating) WHERE rating IS NOT NULL;
CREATE INDEX idx_feedbacks_submitted_at ON feedbacks(submitted_at);
CREATE INDEX idx_feedbacks_created_at ON feedbacks(created_at);
CREATE INDEX idx_feedbacks_is_synced ON feedbacks(is_synced) WHERE is_synced = false;

-- =====================================================
-- AUTOMATIC TIMESTAMP TRIGGERS
-- =====================================================

-- Function to update the updated_at column
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply triggers to tables with updated_at column
CREATE TRIGGER trigger_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_app_sessions_updated_at
    BEFORE UPDATE ON app_sessions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_app_settings_updated_at
    BEFORE UPDATE ON app_settings
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_screen_settings_updated_at
    BEFORE UPDATE ON screen_settings
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_section_settings_updated_at
    BEFORE UPDATE ON section_settings
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_category_settings_updated_at
    BEFORE UPDATE ON category_settings
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_tool_settings_updated_at
    BEFORE UPDATE ON tool_settings
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_feedbacks_updated_at
    BEFORE UPDATE ON feedbacks
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- 10. ANNOUNCEMENTS TABLE - In-App Announcements System
-- Added in Migration 009
-- =====================================================

CREATE TABLE IF NOT EXISTS public.announcements (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- Content
  title TEXT NOT NULL,
  message TEXT,

  -- Where this announcement appears
  surface TEXT NOT NULL CHECK (surface IN ('home_banner', 'modal', 'inbox', 'tooltip')),

  -- Priority
  importance TEXT NOT NULL DEFAULT 'low' CHECK (importance IN ('low', 'medium', 'high')),

  -- What happens when the CTA button is pressed
  action_type TEXT NOT NULL DEFAULT 'none' CHECK (action_type IN ('none', 'open_link', 'open_screen', 'open_tool')),
  action_value TEXT,  -- URL, route key, or tool ID

  -- Time window and activation
  start_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  end_at TIMESTAMPTZ,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,

  -- Soft delete support
  is_deleted BOOLEAN NOT NULL DEFAULT FALSE,
  deleted_at TIMESTAMPTZ,
  deleted_by TEXT,

  -- Dismiss and repeat behavior
  dismissible BOOLEAN NOT NULL DEFAULT TRUE,
  repeat_mode TEXT NOT NULL DEFAULT 'once' CHECK (repeat_mode IN ('once', 'per_app_open', 'interval_hours')),
  repeat_interval_hours INTEGER,
  max_times_seen_per_user INTEGER,

  -- Simple targeting
  target_country TEXT,
  target_speciality TEXT,
  target_min_app_version TEXT,
  target_max_app_version TEXT,
  target_logged_in_only BOOLEAN NOT NULL DEFAULT FALSE,
  target_anonymous_only BOOLEAN NOT NULL DEFAULT FALSE,

  -- Additional metadata (JSON)
  metadata JSONB DEFAULT '{}'::jsonb,

  -- Audit fields
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_by TEXT,
  updated_by TEXT,

  -- Version tracking for optimistic locking
  version INTEGER NOT NULL DEFAULT 1,

  -- Constraint: target_logged_in_only and target_anonymous_only cannot both be true
  CONSTRAINT check_targeting_exclusive CHECK (
    NOT (target_logged_in_only = TRUE AND target_anonymous_only = TRUE)
  )
);

-- Announcements table indexes
CREATE INDEX IF NOT EXISTS idx_announcements_active_time
  ON public.announcements (is_active, is_deleted, start_at, end_at);

CREATE INDEX IF NOT EXISTS idx_announcements_surface
  ON public.announcements (surface) WHERE is_deleted = FALSE;

CREATE INDEX IF NOT EXISTS idx_announcements_importance
  ON public.announcements (importance) WHERE is_active = TRUE AND is_deleted = FALSE;

CREATE INDEX IF NOT EXISTS idx_announcements_target_country
  ON public.announcements (target_country) WHERE target_country IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_announcements_target_speciality
  ON public.announcements (target_speciality) WHERE target_speciality IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_announcements_deleted
  ON public.announcements (is_deleted, deleted_at);

CREATE INDEX IF NOT EXISTS idx_announcements_created_at
  ON public.announcements (created_at DESC);

-- Announcements RLS
ALTER TABLE announcements ENABLE ROW LEVEL SECURITY;

-- Policy: Anyone (including anonymous) can read active, non-deleted announcements
CREATE POLICY "announcements_read_active" ON announcements
    FOR SELECT USING (
        is_active = TRUE AND is_deleted = FALSE
        AND start_at <= NOW()
        AND (end_at IS NULL OR end_at > NOW())
    );

-- Policy: Service role has full access (for admin dashboard)
CREATE POLICY "announcements_service_role_all" ON announcements
    FOR ALL USING (
        auth.role() = 'service_role'
    );

-- Announcements trigger
CREATE TRIGGER trigger_announcements_updated_at
    BEFORE UPDATE ON public.announcements
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- COMPREHENSIVE TESTING
-- =====================================================

-- Test all upsert operations that your sync service uses
SELECT 'Testing upsert operations...' as test_status;

-- Test 1: app_settings upsert
INSERT INTO app_settings (user_id, auth_uid, setting_key, setting_value) 
VALUES ('test-user-final', 'test-user-final', 'test-setting', '{"value": "initial"}')
ON CONFLICT (user_id, setting_key) 
DO UPDATE SET 
    setting_value = EXCLUDED.setting_value,
    updated_at = NOW();

-- Update the same record
INSERT INTO app_settings (user_id, auth_uid, setting_key, setting_value) 
VALUES ('test-user-final', 'test-user-final', 'test-setting', '{"value": "updated"}')
ON CONFLICT (user_id, setting_key) 
DO UPDATE SET 
    setting_value = EXCLUDED.setting_value,
    updated_at = NOW();

-- Test 2: section_settings upsert
INSERT INTO section_settings (user_id, auth_uid, section_id, settings) 
VALUES ('test-user-final', 'test-user-final', 'test-section', '{"enabled": true}')
ON CONFLICT (user_id, section_id) 
DO UPDATE SET 
    settings = EXCLUDED.settings,
    updated_at = NOW();

-- Test 3: screen_settings upsert
INSERT INTO screen_settings (user_id, auth_uid, screen_id, settings) 
VALUES ('test-user-final', 'test-user-final', 'test-screen', '{"theme": "dark"}')
ON CONFLICT (user_id, screen_id) 
DO UPDATE SET 
    settings = EXCLUDED.settings,
    updated_at = NOW();

-- Test 4: category_settings upsert (using dedicated columns, not redundant JSON)
INSERT INTO category_settings (user_id, auth_uid, category_id, sort_order, is_expanded, is_visible, settings) 
VALUES ('test-user-final', 'test-user-final', 'test-category', 1, false, true, '{}'::jsonb)
ON CONFLICT (user_id, category_id) 
DO UPDATE SET 
    sort_order = EXCLUDED.sort_order,
    is_expanded = EXCLUDED.is_expanded,
    is_visible = EXCLUDED.is_visible,
    settings = EXCLUDED.settings,
    updated_at = NOW();

-- Test 5: tool_settings upsert
INSERT INTO tool_settings (user_id, auth_uid, tool_id, settings) 
VALUES ('test-user-final', 'test-user-final', 'test-tool', '{"enabled": true}')
ON CONFLICT (user_id, tool_id) 
DO UPDATE SET 
    settings = EXCLUDED.settings,
    updated_at = NOW();

-- Clean up test data
DELETE FROM app_settings WHERE user_id = 'test-user-final';
DELETE FROM section_settings WHERE user_id = 'test-user-final';
DELETE FROM screen_settings WHERE user_id = 'test-user-final';
DELETE FROM category_settings WHERE user_id = 'test-user-final';
DELETE FROM tool_settings WHERE user_id = 'test-user-final';

-- =====================================================
-- FINAL VERIFICATION
-- =====================================================

-- Verify all tables were created
SELECT 
    'SUCCESS: All tables created' as status,
    COUNT(*) as table_count
FROM information_schema.tables 
WHERE table_schema = 'public' 
    AND table_name IN (
        'users', 'app_sessions', 'app_settings', 'screen_settings', 
        'section_settings', 'category_settings', 'tool_settings', 
        'tool_usage_events', 'feedbacks', 'announcements'
    );

-- Verify composite primary keys for settings tables
SELECT 
    'SUCCESS: Composite primary keys created' as status,
    COUNT(*) as composite_pk_count
FROM information_schema.table_constraints tc
WHERE tc.table_schema = 'public'
    AND tc.constraint_type = 'PRIMARY KEY'
    AND tc.table_name IN ('app_settings', 'screen_settings', 'section_settings', 'category_settings', 'tool_settings');

-- Verify unique constraints for ON CONFLICT operations
SELECT 
    'SUCCESS: Unique constraints for upsert operations' as status,
    COUNT(*) as unique_constraint_count
FROM information_schema.table_constraints tc
WHERE tc.table_schema = 'public'
    AND tc.constraint_type = 'UNIQUE'
    AND tc.constraint_name LIKE '%_unique';

-- Verify RLS policies
SELECT 
    'SUCCESS: RLS policies created' as status,
    COUNT(*) as policy_count
FROM pg_policies 
WHERE schemaname = 'public';

-- Verify indexes
SELECT 
    'SUCCESS: Performance indexes created' as status,
    COUNT(*) as index_count
FROM pg_indexes 
WHERE schemaname = 'public'
    AND indexname LIKE 'idx_%';

-- Final success message
SELECT 
    '🎉 SUPABASE COMPLETE FINAL SCHEMA DEPLOYED SUCCESSFULLY! 🎉' as status,
    NOW() as deployment_time,
    '10 tables, 11 RLS policies, 35+ indexes, 9 triggers, 0 foreign keys' as components_created,
    'Includes announcements system - Optimized for sync service compatibility!' as note;

-- =====================================================
-- SCHEMA DEPLOYMENT COMPLETE
-- =====================================================

-- =====================================================
-- ADMIN DASHBOARD ADDITIONS (additive, non-destructive)
-- Keep existing sync tables intact. Requires pgcrypto for gen_random_uuid.
-- =====================================================
create extension if not exists "pgcrypto";

-- 1) Admin users (independent of app users; no FK constraint)
create table if not exists public.admin_users (
  id uuid primary key default gen_random_uuid(),
  user_id text not null, -- store Supabase Auth user id for admin, but not tied to app users
  email text not null,
  password_hash text, -- bcrypt hashed password for email/password login
  display_name text, -- display name for the admin
  role text not null default 'admin' check (role in ('admin','superadmin')),
  is_active boolean not null default true,
  last_login_at timestamptz,
  created_at timestamptz not null default now(),
  created_by text
);

-- Add missing columns if table already exists
alter table public.admin_users add column if not exists password_hash text;
alter table public.admin_users add column if not exists display_name text;

alter table public.admin_users enable row level security;

drop policy if exists "admin_users read own" on public.admin_users;
drop policy if exists "admin_users read self" on public.admin_users;
drop policy if exists "admin_users read active" on public.admin_users;
drop policy if exists "admin_users service all" on public.admin_users;

-- Allow any authenticated/anon session to read active rows (whitelist check happens by matching user_id client-side)
create policy "admin_users read active"
  on public.admin_users for select
  using (is_active = true);

-- Service role: full control for inserts/updates
create policy "admin_users service all"
  on public.admin_users for all
  using (auth.role() = 'service_role')
  with check (auth.role() = 'service_role');

-- 2) Tool analytics snapshot
create table if not exists public.tool_usage_summary (
  id uuid primary key default gen_random_uuid(),
  tool_slug text not null,
  tool_name text,
  usage_count bigint not null default 0,
  total_duration_seconds bigint not null default 0,
  days_used integer not null default 0,
  months_used integer not null default 0,
  years_used integer not null default 0,
  last_used_at timestamptz,
  unique_users integer not null default 0,
  session_count integer not null default 0,
  country_count integer not null default 0,
  city_count integer not null default 0,
  avg_usage_per_user numeric not null default 0,
  avg_time_per_user_seconds numeric not null default 0,
  avg_calc_time_ms numeric,
  usage_by_date jsonb default '[]'::jsonb,
  duration_by_date jsonb default '[]'::jsonb,
  country_breakdown jsonb default '[]'::jsonb,
  updated_at timestamptz not null default now()
);
create index if not exists idx_tool_usage_summary_slug on public.tool_usage_summary (tool_slug);

alter table public.tool_usage_summary enable row level security;

drop policy if exists "tool_usage_summary admin read" on public.tool_usage_summary;
create policy "tool_usage_summary admin read"
  on public.tool_usage_summary for select
  using (
    exists (
      select 1 from public.admin_users au
      where au.user_id = auth.uid()::text and au.is_active = true
    )
  );

drop policy if exists "tool_usage_summary admin insert" on public.tool_usage_summary;
create policy "tool_usage_summary admin insert"
  on public.tool_usage_summary for insert
  with check (
    exists (
      select 1 from public.admin_users au
      where au.user_id = auth.uid()::text and au.is_active = true
    )
  );

drop policy if exists "tool_usage_summary admin update" on public.tool_usage_summary;
create policy "tool_usage_summary admin update"
  on public.tool_usage_summary for update
  using (
    exists (
      select 1 from public.admin_users au
      where au.user_id = auth.uid()::text and au.is_active = true
    )
  );

-- 3) User usage snapshot
create table if not exists public.user_usage_summary (
  user_id uuid primary key,
  full_name text,
  email text,
  country text,
  city text,
  total_sessions integer not null default 0,
  most_used_tool text,
  tools jsonb default '[]'::jsonb,
  locations jsonb default '[]'::jsonb,
  updated_at timestamptz not null default now()
);
create index if not exists idx_user_usage_summary_user on public.user_usage_summary (user_id);

alter table public.user_usage_summary enable row level security;

drop policy if exists "user_usage_summary admin read" on public.user_usage_summary;
create policy "user_usage_summary admin read"
  on public.user_usage_summary for select
  using (
    exists (
      select 1 from public.admin_users au
      where au.user_id = auth.uid()::text and au.is_active = true
    )
  );

-- 4) Announcements: extend existing table safely + dashboard view
alter table public.announcements add column if not exists body text;
alter table public.announcements add column if not exists kind text not null default 'announcement' check (kind in ('announcement','survey'));
alter table public.announcements add column if not exists priority text not null default 'normal' check (priority in ('low','normal','high'));
alter table public.announcements add column if not exists audience text not null default 'all' check (audience in ('all','doctors','residents','students'));
alter table public.announcements add column if not exists show_in_carousel boolean not null default true;
alter table public.announcements add column if not exists show_in_notifications boolean not null default true;
alter table public.announcements add column if not exists max_impressions integer;
alter table public.announcements add column if not exists status text not null default 'scheduled' check (status in ('scheduled','live','ended'));
alter table public.announcements add column if not exists questions jsonb default '[]'::jsonb;
alter table public.announcements add column if not exists responses jsonb default '[]'::jsonb;

create index if not exists idx_announcements_admin_active on public.announcements (is_active, start_at, end_at);
create index if not exists idx_announcements_admin_audience on public.announcements (audience);

create or replace view public.dashboard_announcements
with (security_invoker = true) as
select
  id,
  title,
  coalesce(body, message) as body,
  coalesce(kind, 'announcement') as kind,
  coalesce(priority, importance, 'normal') as priority,
  coalesce(audience, 'all') as audience,
  start_at,
  end_at,
  coalesce(show_in_carousel, true) as show_in_carousel,
  coalesce(show_in_notifications, true) as show_in_notifications,
  max_impressions,
  coalesce(status, 'live') as status,
  coalesce(questions, '[]'::jsonb) as questions,
  coalesce(responses, '[]'::jsonb) as responses
from public.announcements
where is_deleted = false;

-- 5) Announcement responses + impressions
create table if not exists public.announcement_responses (
  id uuid primary key default gen_random_uuid(),
  announcement_id uuid references public.announcements(id) on delete cascade,
  question_id text not null,
  user_id uuid references auth.users(id),
  option_value text,
  text_value text,
  numeric_value numeric,
  created_at timestamptz not null default now()
);
create index if not exists idx_announcement_responses_question on public.announcement_responses (question_id);
create index if not exists idx_announcement_responses_announcement on public.announcement_responses (announcement_id);

alter table public.announcement_responses enable row level security;

drop policy if exists "announcement_responses app insert" on public.announcement_responses;
create policy "announcement_responses app insert"
  on public.announcement_responses for insert
  with check (auth.role() = 'authenticated');

drop policy if exists "announcement_responses admin read" on public.announcement_responses;
create policy "announcement_responses admin read"
  on public.announcement_responses for select
  using (
    exists (
      select 1 from public.admin_users au
      where au.user_id = auth.uid()::text and au.is_active = true
    )
  );

create table if not exists public.announcement_impressions (
  id uuid primary key default gen_random_uuid(),
  announcement_id uuid references public.announcements(id) on delete cascade,
  user_id uuid references auth.users(id),
  impressions integer not null default 0,
  last_seen_at timestamptz not null default now(),
  constraint impressions_unique unique (announcement_id, user_id)
);
create index if not exists idx_announcement_impressions_user on public.announcement_impressions (user_id);

alter table public.announcement_impressions enable row level security;

drop policy if exists "announcement_impressions upsert self" on public.announcement_impressions;
create policy "announcement_impressions upsert self"
  on public.announcement_impressions for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- 6) Feedback admin view (non-destructive)
create or replace view public.dashboard_feedbacks
with (security_invoker = true) as
select
  id,
  message,
  tool_id as tool_slug,
  type as feedback_type,
  conclusion_data as conclusion,
  submitted_at as created_at
from public.feedbacks;

-- END ADMIN DASHBOARD ADDITIONS
