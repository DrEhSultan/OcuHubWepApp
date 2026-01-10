import type { NextApiRequest, NextApiResponse } from 'next';
import { getSupabaseAdmin } from '../../../lib/supabaseAdmin';
import { requireAdminApi } from '../../../lib/adminAuth';
import { withApiGuards } from '../../../lib/apiGuards';

export interface SurveyResponseRow {
  id: string;
  announcementId: string;
  announcementTitle: string;
  questionId: string;
  questionText: string;
  userId: string | null;
  userAuthUid: string | null;
  userName: string | null;
  userEmail: string | null;
  optionValue: string | null;
  textValue: string | null;
  numericValue: number | null;
  firstOptionValue: string | null;
  firstTextValue: string | null;
  firstNumericValue: number | null;
  firstAnsweredAt: string | null;
  linkToProfile: string | null;
  createdAt: string;
}

export interface SurveyResponsesResponse {
  responses: SurveyResponseRow[];
  total: number;
  surveys: { id: string; title: string; questionCount: number; responseCount: number }[];
}

async function handler(
  req: NextApiRequest,
  res: NextApiResponse<SurveyResponsesResponse | { error: string }>
) {
  if (req.method !== 'GET') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  const adminSession = requireAdminApi(req, res);
  if (!adminSession) {
    return null;
  }

  try {
    const supabase = getSupabaseAdmin();
    const { announcementId } = req.query;

    // Get all announcements that are surveys (have questions)
    const { data: surveysData, error: surveysError } = await supabase
      .from('announcements')
      .select('id, title, questions')
      .eq('kind', 'survey')
      .eq('is_deleted', false)
      .order('created_at', { ascending: false });

    if (surveysError) {
      console.error('[survey-responses] Surveys query error:', surveysError);
      return res.status(500).json({ error: 'Failed to load surveys' });
    }

    // Build survey list with question counts
    const surveys = (surveysData ?? []).map((s: any) => {
      const questions = Array.isArray(s.questions) ? s.questions : [];
      return {
        id: s.id,
        title: s.title,
        questionCount: questions.length,
        responseCount: 0, // Will be updated below
      };
    });

    // Build query for responses
    let responsesQuery = supabase
      .from('announcement_responses')
      .select('*')
      .order('created_at', { ascending: false })
      .limit(500);

    if (announcementId && typeof announcementId === 'string') {
      responsesQuery = responsesQuery.eq('announcement_id', announcementId);
    }

    const { data: responsesData, error: responsesError } = await responsesQuery;

    if (responsesError) {
      console.error('[survey-responses] Responses query error:', responsesError);
      return res.status(500).json({ error: 'Failed to load responses' });
    }

    // Get user info for responses
    const userAuthUids = Array.from(new Set((responsesData ?? []).map((r: any) => r.user_auth_uid).filter(Boolean)));
    
    let usersMap = new Map<string, { name: string | null; email: string | null }>();
    if (userAuthUids.length > 0) {
      const { data: usersData } = await supabase
        .from('users')
        .select('auth_uid, name, email')
        .in('auth_uid', userAuthUids);
      
      (usersData ?? []).forEach((u: any) => {
        usersMap.set(u.auth_uid, { name: u.name, email: u.email });
      });
    }

    // Build announcement map for titles and questions
    const announcementMap = new Map<string, { title: string; questions: any[] }>();
    (surveysData ?? []).forEach((s: any) => {
      announcementMap.set(s.id, {
        title: s.title,
        questions: Array.isArray(s.questions) ? s.questions : [],
      });
    });

    // Count responses per survey
    const responseCountMap = new Map<string, number>();
    (responsesData ?? []).forEach((r: any) => {
      const count = responseCountMap.get(r.announcement_id) || 0;
      responseCountMap.set(r.announcement_id, count + 1);
    });
    surveys.forEach((s) => {
      s.responseCount = responseCountMap.get(s.id) || 0;
    });

    // Transform responses
    const responses: SurveyResponseRow[] = (responsesData ?? []).map((r: any) => {
      const announcement = announcementMap.get(r.announcement_id);
      const question = announcement?.questions.find((q: any) => q.id === r.question_id);
      const user = usersMap.get(r.user_auth_uid);

      return {
        id: r.id,
        announcementId: r.announcement_id,
        announcementTitle: announcement?.title || 'Unknown Survey',
        questionId: r.question_id,
        questionText: question?.question || question?.text || r.question_id,
        userId: r.user_id,
        userAuthUid: r.user_auth_uid,
        userName: user?.name || null,
        userEmail: user?.email || null,
        optionValue: r.option_value,
        textValue: r.text_value,
        numericValue: r.numeric_value,
        firstOptionValue: r.first_option_value,
        firstTextValue: r.first_text_value,
        firstNumericValue: r.first_numeric_value,
        firstAnsweredAt: r.first_answered_at,
        linkToProfile: r.link_to_profile,
        createdAt: r.created_at,
      };
    });

    return res.status(200).json({
      responses,
      total: responses.length,
      surveys,
    });
  } catch (err) {
    console.error('[survey-responses] Endpoint error:', err);
    return res.status(500).json({ error: 'Unexpected error' });
  }
}

export default withApiGuards(handler, { requireCsrf: true });
