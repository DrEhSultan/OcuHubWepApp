import type { NextApiRequest, NextApiResponse } from 'next';
import { createClient } from '@supabase/supabase-js';
import { setAdminCookie, signAdminToken } from '../../../lib/adminAuth';
import type { AdminSession } from '../../../types/admin';

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  console.log('[admin/google-auth] Starting Google auth verification');

  try {
    const { access_token } = req.body;

    if (!access_token) {
      console.log('[admin/google-auth] No access_token provided');
      return res.status(400).json({ error: 'Missing access_token' });
    }

    // Create a Supabase client with the user's access token to get their info
    const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
    const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;
    const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

    if (!supabaseUrl || !supabaseAnonKey || !serviceRoleKey) {
      console.error('[admin/google-auth] Missing Supabase env vars');
      return res.status(500).json({ error: 'Server configuration error' });
    }

    // Get user from the access token
    const userClient = createClient(supabaseUrl, supabaseAnonKey, {
      global: { headers: { Authorization: `Bearer ${access_token}` } },
    });

    const { data: userData, error: userError } = await userClient.auth.getUser();

    if (userError || !userData.user) {
      console.error('[admin/google-auth] Failed to get user:', userError);
      return res.status(401).json({ error: 'Invalid session' });
    }

    console.log('[admin/google-auth] User ID:', userData.user.id);
    console.log('[admin/google-auth] User email:', userData.user.email);

    // Use service role to check admin_users table
    const adminClient = createClient(supabaseUrl, serviceRoleKey, {
      auth: { persistSession: false },
    });

    const { data: adminUser, error: adminError } = await adminClient
      .from('admin_users')
      .select('id, user_id, email, display_name, role, is_active')
      .eq('user_id', userData.user.id)
      .eq('is_active', true)
      .maybeSingle();

    console.log('[admin/google-auth] Admin query result:', { adminUser, adminError });

    if (adminError) {
      console.error('[admin/google-auth] Admin query failed:', adminError);
      return res.status(500).json({ error: 'Failed to verify admin access' });
    }

    if (!adminUser) {
      console.log('[admin/google-auth] User not in admin_users table');
      return res.status(403).json({ error: 'Not authorized as admin' });
    }

    // Create admin session
    const sessionPayload: AdminSession = {
      id: adminUser.id,
      email: adminUser.email,
      role: adminUser.role,
      displayName: adminUser.display_name || adminUser.email,
    };

    const token = signAdminToken(sessionPayload);
    setAdminCookie(res, token);

    // Update last login
    await adminClient
      .from('admin_users')
      .update({ last_login_at: new Date().toISOString() })
      .eq('id', adminUser.id);

    console.log('[admin/google-auth] Login successful for:', adminUser.email);
    return res.status(200).json({ success: true });
  } catch (error) {
    console.error('[admin/google-auth] Unexpected error:', error);
    return res.status(500).json({ error: 'Unexpected error' });
  }
}
