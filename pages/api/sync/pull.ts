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

// Column mapping: Supabase snake_case -> client camelCase
// Only include columns that differ between server and client
const COLUMN_MAPPINGS: Record<string, Record<string, string>> = {
  user_profiles: {
    user_id: 'userId',
    auth_uid: 'authUid',
    image_uri: 'imageUri',
    is_verified: 'isVerified',
    is_anonymous: 'isAnonymous',
    login_method: 'loginMethod',
    created_at: 'createdAt',
    updated_at: 'updatedAt',
    is_synced: 'isSynced',
    last_synced_at: 'lastSyncedAt',
    last_country: 'lastCountry',
    last_city: 'lastCity',
    last_platform: 'lastPlatform',
    last_device_brand: 'lastDeviceBrand',
    last_is_real_device: 'lastIsRealDevice',
    last_ip: 'lastIp',
    last_location_updated_at: 'lastLocationUpdatedAt',
  },
  app_sessions: {
    user_id: 'userId',
    start_time: 'startTime',
    end_time: 'endTime',
    public_ip: 'publicIp',
    device_info: 'deviceInfo',
    app_version: 'appVersion',
    is_active: 'isActive',
    is_synced: 'isSynced',
    last_synced_at: 'lastSyncedAt',
    created_at: 'createdAt',
    updated_at: 'updatedAt',
    os_platform: 'osPlatform',
    device_brand: 'deviceBrand',
    device_model: 'deviceModel',
    is_device: 'isDevice',
    device_type: 'deviceType',
    os_version: 'osVersion',
    is_location_live: 'isLocationLive',
    last_live_location_fetched_at: 'lastLiveLocationFetchedAt',
    fallback_location_used_at: 'fallbackLocationUsedAt',
    device_profile_id: 'deviceProfileId',
    platform_type: 'platformType',
  },
  app_settings: {
    user_id: 'userId',
    setting_key: 'settingKey',
    setting_value: 'settingValue',
    custom_settings: 'customSettings',
    is_archived: 'isArchived',
    last_updated: 'lastUpdated',
    created_at: 'createdAt',
    updated_at: 'updatedAt',
    is_synced: 'isSynced',
    last_synced_at: 'lastSyncedAt',
  },
  screen_settings: {
    user_id: 'userId',
    screen_id: 'screenId',
    last_updated: 'lastUpdated',
    created_at: 'createdAt',
    updated_at: 'updatedAt',
    is_synced: 'isSynced',
    last_synced_at: 'lastSyncedAt',
    is_archived: 'isArchived',
  },
  section_settings: {
    user_id: 'userId',
    section_id: 'sectionId',
    is_expanded: 'isExpanded',
    sort_order: 'sortOrder',
    is_hidden: 'isHidden',
    last_updated: 'lastUpdated',
    created_at: 'createdAt',
    updated_at: 'updatedAt',
    is_synced: 'isSynced',
    last_synced_at: 'lastSyncedAt',
    is_archived: 'isArchived',
  },
  category_settings: {
    user_id: 'userId',
    category_id: 'categoryId',
    is_expanded: 'isExpanded',
    sort_order: 'sortOrder',
    is_hidden: 'isHidden',
    last_updated: 'lastUpdated',
    created_at: 'createdAt',
    updated_at: 'updatedAt',
    is_synced: 'isSynced',
    last_synced_at: 'lastSyncedAt',
    is_archived: 'isArchived',
  },
  tool_settings: {
    user_id: 'userId',
    tool_id: 'toolId',
    is_favorite: 'isFavorite',
    is_hidden: 'isHidden',
    sort_order: 'sortOrder',
    last_used: 'lastUsed',
    usage_count: 'usageCount',
    created_at: 'createdAt',
    updated_at: 'updatedAt',
    is_synced: 'isSynced',
    last_synced_at: 'lastSyncedAt',
    is_archived: 'isArchived',
  },
  tool_usage_events: {
    user_id: 'userId',
    tool_id: 'toolId',
    session_id: 'sessionId',
    app_session_id: 'appSessionId',
    tool_session_id: 'toolSessionId',
    event_type: 'eventType',
    event_data: 'eventData',
    event_timestamp: 'eventTimestamp',
    created_at: 'createdAt',
    is_synced: 'isSynced',
    last_synced_at: 'lastSyncedAt',
  },
  feedbacks: {
    user_id: 'userId',
    tool_id: 'toolId',
    feedback_type: 'feedbackType',
    feedback_text: 'feedbackText',
    created_at: 'createdAt',
    is_synced: 'isSynced',
    last_synced_at: 'lastSyncedAt',
  },
  user_announcement_state: {
    order_id: 'orderId',
    user_id: 'userId',
    announcement_id: 'announcementId',
    is_read: 'isRead',
    is_dismissed: 'isDismissed',
    read_at: 'readAt',
    dismissed_at: 'dismissedAt',
    created_at: 'createdAt',
    updated_at: 'updatedAt',
    is_synced: 'isSynced',
    last_synced_at: 'lastSyncedAt',
  },
};

/**
 * Transform a row from Supabase snake_case to client camelCase
 */
function transformRowToClient(table: string, row: Record<string, any>): Record<string, any> {
  const mapping = COLUMN_MAPPINGS[table];
  if (!mapping) return row; // No mapping needed for this table
  
  const transformed: Record<string, any> = {};
  for (const [key, value] of Object.entries(row)) {
    const newKey = mapping[key] || key;
    transformed[newKey] = value;
  }
  
  // Remove auth_uid from all tables - local SQLite doesn't have this column
  delete transformed.auth_uid;
  delete transformed.authUid;
  
  // Special handling for app_sessions
  if (table === 'app_sessions') {
    // Convert ISO timestamps to INTEGER (milliseconds) for SQLite
    if (typeof transformed.startTime === 'string') {
      const ts = Date.parse(transformed.startTime);
      if (!isNaN(ts)) transformed.startTime = ts;
    }
    if (typeof transformed.endTime === 'string') {
      const ts = Date.parse(transformed.endTime);
      if (!isNaN(ts)) transformed.endTime = ts;
    }
    
    // Stringify deviceInfo for SQLite (stores as TEXT)
    if (transformed.deviceInfo && typeof transformed.deviceInfo === 'object') {
      transformed.deviceInfo = JSON.stringify(transformed.deviceInfo);
    }
  }
  
  // Special handling for app_settings - transform from Supabase format to client format
  // Supabase: { user_id, setting_key, setting_value (JSONB) }
  // Client SQLite: { userId, settings (JSON string), lastUpdated, version }
  if (table === 'app_settings') {
    // Transform setting_value to settings JSON string
    if (transformed.settingValue !== undefined) {
      transformed.settings = typeof transformed.settingValue === 'string' 
        ? transformed.settingValue 
        : JSON.stringify(transformed.settingValue || {});
      delete transformed.settingValue;
    }
    // Convert timestamp to INTEGER
    if (typeof transformed.lastUpdated === 'string') {
      const ts = Date.parse(transformed.lastUpdated);
      if (!isNaN(ts)) transformed.lastUpdated = ts;
    }
    // Remove fields that don't exist in client SQLite
    delete transformed.settingKey;
    delete transformed.customSettings;
    delete transformed.isArchived;
    delete transformed.createdAt;
    delete transformed.updatedAt;
    // Add default version if missing
    if (transformed.version === undefined) {
      transformed.version = 1;
    }
  }
  
  // Special handling for section_settings
  if (table === 'section_settings') {
    // Convert timestamp to INTEGER
    if (typeof transformed.lastUpdated === 'string') {
      const ts = Date.parse(transformed.lastUpdated);
      if (!isNaN(ts)) transformed.lastUpdated = ts;
    }
    // Remove fields that don't exist in client SQLite
    delete transformed.filters;
    delete transformed.isArchived;
    delete transformed.createdAt;
    delete transformed.updatedAt;
  }
  
  // Special handling for user_announcement_state
  // Supabase schema is different from client SQLite
  if (table === 'user_announcement_state') {
    // The Supabase table has different columns than client expects
    // Skip transformation - this table has incompatible schemas
    // Return empty to skip inserting into local DB
    return {}; // Skip this table for now
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

  // Non-allowlisted users keep legacy path (direct Supabase on client)
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
      data: {},
    });
  }

  const supabase = createClient(process.env.NEXT_PUBLIC_SUPABASE_URL!, process.env.SUPABASE_SERVICE_ROLE_KEY!);

  const { tables = [], auth_uid, user_id } = (req.body || {}) as {
    tables?: string[];
    auth_uid?: string;
    user_id?: string;
  };

  const safeTables = tables.filter((t: string) => ALLOWED_TABLES.includes(t as any));
  const responseData: Record<string, any[]> = {};

  // Map client table names to Supabase table names where they differ
  const tableNameMap: Record<string, string> = {
    'user_profiles': 'users',
  };

  // Tables that don't have auth_uid column - use user_id instead
  const tablesWithoutAuthUid = ['user_announcement_state'];

  for (const table of safeTables) {
    const supabaseTable = tableNameMap[table] || table;
    try {
      const query = supabase.from(supabaseTable).select('*');
      // Apply simple filters where possible
      // Some tables don't have auth_uid column
      if (tablesWithoutAuthUid.includes(table)) {
        if (user_id) {
          query.eq('user_id', user_id);
        } else if (auth_uid) {
          query.eq('user_id', auth_uid); // Use auth_uid as user_id for these tables
        }
      } else {
        if (auth_uid) {
          query.eq('auth_uid', auth_uid);
        } else if (user_id) {
          query.eq('user_id', user_id);
        }
      }
      const { data, error } = await query;
      if (error) {
        // Log error but continue with other tables
        console.error(JSON.stringify({ scope: 'sync_pull_error', table, supabaseTable, error: error.message, requestId }));
        responseData[table] = [];
        continue;
      }
      // Transform rows from Supabase snake_case to client camelCase
      responseData[table] = (data || []).map(row => transformRowToClient(table, row));
    } catch (err) {
      console.error(JSON.stringify({ scope: 'sync_pull_exception', table, error: String(err), requestId }));
      responseData[table] = [];
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
        scope: 'sync_pull',
        requestId,
        mode: 'v2',
        decision_reason: 'allowlisted',
        tables_requested: safeTables,
        rows_returned_per_table: Object.fromEntries(
          safeTables.map((t) => [t, responseData[t]?.length || 0])
        ),
      })
    );
  }

  return res.status(200).json({
    success: true,
    mode: 'v2',
    requestId,
    data: responseData,
  });
}

const shouldLog = () => {
  const enabled = process.env.DEBUG_SECURE_GATE === 'true';
  if (!enabled) return false;
  const rate = Number(process.env.DEBUG_SAMPLE_RATE || '0.05');
  return Math.random() < rate;
};
