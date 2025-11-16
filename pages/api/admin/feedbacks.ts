import type { NextApiRequest, NextApiResponse } from 'next';
import { getSupabaseAdmin } from '../../../lib/supabaseAdmin';
import { requireAdminApi } from '../../../lib/adminAuth';

export interface FeedbackItem {
  id: string;
  type: 'bug' | 'feature' | 'general';
  toolId: string | null;
  toolName: string | null;
  userId: string;
  userName: string | null;
  message: string;
  rating: number | null;
  metadata: Record<string, any> | null;
  submittedAt: string;
}

export interface FeedbacksResponse {
  feedbacks: FeedbackItem[];
  total: number;
}

const clampDays = (value: string | string[] | undefined): number => {
  const parsed = Array.isArray(value) ? parseInt(value[0] ?? '', 10) : parseInt(value ?? '', 10);
  if (Number.isNaN(parsed) || parsed <= 0) {
    return 30;
  }
  return Math.min(parsed, 365);
};

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method !== 'GET') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  const adminSession = requireAdminApi(req, res);
  if (!adminSession) {
    return null;
  }

  try {
    const days = clampDays(req.query.days);
    const sinceDate = new Date();
    sinceDate.setDate(sinceDate.getDate() - days);
    const sinceIso = sinceDate.toISOString();

    const supabase = getSupabaseAdmin();

    // Fetch feedbacks with user and tool information
    // Fetch feedbacks without relying on FK-based joins (schema-safe)
    const { data: feedbacksData, error: feedbacksError } = await supabase
      .from('feedbacks')
      .select('id,type,tool_id,user_id,message,rating,metadata,submitted_at')
      .gte('submitted_at', sinceIso)
      .order('submitted_at', { ascending: false });

    if (feedbacksError) {
      console.error('Feedbacks query error:', feedbacksError);
      return res.status(500).json({ error: 'Failed to load feedbacks' });
    }

    // Resolve tool names separately (best-effort); ignore errors to keep data flowing
    const toolIds = Array.from(new Set((feedbacksData ?? []).map((f: any) => f.tool_id).filter(Boolean)));
    let toolNameMap: Record<string, string> = {};
    if (toolIds.length > 0) {
      const { data: toolRows, error: toolsError } = await supabase
        .from('tool_catalog')
        .select('tool_id,display_name')
        .in('tool_id', toolIds);
      if (!toolsError && toolRows) {
        toolNameMap = Object.fromEntries(toolRows.map((t: any) => [t.tool_id, t.display_name || t.tool_id]));
      } else if (toolsError) {
        console.warn('Tool catalog lookup failed (continuing without names):', toolsError.message);
      }
    }

    const feedbacks: FeedbackItem[] = (feedbacksData ?? []).map((row: any) => ({
      id: row.id,
      type: row.type ?? 'general',
      toolId: row.tool_id ?? null,
      toolName: row.tool_id ? toolNameMap[row.tool_id] ?? row.tool_id : null,
      userId: row.user_id,
      userName: null, // left null until we add a safe user lookup; prevents FK errors
      message: row.message,
      rating: row.rating ? Number(row.rating) : null,
      metadata: row.metadata ?? null,
      submittedAt: row.submitted_at,
    }));

    const response: FeedbacksResponse = {
      feedbacks,
      total: feedbacks.length,
    };

    return res.status(200).json(response);
  } catch (error) {
    console.error('Feedbacks endpoint error:', error);
    return res.status(500).json({ error: 'Unexpected error' });
  }
}
