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

// Column mapping: Supabase snake_case -> client camelCase
// Only include columns that differ between server and client
const COLUMN_MAPPINGS: Record<string, Record<string, string>> = {
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
    event_type: 'eventType',
    event_data: 'eventData',
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

  for (const table of safeTables) {
    const supabaseTable = tableNameMap[table] || table;
    try {
      const query = supabase.from(supabaseTable).select('*');
      // Apply simple filters where possible
      if (auth_uid) {
        query.eq('auth_uid', auth_uid);
      } else if (user_id) {
        query.eq('user_id', user_id);
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
