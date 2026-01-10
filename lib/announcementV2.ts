import { createClient } from '@supabase/supabase-js';
import { verifyFirebaseToken } from './firebaseVerify';
import type { NextApiRequest } from 'next';
import { randomUUID, createHash } from 'crypto';

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
  requestId?: string;
};

const normalizeFirebasePrivateKey = (raw: string | undefined) => {
  if (!raw) return raw;
  const trimmed = raw.trim();
  return trimmed.includes('\\n') ? trimmed.replace(/\\n/g, '\n') : trimmed;
};

const hashUid = (uid: string) => createHash('sha256').update(uid).digest('hex').slice(0, 12);

export const shouldUseAnnouncementV2 = async (req: NextApiRequest): Promise<V2Eligibility> => {
  const requestId = randomUUID();
  // V1 naming: prefer V1 envs; fall back to legacy V2 names if present
  const enabledFlag =
    boolFromEnv(process.env.ANNOUNCEMENTS_V1_ENABLED, false) ||
    boolFromEnv(process.env.ANNOUNCEMENTS_V2_ENABLED, false);
  if (!enabledFlag) {
    console.log(
      JSON.stringify({
        scope: 'announcements/eligibility_gate',
        requestId,
        step: 'flag_check',
        enabledFlag: false,
      })
    );
    logDecision({ requestId, enabled: false, reason: 'flag_disabled' });
    return { enabled: false, reason: 'flag_disabled', requestId };
  }

  // Require anon key and Firebase env for v2
  if (!process.env.NEXT_PUBLIC_SUPABASE_URL || !process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY) {
    console.log(
      JSON.stringify({
        scope: 'announcements/eligibility_gate',
        requestId,
        step: 'supabase_env',
        has_url: !!process.env.NEXT_PUBLIC_SUPABASE_URL,
        has_anon: !!process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY,
      })
    );
    logDecision({ requestId, enabled: false, reason: 'missing_supabase_env' });
    return { enabled: false, reason: 'missing_supabase_env', requestId };
  }
  const normalizedPrivateKey = normalizeFirebasePrivateKey(process.env.FIREBASE_PRIVATE_KEY);
  const hasProjectId = !!process.env.FIREBASE_PROJECT_ID;
  const hasPrivateKey = !!normalizedPrivateKey;
  if (!hasProjectId || !hasPrivateKey) {
    const rawKey = process.env.FIREBASE_PRIVATE_KEY || '';
    console.log(
      JSON.stringify({
        scope: 'announcements/eligibility_gate',
        requestId,
        step: 'firebase_env',
        has_project: hasProjectId,
        project_id_length: (process.env.FIREBASE_PROJECT_ID || '').length,
        has_private_key: hasPrivateKey,
        private_key_length: rawKey.length,
        private_key_contains_begin_marker: rawKey.includes('BEGIN PRIVATE KEY'),
        private_key_contains_end_marker: rawKey.includes('END PRIVATE KEY'),
        private_key_contains_newlines: rawKey.includes('\n'),
        private_key_contains_escaped_newlines: rawKey.includes('\\n'),
        env_source_hint: 'process.env direct',
      })
    );
    logDecision({ requestId, enabled: false, reason: 'missing_firebase_env' });
    return { enabled: false, reason: 'missing_firebase_env', requestId };
  }

  // Verify Firebase token first (needed for authUid allowlist)
  const authHeader = req.headers.authorization;
  const token = authHeader?.startsWith('Bearer ') ? authHeader.slice(7) : undefined;
  const verification = await verifyFirebaseToken(token);
  if (!verification.ok) {
    console.log(
      JSON.stringify({
        scope: 'announcements/eligibility_gate',
        requestId,
        step: 'token_verification',
        has_token: !!token,
        has_auth_header: !!authHeader,
        auth_scheme: authHeader?.split(' ')[0] || null,
        verification_ok: false,
        reason: 'invalid_token',
        verification_error: !verification.ok ? (verification as any).error || null : null,
        token_length: token?.length || 0,
        token_prefix: token ? token.slice(0, 10) : null,
      })
    );
    logDecision({ requestId, enabled: false, reason: 'invalid_token' });
    return { enabled: false, reason: 'invalid_token', requestId };
  }

  const authUid = verification.authUid;
  const testUsers = parseCsv(process.env.ANNOUNCEMENTS_V1_TEST_USERS || process.env.ANNOUNCEMENTS_V2_TEST_USERS);
  const testDevices = parseCsv(process.env.ANNOUNCEMENTS_V1_TEST_DEVICES || process.env.ANNOUNCEMENTS_V2_TEST_DEVICES);
  const deviceIdHeader = (req.headers['x-device-id'] as string | undefined)?.trim();

  // Strict allowlist: if set, only allow listed auth_uids or device_ids
  if (testUsers.size > 0 || testDevices.size > 0) {
    const userAllowed = testUsers.has(authUid);
    const deviceAllowed = deviceIdHeader ? testDevices.has(deviceIdHeader) : false;
    console.log(
      JSON.stringify({
        scope: 'announcements/eligibility_gate',
        requestId,
        step: 'allowlist',
        uid_hash: hashUid(authUid),
        test_users_count: testUsers.size,
        test_devices_count: testDevices.size,
        userAllowed,
        deviceAllowed,
      })
    );
    if (!userAllowed && !deviceAllowed) {
      logDecision({ requestId, enabled: false, reason: 'not_in_allowlist', authUid });
      return { enabled: false, reason: 'not_in_allowlist', requestId };
    }
    // Force v2 for allowlisted callers regardless of version/percent
    logDecision({ requestId, enabled: true, authUid, forced: true });
    return { enabled: true, authUid, forced: true, requestId };
  }

  const minVersion = process.env.ANNOUNCEMENTS_V1_MIN_APP_VERSION || process.env.ANNOUNCEMENTS_V2_MIN_APP_VERSION;
  const appVersionHeader = (req.headers['x-app-version'] as string | undefined)?.trim();
  if (minVersion && appVersionHeader) {
    if (compareVersions(appVersionHeader, minVersion) < 0) {
      logDecision({ requestId, enabled: false, reason: 'version_below_min', authUid });
      return { enabled: false, reason: 'version_below_min', requestId };
    }
  }

  // Percent-based rollout is intentionally disabled for V1.0.0 hardening even if env values are present.
  const rolloutPercent = 0;
  if (rolloutPercent > 0) {
    const ip = getRequestIp(req);
    const bucket = hashString(ip) % 100;
    if (bucket >= rolloutPercent) {
      logDecision({ requestId, enabled: false, reason: 'percent_bucket', authUid });
      return { enabled: false, reason: 'percent_bucket', requestId };
    }
  }

  logDecision({ requestId, enabled: true, authUid });
  return { enabled: true, authUid, requestId };
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

const logDecision = ({
  requestId,
  enabled,
  reason,
  authUid,
  forced,
}: {
  requestId: string;
  enabled: boolean;
  reason?: string;
  authUid?: string;
  forced?: boolean;
}) => {
  console.log(
    JSON.stringify({
      scope: 'announcements/eligibility_gate',
      requestId,
      step: 'final_decision',
      enabled,
      reason: reason || null,
      uid_hash: authUid ? hashUid(authUid) : null,
      forced: !!forced,
    })
  );
};
