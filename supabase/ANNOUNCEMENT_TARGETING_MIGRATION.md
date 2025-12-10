# Announcement Targeting Migration Guide

## Overview

This migration adds comprehensive targeting capabilities to announcements, allowing you to filter announcements based on:

1. **Location**: Country (ISO codes), City
2. **User Insights**: Profession, Specialty, Subspecialty, Degree, Hospital
3. **Device/Platform**: iOS/Android, Real device vs Emulator, Device brand
4. **Testing**: IP address targeting for testing new features

## Migration Steps

### 1. Run the Supabase Migration

Execute the SQL migration in your Supabase SQL Editor:

```bash
# File: OcuHubWepApp/supabase/migrations/add_announcement_targeting.sql
```

This migration:
- Adds new targeting columns to `announcements` table
- Adds location tracking columns to `users` table
- Creates a trigger to auto-update user location from app sessions
- Creates indexes for efficient targeting queries
- Creates the `get_targeted_announcements` RPC function

### 2. Update the Schema (Already Done)

The `schema.sql` file has been updated with:
- New targeting columns in `announcements` table
- Location tracking columns in `users` table
- Auto-update trigger for user location
- New indexes for targeting queries

### 3. Mobile App Changes

The mobile app has been updated with:
- New `UserContext` interface with all targeting fields
- Updated `matchesTargeting` function with comma-separated value support
- New `getLastSessionData` method to get device/location info
- SQLite migration (017) to add new columns locally

## New Targeting Fields

### Announcements Table

| Field | Type | Description |
|-------|------|-------------|
| `target_country` | TEXT | ISO country codes, comma-separated (e.g., 'US,SA,EG') |
| `target_city` | TEXT | City names, comma-separated |
| `target_speciality` | TEXT | Medical specialties, comma-separated |
| `target_degree` | TEXT | Degrees, comma-separated (e.g., 'MD,MBBS,PhD') |
| `target_subspecialty` | TEXT | Subspecialties, comma-separated |
| `target_profession` | TEXT | Professions, comma-separated |
| `target_hospital` | TEXT | Hospital name (partial match) |
| `target_platform` | TEXT | 'ios', 'android', or NULL for all |
| `target_is_real_device` | BOOLEAN | true = real device only, false = emulator only |
| `target_device_brand` | TEXT | Device brands, comma-separated |
| `target_ip_addresses` | TEXT | IP addresses for testing, comma-separated |

### Users Table (Auto-Updated)

| Field | Type | Description |
|-------|------|-------------|
| `last_country` | TEXT | ISO country code from most recent session |
| `last_city` | TEXT | City from most recent session |
| `last_platform` | TEXT | 'ios' or 'android' |
| `last_device_brand` | TEXT | Device brand |
| `last_is_real_device` | BOOLEAN | Whether on real device |
| `last_ip` | TEXT | Last known IP address |
| `last_location_updated_at` | TIMESTAMPTZ | When location was last updated |

## How Targeting Works

### Comma-Separated Values

All targeting fields support comma-separated values for multi-targeting:

```
target_country: "US, SA, EG"  // Shows to users in US, Saudi Arabia, or Egypt
target_degree: "MD, MBBS"     // Shows to users with MD or MBBS degree
```

### Matching Logic

- **Empty field** = No targeting (shows to all)
- **Has value but user doesn't** = No match (doesn't show)
- **Has value and user matches** = Match (shows)

### Priority

Announcements are filtered in this order:
1. Basic filters (active, not deleted, within date range)
2. Login status (logged in only / anonymous only)
3. App version (min/max)
4. Location (country, city)
5. Platform (iOS/Android)
6. Device type (real/emulator)
7. User insights (profession, specialty, degree, etc.)
8. IP address (for testing)

## Admin Dashboard Usage

The AnnouncementForm now includes three targeting sections:

1. **Location & User Type**: Country, City, User type, Platform
2. **User Insights**: Profession, Specialty, Subspecialty, Degree
3. **Device & Version**: App version, Device type, Device brand, Test IPs

### Testing New Announcements

Use the "Test IPs" field to target specific IP addresses during testing:

```
target_ip_addresses: "192.168.1.100, 10.0.0.50"
```

This allows you to test announcements on specific devices before rolling out to all users.

## Performance Considerations

- User location is cached in the `users` table and auto-updated from sessions
- Indexes are created on all targeting columns
- Filtering happens at the database level for efficiency
- The mobile app caches announcements locally for offline access

## Rollback

To rollback this migration:

1. The SQLite migration (017) cannot be easily rolled back, but unused columns don't affect functionality
2. For Supabase, you can drop the new columns manually if needed

## Files Changed

### Web Dashboard
- `OcuHubWepApp/components/AnnouncementForm.tsx` - Updated form with new targeting fields
- `OcuHubWepApp/pages/api/admin/announcements.ts` - Updated API to handle new fields
- `OcuHubWepApp/supabase/schema.sql` - Updated schema with new columns

### Mobile App
- `OcuHub/src/services/AnnouncementService.ts` - Updated targeting logic
- `OcuHub/src/hooks/useAnnouncements.ts` - Updated user context building
- `OcuHub/src/database/migrations/017_add_announcement_targeting.ts` - New migration
- `OcuHub/src/database/migrations/index.ts` - Added new migration

### Supabase
- `OcuHubWepApp/supabase/migrations/add_announcement_targeting.sql` - Migration file
