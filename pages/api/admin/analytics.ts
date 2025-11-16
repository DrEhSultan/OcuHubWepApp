import type { NextApiRequest, NextApiResponse } from 'next';
import { getSupabaseAdmin } from '../../../lib/supabaseAdmin';
import { requireAdminApi } from '../../../lib/adminAuth';
import type { DashboardResponse } from '../../../types/admin';

const clampDays = (value: string | string[] | undefined): number => {
  const parsed = Array.isArray(value) ? parseInt(value[0] ?? '', 10) : parseInt(value ?? '', 10);
  if (Number.isNaN(parsed) || parsed <= 0) {
    return 30;
  }
  return Math.min(parsed, 180);
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
    const sinceIso = sinceDate.toISOString().split('T')[0];

    const supabase = getSupabaseAdmin();

    const [
      overviewResult,
      timelineResult,
      toolsResult,
      locationResult,
      feedbackResult,
      sessionsResult,
      announcementsResult,
    ] = await Promise.all([
      supabase.rpc('get_admin_overview_metrics', { p_days: days }),
      supabase
        .from('admin_usage_timeline_view')
        .select('*')
        .gte('usage_date', sinceIso)
        .order('usage_date', { ascending: true }),
      supabase
        .from('admin_tool_usage_view')
        .select('*')
        .order('open_events', { ascending: false })
        .limit(12),
      supabase
        .from('admin_location_usage_view')
        .select('*')
        .order('session_count', { ascending: false })
        .limit(15),
      supabase
        .from('admin_feedback_summary_view')
        .select('*')
        .order('feedback_count', { ascending: false }),
      supabase
        .from('admin_recent_sessions_view')
        .select('*')
        .limit(30),
      supabase
        .from('app_announcements')
        .select('id,title,severity,status,published_at,expires_at')
        .order('published_at', { ascending: false })
        .limit(8),
    ]);

    const firstError =
      overviewResult.error ||
      timelineResult.error ||
      toolsResult.error ||
      locationResult.error ||
      feedbackResult.error ||
      sessionsResult.error ||
      announcementsResult.error;

    if (firstError) {
      console.error('Dashboard aggregation error:', firstError);
      return res.status(500).json({ error: 'Failed to load analytics' });
    }

    const overviewRow = overviewResult.data?.[0] ?? null;
    const overview = overviewRow
      ? {
          totalUsers: Number(overviewRow.total_users ?? 0),
          activeUsers: Number(overviewRow.active_users ?? 0),
          sessionCount: Number(overviewRow.session_count ?? 0),
          avgSessionDurationSeconds: Number(overviewRow.avg_session_duration_seconds ?? 0),
          toolEventCount: Number(overviewRow.tool_event_count ?? 0),
          feedbackCount: Number(overviewRow.feedback_count ?? 0),
          countryCount: Number(overviewRow.country_count ?? 0),
          lastActivity: overviewRow.last_activity,
        }
      : null;

    const response: DashboardResponse = {
      overview,
      timeline: (timelineResult.data ?? []).map((row) => ({
        date: row.usage_date,
        activeUsers: Number(row.active_users ?? 0),
        sessionCount: Number(row.session_count ?? 0),
        toolEvents: Number(row.tool_events ?? 0),
      })),
      topTools: (toolsResult.data ?? []).map((row) => ({
        toolId: row.tool_id,
        toolName: row.tool_name ?? row.tool_id,
        totalEvents: Number(row.total_events ?? 0),
        openEvents: Number(row.open_events ?? 0),
        closeEvents: Number(row.close_events ?? 0),
        calculateEvents: Number(row.calculate_events ?? 0),
        saveEvents: Number(row.save_events ?? 0),
        errorEvents: Number(row.error_events ?? 0),
        totalSessions: Number(row.total_sessions ?? 0),
        uniqueUsers: Number(row.unique_users ?? 0),
        totalDurationSeconds: Number(row.total_duration_seconds ?? 0),
        lastUsedAt: row.last_used_at,
      })),
      locationBreakdown: (locationResult.data ?? []).map((row) => ({
        country: row.country ?? 'Unknown',
        city: row.city ?? 'Unknown',
        sessionCount: Number(row.session_count ?? 0),
        uniqueUsers: Number(row.unique_users ?? 0),
        lastSessionAt: row.last_session_at,
      })),
      feedbackSummary: (feedbackResult.data ?? []).map((row) => ({
        feedbackType: row.feedback_type ?? 'general',
        feedbackCount: Number(row.feedback_count ?? 0),
        avgRating: row.avg_rating,
        lastFeedbackAt: row.last_feedback_at,
      })),
      recentSessions: (sessionsResult.data ?? []).map((row) => ({
        id: row.id,
        userId: row.user_id,
        country: row.country,
        city: row.city,
        region: row.region,
        appVersion: row.app_version,
        startTime: row.start_time,
        endTime: row.end_time,
        durationSeconds: Number(row.duration_seconds ?? 0),
      })),
      announcements: (announcementsResult.data ?? []).map((row) => ({
        id: row.id,
        title: row.title,
        severity: row.severity,
        status: row.status,
        publishedAt: row.published_at,
        expiresAt: row.expires_at,
      })),
    };

    return res.status(200).json(response);
  } catch (error) {
    console.error('Dashboard analytics failure', error);
    return res.status(500).json({ error: 'Unexpected analytics error' });
  }
}
