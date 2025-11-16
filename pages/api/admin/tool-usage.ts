import type { NextApiRequest, NextApiResponse } from 'next';
import { getSupabaseAdmin } from '../../../lib/supabaseAdmin';
import { requireAdminApi } from '../../../lib/adminAuth';
import type { ToolDrilldownResponse, ToolLeaderboardResponse } from '../../../types/admin';

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

  try {
    // Leaderboard (always fetched; reused for drilldowns)
    const leaderboardResult = await supabase.rpc('get_tool_usage_leaderboard', { p_days: days });
    if (leaderboardResult.error) {
      console.error('tool-usage leaderboard error', leaderboardResult.error);
      return res.status(500).json({ error: 'Failed to load tool usage leaderboard' });
    }

    const leaderboardRows = (leaderboardResult.data ?? []).map((row: any) => ({
      toolId: row.tool_id,
      toolName: row.tool_name ?? row.tool_id,
      events: Number(row.events ?? 0),
      uniqueUsers: Number(row.unique_users ?? 0),
      uniqueSessions: Number(row.unique_sessions ?? 0),
      countries: Number(row.countries ?? 0),
      lastEventAt: row.last_event_at ?? null,
    }));

    if (!toolId) {
      const response: ToolLeaderboardResponse = { tools: leaderboardRows };
      return res.status(200).json(response);
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

    const [countriesResult, citiesResult, dailyResult] = await Promise.all([
      supabase.rpc('get_tool_usage_countries', { p_tool_id: toolId, p_days: days, p_limit: 10 }),
      supabase.rpc('get_tool_usage_cities', { p_tool_id: toolId, p_days: days, p_limit: 10 }),
      supabase.rpc('get_tool_usage_daily', { p_tool_id: toolId, p_days: days }),
    ]);

    const firstError = countriesResult.error || citiesResult.error || dailyResult.error;
    if (firstError) {
      console.error('tool-usage drilldown error', firstError);
      return res.status(500).json({ error: 'Failed to load tool drilldown' });
    }

    const topCountries = (countriesResult.data ?? []).map((row: any) => ({
      country: row.country ?? 'Unknown',
      events: Number(row.events ?? 0),
      uniqueUsers: Number(row.unique_users ?? 0),
      uniqueSessions: Number(row.unique_sessions ?? 0),
      lastEventAt: row.last_event_at ?? null,
    }));

    const topCities = (citiesResult.data ?? []).map((row: any) => ({
      country: row.country ?? 'Unknown',
      city: row.city ?? 'Unknown',
      events: Number(row.events ?? 0),
      uniqueUsers: Number(row.unique_users ?? 0),
      uniqueSessions: Number(row.unique_sessions ?? 0),
      lastEventAt: row.last_event_at ?? null,
    }));

    const daily = (dailyResult.data ?? []).map((row: any) => ({
      date: row.usage_date,
      events: Number(row.events ?? 0),
      uniqueUsers: Number(row.unique_users ?? 0),
      uniqueSessions: Number(row.unique_sessions ?? 0),
    }));

    // Build per-country trend for the top 3 countries
    const topCountryNames = topCountries.slice(0, 3).map((c) => c.country);
    let countrySeries: ToolDrilldownResponse['countrySeries'] = [];

    if (topCountryNames.length > 0) {
      const seriesResult = await supabase.rpc('get_tool_usage_daily_by_country', {
        p_tool_id: toolId,
        p_days: days,
        p_countries: topCountryNames,
      });

      if (seriesResult.error) {
        console.error('tool-usage country series error', seriesResult.error);
      } else {
        const grouped: Record<string, { country: string; points: { date: string; events: number }[] }> = {};
        for (const row of seriesResult.data ?? []) {
          const country = row.country ?? 'Unknown';
          if (!grouped[country]) {
            grouped[country] = { country, points: [] };
          }
          grouped[country].points.push({
            date: row.usage_date,
            events: Number(row.events ?? 0),
          });
        }
        countrySeries = Object.values(grouped).map((g) => ({
          country: g.country,
          points: g.points.sort((a, b) => a.date.localeCompare(b.date)),
        }));
      }
    }

    const response: ToolDrilldownResponse = {
      summary,
      topCountries,
      topCities,
      daily,
      countrySeries,
    };

    return res.status(200).json(response);
  } catch (error) {
    console.error('tool-usage unhandled error', error);
    return res.status(500).json({ error: 'Unexpected error' });
  }
}
