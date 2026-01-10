import type { NextApiHandler, NextApiRequest, NextApiResponse } from 'next';

type RateLimitConfig = {
  windowMs: number;
  limit: number;
};

type GuardOptions = {
  rateLimit?: RateLimitConfig;
  requireCsrf?: boolean;
  cors?: boolean;
};

const defaultRateLimit: RateLimitConfig = {
  windowMs: 60_000, // 1 minute
  limit: 120, // generous default to avoid breaking existing clients
};

const defaultAllowedOrigins = (() => {
  const envOrigins = process.env.API_ALLOWED_ORIGINS
    ?.split(',')
    .map((o) => o.trim())
    .filter(Boolean);

  return envOrigins && envOrigins.length > 0
    ? envOrigins
    : ['http://localhost:3000', 'https://localhost:3000'];
})();

const rateLimitStore = new Map<string, { count: number; reset: number }>();

const getClientIp = (req: NextApiRequest): string => {
  const xfwd = req.headers['x-forwarded-for'];
  if (typeof xfwd === 'string') {
    return xfwd.split(',')[0]?.trim() || 'unknown';
  }
  if (Array.isArray(xfwd) && xfwd.length > 0) {
    return xfwd[0].split(',')[0]?.trim() || 'unknown';
  }
  return req.socket?.remoteAddress || 'unknown';
};

const isOriginAllowed = (origin?: string | null): boolean => {
  if (!origin) return true; // allow mobile/native fetches without Origin
  return defaultAllowedOrigins.some((allowed) => origin === allowed);
};

const applyCors = (req: NextApiRequest, res: NextApiResponse): { ok: boolean; ended: boolean } => {
  const origin = req.headers.origin || null;
  const originAllowed = isOriginAllowed(origin);

  if (origin && originAllowed) {
    res.setHeader('Access-Control-Allow-Origin', origin);
    res.setHeader('Vary', 'Origin');
  }

  res.setHeader('Access-Control-Allow-Methods', 'GET,POST,PUT,DELETE,OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type,Authorization');
  res.setHeader('Access-Control-Allow-Credentials', 'true');

  if (req.method === 'OPTIONS') {
    res.status(200).end();
    return { ok: false, ended: true };
  }

  if (origin && !originAllowed) {
    res.status(403).json({ error: 'Forbidden' });
    return { ok: false, ended: true };
  }

  return { ok: true, ended: false };
};

const applyRateLimit = (req: NextApiRequest, res: NextApiResponse, cfg: RateLimitConfig): boolean => {
  const key = `${req.url || ''}:${getClientIp(req)}`;
  const now = Date.now();
  const existing = rateLimitStore.get(key);

  if (!existing || now > existing.reset) {
    rateLimitStore.set(key, { count: 1, reset: now + cfg.windowMs });
    return true;
  }

  if (existing.count >= cfg.limit) {
    res.status(429).json({ error: 'Too many requests' });
    return false;
  }

  existing.count += 1;
  return true;
};

const applyCsrf = (req: NextApiRequest, res: NextApiResponse): boolean => {
  if (req.method === 'GET' || req.method === 'HEAD' || req.method === 'OPTIONS') {
    return true;
  }

  const origin = req.headers.origin || null;
  const referer = req.headers.referer || null;

  if (origin && isOriginAllowed(origin)) {
    return true;
  }

  if (referer) {
    try {
      const refUrl = new URL(referer);
      if (isOriginAllowed(`${refUrl.protocol}//${refUrl.host}`)) {
        return true;
      }
    } catch {
      // ignore parse errors
    }
  }

  res.status(403).json({ error: 'Forbidden' });
  return false;
};

export const withApiGuards = (
  handler: NextApiHandler,
  options: GuardOptions = {}
): NextApiHandler => {
  const rateCfg = options.rateLimit ?? defaultRateLimit;
  const enableCors = options.cors !== false;

  return async (req: NextApiRequest, res: NextApiResponse) => {
    // CORS (handles OPTIONS early exit)
    if (enableCors) {
      const corsResult = applyCors(req, res);
      if (!corsResult.ok) {
        return;
      }
    }

    // Rate limiting
    if (!applyRateLimit(req, res, rateCfg)) {
      return;
    }

    // CSRF (admin-only callers)
    if (options.requireCsrf && !applyCsrf(req, res)) {
      return;
    }

    return handler(req, res);
  };
};
