-- =====================================================
-- MIGRATION: Add Quiz as Third Announcement Type
-- Date: December 2024
-- Description: Adds 'quiz' as a distinct type from 'survey'
--              Quiz supports correct answers and feedback modals
-- =====================================================

-- 1. Update the kind check constraint to include 'quiz'
ALTER TABLE public.announcements 
DROP CONSTRAINT IF EXISTS announcements_kind_check;

ALTER TABLE public.announcements 
ADD CONSTRAINT announcements_kind_check 
CHECK (kind IN ('announcement', 'survey', 'quiz'));

-- 2. Add comment explaining the difference
COMMENT ON COLUMN public.announcements.kind IS 
'Type of announcement: 
- announcement: Simple notification/message
- survey: Questions without correct answers, collects user feedback
- quiz: Questions WITH correct answers, shows right/wrong feedback';

-- Note: Quiz-specific data is stored in the questions JSONB field
-- Each question can have:
-- - correctAnswer: string (for single_choice, dropdown, yes_no)
-- - correctAnswers: string[] (for multiple_choice)
-- - correctNumber: number (for number type)
-- - correctNumberRange: { min: number, max: number } (for number type with range)
-- - feedbackCorrect: { actionType, actionValue, actionTitle } (modal shown on correct)
-- - feedbackWrong: { actionType, actionValue, actionTitle } (modal shown on wrong)
