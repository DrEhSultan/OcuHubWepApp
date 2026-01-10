import { createClient } from '@supabase/supabase-js';
import { verifyFirebaseToken } from './firebaseVerify';
import type { NextApiRequest } from 'next';

const boolFromEnv = (value: string | undefined, defaultValue: boolean) => {
  if (value === undefined) return defaultValue;
  return ['true', '1', 'yes', 'on'].includes(value.toLowerCase());
};

const parsePercent = (value: string | undefined, defaultValue: number): number => {
  if (!value) return defaultValue;
  const parsed = Number(value);
  if (Number.isNaN(parsed) || parsed < 0) return defaultValue;
  return Math.min(parsed, 100);
};

const parseCsv = (value: string | undefined): Set<string> => {
  if (!value) return new Set();
  return new Set(
    value
      .split(',')
      .map((v) => v.trim())
      .filter(Boolean)
  );
};

const compareVersions = (a: string, b: string): number => {
  const pa = a.split('.').map((n) => parseInt(n, 10));
  const pb = b.split('.').map((n) => parseInt(n, 10));
  const len = Math.max(pa.length, pb.length);
  for (let i = 0; i < len; i++) {
    const av = pa[i] || 0;
    const bv = pb[i] || 0;
    if (av > bv) return 1;
    if (av < bv) return -1;
  }
  return 0;
};

const hashString = (value: string): number => {
  let hash = 0;
  for (let i = 0; i < value.length; i++) {
    hash = (hash << 5) - hash + value.charCodeAt(i);
    hash |= 0;
  }
  return Math.abs(hash);
};

const getRequestIp = (req: NextApiRequest): string => {
  const xfwd = req.headers['x-forwarded-for'];
  if (typeof xfwd === 'string' && xfwd.length > 0) {
    return xfwd.split(',')[0]?.trim() || 'unknown';
  }
  if (Array.isArray(xfwd) && xfwd.length > 0) {
    return xfwd[0].split(',')[0]?.trim() || 'unknown';
  }
  return req.socket?.remoteAddress || 'unknown';
};

export type V2Eligibility = {
  enabled: boolean;
  reason?: string;
  authUid?: string;
  forced?: boolean;
};

export const shouldUseAnnouncementV2 = async (req: NextApiRequest): Promise<V2Eligibility> => {
  // V1 naming: prefer V1 envs; fall back to legacy V2 names if present
  const enabledFlag =
    boolFromEnv(process.env.ANNOUNCEMENTS_V1_ENABLED, false) ||
    boolFromEnv(process.env.ANNOUNCEMENTS_V2_ENABLED, false);
  if (!enabledFlag) {
    return { enabled: false, reason: 'flag_disabled' };
  }

  // Require anon key and Firebase env for v2
  if (!process.env.NEXT_PUBLIC_SUPABASE_URL || !process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY) {
    return { enabled: false, reason: 'missing_supabase_env' };
  }
  if (!process.env.FIREBASE_PROJECT_ID && !process.env.FIREBASE_PRIVATE_KEY) {
    return { enabled: false, reason: 'missing_firebase_env' };
  }

  // Verify Firebase token first (needed for authUid allowlist)
  const authHeader = req.headers.authorization;
  const token = authHeader?.startsWith('Bearer ') ? authHeader.slice(7) : undefined;
  const verification = await verifyFirebaseToken(token);
  if (!verification.ok) {
    return { enabled: false, reason: 'invalid_token' };
  }

  const authUid = verification.authUid;
  const testUsers = parseCsv(process.env.ANNOUNCEMENTS_V1_TEST_USERS || process.env.ANNOUNCEMENTS_V2_TEST_USERS);
  const testDevices = parseCsv(process.env.ANNOUNCEMENTS_V1_TEST_DEVICES || process.env.ANNOUNCEMENTS_V2_TEST_DEVICES);
  const deviceIdHeader = (req.headers['x-device-id'] as string | undefined)?.trim();

  // Strict allowlist: if set, only allow listed auth_uids or device_ids
  if (testUsers.size > 0 || testDevices.size > 0) {
    const userAllowed = testUsers.has(authUid);
    const deviceAllowed = deviceIdHeader ? testDevices.has(deviceIdHeader) : false;
    if (!userAllowed && !deviceAllowed) {
      return { enabled: false, reason: 'not_in_allowlist' };
    }
    // Force v2 for allowlisted callers regardless of version/percent
    return { enabled: true, authUid, forced: true };
  }

  const minVersion = process.env.ANNOUNCEMENTS_V1_MIN_APP_VERSION || process.env.ANNOUNCEMENTS_V2_MIN_APP_VERSION;
  const appVersionHeader = (req.headers['x-app-version'] as string | undefined)?.trim();
  if (minVersion && appVersionHeader) {
    if (compareVersions(appVersionHeader, minVersion) < 0) {
      return { enabled: false, reason: 'version_below_min' };
    }
  }

  // Percent-based rollout is intentionally disabled for V1.0.0 hardening even if env values are present.
  const rolloutPercent = 0;
  if (rolloutPercent > 0) {
    const ip = getRequestIp(req);
    const bucket = hashString(ip) % 100;
    if (bucket >= rolloutPercent) {
      return { enabled: false, reason: 'percent_bucket' };
    }
  }

  return { enabled: true, authUid };
};

export const getSupabaseAnonClientWithAuth = (firebaseToken: string) => {
  const url = process.env.NEXT_PUBLIC_SUPABASE_URL!;
  const anonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!;

  return createClient(url, anonKey, {
    global: {
      headers: {
        Authorization: `Bearer ${firebaseToken}`,
      },
    },
  });
};
