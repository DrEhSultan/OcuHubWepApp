import type { NextApiRequest, NextApiResponse } from 'next';
import { getSupabaseAdmin } from '../../lib/supabaseAdmin';

/**
 * Public API endpoint for fetching credits data
 * Used by the mobile app to sync credits/acknowledgments
 */
export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  // Only allow GET requests
  if (req.method !== 'GET') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  const supabase = getSupabaseAdmin();

  try {
    // Fetch all active credits data
    const [assetTypesRes, sitesRes, linksRes] = await Promise.all([
      supabase
        .from('credit_asset_types')
        .select('*')
        .eq('is_active', true)
        .order('sort_order', { ascending: true }),
      supabase
        .from('credit_sites')
        .select('*')
        .eq('is_active', true)
        .order('sort_order', { ascending: true }),
      supabase
        .from('credit_links')
        .select('*')
        .eq('is_active', true)
        .order('sort_order', { ascending: true }),
    ]);

    if (assetTypesRes.error || sitesRes.error || linksRes.error) {
      console.error('[credits] Query errors:', {
        assetTypes: assetTypesRes.error,
        sites: sitesRes.error,
        links: linksRes.error,
      });
      return res.status(500).json({ error: 'Failed to load credits data' });
    }

    // Set cache headers for better performance
    res.setHeader('Cache-Control', 'public, s-maxage=3600, stale-while-revalidate=86400');

    return res.status(200).json({
      assetTypes: assetTypesRes.data || [],
      sites: sitesRes.data || [],
      links: linksRes.data || [],
      lastUpdated: new Date().toISOString(),
    });
  } catch (error) {
    console.error('[credits] GET error:', error);
    return res.status(500).json({ error: 'Unexpected error' });
  }
}
