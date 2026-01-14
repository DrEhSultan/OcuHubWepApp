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
  // Case notes tables temporarily disabled - not yet implemented in Supabase
  // 'case_notes',
  // 'case_visits',
  // 'case_entries',
  // 'case_attachments',
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
  user_profiles: {
    userId: 'user_id',
    authUid: 'auth_uid',
    imageUri: 'image_uri',
    isVerified: 'is_verified',
    isAnonymous: 'is_anonymous',
    loginMethod: 'login_method',
    createdAt: 'created_at',
    updatedAt: 'updated_at',
    isSynced: 'is_synced',
    lastSyncedAt: 'last_synced_at',
    lastCountry: 'last_country',
    lastCity: 'last_city',
    lastPlatform: 'last_platform',
    lastDeviceBrand: 'last_device_brand',
    lastIsRealDevice: 'last_is_real_device',
    lastIp: 'last_ip',
    lastLocationUpdatedAt: 'last_location_updated_at',
  },
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
    isFavourite: 'is_favourite',
    isFavorite: 'is_favourite',
    isHidden: 'is_hidden',
    orderInApp: 'order_in_app',
    orderInCategory: 'order_in_category',
    orderInSection: 'order_in_section',
    usageCount: 'usage_count',
    totalUsageDurationSec: 'usage_duration_sec',
    lastUsedAt: 'last_used_at',
    customSettings: 'settings',
    lastUpdated: 'last_updated',
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
    
    // Helper to convert timestamp (number or numeric string) to ISO string
    const convertTimestamp = (val: any): string | null => {
      if (val === null || val === undefined) return null;
      // Already an ISO string
      if (typeof val === 'string' && val.includes('T')) return val;
      // Numeric value (number or string of digits)
      const ts = typeof val === 'number' ? val : (typeof val === 'string' && /^\d+$/.test(val)) ? parseInt(val, 10) : null;
      if (ts !== null && !isNaN(ts) && ts > 0) {
        return new Date(ts).toISOString();
      }
      return null;
    };
    
    // Convert all timestamp fields - check both snake_case and original values
    // start_time / startTime
    if (transformed.start_time !== null && transformed.start_time !== undefined) {
      const converted = convertTimestamp(transformed.start_time);
      if (converted) transformed.start_time = converted;
    }
    // end_time / endTime  
    if (transformed.end_time !== null && transformed.end_time !== undefined) {
      const converted = convertTimestamp(transformed.end_time);
      if (converted) transformed.end_time = converted;
    }
    // created_at
    if (transformed.created_at !== null && transformed.created_at !== undefined) {
      const converted = convertTimestamp(transformed.created_at);
      if (converted) transformed.created_at = converted;
    }
    // updated_at
    if (transformed.updated_at !== null && transformed.updated_at !== undefined) {
      const converted = convertTimestamp(transformed.updated_at);
      if (converted) transformed.updated_at = converted;
    }
    // last_synced_at
    if (transformed.last_synced_at !== null && transformed.last_synced_at !== undefined) {
      const converted = convertTimestamp(transformed.last_synced_at);
      if (converted) transformed.last_synced_at = converted;
    }
    // last_live_location_fetched_at
    if (transformed.last_live_location_fetched_at !== null && transformed.last_live_location_fetched_at !== undefined) {
      const converted = convertTimestamp(transformed.last_live_location_fetched_at);
      if (converted) transformed.last_live_location_fetched_at = converted;
    }
    // fallback_location_used_at
    if (transformed.fallback_location_used_at !== null && transformed.fallback_location_used_at !== undefined) {
      const converted = convertTimestamp(transformed.fallback_location_used_at);
      if (converted) transformed.fallback_location_used_at = converted;
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
  
  // Special handling for app_settings - transform from client format to Supabase format
  // Client: { userId, settings (JSON string), lastUpdated, version }
  // Supabase: { user_id, auth_uid, setting_key, setting_value (JSONB), last_updated }
  if (table === 'app_settings') {
    // Ensure auth_uid = user_id (Supabase constraint)
    if (transformed.user_id && !transformed.auth_uid) {
      transformed.auth_uid = transformed.user_id;
    }
    
    // Transform settings JSON string to setting_value JSONB
    if (transformed.settings && !transformed.setting_value) {
      let settingsObj = transformed.settings;
      if (typeof settingsObj === 'string') {
        try {
          settingsObj = JSON.parse(settingsObj);
        } catch {
          settingsObj = {};
        }
      }
      transformed.setting_value = settingsObj;
      transformed.custom_settings = settingsObj;
      delete transformed.settings;
    }
    
    // Ensure setting_key exists (required by Supabase)
    if (!transformed.setting_key) {
      transformed.setting_key = 'default';
    }
    
    // Convert lastUpdated INTEGER to ISO timestamp
    if (typeof transformed.last_updated === 'number') {
      transformed.last_updated = new Date(transformed.last_updated).toISOString();
    }
    
    // Remove version field (not in Supabase schema)
    delete transformed.version;
  }
  
  // Special handling for screen_settings
  if (table === 'screen_settings') {
    if (transformed.user_id && !transformed.auth_uid) {
      transformed.auth_uid = transformed.user_id;
    }
    // Parse settings JSON string
    if (typeof transformed.settings === 'string') {
      try {
        transformed.settings = JSON.parse(transformed.settings);
      } catch {
        transformed.settings = {};
      }
    }
    // Convert lastUpdated INTEGER to ISO timestamp
    if (typeof transformed.last_updated === 'number') {
      transformed.last_updated = new Date(transformed.last_updated).toISOString();
    }
    delete transformed.version;
  }
  
  // Special handling for section_settings
  if (table === 'section_settings') {
    if (transformed.user_id && !transformed.auth_uid) {
      transformed.auth_uid = transformed.user_id;
    }
    // Convert lastUpdated INTEGER to ISO timestamp
    if (typeof transformed.last_updated === 'number') {
      transformed.last_updated = new Date(transformed.last_updated).toISOString();
    }
    // Transform client fields to Supabase filters JSONB
    if (!transformed.filters) {
      transformed.filters = {
        showFavoritesOnly: transformed.show_favorites_only || transformed.showFavoritesOnly || false,
        sortOption: transformed.sort_option || transformed.sortOption || null,
        searchQuery: transformed.search_query || transformed.searchQuery || null,
      };
    }
    // Clean up client-specific fields
    delete transformed.show_favorites_only;
    delete transformed.showFavoritesOnly;
    delete transformed.sort_option;
    delete transformed.sortOption;
    delete transformed.search_query;
    delete transformed.searchQuery;
    // Remove id field - Supabase uses composite key (user_id, section_id)
    delete transformed.id;
  }
  
  // Special handling for category_settings
  if (table === 'category_settings') {
    if (transformed.user_id && !transformed.auth_uid) {
      transformed.auth_uid = transformed.user_id;
    }
    // Parse settings JSON string
    if (typeof transformed.settings === 'string') {
      try {
        transformed.settings = JSON.parse(transformed.settings);
      } catch {
        transformed.settings = {};
      }
    }
    // Convert lastUpdated INTEGER to ISO timestamp
    if (typeof transformed.last_updated === 'number') {
      transformed.last_updated = new Date(transformed.last_updated).toISOString();
    }
  }
  
  // Special handling for tool_settings
  if (table === 'tool_settings') {
    if (transformed.user_id && !transformed.auth_uid) {
      transformed.auth_uid = transformed.user_id;
    }
    // Map customSettings to settings (Supabase column name)
    if (transformed.settings === undefined && transformed.custom_settings !== undefined) {
      transformed.settings = transformed.custom_settings;
      delete transformed.custom_settings;
    }
    // Parse settings JSON string
    if (typeof transformed.settings === 'string') {
      try {
        transformed.settings = JSON.parse(transformed.settings);
      } catch {
        transformed.settings = {};
      }
    }
    // Convert timestamps
    if (typeof transformed.last_updated === 'number') {
      transformed.last_updated = new Date(transformed.last_updated).toISOString();
    }
    if (typeof transformed.last_used_at === 'number') {
      transformed.last_used_at = new Date(transformed.last_used_at).toISOString();
    }
    if (typeof transformed.created_at === 'number') {
      transformed.created_at = new Date(transformed.created_at).toISOString();
    }
    if (typeof transformed.updated_at === 'number') {
      transformed.updated_at = new Date(transformed.updated_at).toISOString();
    }
    // Remove fields that don't exist in Supabase tool_settings
    // Supabase uses composite key (user_id, tool_id), not id
    delete transformed.id;
    delete transformed.sort_order;
    delete transformed.last_used;
    delete transformed.is_hidden;
    delete transformed.is_favorite;
  }
  
  // Special handling for tool_usage_events
  if (table === 'tool_usage_events') {
    if (transformed.user_id && !transformed.auth_uid) {
      transformed.auth_uid = transformed.user_id;
    }
    // Parse eventData JSON string
    if (typeof transformed.event_data === 'string') {
      try {
        transformed.event_data = JSON.parse(transformed.event_data);
      } catch {
        transformed.event_data = {};
      }
    }
    // Convert timestamps
    if (typeof transformed.event_timestamp === 'number') {
      transformed.event_timestamp = new Date(transformed.event_timestamp).toISOString();
    }
  }
  
  // Special handling for user_profiles (maps to users table)
  if (table === 'user_profiles') {
    // Ensure auth_uid = user_id (Supabase constraint)
    if (transformed.user_id && !transformed.auth_uid) {
      transformed.auth_uid = transformed.user_id;
    }
    // Parse insights JSON string
    if (typeof transformed.insights === 'string') {
      try {
        transformed.insights = JSON.parse(transformed.insights);
      } catch {
        transformed.insights = {};
      }
    }
    // Convert timestamps
    if (typeof transformed.created_at === 'number') {
      transformed.created_at = new Date(transformed.created_at).toISOString();
    }
    if (typeof transformed.updated_at === 'number') {
      transformed.updated_at = new Date(transformed.updated_at).toISOString();
    }
    if (typeof transformed.last_location_updated_at === 'number') {
      transformed.last_location_updated_at = new Date(transformed.last_location_updated_at).toISOString();
    }
    if (typeof transformed.last_synced_at === 'number') {
      transformed.last_synced_at = new Date(transformed.last_synced_at).toISOString();
    }
    // Remove fields that don't exist in Supabase users table
    delete transformed.version;
    delete transformed.device_id;
    delete transformed.device_info;
    delete transformed.deviceInfo;
    delete transformed.last_active_at;
    delete transformed.lastActiveAt;
    delete transformed.sync_status;
    delete transformed.syncStatus;
    delete transformed.is_synced;
    delete transformed.isSynced;
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

  // Tables with composite primary keys need onConflict specified
  const compositeKeyTables: Record<string, string> = {
    'section_settings': 'user_id,section_id',
    'tool_settings': 'user_id,tool_id',
    'screen_settings': 'user_id,screen_id',
    'category_settings': 'user_id,category_id',
    'app_settings': 'user_id,setting_key',
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
      // Log the transformation for debugging - ALWAYS log for now to debug issues
      // For app_sessions, log specific timestamp fields to debug conversion
      if (w.table === 'app_sessions' && w.rows[0]) {
        console.log(JSON.stringify({
          scope: 'sync_push_app_sessions_debug',
          original_start_time: w.rows[0].startTime || w.rows[0].start_time,
          original_start_time_type: typeof (w.rows[0].startTime || w.rows[0].start_time),
          transformed_start_time: transformedRows[0]?.start_time,
          transformed_start_time_type: typeof transformedRows[0]?.start_time,
          requestId,
        }));
      }
      
      console.log(JSON.stringify({
        scope: 'sync_push_transform',
        table: w.table,
        supabaseTable,
        originalRowCount: w.rows.length,
        transformedRowCount: transformedRows.length,
        sampleOriginal: w.rows[0] ? Object.keys(w.rows[0]) : [],
        sampleTransformed: transformedRows[0] ? Object.keys(transformedRows[0]) : [],
        sampleTransformedData: transformedRows[0] || null,
        requestId,
      }));
      
      if (mode === 'insert') {
        const { error } = await supabase.from(supabaseTable).insert(transformedRows);
        if (error) {
          console.error(JSON.stringify({ scope: 'sync_push_error', table: w.table, supabaseTable, error: error.message, requestId }));
          errors.push(`${w.table}: ${error.message}`);
          rowsWritten[w.table] = 0;
          continue;
        }
      } else {
        // Use onConflict for tables with composite primary keys
        const onConflict = compositeKeyTables[w.table];
        const upsertOptions = onConflict ? { onConflict } : undefined;
        const { error } = await supabase.from(supabaseTable).upsert(transformedRows, upsertOptions);
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
