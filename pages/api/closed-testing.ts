import type { NextApiRequest, NextApiResponse } from 'next';
import { getSupabaseAdmin } from '../../lib/supabaseAdmin';

const allowedPlatforms = ['android', 'ios'] as const;

const normalize = (value?: string) => value?.trim() ?? '';

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  const fullName = normalize((req.body as any)?.fullName);
  const emailRaw = normalize((req.body as any)?.email);
  const country = normalize((req.body as any)?.country);
  const platform = normalize((req.body as any)?.platform).toLowerCase();
  const referralCode = normalize((req.body as any)?.referralCode).toUpperCase();
  const note = normalize((req.body as any)?.note);

  if (!fullName || !emailRaw || !country || !platform || !referralCode) {
    return res.status(400).json({ error: 'Please fill in all required fields.' });
  }

  if (!emailRaw.includes('@')) {
    return res.status(400).json({ error: 'Enter a valid email address.' });
  }

  if (!allowedPlatforms.includes(platform as any)) {
    return res.status(400).json({ error: 'Platform must be android or ios.' });
  }

  try {
    const supabase = getSupabaseAdmin();

    // Optional referrer lookup
    let referrerName: string | null = null;
    let referrerCountry: string | null = null;
    try {
      const { data: refRow } = await supabase
        .from('referral_codes')
        .select('referrer_name,country')
        .ilike('code', referralCode)
        .maybeSingle();
      if (refRow) {
        referrerName = refRow.referrer_name || null;
        referrerCountry = refRow.country || null;
      }
    } catch (lookupErr) {
      console.warn('[closed-testing] Referral lookup failed:', lookupErr);
    }

    const { error } = await supabase.from('closed_testing_signups').insert([
      {
        full_name: fullName,
        email: emailRaw.toLowerCase(),
        country,
        platform,
        referral_code: referralCode,
        note: note || null,
        status: 'pending',
      },
    ]);

    if (error) {
      if (error.code === '23505') {
        return res.status(400).json({ error: 'You are already on the list. We will email you soon.' });
      }
      console.error('[closed-testing] Insert error:', error);
      return res.status(500).json({ error: 'Could not save your request. Please try again.' });
    }

    return res.status(201).json({
      ok: true,
      referral: referrerName ? { name: referrerName, country: referrerCountry } : null,
    });
  } catch (err) {
    console.error('[closed-testing] Unexpected error:', err);
    return res.status(500).json({ error: 'Unexpected server error' });
  }
}
