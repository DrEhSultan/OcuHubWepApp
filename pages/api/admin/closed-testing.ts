import type { NextApiRequest, NextApiResponse } from 'next';
import { getSupabaseAdmin } from '../../../lib/supabaseAdmin';
import { requireAdminApi } from '../../../lib/adminAuth';

const allowedStatuses = ['pending', 'invited', 'activated', 'waitlist', 'declined'] as const;

const normalize = (value?: string | null) => (typeof value === 'string' ? value.trim() : null);

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  const adminSession = requireAdminApi(req, res);
  if (!adminSession) {
    return null;
  }

  const supabase = getSupabaseAdmin();

  if (req.method === 'GET') {
    const { data, error } = await supabase
      .from('closed_testing_signups')
      .select('*')
      .order('created_at', { ascending: false })
      .limit(500);

    if (error) {
      console.error('[admin/closed-testing] Load error:', error);
      return res.status(500).json({ error: 'Failed to load signups' });
    }

    const payload = (data ?? []).map((row: any) => ({
      id: row.id,
      fullName: row.full_name,
      email: row.email,
      country: row.country,
      platform: row.platform,
      referralCode: row.referral_code,
      status: row.status,
      note: row.note,
      invitedBy: row.invited_by,
      invitedAt: row.invited_at,
      emailSentAt: row.email_sent_at,
      createdAt: row.created_at,
    }));

    return res.status(200).json({ signups: payload });
  }

  if (req.method === 'PUT') {
    const { id, status, note, invitedBy, markEmailSent } = (req.body || {}) as {
      id?: string;
      status?: string;
      note?: string;
      invitedBy?: string;
      markEmailSent?: boolean;
    };

    if (!id) {
      return res.status(400).json({ error: 'Missing signup id.' });
    }

    const update: Record<string, any> = {
      updated_at: new Date().toISOString(),
    };

    if (status) {
      if (!allowedStatuses.includes(status as any)) {
        return res.status(400).json({ error: 'Invalid status.' });
      }
      update.status = status;
      if (status === 'invited' || status === 'activated') {
        update.invited_at = new Date().toISOString();
        update.invited_by = invitedBy || adminSession.email;
      }
    }

    if (note !== undefined) {
      update.note = normalize(note);
    }

    if (invitedBy) {
      update.invited_by = invitedBy;
    }

    if (markEmailSent) {
      update.email_sent_at = new Date().toISOString();
    }

    const { data, error } = await supabase
      .from('closed_testing_signups')
      .update(update)
      .eq('id', id)
      .select('*')
      .maybeSingle();

    if (error) {
      console.error('[admin/closed-testing] Update error:', error);
      return res.status(500).json({ error: 'Failed to update signup.' });
    }

    if (!data) {
      return res.status(404).json({ error: 'Signup not found.' });
    }

    return res.status(200).json({
      signup: {
        id: data.id,
        fullName: data.full_name,
        email: data.email,
        country: data.country,
        platform: data.platform,
        referralCode: data.referral_code,
        status: data.status,
        note: data.note,
        invitedBy: data.invited_by,
        invitedAt: data.invited_at,
        emailSentAt: data.email_sent_at,
        createdAt: data.created_at,
      },
    });
  }

  return res.status(405).json({ error: 'Method not allowed' });
}
