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

  console.log('[admin/login] Starting login attempt');

  try {
    const { email, password } = loginSchema.parse(req.body);
    console.log('[admin/login] Email:', email);

    let supabase;
    try {
      supabase = getSupabaseAdmin();
      console.log('[admin/login] Supabase admin client created');
    } catch (envError) {
      console.error('[admin/login] Failed to create Supabase client:', envError);
      return res.status(500).json({ error: 'Server configuration error', details: String(envError) });
    }

    const { data: adminUser, error } = await supabase
      .from('admin_users')
      .select('id,user_id,email,password_hash,display_name,role,is_active')
      .ilike('email', email.trim())
      .maybeSingle();

    console.log('[admin/login] Query result:', { adminUser: adminUser ? { ...adminUser, password_hash: '[REDACTED]' } : null, error });

    if (error) {
      console.error('[admin/login] Admin login query failed:', error);
      return res.status(500).json({ error: 'Failed to verify credentials', details: error.message });
    }

    if (!adminUser) {
      console.log('[admin/login] No admin user found for email:', email);
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    if (!adminUser.is_active) {
      console.log('[admin/login] Admin user is not active');
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    if (!adminUser.password_hash) {
      console.log('[admin/login] Admin user has no password_hash set');
      return res.status(401).json({ error: 'Password not configured for this account' });
    }

    const isValidPassword = await bcrypt.compare(password, adminUser.password_hash);
    console.log('[admin/login] Password valid:', isValidPassword);

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
      console.log('[admin/login] JWT token created');
    } catch (jwtError) {
      console.error('[admin/login] Failed to sign JWT:', jwtError);
      return res.status(500).json({ error: 'Failed to create session', details: String(jwtError) });
    }

    setAdminCookie(res, token);

    // Update last login (don't fail if this errors)
    try {
      await supabase
        .from('admin_users')
        .update({ last_login_at: new Date().toISOString() })
        .eq('id', adminUser.id);
      console.log('[admin/login] Updated last_login_at');
    } catch (updateError) {
      console.warn('[admin/login] Failed to update last_login_at:', updateError);
    }

    console.log('[admin/login] Login successful for:', email);
    return res.status(200).json({ success: true });
  } catch (error) {
    if (error instanceof z.ZodError) {
      console.log('[admin/login] Validation error:', error.issues);
      return res.status(400).json({ error: 'Invalid payload', details: error.issues });
    }

    console.error('[admin/login] Unexpected error:', error);
    return res.status(500).json({ error: 'Unexpected error', details: String(error) });
  }
}
