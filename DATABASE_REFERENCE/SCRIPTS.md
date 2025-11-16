# Database Scripts Reference

Documentation for all database backup, restore, and utility scripts.

## Available Scripts

1. [backup-database.ts](#backup-databasets) - Backup all tables
2. [restore-database.ts](#restore-databasets) - Restore from backup
3. [Coming Soon](#coming-soon) - Planned scripts

---

## backup-database.ts

**Location:** `OcuHubWepApp/scripts/backup-database.ts`

**Purpose:** Export all database tables to JSON files with timestamps

### Usage

```bash
cd OcuHubWepApp
npx ts-node scripts/backup-database.ts
```

### What It Does

1. **Connects to Supabase**
   - Uses SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY from .env
   - Creates authenticated client

2. **Exports Each Table**
   - Queries all data from each table
   - Converts to JSON format
   - Saves to individual files

3. **Creates Backup Folder**
   - Generates timestamp: `backup-YYYY-MM-DDTHH-MM-SS-XXXZ`
   - Creates folder in `backups/` directory
   - Saves all table exports

4. **Generates Metadata**
   - Counts rows per table
   - Records backup timestamp
   - Saves to `backup-metadata.json`

### Output

```
📦 Starting backup to: /path/to/backups/backup-2025-11-16T09-16-48-506Z

⏳ Backing up table: app_sessions
✅ app_sessions: 385 rows backed up
⏳ Backing up table: app_settings
✅ app_settings: 33 rows backed up
...
⏳ Backing up table: tool_usage_events
✅ tool_usage_events: 1000 rows backed up
⏳ Backing up table: users
✅ users: 33 rows backed up

✨ Backup complete! Saved to: /path/to/backups/backup-2025-11-16T09-16-48-506Z
📋 Total tables backed up: 10
📊 Total rows backed up: 1676
```

### Tables Backed Up

| # | Table | Typical Rows | Size |
|---|-------|--------------|------|
| 1 | app_sessions | 385 | 304 KB |
| 2 | app_settings | 33 | 140 KB |
| 3 | category_settings | 0 | - |
| 4 | feedbacks | 1 | 2 KB |
| 5 | screen_settings | 0 | - |
| 6 | section_settings | 40 | 21 KB |
| 7 | tool_settings | 165 | 102 KB |
| 8 | tool_usage_events | 1000+ | 715 KB |
| 9 | user_sync_states | 19 | 8.2 KB |
| 10 | users | 33 | 14 KB |

### Output Files

```
backups/backup-2025-11-16T09-16-48-506Z/
├── app_sessions.json               # Session data
├── app_settings.json               # App configuration
├── category_settings.json          # Empty/small
├── feedbacks.json                  # User feedback
├── screen_settings.json            # Empty/small
├── section_settings.json           # Section data
├── tool_settings.json              # Tool preferences
├── tool_usage_events.json          # Analytics (largest)
├── user_sync_states.json           # Sync decisions
├── users.json                      # User profiles
└── backup-metadata.json            # Backup manifest
```

### Metadata Format

`backup-metadata.json`:
```json
{
  "timestamp": "2025-11-16T09:16:48.506Z",
  "tables": {
    "app_sessions": {
      "rowCount": 385,
      "filePath": "app_sessions.json",
      "success": true
    },
    "app_settings": {
      "rowCount": 33,
      "filePath": "app_settings.json",
      "success": true
    }
    // ... more tables
  }
}
```

### Error Handling

**Missing Environment Variable:**
```
❌ Backup failed: Missing required environment variable: SUPABASE_URL
```
Solution: Add to `.env` file

**Connection Error:**
```
❌ Error backing up app_sessions: ...
```
Solution: Check SUPABASE_SERVICE_ROLE_KEY is valid

### Performance

- **Time:** 5-30 seconds (depends on data size)
- **Typical Size:** 2-3 MB total
- **Network:** Requires internet connection
- **CPU:** Minimal usage

### Code Overview

```typescript
require('dotenv').config();
const { createClient } = require('@supabase/supabase-js');
const fs = require('fs');
const path = require('path');

// 1. Read environment
const url = process.env.SUPABASE_URL;
const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

// 2. Create client
const supabase = createClient(url, serviceRoleKey);

// 3. For each table
const { data, error } = await supabase
  .from(table)
  .select('*', { count: 'exact' });

// 4. Save to JSON
fs.writeFileSync(filePath, JSON.stringify(data, null, 2));

// 5. Record metadata
metadata.tables[table] = {
  rowCount: data?.length || 0,
  filePath: `${table}.json`,
  success: true
};
```

---

## restore-database.ts

**Location:** `OcuHubWepApp/scripts/restore-database.ts`

**Purpose:** Restore database from a backup folder with safety checks

### Usage

**Step 1: Preview (Safe)**
```bash
npx ts-node scripts/restore-database.ts ./backups/backup-2025-11-16T09-16-48-506Z
```

**Step 2: Execute**
```bash
npx ts-node scripts/restore-database.ts ./backups/backup-2025-11-16T09-16-48-506Z --confirm
```

### What It Does

1. **Validates Backup**
   - Checks folder exists
   - Reads metadata file
   - Verifies backup integrity

2. **Shows Warning**
   - Displays backup timestamp
   - Warns about data overwrite
   - Requires `--confirm` flag

3. **Clears Existing Data**
   - Deletes all records from each table
   - Preserves table structure
   - Creates clean slate

4. **Restores Data**
   - Reads JSON files
   - Inserts in batches of 100
   - Tracks progress per table

5. **Confirms Completion**
   - Shows row counts restored
   - Displays success message

### Output

**Preview Mode:**
```
🔄 Starting restore from backup created: 2025-11-16T09:16:48.506Z
⚠️  WARNING: This will OVERWRITE existing data!

To proceed with restore, run:
npx ts-node scripts/restore-database.ts "./backups/backup-2025-11-16T09-16-48-506Z" --confirm
```

**Execute Mode:**
```
⏳ Restoring table: app_sessions (385 rows)
✅ app_sessions: Restored 385 rows
⏳ Restoring table: app_settings (33 rows)
✅ app_settings: Restored 33 rows
⏳ Restoring table: tool_usage_events (1000 rows)
✅ tool_usage_events: Restored 1000 rows
...
✨ Restore complete!
```

### Safety Features

1. **Two-Step Process**
   - Preview first (no changes)
   - Confirm to execute
   - Prevents accidental restore

2. **Metadata Validation**
   - Reads backup-metadata.json
   - Verifies backup structure
   - Checks file integrity

3. **Batch Processing**
   - Restores in 100-row batches
   - Prevents database timeouts
   - Tracks batch failures

4. **Error Reporting**
   - Shows which tables failed
   - Reports row counts
   - Maintains partial success

### Batch Processing

Tables are restored in batches:
```typescript
const batchSize = 100;
for (let i = 0; i < data.length; i += batchSize) {
  const batch = data.slice(i, i + batchSize);
  const { error } = await supabase
    .from(table)
    .insert(batch);
}
```

### Error Handling

**Invalid Backup Path:**
```
❌ Backup directory not found: ./backups/invalid-path
```
Solution: Check backup folder name and path

**Restore Without Confirmation:**
```
⚠️  WARNING: This will OVERWRITE existing data!
To proceed with restore, run:
npx ts-node scripts/restore-database.ts "./backups/..." --confirm
```
Solution: Add `--confirm` flag

**Database Connection Error:**
```
❌ Error restoring app_settings: ...
```
Solution: Check Supabase credentials and network

### Recovery

If restore fails midway:

1. **Don't panic** - Database may be partially restored
2. **Check status** - Review which tables succeeded
3. **Manual cleanup** - Delete corrupted data if needed
4. **Retry restore** - Run restore again with `--confirm`

### Code Overview

```typescript
// 1. Validate backup
if (!fs.existsSync(metadataPath)) {
  throw new Error('Backup metadata not found');
}

// 2. Read metadata
const metadata = JSON.parse(
  fs.readFileSync(metadataPath, 'utf-8')
);

// 3. For each table
const filePath = path.join(backupPath, tableInfo.filePath);
const data = JSON.parse(fs.readFileSync(filePath, 'utf-8'));

// 4. Clear existing data
await supabase.from(table).delete().neq('id', '');

// 5. Restore in batches
for (let i = 0; i < data.length; i += batchSize) {
  const batch = data.slice(i, i + batchSize);
  await supabase.from(table).insert(batch);
}
```

---

## Dependencies

Both scripts require:

```json
{
  "@supabase/supabase-js": "^2.x",
  "dotenv": "^17.x",
  "ts-node": "^10.x"
}
```

Install with:
```bash
npm install --save-dev @supabase/supabase-js dotenv ts-node
```

---

## Environment Variables

Required in `OcuHubWepApp/.env`:

```bash
SUPABASE_URL=https://gkbhxyjfnbhkiarsutby.supabase.co
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key-here
```

⚠️ **Security:**
- Never commit `.env` to git
- Never share service role key
- Use key rotation regularly
- Only share with trusted developers

---

## Coming Soon

Planned scripts for future implementation:

### verify-backup.ts
- Validate backup integrity
- Check all files present
- Verify row counts
- Compare checksums

### list-backups.ts
- Show all available backups
- Display backup sizes
- Show creation dates
- List row counts per table

### delete-backup.ts
- Remove old backups
- Free up disk space
- Confirm before deletion
- Archive to external storage

### schedule-backup.ts
- Set up cron jobs
- Daily automatic backups
- Email notifications
- Backup rotation

### restore-specific-table.ts
- Restore single table only
- Useful for selective recovery
- Faster than full restore
- Minimal downtime

### compare-backups.ts
- Compare two backups
- Show differences
- Data drift detection
- Audit trail

---

## Troubleshooting

### Script Execution Issues

**Error: "Cannot find module"**
```bash
# Install dependencies
npm install
# Or install specific package
npm install @supabase/supabase-js
```

**Error: "Unsupported engine"**
```bash
# Update Node.js to v20+
nvm install 20
nvm use 20
```

**Error: "ENOENT: no such file or directory"**
```bash
# Ensure .env exists and has correct path
ls -la OcuHubWepApp/.env
```

### Database Issues

**Timeout during backup:**
- Reduce batch size in code
- Check internet connection
- Try again during off-peak hours

**Timeout during restore:**
- Database may be slow
- Try restoring fewer tables first
- Check Supabase status page

**Permission denied:**
- Verify service role key permissions
- Check Supabase RLS policies
- Regenerate key if needed

---

## Performance Tips

1. **Backup Frequency**
   - Daily backups recommended
   - Weekly full verification
   - Monthly archive to external storage

2. **Backup Timing**
   - Run during low-traffic hours
   - Avoid peak usage times
   - Schedule for off-hours

3. **Storage**
   - Keep last 10 backups
   - Delete backups older than 30 days
   - Archive important backups

4. **Network**
   - Use stable internet connection
   - Close other bandwidth-heavy apps
   - Avoid VPN if possible

---

## Support

For issues:
1. Check the [DATABASE_REFERENCE/README.md](./README.md)
2. Review [BACKUP_RESTORE_OPERATIONS.md](./BACKUP_RESTORE_OPERATIONS.md)
3. Check error messages carefully
4. Review Supabase status page
5. Contact support with error logs
