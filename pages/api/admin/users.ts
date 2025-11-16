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

    const { data: usersData, error } = await supabase
      .from('users')
      // Select all columns to remain forwards-compatible if schema evolves
      .select('*')
      .order('created_at', { ascending: false })
      .limit(limit);

    if (error) {
      console.error('Users query error:', error);
      return res.status(500).json({ error: 'Failed to load users' });
    }

    const users: AdminUserRow[] = (usersData ?? []).map((row: any) => ({
      id: row.id,
      displayName: row.display_name ?? null,
      email: row.email ?? null,
      createdAt: row.created_at,
      lastSeenAt: row.last_seen_at ?? row.last_session_at ?? null,
      country: row.country ?? null,
      city: row.city ?? null,
    }));

    return res.status(200).json({
      users,
      total: users.length,
    });
  } catch (err) {
    console.error('Users endpoint error:', err);
    return res.status(500).json({ error: 'Unexpected error' });
  }
}
