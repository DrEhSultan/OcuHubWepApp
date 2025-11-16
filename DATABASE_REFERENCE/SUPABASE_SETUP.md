# Supabase (Web) – Backups & Automation

This folder is the single place for all web/Supabase-related notes, backups, and automation docs.

## What’s here
- `backups/` – JSON backups from Supabase exports (data-only snapshots).
- `db-sync-automation.md` – How to auto-sync tool metadata from the mobile app migrations into Supabase (`tool_catalog`).

## Where the scripts live
The automation script lives in the mobile app repo (OcuHub):
- `OcuHub/scripts/sync-tool-catalog.mjs` (generates Supabase-safe upserts)
- Output: `OcuHub/scripts/generated/tool_catalog_diff.sql`

## Quick flow to sync tools
```bash
cd OcuHub
export SUPABASE_URL=...
export SUPABASE_SERVICE_ROLE_KEY=...
node scripts/sync-tool-catalog.mjs
supabase db execute --file scripts/generated/tool_catalog_diff.sql --db-url "$SUPABASE_DB_URL"
```

If nothing changed, the SQL is a no-op comment. If there are changes, it only includes the rows that need upserting.
