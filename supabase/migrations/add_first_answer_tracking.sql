-- Migration: Add First Answer Tracking
-- Purpose: Track user's first answer separately from current answer for statistics
-- Date: 2025-12-14

-- Add first answer columns to announcement_responses table
-- These columns store the user's initial response and never change after first save

ALTER TABLE public.announcement_responses 
ADD COLUMN IF NOT EXISTS first_option_value TEXT;

ALTER TABLE public.announcement_responses 
ADD COLUMN IF NOT EXISTS first_text_value TEXT;

ALTER TABLE public.announcement_responses 
ADD COLUMN IF NOT EXISTS first_numeric_value NUMERIC;

ALTER TABLE public.announcement_responses 
ADD COLUMN IF NOT EXISTS first_answered_at TIMESTAMPTZ;

-- Add comment explaining the columns
COMMENT ON COLUMN public.announcement_responses.first_option_value IS 'User''s first answer for option-based questions (never changes after initial save)';
COMMENT ON COLUMN public.announcement_responses.first_text_value IS 'User''s first answer for text-based questions (never changes after initial save)';
COMMENT ON COLUMN public.announcement_responses.first_numeric_value IS 'User''s first answer for numeric questions (never changes after initial save)';
COMMENT ON COLUMN public.announcement_responses.first_answered_at IS 'Timestamp when user first answered this question';

-- Backfill existing responses: set first_* values to current values for existing records
-- This ensures existing data has first answer = current answer
UPDATE public.announcement_responses 
SET 
  first_option_value = option_value,
  first_text_value = text_value,
  first_numeric_value = numeric_value,
  first_answered_at = created_at
WHERE first_option_value IS NULL 
  AND first_text_value IS NULL 
  AND first_numeric_value IS NULL;
