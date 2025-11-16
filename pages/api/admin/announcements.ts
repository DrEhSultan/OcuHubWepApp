import type { NextApiRequest, NextApiResponse } from 'next';
import { getSupabaseAdmin } from '../../../lib/supabaseAdmin';
import { requireAdminApi } from '../../../lib/adminAuth';
import { z } from 'zod';

export interface AnnouncementItem {
  id: string;
  title: string;
  content?: string;
  severity: 'info' | 'warning' | 'critical';
  status: 'draft' | 'published' | 'archived';
  publishedAt: string | null;
  expiresAt: string | null;
  createdAt: string;
  createdBy: string;
}

export interface AnnouncementsListResponse {
  announcements: AnnouncementItem[];
  total: number;
}

const createAnnouncementSchema = z.object({
  title: z.string().min(1).max(255),
  content: z.string().optional(),
  severity: z.enum(['info', 'warning', 'critical']),
  status: z.enum(['draft', 'published', 'archived']).default('draft'),
  expiresAt: z.string().datetime().optional(),
});

const updateAnnouncementSchema = createAnnouncementSchema.partial();

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  const adminSession = requireAdminApi(req, res);
  if (!adminSession) {
    return null;
  }

  const supabase = getSupabaseAdmin();

  // GET all announcements
  if (req.method === 'GET') {
    try {
      const { data: announcementsData, error } = await supabase
        .from('app_announcements')
        .select('id,title,content,severity,status,published_at,expires_at,created_at,created_by')
        .order('published_at', { ascending: false });

      if (error) {
        console.error('Announcements query error:', error);
        return res.status(500).json({ error: 'Failed to load announcements' });
      }

      const announcements: AnnouncementItem[] = (announcementsData ?? []).map((row: any) => ({
        id: row.id,
        title: row.title,
        content: row.content,
        severity: row.severity ?? 'info',
        status: row.status ?? 'draft',
        publishedAt: row.published_at,
        expiresAt: row.expires_at,
        createdAt: row.created_at,
        createdBy: row.created_by,
      }));

      return res.status(200).json({
        announcements,
        total: announcements.length,
      });
    } catch (error) {
      console.error('Announcements GET error:', error);
      return res.status(500).json({ error: 'Unexpected error' });
    }
  }

  // POST - Create new announcement
  if (req.method === 'POST') {
    try {
      const payload = createAnnouncementSchema.parse(req.body);

      const { data: newAnnouncement, error } = await supabase
        .from('app_announcements')
        .insert({
          title: payload.title,
          content: payload.content,
          severity: payload.severity,
          status: payload.status,
          expires_at: payload.expiresAt || null,
          created_by: adminSession.id,
        })
        .select('id,title,content,severity,status,published_at,expires_at,created_at,created_by')
        .single();

      if (error) {
        console.error('Announcement create error:', error);
        return res.status(500).json({ error: 'Failed to create announcement' });
      }

      return res.status(201).json({
        id: newAnnouncement.id,
        title: newAnnouncement.title,
        content: newAnnouncement.content,
        severity: newAnnouncement.severity,
        status: newAnnouncement.status,
        publishedAt: newAnnouncement.published_at,
        expiresAt: newAnnouncement.expires_at,
        createdAt: newAnnouncement.created_at,
        createdBy: newAnnouncement.created_by,
      });
    } catch (error) {
      if (error instanceof z.ZodError) {
        return res.status(400).json({ error: 'Invalid payload' });
      }
      console.error('Announcement POST error:', error);
      return res.status(500).json({ error: 'Unexpected error' });
    }
  }

  // PUT - Update announcement
  if (req.method === 'PUT') {
    try {
      const { id } = req.query;
      if (typeof id !== 'string') {
        return res.status(400).json({ error: 'Invalid announcement ID' });
      }

      const payload = updateAnnouncementSchema.parse(req.body);

      const updateData: Record<string, any> = {
        title: payload.title,
        content: payload.content,
        severity: payload.severity,
        status: payload.status,
        expires_at: payload.expiresAt || null,
      };

      // Only include fields that were actually provided
      Object.keys(updateData).forEach(key => {
        if (updateData[key] === undefined) {
          delete updateData[key];
        }
      });

      if (payload.status === 'published') {
        updateData.published_at = new Date().toISOString();
      }

      const { data: updatedAnnouncement, error } = await supabase
        .from('app_announcements')
        .update(updateData)
        .eq('id', id)
        .select('id,title,content,severity,status,published_at,expires_at,created_at,created_by')
        .single();

      if (error) {
        console.error('Announcement update error:', error);
        return res.status(500).json({ error: 'Failed to update announcement' });
      }

      if (!updatedAnnouncement) {
        return res.status(404).json({ error: 'Announcement not found' });
      }

      return res.status(200).json({
        id: updatedAnnouncement.id,
        title: updatedAnnouncement.title,
        content: updatedAnnouncement.content,
        severity: updatedAnnouncement.severity,
        status: updatedAnnouncement.status,
        publishedAt: updatedAnnouncement.published_at,
        expiresAt: updatedAnnouncement.expires_at,
        createdAt: updatedAnnouncement.created_at,
        createdBy: updatedAnnouncement.created_by,
      });
    } catch (error) {
      if (error instanceof z.ZodError) {
        return res.status(400).json({ error: 'Invalid payload' });
      }
      console.error('Announcement PUT error:', error);
      return res.status(500).json({ error: 'Unexpected error' });
    }
  }

  // DELETE - Delete announcement
  if (req.method === 'DELETE') {
    try {
      const { id } = req.query;
      if (typeof id !== 'string') {
        return res.status(400).json({ error: 'Invalid announcement ID' });
      }

      const { error } = await supabase
        .from('app_announcements')
        .delete()
        .eq('id', id);

      if (error) {
        console.error('Announcement delete error:', error);
        return res.status(500).json({ error: 'Failed to delete announcement' });
      }

      return res.status(204).send(null);
    } catch (error) {
      console.error('Announcement DELETE error:', error);
      return res.status(500).json({ error: 'Unexpected error' });
    }
  }

  return res.status(405).json({ error: 'Method not allowed' });
}
