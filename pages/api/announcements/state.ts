/**
 * API Endpoint: Update Announcement State
 * 
 * This endpoint handles user interactions with announcements:
 * - Mark as seen
 * - Dismiss
 * - Defer (remind later)
 * - Complete (survey/quiz submitted)
 * - Record impressions
 */

import type { NextApiRequest, NextApiResponse } from 'next';
import { randomUUID } from 'crypto';
import { createClient } from '@supabase/supabase-js';
import { withApiGuards } from '../../../lib/apiGuards';
import { getSupabaseAnonClientWithAuth, shouldUseAnnouncementV2 } from '../../../lib/announcementV2';

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!
);

const clampInt32 = (value: any): number | null => {
  if (value === null || value === undefined || value === '') return null;
  const num = Number(value);
  if (!Number.isFinite(num)) return null;
  const intVal = Math.trunc(num);
  const SAFE_MAX = 1_000_000_000; // conservative cap to avoid any int overflow inside RPC math
  const INT32_MIN = -2_147_483_648;
  const clamped = Math.min(Math.max(intVal, INT32_MIN), SAFE_MAX);
  return clamped;
};

const logStateRpcError = ({
  requestId,
  rpc,
  error,
  session_number_raw,
  session_number_clamped,
  mode,
  batch,
}: {
  requestId: string;
  rpc: string;
  error: any;
  session_number_raw: any;
  session_number_clamped: number | null;
  mode: 'legacy' | 'secure';
  batch: boolean;
}) => {
  console.error(
    JSON.stringify({
      scope: 'announcements/state',
      requestId,
      rpc,
      mode,
      batch,
      session_number_raw: session_number_raw ?? null,
      session_number_clamped,
      supabase_error_code: error?.code || error?.status || 'unknown_code',
      supabase_error_message: error?.message || 'unknown_error',
      supabase_error_hint: error?.hint || null,
    })
  );
};

interface StateUpdateRequest {
  announcement_id: string;
  user_id: string;
  action: 'seen' | 'dismissed' | 'deferred' | 'completed' | 'impression';
  session_number?: number;
  defer_sessions?: number;
  defer_hours?: number;
  questions_answered?: number;
}

interface BatchStateUpdateRequest {
  updates: StateUpdateRequest[];
}

async function handler(
  req: NextApiRequest,
  res: NextApiResponse
) {
  const requestId = randomUUID();
  if (req.method === 'POST') {
    return handleSingleUpdate(req, res, requestId);
  } else if (req.method === 'PUT') {
    return handleBatchUpdate(req, res, requestId);
  } else {
    return res.status(405).json({ error: 'Method not allowed', requestId });
  }
}

export default withApiGuards(handler);

async function handleSingleUpdate(req: NextApiRequest, res: NextApiResponse, requestId: string) {
  const v2Decision = await shouldUseAnnouncementV2(req);
  if (v2Decision.enabled) {
    console.log('[announcements/state] allowlisted user -> secure path (single)');
    return handleV2SingleUpdate(req, res, v2Decision.authUid!, requestId);
  }
  console.log('[announcements/state] legacy path (single)');

  try {
    const {
      announcement_id,
      user_id,
      action,
      session_number,
      defer_sessions,
      defer_hours,
      questions_answered,
    }: StateUpdateRequest = req.body;

    // Validate required fields
    if (!announcement_id || !user_id || !action) {
      return res.status(400).json({ 
        error: 'announcement_id, user_id, and action are required' 
      });
    }

    const safeSessionNumber = clampInt32(session_number);
    const safeDeferSessions = clampInt32(defer_sessions);
    const safeDeferHours = clampInt32(defer_hours);
    const safeQuestionsAnswered = clampInt32(questions_answered);

    // Handle impression separately (lightweight)
    if (action === 'impression') {
      console.log(
        JSON.stringify({
          scope: 'announcements/state',
          requestId,
          mode: 'legacy',
          action: 'impression',
          session_number_raw: session_number ?? null,
          session_number_clamped: safeSessionNumber,
        })
      );
      const { error } = await supabase.rpc('record_announcement_impression', {
        p_announcement_id: announcement_id,
        p_user_id: user_id,
        p_session_number: safeSessionNumber,
      });

      if (error) {
        logStateRpcError({
          requestId,
          rpc: 'record_announcement_impression',
          error,
          session_number_raw: session_number,
          session_number_clamped: safeSessionNumber,
          mode: 'legacy',
          batch: false,
        });
        return res.status(500).json({ error: 'Internal server error', requestId });
      }

      return res.status(200).json({ success: true, action: 'impression' });
    }

    // Map action to status
    const statusMap: Record<string, string> = {
      seen: 'seen',
      dismissed: 'dismissed',
      deferred: 'deferred',
      completed: 'completed',
    };

    const status = statusMap[action];
    if (!status) {
      return res.status(400).json({ error: 'Invalid action' });
    }

    // Update state using server function
    const { data, error } = await supabase.rpc('update_announcement_state', {
      p_announcement_id: announcement_id,
      p_user_id: user_id,
      p_status: status,
      p_session_number: safeSessionNumber,
      p_defer_sessions: safeDeferSessions,
      p_defer_hours: safeDeferHours,
      p_questions_answered: safeQuestionsAnswered,
    });

    if (error) {
      console.error('[API] update_announcement_state error');
      return res.status(500).json({ error: 'Internal server error' });
    }

    return res.status(200).json({ 
      success: true, 
      action,
      state: data,
    });
  } catch (error: any) {
    console.error('[API] State update error');
    return res.status(500).json({ error: 'Internal server error' });
  }
}

async function handleV2SingleUpdate(req: NextApiRequest, res: NextApiResponse, authUid: string, requestId: string) {
  try {
    const {
      announcement_id,
      action,
      session_number,
      defer_sessions,
      defer_hours,
      questions_answered,
    }: StateUpdateRequest = req.body;

    if (!announcement_id || !action) {
      return res.status(400).json({
        error: 'announcement_id and action are required',
      });
    }

    const safeSessionNumber = clampInt32(session_number);
    const safeDeferSessions = clampInt32(defer_sessions);
    const safeDeferHours = clampInt32(defer_hours);
    const safeQuestionsAnswered = clampInt32(questions_answered);

    if (action === 'impression') {
      console.log(
        JSON.stringify({
          scope: 'announcements/state',
          requestId,
          mode: 'secure',
          action: 'impression',
          session_number_raw: session_number ?? null,
          session_number_clamped: safeSessionNumber,
        })
      );
      const { error } = await supabase.rpc('record_announcement_impression', {
        p_announcement_id: announcement_id,
        p_user_id: authUid,
        p_session_number: safeSessionNumber,
      });

      if (error) {
        logStateRpcError({
          requestId,
          rpc: 'record_announcement_impression',
          error,
          session_number_raw: session_number,
          session_number_clamped: safeSessionNumber,
          mode: 'secure',
          batch: false,
        });
        return res.status(500).json({ error: 'Internal server error', requestId });
      }

      return res.status(200).json({ success: true, action: 'impression', mode: 'v2' });
    }

    const statusMap: Record<string, string> = {
      seen: 'seen',
      dismissed: 'dismissed',
      deferred: 'deferred',
      completed: 'completed',
    };

    const status = statusMap[action];
    if (!status) {
      return res.status(400).json({ error: 'Invalid action' });
    }

    const token = (req.headers.authorization || '').replace(/^Bearer\s+/i, '').trim();
    const v2Client = getSupabaseAnonClientWithAuth(token);

    const { data, error } = await v2Client.rpc('update_announcement_state', {
      p_announcement_id: announcement_id,
      p_user_id: authUid,
      p_status: status,
      p_session_number: safeSessionNumber,
      p_defer_sessions: safeDeferSessions,
      p_defer_hours: safeDeferHours,
      p_questions_answered: safeQuestionsAnswered,
    });

    if (error) {
      console.error('[API v2] update_announcement_state error');
      return res.status(500).json({ error: 'Internal server error' });
    }

    return res.status(200).json({
      success: true,
      action,
      state: data,
      mode: 'v2',
    });
  } catch (error: any) {
    console.error('[API v2] State update error');
    return res.status(500).json({ error: 'Internal server error' });
  }
}

async function handleBatchUpdate(req: NextApiRequest, res: NextApiResponse, requestId: string) {
  const v2Decision = await shouldUseAnnouncementV2(req);
  console.log(
    v2Decision.enabled
      ? '[announcements/state] allowlisted user -> secure path (batch)'
      : '[announcements/state] legacy path (batch)'
  );

  try {
    const { updates }: BatchStateUpdateRequest = req.body;

    if (!updates || !Array.isArray(updates) || updates.length === 0) {
      return res.status(400).json({ error: 'updates array is required' });
    }

    // Limit batch size
    if (updates.length > 50) {
      return res.status(400).json({ error: 'Maximum 50 updates per batch' });
    }

    const results = [];
    const errors = [];

    for (const update of updates) {
      const {
        announcement_id,
        user_id,
        action,
        session_number,
        defer_sessions,
        defer_hours,
        questions_answered,
      } = update;
      const safeSessionNumber = clampInt32(session_number);
      const safeDeferSessions = clampInt32(defer_sessions);
      const safeDeferHours = clampInt32(defer_hours);
      const safeQuestionsAnswered = clampInt32(questions_answered);

      if (!announcement_id || (!v2Decision.enabled && !user_id) || !action) {
        errors.push({ update, error: 'Missing required fields' });
        continue;
      }

      try {
        const targetUserId = v2Decision.enabled ? v2Decision.authUid! : user_id;
        const client =
          v2Decision.enabled && req.headers.authorization
            ? getSupabaseAnonClientWithAuth((req.headers.authorization as string).replace(/^Bearer\s+/i, '').trim())
            : supabase;

        if (action === 'impression') {
          console.log(
            JSON.stringify({
              scope: 'announcements/state',
              requestId,
              mode: v2Decision.enabled ? 'secure' : 'legacy',
              action: 'impression',
              session_number_raw: session_number ?? null,
              session_number_clamped: safeSessionNumber,
              batch: true,
            })
          );
          await client.rpc('record_announcement_impression', {
            p_announcement_id: announcement_id,
            p_user_id: targetUserId,
            p_session_number: safeSessionNumber,
          });
          results.push({ announcement_id, action, success: true, mode: v2Decision.enabled ? 'v2' : 'legacy' });
        } else {
          const statusMap: Record<string, string> = {
            seen: 'seen',
            dismissed: 'dismissed',
            deferred: 'deferred',
            completed: 'completed',
          };

          const status = statusMap[action];
          if (status) {
            await client.rpc('update_announcement_state', {
              p_announcement_id: announcement_id,
              p_user_id: targetUserId,
              p_status: status,
              p_session_number: safeSessionNumber,
              p_defer_sessions: safeDeferSessions,
              p_defer_hours: safeDeferHours,
              p_questions_answered: safeQuestionsAnswered,
            });
            results.push({ announcement_id, action, success: true, mode: v2Decision.enabled ? 'v2' : 'legacy' });
          } else {
            errors.push({ update, error: 'Invalid action' });
          }
        }
      } catch (e: any) {
        errors.push({ update, error: 'Failed to process update' });
      }
    }

    return res.status(200).json({
      success: errors.length === 0,
      results,
      errors: errors.length > 0 ? errors : undefined,
      summary: {
        total: updates.length,
        succeeded: results.length,
        failed: errors.length,
      },
    });
  } catch (error: any) {
    console.error('[API] Batch state update error');
    return res.status(500).json({ error: 'Internal server error' });
  }
}
