import { getApps, initializeApp, cert, applicationDefault } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';

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

  try {
    const app = getFirebaseApp();
    const decoded = await getAuth(app).verifyIdToken(token, true);
    return { ok: true, authUid: decoded.uid, email: decoded.email ?? null };
  } catch (error: any) {
    return { ok: false, error: error?.message || 'invalid_token' };
  }
};
