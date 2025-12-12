# Announcement Customization Migration

## Date: December 12, 2025

## Overview
This migration adds support for custom accent colors and CTA button icons in announcements.

## Changes
The new fields are stored in the existing `metadata` JSONB column of the `announcements` table:

| Field | Type | Description | Default |
|-------|------|-------------|---------|
| `custom_color` | string | Custom hex color for announcement accent (e.g., '#F59E0B') | null (uses importance-based color) |
| `cta_icon` | string | Custom icon/emoji for CTA button | '→' |

## No Schema Changes Required
Since these fields are stored in the existing `metadata` JSONB column, **no database migration is needed**.

## Example Metadata Structure
```json
{
  "thumbnail": "https://example.com/image.jpg",
  "image_url": "https://example.com/full-image.jpg",
  "cta_label": "Learn More",
  "cta_icon": "🚀",
  "custom_color": "#F59E0B",
  "background_color": "",
  "text_color": "",
  "survey_category": "survey",
  "survey_badge_text": "Survey"
}
```

## Color Presets Available
| Color | Hex | Label |
|-------|-----|-------|
| Orange | #F59E0B | 🟠 Orange |
| Purple | #8B5CF6 | 🟣 Purple |
| Red | #EF4444 | 🔴 Red |
| Blue | #3B82F6 | 🔵 Blue |
| Green | #10B981 | 🟢 Green |
| Pink | #EC4899 | 💗 Pink |
| Indigo | #6366F1 | 💜 Indigo |
| Teal | #14B8A6 | 🩵 Teal |
| Deep Orange | #F97316 | 🧡 Deep Orange |

## CTA Icon Presets Available
| Icon | Label |
|------|-------|
| → | Arrow |
| › | Chevron |
| ▶ | Play |
| ⟶ | Long Arrow |
| 🚀 | Rocket |
| ✨ | Sparkles |
| 💡 | Lightbulb |
| 🎯 | Target |
| 📱 | Phone |
| 🔗 | Link |
| 📋 | Clipboard |
| ⭐ | Star |
| 🎉 | Party |
| 👉 | Point |
| 🔥 | Fire |

## Default Behavior
- If `custom_color` is not set, the color is determined by:
  - Surveys: Purple (#8B5CF6)
  - High importance: Red (#EF4444)
  - Medium importance: Orange (#F59E0B)
  - Low importance: Indigo (#6366F1)
- If `cta_icon` is not set, defaults to '→'

## Supabase Migration (if needed for documentation)
```sql
-- No schema changes needed - using existing metadata JSONB column
-- This comment documents the new metadata fields:
-- metadata.custom_color: Custom hex color for announcement accent
-- metadata.cta_icon: Custom icon/emoji for CTA button

SELECT 'Announcement customization fields added to metadata JSONB' as status;
```

## Files Modified
1. `OcuHubWepApp/components/AnnouncementForm.tsx` - Added color picker and icon selector UI
2. `OcuHubWepApp/pages/admin/index.tsx` - Updated metadata extraction for edit/duplicate
3. `OcuHubWepApp/pages/api/admin/announcements.ts` - Added new fields to metadata handling
4. `OcuHubWepApp/supabase/schema.sql` - Added documentation for metadata fields
