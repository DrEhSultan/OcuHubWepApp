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
      if (body.cta_icon) metadata.cta_icon = body.cta_icon;
      if (body.background_color) metadata.background_color = body.background_color;
      if (body.text_color) metadata.text_color = body.text_color;
      if (body.custom_color) metadata.custom_color = body.custom_color;
      // Survey-specific metadata
      if (body.survey_category) metadata.survey_category = body.survey_category;
      if (body.survey_badge_text) metadata.survey_badge_text = body.survey_badge_text;

      const insertData = {
        title: body.title,
        message: body.message || null,
        kind: body.kind || 'announcement',
        surface: body.surface || 'home_banner',
        importance: body.importance || 'medium',
        action_type: body.action_type || 'none',
        action_value: body.action_value || null,
        start_at: (body.start_at && body.start_at.trim() !== '' && !isNaN(new Date(body.start_at).getTime())) 
          ? new Date(body.start_at).toISOString() 
          : new Date().toISOString(),
        end_at: (body.end_at && body.end_at.trim() !== '' && !isNaN(new Date(body.end_at).getTime())) 
          ? new Date(body.end_at).toISOString() 
          : null,
        is_active: body.is_active !== false,
        dismissible: body.dismissible !== false,
        dismissible_mode: body.dismissible_mode || 'yes',
        remind_later_count: body.remind_later_count || 3,
        remind_later_sessions: body.remind_later_sessions || 1,
        repeat_mode: body.repeat_mode || 'once',
        repeat_interval_hours: body.repeat_interval_hours || null,
        max_times_seen_per_user: body.max_times_seen_per_user || null,
        // Basic Targeting
        target_country: body.target_country || null,
        target_city: body.target_city || null,
        target_speciality: body.target_speciality || null,
        target_min_app_version: body.target_min_app_version || null,
        target_max_app_version: body.target_max_app_version || null,
        target_logged_in_only: body.target_logged_in_only || false,
        target_anonymous_only: body.target_anonymous_only || false,
        // User Insights Targeting
        target_degree: body.target_degree || null,
        target_subspecialty: body.target_subspecialty || null,
        target_profession: body.target_profession || null,
        target_hospital: body.target_hospital || null,
        target_years_experience: body.target_years_experience || null,
        // Device/Platform Targeting
        target_platform: body.target_platform || null,
        target_is_real_device: body.target_is_real_device,
        target_device_brand: body.target_device_brand || null,
        target_ip_addresses: body.target_ip_addresses || null,
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
      if (body.cta_icon) metadata.cta_icon = body.cta_icon;
      if (body.background_color) metadata.background_color = body.background_color;
      if (body.text_color) metadata.text_color = body.text_color;
      if (body.custom_color) metadata.custom_color = body.custom_color;
      // Survey-specific metadata
      if (body.survey_category) metadata.survey_category = body.survey_category;
      if (body.survey_badge_text) metadata.survey_badge_text = body.survey_badge_text;

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
      if (body.start_at !== undefined) {
        if (body.start_at && body.start_at.trim() !== '') {
          const startDate = new Date(body.start_at);
          updateData.start_at = !isNaN(startDate.getTime()) ? startDate.toISOString() : null;
        } else {
          updateData.start_at = null;
        }
      }
      if (body.end_at !== undefined) {
        if (body.end_at && body.end_at.trim() !== '') {
          const endDate = new Date(body.end_at);
          updateData.end_at = !isNaN(endDate.getTime()) ? endDate.toISOString() : null;
        } else {
          updateData.end_at = null;
        }
      }
      if (body.is_active !== undefined) updateData.is_active = body.is_active;
      if (body.dismissible !== undefined) updateData.dismissible = body.dismissible;
      if (body.dismissible_mode !== undefined) updateData.dismissible_mode = body.dismissible_mode;
      if (body.remind_later_count !== undefined) updateData.remind_later_count = body.remind_later_count;
      if (body.remind_later_sessions !== undefined) updateData.remind_later_sessions = body.remind_later_sessions;
      if (body.repeat_mode !== undefined) updateData.repeat_mode = body.repeat_mode;
      if (body.repeat_interval_hours !== undefined) updateData.repeat_interval_hours = body.repeat_interval_hours;
      if (body.max_times_seen_per_user !== undefined) updateData.max_times_seen_per_user = body.max_times_seen_per_user;
      // Basic Targeting
      if (body.target_country !== undefined) updateData.target_country = body.target_country || null;
      if (body.target_city !== undefined) updateData.target_city = body.target_city || null;
      if (body.target_speciality !== undefined) updateData.target_speciality = body.target_speciality || null;
      if (body.target_min_app_version !== undefined) updateData.target_min_app_version = body.target_min_app_version || null;
      if (body.target_max_app_version !== undefined) updateData.target_max_app_version = body.target_max_app_version || null;
      if (body.target_logged_in_only !== undefined) updateData.target_logged_in_only = body.target_logged_in_only;
      if (body.target_anonymous_only !== undefined) updateData.target_anonymous_only = body.target_anonymous_only;
      // User Insights Targeting
      if (body.target_degree !== undefined) updateData.target_degree = body.target_degree || null;
      if (body.target_subspecialty !== undefined) updateData.target_subspecialty = body.target_subspecialty || null;
      if (body.target_profession !== undefined) updateData.target_profession = body.target_profession || null;
      if (body.target_hospital !== undefined) updateData.target_hospital = body.target_hospital || null;
      if (body.target_years_experience !== undefined) updateData.target_years_experience = body.target_years_experience || null;
      // Device/Platform Targeting
      if (body.target_platform !== undefined) updateData.target_platform = body.target_platform || null;
      if (body.target_is_real_device !== undefined) updateData.target_is_real_device = body.target_is_real_device;
      if (body.target_device_brand !== undefined) updateData.target_device_brand = body.target_device_brand || null;
      if (body.target_ip_addresses !== undefined) updateData.target_ip_addresses = body.target_ip_addresses || null;
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
