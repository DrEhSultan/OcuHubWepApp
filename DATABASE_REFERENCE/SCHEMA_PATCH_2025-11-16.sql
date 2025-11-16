-- Patch: align production Supabase schema with current admin app expectations
-- Date: 2025-11-16
-- Safe to run multiple times (uses IF NOT EXISTS/default adjustments)
-- Run this in Supabase SQL editor using the service role or migration role.

-- 1) Announcements table: add missing columns used by the admin UI/API
ALTER TABLE public.app_announcements
  ADD COLUMN IF NOT EXISTS content TEXT;

-- Keep previous body_markdown values if present and content is null
UPDATE public.app_announcements
SET content = COALESCE(content, body_markdown)
WHERE content IS NULL;

-- Ensure status default aligns with API usage (published when created)
ALTER TABLE public.app_announcements
  ALTER COLUMN status SET DEFAULT 'published';

-- 2) Feedbacks: define FK to tool_catalog so Supabase can join `tool_catalog!left(...)`
-- If you have orphaned tool_ids, clean them up before validating.
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_constraint
    WHERE conname = 'feedbacks_tool_catalog_fk'
  ) THEN
    ALTER TABLE public.feedbacks
      ADD CONSTRAINT feedbacks_tool_catalog_fk
      FOREIGN KEY (tool_id) REFERENCES public.tool_catalog(tool_id) ON DELETE SET NULL;
  END IF;
END $$;

-- Optional: validate the FK (comment out if you need to fix data first)
ALTER TABLE public.feedbacks VALIDATE CONSTRAINT feedbacks_tool_catalog_fk;

