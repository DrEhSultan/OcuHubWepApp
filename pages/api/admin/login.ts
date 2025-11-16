import type { NextApiRequest, NextApiResponse } from 'next';
import bcrypt from 'bcryptjs';
import { z } from 'zod';
import { getSupabaseAdmin } from '../../../lib/supabaseAdmin';
import { setAdminCookie, signAdminToken } from '../../../lib/adminAuth';
import type { AdminSession } from '../../../types/admin';

const loginSchema = z.object({
  email: z.string().email(),
  password: z.string().min(6),
});

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  try {
    const { email, password } = loginSchema.parse(req.body);
    const supabase = getSupabaseAdmin();

    const { data: adminUser, error } = await supabase
      .from('admin_users')
      .select('id,email,password_hash,display_name,role,is_active')
      .ilike('email', email.trim())
      .maybeSingle();

    if (error) {
      console.error('Admin login query failed', error);
      return res.status(500).json({ error: 'Failed to verify credentials' });
    }

    if (!adminUser || !adminUser.is_active) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    const isValidPassword = await bcrypt.compare(password, adminUser.password_hash);
    if (!isValidPassword) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    const sessionPayload: AdminSession = {
      id: adminUser.id,
      email: adminUser.email,
      role: adminUser.role,
      displayName: adminUser.display_name,
    };

    const token = signAdminToken(sessionPayload);
    setAdminCookie(res, token);

    await Promise.all([
      supabase
        .from('admin_users')
        .update({ last_login_at: new Date().toISOString() })
        .eq('id', adminUser.id),
      supabase.from('admin_audit_logs').insert({
        admin_id: adminUser.id,
        action: 'login',
        details: { user_agent: req.headers['user-agent'] ?? '' },
        ip_address: (req.headers['x-forwarded-for'] as string | undefined)?.split(',')[0]?.trim() ?? req.socket.remoteAddress ?? null,
      }),
    ]);

    return res.status(200).json({ success: true });
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ error: 'Invalid payload' });
    }

    console.error('Admin login error', error);
    return res.status(500).json({ error: 'Unexpected error' });
  }
}
