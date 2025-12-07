import type { NextApiRequest, NextApiResponse } from 'next';
import { getSupabaseAdmin } from '../../../lib/supabaseAdmin';
import { requireAdminApi } from '../../../lib/adminAuth';

const clampDays = (value: string | string[] | undefined): number => {
  const parsed = Array.isArray(value) ? parseInt(value[0] ?? '', 10) : parseInt(value ?? '', 10);
  if (Number.isNaN(parsed) || parsed <= 0) return 30;
  return Math.min(parsed, 365);
};

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method !== 'GET') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  const adminSession = requireAdminApi(req, res);
  if (!adminSession) return;

  const supabase = getSupabaseAdmin();
  const days = clampDays(req.query.days);
  const toolId = typeof req.query.toolId === 'string' ? req.query.toolId : undefined;

  const sinceDate = new Date();
  sinceDate.setDate(sinceDate.getDate() - days);
  const sinceIso = sinceDate.toISOString();

  try {
    // Get all tool usage events
    const { data: events, error } = await supabase
      .from('tool_usage_events')
      .select('*')
      .gte('created_at', sinceIso);

    if (error) {
      console.error('[tool-usage] Query error:', error);
      return res.status(500).json({ error: 'Failed to load tool usage' });
    }

    const toolEvents = events ?? [];

    // Build leaderboard from events
    const toolMap = new Map<string, { 
      events: number; 
      users: Set<string>; 
      sessions: Set<string>; 
      countries: Set<string>;
      lastAt: string | null 
    }>();

    for (const event of toolEvents) {
      if (!toolMap.has(event.tool_id)) {
        toolMap.set(event.tool_id, { 
          events: 0, 
          users: new Set(), 
          sessions: new Set(), 
          countries: new Set(),
          lastAt: null 
        });
      }
      const tool = toolMap.get(event.tool_id)!;
      tool.events++;
      tool.users.add(event.user_id);
      if (event.app_session_id) tool.sessions.add(event.app_session_id);
      if (!tool.lastAt || event.created_at > tool.lastAt) tool.lastAt = event.created_at;
    }

    const leaderboardRows = Array.from(toolMap.entries())
      .map(([id, data]) => ({
        toolId: id,
        toolName: id,
        events: data.events,
        uniqueUsers: data.users.size,
        uniqueSessions: data.sessions.size,
        countries: data.countries.size,
        lastEventAt: data.lastAt,
      }))
      .sort((a, b) => b.events - a.events);

    if (!toolId) {
      return res.status(200).json({ tools: leaderboardRows });
    }

    // Drilldown for a specific tool
    const summary = leaderboardRows.find((r) => r.toolId === toolId) ?? {
      toolId,
      toolName: toolId,
      events: 0,
      uniqueUsers: 0,
      uniqueSessions: 0,
      countries: 0,
      lastEventAt: null,
    };

    // Filter events for this tool
    const toolSpecificEvents = toolEvents.filter(e => e.tool_id === toolId);

    // For drilldown, we'd need session data to get country/city info
    // For now, return empty arrays since we don't have that join
    const response = {
      summary,
      topCountries: [],
      topCities: [],
      daily: [],
      countrySeries: [],
    };

    return res.status(200).json(response);
  } catch (error) {
    console.error('[tool-usage] Unexpected error:', error);
    return res.status(500).json({ error: 'Unexpected error' });
  }
}
