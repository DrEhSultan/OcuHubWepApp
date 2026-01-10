import type { NextApiRequest, NextApiResponse } from 'next';
import bcrypt from 'bcryptjs';
import { z } from 'zod';
import { getSupabaseAdmin } from '../../../lib/supabaseAdmin';
import { setAdminCookie, signAdminToken } from '../../../lib/adminAuth';
import type { AdminSession } from '../../../types/admin';
import { withApiGuards } from '../../../lib/apiGuards';

const loginSchema = z.object({
  email: z.string().email(),
  password: z.string().min(6),
});

async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  try {
    const { email, password } = loginSchema.parse(req.body);

    let supabase;
    try {
      supabase = getSupabaseAdmin();
    } catch (envError) {
      console.error('[admin/login] Failed to create Supabase client');
      return res.status(500).json({ error: 'Server configuration error' });
    }

    const { data: adminUser, error } = await supabase
      .from('admin_users')
      .select('id,user_id,email,password_hash,display_name,role,is_active')
      .ilike('email', email.trim())
      .maybeSingle();

    if (error) {
      console.error('[admin/login] Admin login query failed');
      return res.status(500).json({ error: 'Failed to verify credentials' });
    }

    if (!adminUser) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    if (!adminUser.is_active) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    if (!adminUser.password_hash) {
      return res.status(401).json({ error: 'Password not configured for this account' });
    }

    const isValidPassword = await bcrypt.compare(password, adminUser.password_hash);

    if (!isValidPassword) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    const sessionPayload: AdminSession = {
      id: adminUser.id,
      email: adminUser.email,
      role: adminUser.role,
      displayName: adminUser.display_name || adminUser.email,
    };

    let token;
    try {
      token = signAdminToken(sessionPayload);
    } catch (jwtError) {
      console.error('[admin/login] Failed to sign JWT');
      return res.status(500).json({ error: 'Failed to create session' });
    }

    setAdminCookie(res, token);

    // Update last login (don't fail if this errors)
    try {
      await supabase
        .from('admin_users')
        .update({ last_login_at: new Date().toISOString() })
        .eq('id', adminUser.id);
    } catch (updateError) {
      console.warn('[admin/login] Failed to update last_login_at');
    }

    return res.status(200).json({ success: true });
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ error: 'Invalid payload', details: error.issues });
    }

    console.error('[admin/login] Unexpected error');
    return res.status(500).json({ error: 'Unexpected error' });
  }
}

export default withApiGuards(handler, { requireCsrf: true });
