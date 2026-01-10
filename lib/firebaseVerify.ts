import { getApps, initializeApp, cert, applicationDefault } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';
import { randomUUID } from 'crypto';

type VerifyResult =
  | { ok: true; authUid: string; email?: string | null }
  | { ok: false; error: string };

const normalizeFirebasePrivateKey = (raw: string | undefined) => {
  if (!raw) return raw;
  const trimmed = raw.trim();
  return trimmed.includes('\\n') ? trimmed.replace(/\\n/g, '\n') : trimmed;
};

const getFirebaseApp = () => {
  if (getApps().length) {
    return getApps()[0];
  }

  const projectId = process.env.FIREBASE_PROJECT_ID;
  const clientEmail = process.env.FIREBASE_CLIENT_EMAIL;
  const privateKey = normalizeFirebasePrivateKey(process.env.FIREBASE_PRIVATE_KEY);

  // Prefer explicit service account; fall back to ADC if available
  const rawKey = process.env.FIREBASE_PRIVATE_KEY || '';
  console.log(
    JSON.stringify({
      scope: 'firebase_verify_env',
      requestId: randomUUID(),
      has_project_id: !!projectId,
      project_id_length: (projectId || '').length,
      has_private_key: !!privateKey,
      private_key_length: rawKey.length,
      private_key_contains_begin_marker: rawKey.includes('BEGIN PRIVATE KEY'),
      private_key_contains_end_marker: rawKey.includes('END PRIVATE KEY'),
      private_key_contains_newlines: rawKey.includes('\n'),
      private_key_contains_escaped_newlines: rawKey.includes('\\n'),
      private_key_has_markers: rawKey.includes('BEGIN PRIVATE KEY') && rawKey.includes('END PRIVATE KEY'),
    })
  );
  if (projectId && clientEmail && privateKey) {
    return initializeApp({
      credential: cert({
        projectId,
        clientEmail,
        privateKey,
      }),
    });
  }

  // Attempt to use application default credentials
  return initializeApp({
    credential: applicationDefault(),
  });
};

export const verifyFirebaseToken = async (token: string | undefined | null): Promise<VerifyResult> => {
  if (!token) {
    return { ok: false, error: 'missing_token' };
  }

  // Lightweight decode (no signature verification) to log aud/iss/sub/kid for diagnostics
  const parts = token.split('.');
  let decodedHeader: any = null;
  let decodedPayload: any = null;
  if (parts.length >= 2) {
    try {
      const base64UrlToJson = (str: string) =>
        JSON.parse(Buffer.from(str.replace(/-/g, '+').replace(/_/g, '/'), 'base64').toString('utf8'));
      decodedHeader = base64UrlToJson(parts[0]);
      decodedPayload = base64UrlToJson(parts[1]);
    } catch {
      // ignore decode errors
    }
  }

  console.log(
    JSON.stringify({
      scope: 'firebase_verify_token_debug',
      requestId: randomUUID(),
      token_present: !!token,
      token_length: token.length,
      token_prefix: token.slice(0, 10),
      decoded_aud: decodedPayload?.aud || null,
      decoded_iss: decodedPayload?.iss || null,
      decoded_sub: decodedPayload?.sub || null,
      header_kid: decodedHeader?.kid || null,
    })
  );

  try {
    const app = getFirebaseApp();
    const decoded = await getAuth(app).verifyIdToken(token, true);
    return { ok: true, authUid: decoded.uid, email: decoded.email ?? null };
  } catch (error: any) {
    console.error(
      JSON.stringify({
        scope: 'firebase_verify',
        requestId: randomUUID(),
        error: error?.message || 'invalid_token',
      })
    );
    return { ok: false, error: error?.message || 'invalid_token' };
  }
};
