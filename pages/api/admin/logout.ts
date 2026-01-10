import type { NextApiRequest, NextApiResponse } from 'next';
import { clearAdminCookie } from '../../../lib/adminAuth';
import { withApiGuards } from '../../../lib/apiGuards';

async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  clearAdminCookie(res);
  return res.status(200).json({ success: true });
}

export default withApiGuards(handler, { requireCsrf: true });
