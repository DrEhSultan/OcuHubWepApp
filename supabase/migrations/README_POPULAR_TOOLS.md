# Popular Tools Feature

## Overview
The Popular Tools feature shows the most commonly used tools across all OcuHub users, providing community-driven insights into which tools are most valuable.

## Backend Implementation

### Database Function
**File:** `001_add_popular_tools_function.sql`

**Function:** `get_popular_tools(limit_count INTEGER)`

This PostgreSQL function:
- Aggregates `usage_count` from the `tool_settings` table across all users
- **Filters to only include real devices** (excludes emulators) by checking `app_sessions.is_device = TRUE`
- Groups by `tool_id` to get total usage per tool
- Counts unique users for each tool
- Returns the top N tools sorted by total usage count
- Excludes archived records

### Why Filter by Real Devices?
- Emulator data can skew statistics with test/development usage
- Real device usage represents actual user behavior
- Ensures Popular tools reflect genuine community preferences

### Deployment
To deploy this migration to Supabase:

```bash
# Navigate to the web app directory
cd OcuHubWepApp

# Apply the migration (if using Supabase CLI)
supabase db push

# Or manually run the SQL in Supabase Dashboard > SQL Editor
```

## Mobile App Integration

### ContentService Method
**File:** `OcuHub/src/database/services/ContentService.ts`

**Method:** `getPopularTools(limit: number)`

This method:
1. Calls the Supabase RPC function `get_popular_tools`
2. Receives aggregated tool IDs sorted by popularity
3. Fetches full tool details from local database
4. Returns tools with user-specific settings (favorites, usage)
5. Gracefully handles API failures by returning empty array

### Home Screen Integration
**File:** `OcuHub/src/screens/HomeScreen/index.tsx`

The Popular tab:
- Shows tools most used across the entire community
- Updates on pull-to-refresh
- Respects the `homeToolsCount` setting (4-12 tools)
- Can be set as default tab in Settings

## Tab Differences

| Tab | Data Source | Description |
|-----|-------------|-------------|
| **Recent** | Local user data | Tools you used recently |
| **Frequent** | Local user data | Your most used tools |
| **Favourites** | Synced user data | Tools you marked as favorites |
| **Popular** | All users (backend) | Most used tools across community |

## Settings
Users can configure:
- Default home tab (including Popular)
- Number of tools to show (4-12)

**Location:** Settings > App Settings > Home Screen Default Tab

## Notes
- Popular tools data requires active internet connection
- Falls back to empty state if backend is unavailable
- Tool usage is automatically synced to Supabase when users are authenticated
- Anonymous users can view popular tools but don't contribute to the statistics
