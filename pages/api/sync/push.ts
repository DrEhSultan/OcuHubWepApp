import type { NextApiRequest, NextApiResponse } from 'next';
import { randomUUID } from 'crypto';
import { gateNewPath } from '../../../lib/authGate';
import { createClient } from '@supabase/supabase-js';
import { getSecurePathEnv } from '../../../lib/securePathConfig';

const ALLOWED_TABLES = [
  'user_profiles',
  'app_sessions',
  'app_settings',
  'screen_settings',
  'section_settings',
  'category_settings',
  'tool_settings',
  'tool_usage_events',
  'feedbacks',
  'survey_responses',
  'user_announcement_state',
  'case_notes',
  'case_visits',
  'case_entries',
  'case_attachments',
] as const;

type PushRow = Record<string, any>;
type PushPayload = {
  writes?: Array<{
    table: string;
    rows: PushRow[];
    mode?: 'upsert' | 'insert';
  }>;
};

// Column mapping: client camelCase -> Supabase snake_case
// Only include columns that differ between client and server
const COLUMN_MAPPINGS: Record<string, Record<string, string>> = {
  app_sessions: {
    userId: 'user_id',
    startTime: 'start_time',
    endTime: 'end_time',
    publicIp: 'public_ip',
    deviceInfo: 'device_info',
    appVersion: 'app_version',
    isActive: 'is_active',
    isSynced: 'is_synced',
    lastSyncedAt: 'last_synced_at',
    createdAt: 'created_at',
    updatedAt: 'updated_at',
    osPlatform: 'os_platform',
    deviceBrand: 'device_brand',
    deviceModel: 'device_model',
    isDevice: 'is_device',
    deviceType: 'device_type',
    osVersion: 'os_version',
    isLocationLive: 'is_location_live',
    lastLiveLocationFetchedAt: 'last_live_location_fetched_at',
    fallbackLocationUsedAt: 'fallback_location_used_at',
    deviceProfileId: 'device_profile_id',
    platformType: 'platform_type',
  },
  app_settings: {
    userId: 'user_id',
    settingKey: 'setting_key',
    settingValue: 'setting_value',
    customSettings: 'custom_settings',
    isArchived: 'is_archived',
    lastUpdated: 'last_updated',
    createdAt: 'created_at',
    updatedAt: 'updated_at',
    isSynced: 'is_synced',
    lastSyncedAt: 'last_synced_at',
  },
  screen_settings: {
    userId: 'user_id',
    screenId: 'screen_id',
    lastUpdated: 'last_updated',
    createdAt: 'created_at',
    updatedAt: 'updated_at',
    isSynced: 'is_synced',
    lastSyncedAt: 'last_synced_at',
    isArchived: 'is_archived',
  },
  section_settings: {
    userId: 'user_id',
    sectionId: 'section_id',
    isExpanded: 'is_expanded',
    sortOrder: 'sort_order',
    isHidden: 'is_hidden',
    lastUpdated: 'last_updated',
    createdAt: 'created_at',
    updatedAt: 'updated_at',
    isSynced: 'is_synced',
    lastSyncedAt: 'last_synced_at',
    isArchived: 'is_archived',
  },
  category_settings: {
    userId: 'user_id',
    categoryId: 'category_id',
    isExpanded: 'is_expanded',
    sortOrder: 'sort_order',
    isHidden: 'is_hidden',
    lastUpdated: 'last_updated',
    createdAt: 'created_at',
    updatedAt: 'updated_at',
    isSynced: 'is_synced',
    lastSyncedAt: 'last_synced_at',
    isArchived: 'is_archived',
  },
  tool_settings: {
    userId: 'user_id',
    toolId: 'tool_id',
    isFavorite: 'is_favorite',
    isHidden: 'is_hidden',
    sortOrder: 'sort_order',
    lastUsed: 'last_used',
    usageCount: 'usage_count',
    createdAt: 'created_at',
    updatedAt: 'updated_at',
    isSynced: 'is_synced',
    lastSyncedAt: 'last_synced_at',
    isArchived: 'is_archived',
  },
  tool_usage_events: {
    userId: 'user_id',
    toolId: 'tool_id',
    sessionId: 'session_id',
    appSessionId: 'app_session_id',
    toolSessionId: 'tool_session_id',
    eventType: 'event_type',
    eventData: 'event_data',
    eventTimestamp: 'event_timestamp',
    createdAt: 'created_at',
    isSynced: 'is_synced',
    lastSyncedAt: 'last_synced_at',
  },
  feedbacks: {
    userId: 'user_id',
    toolId: 'tool_id',
    feedbackType: 'feedback_type',
    feedbackText: 'feedback_text',
    createdAt: 'created_at',
    isSynced: 'is_synced',
    lastSyncedAt: 'last_synced_at',
  },
  user_announcement_state: {
    oderId: 'order_id',
    userId: 'user_id',
    announcementId: 'announcement_id',
    isRead: 'is_read',
    isDismissed: 'is_dismissed',
    readAt: 'read_at',
    dismissedAt: 'dismissed_at',
    createdAt: 'created_at',
    updatedAt: 'updated_at',
    isSynced: 'is_synced',
    lastSyncedAt: 'last_synced_at',
  },
};

/**
 * Transform a row from client camelCase to Supabase snake_case
 */
function transformRowToSupabase(table: string, row: PushRow): PushRow {
  const mapping = COLUMN_MAPPINGS[table];
  if (!mapping) return row; // No mapping needed for this table
  
  const transformed: PushRow = {};
  for (const [key, value] of Object.entries(row)) {
    const newKey = mapping[key] || key;
    transformed[newKey] = value;
  }
  
  // Special handling for app_sessions
  if (table === 'app_sessions') {
    // Supabase requires auth_uid = user_id (constraint)
    // The local table doesn't have auth_uid, so we copy user_id to auth_uid
    if (transformed.user_id && !transformed.auth_uid) {
      transformed.auth_uid = transformed.user_id;
    }
    
    // Convert INTEGER timestamps to ISO strings for Supabase
    if (typeof transformed.start_time === 'number') {
      transformed.start_time = new Date(transformed.start_time).toISOString();
    }
    if (typeof transformed.end_time === 'number') {
      transformed.end_time = new Date(transformed.end_time).toISOString();
    }
    
    // Parse deviceInfo if it's a string (SQLite stores as TEXT)
    if (typeof transformed.device_info === 'string') {
      try {
        transformed.device_info = JSON.parse(transformed.device_info);
      } catch {
        // Keep as string if parsing fails
      }
    }
  }
  
  return transformed;
}

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  const requestId = (req.headers['x-request-id'] as string) || randomUUID();
  const envNames = getSecurePathEnv('sync');

  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed', requestId });
  }

  const decision = await gateNewPath(req, envNames.enabledEnv, envNames.usersEnv, envNames.devicesEnv, {
    allowMissingTokenFallback: 'legacy',
    requestId,
    featureTag: 'sync',
    minVersionEnvName: envNames.minVersionEnv,
  });

  if (decision.mode !== 'v2') {
    if (shouldLog()) {
      console.log(
        JSON.stringify({
          scope: 'secure_path_decision',
          feature: 'sync',
          requestId,
          final_mode: 'legacy',
          allowlisted: false,
          decision_reason: decision.reason,
        })
      );
    }
    return res.status(200).json({
      success: true,
      mode: 'legacy',
      requestId,
    });
  }

  const supabase = createClient(process.env.NEXT_PUBLIC_SUPABASE_URL!, process.env.SUPABASE_SERVICE_ROLE_KEY!);
  const payload = (req.body || {}) as PushPayload;
  const writes = payload.writes || [];
  const rowsWritten: Record<string, number> = {};
  const errors: string[] = [];

  // Map client table names to Supabase table names where they differ
  const tableNameMap: Record<string, string> = {
    'user_profiles': 'users',
  };

  for (const w of writes) {
    if (!ALLOWED_TABLES.includes(w.table as any)) {
      rowsWritten[w.table] = 0;
      continue;
    }
    if (!Array.isArray(w.rows) || w.rows.length === 0) {
      rowsWritten[w.table] = 0;
      continue;
    }

    const supabaseTable = tableNameMap[w.table] || w.table;
    const mode = w.mode || 'upsert';
    
    // Transform rows from client camelCase to Supabase snake_case
    const transformedRows = w.rows.map(row => transformRowToSupabase(w.table, row));

    try {
      // Log the transformation for debugging
      if (shouldLog()) {
        console.log(JSON.stringify({
          scope: 'sync_push_transform',
          table: w.table,
          supabaseTable,
          originalRowCount: w.rows.length,
          transformedRowCount: transformedRows.length,
          sampleOriginal: w.rows[0] ? Object.keys(w.rows[0]) : [],
          sampleTransformed: transformedRows[0] ? Object.keys(transformedRows[0]) : [],
          requestId,
        }));
      }
      
      if (mode === 'insert') {
        const { error } = await supabase.from(supabaseTable).insert(transformedRows);
        if (error) {
          console.error(JSON.stringify({ scope: 'sync_push_error', table: w.table, supabaseTable, error: error.message, requestId }));
          errors.push(`${w.table}: ${error.message}`);
          rowsWritten[w.table] = 0;
          continue;
        }
      } else {
        const { error } = await supabase.from(supabaseTable).upsert(transformedRows);
        if (error) {
          console.error(JSON.stringify({ scope: 'sync_push_error', table: w.table, supabaseTable, error: error.message, requestId }));
          errors.push(`${w.table}: ${error.message}`);
          rowsWritten[w.table] = 0;
          continue;
        }
      }
      rowsWritten[w.table] = (rowsWritten[w.table] || 0) + w.rows.length;
    } catch (err) {
      console.error(JSON.stringify({ scope: 'sync_push_exception', table: w.table, error: String(err), requestId }));
      errors.push(`${w.table}: ${String(err)}`);
      rowsWritten[w.table] = 0;
    }
  }

  if (shouldLog()) {
    console.log(
      JSON.stringify({
        scope: 'secure_path_decision',
        feature: 'sync',
        requestId,
        final_mode: 'secure',
        allowlisted: true,
        uid_hash: decision.uidHash || null,
        decision_reason: decision.reason,
      })
    );
    console.log(
      JSON.stringify({
        scope: 'sync_push',
        requestId,
        mode: 'v2',
        decision_reason: 'allowlisted',
        rows_received_per_table: Object.fromEntries(writes.map((w) => [w.table, w.rows?.length || 0])),
        rows_written_per_table: rowsWritten,
        errors_count: 0,
      })
    );
  }

  return res.status(200).json({
    success: true,
    mode: 'v2',
    requestId,
  });
}

const shouldLog = () => {
  const enabled = process.env.DEBUG_SECURE_GATE === 'true';
  if (!enabled) return false;
  const rate = Number(process.env.DEBUG_SAMPLE_RATE || '0.05');
  return Math.random() < rate;
};
