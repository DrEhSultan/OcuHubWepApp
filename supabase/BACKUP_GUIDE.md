# Supabase Backup Guide

## Quick Backup Command

Run this command from the project root to create a full backup:

```bash
PGPASSWORD='YOUR_DB_PASSWORD' pg_dump -h aws-0-eu-central-1.pooler.supabase.com -p 5432 -U postgres.gkbhxyjfnbhkiarsutby -d postgres --no-owner --no-acl -F p > "OcuHubWepApp/supabase/schema/full_backup_$(date +%Y-%m-%d).sql"
```

## Connection Details

- Host: `aws-0-eu-central-1.pooler.supabase.com`
- Port: `5432`
- User: `postgres.gkbhxyjfnbhkiarsutby`
- Database: `postgres`
- Password: Ask project owner (DB password from Supabase dashboard)

## What Gets Backed Up

- All tables (schema + data)
- All functions
- All triggers
- All indexes
- All RLS policies
- All schemas (auth, public, storage, etc.)

## Backup Location

Backups are stored in: `OcuHubWepApp/supabase/schema/`

## Naming Convention

Use date format: `full_backup_YYYY-MM-DD.sql`

## Restore Command (if needed)

```bash
PGPASSWORD='YOUR_DB_PASSWORD' psql -h aws-0-eu-central-1.pooler.supabase.com -p 5432 -U postgres.gkbhxyjfnbhkiarsutby -d postgres < "OcuHubWepApp/supabase/schema/full_backup_YYYY-MM-DD.sql"
```

## Notes

- Free tier Supabase doesn't have automatic backups, so run this manually before major changes
- The `--no-owner --no-acl` flags ensure the backup can be restored without permission issues
- Backup includes all row data via COPY statements
