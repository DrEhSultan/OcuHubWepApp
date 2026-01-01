-- Migration: Add Device Profiles Tables for Multi-Device Support
-- Date: 2026-01-01
-- Description: Adds tables for multi-device settings profiles feature
-- 
-- BACKWARD COMPATIBILITY:
-- - All new tables are additive (no changes to existing tables)
-- - All new columns on existing tables are nullable with no default
-- - Existing app versions continue to work without these tables
-- - Legacy sync payloads without device info are accepted

-- ============================================
-- NEW TABLES
-- ============================================

-- Device profiles table
-- Stores registered devices for each user
CREATE TABLE IF NOT EXISTS public.device_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id TEXT NOT NULL,
    auth_uid TEXT,
    device_id TEXT NOT NULL,
    platform_type TEXT NOT NULL CHECK (platform_type IN ('mobile', 'casted_mobile', 'tablet', 'tv', 'web')),
    device_name TEXT NOT NULL,
    app_version TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    last_active_at TIMESTAMPTZ DEFAULT NOW(),
    is_synced BOOLEAN DEFAULT FALSE,
    last_synced_at TIMESTAMPTZ,
    UNIQUE(user_id, device_id)
);

-- Device-specific settings table
-- Stores calibration, distance, and screen settings per device
-- These settings are NEVER shared between devices
CREATE TABLE IF NOT EXISTS public.device_settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    device_profile_id UUID NOT NULL REFERENCES public.device_profiles(id) ON DELETE CASCADE,
    calibration_data JSONB,
    distance_settings JSONB,
    screen_settings JSONB,
    last_updated TIMESTAMPTZ DEFAULT NOW(),
    is_synced BOOLEAN DEFAULT FALSE,
    last_synced_at TIMESTAMPTZ
);

-- Per-device sync preferences table
-- Controls what data each device shares with other devices
CREATE TABLE IF NOT EXISTS public.device_sync_preferences (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    device_profile_id UUID NOT NULL REFERENCES public.device_profiles(id) ON DELETE CASCADE,
    share_favorites BOOLEAN DEFAULT FALSE,
    share_tool_usage BOOLEAN DEFAULT FALSE,
    share_preferences BOOLEAN DEFAULT FALSE,
    share_section_settings BOOLEAN DEFAULT FALSE,
    last_updated TIMESTAMPTZ DEFAULT NOW(),
    is_synced BOOLEAN DEFAULT FALSE,
    last_synced_at TIMESTAMPTZ,
    UNIQUE(device_profile_id)
);

-- Shared user data pool table
-- Stores data that can be shared across devices
CREATE TABLE IF NOT EXISTS public.shared_user_data (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id TEXT NOT NULL,
    auth_uid TEXT,
    data_type TEXT NOT NULL CHECK (data_type IN ('favorites', 'tool_usage', 'preferences', 'section_settings')),
    data JSONB NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    updated_by_device_id TEXT,
    is_synced BOOLEAN DEFAULT FALSE,
    last_synced_at TIMESTAMPTZ,
    UNIQUE(user_id, data_type)
);

-- ============================================
-- INDEXES FOR NEW TABLES
-- ============================================

CREATE INDEX IF NOT EXISTS idx_device_profiles_user_id ON public.device_profiles(user_id);
CREATE INDEX IF NOT EXISTS idx_device_profiles_auth_uid ON public.device_profiles(auth_uid);
CREATE INDEX IF NOT EXISTS idx_device_profiles_device_id ON public.device_profiles(device_id);
CREATE INDEX IF NOT EXISTS idx_device_settings_profile_id ON public.device_settings(device_profile_id);
CREATE INDEX IF NOT EXISTS idx_device_sync_prefs_profile_id ON public.device_sync_preferences(device_profile_id);
CREATE INDEX IF NOT EXISTS idx_shared_data_user_id ON public.shared_user_data(user_id);
CREATE INDEX IF NOT EXISTS idx_shared_data_auth_uid ON public.shared_user_data(auth_uid);
CREATE INDEX IF NOT EXISTS idx_shared_data_type ON public.shared_user_data(data_type);

-- ============================================
-- ADD NULLABLE COLUMNS TO EXISTING TABLES
-- (All nullable with no default for backward compatibility)
-- ============================================

-- Add device profile columns to app_sessions
ALTER TABLE public.app_sessions 
ADD COLUMN IF NOT EXISTS device_profile_id UUID,
ADD COLUMN IF NOT EXISTS platform_type TEXT;

-- Add device profile columns to tool_usage_events (if exists)
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'tool_usage_events') THEN
        ALTER TABLE public.tool_usage_events 
        ADD COLUMN IF NOT EXISTS device_profile_id UUID,
        ADD COLUMN IF NOT EXISTS platform_type TEXT;
    END IF;
END $$;

-- Add device profile columns to feedbacks
ALTER TABLE public.feedbacks 
ADD COLUMN IF NOT EXISTS device_profile_id UUID,
ADD COLUMN IF NOT EXISTS platform_type TEXT;

-- Add device profile columns to sync_queue (if exists)
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'sync_queue') THEN
        ALTER TABLE public.sync_queue 
        ADD COLUMN IF NOT EXISTS device_profile_id UUID,
        ADD COLUMN IF NOT EXISTS platform_type TEXT;
    END IF;
END $$;

-- ============================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ============================================

-- Enable RLS on new tables
ALTER TABLE public.device_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.device_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.device_sync_preferences ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.shared_user_data ENABLE ROW LEVEL SECURITY;

-- Device profiles: Users can only access their own device profiles
CREATE POLICY "Users can view own device profiles" ON public.device_profiles
    FOR SELECT USING (auth_uid = auth.uid()::text OR user_id = auth.uid()::text);

CREATE POLICY "Users can insert own device profiles" ON public.device_profiles
    FOR INSERT WITH CHECK (auth_uid = auth.uid()::text OR user_id = auth.uid()::text);

CREATE POLICY "Users can update own device profiles" ON public.device_profiles
    FOR UPDATE USING (auth_uid = auth.uid()::text OR user_id = auth.uid()::text);

CREATE POLICY "Users can delete own device profiles" ON public.device_profiles
    FOR DELETE USING (auth_uid = auth.uid()::text OR user_id = auth.uid()::text);

-- Device settings: Users can only access settings for their own device profiles
CREATE POLICY "Users can view own device settings" ON public.device_settings
    FOR SELECT USING (
        device_profile_id IN (
            SELECT id FROM public.device_profiles 
            WHERE auth_uid = auth.uid()::text OR user_id = auth.uid()::text
        )
    );

CREATE POLICY "Users can insert own device settings" ON public.device_settings
    FOR INSERT WITH CHECK (
        device_profile_id IN (
            SELECT id FROM public.device_profiles 
            WHERE auth_uid = auth.uid()::text OR user_id = auth.uid()::text
        )
    );

CREATE POLICY "Users can update own device settings" ON public.device_settings
    FOR UPDATE USING (
        device_profile_id IN (
            SELECT id FROM public.device_profiles 
            WHERE auth_uid = auth.uid()::text OR user_id = auth.uid()::text
        )
    );

CREATE POLICY "Users can delete own device settings" ON public.device_settings
    FOR DELETE USING (
        device_profile_id IN (
            SELECT id FROM public.device_profiles 
            WHERE auth_uid = auth.uid()::text OR user_id = auth.uid()::text
        )
    );

-- Device sync preferences: Users can only access preferences for their own device profiles
CREATE POLICY "Users can view own sync preferences" ON public.device_sync_preferences
    FOR SELECT USING (
        device_profile_id IN (
            SELECT id FROM public.device_profiles 
            WHERE auth_uid = auth.uid()::text OR user_id = auth.uid()::text
        )
    );

CREATE POLICY "Users can insert own sync preferences" ON public.device_sync_preferences
    FOR INSERT WITH CHECK (
        device_profile_id IN (
            SELECT id FROM public.device_profiles 
            WHERE auth_uid = auth.uid()::text OR user_id = auth.uid()::text
        )
    );

CREATE POLICY "Users can update own sync preferences" ON public.device_sync_preferences
    FOR UPDATE USING (
        device_profile_id IN (
            SELECT id FROM public.device_profiles 
            WHERE auth_uid = auth.uid()::text OR user_id = auth.uid()::text
        )
    );

CREATE POLICY "Users can delete own sync preferences" ON public.device_sync_preferences
    FOR DELETE USING (
        device_profile_id IN (
            SELECT id FROM public.device_profiles 
            WHERE auth_uid = auth.uid()::text OR user_id = auth.uid()::text
        )
    );

-- Shared user data: Users can only access their own shared data
CREATE POLICY "Users can view own shared data" ON public.shared_user_data
    FOR SELECT USING (auth_uid = auth.uid()::text OR user_id = auth.uid()::text);

CREATE POLICY "Users can insert own shared data" ON public.shared_user_data
    FOR INSERT WITH CHECK (auth_uid = auth.uid()::text OR user_id = auth.uid()::text);

CREATE POLICY "Users can update own shared data" ON public.shared_user_data
    FOR UPDATE USING (auth_uid = auth.uid()::text OR user_id = auth.uid()::text);

CREATE POLICY "Users can delete own shared data" ON public.shared_user_data
    FOR DELETE USING (auth_uid = auth.uid()::text OR user_id = auth.uid()::text);

-- ============================================
-- SERVICE ROLE POLICIES (for backend operations)
-- ============================================

-- Allow service role full access to all new tables
CREATE POLICY "Service role has full access to device_profiles" ON public.device_profiles
    FOR ALL USING (auth.role() = 'service_role');

CREATE POLICY "Service role has full access to device_settings" ON public.device_settings
    FOR ALL USING (auth.role() = 'service_role');

CREATE POLICY "Service role has full access to device_sync_preferences" ON public.device_sync_preferences
    FOR ALL USING (auth.role() = 'service_role');

CREATE POLICY "Service role has full access to shared_user_data" ON public.shared_user_data
    FOR ALL USING (auth.role() = 'service_role');

-- ============================================
-- COMMENTS
-- ============================================

COMMENT ON TABLE public.device_profiles IS 'Stores registered devices for each user in the multi-device settings system';
COMMENT ON TABLE public.device_settings IS 'Device-specific settings (calibration, distance, screen) that are never shared';
COMMENT ON TABLE public.device_sync_preferences IS 'Per-device toggles controlling what data is shared with other devices';
COMMENT ON TABLE public.shared_user_data IS 'Shared data pool for cross-device synchronization';

COMMENT ON COLUMN public.device_profiles.platform_type IS 'Device platform: mobile, casted_mobile, tablet, tv, web';
COMMENT ON COLUMN public.device_sync_preferences.share_favorites IS 'When true, favorites are shared with other devices';
COMMENT ON COLUMN public.device_sync_preferences.share_tool_usage IS 'When true, tool usage stats are shared with other devices';
COMMENT ON COLUMN public.device_sync_preferences.share_preferences IS 'When true, app preferences are shared with other devices';
COMMENT ON COLUMN public.device_sync_preferences.share_section_settings IS 'When true, section settings are shared with other devices';
