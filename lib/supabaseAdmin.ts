import { createClient, SupabaseClient } from '@supabase/supabase-js';

let cachedClient: SupabaseClient | null = null;

const getEnv = (key: string, fallbackKey?: string) => {
  const value = process.env[key] || (fallbackKey ? process.env[fallbackKey] : undefined);
  if (!value) {
    const keys = fallbackKey ? `${key} or ${fallbackKey}` : key;
    throw new Error(`Missing required environment variable: ${keys}`);
  }
  return value;
};

export const getSupabaseAdmin = (): SupabaseClient => {
  if (cachedClient) {
    return cachedClient;
  }

  // Try SUPABASE_URL first, fall back to NEXT_PUBLIC_SUPABASE_URL
  const url = getEnv('SUPABASE_URL', 'NEXT_PUBLIC_SUPABASE_URL');
  const serviceRoleKey = getEnv('SUPABASE_SERVICE_ROLE_KEY');

  console.log('[supabaseAdmin] Creating client with URL:', url.substring(0, 30) + '...');

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
