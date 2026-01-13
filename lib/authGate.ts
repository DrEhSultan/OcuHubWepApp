import type { NextApiRequest } from 'next';
import { randomUUID, createHash } from 'crypto';
import { verifyFirebaseToken } from './firebaseVerify';
import type { SecurePathEnvNames } from './securePathConfig';

const toBool = (val: string | undefined, fallback: boolean) => {
  if (val === undefined) return fallback;
  return ['true', '1', 'yes', 'on'].includes(val.toLowerCase());
};

const toNumber = (val: string | undefined, fallback: number) => {
  const n = Number(val);
  return Number.isFinite(n) ? n : fallback;
};

const shouldLog = () => {
  const enabled = toBool(process.env.DEBUG_SECURE_GATE, false);
  if (!enabled) return false;
  const rate = toNumber(process.env.DEBUG_SAMPLE_RATE, 0.05);
  return Math.random() < rate;
};

const normalizePrivateKey = (raw: string | undefined) => {
  if (!raw) return raw;
  const trimmed = raw.trim();
  return trimmed.includes('\\n') ? trimmed.replace(/\\n/g, '\n') : trimmed;
};

const hashValue = (val: string | undefined | null) => {
  if (!val) return null;
  return createHash('sha256').update(val).digest('hex').slice(0, 12);
};

export const verifyAuthFromRequest = async (req: NextApiRequest, requestId?: string) => {
  const rid = requestId || (req.headers['x-request-id'] as string) || randomUUID();
  const authHeader = req.headers.authorization || '';
  const authScheme = authHeader.split(' ')[0] || null;
  const token = authHeader.startsWith('Bearer ') ? authHeader.slice(7) : '';
  const tokenMeta = {
    has_auth_header: !!authHeader,
    auth_scheme: authScheme,
    token_length: token ? token.length : 0,
    token_prefix: token ? token.slice(0, 12) : null,
  };

  if (!process.env.FIREBASE_PROJECT_ID || !process.env.FIREBASE_CLIENT_EMAIL || !normalizePrivateKey(process.env.FIREBASE_PRIVATE_KEY)) {
    return { ok: false, reason: 'missing_firebase_env', requestId: rid, tokenMeta };
  }

  const verification = await verifyFirebaseToken(token);
  const verificationError = !verification.ok ? (verification as any).error || 'invalid_token' : null;
  if (!verification.ok) {
    if (shouldLog()) {
      console.log(
        JSON.stringify({
          scope: 'auth_gate',
          requestId: rid,
          path: req.url,
          method: req.method,
          ...tokenMeta,
          verification_ok: false,
          verification_error: verificationError,
        })
      );
    }
    return { ok: false, reason: verificationError || 'invalid_token', requestId: rid, tokenMeta };
  }

  const uid = verification.authUid;
  const uidHash = hashValue(uid);

  if (shouldLog()) {
    console.log(
      JSON.stringify({
        scope: 'auth_gate',
        requestId: rid,
        path: req.url,
        method: req.method,
        ...tokenMeta,
        verification_ok: true,
        uid_hash: uidHash,
      })
    );
  }

  return { ok: true, uid, uidHash, requestId: rid, tokenMeta };
};

const parseCsv = (val: string | undefined) =>
  new Set((val || '').split(',').map((v) => v.trim()).filter(Boolean));

export const allowlistCheck = (
  uid: string | undefined,
  deviceId: string | undefined,
  usersEnvName: string,
  devicesEnvName: string
) => {
  const userSet = parseCsv(process.env[usersEnvName]);
  const deviceSet = parseCsv(process.env[devicesEnvName]);
  const userAllowed = uid ? userSet.has(uid) : false;
  const deviceAllowed = deviceId ? deviceSet.has(deviceId) : false;
  return {
    userAllowed,
    deviceAllowed,
    allowed: userAllowed || deviceAllowed,
    userSetSize: userSet.size,
    deviceSetSize: deviceSet.size,
  };
};

export const gateNewPath = async (
  req: NextApiRequest,
  featureFlagEnvName: string,
  usersEnvName: string,
  devicesEnvName: string,
  options?: { allowMissingTokenFallback?: 'legacy' | 'deny'; requestId?: string; featureTag?: SecurePathEnvNames['feature']; minVersionEnvName?: string }
) => {
  const rid = options?.requestId || (req.headers['x-request-id'] as string) || randomUUID();
  const featureEnabled = toBool(process.env[featureFlagEnvName], false);
  if (!featureEnabled) {
    return { mode: 'legacy' as const, reason: 'flag_disabled', requestId: rid };
  }

  const verification = await verifyAuthFromRequest(req, rid);
  if (!verification.ok) {
    if (options?.allowMissingTokenFallback === 'deny' && verification.reason === 'missing_token') {
      return { mode: 'deny' as const, reason: verification.reason, requestId: rid };
    }
    return { mode: 'legacy' as const, reason: verification.reason || 'invalid_token', requestId: rid };
  }

  const deviceId = (req.headers['x-device-id'] as string | undefined)?.trim();
  const allow = allowlistCheck(verification.uid, deviceId, usersEnvName, devicesEnvName);
  const allowlisted = allow.userAllowed || allow.deviceAllowed;
  // Optional minimum app version gate (if provided and not allowlisted)
  const appVersionHeader = (req.headers['x-app-version'] as string | undefined)?.trim();
  const minVersionEnvName = options?.minVersionEnvName;
  if (!allowlisted && minVersionEnvName && process.env[minVersionEnvName]) {
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
    if (appVersionHeader && compareVersions(appVersionHeader, process.env[minVersionEnvName]!) < 0) {
      if (shouldLog()) {
        console.log(
          JSON.stringify({
            scope: 'secure_path_decision',
            feature: options?.featureTag || 'unspecified',
            requestId: rid,
            final_mode: 'legacy',
            allowlisted,
            uid_hash: verification.uidHash || null,
            decision_reason: 'version_below_min',
          })
        );
      }
      return { mode: 'legacy' as const, reason: 'version_below_min', requestId: rid };
    }
  }
  const decision =
    allowlisted && verification.uid
      ? { mode: 'v2' as const, authUid: verification.uid, uidHash: verification.uidHash, requestId: rid, reason: 'allowlisted' }
      : { mode: 'legacy' as const, reason: 'not_allowlisted', requestId: rid };

  if (shouldLog()) {
    const finalMode = decision.mode === 'v2' ? 'secure' : 'legacy';
    console.log(
      JSON.stringify({
        scope: 'auth_gate',
        requestId: rid,
        path: req.url,
        method: req.method,
        token_length: verification.tokenMeta?.token_length,
        token_prefix: verification.tokenMeta?.token_prefix,
        auth_scheme: verification.tokenMeta?.auth_scheme,
        verification_ok: verification.ok,
        verification_error: verification.ok ? null : verification.reason,
        uid_hash: verification.uidHash || null,
        userAllowed: allow.userAllowed,
        deviceAllowed: allow.deviceAllowed,
        userSetSize: allow.userSetSize,
        deviceSetSize: allow.deviceSetSize,
        final_mode: finalMode,
        decision_reason: decision.reason,
        feature: options?.featureTag || null,
      })
    );
    console.log(
      JSON.stringify({
        scope: 'secure_path_decision',
        feature: options?.featureTag || 'unspecified',
        requestId: rid,
        final_mode: finalMode,
        allowlisted,
        uid_hash: verification.uidHash || null,
        decision_reason: decision.reason,
      })
    );
  }

  return decision;
};

export { normalizePrivateKey };
