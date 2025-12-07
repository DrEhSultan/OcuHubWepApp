import type { NextApiRequest, NextApiResponse } from 'next';
import { getSupabaseAdmin } from '../../../lib/supabaseAdmin';
import { requireAdminApi } from '../../../lib/adminAuth';

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  const adminSession = requireAdminApi(req, res);
  if (!adminSession) return null;

  const supabase = getSupabaseAdmin();

  // GET all announcements
  if (req.method === 'GET') {
    try {
      const { data, error } = await supabase
        .from('announcements')
        .select('*')
        .eq('is_deleted', false)
        .order('created_at', { ascending: false });

      if (error) {
        console.error('[announcements] Query error:', error);
        return res.status(500).json({ error: 'Failed to load announcements' });
      }

      return res.status(200).json({ announcements: data || [], total: data?.length || 0 });
    } catch (error) {
      console.error('[announcements] GET error:', error);
      return res.status(500).json({ error: 'Unexpected error' });
    }
  }

  // POST - Create new announcement
  if (req.method === 'POST') {
    try {
      const body = req.body;
      
      // Build metadata object
      const metadata: Record<string, any> = {};
      if (body.thumbnail) metadata.thumbnail = body.thumbnail;
      if (body.image_url) metadata.image_url = body.image_url;
      if (body.cta_label) metadata.cta_label = body.cta_label;
      if (body.background_color) metadata.background_color = body.background_color;
      if (body.text_color) metadata.text_color = body.text_color;

      const insertData = {
        title: body.title,
        message: body.message || null,
        kind: body.kind || 'announcement',
        surface: body.surface || 'home_banner',
        importance: body.importance || 'medium',
        action_type: body.action_type || 'none',
        action_value: body.action_value || null,
        start_at: body.start_at ? new Date(body.start_at).toISOString() : new Date().toISOString(),
        end_at: body.end_at ? new Date(body.end_at).toISOString() : null,
        is_active: body.is_active !== false,
        dismissible: body.dismissible !== false,
        repeat_mode: body.repeat_mode || 'once',
        repeat_interval_hours: body.repeat_interval_hours || null,
        max_times_seen_per_user: body.max_times_seen_per_user || null,
        target_country: body.target_country || null,
        target_speciality: body.target_speciality || null,
        target_min_app_version: body.target_min_app_version || null,
        target_max_app_version: body.target_max_app_version || null,
        target_logged_in_only: body.target_logged_in_only || false,
        target_anonymous_only: body.target_anonymous_only || false,
        metadata: metadata,
        questions: body.questions || [],
        created_by: adminSession.id,
      };

      const { data, error } = await supabase
        .from('announcements')
        .insert(insertData)
        .select('*')
        .single();

      if (error) {
        console.error('[announcements] Create error:', error);
        return res.status(500).json({ error: error.message || 'Failed to create announcement' });
      }

      return res.status(201).json(data);
    } catch (error) {
      console.error('[announcements] POST error:', error);
      return res.status(500).json({ error: 'Unexpected error' });
    }
  }

  // PUT - Update announcement
  if (req.method === 'PUT') {
    try {
      const { id } = req.query;
      if (typeof id !== 'string') {
        return res.status(400).json({ error: 'Invalid announcement ID' });
      }

      const body = req.body;
      
      // Build metadata object
      const metadata: Record<string, any> = {};
      if (body.thumbnail) metadata.thumbnail = body.thumbnail;
      if (body.image_url) metadata.image_url = body.image_url;
      if (body.cta_label) metadata.cta_label = body.cta_label;
      if (body.background_color) metadata.background_color = body.background_color;
      if (body.text_color) metadata.text_color = body.text_color;

      const updateData: Record<string, any> = {
        updated_by: adminSession.id,
      };

      // Only include fields that were provided
      if (body.title !== undefined) updateData.title = body.title;
      if (body.message !== undefined) updateData.message = body.message;
      if (body.kind !== undefined) updateData.kind = body.kind;
      if (body.surface !== undefined) updateData.surface = body.surface;
      if (body.importance !== undefined) updateData.importance = body.importance;
      if (body.action_type !== undefined) updateData.action_type = body.action_type;
      if (body.action_value !== undefined) updateData.action_value = body.action_value;
      if (body.start_at !== undefined) updateData.start_at = body.start_at ? new Date(body.start_at).toISOString() : null;
      if (body.end_at !== undefined) updateData.end_at = body.end_at ? new Date(body.end_at).toISOString() : null;
      if (body.is_active !== undefined) updateData.is_active = body.is_active;
      if (body.dismissible !== undefined) updateData.dismissible = body.dismissible;
      if (body.repeat_mode !== undefined) updateData.repeat_mode = body.repeat_mode;
      if (body.repeat_interval_hours !== undefined) updateData.repeat_interval_hours = body.repeat_interval_hours;
      if (body.max_times_seen_per_user !== undefined) updateData.max_times_seen_per_user = body.max_times_seen_per_user;
      if (body.target_country !== undefined) updateData.target_country = body.target_country || null;
      if (body.target_speciality !== undefined) updateData.target_speciality = body.target_speciality || null;
      if (body.target_min_app_version !== undefined) updateData.target_min_app_version = body.target_min_app_version || null;
      if (body.target_max_app_version !== undefined) updateData.target_max_app_version = body.target_max_app_version || null;
      if (body.target_logged_in_only !== undefined) updateData.target_logged_in_only = body.target_logged_in_only;
      if (body.target_anonymous_only !== undefined) updateData.target_anonymous_only = body.target_anonymous_only;
      if (Object.keys(metadata).length > 0) updateData.metadata = metadata;
      if (body.questions !== undefined) updateData.questions = body.questions;

      const { data, error } = await supabase
        .from('announcements')
        .update(updateData)
        .eq('id', id)
        .select('*')
        .single();

      if (error) {
        console.error('[announcements] Update error:', error);
        return res.status(500).json({ error: error.message || 'Failed to update announcement' });
      }

      return res.status(200).json(data);
    } catch (error) {
      console.error('[announcements] PUT error:', error);
      return res.status(500).json({ error: 'Unexpected error' });
    }
  }


  // DELETE - Soft delete announcement
  if (req.method === 'DELETE') {
    try {
      const { id } = req.query;
      if (typeof id !== 'string') {
        return res.status(400).json({ error: 'Invalid announcement ID' });
      }

      const { error } = await supabase
        .from('announcements')
        .update({ 
          is_deleted: true, 
          deleted_at: new Date().toISOString(), 
          deleted_by: adminSession.id,
          is_active: false,
        })
        .eq('id', id);

      if (error) {
        console.error('[announcements] Delete error:', error);
        return res.status(500).json({ error: error.message || 'Failed to delete announcement' });
      }

      return res.status(204).send(null);
    } catch (error) {
      console.error('[announcements] DELETE error:', error);
      return res.status(500).json({ error: 'Unexpected error' });
    }
  }

  return res.status(405).json({ error: 'Method not allowed' });
}
