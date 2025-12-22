import type { NextApiRequest, NextApiResponse } from 'next';
import { getSupabaseAdmin } from '../../../lib/supabaseAdmin';
import { requireAdminApi } from '../../../lib/adminAuth';
import type { AdminUserRow } from '../../../types/admin';

const clampLimit = (value: string | string[] | undefined): number => {
  const parsed = Array.isArray(value) ? parseInt(value[0] ?? '', 10) : parseInt(value ?? '', 10);
  if (Number.isNaN(parsed) || parsed <= 0) {
    return 100;
  }
  return Math.min(parsed, 500);
};

export interface EnhancedUserRow extends AdminUserRow {
  isAnonymous: boolean;
  isRealDevice: boolean | null;
  deviceBrand: string | null;
  deviceModel: string | null;
  osPlatform: string | null;
  osVersion: string | null;
  sessionCount: number;
  lastSessionAt: string | null;
  toolsUsedCount: number;
  totalToolTimeSeconds: number;
  firstSessionAt: string | null;
}

export interface UserSessionLog {
  id: string;
  startTime: string;
  endTime: string | null;
  durationSeconds: number;
  country: string | null;
  city: string | null;
  appVersion: string | null;
  osPlatform: string | null;
  deviceBrand: string | null;
  deviceModel: string | null;
  isDevice: boolean | null;
}

export interface UserToolLog {
  toolId: string;
  toolName: string;
  usageCount: number;
  totalTimeSeconds: number;
  lastUsedAt: string | null;
  events: {
    id: string;
    eventType: string;
    eventTimestamp: string;
    appSessionId: string;
    eventData: any;
  }[];
}

export interface UserDetailResponse {
  user: EnhancedUserRow;
  sessions: UserSessionLog[];
  toolUsage: UserToolLog[];
}

export interface UsersResponse {
  users: EnhancedUserRow[];
  total: number;
}

export default async function handler(req: NextApiRequest, res: NextApiResponse<UsersResponse | UserDetailResponse | { error: string }>) {
  if (req.method !== 'GET') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  const adminSession = requireAdminApi(req, res);
  if (!adminSession) {
    return null;
  }

  try {
    const supabase = getSupabaseAdmin();
    
    // Check if requesting single user detail
    const userId = req.query.userId as string | undefined;
    if (userId) {
      return await handleUserDetail(supabase, userId, res);
    }

    const limit = clampLimit(req.query.limit);
    
    // Parse filters
    const filterAnonymous = req.query.anonymous as string | undefined; // 'true', 'false', or undefined
    const filterDevice = req.query.device as string | undefined; // 'real', 'emulator', or undefined
    const sortBy = (req.query.sortBy as string) || 'createdAt';
    const sortOrder = (req.query.sortOrder as string) || 'desc';

    // Get users
    const { data: usersData, error: usersError } = await supabase
      .from('users')
      .select('*')
      .order('created_at', { ascending: false })
      .limit(limit);

    if (usersError) {
      console.error('[users] Query error:', usersError);
      return res.status(500).json({ error: 'Failed to load users' });
    }

    // Get all sessions with device info
    const { data: sessionsData, error: sessionsError } = await supabase
      .from('app_sessions')
      .select('user_id, country, city, start_time, end_time, created_at, is_device, device_brand, device_model, os_platform, os_version, app_version')
      .order('start_time', { ascending: false });

    if (sessionsError) {
      console.error('[users] Sessions query error:', sessionsError);
    }

    // Get tool usage events
    const { data: toolEventsData, error: toolEventsError } = await supabase
      .from('tool_usage_events')
      .select('user_id, tool_id, event_type, event_timestamp, created_at')
      .order('event_timestamp', { ascending: false });

    if (toolEventsError) {
      console.error('[users] Tool events query error:', toolEventsError);
    }

    // Build user session and tool info maps
    const userSessionInfo = new Map<string, {
      lastSeenAt: string | null;
      firstSessionAt: string | null;
      country: string | null;
      city: string | null;
      sessionCount: number;
      isRealDevice: boolean | null;
      deviceBrand: string | null;
      deviceModel: string | null;
      osPlatform: string | null;
      osVersion: string | null;
    }>();

    const userToolInfo = new Map<string, {
      toolsUsedCount: number;
      totalToolTimeSeconds: number;
    }>();

    if (sessionsData) {
      const userSessions = new Map<string, typeof sessionsData>();
      for (const session of sessionsData) {
        if (!userSessions.has(session.user_id)) {
          userSessions.set(session.user_id, []);
        }
        userSessions.get(session.user_id)!.push(session);
      }

      for (const [uId, sessions] of Array.from(userSessions.entries())) {
        const lastSession = sessions[0];
        const firstSession = sessions[sessions.length - 1];
        const lastSeenAt = lastSession?.start_time || lastSession?.created_at || null;
        const firstSessionAt = firstSession?.start_time || firstSession?.created_at || null;

        // Most used location
        const locationCounts = new Map<string, { country: string; city: string; count: number }>();
        for (const s of sessions) {
          if (s.country) {
            const key = `${s.country}|${s.city || ''}`;
            if (!locationCounts.has(key)) {
              locationCounts.set(key, { country: s.country, city: s.city || '', count: 0 });
            }
            locationCounts.get(key)!.count++;
          }
        }

        let mostUsedLocation = { country: null as string | null, city: null as string | null };
        let maxCount = 0;
        for (const loc of Array.from(locationCounts.values())) {
          if (loc.count > maxCount) {
            maxCount = loc.count;
            mostUsedLocation = { country: loc.country, city: loc.city || null };
          }
        }

        userSessionInfo.set(uId, {
          lastSeenAt,
          firstSessionAt,
          country: mostUsedLocation.country,
          city: mostUsedLocation.city,
          sessionCount: sessions.length,
          isRealDevice: lastSession?.is_device ?? null,
          deviceBrand: lastSession?.device_brand || null,
          deviceModel: lastSession?.device_model || null,
          osPlatform: lastSession?.os_platform || null,
          osVersion: lastSession?.os_version || null,
        });
      }
    }

    // Calculate tool usage per user
    if (toolEventsData) {
      const userTools = new Map<string, { tools: Set<string>; openTimes: Map<string, number>; totalTime: number }>();
      
      for (const event of toolEventsData) {
        if (!userTools.has(event.user_id)) {
          userTools.set(event.user_id, { tools: new Set(), openTimes: new Map(), totalTime: 0 });
        }
        const userData = userTools.get(event.user_id)!;
        userData.tools.add(event.tool_id);
        
        // Track open/close for duration calculation
        const eventTime = new Date(event.event_timestamp || event.created_at).getTime();
        if (event.event_type === 'open') {
          userData.openTimes.set(event.tool_id, eventTime);
        } else if (event.event_type === 'close') {
          const openTime = userData.openTimes.get(event.tool_id);
          if (openTime) {
            userData.totalTime += Math.max(0, (eventTime - openTime) / 1000);
            userData.openTimes.delete(event.tool_id);
          }
        }
      }

      for (const [uId, data] of Array.from(userTools.entries())) {
        userToolInfo.set(uId, {
          toolsUsedCount: data.tools.size,
          totalToolTimeSeconds: Math.round(data.totalTime),
        });
      }
    }

    let users: EnhancedUserRow[] = (usersData ?? []).map((row: any) => {
      const sessionInfo = userSessionInfo.get(row.auth_uid) || userSessionInfo.get(row.user_id);
      const toolInfo = userToolInfo.get(row.auth_uid) || userToolInfo.get(row.user_id);
      const insights = row.insights || {};
      const hasEmail = !!row.email;
      const hasName = !!(row.name || row.display_name);
      
      return {
        id: row.auth_uid || row.user_id,
        displayName: row.name || row.display_name || null,
        email: row.email || null,
        createdAt: row.created_at,
        lastSeenAt: sessionInfo?.lastSeenAt || row.last_synced_at || null,
        country: sessionInfo?.country || insights.country || null,
        city: sessionInfo?.city || insights.city || null,
        profession: insights.profession || null,
        specialty: insights.specialty || null,
        subspecialty: insights.subspecialty || null,
        hospital: insights.hospital || null,
        yearsExperience: insights.years_experience || null,
        insights: insights,
        // Enhanced fields
        isAnonymous: !hasEmail && !hasName,
        isRealDevice: sessionInfo?.isRealDevice ?? null,
        deviceBrand: sessionInfo?.deviceBrand || null,
        deviceModel: sessionInfo?.deviceModel || null,
        osPlatform: sessionInfo?.osPlatform || null,
        osVersion: sessionInfo?.osVersion || null,
        sessionCount: sessionInfo?.sessionCount || 0,
        lastSessionAt: sessionInfo?.lastSeenAt || null,
        toolsUsedCount: toolInfo?.toolsUsedCount || 0,
        totalToolTimeSeconds: toolInfo?.totalToolTimeSeconds || 0,
        firstSessionAt: sessionInfo?.firstSessionAt || row.created_at,
      };
    });

    // Apply filters
    if (filterAnonymous === 'true') {
      users = users.filter(u => u.isAnonymous);
    } else if (filterAnonymous === 'false') {
      users = users.filter(u => !u.isAnonymous);
    }

    if (filterDevice === 'real') {
      users = users.filter(u => u.isRealDevice === true);
    } else if (filterDevice === 'emulator') {
      users = users.filter(u => u.isRealDevice === false);
    }

    // Apply sorting
    users.sort((a, b) => {
      let aVal: any, bVal: any;
      switch (sortBy) {
        case 'sessionCount':
          aVal = a.sessionCount;
          bVal = b.sessionCount;
          break;
        case 'lastSessionAt':
          aVal = a.lastSessionAt ? new Date(a.lastSessionAt).getTime() : 0;
          bVal = b.lastSessionAt ? new Date(b.lastSessionAt).getTime() : 0;
          break;
        case 'toolsUsedCount':
          aVal = a.toolsUsedCount;
          bVal = b.toolsUsedCount;
          break;
        case 'totalToolTimeSeconds':
          aVal = a.totalToolTimeSeconds;
          bVal = b.totalToolTimeSeconds;
          break;
        case 'firstSessionAt':
          aVal = a.firstSessionAt ? new Date(a.firstSessionAt).getTime() : 0;
          bVal = b.firstSessionAt ? new Date(b.firstSessionAt).getTime() : 0;
          break;
        case 'createdAt':
        default:
          aVal = a.createdAt ? new Date(a.createdAt).getTime() : 0;
          bVal = b.createdAt ? new Date(b.createdAt).getTime() : 0;
          break;
      }
      return sortOrder === 'asc' ? aVal - bVal : bVal - aVal;
    });

    return res.status(200).json({
      users,
      total: users.length,
    });
  } catch (err) {
    console.error('[users] Endpoint error:', err);
    return res.status(500).json({ error: 'Unexpected error' });
  }
}

async function handleUserDetail(supabase: any, userId: string, res: NextApiResponse) {
  try {
    console.log('[handleUserDetail] Fetching user:', userId);
    
    // Get user - try both auth_uid and user_id
    let userData: any = null;
    let userError: any = null;
    
    // First try auth_uid
    const authResult = await supabase
      .from('users')
      .select('*')
      .eq('auth_uid', userId)
      .maybeSingle();
    
    if (authResult.data) {
      userData = authResult.data;
    } else {
      // Try user_id
      const userIdResult = await supabase
        .from('users')
        .select('*')
        .eq('user_id', userId)
        .maybeSingle();
      
      userData = userIdResult.data;
      userError = userIdResult.error;
    }

    if (!userData) {
      console.error('[users] User not found:', userError);
      return res.status(404).json({ error: 'User not found' });
    }

    console.log('[handleUserDetail] User found:', userData.auth_uid || userData.user_id);

    // Use both auth_uid and user_id to query sessions and events
    const userIdToQuery = userData.auth_uid || userData.user_id;

  // Get all sessions for this user
  const { data: sessionsData, error: sessionsError } = await supabase
    .from('app_sessions')
    .select('*')
    .eq('user_id', userIdToQuery)
    .order('start_time', { ascending: false });

  if (sessionsError) {
    console.error('[users] User sessions error:', sessionsError);
  }

  // Get all tool events for this user
  const { data: toolEventsData, error: toolEventsError } = await supabase
    .from('tool_usage_events')
    .select('*')
    .eq('user_id', userIdToQuery)
    .order('event_timestamp', { ascending: false });

  if (toolEventsError) {
    console.error('[users] User tool events error:', toolEventsError);
  }

  const sessions = sessionsData || [];
  const toolEvents = toolEventsData || [];

  console.log('[handleUserDetail] Found', sessions.length, 'sessions and', toolEvents.length, 'tool events');

  // Build session logs
  const sessionLogs: UserSessionLog[] = sessions.map((s: any) => {
    const startTime = new Date(s.start_time || s.created_at).getTime();
    const endTime = s.end_time ? new Date(s.end_time).getTime() : Date.now();
    return {
      id: s.id,
      startTime: s.start_time || s.created_at,
      endTime: s.end_time || null,
      durationSeconds: Math.round((endTime - startTime) / 1000),
      country: s.country || null,
      city: s.city || null,
      appVersion: s.app_version || null,
      osPlatform: s.os_platform || null,
      deviceBrand: s.device_brand || null,
      deviceModel: s.device_model || null,
      isDevice: s.is_device ?? null,
    };
  });

  // Build tool usage logs
  const toolMap = new Map<string, {
    usageCount: number;
    openTimes: Map<string, number>;
    totalTime: number;
    lastUsedAt: string | null;
    events: any[];
  }>();

  for (const event of toolEvents) {
    if (!toolMap.has(event.tool_id)) {
      toolMap.set(event.tool_id, {
        usageCount: 0,
        openTimes: new Map(),
        totalTime: 0,
        lastUsedAt: null,
        events: [],
      });
    }
    const toolData = toolMap.get(event.tool_id)!;
    
    const eventTime = new Date(event.event_timestamp || event.created_at).getTime();
    const eventTimeStr = event.event_timestamp || event.created_at;
    
    if (event.event_type === 'open') {
      toolData.usageCount++;
      toolData.openTimes.set(event.tool_session_id || event.id, eventTime);
    } else if (event.event_type === 'close') {
      const sessionKey = event.tool_session_id || event.id;
      const openTime = toolData.openTimes.get(sessionKey);
      if (openTime) {
        toolData.totalTime += Math.max(0, (eventTime - openTime) / 1000);
        toolData.openTimes.delete(sessionKey);
      }
    }
    
    if (!toolData.lastUsedAt || eventTimeStr > toolData.lastUsedAt) {
      toolData.lastUsedAt = eventTimeStr;
    }
    
    toolData.events.push({
      id: event.id,
      eventType: event.event_type,
      eventTimestamp: eventTimeStr,
      appSessionId: event.app_session_id,
      eventData: event.event_data ? JSON.parse(event.event_data) : null,
    });
  }

  const toolUsage: UserToolLog[] = Array.from(toolMap.entries()).map(([toolId, data]) => ({
    toolId,
    toolName: toolId, // Could be enhanced with tool name lookup
    usageCount: data.usageCount,
    totalTimeSeconds: Math.round(data.totalTime),
    lastUsedAt: data.lastUsedAt,
    events: data.events.slice(0, 50), // Limit events per tool
  })).sort((a, b) => b.usageCount - a.usageCount);

  // Build enhanced user row
  const insights = userData.insights || {};
  const lastSession = sessions[0];
  const firstSession = sessions[sessions.length - 1];
  const hasEmail = !!userData.email;
  const hasName = !!(userData.name || userData.display_name);

  const user: EnhancedUserRow = {
    id: userData.auth_uid || userData.user_id,
    displayName: userData.name || userData.display_name || null,
    email: userData.email || null,
    createdAt: userData.created_at,
    lastSeenAt: lastSession?.start_time || userData.last_synced_at || null,
    country: lastSession?.country || insights.country || null,
    city: lastSession?.city || insights.city || null,
    profession: insights.profession || null,
    specialty: insights.specialty || null,
    subspecialty: insights.subspecialty || null,
    hospital: insights.hospital || null,
    yearsExperience: insights.years_experience || null,
    insights: insights,
    isAnonymous: !hasEmail && !hasName,
    isRealDevice: lastSession?.is_device ?? null,
    deviceBrand: lastSession?.device_brand || null,
    deviceModel: lastSession?.device_model || null,
    osPlatform: lastSession?.os_platform || null,
    osVersion: lastSession?.os_version || null,
    sessionCount: sessions.length,
    lastSessionAt: lastSession?.start_time || null,
    toolsUsedCount: toolMap.size,
    totalToolTimeSeconds: Array.from(toolMap.values()).reduce((sum, t) => sum + Math.round(t.totalTime), 0),
    firstSessionAt: firstSession?.start_time || userData.created_at,
  };

  return res.status(200).json({
    user,
    sessions: sessionLogs,
    toolUsage,
  } as UserDetailResponse);
  } catch (error: any) {
    console.error('[handleUserDetail] Error:', error);
    return res.status(500).json({ error: error.message || 'Failed to fetch user details' });
  }
}
