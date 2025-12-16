# Supabase Schema Backup

This folder contains the complete working schema backup from the OcuHub Supabase database.
**Use this as the starting point for any future migrations.**

## Files

- `COMPLETE_SCHEMA_RESTORE.sql` - **SINGLE FILE** containing everything needed to restore the database

## Generated

December 16, 2025

## Working Functions (Verified)

| Function | Status | Description |
|----------|--------|-------------|
| `get_eligible_announcements` | ✅ Working | Main targeting/filtering |
| `get_carousel_announcements` | ✅ Working | Home carousel |
| `get_inbox_announcements` | ✅ Working | Inbox with pagination |
| `update_announcement_state` | ✅ Working | Update user state |

## How to Use

### To restore complete database:
1. Run `COMPLETE_SCHEMA_RESTORE.sql` in Supabase SQL Editor
2. That's it! Everything is included in one file.

### What's included:
- ✅ All 20+ tables with complete structure, indexes, constraints
- ✅ All 4 working functions with complete code
- ✅ All triggers and RLS policies
- ✅ All permissions and configuration data
- ❌ User data (tables will be empty - data not important yet)

## Tables

| Table | Description |
|-------|-------------|
| users | User profiles and settings |
| announcements | Announcements, surveys, quizzes |
| user_announcement_state | User's state for each announcement |
| announcement_responses | Survey/quiz responses |
| announcement_impressions | View counts |
| announcement_config | System configuration |
| app_sessions | User sessions with location |
| feedbacks | User feedback |
| tool_settings | Per-tool user settings |
| section_settings | Section preferences |
| category_settings | Category preferences |
| screen_settings | Screen preferences |
| app_settings | App-wide settings |
| tool_usage_events | Analytics events |
| user_sync_states | Sync decision history |
| admin_users | Admin dashboard users |
| credit_asset_types | Credit categories |
| credit_sites | Credit sources |
| credit_links | Individual credits |
| tool_usage_summary | Aggregated tool stats |
| user_usage_summary | Aggregated user stats |

## Functions

| Function | Description |
|----------|-------------|
| get_eligible_announcements | Main targeting/filtering function |
| get_carousel_announcements | Home carousel announcements |
| get_inbox_announcements | Inbox with pagination |
| update_announcement_state | Update user state |
| update_updated_at_column | Auto-update timestamps |
