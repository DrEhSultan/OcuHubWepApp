-- Check if user_announcement_state table exists and has correct structure
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'user_announcement_state'
ORDER BY ordinal_position;

-- Check if the functions exist
SELECT routine_name, routine_type
FROM information_schema.routines
WHERE routine_schema = 'public'
AND routine_name IN (
    'get_eligible_announcements',
    'get_carousel_announcements', 
    'get_inbox_announcements',
    'update_announcement_state',
    'record_announcement_impression'
);

-- Check current state for a specific user (replace with actual user_id)
-- SELECT * FROM user_announcement_state WHERE user_id = 'YOUR_USER_ID';
