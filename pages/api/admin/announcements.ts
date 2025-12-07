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
  expiresAt: z.string().optional().nullable(),
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
        .from('announcements')
        .select('*')
        .eq('is_deleted', false)
        .order('created_at', { ascending: false });

      if (error) {
        console.error('[announcements] Query error:', error);
        return res.status(500).json({ error: 'Failed to load announcements' });
      }

      const announcements: AnnouncementItem[] = (announcementsData ?? []).map((row: any) => ({
        id: row.id,
        title: row.title,
        content: row.message || row.body,
        severity: row.importance === 'high' ? 'critical' : row.importance === 'medium' ? 'warning' : 'info',
        status: row.is_active ? 'published' : 'draft',
        publishedAt: row.start_at,
        expiresAt: row.end_at,
        createdAt: row.created_at,
        createdBy: row.created_by || 'system',
      }));

      return res.status(200).json({
        announcements,
        total: announcements.length,
      });
    } catch (error) {
      console.error('[announcements] GET error:', error);
      return res.status(500).json({ error: 'Unexpected error' });
    }
  }

  // POST - Create new announcement
  if (req.method === 'POST') {
    try {
      const payload = createAnnouncementSchema.parse(req.body);

      const importance = payload.severity === 'critical' ? 'high' : payload.severity === 'warning' ? 'medium' : 'low';
      const isActive = payload.status === 'published';

      const { data: newAnnouncement, error } = await supabase
        .from('announcements')
        .insert({
          title: payload.title,
          message: payload.content,
          surface: 'home_banner',
          importance,
          is_active: isActive,
          start_at: isActive ? new Date().toISOString() : null,
          end_at: payload.expiresAt || null,
          created_by: adminSession.id,
        })
        .select('*')
        .single();

      if (error) {
        console.error('[announcements] Create error:', error);
        return res.status(500).json({ error: error.message ?? 'Failed to create announcement' });
      }

      return res.status(201).json({
        id: newAnnouncement.id,
        title: newAnnouncement.title,
        content: newAnnouncement.message,
        severity: payload.severity,
        status: payload.status,
        publishedAt: newAnnouncement.start_at,
        expiresAt: newAnnouncement.end_at,
        createdAt: newAnnouncement.created_at,
        createdBy: newAnnouncement.created_by,
      });
    } catch (error) {
      if (error instanceof z.ZodError) {
        return res.status(400).json({ error: 'Invalid payload', details: error.issues });
      }
      console.error('[announcements] POST error:', error);
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

      const updateData: Record<string, any> = {};
      
      if (payload.title !== undefined) updateData.title = payload.title;
      if (payload.content !== undefined) updateData.message = payload.content;
      if (payload.severity !== undefined) {
        updateData.importance = payload.severity === 'critical' ? 'high' : payload.severity === 'warning' ? 'medium' : 'low';
      }
      if (payload.status !== undefined) {
        updateData.is_active = payload.status === 'published';
        if (payload.status === 'published' && !updateData.start_at) {
          updateData.start_at = new Date().toISOString();
        }
      }
      if (payload.expiresAt !== undefined) updateData.end_at = payload.expiresAt;

      const { data: updatedAnnouncement, error } = await supabase
        .from('announcements')
        .update(updateData)
        .eq('id', id)
        .select('*')
        .single();

      if (error) {
        console.error('[announcements] Update error:', error);
        return res.status(500).json({ error: error.message ?? 'Failed to update announcement' });
      }

      if (!updatedAnnouncement) {
        return res.status(404).json({ error: 'Announcement not found' });
      }

      return res.status(200).json({
        id: updatedAnnouncement.id,
        title: updatedAnnouncement.title,
        content: updatedAnnouncement.message,
        severity: updatedAnnouncement.importance === 'high' ? 'critical' : updatedAnnouncement.importance === 'medium' ? 'warning' : 'info',
        status: updatedAnnouncement.is_active ? 'published' : 'draft',
        publishedAt: updatedAnnouncement.start_at,
        expiresAt: updatedAnnouncement.end_at,
        createdAt: updatedAnnouncement.created_at,
        createdBy: updatedAnnouncement.created_by,
      });
    } catch (error) {
      if (error instanceof z.ZodError) {
        return res.status(400).json({ error: 'Invalid payload' });
      }
      console.error('[announcements] PUT error:', error);
      return res.status(500).json({ error: 'Unexpected error' });
    }
  }

  // DELETE - Soft delete announcement
  if (req.method === 'DELETE') {
    try {
      const { id } = req.query;
      if (typeof id !== 'string') {
        return res.status(400).json({ error: 'Invalid announcement ID' });
      }

      const { error } = await supabase
        .from('announcements')
        .update({ is_deleted: true, deleted_at: new Date().toISOString(), deleted_by: adminSession.id })
        .eq('id', id);

      if (error) {
        console.error('[announcements] Delete error:', error);
        return res.status(500).json({ error: error.message ?? 'Failed to delete announcement' });
      }

      return res.status(204).send(null);
    } catch (error) {
      console.error('[announcements] DELETE error:', error);
      return res.status(500).json({ error: 'Unexpected error' });
    }
  }

  return res.status(405).json({ error: 'Method not allowed' });
}
