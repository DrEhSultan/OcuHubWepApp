# How to Apply Version Filtering Fix

## The Problem
Version filtering was using string comparison instead of semantic version comparison:
- Current app version: `1.0.1`
- Announcement min version: `1.0.2`
- Announcement max version: `1.0.3`

With string comparison, `"1.0.1" >= "1.0.2"` incorrectly evaluates, causing announcements to show when they shouldn't.

## The Fix
Change from string comparison to semantic version comparison using the existing `compare_semver()` function.

**Only 2 lines need to change in the `get_eligible_announcements` function:**

### Line 1 (around line 941):
```sql
-- BEFORE:
OR p_app_version >= a.target_min_app_version

-- AFTER:
OR compare_semver(p_app_version, a.target_min_app_version) >= 0
```

### Line 2 (around line 947):
```sql
-- BEFORE:
OR p_app_version <= a.target_max_app_version

-- AFTER:
OR compare_semver(p_app_version, a.target_max_app_version) <= 0
```

## How to Apply

### Option 1: Via Supabase Dashboard (Recommended - Safest)
1. Go to your Supabase project dashboard
2. Navigate to SQL Editor
3. Click "New Query"
4. Copy the ENTIRE `get_eligible_announcements` function from `full_backup.sql` (lines 416-700)
5. The function in `full_backup.sql` already has the fix applied (you can see `compare_semver` on lines 941 and 947)
6. Execute the query to replace the function

### Option 2: Via Migration File
1. The fix is already in `OcuHubWepApp/supabase/schema/full_backup.sql`
2. You can re-run the full schema if needed

## Verification
After applying the fix, test with your announcement:
- Min Version: 1.0.2
- Max Version: 1.0.3
- Current App: 1.0.1

The announcement should NOT appear because:
- `compare_semver("1.0.1", "1.0.2")` returns `-1` (1.0.1 is less than 1.0.2)
- `-1 >= 0` is `false`
- Therefore the announcement is filtered out ✓

## What This Fix Does NOT Change
- All other filtering logic (country, profession, device type, etc.) remains exactly the same
- All eligibility logic (repeat mode, dismiss mode, etc.) remains exactly the same
- Only the version comparison method changes from string to semantic

## Safety
This is a surgical fix that only affects version filtering. The `compare_semver` function is already used successfully in other parts of the codebase (see line 164-165 in full_backup.sql for the alerts function).
