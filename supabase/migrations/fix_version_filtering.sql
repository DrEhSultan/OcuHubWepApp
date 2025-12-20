-- Fix version filtering in get_eligible_announcements function
-- This migration ONLY changes the app version comparison from string comparison to semantic version comparison
-- All other logic remains exactly the same

-- The issue: String comparison "1.0.1" >= "1.0.2" doesn't work correctly for semantic versions
-- The fix: Use compare_semver() function which properly compares semantic versions

-- Before:
-- OR p_app_version >= a.target_min_app_version
-- OR p_app_version <= a.target_max_app_version

-- After:
-- OR compare_semver(p_app_version, a.target_min_app_version) >= 0
-- OR compare_semver(p_app_version, a.target_max_app_version) <= 0

-- This is a surgical fix that only modifies 2 lines in the WHERE clause of get_eligible_announcements
-- The compare_semver function already exists and is used correctly in other functions

-- To apply this fix, you need to recreate the entire function with this one change.
-- Since the function is very long, the safest approach is to:
-- 1. Export the current function definition
-- 2. Replace the two version comparison lines
-- 3. Execute the modified function

-- You can apply this manually in Supabase SQL Editor by:
-- 1. Finding the get_eligible_announcements function
-- 2. Replacing these two lines in the WHERE clause:
--    FROM: OR p_app_version >= a.target_min_app_version
--    TO:   OR compare_semver(p_app_version, a.target_min_app_version) >= 0
--
--    FROM: OR p_app_version <= a.target_max_app_version  
--    TO:   OR compare_semver(p_app_version, a.target_max_app_version) <= 0

-- The change has already been applied to OcuHubWepApp/supabase/schema/full_backup.sql
-- To apply to your live database, run the updated full_backup.sql or manually edit the function in Supabase dashboard