import { createClient } from '@supabase/supabase-js';
import type { NextApiRequest } from 'next';
import { randomUUID } from 'crypto';
import { gateNewPath } from './authGate';
import { getSecurePathEnv } from './securePathConfig';

export type V2Eligibility = {
  enabled: boolean;
  reason?: string;
  authUid?: string;
  forced?: boolean;
  requestId?: string;
};

export const shouldUseAnnouncementV2 = async (req: NextApiRequest): Promise<V2Eligibility> => {
  const envNames = getSecurePathEnv('announcements');
  const decision = await gateNewPath(
    req,
    envNames.enabledEnv,
    envNames.usersEnv,
    envNames.devicesEnv,
    { allowMissingTokenFallback: 'legacy', featureTag: 'announcements', minVersionEnvName: envNames.minVersionEnv }
  );
  const requestId = decision.requestId || randomUUID();
  if (decision.mode === 'v2') {
    return { enabled: true, authUid: (decision as any).authUid, requestId };
  }
  return { enabled: false, reason: decision.reason, requestId };
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
