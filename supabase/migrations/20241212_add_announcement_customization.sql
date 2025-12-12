-- Migration: Add custom_color and cta_icon to announcements
-- Date: December 12, 2025
-- Description: Adds support for custom accent colors and CTA button icons in announcements
-- These fields are stored in the metadata JSONB column, no schema changes needed

-- Note: The custom_color and cta_icon fields are stored in the existing metadata JSONB column
-- No database schema changes are required for this feature
-- The fields are:
--   metadata.custom_color: Custom hex color for announcement accent (e.g., '#F59E0B')
--   metadata.cta_icon: Custom icon/emoji for CTA button (e.g., '→', '🚀', '✨')

-- This migration is a no-op since we're using the existing metadata JSONB column
-- It's included for documentation purposes

-- Example of how the metadata looks with new fields:
-- {
--   "thumbnail": "https://example.com/image.jpg",
--   "cta_label": "Learn More",
--   "cta_icon": "🚀",
--   "custom_color": "#F59E0B",
--   "background_color": "",
--   "text_color": ""
-- }

SELECT 'Migration 20241212_add_announcement_customization applied - no schema changes needed (using metadata JSONB)' as status;
