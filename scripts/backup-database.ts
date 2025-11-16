import 'dotenv/config';
import { createClient } from '@supabase/supabase-js';
import fs from 'fs';
import path from 'path';

const TABLES = [
  'app_sessions',
  'app_settings',
  'category_settings',
  'feedbacks',
  'screen_settings',
  'section_settings',
  'tool_settings',
  'tool_usage_events',
  'user_sync_states',
  'users',
];

const getEnv = (key: string): string => {
  const value = process.env[key];
  if (!value) {
    throw new Error(`Missing required environment variable: ${key}`);
  }
  return value;
};

const createBackupDir = (): string => {
  const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
  const backupDir = path.join(process.cwd(), 'backups', `backup-${timestamp}`);

  if (!fs.existsSync(backupDir)) {
    fs.mkdirSync(backupDir, { recursive: true });
  }

  return backupDir;
};

const backupDatabase = async () => {
  try {
    const url = getEnv('SUPABASE_URL');
    const serviceRoleKey = getEnv('SUPABASE_SERVICE_ROLE_KEY');

    const supabase = createClient(url, serviceRoleKey, {
      auth: { persistSession: false },
    });

    const backupDir = createBackupDir();
    console.log(`📦 Starting backup to: ${backupDir}\n`);

    const metadata: any = {
      timestamp: new Date().toISOString(),
      tables: {},
    };

    for (const table of TABLES) {
      try {
        console.log(`⏳ Backing up table: ${table}`);

        // Fetch all data from the table
        const { data, error, count } = await supabase
          .from(table)
          .select('*', { count: 'exact' });

        if (error) {
          console.error(`❌ Error backing up ${table}:`, error);
          metadata.tables[table] = { error: error.message, rowCount: 0 };
          continue;
        }

        // Write to JSON file
        const filePath = path.join(backupDir, `${table}.json`);
        fs.writeFileSync(filePath, JSON.stringify(data, null, 2));

        console.log(`✅ ${table}: ${data?.length || 0} rows backed up`);
        metadata.tables[table] = {
          rowCount: data?.length || 0,
          filePath: `${table}.json`,
          success: true,
        };
      } catch (error: any) {
        console.error(`❌ Error processing ${table}:`, error.message);
        metadata.tables[table] = { error: error.message, rowCount: 0 };
      }
    }

    // Write metadata file
    const metadataPath = path.join(backupDir, 'backup-metadata.json');
    fs.writeFileSync(metadataPath, JSON.stringify(metadata, null, 2));

    console.log(`\n✨ Backup complete! Saved to: ${backupDir}`);
    console.log(`📋 Total tables backed up: ${Object.keys(metadata.tables).length}`);

    // Summary
    const totalRows = Object.values(metadata.tables).reduce(
      (sum: number, table: any) => sum + (table.rowCount || 0),
      0
    );
    console.log(`📊 Total rows backed up: ${totalRows}`);

  } catch (error: any) {
    console.error('❌ Backup failed:', error.message);
    process.exit(1);
  }
};

backupDatabase();
