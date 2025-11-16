import { createClient, SupabaseClient } from '@supabase/supabase-js';

let cachedClient: SupabaseClient | null = null;

const getEnv = (key: string) => {
  const value = process.env[key];
  if (!value) {
    throw new Error(`Missing required environment variable: ${key}`);
  }
  return value;
};

export const getSupabaseAdmin = (): SupabaseClient => {
  if (cachedClient) {
    return cachedClient;
  }

  const url = getEnv('SUPABASE_URL');
  const serviceRoleKey = getEnv('SUPABASE_SERVICE_ROLE_KEY');

  cachedClient = createClient(url, serviceRoleKey, {
    auth: { persistSession: false },
    global: {
      headers: {
        'x-ocuhub-client': 'admin-dashboard',
      },
    },
  });

  return cachedClient;
};
