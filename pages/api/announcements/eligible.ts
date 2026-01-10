/**
 * API Endpoint: Get Eligible Announcements for Mobile App (legacy V1.0.0)
 * 
 * Returns server-filtered announcements. Backward-compatible: service-role path by default,
 * secure path via allowlist when enabled. This file now includes temporary debug instrumentation.
 */

import type { NextApiRequest, NextApiResponse } from 'next';
import { randomUUID } from 'crypto';
import { createClient } from '@supabase/supabase-js';
import { withApiGuards } from '../../../lib/apiGuards';
import { getSupabaseAnonClientWithAuth, shouldUseAnnouncementV2 } from '../../../lib/announcementV2';

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!
);

type Surface = 'carousel' | 'inbox' | 'home_banner' | 'modal' | 'tooltip';

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
  surface?: Surface;
  is_real_device?: boolean;
  device_brand?: string;
  subspecialty?: string;
  hospital?: string;
  ip_address?: string;
  page?: number;
  page_size?: number;
}

type NormalizedParams = ReturnType<typeof buildNormalizedParams>;

// DEBUG-INSTRUMENTATION: request normalization helpers
const normalizeString = (value: any): string | null => {
  if (value === undefined || value === null) return null;
  const trimmed = String(value).trim();
  return trimmed.length === 0 ? null : trimmed;
};

const normalizeBoolean = (value: any, defaultValue: boolean | null = null): boolean | null => {
  if (value === undefined || value === null || value === '') return defaultValue;
  if (typeof value === 'boolean') return value;
  if (typeof value === 'string') {
    const lowered = value.toLowerCase();
    if (['true', '1', 'yes', 'on'].includes(lowered)) return true;
    if (['false', '0', 'no', 'off'].includes(lowered)) return false;
  }
  return defaultValue;
};

const normalizeInteger = (value: any, defaultValue: number | null = null): number | null => {
  if (value === undefined || value === null || value === '') return defaultValue;
  const parsed = parseInt(String(value), 10);
  return Number.isNaN(parsed) ? defaultValue : parsed;
};

// DEBUG-INSTRUMENTATION: normalize incoming body
function buildNormalizedParams(body: EligibleRequest) {
  return {
    user_id: normalizeString(body.user_id),
    device_id: normalizeString(body.device_id),
    auth_uid: normalizeString(body.auth_uid),
    platform: normalizeString(body.platform),
    app_version: normalizeString(body.app_version),
    country: normalizeString(body.country),
    city: normalizeString(body.city),
    is_logged_in: normalizeBoolean(body.is_logged_in, false) ?? false,
    profession: normalizeString(body.profession),
    speciality: normalizeString(body.speciality),
    degree: normalizeString(body.degree),
    experience: normalizeString(body.experience),
    has_complete_profile: normalizeBoolean(body.has_complete_profile, false) ?? false,
    session_number: normalizeInteger(body.session_number, 1) ?? 1,
    surface: (normalizeString(body.surface) as Surface) || 'carousel',
    is_real_device: normalizeBoolean(body.is_real_device),
    device_brand: normalizeString(body.device_brand),
    subspecialty: normalizeString(body.subspecialty),
    hospital: normalizeString(body.hospital),
    ip_address: normalizeString(body.ip_address),
    page: normalizeInteger(body.page, 1) ?? 1,
    page_size: normalizeInteger(body.page_size, 20) ?? 20,
  };
}

type RpcError = {
  requestId: string;
  rpc: string;
  error: any;
  httpStatus: number;
  paramsSummary?: Record<string, unknown>;
};

// DEBUG-INSTRUMENTATION: structured Supabase error logging
const logRpcError = ({ requestId, rpc, error, httpStatus, paramsSummary }: RpcError) => {
  const code = error?.code || error?.status || 'unknown_code';
  const message = error?.message || 'unknown_error';
  const hint = error?.hint;
  console.error(
    JSON.stringify({
      scope: 'announcements/eligible',
      requestId,
      rpc,
      httpStatus,
      params_summary: paramsSummary,
      supabase_error_code: code,
      supabase_error_message: message,
      supabase_error_hint: hint,
    })
  );
};

// DEBUG-INSTRUMENTATION: per-request summary log
const logSummary = ({
  requestId,
  inbox_ok,
  carousel_ok,
  modal_ok,
  used_legacy_path,
  debug_surface,
}: {
  requestId: string;
  inbox_ok: boolean;
  carousel_ok: boolean;
  modal_ok: boolean;
  used_legacy_path: boolean;
  debug_surface?: string | null;
}) => {
  console.log(
    JSON.stringify({
      scope: 'announcements/eligible',
      requestId,
      rpc_name: 'eligible_summary',
      inbox_ok,
      carousel_ok,
      modal_ok,
      used_legacy_path,
      debug_surface: debug_surface || null,
    })
  );
};

const getDebugSurface = (): Surface | null => {
  const val = normalizeString(process.env.ANNOUNCEMENTS_DEBUG_SINGLE_SURFACE);
  if (!val) return null;
  if (['inbox', 'carousel', 'modal', 'home_banner', 'tooltip'].includes(val)) {
    return val as Surface;
  }
  return null;
};

async function handler(req: NextApiRequest, res: NextApiResponse) {
  const requestId = randomUUID();

  // Only allow POST requests
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed', requestId });
  }

  const params = buildNormalizedParams(req.body);
  const debugSurface = getDebugSurface();

  if (debugSurface) {
    console.log(
      // DEBUG-INSTRUMENTATION
      JSON.stringify({
        scope: 'announcements/eligible',
        requestId,
        message: 'Isolation mode enabled',
        debug_surface: debugSurface,
      })
    );
  }

  // Decide whether to use secured path (Firebase JWT + anon key) or legacy (service role)
  const v2Decision = await shouldUseAnnouncementV2(req);

  if (v2Decision.enabled) {
    console.log('[announcements/eligible] allowlisted user -> secure path');
    return handleV2({
      req,
      res,
      authUid: v2Decision.authUid!,
      requestId,
      params,
      debugSurface,
    });
  }
  console.log('[announcements/eligible] legacy path (flag disabled or not allowlisted)');

  // Validate required fields
  if (!params.user_id && !params.device_id && !params.auth_uid) {
    return res.status(400).json({
      error: 'At least one of user_id, device_id, or auth_uid is required',
      requestId,
    });
  }

  return handleLegacy({
    res,
    requestId,
    params,
    debugSurface,
  });
}

async function handleLegacy({
  res,
  requestId,
  params,
  debugSurface,
}: {
  res: NextApiResponse;
  requestId: string;
  params: NormalizedParams;
  debugSurface: Surface | null;
}) {
  const effectiveUserId = params.auth_uid || params.device_id || params.user_id!;
  const surfaceToUse: Surface = debugSurface || params.surface;
  const summary = { inbox_ok: false, carousel_ok: false, modal_ok: false };

  if (surfaceToUse === 'carousel' || surfaceToUse === 'home_banner') {
    const paramsSummary = {
      has_user_id: !!params.user_id,
      has_device_id: !!params.device_id,
      has_auth_uid: !!params.auth_uid,
      is_logged_in: params.is_logged_in,
      has_app_version: !!params.app_version,
    };

    try {
      const { data, error } = await supabase.rpc('get_carousel_announcements', {
        p_user_id: effectiveUserId,
        p_device_id: params.device_id,
        p_auth_uid: params.auth_uid,
        p_platform: params.platform,
        p_app_version: params.app_version,
        p_country: params.country,
        p_city: params.city,
        p_is_logged_in: params.is_logged_in,
        p_profession: params.profession,
        p_speciality: params.speciality,
        p_degree: params.degree,
        p_experience: params.experience,
        p_has_complete_profile: params.has_complete_profile,
        p_session_number: params.session_number,
        p_is_real_device: params.is_real_device,
        p_device_brand: params.device_brand,
        p_subspecialty: params.subspecialty,
        p_hospital: params.hospital,
        p_ip_address: params.ip_address,
      });

      if (error) {
        logRpcError({
          requestId,
          rpc: 'get_carousel_announcements',
          error,
          httpStatus: 500,
          paramsSummary,
        });
      } else {
        summary.carousel_ok = true;
        console.log(
          // DEBUG-INSTRUMENTATION
          JSON.stringify({
            scope: 'announcements/eligible',
            requestId,
            rpc_name: 'get_carousel_announcements',
            status: 'ok',
            params_summary: paramsSummary,
          })
        );

        // Config fetch is kept; errors will just default later
        const { data: configData } = await supabase
          .from('announcement_config')
          .select('config_value')
          .eq('config_key', 'carousel_max_items')
          .single();

        logSummary({
          requestId,
          inbox_ok: summary.inbox_ok,
          carousel_ok: summary.carousel_ok,
          modal_ok: summary.modal_ok,
          used_legacy_path: true,
          debug_surface: debugSurface,
        });

        return res.status(200).json({
          success: true,
          announcements: data || [],
          config: {
            carousel_max_items: parseInt(configData?.config_value || '5'),
          },
          meta: {
            surface: surfaceToUse,
            count: data?.length || 0,
            session_number: params.session_number,
          },
          requestId,
        });
      }
    } catch (error: any) {
      logRpcError({
        requestId,
        rpc: 'get_carousel_announcements',
        error,
        httpStatus: 500,
        paramsSummary,
      });
    }

    logSummary({
      requestId,
      inbox_ok: summary.inbox_ok,
      carousel_ok: summary.carousel_ok,
      modal_ok: summary.modal_ok,
      used_legacy_path: true,
      debug_surface: debugSurface,
    });

    return res.status(200).json({
      success: true,
      announcements: [],
      config: { carousel_max_items: 0 },
      meta: {
        surface: surfaceToUse,
        count: 0,
        session_number: params.session_number,
      },
      requestId,
    });
  }

  if (surfaceToUse === 'inbox') {
    const paramsSummary = {
      has_user_id: !!params.user_id,
      has_device_id: !!params.device_id,
      has_auth_uid: !!params.auth_uid,
      is_logged_in: params.is_logged_in,
      has_app_version: !!params.app_version,
      page: params.page,
      page_size: params.page_size,
    };

    try {
      const { data, error } = await supabase.rpc('get_inbox_announcements', {
        p_user_id: effectiveUserId,
        p_device_id: params.device_id,
        p_auth_uid: params.auth_uid,
        p_platform: params.platform,
        p_app_version: params.app_version,
        p_country: params.country,
        p_city: params.city,
        p_is_logged_in: params.is_logged_in,
        p_profession: params.profession,
        p_speciality: params.speciality,
        p_degree: params.degree,
        p_experience: params.experience,
        p_has_complete_profile: params.has_complete_profile,
        p_session_number: params.session_number,
        p_is_real_device: params.is_real_device,
        p_device_brand: params.device_brand,
        p_subspecialty: params.subspecialty,
        p_hospital: params.hospital,
        p_ip_address: params.ip_address,
        p_page: params.page,
        p_page_size: params.page_size,
      });

      if (error) {
        logRpcError({
          requestId,
          rpc: 'get_inbox_announcements',
          error,
          httpStatus: 500,
          paramsSummary,
        });
      } else {
        summary.inbox_ok = true;
        const totalCount = data?.[0]?.total_count || 0;
        const totalPages = Math.ceil(totalCount / params.page_size);

        console.log(
          // DEBUG-INSTRUMENTATION
          JSON.stringify({
            scope: 'announcements/eligible',
            requestId,
            rpc_name: 'get_inbox_announcements',
            status: 'ok',
            params_summary: paramsSummary,
          })
        );

        logSummary({
          requestId,
          inbox_ok: summary.inbox_ok,
          carousel_ok: summary.carousel_ok,
          modal_ok: summary.modal_ok,
          used_legacy_path: true,
          debug_surface: debugSurface,
        });

        return res.status(200).json({
          success: true,
          announcements: data || [],
          pagination: {
            page: params.page,
            page_size: params.page_size,
            total_count: totalCount,
            total_pages: totalPages,
            has_more: params.page < totalPages,
          },
          meta: {
            surface: 'inbox',
            session_number: params.session_number,
          },
          requestId,
        });
      }
    } catch (error: any) {
      logRpcError({
        requestId,
        rpc: 'get_inbox_announcements',
        error,
        httpStatus: 500,
        paramsSummary,
      });
    }

    logSummary({
      requestId,
      inbox_ok: summary.inbox_ok,
      carousel_ok: summary.carousel_ok,
      modal_ok: summary.modal_ok,
      used_legacy_path: true,
      debug_surface: debugSurface,
    });

    return res.status(200).json({
      success: true,
      announcements: [],
      pagination: {
        page: params.page,
        page_size: params.page_size,
        total_count: 0,
        total_pages: 0,
        has_more: false,
      },
      meta: {
        surface: 'inbox',
        session_number: params.session_number,
      },
      requestId,
    });
  }

  // Generic surfaces (modal, tooltip, etc.)
  const paramsSummary = {
    surface: surfaceToUse,
    has_user_id: !!params.user_id,
    has_device_id: !!params.device_id,
    has_auth_uid: !!params.auth_uid,
    is_logged_in: params.is_logged_in,
    has_app_version: !!params.app_version,
  };

  try {
    const { data, error } = await supabase.rpc('get_eligible_announcements', {
      p_user_id: effectiveUserId,
      p_device_id: params.device_id,
      p_auth_uid: params.auth_uid,
      p_platform: params.platform,
      p_app_version: params.app_version,
      p_country: params.country,
      p_city: params.city,
      p_is_logged_in: params.is_logged_in,
      p_profession: params.profession,
      p_speciality: params.speciality,
      p_degree: params.degree,
      p_experience: params.experience,
      p_has_complete_profile: params.has_complete_profile,
      p_session_number: params.session_number,
      p_surface: surfaceToUse,
      p_is_real_device: params.is_real_device,
      p_device_brand: params.device_brand,
      p_subspecialty: params.subspecialty,
      p_hospital: params.hospital,
      p_ip_address: params.ip_address,
      p_limit: params.page_size,
      p_offset: (params.page - 1) * params.page_size,
    });

    if (error) {
      logRpcError({
        requestId,
        rpc: `get_eligible_announcements(${surfaceToUse})`,
        error,
        httpStatus: 500,
        paramsSummary,
      });
    } else {
      summary.modal_ok = true;
      console.log(
        // DEBUG-INSTRUMENTATION
        JSON.stringify({
          scope: 'announcements/eligible',
          requestId,
          rpc_name: `get_eligible_announcements(${surfaceToUse})`,
          status: 'ok',
          params_summary: paramsSummary,
        })
      );

      logSummary({
        requestId,
        inbox_ok: summary.inbox_ok,
        carousel_ok: summary.carousel_ok,
        modal_ok: summary.modal_ok,
        used_legacy_path: true,
        debug_surface: debugSurface,
      });

      return res.status(200).json({
        success: true,
        announcements: data || [],
        meta: {
          surface: surfaceToUse,
          count: data?.length || 0,
          session_number: params.session_number,
        },
        requestId,
      });
    }
  } catch (error: any) {
    logRpcError({
      requestId,
      rpc: `get_eligible_announcements(${surfaceToUse})`,
      error,
      httpStatus: 500,
      paramsSummary,
    });
  }

  logSummary({
    requestId,
    inbox_ok: summary.inbox_ok,
    carousel_ok: summary.carousel_ok,
    modal_ok: summary.modal_ok,
    used_legacy_path: true,
    debug_surface: debugSurface,
  });

  return res.status(200).json({
    success: true,
    announcements: [],
    meta: {
      surface: surfaceToUse,
      count: 0,
      session_number: params.session_number,
    },
    requestId,
  });
}

async function handleV2({
  req,
  res,
  authUid,
  requestId,
  params,
  debugSurface,
}: {
  req: NextApiRequest;
  res: NextApiResponse;
  authUid: string;
  requestId: string;
  params: NormalizedParams;
  debugSurface: Surface | null;
}) {
  const firebaseToken = (req.headers.authorization || '').replace(/^Bearer\s+/i, '').trim();
  const v2Client = getSupabaseAnonClientWithAuth(firebaseToken);

  const effectiveUserId = authUid;
  const surfaceToUse: Surface = debugSurface || params.surface;
  const summary = { inbox_ok: false, carousel_ok: false, modal_ok: false };

  if (surfaceToUse === 'carousel' || surfaceToUse === 'home_banner') {
    const paramsSummary = {
      has_user_id: !!params.user_id,
      has_device_id: !!params.device_id,
      has_auth_uid: true,
      is_logged_in: params.is_logged_in,
      has_app_version: !!params.app_version,
    };

    try {
      const { data, error } = await v2Client.rpc('get_carousel_announcements', {
        p_user_id: effectiveUserId,
        p_device_id: params.device_id,
        p_auth_uid: authUid,
        p_platform: params.platform,
        p_app_version: params.app_version,
        p_country: params.country,
        p_city: params.city,
        p_is_logged_in: params.is_logged_in,
        p_profession: params.profession,
        p_speciality: params.speciality,
        p_degree: params.degree,
        p_experience: params.experience,
        p_has_complete_profile: params.has_complete_profile,
        p_session_number: params.session_number,
        p_is_real_device: params.is_real_device,
        p_device_brand: params.device_brand,
        p_subspecialty: params.subspecialty,
        p_hospital: params.hospital,
        p_ip_address: params.ip_address,
      });

      if (error) {
        logRpcError({
          requestId,
          rpc: 'get_carousel_announcements (secure)',
          error,
          httpStatus: 500,
          paramsSummary,
        });
      } else {
        summary.carousel_ok = true;
        console.log(
          // DEBUG-INSTRUMENTATION
          JSON.stringify({
            scope: 'announcements/eligible',
            requestId,
            rpc_name: 'get_carousel_announcements (secure)',
            status: 'ok',
            params_summary: paramsSummary,
          })
        );

        const { data: configData } = await v2Client
          .from('announcement_config')
          .select('config_value')
          .eq('config_key', 'carousel_max_items')
          .single();

        logSummary({
          requestId,
          inbox_ok: summary.inbox_ok,
          carousel_ok: summary.carousel_ok,
          modal_ok: summary.modal_ok,
          used_legacy_path: false,
          debug_surface: debugSurface,
        });

        return res.status(200).json({
          success: true,
          announcements: data || [],
          config: {
            carousel_max_items: parseInt(configData?.config_value || '5'),
          },
          meta: {
            surface: surfaceToUse,
            count: data?.length || 0,
            session_number: params.session_number,
          },
          mode: 'v2',
          requestId,
        });
      }
    } catch (error: any) {
      logRpcError({
        requestId,
        rpc: 'get_carousel_announcements (secure)',
        error,
        httpStatus: 500,
        paramsSummary,
      });
    }

    logSummary({
      requestId,
      inbox_ok: summary.inbox_ok,
      carousel_ok: summary.carousel_ok,
      modal_ok: summary.modal_ok,
      used_legacy_path: false,
      debug_surface: debugSurface,
    });

    return res.status(200).json({
      success: true,
      announcements: [],
      config: { carousel_max_items: 0 },
      meta: {
        surface: surfaceToUse,
        count: 0,
        session_number: params.session_number,
      },
      mode: 'v2',
      requestId,
    });
  }

  if (surfaceToUse === 'inbox') {
    const paramsSummary = {
      has_user_id: !!params.user_id,
      has_device_id: !!params.device_id,
      has_auth_uid: true,
      is_logged_in: params.is_logged_in,
      has_app_version: !!params.app_version,
      page: params.page,
      page_size: params.page_size,
    };

    try {
      const { data, error } = await v2Client.rpc('get_inbox_announcements', {
        p_user_id: effectiveUserId,
        p_device_id: params.device_id,
        p_auth_uid: authUid,
        p_platform: params.platform,
        p_app_version: params.app_version,
        p_country: params.country,
        p_city: params.city,
        p_is_logged_in: params.is_logged_in,
        p_profession: params.profession,
        p_speciality: params.speciality,
        p_degree: params.degree,
        p_experience: params.experience,
        p_has_complete_profile: params.has_complete_profile,
        p_session_number: params.session_number,
        p_is_real_device: params.is_real_device,
        p_device_brand: params.device_brand,
        p_subspecialty: params.subspecialty,
        p_hospital: params.hospital,
        p_ip_address: params.ip_address,
        p_page: params.page,
        p_page_size: params.page_size,
      });

      if (error) {
        logRpcError({
          requestId,
          rpc: 'get_inbox_announcements (secure)',
          error,
          httpStatus: 500,
          paramsSummary,
        });
      } else {
        summary.inbox_ok = true;
        const totalCount = data?.[0]?.total_count || 0;
        const totalPages = Math.ceil(totalCount / params.page_size);

        console.log(
          // DEBUG-INSTRUMENTATION
          JSON.stringify({
            scope: 'announcements/eligible',
            requestId,
            rpc_name: 'get_inbox_announcements (secure)',
            status: 'ok',
            params_summary: paramsSummary,
          })
        );

        logSummary({
          requestId,
          inbox_ok: summary.inbox_ok,
          carousel_ok: summary.carousel_ok,
          modal_ok: summary.modal_ok,
          used_legacy_path: false,
          debug_surface: debugSurface,
        });

        return res.status(200).json({
          success: true,
          announcements: data || [],
          pagination: {
            page: params.page,
            page_size: params.page_size,
            total_count: totalCount,
            total_pages: totalPages,
            has_more: params.page < totalPages,
          },
          meta: {
            surface: 'inbox',
            session_number: params.session_number,
          },
          mode: 'v2',
          requestId,
        });
      }
    } catch (error: any) {
      logRpcError({
        requestId,
        rpc: 'get_inbox_announcements (secure)',
        error,
        httpStatus: 500,
        paramsSummary,
      });
    }

    logSummary({
      requestId,
      inbox_ok: summary.inbox_ok,
      carousel_ok: summary.carousel_ok,
      modal_ok: summary.modal_ok,
      used_legacy_path: false,
      debug_surface: debugSurface,
    });

    return res.status(200).json({
      success: true,
      announcements: [],
      pagination: {
        page: params.page,
        page_size: params.page_size,
        total_count: 0,
        total_pages: 0,
        has_more: false,
      },
      meta: {
        surface: 'inbox',
        session_number: params.session_number,
      },
      mode: 'v2',
      requestId,
    });
  }

  const paramsSummary = {
    surface: surfaceToUse,
    has_user_id: !!params.user_id,
    has_device_id: !!params.device_id,
    has_auth_uid: true,
    is_logged_in: params.is_logged_in,
    has_app_version: !!params.app_version,
  };

  try {
    const { data, error } = await v2Client.rpc('get_eligible_announcements', {
      p_user_id: effectiveUserId,
      p_device_id: params.device_id,
      p_auth_uid: authUid,
      p_platform: params.platform,
      p_app_version: params.app_version,
      p_country: params.country,
      p_city: params.city,
      p_is_logged_in: params.is_logged_in,
      p_profession: params.profession,
      p_speciality: params.speciality,
      p_degree: params.degree,
      p_experience: params.experience,
      p_has_complete_profile: params.has_complete_profile,
      p_session_number: params.session_number,
      p_surface: surfaceToUse,
      p_is_real_device: params.is_real_device,
      p_device_brand: params.device_brand,
      p_subspecialty: params.subspecialty,
      p_hospital: params.hospital,
      p_ip_address: params.ip_address,
      p_limit: params.page_size,
      p_offset: (params.page - 1) * params.page_size,
    });

    if (error) {
      logRpcError({
        requestId,
        rpc: `get_eligible_announcements(${surfaceToUse}) (secure)`,
        error,
        httpStatus: 500,
        paramsSummary,
      });
    } else {
      summary.modal_ok = true;
      console.log(
        // DEBUG-INSTRUMENTATION
        JSON.stringify({
          scope: 'announcements/eligible',
          requestId,
          rpc_name: `get_eligible_announcements(${surfaceToUse}) (secure)`,
          status: 'ok',
          params_summary: paramsSummary,
        })
      );

      logSummary({
        requestId,
        inbox_ok: summary.inbox_ok,
        carousel_ok: summary.carousel_ok,
        modal_ok: summary.modal_ok,
        used_legacy_path: false,
        debug_surface: debugSurface,
      });

      return res.status(200).json({
        success: true,
        announcements: data || [],
        meta: {
          surface: surfaceToUse,
          count: data?.length || 0,
          session_number: params.session_number,
        },
        mode: 'v2',
        requestId,
      });
    }
  } catch (error: any) {
    logRpcError({
      requestId,
      rpc: `get_eligible_announcements(${surfaceToUse}) (secure)`,
      error,
      httpStatus: 500,
      paramsSummary,
    });
  }

  logSummary({
    requestId,
    inbox_ok: summary.inbox_ok,
    carousel_ok: summary.carousel_ok,
    modal_ok: summary.modal_ok,
    used_legacy_path: false,
    debug_surface: debugSurface,
  });

  return res.status(200).json({
    success: true,
    announcements: [],
    meta: {
      surface: surfaceToUse,
      count: 0,
      session_number: params.session_number,
    },
    mode: 'v2',
    requestId,
  });
}

export default withApiGuards(handler);
