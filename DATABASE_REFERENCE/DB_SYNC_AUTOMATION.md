# Tool catalog sync (mobile → Supabase)

Goal: keep `tool_catalog` in Supabase aligned with the mobile app tool definitions, with zero conflicts and minimal manual work.

## Script location
- Mobile repo: `OcuHub/scripts/sync-tool-catalog.mjs`
- Generates: `OcuHub/scripts/generated/tool_catalog_diff.sql`
- Safe to run anytime; if already in sync, the SQL is a no-op comment.

## How it works
1) Mobile migrations are the source of truth for tool IDs/titles/sections.
2) The script parses all migrations, fetches current `tool_catalog` from Supabase (service role), and emits ONLY the rows that need upsert (`INSERT ... ON CONFLICT`).
3) No deletes are generated; historical analytics stay intact.

## Usage (whenever tools change)
```bash
cd OcuHub
export SUPABASE_URL=...
export SUPABASE_SERVICE_ROLE_KEY=...
node scripts/sync-tool-catalog.mjs
cat scripts/generated/tool_catalog_diff.sql
supabase db execute --file scripts/generated/tool_catalog_diff.sql --db-url "$SUPABASE_DB_URL"
```

## CI-friendly
- Trigger the script when `src/database/migrations/**` changes.
- Fail CI if `tool_catalog_diff.sql` was produced but not committed, or have CI apply it directly (service role in secrets, never in repo).

## Why it’s safe
- `ON CONFLICT (tool_id) DO UPDATE` → idempotent.
- Scope limited to changed rows.
- No deletes, so old analytics stay intact.
