-- Migration: Refactor Case Notes Entries
-- Date: 2026-01-05
-- Description: Adds Case Notes tables and updates case_entries to use item_name + item_value structure
--              Adds case_notes_suggestions table for autocomplete
--
-- CHANGES:
-- - Renames 'value' column to 'item_name' (the searchable/suggestable part)
-- - Adds 'item_value' column (optional value, never saved to suggestions)
-- - Renames 'entry_type' to 'subtype' for consistency
-- - Updates section enum to include 'signs' (renamed from 'diagnosis')
-- - Adds case_notes_suggestions table

-- ============================================
-- CREATE CASE NOTES TABLES
-- ============================================

CREATE TABLE IF NOT EXISTS public.case_notes (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL,
    auth_uid TEXT NOT NULL,
    patient_tag TEXT NOT NULL,
    date_of_birth TIMESTAMPTZ,
    gender TEXT,
    description TEXT,
    clinic_place TEXT,
    metadata JSONB,
    status TEXT DEFAULT 'active',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    last_visited_at TIMESTAMPTZ,
    last_edited_at TIMESTAMPTZ,
    schema_version INTEGER DEFAULT 1,
    created_by_device_profile_id UUID,
    updated_by_device_profile_id UUID,
    is_deleted BOOLEAN DEFAULT FALSE,
    is_synced BOOLEAN DEFAULT FALSE,
    last_synced_at TIMESTAMPTZ,
    CONSTRAINT case_notes_user_match CHECK (user_id = auth_uid)
);

CREATE TABLE IF NOT EXISTS public.case_visits (
    id TEXT PRIMARY KEY,
    case_id TEXT NOT NULL REFERENCES public.case_notes(id) ON DELETE CASCADE,
    user_id TEXT NOT NULL,
    auth_uid TEXT NOT NULL,
    visit_date TIMESTAMPTZ NOT NULL,
    title TEXT,
    note TEXT,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    schema_version INTEGER DEFAULT 1,
    created_by_device_profile_id UUID,
    updated_by_device_profile_id UUID,
    is_deleted BOOLEAN DEFAULT FALSE,
    is_synced BOOLEAN DEFAULT FALSE,
    last_synced_at TIMESTAMPTZ,
    CONSTRAINT case_visits_user_match CHECK (user_id = auth_uid)
);

CREATE TABLE IF NOT EXISTS public.case_entries (
    id TEXT PRIMARY KEY,
    case_id TEXT NOT NULL REFERENCES public.case_notes(id) ON DELETE CASCADE,
    visit_id TEXT NOT NULL REFERENCES public.case_visits(id) ON DELETE CASCADE,
    user_id TEXT NOT NULL,
    auth_uid TEXT NOT NULL,
    section TEXT NOT NULL,
    entry_type TEXT,
    laterality TEXT NOT NULL,
    value TEXT NOT NULL,
    metadata JSONB,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    schema_version INTEGER DEFAULT 1,
    created_by_device_profile_id UUID,
    updated_by_device_profile_id UUID,
    is_deleted BOOLEAN DEFAULT FALSE,
    is_synced BOOLEAN DEFAULT FALSE,
    last_synced_at TIMESTAMPTZ,
    CONSTRAINT case_entries_user_match CHECK (user_id = auth_uid)
);

CREATE TABLE IF NOT EXISTS public.case_attachments (
    id TEXT PRIMARY KEY,
    case_id TEXT NOT NULL REFERENCES public.case_notes(id) ON DELETE CASCADE,
    visit_id TEXT REFERENCES public.case_visits(id) ON DELETE SET NULL,
    user_id TEXT NOT NULL,
    auth_uid TEXT NOT NULL,
    type TEXT NOT NULL,
    source TEXT,
    local_uri TEXT,
    thumbnail_uri TEXT,
    file_name TEXT,
    mime_type TEXT,
    size_bytes INTEGER,
    width INTEGER,
    height INTEGER,
    duration_ms INTEGER,
    storage_provider TEXT DEFAULT 'local',
    remote_id TEXT,
    remote_folder_id TEXT,
    remote_meta JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    schema_version INTEGER DEFAULT 1,
    created_by_device_profile_id UUID,
    updated_by_device_profile_id UUID,
    is_deleted BOOLEAN DEFAULT FALSE,
    is_synced BOOLEAN DEFAULT FALSE,
    last_synced_at TIMESTAMPTZ,
    CONSTRAINT case_attachments_user_match CHECK (user_id = auth_uid)
);

CREATE INDEX IF NOT EXISTS idx_case_notes_user_id ON public.case_notes(user_id);
CREATE INDEX IF NOT EXISTS idx_case_notes_updated_at ON public.case_notes(updated_at);
CREATE INDEX IF NOT EXISTS idx_case_visits_case_id ON public.case_visits(case_id);
CREATE INDEX IF NOT EXISTS idx_case_visits_visit_date ON public.case_visits(visit_date);
CREATE INDEX IF NOT EXISTS idx_case_entries_visit_id ON public.case_entries(visit_id);
CREATE INDEX IF NOT EXISTS idx_case_entries_case_id ON public.case_entries(case_id);
CREATE INDEX IF NOT EXISTS idx_case_attachments_case_id ON public.case_attachments(case_id);
CREATE INDEX IF NOT EXISTS idx_case_attachments_visit_id ON public.case_attachments(visit_id);

ALTER TABLE public.case_notes
ADD COLUMN IF NOT EXISTS date_of_birth TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS gender TEXT;

ALTER TABLE public.device_sync_preferences
ADD COLUMN IF NOT EXISTS share_case_notes BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS share_case_note_attachments BOOLEAN DEFAULT FALSE;

ALTER TABLE public.case_notes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.case_visits ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.case_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.case_attachments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own case notes" ON public.case_notes
    FOR SELECT USING (auth_uid = auth.uid()::text OR user_id = auth.uid()::text);
CREATE POLICY "Users can insert own case notes" ON public.case_notes
    FOR INSERT WITH CHECK (auth_uid = auth.uid()::text OR user_id = auth.uid()::text);
CREATE POLICY "Users can update own case notes" ON public.case_notes
    FOR UPDATE USING (auth_uid = auth.uid()::text OR user_id = auth.uid()::text);
CREATE POLICY "Users can delete own case notes" ON public.case_notes
    FOR DELETE USING (auth_uid = auth.uid()::text OR user_id = auth.uid()::text);

CREATE POLICY "Users can view own case visits" ON public.case_visits
    FOR SELECT USING (auth_uid = auth.uid()::text OR user_id = auth.uid()::text);
CREATE POLICY "Users can insert own case visits" ON public.case_visits
    FOR INSERT WITH CHECK (auth_uid = auth.uid()::text OR user_id = auth.uid()::text);
CREATE POLICY "Users can update own case visits" ON public.case_visits
    FOR UPDATE USING (auth_uid = auth.uid()::text OR user_id = auth.uid()::text);
CREATE POLICY "Users can delete own case visits" ON public.case_visits
    FOR DELETE USING (auth_uid = auth.uid()::text OR user_id = auth.uid()::text);

CREATE POLICY "Users can view own case entries" ON public.case_entries
    FOR SELECT USING (auth_uid = auth.uid()::text OR user_id = auth.uid()::text);
CREATE POLICY "Users can insert own case entries" ON public.case_entries
    FOR INSERT WITH CHECK (auth_uid = auth.uid()::text OR user_id = auth.uid()::text);
CREATE POLICY "Users can update own case entries" ON public.case_entries
    FOR UPDATE USING (auth_uid = auth.uid()::text OR user_id = auth.uid()::text);
CREATE POLICY "Users can delete own case entries" ON public.case_entries
    FOR DELETE USING (auth_uid = auth.uid()::text OR user_id = auth.uid()::text);

CREATE POLICY "Users can view own case attachments" ON public.case_attachments
    FOR SELECT USING (auth_uid = auth.uid()::text OR user_id = auth.uid()::text);
CREATE POLICY "Users can insert own case attachments" ON public.case_attachments
    FOR INSERT WITH CHECK (auth_uid = auth.uid()::text OR user_id = auth.uid()::text);
CREATE POLICY "Users can update own case attachments" ON public.case_attachments
    FOR UPDATE USING (auth_uid = auth.uid()::text OR user_id = auth.uid()::text);
CREATE POLICY "Users can delete own case attachments" ON public.case_attachments
    FOR DELETE USING (auth_uid = auth.uid()::text OR user_id = auth.uid()::text);

-- ============================================
-- UPDATE CASE_ENTRIES TABLE
-- ============================================

-- Add new columns
ALTER TABLE public.case_entries ADD COLUMN IF NOT EXISTS item_name TEXT;
ALTER TABLE public.case_entries ADD COLUMN IF NOT EXISTS item_value TEXT;
ALTER TABLE public.case_entries ADD COLUMN IF NOT EXISTS subtype TEXT;
ALTER TABLE public.case_entries ADD COLUMN IF NOT EXISTS ipd NUMERIC(4,1); -- IPD in millimeters (e.g., 62.5)

-- Migrate data from old columns to new
UPDATE public.case_entries 
SET item_name = value,
    subtype = entry_type,
    section = CASE 
      WHEN section = 'diagnosis' THEN 'signs'
      WHEN section = 'decision' THEN 'decisions'
      WHEN section = 'complaints' THEN 'symptoms'
      ELSE section 
    END
WHERE item_name IS NULL;

-- Make item_name NOT NULL after migration
ALTER TABLE public.case_entries ALTER COLUMN item_name SET NOT NULL;

-- Drop old columns (keeping for backward compatibility, can be removed later)
-- ALTER TABLE public.case_entries DROP COLUMN IF EXISTS value;
-- ALTER TABLE public.case_entries DROP COLUMN IF EXISTS entry_type;

-- Add index for item_name lookups
CREATE INDEX IF NOT EXISTS idx_case_entries_item_name ON public.case_entries(user_id, section, item_name);

-- ============================================
-- CREATE SUGGESTIONS TABLE
-- ============================================

CREATE TABLE IF NOT EXISTS public.case_notes_suggestions (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL,
    auth_uid TEXT NOT NULL,
    section TEXT NOT NULL,
    subtype TEXT,
    item_name TEXT NOT NULL,
    use_count INTEGER DEFAULT 1,
    last_used_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    is_deleted BOOLEAN DEFAULT FALSE,
    CONSTRAINT case_notes_suggestions_user_match CHECK (user_id = auth_uid),
    CONSTRAINT case_notes_suggestions_unique UNIQUE (user_id, section, subtype, item_name)
);

-- Normalize section names for existing suggestions
UPDATE public.case_notes_suggestions
SET section = 'symptoms'
WHERE section = 'complaints';

-- Indexes for fast suggestion lookups
CREATE INDEX IF NOT EXISTS idx_suggestions_lookup 
ON public.case_notes_suggestions(user_id, section, subtype, use_count DESC);

CREATE INDEX IF NOT EXISTS idx_suggestions_item 
ON public.case_notes_suggestions(user_id, item_name);

-- ============================================
-- ROW LEVEL SECURITY
-- ============================================

ALTER TABLE public.case_notes_suggestions ENABLE ROW LEVEL SECURITY;

-- Users can only see their own suggestions
CREATE POLICY "Users can view own suggestions"
ON public.case_notes_suggestions FOR SELECT
USING (auth_uid = auth.uid()::text);

-- Users can insert their own suggestions
CREATE POLICY "Users can insert own suggestions"
ON public.case_notes_suggestions FOR INSERT
WITH CHECK (auth_uid = auth.uid()::text);

-- Users can update their own suggestions
CREATE POLICY "Users can update own suggestions"
ON public.case_notes_suggestions FOR UPDATE
USING (auth_uid = auth.uid()::text);

-- Users can delete their own suggestions
CREATE POLICY "Users can delete own suggestions"
ON public.case_notes_suggestions FOR DELETE
USING (auth_uid = auth.uid()::text);

-- ============================================
-- COMMENTS
-- ============================================

COMMENT ON TABLE public.case_notes_suggestions IS 'Stores autocomplete suggestions for case note entries. Only stores item_name, never item_value.';
COMMENT ON COLUMN public.case_notes_suggestions.item_name IS 'The item name to suggest - this is the only value stored for suggestions';
COMMENT ON COLUMN public.case_notes_suggestions.subtype IS 'Optional subtype for history/decisions classification';
COMMENT ON COLUMN public.case_notes_suggestions.use_count IS 'Number of times this suggestion has been used';

COMMENT ON COLUMN public.case_entries.item_name IS 'The name/label of the entry - saved to suggestions';
COMMENT ON COLUMN public.case_entries.item_value IS 'Optional value for the entry - NEVER saved to suggestions';
COMMENT ON COLUMN public.case_entries.subtype IS 'Subtype classification for history/decisions entries';
COMMENT ON COLUMN public.case_entries.ipd IS 'Interpupillary distance in millimeters for refraction entries';
COMMENT ON COLUMN public.case_entries.metadata IS 'JSON metadata for entries. For history entries: {"historyDate": "2020", "historyDateTimestamp": 946684800000}. For surgery decisions: {"scheduledDate": "15 Jan 2026", "scheduledDateTimestamp": 1768521600000}';

-- ============================================
-- HISTORY DATE SUPPORT
-- ============================================

-- Optional: Create an index on metadata->>'historyDate' for better query performance
-- Uncomment if you need to query history entries by date frequently
-- CREATE INDEX IF NOT EXISTS idx_case_entries_history_date 
--   ON public.case_entries ((metadata->>'historyDate')) 
--   WHERE section = 'history' AND metadata IS NOT NULL;

-- Optional: Create an index on metadata->>'historyDateTimestamp' for timestamp-based queries
-- CREATE INDEX IF NOT EXISTS idx_case_entries_history_timestamp 
--   ON public.case_entries (((metadata->>'historyDateTimestamp')::BIGINT)) 
--   WHERE section = 'history' AND metadata IS NOT NULL;

-- ============================================
-- SURGERY SCHEDULED DATE SUPPORT
-- ============================================

-- Optional: Create an index on metadata->>'scheduledDateTimestamp' for surgery scheduling queries
-- Uncomment if you need to query upcoming surgeries frequently
-- CREATE INDEX IF NOT EXISTS idx_case_entries_scheduled_date 
--   ON public.case_entries (((metadata->>'scheduledDateTimestamp')::BIGINT)) 
--   WHERE section = 'decisions' AND subtype = 'surgery' AND metadata IS NOT NULL;
