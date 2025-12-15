#!/bin/bash
# Script to get current schema from Supabase
# Run this to get the current database schema

echo "Getting current schema from Supabase..."
npx supabase db dump --schema-only > supabase/current_schema.sql

if [ $? -eq 0 ]; then
    echo "✅ Schema exported to supabase/current_schema.sql"
    echo "You can now use this file instead of the old schema.sql"
else
    echo "❌ Failed to export schema. Make sure you're logged in to Supabase CLI:"
    echo "npx supabase login"
fi