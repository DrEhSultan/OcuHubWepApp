import type { NextApiRequest, NextApiResponse } from 'next';
import { getSupabaseAdmin } from '../../../lib/supabaseAdmin';
import { requireAdminApi } from '../../../lib/adminAuth';
import type { AdminUserRow } from '../../../types/admin';

const clampLimit = (value: string | string[] | undefined): number => {
  const parsed = Array.isArray(value) ? parseInt(value[0] ?? '', 10) : parseInt(value ?? '', 10);
  if (Number.isNaN(parsed) || parsed <= 0) {
    return 100;
  }
  return Math.min(parsed, 500);
};

export interface UsersResponse {
  users: AdminUserRow[];
  total: number;
}

export default async function handler(req: NextApiRequest, res: NextApiResponse<UsersResponse | { error: string }>) {
  if (req.method !== 'GET') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  const adminSession = requireAdminApi(req, res);
  if (!adminSession) {
    return null;
  }

  try {
    const limit = clampLimit(req.query.limit);
    const supabase = getSupabaseAdmin();

    // Get users
    const { data: usersData, error: usersError } = await supabase
      .from('users')
      .select('*')
      .order('created_at', { ascending: false })
      .limit(limit);

    if (usersError) {
      console.error('[users] Query error:', usersError);
      return res.status(500).json({ error: 'Failed to load users' });
    }

    // Get all sessions to find last seen and most used location per user
    const { data: sessionsData, error: sessionsError } = await supabase
      .from('app_sessions')
      .select('user_id, country, city, start_time, created_at')
      .order('start_time', { ascending: false });

    if (sessionsError) {
      console.error('[users] Sessions query error:', sessionsError);
    }

    // Build a map of user_id -> { lastSeenAt, mostUsedLocation }
    const userSessionInfo = new Map<string, { 
      lastSeenAt: string | null; 
      country: string | null; 
      city: string | null;
    }>();

    if (sessionsData) {
      // Group sessions by user
      const userSessions = new Map<string, typeof sessionsData>();
      for (const session of sessionsData) {
        if (!userSessions.has(session.user_id)) {
          userSessions.set(session.user_id, []);
        }
        userSessions.get(session.user_id)!.push(session);
      }

      // For each user, find last seen and most used location
      for (const [userId, sessions] of Array.from(userSessions.entries())) {
        // Last seen is the most recent session
        const lastSession = sessions[0];
        const lastSeenAt = lastSession?.start_time || lastSession?.created_at || null;

        // Most used location: count occurrences of each country+city combo
        const locationCounts = new Map<string, { country: string; city: string; count: number }>();
        for (const s of sessions) {
          if (s.country) {
            const key = `${s.country}|${s.city || ''}`;
            if (!locationCounts.has(key)) {
              locationCounts.set(key, { country: s.country, city: s.city || '', count: 0 });
            }
            locationCounts.get(key)!.count++;
          }
        }

        // Find the most used location
        let mostUsedLocation = { country: null as string | null, city: null as string | null };
        let maxCount = 0;
        for (const loc of locationCounts.values()) {
          if (loc.count > maxCount) {
            maxCount = loc.count;
            mostUsedLocation = { country: loc.country, city: loc.city || null };
          }
        }

        userSessionInfo.set(userId, {
          lastSeenAt,
          country: mostUsedLocation.country,
          city: mostUsedLocation.city,
        });
      }
    }

    const users: AdminUserRow[] = (usersData ?? []).map((row: any) => {
      const sessionInfo = userSessionInfo.get(row.auth_uid) || userSessionInfo.get(row.user_id);
      
      return {
        id: row.auth_uid || row.user_id,
        displayName: row.name || row.display_name || null,
        email: row.email || null,
        createdAt: row.created_at,
        lastSeenAt: sessionInfo?.lastSeenAt || row.last_synced_at || null,
        country: sessionInfo?.country || null,
        city: sessionInfo?.city || null,
      };
    });

    return res.status(200).json({
      users,
      total: users.length,
    });
  } catch (err) {
    console.error('[users] Endpoint error:', err);
    return res.status(500).json({ error: 'Unexpected error' });
  }
}
