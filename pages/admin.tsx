import Head from 'next/head';
import { useEffect, useMemo, useState, type ReactNode } from 'react';
import type { Session } from '@supabase/supabase-js';
import {
  Area,
  AreaChart,
  Bar,
  BarChart,
  CartesianGrid,
  Cell,
  Legend,
  Pie,
  PieChart,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from 'recharts';
import { supabaseClient } from '../lib/supabaseClient';
import { EnhancedUsersPanel } from '../components/EnhancedUsersPanel';

type ToolSummary = {
  id: string;
  name: string;
  slug: string;
  usage_count: number;
  total_duration_seconds: number;
  days_used: number;
  months_used: number;
  years_used: number;
  last_used_at: string | null;
  unique_users: number;
  session_count: number;
  country_count: number;
  city_count: number;
  avg_usage_per_user: number;
  avg_time_per_user_seconds: number;
  avg_calc_time_ms?: number;
  usage_by_date?: { date: string; count: number }[];
  duration_by_date?: { date: string; total_seconds: number }[];
  country_breakdown?: { country: string; count: number }[];
};

type UserToolUsage = {
  tool_slug: string;
  tool_name: string;
  usage_count: number;
  total_time_seconds: number;
  days_used: number;
  last_used_at: string | null;
};

type UserSummary = {
  user_id: string;
  full_name: string | null;
  email: string | null;
  country: string | null;
  city: string | null;
  total_sessions: number;
  most_used_tool: string | null;
  tools?: UserToolUsage[];
  locations?: { country: string | null; city: string | null; sessions: number }[];
};

type Feedback = {
  id: string;
  message: string;
  tool_slug: string | null;
  feedback_type: string | null;
  created_at: string;
  conclusion?: Record<string, unknown> | null;
};

type AnnouncementQuestion = {
  id: string;
  prompt: string;
  type: 'yes_no' | 'single_choice' | 'multi_choice' | 'text' | 'number';
  options?: string[];
  required: boolean;
};

type AnnouncementDraft = {
  title: string;
  body: string;
  kind: 'announcement' | 'survey';
  start_at: string;
  end_at: string;
  priority: 'low' | 'normal' | 'high';
  audience: 'all' | 'doctors' | 'residents' | 'students';
  show_in_carousel: boolean;
  show_in_notifications: boolean;
  max_impressions: number | null;
  questions: AnnouncementQuestion[];
};

type Announcement = AnnouncementDraft & {
  id: string;
  status: 'scheduled' | 'live' | 'ended';
  responses?: {
    question_id: string;
    option?: string;
    value?: string | number;
    count: number;
  }[];
};

type AdminProfile = {
  id: string;
  email: string;
  role: 'admin' | 'superadmin';
  last_login_at: string | null;
};

const chartPalette = ['#2563eb', '#7c3aed', '#06b6d4', '#22c55e', '#f97316', '#ef4444'];

const fallbackTools: ToolSummary[] = [
  {
    id: 'iol-power',
    name: 'IOL Power Calculator',
    slug: 'iol_power',
    usage_count: 1420,
    total_duration_seconds: 48200,
    days_used: 180,
    months_used: 8,
    years_used: 1,
    last_used_at: new Date().toISOString(),
    unique_users: 320,
    session_count: 2100,
    country_count: 22,
    city_count: 85,
    avg_usage_per_user: 4.4,
    avg_time_per_user_seconds: 150,
    avg_calc_time_ms: 920,
    usage_by_date: Array.from({ length: 12 }).map((_, idx) => ({
      date: `2024-${String(idx + 1).padStart(2, '0')}-01`,
      count: Math.round(40 + Math.random() * 120),
    })),
    duration_by_date: Array.from({ length: 12 }).map((_, idx) => ({
      date: `2024-${String(idx + 1).padStart(2, '0')}-01`,
      total_seconds: Math.round(1800 + Math.random() * 4600),
    })),
    country_breakdown: [
      { country: 'United States', count: 480 },
      { country: 'India', count: 370 },
      { country: 'Saudi Arabia', count: 260 },
      { country: 'Egypt', count: 190 },
      { country: 'Brazil', count: 120 },
    ],
  },
  {
    id: 'visual-acuity',
    name: 'Visual Acuity',
    slug: 'visual_acuity',
    usage_count: 1180,
    total_duration_seconds: 39800,
    days_used: 160,
    months_used: 7,
    years_used: 1,
    last_used_at: new Date().toISOString(),
    unique_users: 270,
    session_count: 1780,
    country_count: 18,
    city_count: 64,
    avg_usage_per_user: 4.3,
    avg_time_per_user_seconds: 140,
    avg_calc_time_ms: 0,
    usage_by_date: Array.from({ length: 12 }).map((_, idx) => ({
      date: `2024-${String(idx + 1).padStart(2, '0')}-01`,
      count: Math.round(30 + Math.random() * 90),
    })),
    duration_by_date: Array.from({ length: 12 }).map((_, idx) => ({
      date: `2024-${String(idx + 1).padStart(2, '0')}-01`,
      total_seconds: Math.round(1200 + Math.random() * 4200),
    })),
    country_breakdown: [
      { country: 'United States', count: 420 },
      { country: 'United Kingdom', count: 210 },
      { country: 'Canada', count: 160 },
      { country: 'India', count: 150 },
      { country: 'Mexico', count: 90 },
    ],
  },
  {
    id: 'ocular-lens',
    name: 'Ocular Lens Power',
    slug: 'ocular_lens_power',
    usage_count: 760,
    total_duration_seconds: 25100,
    days_used: 120,
    months_used: 6,
    years_used: 1,
    last_used_at: new Date().toISOString(),
    unique_users: 180,
    session_count: 1120,
    country_count: 15,
    city_count: 52,
    avg_usage_per_user: 4.2,
    avg_time_per_user_seconds: 128,
    avg_calc_time_ms: 1040,
    usage_by_date: Array.from({ length: 12 }).map((_, idx) => ({
      date: `2024-${String(idx + 1).padStart(2, '0')}-01`,
      count: Math.round(20 + Math.random() * 60),
    })),
    duration_by_date: Array.from({ length: 12 }).map((_, idx) => ({
      date: `2024-${String(idx + 1).padStart(2, '0')}-01`,
      total_seconds: Math.round(900 + Math.random() * 3200),
    })),
    country_breakdown: [
      { country: 'Spain', count: 130 },
      { country: 'Australia', count: 120 },
      { country: 'Egypt', count: 110 },
      { country: 'United States', count: 190 },
      { country: 'Germany', count: 85 },
    ],
  },
];

const fallbackUsers: UserSummary[] = [
  {
    user_id: 'user-001',
    full_name: 'Dr. Sarah Bennett',
    email: 'sarah@example.com',
    country: 'United States',
    city: 'Houston',
    total_sessions: 210,
    most_used_tool: 'IOL Power Calculator',
    tools: [
      { tool_slug: 'iol_power', tool_name: 'IOL Power Calculator', usage_count: 120, total_time_seconds: 4200, days_used: 90, last_used_at: new Date().toISOString() },
      { tool_slug: 'visual_acuity', tool_name: 'Visual Acuity', usage_count: 60, total_time_seconds: 2600, days_used: 70, last_used_at: new Date().toISOString() },
      { tool_slug: 'ocular_lens_power', tool_name: 'Ocular Lens Power', usage_count: 30, total_time_seconds: 1200, days_used: 40, last_used_at: new Date().toISOString() },
    ],
    locations: [
      { country: 'United States', city: 'Houston', sessions: 140 },
      { country: 'United States', city: 'Austin', sessions: 40 },
      { country: 'Canada', city: 'Toronto', sessions: 30 },
    ],
  },
  {
    user_id: 'user-002',
    full_name: 'Dr. Ahmed Youssef',
    email: 'ahmed@example.com',
    country: 'Egypt',
    city: 'Cairo',
    total_sessions: 180,
    most_used_tool: 'Visual Acuity',
    tools: [
      { tool_slug: 'visual_acuity', tool_name: 'Visual Acuity', usage_count: 90, total_time_seconds: 3200, days_used: 75, last_used_at: new Date().toISOString() },
      { tool_slug: 'iol_power', tool_name: 'IOL Power Calculator', usage_count: 55, total_time_seconds: 1900, days_used: 55, last_used_at: new Date().toISOString() },
      { tool_slug: 'ocular_lens_power', tool_name: 'Ocular Lens Power', usage_count: 35, total_time_seconds: 1400, days_used: 38, last_used_at: new Date().toISOString() },
    ],
    locations: [
      { country: 'Egypt', city: 'Cairo', sessions: 120 },
      { country: 'Saudi Arabia', city: 'Riyadh', sessions: 40 },
      { country: 'United Arab Emirates', city: 'Dubai', sessions: 20 },
    ],
  },
  {
    user_id: 'user-003',
    full_name: 'Dr. Lucia Gomez',
    email: 'lucia@example.com',
    country: 'Spain',
    city: 'Madrid',
    total_sessions: 130,
    most_used_tool: 'Ocular Lens Power',
    tools: [
      { tool_slug: 'ocular_lens_power', tool_name: 'Ocular Lens Power', usage_count: 70, total_time_seconds: 2600, days_used: 55, last_used_at: new Date().toISOString() },
      { tool_slug: 'visual_acuity', tool_name: 'Visual Acuity', usage_count: 40, total_time_seconds: 1700, days_used: 48, last_used_at: new Date().toISOString() },
      { tool_slug: 'iol_power', tool_name: 'IOL Power Calculator', usage_count: 20, total_time_seconds: 800, days_used: 25, last_used_at: new Date().toISOString() },
    ],
    locations: [
      { country: 'Spain', city: 'Madrid', sessions: 90 },
      { country: 'Spain', city: 'Barcelona', sessions: 25 },
      { country: 'Portugal', city: 'Lisbon', sessions: 15 },
    ],
  },
];

const fallbackFeedback: Feedback[] = [
  {
    id: 'fb-1',
    message: 'The IOL calculator is accurate but could use quicker input presets.',
    tool_slug: 'iol_power',
    feedback_type: 'feature',
    created_at: new Date().toISOString(),
    conclusion: {
      priority: 'medium',
      sentiment: 'positive',
      action_items: ['Add preset templates', 'Reduce calculation step count'],
    },
  },
  {
    id: 'fb-2',
    message: 'Visual acuity test works great; export PDF would be helpful.',
    tool_slug: 'visual_acuity',
    feedback_type: 'idea',
    created_at: new Date().toISOString(),
  },
  {
    id: 'fb-3',
    message: 'Please localize the interface for Spanish users.',
    tool_slug: 'ocular_lens_power',
    feedback_type: 'localization',
    created_at: new Date().toISOString(),
    conclusion: {
      priority: 'high',
      effort: 'medium',
      locales: ['es-ES', 'es-MX'],
    },
  },
];

const fallbackAnnouncements: Announcement[] = [
  {
    id: 'ann-1',
    title: 'New Cataract Workflow',
    body: 'Walk-through for cataract planning with guided calculator steps.',
    kind: 'announcement',
    start_at: new Date().toISOString(),
    end_at: new Date(Date.now() + 1000 * 60 * 60 * 24 * 5).toISOString(),
    priority: 'high',
    audience: 'doctors',
    show_in_carousel: true,
    show_in_notifications: true,
    max_impressions: 3,
    questions: [],
    status: 'live',
  },
  {
    id: 'ann-2',
    title: 'Sub-speciality Survey',
    body: 'Help us tailor tools to your day-to-day practice.',
    kind: 'survey',
    start_at: new Date().toISOString(),
    end_at: new Date(Date.now() + 1000 * 60 * 60 * 24 * 7).toISOString(),
    priority: 'normal',
    audience: 'all',
    show_in_carousel: true,
    show_in_notifications: true,
    max_impressions: 2,
    status: 'live',
    questions: [
      {
        id: 'q-1',
        prompt: 'What is your sub-speciality?',
        type: 'single_choice',
        options: ['Anterior segment', 'Retina', 'Pediatrics', 'Glaucoma'],
        required: true,
      },
      {
        id: 'q-2',
        prompt: 'Years of experience',
        type: 'number',
        required: true,
      },
      {
        id: 'q-3',
        prompt: 'Do you want monthly surgical tips?',
        type: 'yes_no',
        required: false,
      },
    ],
    responses: [
      { question_id: 'q-1', option: 'Anterior segment', count: 42 },
      { question_id: 'q-1', option: 'Retina', count: 33 },
      { question_id: 'q-1', option: 'Glaucoma', count: 18 },
      { question_id: 'q-2', value: 3, count: 12 },
      { question_id: 'q-2', value: 8, count: 20 },
      { question_id: 'q-2', value: 15, count: 14 },
      { question_id: 'q-3', option: 'Yes', count: 58 },
      { question_id: 'q-3', option: 'No', count: 18 },
    ],
  },
];

const formatDuration = (seconds: number) => {
  if (seconds < 60) return `${seconds}s`;
  const mins = Math.round(seconds / 60);
  if (mins < 60) return `${mins}m`;
  const hours = mins / 60;
  return `${hours.toFixed(1)}h`;
};

const formatDate = (value: string | null) => (value ? new Date(value).toLocaleString() : '—');

const gradientClass = 'bg-gradient-to-br from-slate-900 via-indigo-900 to-slate-800';

export default function AdminDashboard() {
  const [session, setSession] = useState<Session | null>(null);
  const [adminProfile, setAdminProfile] = useState<AdminProfile | null>(null);
  const [authLoading, setAuthLoading] = useState(true);
  const [authError, setAuthError] = useState<string | null>(null);
  const [loginEmail, setLoginEmail] = useState('');
  const [loginPassword, setLoginPassword] = useState('');

  const [activeTab, setActiveTab] = useState<'tools' | 'users' | 'feedbacks' | 'announcements'>('tools');
  const [loading, setLoading] = useState(false);
  const [toolSummaries, setToolSummaries] = useState<ToolSummary[]>([]);
  const [selectedTool, setSelectedTool] = useState<ToolSummary | null>(null);
  const [users, setUsers] = useState<UserSummary[]>([]);
  const [selectedUser, setSelectedUser] = useState<UserSummary | null>(null);
  const [feedbacks, setFeedbacks] = useState<Feedback[]>([]);
  const [feedbackView, setFeedbackView] = useState<'latest' | 'byTool'>('latest');
  const [announcements, setAnnouncements] = useState<Announcement[]>([]);
  const [announcementForm, setAnnouncementForm] = useState<AnnouncementDraft>({
    title: '',
    body: '',
    kind: 'announcement',
    start_at: new Date().toISOString().slice(0, 16),
    end_at: new Date(Date.now() + 1000 * 60 * 60 * 24 * 3).toISOString().slice(0, 16),
    priority: 'normal',
    audience: 'all',
    show_in_carousel: true,
    show_in_notifications: true,
    max_impressions: 3,
    questions: [],
  });
  const [formSaving, setFormSaving] = useState(false);
  const [formError, setFormError] = useState<string | null>(null);

  useEffect(() => {
    const bootstrap = async () => {
      const { data } = await supabaseClient.auth.getSession();
      setSession(data.session ?? null);
      setAuthLoading(false);
      if (data.session) {
        await ensureAdmin(data.session);
        await loadDashboardData();
      }
    };
    bootstrap();

    const {
      data: authListener,
    } = supabaseClient.auth.onAuthStateChange(async (_event, newSession) => {
      setSession(newSession);
      if (newSession) {
        await ensureAdmin(newSession);
        await loadDashboardData();
      } else {
        setAdminProfile(null);
      }
    });

    return () => {
      authListener?.subscription.unsubscribe();
    };
  }, []);

  const ensureAdmin = async (currentSession: Session) => {
    console.info('[admin] ensureAdmin: checking admin_users for user', {
      user_id: currentSession.user.id,
      email: currentSession.user.email,
    });
    const { data, error } = await supabaseClient
      .from('admin_users')
      .select('id, email, role, last_login_at, is_active')
      .eq('user_id', currentSession.user.id)
      .eq('is_active', true)
      .maybeSingle();

    if (error) {
      console.warn('[admin] admin_users lookup failed', error.message);
      setAdminProfile({
        id: currentSession.user.id,
        email: currentSession.user.email ?? 'admin@ocuhub.com',
        role: 'admin',
        last_login_at: null,
      });
      return;
    }

    if (!data) {
      console.warn('[admin] no admin_users row found for user, staying on login', {
        user_id: currentSession.user.id,
        email: currentSession.user.email,
      });
      setAuthError(
        'You are signed in with Supabase, but not whitelisted in admin_users. Add your Supabase Auth user id to admin_users and set is_active=true.',
      );
      setAdminProfile(null);
      return;
    }

    console.info('[admin] admin user authorized', {
      admin_id: data.id,
      email: data.email,
      role: data.role,
    });

    setAdminProfile({
      id: data.id,
      email: data.email,
      role: data.role as AdminProfile['role'],
      last_login_at: data.last_login_at,
    });
  };

  const handleLogin = async (email: string, password: string) => {
    setAuthError(null);
    setAuthLoading(true);
    const { data, error } = await supabaseClient.auth.signInWithPassword({ email, password });
    if (error) {
      setAuthError(error.message);
      setAuthLoading(false);
      return;
    }
    setSession(data.session);
    setAuthLoading(false);
  };

  const loadDashboardData = async () => {
    setLoading(true);
    try {
      const [toolsRes, usersRes, feedbackRes, annRes] = await Promise.allSettled([
        supabaseClient
          .from('tool_usage_summary')
          .select(
            'id, tool_name, tool_slug, usage_count, total_duration_seconds, days_used, months_used, years_used, last_used_at, unique_users, session_count, country_count, city_count, avg_usage_per_user, avg_time_per_user_seconds, avg_calc_time_ms, usage_by_date, duration_by_date, country_breakdown',
          )
          .order('usage_count', { ascending: false }),
        supabaseClient
          .from('user_usage_summary')
          .select(
            'user_id, full_name, email, country, city, total_sessions, most_used_tool, tools, locations',
          )
          .order('total_sessions', { ascending: false }),
        supabaseClient
          .from('dashboard_feedbacks')
          .select('id, message, tool_slug, feedback_type, conclusion, created_at')
          .order('created_at', { ascending: false }),
        supabaseClient
          .from('dashboard_announcements')
          .select(
            'id, title, body, kind, start_at, end_at, priority, audience, show_in_carousel, show_in_notifications, max_impressions, status, questions, responses',
          )
          .order('start_at', { ascending: false }),
      ]);

      if (toolsRes.status === 'fulfilled' && !toolsRes.value.error && toolsRes.value.data) {
        const parsed = (toolsRes.value.data as any[]).map((item) => ({
          id: item.id,
          name: item.tool_name ?? item.tool_slug,
          slug: item.tool_slug,
          usage_count: item.usage_count ?? 0,
          total_duration_seconds: item.total_duration_seconds ?? 0,
          days_used: item.days_used ?? 0,
          months_used: item.months_used ?? 0,
          years_used: item.years_used ?? 0,
          last_used_at: item.last_used_at,
          unique_users: item.unique_users ?? 0,
          session_count: item.session_count ?? 0,
          country_count: item.country_count ?? 0,
          city_count: item.city_count ?? 0,
          avg_usage_per_user: item.avg_usage_per_user ?? 0,
          avg_time_per_user_seconds: item.avg_time_per_user_seconds ?? 0,
          avg_calc_time_ms: item.avg_calc_time_ms ?? 0,
          usage_by_date: item.usage_by_date ?? [],
          duration_by_date: item.duration_by_date ?? [],
          country_breakdown: item.country_breakdown ?? [],
        })) as ToolSummary[];
        setToolSummaries(parsed);
        setSelectedTool(parsed[0] ?? null);
      } else {
        if (toolsRes.status === 'fulfilled' && toolsRes.value.error) {
          console.warn('[admin] tool_usage_summary error', toolsRes.value.error.message);
        }
        setToolSummaries(fallbackTools);
        setSelectedTool(fallbackTools[0]);
      }

      if (usersRes.status === 'fulfilled' && !usersRes.value.error && usersRes.value.data) {
        setUsers(usersRes.value.data as UserSummary[]);
        setSelectedUser((usersRes.value.data as UserSummary[])[0] ?? null);
      } else {
        if (usersRes.status === 'fulfilled' && usersRes.value.error) {
          console.warn('[admin] user_usage_summary error', usersRes.value.error.message);
        }
        setUsers(fallbackUsers);
        setSelectedUser(fallbackUsers[0]);
      }

      if (feedbackRes.status === 'fulfilled' && !feedbackRes.value.error && feedbackRes.value.data) {
        setFeedbacks(feedbackRes.value.data as Feedback[]);
      } else {
        if (feedbackRes.status === 'fulfilled' && feedbackRes.value.error) {
          console.warn('[admin] feedbacks error', feedbackRes.value.error.message);
        }
        setFeedbacks(fallbackFeedback);
      }

      if (annRes.status === 'fulfilled' && !annRes.value.error && annRes.value.data) {
        setAnnouncements(annRes.value.data as Announcement[]);
      } else {
        if (annRes.status === 'fulfilled' && annRes.value.error) {
          console.warn('[admin] announcements error', annRes.value.error.message);
        }
        setAnnouncements(fallbackAnnouncements);
      }
    } catch (error) {
      console.error('[admin] loadDashboardData failed', error);
      setToolSummaries(fallbackTools);
      setUsers(fallbackUsers);
      setFeedbacks(fallbackFeedback);
      setAnnouncements(fallbackAnnouncements);
    } finally {
      setLoading(false);
    }
  };

  const handleCreateAnnouncement = async () => {
    setFormError(null);
    setFormSaving(true);
    try {
      const payload = {
        title: announcementForm.title.trim(),
        body: announcementForm.body.trim(),
        kind: announcementForm.kind,
        start_at: new Date(announcementForm.start_at).toISOString(),
        end_at: new Date(announcementForm.end_at).toISOString(),
        priority: announcementForm.priority,
        audience: announcementForm.audience,
        show_in_carousel: announcementForm.show_in_carousel,
        show_in_notifications: announcementForm.show_in_notifications,
        max_impressions: announcementForm.max_impressions,
        questions: announcementForm.kind === 'survey' ? announcementForm.questions : [],
        status: 'scheduled',
      };

      const { data, error } = await supabaseClient
        .from('announcements')
        .insert(payload)
        .select('id')
        .single();

      if (error) {
        throw error;
      }

      const newAnnouncement: Announcement = {
        ...payload,
        id: data?.id ?? crypto.randomUUID?.() ?? Math.random().toString(36),
        status: payload.start_at <= new Date().toISOString() ? 'live' : 'scheduled',
        responses: [],
      };

      setAnnouncements((prev) => [newAnnouncement, ...prev]);
      setAnnouncementForm((prev) => ({
        ...prev,
        title: '',
        body: '',
        questions: [],
      }));
    } catch (error: any) {
      console.warn('Announcement create failed, saved locally only', error.message);
      setFormError(error.message ?? 'Unable to create announcement. Check Supabase permissions and schema.');
      const offlineAnnouncement: Announcement = {
        ...announcementForm,
        id: crypto.randomUUID?.() ?? Math.random().toString(36),
        status: 'scheduled',
        responses: [],
      };
      setAnnouncements((prev) => [offlineAnnouncement, ...prev]);
    } finally {
      setFormSaving(false);
    }
  };

  const totals = useMemo(() => {
    const totalUsage = toolSummaries.reduce((sum, t) => sum + t.usage_count, 0);
    const totalDuration = toolSummaries.reduce((sum, t) => sum + t.total_duration_seconds, 0);
    const totalUsers = toolSummaries.reduce((sum, t) => sum + t.unique_users, 0);
    const activeAnnouncements = announcements.filter((a) => a.status !== 'ended').length;
    return {
      totalUsage,
      totalDuration,
      totalUsers,
      activeAnnouncements,
    };
  }, [toolSummaries, announcements]);

  const renderLogin = () => (
    <div className="min-h-screen flex items-center justify-center bg-slate-950 px-6 py-12">
      <div className="max-w-md w-full space-y-8 bg-white/5 border border-white/10 backdrop-blur-xl p-10 rounded-3xl shadow-2xl">
        <div className="text-center space-y-3">
          <p className="text-indigo-300 text-sm uppercase tracking-[0.2em]">OcuHub Secure</p>
          <h1 className="text-3xl font-bold text-white">Admin Command Center</h1>
          <p className="text-sm text-slate-300">Sign in with your admin credentials provisioned in Supabase.</p>
        </div>
        <div className="space-y-4">
          <button
            onClick={() =>
              supabaseClient.auth.signInWithOAuth({
                provider: 'google',
                options: { redirectTo: `${typeof window !== 'undefined' ? window.location.origin : ''}/admin` },
              })
            }
            className="w-full bg-white text-slate-900 font-semibold py-3 rounded-xl transition-all duration-300 shadow-lg hover:shadow-xl flex items-center justify-center gap-2"
            aria-label="Continue with Google"
          >
            <img src="https://www.svgrepo.com/show/475656/google-color.svg" alt="Google" className="w-5 h-5" />
            Continue with Google
          </button>
          <div className="flex items-center gap-3 text-xs text-slate-400">
            <div className="h-px flex-1 bg-white/10" />
            <span>or</span>
            <div className="h-px flex-1 bg-white/10" />
          </div>
          <div>
            <label className="block text-sm text-slate-200 mb-2">Admin email</label>
            <input
              type="email"
              className="w-full rounded-xl bg-white/5 border border-white/10 px-4 py-3 text-white focus:ring-2 focus:ring-indigo-500 outline-none"
              placeholder="admin@ocuhub.com"
              value={loginEmail}
              onChange={(e) => setLoginEmail(e.target.value)}
            />
          </div>
          <div>
            <label className="block text-sm text-slate-200 mb-2">Password</label>
            <input
              type="password"
              className="w-full rounded-xl bg-white/5 border border-white/10 px-4 py-3 text-white focus:ring-2 focus:ring-indigo-500 outline-none"
              placeholder="••••••••"
              value={loginPassword}
              onChange={(e) => setLoginPassword(e.target.value)}
            />
          </div>
          {authError ? <p className="text-sm text-rose-400">{authError}</p> : null}
          <button
            onClick={() => handleLogin(loginEmail, loginPassword)}
            className="w-full bg-indigo-500 hover:bg-indigo-400 text-white font-semibold py-3 rounded-xl transition-all duration-300 shadow-lg shadow-indigo-500/30"
            disabled={authLoading}
          >
            {authLoading ? 'Authenticating…' : 'Sign in as admin'}
          </button>
          <p className="text-xs text-slate-400 text-center">
            Admin accounts live in Supabase Auth + admin_users. Service role key stays server-side only.
          </p>
        </div>
      </div>
    </div>
  );

  if (!session || !adminProfile) {
    return renderLogin();
  }

  return (
    <>
      <Head>
        <title>OcuHub Admin Dashboard</title>
        <link
          href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@400;500;600;700&display=swap"
          rel="stylesheet"
        />
      </Head>
      <div className={`${gradientClass} min-h-screen text-white`} style={{ fontFamily: 'Space Grotesk, Inter, system-ui' }}>
        <div className="max-w-7xl mx-auto px-6 py-10 space-y-10">
          <header className="flex flex-col gap-6 lg:flex-row lg:items-center lg:justify-between">
            <div className="space-y-2">
              <p className="text-sm text-indigo-200 uppercase tracking-[0.25em]">OcuHub Control</p>
              <h1 className="text-3xl sm:text-4xl font-bold">Admin Dashboard</h1>
              <p className="text-slate-300 max-w-2xl">
                Monitor tools, sessions, feedback, and drive announcements or surveys without touching the mobile sync pipeline.
              </p>
              {authError ? <p className="text-sm text-rose-400">{authError}</p> : null}
            </div>
            <div className="flex items-center gap-3 bg-white/5 border border-white/10 px-4 py-3 rounded-2xl shadow-lg">
              <div className="h-10 w-10 rounded-xl bg-indigo-500/30 border border-indigo-300/30 flex items-center justify-center">
                <span className="font-semibold text-indigo-100">{adminProfile.email.slice(0, 2).toUpperCase()}</span>
              </div>
              <div>
                <p className="text-sm text-slate-300">Signed in as</p>
                <p className="font-semibold">{adminProfile.email}</p>
              </div>
              <button
                onClick={() => supabaseClient.auth.signOut()}
                className="ml-2 text-sm text-indigo-200 underline underline-offset-4 hover:text-white"
              >
                Sign out
              </button>
            </div>
          </header>

          <section className="grid grid-cols-1 md:grid-cols-4 gap-4">
            <StatCard label="Tool actions" value={totals.totalUsage.toLocaleString()} hint="Total usage count" />
            <StatCard label="Engaged clinicians" value={totals.totalUsers.toLocaleString()} hint="Distinct users" />
            <StatCard label="Run time" value={formatDuration(totals.totalDuration)} hint="Total active time" />
            <StatCard label="Live announcements" value={totals.activeAnnouncements.toString()} hint="Active or scheduled" />
          </section>

          <div className="flex flex-wrap gap-3">
            {(['tools', 'users', 'feedbacks', 'announcements'] as const).map((tab) => (
              <button
                key={tab}
                onClick={() => setActiveTab(tab)}
                className={`px-4 py-2 rounded-full text-sm font-semibold transition-all ${
                  activeTab === tab
                    ? 'bg-white text-slate-900 shadow-lg shadow-indigo-500/30'
                    : 'bg-white/10 text-white hover:bg-white/20'
                }`}
              >
                {tab === 'tools' && 'Tools & Analytics'}
                {tab === 'users' && 'Users & Sessions'}
                {tab === 'feedbacks' && 'Feedback'}
                {tab === 'announcements' && 'Announcements / Surveys'}
              </button>
            ))}
          </div>

          {loading ? (
            <div className="w-full h-72 rounded-3xl bg-white/5 border border-white/10 flex items-center justify-center text-slate-200">
              Loading dashboard…
            </div>
          ) : null}

          {!loading && activeTab === 'tools' ? (
            <ToolsPanel
              tools={toolSummaries}
              selected={selectedTool}
              onSelect={setSelectedTool}
            />
          ) : null}

          {!loading && activeTab === 'users' ? (
            <EnhancedUsersPanel onError={(err) => console.error('[admin] Users panel error:', err)} />
          ) : null}

          {!loading && activeTab === 'feedbacks' ? (
            <FeedbackPanel
              feedbacks={feedbacks}
              view={feedbackView}
              onViewChange={setFeedbackView}
            />
          ) : null}

          {!loading && activeTab === 'announcements' ? (
            <AnnouncementPanel
              announcements={announcements}
              form={announcementForm}
              setForm={setAnnouncementForm}
              onCreate={handleCreateAnnouncement}
              saving={formSaving}
              error={formError}
            />
          ) : null}
        </div>
      </div>
    </>
  );
}

const StatCard = ({ label, value, hint }: { label: string; value: string; hint: string }) => (
  <div className="rounded-2xl bg-white/5 border border-white/10 p-5 shadow-lg shadow-indigo-500/10">
    <p className="text-sm text-indigo-100 uppercase tracking-[0.25em] mb-2">{label}</p>
    <p className="text-3xl font-bold">{value}</p>
    <p className="text-sm text-slate-300">{hint}</p>
  </div>
);

function ToolsPanel({
  tools,
  selected,
  onSelect,
}: {
  tools: ToolSummary[];
  selected: ToolSummary | null;
  onSelect: (tool: ToolSummary | null) => void;
}) {
  return (
    <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
      <div className="lg:col-span-1 space-y-3">
        <div className="flex items-center justify-between">
          <h2 className="text-xl font-semibold">Tools ordered by usage</h2>
          <p className="text-xs text-slate-300">Click to drill in</p>
        </div>
        <div className="space-y-3 max-h-[620px] overflow-y-auto pr-1">
          {tools.map((tool) => (
            <button
              key={tool.id}
              onClick={() => onSelect(tool)}
              className={`w-full text-left rounded-2xl border transition-all ${
                selected?.id === tool.id ? 'border-indigo-400 bg-indigo-500/10' : 'border-white/10 bg-white/5 hover:border-white/20'
              } p-4`}
            >
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm text-indigo-200 uppercase tracking-[0.2em]">#{tool.slug}</p>
                  <h3 className="text-lg font-semibold">{tool.name}</h3>
                </div>
                <div className="text-right">
                  <p className="text-2xl font-bold">{tool.usage_count.toLocaleString()}</p>
                  <p className="text-xs text-slate-300">total uses</p>
                </div>
              </div>
              <div className="mt-3 grid grid-cols-3 gap-2 text-xs text-slate-200">
                <div>
                  <p className="font-semibold">{tool.unique_users}</p>
                  <p className="text-slate-400">users</p>
                </div>
                <div>
                  <p className="font-semibold">{tool.session_count}</p>
                  <p className="text-slate-400">sessions</p>
                </div>
                <div>
                  <p className="font-semibold">{formatDuration(tool.total_duration_seconds)}</p>
                  <p className="text-slate-400">time</p>
                </div>
              </div>
              <div className="mt-2 text-xs text-slate-400 flex items-center gap-2">
                <span className="h-2 w-2 rounded-full bg-emerald-400" />
                Last used {formatDate(tool.last_used_at)}
              </div>
            </button>
          ))}
        </div>
      </div>

      <div className="lg:col-span-2 space-y-6">
        {selected ? (
          <div className="rounded-3xl border border-white/10 bg-white/5 p-6 shadow-lg shadow-indigo-500/10">
            <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 mb-6">
              <div>
                <p className="text-sm text-indigo-200 uppercase tracking-[0.25em]">Tool analytics</p>
                <h3 className="text-2xl font-semibold">{selected.name}</h3>
                <p className="text-xs text-slate-300">Slug: {selected.slug}</p>
              </div>
              <div className="grid grid-cols-2 sm:grid-cols-3 gap-3">
                <MetricBadge label="Avg / user" value={selected.avg_usage_per_user.toFixed(1)} />
                <MetricBadge label="Avg time / user" value={formatDuration(selected.avg_time_per_user_seconds)} />
                <MetricBadge label="Avg calc" value={selected.avg_calc_time_ms ? `${selected.avg_calc_time_ms} ms` : 'N/A'} />
              </div>
            </div>

            <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
              <ChartCard title="Usage over time">
                <ResponsiveContainer width="100%" height={240}>
                  <AreaChart data={selected.usage_by_date ?? []}>
                    <defs>
                      <linearGradient id="usageGradient" x1="0" y1="0" x2="0" y2="1">
                        <stop offset="5%" stopColor="#6366f1" stopOpacity={0.8} />
                        <stop offset="95%" stopColor="#6366f1" stopOpacity={0} />
                      </linearGradient>
                    </defs>
                    <CartesianGrid strokeDasharray="3 3" stroke="#334155" />
                    <XAxis dataKey="date" stroke="#cbd5e1" fontSize={12} />
                    <YAxis stroke="#cbd5e1" fontSize={12} />
                    <Tooltip
                      contentStyle={{ background: '#0f172a', border: '1px solid #334155', borderRadius: 12 }}
                      labelStyle={{ color: '#e2e8f0' }}
                    />
                    <Area
                      type="monotone"
                      dataKey="count"
                      stroke="#818cf8"
                      fillOpacity={1}
                      fill="url(#usageGradient)"
                    />
                  </AreaChart>
                </ResponsiveContainer>
              </ChartCard>

              <ChartCard title="Time spent over time">
                <ResponsiveContainer width="100%" height={240}>
                  <BarChart data={selected.duration_by_date ?? []}>
                    <CartesianGrid strokeDasharray="3 3" stroke="#334155" />
                    <XAxis dataKey="date" stroke="#cbd5e1" fontSize={12} />
                    <YAxis stroke="#cbd5e1" fontSize={12} />
                    <Tooltip
                      contentStyle={{ background: '#0f172a', border: '1px solid #334155', borderRadius: 12 }}
                      labelStyle={{ color: '#e2e8f0' }}
                      formatter={(value: number) => formatDuration(value)}
                    />
                    <Bar dataKey="total_seconds" fill="#22c55e" radius={[10, 10, 0, 0]} />
                  </BarChart>
                </ResponsiveContainer>
              </ChartCard>
            </div>

            <div className="grid grid-cols-1 lg:grid-cols-3 gap-4 mt-4">
              <div className="lg:col-span-2">
                <ChartCard title="Countries">
                  <ResponsiveContainer width="100%" height={240}>
                    <PieChart>
                      <Pie
                        data={selected.country_breakdown ?? []}
                        dataKey="count"
                        nameKey="country"
                        innerRadius={50}
                        outerRadius={90}
                        paddingAngle={2}
                      >
                        {(selected.country_breakdown ?? []).map((entry, index) => (
                          <Cell key={entry.country} fill={chartPalette[index % chartPalette.length]} />
                        ))}
                      </Pie>
                      <Tooltip
                        contentStyle={{ background: '#0f172a', border: '1px solid #334155', borderRadius: 12 }}
                        labelStyle={{ color: '#e2e8f0' }}
                      />
                      <Legend />
                    </PieChart>
                  </ResponsiveContainer>
                </ChartCard>
              </div>
              <div className="space-y-3">
                <div className="rounded-2xl border border-white/10 bg-white/5 p-4">
                  <p className="text-sm text-slate-300 mb-2">Audience reach</p>
                  <div className="flex items-center justify-between text-sm">
                    <span>Countries</span>
                    <span className="font-semibold">{selected.country_count}</span>
                  </div>
                  <div className="flex items-center justify-between text-sm">
                    <span>Cities</span>
                    <span className="font-semibold">{selected.city_count}</span>
                  </div>
                  <div className="flex items-center justify-between text-sm">
                    <span>Sessions</span>
                    <span className="font-semibold">{selected.session_count}</span>
                  </div>
                  <div className="flex items-center justify-between text-sm">
                    <span>Avg / user</span>
                    <span className="font-semibold">{selected.avg_usage_per_user.toFixed(1)}</span>
                  </div>
                </div>
                <div className="rounded-2xl border border-emerald-300/20 bg-emerald-500/10 p-4">
                  <p className="text-sm text-emerald-100">Last used</p>
                  <p className="text-lg font-semibold">{formatDate(selected.last_used_at)}</p>
                  <p className="text-xs text-emerald-100/80 mt-2">
                    Keep an eye on drops; build reminders via announcements if needed.
                  </p>
                </div>
              </div>
            </div>
          </div>
        ) : (
          <div className="rounded-2xl border border-white/10 bg-white/5 p-6 text-slate-200">
            Select a tool to view analytics.
          </div>
        )}
      </div>
    </div>
  );
}

const ChartCard = ({ title, children }: { title: string; children: ReactNode }) => (
  <div className="rounded-2xl border border-white/10 bg-white/5 p-4 shadow-lg shadow-indigo-500/10">
    <div className="flex items-center justify-between mb-3">
      <p className="text-sm text-slate-200">{title}</p>
      <span className="h-2 w-2 rounded-full bg-emerald-400" />
    </div>
    {children}
  </div>
);

const MetricBadge = ({ label, value }: { label: string; value: string }) => (
  <div className="rounded-xl bg-white/10 border border-white/10 px-3 py-2 text-sm">
    <p className="text-slate-300">{label}</p>
    <p className="font-semibold">{value}</p>
  </div>
);

function UsersPanel({
  users,
  selected,
  onSelect,
}: {
  users: UserSummary[];
  selected: UserSummary | null;
  onSelect: (user: UserSummary | null) => void;
}) {
  return (
    <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
      <div className="lg:col-span-1 space-y-3 max-h-[640px] overflow-y-auto pr-1">
        <div className="flex items-center justify-between">
          <h2 className="text-xl font-semibold">Users by sessions</h2>
          <span className="text-xs text-slate-300">Tap to inspect</span>
        </div>
        {users.map((user) => (
          <button
            key={user.user_id}
            onClick={() => onSelect(user)}
            className={`w-full text-left rounded-2xl border p-4 transition ${
              selected?.user_id === user.user_id ? 'border-emerald-300 bg-emerald-500/10' : 'border-white/10 bg-white/5 hover:border-white/20'
            }`}
          >
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-indigo-200 uppercase tracking-[0.2em]">{user.user_id.slice(0, 6)}</p>
                <h3 className="text-lg font-semibold">{user.full_name ?? 'Unknown user'}</h3>
                <p className="text-xs text-slate-300">{user.email ?? 'No email'}</p>
              </div>
              <div className="text-right">
                <p className="text-2xl font-bold">{user.total_sessions}</p>
                <p className="text-xs text-slate-300">sessions</p>
                <p className="text-xs text-emerald-200">Top tool: {user.most_used_tool ?? '—'}</p>
              </div>
            </div>
            <div className="mt-3 flex items-center gap-2 text-sm text-slate-300">
              <span className="h-2 w-2 rounded-full bg-indigo-300" />
              {user.country ?? 'Unknown'} · {user.city ?? 'Unknown'}
            </div>
          </button>
        ))}
      </div>

      <div className="lg:col-span-2 space-y-4">
        {selected ? (
          <div className="rounded-3xl border border-white/10 bg-white/5 p-6 shadow-lg shadow-indigo-500/10">
            <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3">
              <div>
                <p className="text-sm text-indigo-200 uppercase tracking-[0.2em]">User detail</p>
                <h3 className="text-2xl font-semibold">{selected.full_name ?? 'Unknown user'}</h3>
                <p className="text-sm text-slate-300">{selected.email}</p>
              </div>
              <div className="grid grid-cols-3 gap-3">
                <MetricBadge label="Sessions" value={selected.total_sessions.toString()} />
                <MetricBadge label="Top tool" value={selected.most_used_tool ?? '—'} />
                <MetricBadge label="Home" value={`${selected.country ?? 'N/A'}`} />
              </div>
            </div>

            <div className="grid grid-cols-1 lg:grid-cols-2 gap-4 mt-4">
              <div className="rounded-2xl border border-white/10 bg-white/5 p-4">
                <div className="flex items-center justify-between mb-3">
                  <p className="text-sm text-slate-200">Tools used</p>
                  <p className="text-xs text-slate-300">Sorted by usage</p>
                </div>
                <div className="space-y-3">
                  {(selected.tools ?? []).map((tool) => (
                    <div key={tool.tool_slug} className="rounded-xl bg-white/5 border border-white/10 p-3">
                      <div className="flex items-center justify-between">
                        <div>
                          <p className="text-sm text-indigo-200 uppercase tracking-[0.2em]">{tool.tool_slug}</p>
                          <h4 className="font-semibold">{tool.tool_name}</h4>
                        </div>
                        <div className="text-right">
                          <p className="text-lg font-bold">{tool.usage_count}</p>
                          <p className="text-xs text-slate-300">uses</p>
                        </div>
                      </div>
                      <div className="mt-2 grid grid-cols-3 gap-2 text-xs text-slate-300">
                        <span>Time: {formatDuration(tool.total_time_seconds)}</span>
                        <span>Days: {tool.days_used}</span>
                        <span>Last: {formatDate(tool.last_used_at)}</span>
                      </div>
                    </div>
                  ))}
                </div>
              </div>

              <div className="rounded-2xl border border-white/10 bg-white/5 p-4">
                <div className="flex items-center justify-between mb-3">
                  <p className="text-sm text-slate-200">Countries / Cities</p>
                  <p className="text-xs text-slate-300">Most common first</p>
                </div>
                <div className="space-y-3">
                  {(selected.locations ?? []).map((loc) => (
                    <div key={`${loc.country}-${loc.city}`} className="flex items-center justify-between rounded-xl bg-white/5 border border-white/10 p-3">
                      <div>
                        <p className="font-semibold">{loc.city ?? 'Unknown'}, {loc.country ?? 'Unknown'}</p>
                        <p className="text-xs text-slate-300">Sessions</p>
                      </div>
                      <p className="text-lg font-bold">{loc.sessions}</p>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          </div>
        ) : (
          <div className="rounded-2xl border border-white/10 bg-white/5 p-6 text-slate-200">Select a user to inspect sessions.</div>
        )}
      </div>
    </div>
  );
}

function FeedbackPanel({
  feedbacks,
  view,
  onViewChange,
}: {
  feedbacks: Feedback[];
  view: 'latest' | 'byTool';
  onViewChange: (view: 'latest' | 'byTool') => void;
}) {
  const grouped = useMemo(() => {
    const map = new Map<string, Feedback[]>();
    feedbacks.forEach((fb) => {
      const key = fb.tool_slug ?? 'general';
      if (!map.has(key)) map.set(key, []);
      map.get(key)!.push(fb);
    });
    return Array.from(map.entries()).sort((a, b) => b[1].length - a[1].length);
  }, [feedbacks]);

  return (
    <div className="space-y-4">
      <div className="flex items-center gap-3">
        <button
          onClick={() => onViewChange('latest')}
          className={`px-4 py-2 rounded-full text-sm font-semibold transition ${
            view === 'latest' ? 'bg-white text-slate-900' : 'bg-white/10 text-white hover:bg-white/20'
          }`}
        >
          Latest first
        </button>
        <button
          onClick={() => onViewChange('byTool')}
          className={`px-4 py-2 rounded-full text-sm font-semibold transition ${
            view === 'byTool' ? 'bg-white text-slate-900' : 'bg-white/10 text-white hover:bg-white/20'
          }`}
        >
          Grouped by tool
        </button>
      </div>

      {view === 'latest' ? (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {feedbacks.map((fb) => (
            <FeedbackCard key={fb.id} feedback={fb} />
          ))}
        </div>
      ) : (
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
          {grouped.map(([tool, list]) => (
            <div key={tool} className="rounded-2xl border border-white/10 bg-white/5 p-4">
              <div className="flex items-center justify-between mb-2">
                <div>
                  <p className="text-sm text-indigo-200 uppercase tracking-[0.2em]">{tool}</p>
                  <h3 className="text-lg font-semibold">{list[0]?.tool_slug ?? 'General'}</h3>
                </div>
                <div className="text-right">
                  <p className="text-2xl font-bold">{list.length}</p>
                  <p className="text-xs text-slate-300">feedbacks</p>
                </div>
              </div>
              <div className="space-y-3">
                {list.map((item) => (
                  <FeedbackCard key={item.id} feedback={item} compact />
                ))}
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}

const FeedbackCard = ({ feedback, compact = false }: { feedback: Feedback; compact?: boolean }) => (
  <div className="rounded-2xl border border-white/10 bg-white/5 p-4 h-full flex flex-col gap-3">
    <div className="flex items-start justify-between gap-3">
      <div>
        <p className="text-xs text-indigo-200 uppercase tracking-[0.2em]">
          {feedback.tool_slug ?? 'General'} · {feedback.feedback_type ?? 'unspecified'}
        </p>
        <p className="font-semibold">{formatDate(feedback.created_at)}</p>
      </div>
      <span className="px-3 py-1 text-xs rounded-full bg-indigo-500/20 border border-indigo-300/40">
        {feedback.feedback_type ?? 'feedback'}
      </span>
    </div>
    <p className="text-slate-100 text-sm">{feedback.message}</p>
    {feedback.conclusion ? (
      <details className="rounded-xl bg-white/5 border border-white/10 p-3 text-sm">
        <summary className="cursor-pointer text-indigo-200">Conclusion</summary>
        <pre className="mt-2 text-xs text-slate-200 whitespace-pre-wrap break-words">
          {JSON.stringify(feedback.conclusion, null, 2)}
        </pre>
      </details>
    ) : null}
    {!compact ? (
      <button className="self-start text-xs text-indigo-200 underline underline-offset-4 hover:text-white">
        Open thread
      </button>
    ) : null}
  </div>
);

function AnnouncementPanel({
  announcements,
  form,
  setForm,
  onCreate,
  saving,
  error,
}: {
  announcements: Announcement[];
  form: AnnouncementDraft;
  setForm: (draft: AnnouncementDraft) => void;
  onCreate: () => void | Promise<void>;
  saving: boolean;
  error: string | null;
}) {
  const live = announcements.filter((a) => a.status !== 'ended');

  const addQuestion = () => {
    const newQuestion: AnnouncementQuestion = {
      id: crypto.randomUUID?.() ?? Math.random().toString(36),
      prompt: '',
      type: 'yes_no',
      required: false,
      options: ['Yes', 'No'],
    };
    setForm({ ...form, questions: [...form.questions, newQuestion] });
  };

  const updateQuestion = (id: string, updates: Partial<AnnouncementQuestion>) => {
    setForm({
      ...form,
      questions: form.questions.map((q) => (q.id === id ? { ...q, ...updates } : q)),
    });
  };

  const addOption = (id: string) => {
    setForm({
      ...form,
      questions: form.questions.map((q) =>
        q.id === id ? { ...q, options: [...(q.options ?? []), 'New option'] } : q,
      ),
    });
  };

  return (
    <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
      <div className="lg:col-span-2 space-y-4">
        <div className="rounded-3xl border border-white/10 bg-white/5 p-6 shadow-lg shadow-indigo-500/10">
          <div className="flex items-center justify-between mb-4">
            <div>
              <p className="text-sm text-indigo-200 uppercase tracking-[0.2em]">Create announcement or survey</p>
              <h3 className="text-2xl font-semibold">Push to app surfaces</h3>
            </div>
            <span className="px-3 py-1 text-xs rounded-full bg-emerald-500/20 border border-emerald-300/40">RLS enforced</span>
          </div>
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div>
              <label className="text-sm text-slate-200">Title</label>
              <input
                value={form.title}
                onChange={(e) => setForm({ ...form, title: e.target.value })}
                className="mt-1 w-full rounded-xl bg-white/5 border border-white/10 px-4 py-2 text-white focus:ring-2 focus:ring-indigo-500 outline-none"
                placeholder="E.g., Retina tools refresh"
              />
            </div>
            <div>
              <label className="text-sm text-slate-200">Type</label>
              <select
                value={form.kind}
                onChange={(e) => setForm({ ...form, kind: e.target.value as AnnouncementDraft['kind'] })}
                className="mt-1 w-full rounded-xl bg-white/5 border border-white/10 px-4 py-2 text-white focus:ring-2 focus:ring-indigo-500 outline-none"
              >
                <option value="announcement">Announcement</option>
                <option value="survey">Survey / Quiz</option>
              </select>
            </div>
            <div className="sm:col-span-2">
              <label className="text-sm text-slate-200">Body</label>
              <textarea
                value={form.body}
                onChange={(e) => setForm({ ...form, body: e.target.value })}
                className="mt-1 w-full rounded-xl bg-white/5 border border-white/10 px-4 py-3 text-white focus:ring-2 focus:ring-indigo-500 outline-none"
                rows={3}
                placeholder="Context, CTA, links…"
              />
            </div>
            <div>
              <label className="text-sm text-slate-200">Start</label>
              <input
                type="datetime-local"
                value={form.start_at}
                onChange={(e) => setForm({ ...form, start_at: e.target.value })}
                className="mt-1 w-full rounded-xl bg-white/5 border border-white/10 px-4 py-2 text-white focus:ring-2 focus:ring-indigo-500 outline-none"
              />
            </div>
            <div>
              <label className="text-sm text-slate-200">End</label>
              <input
                type="datetime-local"
                value={form.end_at}
                onChange={(e) => setForm({ ...form, end_at: e.target.value })}
                className="mt-1 w-full rounded-xl bg-white/5 border border-white/10 px-4 py-2 text-white focus:ring-2 focus:ring-indigo-500 outline-none"
              />
            </div>
            <div>
              <label className="text-sm text-slate-200">Audience</label>
              <select
                value={form.audience}
                onChange={(e) => setForm({ ...form, audience: e.target.value as AnnouncementDraft['audience'] })}
                className="mt-1 w-full rounded-xl bg-white/5 border border-white/10 px-4 py-2 text-white focus:ring-2 focus:ring-indigo-500 outline-none"
              >
                <option value="all">All users</option>
                <option value="doctors">Doctors</option>
                <option value="residents">Residents</option>
                <option value="students">Students</option>
              </select>
            </div>
            <div>
              <label className="text-sm text-slate-200">Priority</label>
              <select
                value={form.priority}
                onChange={(e) => setForm({ ...form, priority: e.target.value as AnnouncementDraft['priority'] })}
                className="mt-1 w-full rounded-xl bg-white/5 border border-white/10 px-4 py-2 text-white focus:ring-2 focus:ring-indigo-500 outline-none"
              >
                <option value="low">Low</option>
                <option value="normal">Normal</option>
                <option value="high">High</option>
              </select>
            </div>
            <div className="flex items-center gap-3">
              <input
                type="checkbox"
                checked={form.show_in_carousel}
                onChange={(e) => setForm({ ...form, show_in_carousel: e.target.checked })}
                className="h-4 w-4 rounded border-white/20 bg-white/10"
              />
              <label className="text-sm text-slate-200">Show in carousel</label>
            </div>
            <div className="flex items-center gap-3">
              <input
                type="checkbox"
                checked={form.show_in_notifications}
                onChange={(e) => setForm({ ...form, show_in_notifications: e.target.checked })}
                className="h-4 w-4 rounded border-white/20 bg-white/10"
              />
              <label className="text-sm text-slate-200">Send to notification center</label>
            </div>
            <div>
              <label className="text-sm text-slate-200">Max impressions</label>
              <input
                type="number"
                value={form.max_impressions ?? ''}
                onChange={(e) => setForm({ ...form, max_impressions: e.target.value ? Number(e.target.value) : null })}
                className="mt-1 w-full rounded-xl bg-white/5 border border-white/10 px-4 py-2 text-white focus:ring-2 focus:ring-indigo-500 outline-none"
                placeholder="e.g., 3"
              />
              <p className="text-xs text-slate-400 mt-1">Limit number of times a user sees it.</p>
            </div>
          </div>

          {form.kind === 'survey' ? (
            <div className="mt-4 space-y-3">
              <div className="flex items-center justify-between">
                <h4 className="text-lg font-semibold">Questions / Quiz items</h4>
                <button
                  onClick={addQuestion}
                  className="text-sm px-3 py-1 rounded-full bg-indigo-500 text-white hover:bg-indigo-400"
                >
                  Add question
                </button>
              </div>
              <p className="text-sm text-slate-300">
                Supports yes/no, single choice, multiple choice, text, and numeric answers. Responses are stored in announcement_responses.
              </p>
              {form.questions.map((question) => (
                <div key={question.id} className="rounded-2xl border border-white/10 bg-white/5 p-4 space-y-3">
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                    <div>
                      <label className="text-sm text-slate-200">Prompt</label>
                      <input
                        value={question.prompt}
                        onChange={(e) => updateQuestion(question.id, { prompt: e.target.value })}
                        className="mt-1 w-full rounded-xl bg-white/5 border border-white/10 px-4 py-2 text-white focus:ring-2 focus:ring-indigo-500 outline-none"
                        placeholder="E.g., Years of experience"
                      />
                    </div>
                    <div>
                      <label className="text-sm text-slate-200">Type</label>
                      <select
                        value={question.type}
                        onChange={(e) =>
                          updateQuestion(question.id, {
                            type: e.target.value as AnnouncementQuestion['type'],
                            options:
                              e.target.value === 'single_choice' || e.target.value === 'multi_choice'
                                ? question.options ?? ['Option 1']
                                : [],
                          })
                        }
                        className="mt-1 w-full rounded-xl bg-white/5 border border-white/10 px-4 py-2 text-white focus:ring-2 focus:ring-indigo-500 outline-none"
                      >
                        <option value="yes_no">Yes / No</option>
                        <option value="single_choice">Single choice</option>
                        <option value="multi_choice">Multiple choice</option>
                        <option value="text">Text input</option>
                        <option value="number">Number</option>
                      </select>
                    </div>
                  </div>
                  <div className="flex items-center gap-3">
                    <input
                      type="checkbox"
                      checked={question.required}
                      onChange={(e) => updateQuestion(question.id, { required: e.target.checked })}
                      className="h-4 w-4 rounded border-white/20 bg-white/10"
                    />
                    <label className="text-sm text-slate-200">Required</label>
                  </div>
                  {(question.type === 'single_choice' || question.type === 'multi_choice') && (
                    <div className="space-y-2">
                      <div className="flex items-center justify-between">
                        <p className="text-sm text-slate-200">Options</p>
                        <button
                          onClick={() => addOption(question.id)}
                          className="text-xs px-3 py-1 rounded-full bg-white/10 text-white hover:bg-white/20"
                        >
                          Add option
                        </button>
                      </div>
                      {(question.options ?? []).map((opt, idx) => (
                        <input
                          key={idx}
                          value={opt}
                          onChange={(e) => {
                            const next = [...(question.options ?? [])];
                            next[idx] = e.target.value;
                            updateQuestion(question.id, { options: next });
                          }}
                          className="w-full rounded-xl bg-white/5 border border-white/10 px-4 py-2 text-white focus:ring-2 focus:ring-indigo-500 outline-none"
                          placeholder={`Option ${idx + 1}`}
                        />
                      ))}
                    </div>
                  )}
                </div>
              ))}
            </div>
          ) : null}

          {error ? <p className="text-sm text-rose-300 mt-3">{error}</p> : null}
          <div className="mt-4 flex items-center justify-between">
            <p className="text-sm text-slate-300">
              Saved to Supabase with RLS; the mobile app reads only audience-matching and time-valid rows.
            </p>
            <button
              onClick={onCreate}
              disabled={saving}
              className="px-5 py-2 rounded-full bg-indigo-500 hover:bg-indigo-400 text-white font-semibold shadow-lg shadow-indigo-500/30 disabled:opacity-50"
            >
              {saving ? 'Saving…' : 'Publish'}
            </button>
          </div>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          {live.map((announcement) => (
            <div key={announcement.id} className="rounded-2xl border border-white/10 bg-white/5 p-4 space-y-2">
              <div className="flex items-start justify-between gap-2">
                <div>
                  <p className="text-xs text-indigo-200 uppercase tracking-[0.2em]">{announcement.kind}</p>
                  <h4 className="text-lg font-semibold">{announcement.title}</h4>
                  <p className="text-sm text-slate-200">{announcement.body}</p>
                </div>
                <span
                  className={`px-3 py-1 text-xs rounded-full ${
                    announcement.status === 'live'
                      ? 'bg-emerald-500/20 border border-emerald-300/40'
                      : 'bg-amber-500/20 border border-amber-300/40'
                  }`}
                >
                  {announcement.status}
                </span>
              </div>
              <div className="text-xs text-slate-300 flex flex-wrap gap-2">
                <span>Audience: {announcement.audience}</span>
                <span>Priority: {announcement.priority}</span>
                <span>From: {formatDate(announcement.start_at)}</span>
                <span>To: {formatDate(announcement.end_at)}</span>
              </div>
              {announcement.kind === 'survey' && announcement.responses ? (
                <div className="rounded-xl bg-white/5 border border-white/10 p-3">
                  <p className="text-sm text-slate-200 mb-2">Responses</p>
                  {announcement.questions.map((q) => (
                    <div key={q.id} className="mb-3">
                      <p className="text-sm font-semibold">{q.prompt}</p>
                      <div className="mt-1">
                        <ResponsiveContainer width="100%" height={120}>
                          <BarChart
                            data={(announcement.responses ?? [])
                              .filter((r) => r.question_id === q.id)
                              .map((r) => ({
                                label: r.option ?? String(r.value ?? '—'),
                                count: r.count,
                              }))}
                          >
                            <XAxis dataKey="label" stroke="#cbd5e1" fontSize={11} />
                            <YAxis stroke="#cbd5e1" fontSize={11} />
                            <Tooltip
                              contentStyle={{ background: '#0f172a', border: '1px solid #334155', borderRadius: 12 }}
                              labelStyle={{ color: '#e2e8f0' }}
                            />
                            <Bar dataKey="count" fill="#60a5fa" radius={[8, 8, 0, 0]} />
                          </BarChart>
                        </ResponsiveContainer>
                      </div>
                    </div>
                  ))}
                </div>
              ) : null}
            </div>
          ))}
        </div>
      </div>

      <div className="space-y-4">
        <div className="rounded-2xl border border-white/10 bg-white/5 p-5">
          <h4 className="text-lg font-semibold mb-2">Governance</h4>
          <ul className="list-disc list-inside text-sm text-slate-200 space-y-1">
            <li>Admins live in table <code>admin_users</code> with RLS.</li>
            <li>Announcements + surveys live in <code>announcements</code> and <code>announcement_responses</code>.</li>
            <li>Mobile app fetches only active rows by time window and audience.</li>
            <li>Service role stays server-side. Do not embed it in the client.</li>
          </ul>
        </div>
        <div className="rounded-2xl border border-white/10 bg-white/5 p-5">
          <h4 className="text-lg font-semibold mb-2">Operations</h4>
          <ul className="list-disc list-inside text-sm text-slate-200 space-y-1">
            <li>Schedule start/end windows to control carousel visibility.</li>
            <li>Use max impressions to avoid fatigue.</li>
            <li>Survey results aggregate into charts above.</li>
            <li>See ANNOUNCEMENT_ADMIN_DASHBOARD_PROMPT.md for content rules.</li>
          </ul>
        </div>
      </div>
    </div>
  );
}
