/**
 * API Endpoint: Get Eligible Announcements for Mobile App
 * 
 * This endpoint returns server-filtered announcements based on user context.
 * It evaluates eligibility server-side and returns only relevant items.
 * 
 * Supports:
 * - Carousel announcements (limited, prioritized)
 * - Inbox announcements (paginated)
 * - User state tracking
 */

import type { NextApiRequest, NextApiResponse } from 'next';
import { createClient } from '@supabase/supabase-js';

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!
);

interface EligibleRequest {
  user_id: string;
  device_id?: string;
  auth_uid?: string;
  platform?: string;
  app_version?: string;
  country?: string;
  city?: string;
  is_logged_in?: boolean;
  profession?: string;
  speciality?: string;
  degree?: string;
  experience?: string;
  has_complete_profile?: boolean;
  session_number?: number;
  surface?: 'carousel' | 'inbox' | 'home_banner' | 'modal' | 'tooltip';
  is_real_device?: boolean;
  device_brand?: string;
  subspecialty?: string;
  hospital?: string;
  ip_address?: string;
  page?: number;
  page_size?: number;
}

export default async function handler(
  req: NextApiRequest,
  res: NextApiResponse
) {
  // Only allow POST requests
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  try {
    const {
      user_id,
      device_id,
      auth_uid,
      platform,
      app_version,
      country,
      city,
      is_logged_in = false,
      profession,
      speciality,
      degree,
      experience,
      has_complete_profile = false,
      session_number = 1,
      surface = 'carousel',
      is_real_device,
      device_brand,
      subspecialty,
      hospital,
      ip_address,
      page = 1,
      page_size = 20,
    }: EligibleRequest = req.body;

    console.log('[API] Request received:', {
      surface,
      user_id: user_id?.slice(0, 8),
      device_id: device_id?.slice(0, 8),
      auth_uid: auth_uid?.slice(0, 8),
      is_logged_in,
      is_real_device,
      profession,
      speciality,
      degree,
      experience,
      has_complete_profile,
    });

    // Validate required fields
    if (!user_id && !device_id && !auth_uid) {
      return res.status(400).json({ 
        error: 'At least one of user_id, device_id, or auth_uid is required' 
      });
    }

    const effectiveUserId = auth_uid || device_id || user_id;

    // Handle different surfaces
    if (surface === 'carousel' || surface === 'home_banner') {
      // Get carousel/home_banner announcements using the server function
      const { data, error } = await supabase.rpc('get_carousel_announcements', {
        p_user_id: effectiveUserId,
        p_device_id: device_id,
        p_auth_uid: auth_uid,
        p_platform: platform,
        p_app_version: app_version,
        p_country: country,
        p_city: city,
        p_is_logged_in: is_logged_in,
        p_profession: profession,
        p_speciality: speciality,
        p_degree: degree,
        p_experience: experience,
        p_has_complete_profile: has_complete_profile,
        p_session_number: session_number,
        p_is_real_device: is_real_device,
        p_device_brand: device_brand,
        p_subspecialty: subspecialty,
        p_hospital: hospital,
        p_ip_address: ip_address,
      });

      if (error) {
        console.error('[API] get_carousel_announcements error:', {
          message: error.message,
          details: error.details,
          hint: error.hint,
          code: error.code,
        });
        return res.status(500).json({ 
          error: error.message,
          details: error.details,
          hint: error.hint,
          code: error.code,
        });
      }

      // Get config for max items
      const { data: configData } = await supabase
        .from('announcement_config')
        .select('config_value')
        .eq('config_key', 'carousel_max_items')
        .single();

      return res.status(200).json({
        success: true,
        announcements: data || [],
        config: {
          carousel_max_items: parseInt(configData?.config_value || '5'),
        },
        meta: {
          surface: surface,
          count: data?.length || 0,
          session_number,
        },
      });
    } else if (surface === 'inbox') {
      // Get inbox announcements with pagination
      const { data, error } = await supabase.rpc('get_inbox_announcements', {
        p_user_id: effectiveUserId,
        p_device_id: device_id,
        p_auth_uid: auth_uid,
        p_platform: platform,
        p_app_version: app_version,
        p_country: country,
        p_city: city,
        p_is_logged_in: is_logged_in,
        p_profession: profession,
        p_speciality: speciality,
        p_degree: degree,
        p_experience: experience,
        p_has_complete_profile: has_complete_profile,
        p_session_number: session_number,
        p_is_real_device: is_real_device,
        p_device_brand: device_brand,
        p_subspecialty: subspecialty,
        p_hospital: hospital,
        p_ip_address: ip_address,
        p_page: page,
        p_page_size: page_size,
      });

      if (error) {
        console.error('[API] get_inbox_announcements error:', {
          message: error.message,
          details: error.details,
          hint: error.hint,
          code: error.code,
        });
        return res.status(500).json({ 
          error: error.message,
          details: error.details,
          hint: error.hint,
          code: error.code,
        });
      }

      const totalCount = data?.[0]?.total_count || 0;
      const totalPages = Math.ceil(totalCount / page_size);

      return res.status(200).json({
        success: true,
        announcements: data || [],
        pagination: {
          page,
          page_size,
          total_count: totalCount,
          total_pages: totalPages,
          has_more: page < totalPages,
        },
        meta: {
          surface: 'inbox',
          session_number,
        },
      });
    } else {
      // Get announcements for other surfaces (modal, tooltip, etc.)
      // Use the generic get_eligible_announcements function
      const { data, error } = await supabase.rpc('get_eligible_announcements', {
        p_user_id: effectiveUserId,
        p_device_id: device_id,
        p_auth_uid: auth_uid,
        p_platform: platform,
        p_app_version: app_version,
        p_country: country,
        p_city: city,
        p_is_logged_in: is_logged_in,
        p_profession: profession,
        p_speciality: speciality,
        p_degree: degree,
        p_experience: experience,
        p_has_complete_profile: has_complete_profile,
        p_session_number: session_number,
        p_surface: surface,
        p_is_real_device: is_real_device,
        p_device_brand: device_brand,
        p_subspecialty: subspecialty,
        p_hospital: hospital,
        p_ip_address: ip_address,
        p_limit: page_size,
        p_offset: (page - 1) * page_size,
      });

      if (error) {
        console.error(`[API] get_eligible_announcements(${surface}) error:`, {
          message: error.message,
          details: error.details,
          hint: error.hint,
          code: error.code,
        });
        return res.status(500).json({ 
          error: error.message,
          details: error.details,
          hint: error.hint,
          code: error.code,
        });
      }

      return res.status(200).json({
        success: true,
        announcements: data || [],
        meta: {
          surface: surface,
          count: data?.length || 0,
          session_number,
        },
      });
    }
  } catch (error: any) {
    console.error('[API] Eligible announcements error:', error);
    return res.status(500).json({ error: error.message || 'Internal server error' });
  }
}
