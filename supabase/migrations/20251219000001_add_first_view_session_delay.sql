-- Migration: Add first_view_session_delay column to announcements table
-- This column controls how many app sessions must pass before an announcement
-- can be shown for the first time to a user.
-- Default 0 = show immediately on first session
-- Value 2 = show first time after 2 app sessions

-- Add the column
ALTER TABLE public.announcements 
ADD COLUMN IF NOT EXISTS first_view_session_delay integer DEFAULT 0;

-- Add comment explaining the column
COMMENT ON COLUMN public.announcements.first_view_session_delay IS 
'Number of app sessions to wait before showing announcement for the first time. 
Default 0 = show immediately on first session. 
Value 2 = show first time after user has opened app 2 times.
This only affects the FIRST view - subsequent views follow repeat_mode and repeat_session_interval settings.';
