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
    const { data: feedbacksData, error: feedbacksError } = await supabase
      .from('feedbacks')
      .select(
        `
        id,
        type,
        tool_id,
        user_id,
        message,
        rating,
        metadata,
        submitted_at,
        tool_catalog!left(display_name),
        users!left(display_name)
      `
      )
      .gte('submitted_at', sinceIso)
      .order('submitted_at', { ascending: false });

    if (feedbacksError) {
      console.error('Feedbacks query error:', feedbacksError);
      return res.status(500).json({ error: 'Failed to load feedbacks' });
    }

    // Transform the data to match FeedbackItem interface
    const feedbacks: FeedbackItem[] = (feedbacksData ?? []).map((row: any) => ({
      id: row.id,
      type: row.type ?? 'general',
      toolId: row.tool_id ?? null,
      toolName: row.tool_catalog?.display_name ?? row.tool_id ?? null,
      userId: row.user_id,
      userName: row.users?.display_name ?? null,
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
