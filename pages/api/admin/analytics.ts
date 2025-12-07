import type { NextApiRequest, NextApiResponse } from 'next';
import { getSupabaseAdmin } from '../../../lib/supabaseAdmin';
import { requireAdminApi } from '../../../lib/adminAuth';

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
    const sinceIso = sinceDate.toISOString();

    const supabase = getSupabaseAdmin();

    // Query actual tables directly instead of RPC functions
    const [
      usersResult,
      sessionsResult,
      toolEventsResult,
      feedbacksResult,
      announcementsResult,
    ] = await Promise.all([
      supabase.from('users').select('auth_uid, created_at', { count: 'exact' }),
      supabase.from('app_sessions').select('*').gte('created_at', sinceIso).order('created_at', { ascending: false }).limit(50),
      supabase.from('tool_usage_events').select('*').gte('created_at', sinceIso),
      supabase.from('feedbacks').select('*').gte('created_at', sinceIso),
      supabase.from('announcements').select('*').eq('is_deleted', false).order('created_at', { ascending: false }).limit(10),
    ]);

    // Log any errors for debugging
    if (usersResult.error) console.error('[analytics] users error:', usersResult.error);
    if (sessionsResult.error) console.error('[analytics] sessions error:', sessionsResult.error);
    if (toolEventsResult.error) console.error('[analytics] tool_events error:', toolEventsResult.error);
    if (feedbacksResult.error) console.error('[analytics] feedbacks error:', feedbacksResult.error);
    if (announcementsResult.error) console.error('[analytics] announcements error:', announcementsResult.error);

    const users = usersResult.data ?? [];
    const sessions = sessionsResult.data ?? [];
    const toolEvents = toolEventsResult.data ?? [];
    const feedbacks = feedbacksResult.data ?? [];
    const announcements = announcementsResult.data ?? [];

    // Calculate overview metrics
    const uniqueCountries = new Set(sessions.map(s => s.country).filter(Boolean));
    const uniqueActiveUsers = new Set(sessions.map(s => s.user_id));

    const overview = {
      totalUsers: usersResult.count ?? users.length,
      activeUsers: uniqueActiveUsers.size,
      sessionCount: sessions.length,
      avgSessionDurationSeconds: 0,
      toolEventCount: toolEvents.length,
      feedbackCount: feedbacks.length,
      countryCount: uniqueCountries.size,
      lastActivity: sessions[0]?.created_at ?? null,
    };

    // Build location breakdown
    const locationMap = new Map<string, { country: string; city: string; count: number; users: Set<string> }>();
    for (const session of sessions) {
      const key = `${session.country || 'Unknown'}|${session.city || 'Unknown'}`;
      if (!locationMap.has(key)) {
        locationMap.set(key, { country: session.country || 'Unknown', city: session.city || 'Unknown', count: 0, users: new Set() });
      }
      const loc = locationMap.get(key)!;
      loc.count++;
      loc.users.add(session.user_id);
    }
    const locationBreakdown = Array.from(locationMap.values())
      .map(loc => ({
        country: loc.country,
        city: loc.city,
        sessionCount: loc.count,
        uniqueUsers: loc.users.size,
        lastSessionAt: null,
      }))
      .sort((a, b) => b.sessionCount - a.sessionCount)
      .slice(0, 15);

    // Build tool usage leaderboard
    const toolMap = new Map<string, { events: number; users: Set<string>; sessions: Set<string>; lastAt: string | null }>();
    for (const event of toolEvents) {
      if (!toolMap.has(event.tool_id)) {
        toolMap.set(event.tool_id, { events: 0, users: new Set(), sessions: new Set(), lastAt: null });
      }
      const tool = toolMap.get(event.tool_id)!;
      tool.events++;
      tool.users.add(event.user_id);
      if (event.app_session_id) tool.sessions.add(event.app_session_id);
      if (!tool.lastAt || event.created_at > tool.lastAt) tool.lastAt = event.created_at;
    }
    const topTools = Array.from(toolMap.entries())
      .map(([toolId, data]) => ({
        toolId,
        toolName: toolId,
        totalEvents: data.events,
        openEvents: 0,
        closeEvents: 0,
        calculateEvents: 0,
        saveEvents: 0,
        errorEvents: 0,
        totalSessions: data.sessions.size,
        uniqueUsers: data.users.size,
        totalDurationSeconds: 0,
        lastUsedAt: data.lastAt,
      }))
      .sort((a, b) => b.totalEvents - a.totalEvents)
      .slice(0, 12);

    // Build feedback summary
    const feedbackMap = new Map<string, { count: number; ratings: number[]; lastAt: string | null }>();
    for (const fb of feedbacks) {
      const type = fb.type || 'general';
      if (!feedbackMap.has(type)) {
        feedbackMap.set(type, { count: 0, ratings: [], lastAt: null });
      }
      const entry = feedbackMap.get(type)!;
      entry.count++;
      if (fb.rating) entry.ratings.push(fb.rating);
      if (!entry.lastAt || fb.created_at > entry.lastAt) entry.lastAt = fb.created_at;
    }
    const feedbackSummary = Array.from(feedbackMap.entries())
      .map(([type, data]) => ({
        feedbackType: type,
        feedbackCount: data.count,
        avgRating: data.ratings.length > 0 ? data.ratings.reduce((a, b) => a + b, 0) / data.ratings.length : null,
        lastFeedbackAt: data.lastAt,
      }))
      .sort((a, b) => b.feedbackCount - a.feedbackCount);

    // Build a map of user_id -> user name
    const userNameMap = new Map<string, string>();
    for (const user of users) {
      const name = user.name || user.email?.split('@')[0] || null;
      if (name) {
        userNameMap.set(user.auth_uid, name);
        userNameMap.set(user.user_id, name);
      }
    }

    const response = {
      overview,
      timeline: [],
      topTools,
      locationBreakdown,
      feedbackSummary,
      recentSessions: sessions.slice(0, 30).map(s => ({
        id: s.id,
        userId: s.user_id,
        userName: userNameMap.get(s.user_id) || userNameMap.get(s.auth_uid) || s.user_id?.substring(0, 8) || 'Unknown',
        country: s.country,
        city: s.city,
        region: s.region,
        appVersion: s.app_version,
        startTime: s.start_time,
        endTime: s.end_time,
        durationSeconds: 0,
      })),
      announcements: announcements.map(a => ({
        id: a.id,
        title: a.title,
        severity: a.importance === 'high' ? 'critical' : a.importance === 'medium' ? 'warning' : 'info',
        status: a.is_active ? 'published' : 'draft',
        publishedAt: a.start_at,
        expiresAt: a.end_at,
      })),
    };

    return res.status(200).json(response);
  } catch (error) {
    console.error('[analytics] Unexpected error:', error);
    return res.status(500).json({ error: 'Unexpected analytics error' });
  }
}
