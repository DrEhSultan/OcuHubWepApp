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
      responseData[table] = data || [];
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
