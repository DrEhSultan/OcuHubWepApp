import { NextApiRequest, NextApiResponse } from 'next';
import jwt from 'jsonwebtoken';
import { parse, serialize } from 'cookie';
import { AdminSession } from '../types/admin';

const ADMIN_COOKIE_NAME = 'ocuhub_admin_token';

const getSecret = (): string => {
  const secret = process.env.ADMIN_JWT_SECRET;
  if (!secret) {
    throw new Error('ADMIN_JWT_SECRET is not defined');
  }
  return secret;
};

export const signAdminToken = (payload: AdminSession): string => {
  return jwt.sign(payload, getSecret(), { expiresIn: '12h' });
};

export const verifyAdminToken = (token?: string | null): AdminSession | null => {
  if (!token) return null;
  try {
    return jwt.verify(token, getSecret()) as AdminSession;
  } catch {
    return null;
  }
};

export const setAdminCookie = (res: NextApiResponse, token: string) => {
  res.setHeader(
    'Set-Cookie',
    serialize(ADMIN_COOKIE_NAME, token, {
      httpOnly: true,
      secure: process.env.NODE_ENV === 'production',
      sameSite: 'lax',
      path: '/',
      maxAge: 60 * 60 * 12, // 12 hours
    })
  );
};

export const clearAdminCookie = (res: NextApiResponse) => {
  res.setHeader(
    'Set-Cookie',
    serialize(ADMIN_COOKIE_NAME, '', {
      httpOnly: true,
      secure: process.env.NODE_ENV === 'production',
      sameSite: 'lax',
      path: '/',
      maxAge: 0,
    })
  );
};

export const getTokenFromRequest = (req?: NextApiRequest | { headers?: { cookie?: string } } | null): string | undefined => {
  if (!req?.headers?.cookie) {
    return undefined;
  }
  const cookies = parse(req.headers.cookie);
  return cookies[ADMIN_COOKIE_NAME];
};

export const getAdminSessionFromRequest = (req?: NextApiRequest | { headers?: { cookie?: string } } | null): AdminSession | null => {
  const token = getTokenFromRequest(req);
  return verifyAdminToken(token);
};

export const requireAdminApi = (req: NextApiRequest, res: NextApiResponse): AdminSession | null => {
  const session = getAdminSessionFromRequest(req);
  if (!session) {
    res.status(401).json({ error: 'Unauthorized' });
    return null;
  }
  return session;
};
