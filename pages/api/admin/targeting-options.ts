import type { NextApiRequest, NextApiResponse } from 'next';
import { getSupabaseAdmin } from '../../../lib/supabaseAdmin';
import { requireAdminApi } from '../../../lib/adminAuth';
import { withApiGuards } from '../../../lib/apiGuards';

/**
 * API endpoint to fetch unique targeting options from the database
 * Returns countries and cities that have actual users
 */
async function handler(req: NextApiRequest, res: NextApiResponse) {
  const adminSession = requireAdminApi(req, res);
  if (!adminSession) return null;

  if (req.method !== 'GET') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  const supabase = getSupabaseAdmin();

  try {
    // Fetch unique countries from users table
    const { data: countryData, error: countryError } = await supabase
      .from('users')
      .select('last_country')
      .not('last_country', 'is', null)
      .not('last_country', 'eq', '');

    if (countryError) {
      console.error('[targeting-options] Country query error:', countryError);
    }

    // Fetch unique cities from users table
    const { data: cityData, error: cityError } = await supabase
      .from('users')
      .select('last_city')
      .not('last_city', 'is', null)
      .not('last_city', 'eq', '');

    if (cityError) {
      console.error('[targeting-options] City query error:', cityError);
    }

    // Fetch unique device brands from users table
    const { data: brandData, error: brandError } = await supabase
      .from('users')
      .select('last_device_brand')
      .not('last_device_brand', 'is', null)
      .not('last_device_brand', 'eq', '');

    if (brandError) {
      console.error('[targeting-options] Brand query error:', brandError);
    }

    // Extract unique values and sort alphabetically
    const countries = Array.from(new Set(
      (countryData || [])
        .map(r => r.last_country)
        .filter(Boolean)
    )).sort() as string[];

    const cities = Array.from(new Set(
      (cityData || [])
        .map(r => r.last_city)
        .filter(Boolean)
    )).sort() as string[];

    const deviceBrands = Array.from(new Set(
      (brandData || [])
        .map(r => r.last_device_brand)
        .filter(Boolean)
    )).sort() as string[];

    return res.status(200).json({
      countries,
      cities,
      deviceBrands,
      updatedAt: new Date().toISOString(),
    });
  } catch (error) {
    console.error('[targeting-options] Error:', error);
    return res.status(500).json({ error: 'Failed to fetch targeting options' });
  }
}

export default withApiGuards(handler, { requireCsrf: true });
