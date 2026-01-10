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
import { createClient } from '@supabase/supabase-js';
import { withApiGuards } from '../../../lib/apiGuards';
import { getSupabaseAnonClientWithAuth, shouldUseAnnouncementV2 } from '../../../lib/announcementV2';

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!
);

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
  if (req.method === 'POST') {
    return handleSingleUpdate(req, res);
  } else if (req.method === 'PUT') {
    return handleBatchUpdate(req, res);
  } else {
    return res.status(405).json({ error: 'Method not allowed' });
  }
}

export default withApiGuards(handler);

async function handleSingleUpdate(req: NextApiRequest, res: NextApiResponse) {
  const v2Decision = await shouldUseAnnouncementV2(req);
  if (v2Decision.enabled) {
    console.log('[announcements/state] allowlisted user -> secure path (single)');
    return handleV2SingleUpdate(req, res, v2Decision.authUid!);
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

    // Handle impression separately (lightweight)
    if (action === 'impression') {
      const { error } = await supabase.rpc('record_announcement_impression', {
        p_announcement_id: announcement_id,
        p_user_id: user_id,
        p_session_number: session_number || null,
      });

      if (error) {
        console.error('[API] record_impression error:', error);
        return res.status(500).json({ error: error.message });
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
      p_session_number: session_number,
      p_defer_sessions: defer_sessions,
      p_defer_hours: defer_hours,
      p_questions_answered: questions_answered,
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

async function handleV2SingleUpdate(req: NextApiRequest, res: NextApiResponse, authUid: string) {
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

    if (action === 'impression') {
      const { error } = await supabase.rpc('record_announcement_impression', {
        p_announcement_id: announcement_id,
        p_user_id: authUid,
        p_session_number: session_number || null,
      });

      if (error) {
        console.error('[API v2] record_impression error');
        return res.status(500).json({ error: 'Internal server error' });
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
      p_session_number: session_number,
      p_defer_sessions: defer_sessions,
      p_defer_hours: defer_hours,
      p_questions_answered: questions_answered,
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

async function handleBatchUpdate(req: NextApiRequest, res: NextApiResponse) {
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
          await client.rpc('record_announcement_impression', {
            p_announcement_id: announcement_id,
            p_user_id: targetUserId,
            p_session_number: session_number || null,
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
              p_session_number: session_number,
              p_defer_sessions: defer_sessions,
              p_defer_hours: defer_hours,
              p_questions_answered: questions_answered,
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
