-- =====================================================
-- SURVEYS & DATA COLLECTION SYSTEM
-- Integrated with Announcements
-- =====================================================

-- 1. SURVEYS TABLE
CREATE TABLE IF NOT EXISTS public.surveys (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Basic Info
    title TEXT NOT NULL,
    description TEXT,
    
    -- Type of survey
    survey_type TEXT NOT NULL CHECK (survey_type IN ('survey', 'quiz', 'data_collection', 'poll')),
    
    -- Linked announcement (surveys appear as announcements)
    announcement_id UUID REFERENCES public.announcements(id) ON DELETE CASCADE,
    
    -- Questions stored as JSONB array
    questions JSONB NOT NULL DEFAULT '[]'::jsonb,
    -- Structure: [{ id, type, text, required, options, validation }]
    
    -- Settings
    allow_multiple_submissions BOOLEAN NOT NULL DEFAULT false,
    show_results_after_submit BOOLEAN NOT NULL DEFAULT false,
    randomize_questions BOOLEAN NOT NULL DEFAULT false,
    randomize_options BOOLEAN NOT NULL DEFAULT false,
    
    -- Quiz specific
    passing_s