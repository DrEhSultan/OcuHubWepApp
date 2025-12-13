-- Migration: Add CTA disappear option and repeat session interval
-- Date: December 2025
-- Description: 
--   1. disappear_after_cta: Controls whether announcement disappears after CTA button click
--   2. repeat_session_interval: Session interval for per_app_open repeat mode

-- Add disappear_after_cta column (default TRUE - disappear after CTA click)
ALTER TABLE public.announcements 
ADD COLUMN IF NOT EXISTS disappear_after_cta BOOLEAN NOT NULL DEFAULT TRUE;

-- Add repeat_session_interval column (default 1 - show every session when per_app_open)
ALTER TABLE public.announcements 
ADD COLUMN IF NOT EXISTS repeat_session_interval INTEGER DEFAULT 1;

-- Add comment for documentation
COMMENT ON COLUMN public.announcements.disappear_after_cta IS 'Whether announcement disappears after user clicks CTA button. Default TRUE.';
COMMENT ON COLUMN public.announcements.repeat_session_interval IS 'Session interval for per_app_open repeat mode. Show announcement every X sessions. Default 1.';
