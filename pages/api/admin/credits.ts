import type { NextApiRequest, NextApiResponse } from 'next';
import { getSupabaseAdmin } from '../../../lib/supabaseAdmin';
import { requireAdminApi } from '../../../lib/adminAuth';

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  const adminSession = requireAdminApi(req, res);
  if (!adminSession) return null;

  const supabase = getSupabaseAdmin();

  // GET - Fetch all credits data (asset types, sites, links)
  if (req.method === 'GET') {
    try {
      const { type } = req.query;

      // Fetch specific type
      if (type === 'asset-types') {
        const { data, error } = await supabase
          .from('credit_asset_types')
          .select('*')
          .order('sort_order', { ascending: true });

        if (error) {
          console.error('[credits] Asset types query error:', error);
          return res.status(500).json({ error: 'Failed to load asset types' });
        }
        return res.status(200).json({ assetTypes: data || [] });
      }

      if (type === 'sites') {
        const { assetTypeId } = req.query;
        let query = supabase
          .from('credit_sites')
          .select('*, credit_asset_types(name, display_name)')
          .order('sort_order', { ascending: true });

        if (assetTypeId && typeof assetTypeId === 'string') {
          query = query.eq('asset_type_id', assetTypeId);
        }

        const { data, error } = await query;

        if (error) {
          console.error('[credits] Sites query error:', error);
          return res.status(500).json({ error: 'Failed to load sites' });
        }
        return res.status(200).json({ sites: data || [] });
      }

      if (type === 'links') {
        const { siteId } = req.query;
        let query = supabase
          .from('credit_links')
          .select('*, credit_sites(name, display_name)')
          .order('sort_order', { ascending: true });

        if (siteId && typeof siteId === 'string') {
          query = query.eq('site_id', siteId);
        }

        const { data, error } = await query;

        if (error) {
          console.error('[credits] Links query error:', error);
          return res.status(500).json({ error: 'Failed to load links' });
        }
        return res.status(200).json({ links: data || [] });
      }

      // Default: fetch all data for overview
      const [assetTypesRes, sitesRes, linksRes] = await Promise.all([
        supabase
          .from('credit_asset_types')
          .select('*')
          .order('sort_order', { ascending: true }),
        supabase
          .from('credit_sites')
          .select('*')
          .order('sort_order', { ascending: true }),
        supabase
          .from('credit_links')
          .select('*')
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

      return res.status(200).json({
        assetTypes: assetTypesRes.data || [],
        sites: sitesRes.data || [],
        links: linksRes.data || [],
      });
    } catch (error) {
      console.error('[credits] GET error:', error);
      return res.status(500).json({ error: 'Unexpected error' });
    }
  }

  // POST - Create new asset type, site, or link
  if (req.method === 'POST') {
    try {
      const { type } = req.query;
      const body = req.body;

      if (type === 'asset-type') {
        const { data, error } = await supabase
          .from('credit_asset_types')
          .insert({
            name: body.name,
            display_name: body.display_name,
            description: body.description || null,
            icon: body.icon || null,
            sort_order: body.sort_order || 0,
            is_active: body.is_active !== false,
          })
          .select('*')
          .single();

        if (error) {
          console.error('[credits] Create asset type error:', error);
          return res.status(500).json({ error: error.message || 'Failed to create asset type' });
        }
        return res.status(201).json(data);
      }

      if (type === 'site') {
        const { data, error } = await supabase
          .from('credit_sites')
          .insert({
            asset_type_id: body.asset_type_id,
            name: body.name,
            display_name: body.display_name,
            website_url: body.website_url || null,
            attribution_format: body.attribution_format || null,
            description: body.description || null,
            logo_url: body.logo_url || null,
            sort_order: body.sort_order || 0,
            is_active: body.is_active !== false,
          })
          .select('*')
          .single();

        if (error) {
          console.error('[credits] Create site error:', error);
          return res.status(500).json({ error: error.message || 'Failed to create site' });
        }
        return res.status(201).json(data);
      }

      if (type === 'link') {
        const { data, error } = await supabase
          .from('credit_links')
          .insert({
            site_id: body.site_id,
            title: body.title,
            url: body.url,
            author: body.author || null,
            description: body.description || null,
            sort_order: body.sort_order || 0,
            is_active: body.is_active !== false,
          })
          .select('*')
          .single();

        if (error) {
          console.error('[credits] Create link error:', error);
          return res.status(500).json({ error: error.message || 'Failed to create link' });
        }
        return res.status(201).json(data);
      }

      return res.status(400).json({ error: 'Invalid type parameter' });
    } catch (error) {
      console.error('[credits] POST error:', error);
      return res.status(500).json({ error: 'Unexpected error' });
    }
  }

  // PUT - Update asset type, site, or link
  if (req.method === 'PUT') {
    try {
      const { type, id } = req.query;
      if (typeof id !== 'string') {
        return res.status(400).json({ error: 'Invalid ID' });
      }

      const body = req.body;

      if (type === 'asset-type') {
        const updateData: Record<string, any> = {};
        if (body.name !== undefined) updateData.name = body.name;
        if (body.display_name !== undefined) updateData.display_name = body.display_name;
        if (body.description !== undefined) updateData.description = body.description;
        if (body.icon !== undefined) updateData.icon = body.icon;
        if (body.sort_order !== undefined) updateData.sort_order = body.sort_order;
        if (body.is_active !== undefined) updateData.is_active = body.is_active;

        const { data, error } = await supabase
          .from('credit_asset_types')
          .update(updateData)
          .eq('id', id)
          .select('*')
          .single();

        if (error) {
          console.error('[credits] Update asset type error:', error);
          return res.status(500).json({ error: error.message || 'Failed to update asset type' });
        }
        return res.status(200).json(data);
      }

      if (type === 'site') {
        const updateData: Record<string, any> = {};
        if (body.asset_type_id !== undefined) updateData.asset_type_id = body.asset_type_id;
        if (body.name !== undefined) updateData.name = body.name;
        if (body.display_name !== undefined) updateData.display_name = body.display_name;
        if (body.website_url !== undefined) updateData.website_url = body.website_url;
        if (body.attribution_format !== undefined) updateData.attribution_format = body.attribution_format;
        if (body.description !== undefined) updateData.description = body.description;
        if (body.logo_url !== undefined) updateData.logo_url = body.logo_url;
        if (body.sort_order !== undefined) updateData.sort_order = body.sort_order;
        if (body.is_active !== undefined) updateData.is_active = body.is_active;

        const { data, error } = await supabase
          .from('credit_sites')
          .update(updateData)
          .eq('id', id)
          .select('*')
          .single();

        if (error) {
          console.error('[credits] Update site error:', error);
          return res.status(500).json({ error: error.message || 'Failed to update site' });
        }
        return res.status(200).json(data);
      }

      if (type === 'link') {
        const updateData: Record<string, any> = {};
        if (body.site_id !== undefined) updateData.site_id = body.site_id;
        if (body.title !== undefined) updateData.title = body.title;
        if (body.url !== undefined) updateData.url = body.url;
        if (body.author !== undefined) updateData.author = body.author;
        if (body.description !== undefined) updateData.description = body.description;
        if (body.sort_order !== undefined) updateData.sort_order = body.sort_order;
        if (body.is_active !== undefined) updateData.is_active = body.is_active;

        const { data, error } = await supabase
          .from('credit_links')
          .update(updateData)
          .eq('id', id)
          .select('*')
          .single();

        if (error) {
          console.error('[credits] Update link error:', error);
          return res.status(500).json({ error: error.message || 'Failed to update link' });
        }
        return res.status(200).json(data);
      }

      return res.status(400).json({ error: 'Invalid type parameter' });
    } catch (error) {
      console.error('[credits] PUT error:', error);
      return res.status(500).json({ error: 'Unexpected error' });
    }
  }

  // DELETE - Delete asset type, site, or link
  if (req.method === 'DELETE') {
    try {
      const { type, id } = req.query;
      if (typeof id !== 'string') {
        return res.status(400).json({ error: 'Invalid ID' });
      }

      let tableName = '';
      if (type === 'asset-type') tableName = 'credit_asset_types';
      else if (type === 'site') tableName = 'credit_sites';
      else if (type === 'link') tableName = 'credit_links';
      else return res.status(400).json({ error: 'Invalid type parameter' });

      const { error } = await supabase
        .from(tableName)
        .delete()
        .eq('id', id);

      if (error) {
        console.error(`[credits] Delete ${type} error:`, error);
        return res.status(500).json({ error: error.message || `Failed to delete ${type}` });
      }

      return res.status(204).send(null);
    } catch (error) {
      console.error('[credits] DELETE error:', error);
      return res.status(500).json({ error: 'Unexpected error' });
    }
  }

  return res.status(405).json({ error: 'Method not allowed' });
}
