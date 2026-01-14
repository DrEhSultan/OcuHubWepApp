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

  for (const w of writes) {
    if (!ALLOWED_TABLES.includes(w.table as any)) {
      rowsWritten[w.table] = 0;
      continue;
    }
    if (!Array.isArray(w.rows) || w.rows.length === 0) {
      rowsWritten[w.table] = 0;
      continue;
    }
    const mode = w.mode || 'upsert';
    if (mode === 'insert') {
      const { error } = await supabase.from(w.table).insert(w.rows);
      if (error) {
        return res.status(500).json({ error: 'Supabase insert error', requestId });
      }
      rowsWritten[w.table] = (rowsWritten[w.table] || 0) + w.rows.length;
    } else {
      const { error } = await supabase.from(w.table).upsert(w.rows);
      if (error) {
        return res.status(500).json({ error: 'Supabase upsert error', requestId });
      }
      rowsWritten[w.table] = (rowsWritten[w.table] || 0) + w.rows.length;
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
