import { createClient } from '@supabase/supabase-js';
import fs from 'fs';
import path from 'path';

const getEnv = (key: string): string => {
  const value = process.env[key];
  if (!value) {
    throw new Error(`Missing required environment variable: ${key}`);
  }
  return value;
};

const restoreDatabase = async (backupPath: string) => {
  if (!backupPath) {
    console.error('❌ Usage: npx ts-node scripts/restore-database.ts <path-to-backup>');
    console.error('Example: npx ts-node scripts/restore-database.ts ./backups/backup-2024-11-16T10-30-00-000Z');
    process.exit(1);
  }

  if (!fs.existsSync(backupPath)) {
    console.error(`❌ Backup directory not found: ${backupPath}`);
    process.exit(1);
  }

  try {
    const url = getEnv('SUPABASE_URL');
    const serviceRoleKey = getEnv('SUPABASE_SERVICE_ROLE_KEY');

    const supabase = createClient(url, serviceRoleKey, {
      auth: { persistSession: false },
    });

    // Read metadata
    const metadataPath = path.join(backupPath, 'backup-metadata.json');
    if (!fs.existsSync(metadataPath)) {
      console.error('❌ Backup metadata not found. Invalid backup directory.');
      process.exit(1);
    }

    const metadata = JSON.parse(fs.readFileSync(metadataPath, 'utf-8'));
    console.log(`\n🔄 Starting restore from backup created: ${metadata.timestamp}`);
    console.log('⚠️  WARNING: This will OVERWRITE existing data!\n');

    const confirmRestore = process.argv[3];
    if (confirmRestore !== '--confirm') {
      console.log('To proceed with restore, run:');
      console.log(`npx ts-node scripts/restore-database.ts "${backupPath}" --confirm\n`);
      process.exit(0);
    }

    for (const [table, tableInfo] of Object.entries(metadata.tables)) {
      if (!(tableInfo as any).success) {
        console.log(`⏭️  Skipping ${table} (not backed up)`);
        continue;
      }

      try {
        const filePath = path.join(backupPath, (tableInfo as any).filePath);
        const data = JSON.parse(fs.readFileSync(filePath, 'utf-8'));

        if (!data || data.length === 0) {
          console.log(`⏭️  ${table}: No data to restore`);
          continue;
        }

        console.log(`⏳ Restoring table: ${table} (${data.length} rows)`);

        // Clear existing data
        const { error: deleteError } = await supabase.from(table).delete().neq('id', '');

        if (deleteError && deleteError.code !== 'PGRST116') {
          console.warn(`⚠️  Warning clearing ${table}:`, deleteError.message);
        }

        // Insert data in batches to avoid timeout
        const batchSize = 100;
        for (let i = 0; i < data.length; i += batchSize) {
          const batch = data.slice(i, i + batchSize);
          const { error: insertError } = await supabase.from(table).insert(batch);

          if (insertError) {
            console.error(`❌ Error restoring ${table} (batch ${Math.floor(i / batchSize) + 1}):`, insertError);
            throw insertError;
          }
        }

        console.log(`✅ ${table}: Restored ${data.length} rows`);
      } catch (error: any) {
        console.error(`❌ Error restoring ${table}:`, error.message);
        throw error;
      }
    }

    console.log('\n✨ Restore complete!');
  } catch (error: any) {
    console.error('\n❌ Restore failed:', error.message);
    process.exit(1);
  }
};

const backupPath = process.argv[2];
restoreDatabase(backupPath);
