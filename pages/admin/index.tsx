import Head from 'next/head';
import { useEffect, useMemo, useState } from 'react';
import type { GetServerSideProps } from 'next';
import { getAdminSessionFromRequest } from '../../lib/adminAuth';
import AnnouncementForm, { AnnouncementFormData } from '../../components/AnnouncementForm';
import { EnhancedUsersPanel } from '../../components/EnhancedUsersPanel';
import type {
  AdminSession,
  AnnouncementDigestItem,
  DashboardResponse,
  ToolLeaderboardRow,
  ToolDrilldownResponse,
  AdminUserRow,
  ClosedTestingSignup,
  ClosedTestingStatus,
} from '../../types/admin';

interface AdminPageProps {
  admin: AdminSession;
}

type AdminTab = 'home' | 'feedbacks' | 'announcements' | 'tools' | 'users' | 'responses' | 'sessions' | 'credits' | 'closedTesting';

const RANGE_OPTIONS = [7, 30, 90];

const AdminDashboardPage = ({ admin }: AdminPageProps) => {
  const [activeTab, setActiveTab] = useState<AdminTab>('home');
  const [days, setDays] = useState(30);
  const [data, setData] = useState<DashboardResponse | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [toolLeaderboard, setToolLeaderboard] = useState<ToolLeaderboardRow[]>([]);
  const [toolLoading, setToolLoading] = useState(false);
  const [toolError, setToolError] = useState<string | null>(null);
  const [selectedToolId, setSelectedToolId] = useState<string | null>(null);
  const [toolDrilldown, setToolDrilldown] = useState<ToolDrilldownResponse | null>(null);
  const [toolDetailsOpen, setToolDetailsOpen] = useState(false);
  const selectedToolRow = useMemo(
    () => toolLeaderboard.find((t) => t.toolId === selectedToolId) ?? null,
    [selectedToolId, toolLeaderboard]
  );
  const [feedbackTypeFilter, setFeedbackTypeFilter] = useState<string | null>(null);
  const [allFeedbacks, setAllFeedbacks] = useState<any[]>([]);
  const [feedbacksLoading, setFeedbacksLoading] = useState(false);
  const [announcements, setAnnouncements] = useState<AnnouncementDigestItem[]>([]);
  const [announcementsLoading, setAnnouncementsLoading] = useState(false);
  const [announcementsError, setAnnouncementsError] = useState<string | null>(null);
  const [announcementToCreate, setAnnouncementToCreate] = useState(false);
  const [announcementToEdit, setAnnouncementToEdit] = useState<any | null>(null);
  const [newAnnouncementForm, setNewAnnouncementForm] = useState({
    title: '',
    content: '',
    severity: 'info' as const,
    expiresAt: '',
  });

  const [usersLoading, setUsersLoading] = useState(false);
  const [usersError, setUsersError] = useState<string | null>(null);
  const [users, setUsers] = useState<AdminUserRow[]>([]);

  // Survey responses state
  const [surveyResponses, setSurveyResponses] = useState<any[]>([]);
  const [responsesLoading, setResponsesLoading] = useState(false);
  const [responsesError, setResponsesError] = useState<string | null>(null);
  const [selectedSurveyId, setSelectedSurveyId] = useState<string | null>(null);
  const [surveysList, setSurveysList] = useState<{ id: string; title: string; questionCount: number; responseCount: number }[]>([]);

  // Credits state
  const [assetTypes, setAssetTypes] = useState<any[]>([]);
  const [sites, setSites] = useState<any[]>([]);
  const [links, setLinks] = useState<any[]>([]);
  const [creditsLoading, setCreditsLoading] = useState(false);
  const [creditsError, setCreditsError] = useState<string | null>(null);
  const [selectedAssetType, setSelectedAssetType] = useState<string | null>(null);
  const [selectedSite, setSelectedSite] = useState<string | null>(null);
  const [creditModalType, setCreditModalType] = useState<'asset-type' | 'site' | 'link' | null>(null);
  const [editingCreditItem, setEditingCreditItem] = useState<any>(null);
  const [creditFormData, setCreditFormData] = useState<Record<string, any>>({});
  const [savingCredit, setSavingCredit] = useState(false);

  // Closed testing state
  const [closedTesting, setClosedTesting] = useState<ClosedTestingSignup[]>([]);
  const [closedTestingLoading, setClosedTestingLoading] = useState(false);
  const [closedTestingError, setClosedTestingError] = useState<string | null>(null);
  const [closedTestingFilter, setClosedTestingFilter] = useState<ClosedTestingStatus | 'all'>('pending');
  const [updatingSignupId, setUpdatingSignupId] = useState<string | null>(null);
  const [copyNotice, setCopyNotice] = useState<string | null>(null);

  // Load main analytics
  useEffect(() => {
    let cancelled = false;

    const load = async () => {
      setLoading(true);
      setError(null);
      try {
        const response = await fetch(`/api/admin/analytics?days=${days}`);
        if (response.status === 401) {
          window.location.href = '/admin/login';
          return;
        }
        if (!response.ok) {
          const payload = await response.json();
          if (!cancelled) {
            setError(payload.error ?? 'Failed to load analytics.');
          }
          return;
        }
        const payload = (await response.json()) as DashboardResponse;
        if (!cancelled) {
          setData(payload);
          setAnnouncements(payload.announcements);
        }
      } catch (err) {
        if (!cancelled) {
          setError('Network error while loading analytics.');
        }
      } finally {
        if (!cancelled) {
          setLoading(false);
        }
      }
    };

    load();
    return () => {
      cancelled = true;
    };
  }, [days]);

  // Load tool leaderboard
  useEffect(() => {
    let cancelled = false;
    const loadTools = async () => {
      setToolLoading(true);
      setToolError(null);
      try {
        const response = await fetch(`/api/admin/tool-usage?days=${days}`);
        if (response.status === 401) {
          window.location.href = '/admin/login';
          return;
        }
        if (!response.ok) {
          const payload = await response.json();
          if (!cancelled) {
            setToolError(payload.error ?? 'Failed to load tool usage.');
          }
          return;
        }
        const payload = await response.json();
        const tools = (payload.tools as ToolLeaderboardRow[]) ?? [];
        if (!cancelled) {
          setToolLeaderboard(tools);
          if (!selectedToolId && tools.length > 0) {
            setSelectedToolId(tools[0].toolId);
          }
        }
      } catch (err) {
        if (!cancelled) {
          setToolError('Network error while loading tool usage.');
        }
      } finally {
        if (!cancelled) {
          setToolLoading(false);
        }
      }
    };
    loadTools();
    return () => {
      cancelled = true;
    };
  }, [days]);

  // Load tool drilldown
  useEffect(() => {
    let cancelled = false;
    const loadDrilldown = async () => {
      if (!selectedToolId) return;
      console.log('🔍 Loading drilldown for tool:', selectedToolId);
      setToolLoading(true);
      setToolError(null);
      try {
        const url = `/api/admin/tool-usage?toolId=${encodeURIComponent(selectedToolId)}&days=${days}`;
        console.log('📡 Fetching:', url);
        const response = await fetch(url);
        console.log('✅ Response status:', response.status);
        if (response.status === 401) {
          window.location.href = '/admin/login';
          return;
        }
        if (!response.ok) {
          const payload = await response.json();
          console.error('❌ API error:', payload);
          if (!cancelled) {
            setToolError(payload.error ?? 'Failed to load tool drilldown.');
          }
          return;
        }
        const payload = (await response.json()) as ToolDrilldownResponse;
        console.log('📊 Drilldown data:', payload);
        if (!cancelled) {
          setToolDrilldown(payload);
        }
      } catch (err) {
        console.error('💥 Drilldown error:', err);
        if (!cancelled) {
          setToolError('Network error while loading tool drilldown.');
        }
      } finally {
        if (!cancelled) {
          setToolLoading(false);
        }
      }
    };
    loadDrilldown();
    return () => {
      cancelled = true;
    };
  }, [selectedToolId, days]);

  // Load users list
  useEffect(() => {
    if (activeTab !== 'users') return;
    let cancelled = false;
    const loadUsers = async () => {
      setUsersLoading(true);
      setUsersError(null);
      try {
        const response = await fetch('/api/admin/users?limit=200');
        if (response.status === 401) {
          window.location.href = '/admin/login';
          return;
        }
        if (!response.ok) {
          const payload = await response.json();
          if (!cancelled) {
            setUsersError(payload.error ?? 'Failed to load users');
          }
          return;
        }
        const payload = await response.json();
        if (!cancelled) {
          setUsers(payload.users ?? []);
        }
      } catch (err) {
        if (!cancelled) {
          setUsersError('Network error while loading users.');
        }
      } finally {
        if (!cancelled) {
          setUsersLoading(false);
        }
      }
    };
    loadUsers();
    return () => {
      cancelled = true;
    };
  }, [activeTab]);

  // Load all feedbacks
  useEffect(() => {
    if (activeTab !== 'feedbacks') return;

    let cancelled = false;
    const loadFeedbacks = async () => {
      setFeedbacksLoading(true);
      try {
        const response = await fetch(`/api/admin/feedbacks?days=${days}`);
        if (response.ok) {
          const payload = await response.json();
          if (!cancelled) {
            setAllFeedbacks(payload.feedbacks || []);
          }
        }
      } catch (err) {
        console.error('Error loading feedbacks:', err);
      } finally {
        if (!cancelled) {
          setFeedbacksLoading(false);
        }
      }
    };
    loadFeedbacks();
    return () => {
      cancelled = true;
    };
  }, [activeTab, days]);

  // Load announcements
  useEffect(() => {
    if (activeTab !== 'announcements') return;

    let cancelled = false;
    const loadAnnouncements = async () => {
      setAnnouncementsLoading(true);
      setAnnouncementsError(null);
      try {
        const response = await fetch('/api/admin/announcements');
        if (response.ok) {
          const payload = await response.json();
          if (!cancelled) {
            setAnnouncements(payload.announcements || []);
          }
        } else {
          setAnnouncementsError('Failed to load announcements');
        }
      } catch (err) {
        console.error('Error loading announcements:', err);
        if (!cancelled) {
          setAnnouncementsError('Error loading announcements');
        }
      } finally {
        if (!cancelled) {
          setAnnouncementsLoading(false);
        }
      }
    };
    loadAnnouncements();
    return () => {
      cancelled = true;
    };
  }, [activeTab]);

  // Load survey responses
  useEffect(() => {
    if (activeTab !== 'responses') return;

    let cancelled = false;
    const loadResponses = async () => {
      setResponsesLoading(true);
      setResponsesError(null);
      try {
        const url = selectedSurveyId 
          ? `/api/admin/survey-responses?announcementId=${selectedSurveyId}`
          : '/api/admin/survey-responses';
        const response = await fetch(url);
        if (response.ok) {
          const payload = await response.json();
          if (!cancelled) {
            setSurveyResponses(payload.responses || []);
            setSurveysList(payload.surveys || []);
          }
        } else {
          setResponsesError('Failed to load survey responses');
        }
      } catch (err) {
        console.error('Error loading survey responses:', err);
        if (!cancelled) {
          setResponsesError('Error loading survey responses');
        }
      } finally {
        if (!cancelled) {
          setResponsesLoading(false);
        }
      }
    };
    loadResponses();
    return () => {
      cancelled = true;
    };
  }, [activeTab, selectedSurveyId]);

  // Load credits data
  useEffect(() => {
    if (activeTab !== 'credits') return;

    let cancelled = false;
    const loadCredits = async () => {
      setCreditsLoading(true);
      setCreditsError(null);
      try {
        const response = await fetch('/api/admin/credits');
        if (response.status === 401) {
          window.location.href = '/admin/login';
          return;
        }
        if (response.ok) {
          const payload = await response.json();
          if (!cancelled) {
            setAssetTypes(payload.assetTypes || []);
            setSites(payload.sites || []);
            setLinks(payload.links || []);
          }
        } else {
          setCreditsError('Failed to load credits data');
        }
      } catch (err) {
        console.error('Error loading credits:', err);
        if (!cancelled) {
          setCreditsError('Error loading credits data');
        }
      } finally {
        if (!cancelled) {
          setCreditsLoading(false);
        }
      }
    };
    loadCredits();
    return () => {
      cancelled = true;
    };
  }, [activeTab]);

  // Load closed testing signups
  useEffect(() => {
    if (activeTab !== 'closedTesting') return;

    let cancelled = false;
    const loadClosedTesting = async () => {
      setClosedTestingLoading(true);
      setClosedTestingError(null);
      try {
        const response = await fetch('/api/admin/closed-testing');
        if (response.status === 401) {
          window.location.href = '/admin/login';
          return;
        }
        const payload = await response.json().catch(() => ({}));
        if (!response.ok) {
          if (!cancelled) {
            setClosedTestingError(payload.error ?? 'Failed to load signups');
          }
          return;
        }
        if (!cancelled) {
          setClosedTesting(payload.signups || []);
        }
      } catch (err) {
        if (!cancelled) {
          setClosedTestingError('Network error while loading signups.');
        }
      } finally {
        if (!cancelled) {
          setClosedTestingLoading(false);
        }
      }
    };

    loadClosedTesting();
    return () => {
      cancelled = true;
    };
  }, [activeTab]);

  useEffect(() => {
    if (!copyNotice) return;
    const timer = setTimeout(() => setCopyNotice(null), 2000);
    return () => clearTimeout(timer);
  }, [copyNotice]);

  const handleLogout = async () => {
    await fetch('/api/admin/logout', { method: 'POST' });
    window.location.href = '/admin/login';
  };

  const handleCreateAnnouncement = async () => {
    if (!newAnnouncementForm.title.trim()) {
      alert('Title is required');
      return;
    }

    try {
      const response = await fetch('/api/admin/announcements', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          title: newAnnouncementForm.title,
          content: newAnnouncementForm.content,
          severity: newAnnouncementForm.severity,
          status: 'published',
          expiresAt: newAnnouncementForm.expiresAt || null,
        }),
      });

      if (response.ok) {
        setAnnouncements([]);
        setAnnouncementToCreate(false);
        setNewAnnouncementForm({ title: '', content: '', severity: 'info', expiresAt: '' });
        // Reload announcements
        const listResponse = await fetch('/api/admin/announcements');
        const payload = await listResponse.json();
        setAnnouncements(
          payload.announcements.map((item: any) => ({
            id: item.id,
            title: item.title,
            severity: item.severity,
            status: item.status,
            publishedAt: item.createdAt,
            expiresAt: item.expiresAt,
          }))
        );
        alert('Announcement created successfully');
      } else {
        const payload = await response.json().catch(() => ({}));
        alert(payload?.error ? `Failed to create announcement: ${payload.error}` : 'Failed to create announcement');
      }
    } catch (err) {
      console.error('Error creating announcement:', err);
      alert('Error creating announcement');
    }
  };

  const handleDeleteAnnouncement = async (id: string) => {
    if (!confirm('Are you sure you want to delete this announcement?')) {
      return;
    }

    try {
      const response = await fetch(`/api/admin/announcements?id=${id}`, {
        method: 'DELETE',
      });

      if (response.ok) {
        setAnnouncements(announcements.filter(a => a.id !== id));
        alert('Announcement deleted successfully');
      } else {
        alert('Failed to delete announcement');
      }
    } catch (err) {
      console.error('Error deleting announcement:', err);
      alert('Error deleting announcement');
    }
  };

  // Duplicate an announcement as a draft
  const handleDuplicateAnnouncement = (item: any) => {
    // Create a copy with modified properties for draft
    const duplicatedData: any = {
      title: `${item.title} (Copy)`,
      message: item.message || '',
      kind: item.kind || 'announcement',
      surface: item.surface || 'home_banner',
      importance: item.importance || 'medium',
      action_type: item.action_type || 'none',
      action_value: item.action_value || '',
      is_active: false, // Set as draft/inactive
      start_at: new Date().toISOString().slice(0, 16), // Reset start date to now
      end_at: '', // Clear end date
      repeat_mode: item.repeat_mode || 'once',
      repeat_interval_hours: item.repeat_interval_hours || 24,
      repeat_session_interval: item.repeat_session_interval || 1,
      first_view_session_delay: item.first_view_session_delay || 0,
      disappear_after_cta: item.disappear_after_cta || false,
      max_times_seen_per_user: item.max_times_seen_per_user || 1,
      dismissible: item.dismissible !== false,
      dismissible_mode: item.dismissible_mode || 'yes',
      remind_later_count: item.remind_later_count || 3,
      remind_later_sessions: item.remind_later_sessions || 1,
      display_sequence: item.display_sequence || 0,
      // Basic Targeting
      target_country: item.target_country || '',
      target_city: item.target_city || '',
      target_speciality: item.target_speciality || '',
      target_min_app_version: item.target_min_app_version || '',
      target_max_app_version: item.target_max_app_version || '',
      target_logged_in_only: item.target_logged_in_only || false,
      target_anonymous_only: item.target_anonymous_only || false,
      // User Insights Targeting
      target_degree: item.target_degree || '',
      target_subspecialty: item.target_subspecialty || '',
      target_profession: item.target_profession || '',
      target_hospital: item.target_hospital || '',
      target_years_experience: item.target_years_experience || '',
      // Exclusion mode flags
      target_profession_exclude: item.target_profession_exclude || false,
      target_speciality_exclude: item.target_speciality_exclude || false,
      target_subspecialty_exclude: item.target_subspecialty_exclude || false,
      target_degree_exclude: item.target_degree_exclude || false,
      target_experience_exclude: item.target_experience_exclude || false,
      target_country_exclude: item.target_country_exclude || false,
      target_city_exclude: item.target_city_exclude || false,
      // Target incomplete profile
      target_incomplete_profile: item.target_incomplete_profile || false,
      // Device/Platform Targeting
      target_platform: item.target_platform || '',
      target_is_real_device: item.target_is_real_device ?? null,
      target_device_brand: item.target_device_brand || '',
      target_ip_addresses: item.target_ip_addresses || '',
      // Extract metadata fields to top level for the form
      cta_label: item.metadata?.cta_label || '',
      cta_icon: item.metadata?.cta_icon || '→',
      thumbnail: item.metadata?.thumbnail || '',
      image_url: item.metadata?.image_url || '',
      background_color: item.metadata?.background_color || '',
      text_color: item.metadata?.text_color || '',
      custom_color: item.metadata?.custom_color || '',
      survey_category: item.metadata?.survey_category || 'survey',
      survey_badge_text: item.metadata?.survey_badge_text ?? '',
      // Copy questions for surveys
      questions: item.questions || [],
      // Mark as duplicate so form knows to create new (POST) not update (PUT)
      _isDuplicate: true,
      _duplicateKey: Date.now(), // Unique key to force form re-mount
    };
    
    // Open the form with the duplicated data directly
    setAnnouncementToCreate(false);
    setAnnouncementToEdit(duplicatedData);
  };

  // Toggle announcement active/draft status
  const handleToggleAnnouncementStatus = async (id: string, isActive: boolean) => {
    try {
      const response = await fetch(`/api/admin/announcements?id=${id}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ is_active: isActive }),
      });

      if (response.ok) {
        // Update local state
        setAnnouncements(announcements.map(a => 
          a.id === id ? { ...a, is_active: isActive } : a
        ));
      } else {
        const err = await response.json();
        alert(`Failed to update status: ${err.error || 'Unknown error'}`);
      }
    } catch (err) {
      console.error('Error toggling announcement status:', err);
      alert('Error updating announcement status');
    }
  };

  // Credits handlers
  const handleSaveCredit = async () => {
    setSavingCredit(true);
    try {
      const isEdit = !!editingCreditItem;
      const method = isEdit ? 'PUT' : 'POST';
      const url = isEdit
        ? `/api/admin/credits?type=${creditModalType}&id=${editingCreditItem.id}`
        : `/api/admin/credits?type=${creditModalType}`;

      const response = await fetch(url, {
        method,
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(creditFormData),
      });

      if (!response.ok) {
        const payload = await response.json();
        alert(payload.error || 'Failed to save');
        return;
      }

      // Reload credits data
      const reloadResponse = await fetch('/api/admin/credits');
      if (reloadResponse.ok) {
        const payload = await reloadResponse.json();
        setAssetTypes(payload.assetTypes || []);
        setSites(payload.sites || []);
        setLinks(payload.links || []);
      }

      setCreditModalType(null);
      setEditingCreditItem(null);
      setCreditFormData({});
    } catch (err) {
      alert('Error saving data');
    } finally {
      setSavingCredit(false);
    }
  };

  const handleDeleteCredit = async (type: string, id: string, name: string) => {
    if (!confirm(`Are you sure you want to delete "${name}"?`)) return;

    try {
      const response = await fetch(`/api/admin/credits?type=${type}&id=${id}`, {
        method: 'DELETE',
      });

      if (!response.ok && response.status !== 204) {
        const payload = await response.json();
        alert(payload.error || 'Failed to delete');
        return;
      }

      // Reload credits data
      const reloadResponse = await fetch('/api/admin/credits');
      if (reloadResponse.ok) {
        const payload = await reloadResponse.json();
        setAssetTypes(payload.assetTypes || []);
        setSites(payload.sites || []);
        setLinks(payload.links || []);
      }
    } catch (err) {
      alert('Error deleting item');
    }
  };

  const closedTestingStatuses: ClosedTestingStatus[] = ['pending', 'invited', 'activated', 'waitlist', 'declined'];

  const filteredClosedTesting = useMemo(
    () => (closedTestingFilter === 'all' ? closedTesting : closedTesting.filter((s) => s.status === closedTestingFilter)),
    [closedTesting, closedTestingFilter]
  );

  const handleClosedTestingUpdate = async (id: string, update: { status?: ClosedTestingStatus; markEmailSent?: boolean }) => {
    setUpdatingSignupId(id);
    setClosedTestingError(null);
    try {
      const response = await fetch('/api/admin/closed-testing', {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ id, ...update }),
      });
      const payload = await response.json().catch(() => ({}));
      if (!response.ok) {
        setClosedTestingError(payload.error ?? 'Failed to update signup.');
        return;
      }
      const updated = payload.signup as ClosedTestingSignup;
      setClosedTesting((prev) => prev.map((s) => (s.id === updated.id ? updated : s)));
    } catch (err) {
      setClosedTestingError('Network error while updating signup.');
    } finally {
      setUpdatingSignupId(null);
    }
  };

  const buildEmailTemplate = (signup: ClosedTestingSignup) => {
    const firstName = signup.fullName?.split(' ')[0] || 'there';
    const isAndroid = signup.platform === 'android';
    const playLink =
      'https://play.google.com/store/apps/details?id=com.ocuhub.OcuHub&hl=en-US&ah=aWUDqsiuOoiH3wn2qJRT_v4PMpc';
    const subject = `OcuHub ${isAndroid ? 'Android' : 'iOS'} closed testing`;
    const body = [
      `Hi ${firstName},`,
      '',
      'Thanks for joining the OcuHub closed testing group. Your feedback helps us tune the experience for eye-care professionals.',
      isAndroid
        ? `Your Android build is ready. Download here: ${playLink}`
        : 'iOS is still in progress. You’re on the priority list—we’ll email you as soon as the build is ready.',
      '',
      'What helps us most:',
      '- Try the tools you use daily and note anything slow or confusing.',
      '- Share feedback from inside the app (Feedback or Settings → Feedback) so we can track it quickly.',
      '',
      'Thank you for shaping OcuHub.',
      '— OcuHub Team',
    ].join('\n');

    return { subject, body };
  };

  const handleCopyEmail = async (signup: ClosedTestingSignup) => {
    const { subject, body } = buildEmailTemplate(signup);
    const text = `Subject: ${subject}\n\n${body}`;
    try {
      if (typeof navigator !== 'undefined' && navigator.clipboard) {
        await navigator.clipboard.writeText(text);
        setCopyNotice('Email template copied');
        return;
      }
    } catch (err) {
      console.warn('Clipboard copy failed, showing template instead.');
    }
    setCopyNotice('Template ready—paste into email');
    alert(text);
  };

  const formatNumber = (value?: number | null) =>
    new Intl.NumberFormat('en-US', { maximumFractionDigits: 0 }).format(value ?? 0);

  const formatDateTime = (value?: string | null) =>
    value ? new Intl.DateTimeFormat('en-US', { dateStyle: 'medium', timeStyle: 'short' }).format(new Date(value)) : '—';

  const avgSessionMinutes = data?.overview ? (data.overview.avgSessionDurationSeconds / 60).toFixed(1) : '0.0';

  const filteredFeedbacks = feedbackTypeFilter
    ? allFeedbacks.filter(f => f.type === feedbackTypeFilter)
    : allFeedbacks;

  const feedbacksByTool = useMemo(() => {
    const groups = new Map<string, { toolId: string | null; toolName: string; feedbacks: any[] }>();
    filteredFeedbacks.forEach((f) => {
      const toolId = f.toolId ?? 'unknown';
      const toolName = f.toolName ?? 'Unknown Tool';
      if (!groups.has(toolId)) {
        groups.set(toolId, { toolId, toolName, feedbacks: [] });
      }
      groups.get(toolId)?.feedbacks.push(f);
    });
    // sort groups by number of feedbacks desc
    return Array.from(groups.values()).sort((a, b) => b.feedbacks.length - a.feedbacks.length);
  }, [filteredFeedbacks]);

  const feedbackTypes = ['bug', 'feature', 'general'];

  return (
    <>
      <Head>
        <title>OcuHub Admin Console</title>
      </Head>
      <div className="min-h-screen bg-slate-950 text-white">
        <header className="border-b border-white/5 bg-slate-900/80 backdrop-blur sticky top-0 z-50">
          {/* Compact single-row header */}
          <div className="max-w-7xl mx-auto flex items-center justify-between px-4 py-2">
            <div className="flex items-center gap-6">
              <h1 className="text-lg font-semibold text-white">OcuHub <span className="text-indigo-400">Admin</span></h1>
              
              {/* Tab Navigation - inline */}
              <nav className="flex gap-1">
                {(['home', 'tools', 'feedbacks', 'announcements', 'responses', 'closedTesting', 'users', 'sessions', 'credits'] as AdminTab[]).map((tab) => (
                  <button
                    key={tab}
                    onClick={() => setActiveTab(tab)}
                    className={`px-3 py-1.5 text-xs font-medium rounded transition-colors ${
                      activeTab === tab
                        ? 'bg-indigo-500/20 text-indigo-300'
                        : 'text-slate-400 hover:text-slate-200 hover:bg-slate-800'
                    }`}
                  >
                    {tab === 'closedTesting' ? 'Closed testing' : tab.charAt(0).toUpperCase() + tab.slice(1)}
                  </button>
                ))}
              </nav>
            </div>
            
            <div className="flex items-center gap-2">
              {/* Date Range - compact pills */}
              <div className="flex gap-1 mr-2">
                {RANGE_OPTIONS.map((option) => (
                  <button
                    key={option}
                    onClick={() => setDays(option)}
                    className={`px-2 py-1 text-xs font-medium rounded ${
                      days === option
                        ? 'bg-indigo-500 text-white'
                        : 'bg-slate-800 text-slate-400 hover:text-white'
                    }`}
                  >
                    {option}d
                  </button>
                ))}
              </div>
              
              <span className="text-xs text-slate-500">{admin.role}</span>
              <button
                onClick={handleLogout}
                className="px-2 py-1 text-xs text-slate-400 hover:text-white hover:bg-slate-800 rounded"
              >
                Sign out
              </button>
            </div>
          </div>
        </header>

        <main className="max-w-7xl mx-auto px-4 py-10">
          {/* HOME TAB */}
          {activeTab === 'home' && (
            <div className="space-y-8">
              {error && <p className="rounded-xl border border-rose-400/30 bg-rose-950/40 px-4 py-3 text-sm text-rose-200">{error}</p>}

              {/* Overview Cards */}
              <section className="bg-slate-900/60 border border-white/5 rounded-2xl p-6">
                <h2 className="text-xl font-semibold mb-6">Usage Overview</h2>
                <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
                  <StatCard label="Total Users" value={formatNumber(data?.overview?.totalUsers)} />
                  <StatCard label="Active Users" value={`${formatNumber(data?.overview?.activeUsers)} / ${days}d`} />
                  <StatCard label="Sessions" value={formatNumber(data?.overview?.sessionCount)} />
                  <StatCard label="Avg Session (min)" value={avgSessionMinutes} />
                  <StatCard label="Tool Events" value={formatNumber(data?.overview?.toolEventCount)} />
                  <StatCard label="Feedback" value={formatNumber(data?.overview?.feedbackCount)} />
                  <StatCard label="Countries" value={formatNumber(data?.overview?.countryCount)} />
                  <StatCard label="Last Activity" value={formatDateTime(data?.overview?.lastActivity)} isMono />
                </div>
              </section>

              <div className="grid gap-6 lg:grid-cols-2">
                {/* Top Tools */}
                <section className="bg-slate-900/60 border border-white/5 rounded-2xl p-6">
                  <h3 className="text-lg font-semibold mb-4">Top Tools</h3>
                  <div className="space-y-3">
                    {(data?.topTools ?? []).slice(0, 5).map((tool) => (
                      <div key={tool.toolId} className="flex items-center justify-between rounded-lg border border-white/5 bg-slate-800/50 px-4 py-3">
                        <div>
                          <p className="font-medium">{tool.toolName}</p>
                          <p className="text-xs text-slate-400">{formatNumber(tool.uniqueUsers)} users</p>
                        </div>
                        <div className="text-right">
                          <p className="text-sm font-semibold">{formatNumber(tool.totalEvents)} events</p>
                          <p className="text-xs text-slate-500">{formatNumber(tool.totalSessions)} sessions</p>
                        </div>
                      </div>
                    ))}
                  </div>
                </section>

                {/* Latest Announcements */}
                <section className="bg-slate-900/60 border border-white/5 rounded-2xl p-6">
                  <h3 className="text-lg font-semibold mb-4">Latest Announcements</h3>
                  <div className="space-y-3">
                    {announcements.slice(0, 5).map((item) => (
                      <div key={item.id} className="rounded-lg border border-white/5 bg-slate-800/50 px-4 py-3">
                        <div className="flex items-center justify-between">
                          <p className="font-medium text-sm">{item.title}</p>
                          <span className={`text-xs px-2 py-1 rounded-full uppercase tracking-wide ${
                            item.severity === 'critical'
                              ? 'bg-rose-500/20 text-rose-200'
                              : item.severity === 'warning'
                              ? 'bg-amber-500/20 text-amber-100'
                              : 'bg-emerald-500/20 text-emerald-100'
                          }`}>
                            {item.status}
                          </span>
                        </div>
                        <p className="text-xs text-slate-400 mt-1">{formatDateTime(item.publishedAt)}</p>
                      </div>
                    ))}
                  </div>
                </section>
              </div>

              {/* Latest Feedbacks */}
              <section className="bg-slate-900/60 border border-white/5 rounded-2xl p-6">
                <h3 className="text-lg font-semibold mb-4">Latest Feedbacks</h3>
                <div className="space-y-3">
                  {(data?.feedbackSummary ?? []).map((item) => (
                    <div key={item.feedbackType} className="flex items-center justify-between rounded-lg border border-white/5 bg-slate-800/50 px-4 py-3">
                      <div>
                        <p className="font-medium capitalize">{item.feedbackType}</p>
                        <p className="text-xs text-slate-400">{formatNumber(item.feedbackCount)} feedbacks</p>
                      </div>
                      <div className="text-right">
                        {item.avgRating && <p className="text-sm text-amber-300">⭐ {item.avgRating.toFixed(1)}</p>}
                        <p className="text-xs text-slate-500">{formatDateTime(item.lastFeedbackAt)}</p>
                      </div>
                    </div>
                  ))}
                </div>
              </section>
            </div>
          )}

          {/* TOOLS TAB */}
          {activeTab === 'tools' && (
            <div className="space-y-6">
              <section className="bg-slate-900/60 border border-white/5 rounded-2xl p-6">
                <h2 className="text-xl font-semibold mb-4">Tool Leaderboard</h2>
                {toolError && <p className="text-rose-300 text-sm mb-3">{toolError}</p>}
                <div className="overflow-x-auto">
                  <table className="w-full text-sm">
                    <thead>
                      <tr className="text-left text-slate-400 border-b border-white/5">
                        <th className="py-2 px-2">Tool</th>
                        <th className="py-2 px-2">Events</th>
                        <th className="py-2 px-2">Users</th>
                        <th className="py-2 px-2">Sessions</th>
                        <th className="py-2 px-2">Countries</th>
                        <th className="py-2 px-2">Last Used</th>
                      </tr>
                    </thead>
                    <tbody>
                      {toolLeaderboard.length === 0 ? (
                        <tr>
                          <td colSpan={6} className="py-4 text-center text-slate-500">No usage yet.</td>
                        </tr>
                      ) : (
                        toolLeaderboard.map((row) => (
                          <tr
                            key={row.toolId}
                            className={`border-t border-white/5 cursor-pointer hover:bg-slate-800/50 ${
                              selectedToolId === row.toolId && toolDetailsOpen ? 'bg-indigo-500/10' : ''
                            }`}
                            onClick={() => {
                              setSelectedToolId(row.toolId);
                              setToolDetailsOpen(true);
                            }}
                          >
                            <td className="py-3 px-2 text-indigo-100">{row.toolName}</td>
                            <td className="py-3 px-2">{formatNumber(row.events)}</td>
                            <td className="py-3 px-2">{formatNumber(row.uniqueUsers)}</td>
                            <td className="py-3 px-2">{formatNumber(row.uniqueSessions)}</td>
                            <td className="py-3 px-2">{formatNumber(row.countries)}</td>
                            <td className="py-3 px-2 text-xs text-slate-400">{formatDateTime(row.lastEventAt)}</td>
                          </tr>
                        ))
                      )}
                    </tbody>
                  </table>
                </div>
              </section>

              {/* Tool details modal */}
              {toolDetailsOpen && (
                <div className="fixed inset-0 z-50 flex items-start justify-center bg-black/50 backdrop-blur-sm px-4 py-10">
                  <div className="w-full max-w-6xl rounded-2xl bg-slate-950 border border-white/10 shadow-2xl overflow-hidden">
                    <div className="flex flex-col gap-3 border-b border-white/5 px-6 py-4 md:flex-row md:items-center md:justify-between">
                      <div>
                        <p className="text-xs uppercase tracking-[0.3em] text-indigo-300">Tool details</p>
                        <h3 className="text-lg font-semibold text-white">
                          {toolDrilldown?.summary.toolName ?? selectedToolRow?.toolName ?? 'Loading...'}
                        </h3>
                        <p className="text-sm text-slate-400">
                          {toolDrilldown ? 'Detailed usage for the selected tool' : 'Loading usage data...'}
                        </p>
                      </div>
                      <div className="flex flex-wrap items-center gap-2">
                        {selectedToolRow && (
                          <>
                            <span className="px-3 py-2 rounded-lg bg-slate-800/70 border border-white/5 text-xs text-slate-200">
                              Events: {formatNumber(selectedToolRow.events)}
                            </span>
                            <span className="px-3 py-2 rounded-lg bg-slate-800/70 border border-white/5 text-xs text-slate-200">
                              Users: {formatNumber(selectedToolRow.uniqueUsers)}
                            </span>
                            <span className="px-3 py-2 rounded-lg bg-slate-800/70 border border-white/5 text-xs text-slate-200">
                              Sessions: {formatNumber(selectedToolRow.uniqueSessions)}
                            </span>
                            <span className="px-3 py-2 rounded-lg bg-slate-800/70 border border-white/5 text-xs text-slate-200">
                              Countries: {formatNumber(selectedToolRow.countries)}
                            </span>
                          </>
                        )}
                        <button
                          onClick={() => setToolDetailsOpen(false)}
                          className="rounded-xl border border-white/10 bg-slate-800 px-4 py-2 text-sm font-medium text-white hover:bg-slate-700"
                        >
                          Close
                        </button>
                      </div>
                    </div>

                    <div className="p-6 space-y-6 max-h-[75vh] overflow-y-auto pr-2">
                      {!toolDrilldown && toolLoading && <p className="text-slate-400 text-sm">Loading drilldown…</p>}
                      {!toolDrilldown && toolError && <p className="text-rose-400 text-sm">{toolError}</p>}

                      {toolDrilldown && (
                        <>
                          <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
                            <StatCard label="Events" value={formatNumber(toolDrilldown.summary.events)} />
                            <StatCard label="Users" value={formatNumber(toolDrilldown.summary.uniqueUsers)} />
                            <StatCard label="Sessions" value={formatNumber(toolDrilldown.summary.uniqueSessions)} />
                            <StatCard label="Countries" value={formatNumber(toolDrilldown.summary.countries)} />
                          </div>

                          <div className="grid gap-6 lg:grid-cols-2">
                            <div className="rounded-xl border border-white/5 bg-slate-800/60 p-4">
                              <h4 className="text-sm font-semibold mb-2">Top Countries</h4>
                              <div className="space-y-2 max-h-64 overflow-y-auto pr-1">
                                {toolDrilldown.topCountries.length === 0 ? (
                                  <p className="text-slate-500 text-sm">No data</p>
                                ) : (
                                  toolDrilldown.topCountries.map((c) => (
                                    <div key={c.country} className="flex items-center justify-between rounded-lg border border-white/5 bg-slate-900/50 px-3 py-2">
                                      <p className="text-sm">{c.country}</p>
                                      <p className="text-xs font-semibold">{formatNumber(c.events)}</p>
                                    </div>
                                  ))
                                )}
                              </div>
                            </div>

                            <div className="rounded-xl border border-white/5 bg-slate-800/60 p-4">
                              <h4 className="text-sm font-semibold mb-2">Top Cities</h4>
                              <div className="space-y-2 max-h-64 overflow-y-auto pr-1">
                                {toolDrilldown.topCities.length === 0 ? (
                                  <p className="text-slate-500 text-sm">No data</p>
                                ) : (
                                  toolDrilldown.topCities.map((c) => (
                                    <div key={`${c.country}-${c.city}`} className="flex items-center justify-between rounded-lg border border-white/5 bg-slate-900/50 px-3 py-2">
                                      <p className="text-sm">
                                        {c.city}, {c.country}
                                      </p>
                                      <p className="text-xs font-semibold">{formatNumber(c.events)}</p>
                                    </div>
                                  ))
                                )}
                              </div>
                            </div>
                          </div>

                          <div className="grid gap-6 lg:grid-cols-2">
                            <div className="rounded-xl border border-white/5 bg-slate-800/60 p-4">
                              <h4 className="text-sm font-semibold mb-2">Daily Usage</h4>
                              <div className="space-y-3 max-h-64 overflow-y-auto pr-1">
                                {toolDrilldown.daily.length === 0 ? (
                                  <p className="text-slate-500 text-sm">No data</p>
                                ) : (
                                  toolDrilldown.daily.map((d) => (
                                    <div key={d.date} className="flex items-center justify-between text-sm">
                                      <p className="text-slate-300">{d.date}</p>
                                      <p className="font-semibold">{formatNumber(d.events)}</p>
                                    </div>
                                  ))
                                )}
                              </div>
                            </div>

                            <div className="rounded-xl border border-white/5 bg-slate-800/60 p-4">
                              <h4 className="text-sm font-semibold mb-2">Country Series</h4>
                              <div className="space-y-2 max-h-64 overflow-y-auto pr-1">
                                {toolDrilldown.countrySeries.length === 0 ? (
                                  <p className="text-slate-500 text-sm">No data</p>
                                ) : (
                                  toolDrilldown.countrySeries.map((series) => (
                                    <div key={series.country} className="rounded-lg border border-white/5 bg-slate-900/50 p-3">
                                      <p className="text-sm font-semibold">{series.country}</p>
                                      <div className="mt-2 space-y-1 text-xs text-slate-400">
                                        {series.points.map((point) => (
                                          <div key={point.date} className="flex justify-between">
                                            <span>{point.date}</span>
                                            <span className="font-semibold text-slate-200">{formatNumber(point.events)}</span>
                                          </div>
                                        ))}
                                      </div>
                                    </div>
                                  ))
                                )}
                              </div>
                            </div>
                          </div>
                        </>
                      )}
                    </div>
                  </div>
                </div>
              )}
            </div>
          )}

          {/* FEEDBACKS TAB */}
          {activeTab === 'feedbacks' && (
            <div className="space-y-6">
              <section className="bg-slate-900/60 border border-white/5 rounded-2xl p-6">
                <h2 className="text-xl font-semibold mb-4">All Feedbacks</h2>

                {/* Filter by type */}
                <div className="flex gap-2 mb-4">
                  <button
                    onClick={() => setFeedbackTypeFilter(null)}
                    className={`px-4 py-2 rounded-full text-sm font-medium ${
                      feedbackTypeFilter === null
                        ? 'bg-indigo-500 text-white'
                        : 'bg-slate-800 text-slate-300 hover:bg-slate-700'
                    }`}
                  >
                    All
                  </button>
                  {feedbackTypes.map((type) => (
                    <button
                      key={type}
                      onClick={() => setFeedbackTypeFilter(type)}
                      className={`px-4 py-2 rounded-full text-sm font-medium capitalize ${
                        feedbackTypeFilter === type
                          ? 'bg-indigo-500 text-white'
                          : 'bg-slate-800 text-slate-300 hover:bg-slate-700'
                      }`}
                    >
                      {type}
                    </button>
                  ))}
                </div>

                {feedbacksLoading ? (
                  <p className="text-slate-400">Loading feedbacks...</p>
                ) : filteredFeedbacks.length === 0 ? (
                  <p className="text-slate-400">No feedbacks found</p>
                ) : (
                  <div className="space-y-4">
                    {feedbacksByTool.map((group) => (
                      <div key={group.toolId} className="rounded-xl border border-white/5 bg-slate-800/50 p-4">
                        <div className="flex items-center justify-between mb-3">
                          <div>
                            <p className="font-semibold text-indigo-100 text-lg">{group.toolName}</p>
                            <p className="text-xs text-slate-400">{group.feedbacks.length} feedback(s)</p>
                          </div>
                          <span className="text-xs rounded-full bg-slate-700 px-3 py-1 text-slate-200">
                            {group.feedbacks.length}
                          </span>
                        </div>

                        <div className="space-y-3">
                          {group.feedbacks.map((feedback) => (
                            <div key={feedback.id} className="rounded-lg border border-white/5 bg-slate-900/60 p-4 space-y-2">
                              <div className="flex items-start justify-between gap-3">
                                <div className="min-w-0">
                                  <p className="font-semibold text-indigo-100 text-base truncate">
                                    {feedback.toolName || 'Unknown Tool'}
                                  </p>
                                  <p className="text-xs text-slate-400 mt-1 truncate">
                                    {formatDateTime(feedback.submittedAt)}
                                  </p>
                                </div>
                                <span className="text-xs rounded-full bg-slate-800 px-3 py-1 capitalize text-slate-200 shrink-0">
                                  {feedback.type}
                                </span>
                              </div>

                              <p className="text-sm text-slate-200 whitespace-pre-line">{feedback.message}</p>

                              {feedback.metadata && (
                                <details className="rounded border border-white/5 bg-slate-950/60">
                                  <summary className="cursor-pointer px-3 py-2 text-xs text-slate-300">
                                    Tool Results
                                  </summary>
                                  <pre className="px-3 py-2 text-xs text-slate-200 overflow-x-auto">
                                    {JSON.stringify(feedback.metadata, null, 2)}
                                  </pre>
                                </details>
                              )}
                            </div>
                          ))}
                        </div>
                      </div>
                    ))}
                  </div>
                )}
              </section>
            </div>
          )}

          {/* ANNOUNCEMENTS TAB */}
          {activeTab === 'announcements' && (
            <div className="space-y-6">
              {/* Create/Edit Announcement Form */}
              {(announcementToCreate || announcementToEdit) && (
                <AnnouncementForm
                  key={announcementToEdit?._duplicateKey || announcementToEdit?.id || 'new'}
                  initialData={announcementToEdit ? {
                    ...announcementToEdit,
                    // Format dates for datetime-local input (YYYY-MM-DDTHH:mm)
                    start_at: (() => {
                      if (!announcementToEdit.start_at) return '';
                      const d = new Date(announcementToEdit.start_at);
                      return isNaN(d.getTime()) ? '' : d.toISOString().slice(0, 16);
                    })(),
                    end_at: (() => {
                      if (!announcementToEdit.end_at) return '';
                      const d = new Date(announcementToEdit.end_at);
                      return isNaN(d.getTime()) ? '' : d.toISOString().slice(0, 16);
                    })(),
                    // Extract metadata fields to top level (only if not already extracted by duplicate)
                    cta_label: announcementToEdit.cta_label ?? announcementToEdit.metadata?.cta_label ?? '',
                    cta_icon: announcementToEdit.cta_icon ?? announcementToEdit.metadata?.cta_icon ?? '→',
                    thumbnail: announcementToEdit.thumbnail ?? announcementToEdit.metadata?.thumbnail ?? '',
                    image_url: announcementToEdit.image_url ?? announcementToEdit.metadata?.image_url ?? '',
                    background_color: announcementToEdit.background_color ?? announcementToEdit.metadata?.background_color ?? '',
                    text_color: announcementToEdit.text_color ?? announcementToEdit.metadata?.text_color ?? '',
                    custom_color: announcementToEdit.custom_color ?? announcementToEdit.metadata?.custom_color ?? '',
                    // Survey-specific metadata
                    survey_category: announcementToEdit.survey_category ?? announcementToEdit.metadata?.survey_category ?? 'survey',
                    survey_badge_text: announcementToEdit.survey_badge_text ?? announcementToEdit.metadata?.survey_badge_text ?? '',
                  } : undefined}
                  isEditing={!!announcementToEdit && !announcementToEdit._isDuplicate}
                  onSubmit={async (formData: AnnouncementFormData, closeModal = true) => {
                    // For duplicates, always create new (POST)
                    const isDuplicate = announcementToEdit?._isDuplicate;
                    const isEdit = !!announcementToEdit && !isDuplicate;
                    const url = isEdit 
                      ? `/api/admin/announcements?id=${announcementToEdit.id}`
                      : '/api/admin/announcements';
                    const response = await fetch(url, {
                      method: isEdit ? 'PUT' : 'POST',
                      headers: { 'Content-Type': 'application/json' },
                      body: JSON.stringify(formData),
                    });
                    if (!response.ok) {
                      const err = await response.json();
                      throw new Error(err.error || `Failed to ${isEdit ? 'update' : 'create'}`);
                    }
                    // Only close modal if closeModal is true
                    if (closeModal) {
                      setAnnouncementToCreate(false);
                      setAnnouncementToEdit(null);
                    }
                    // Reload announcements
                    const listRes = await fetch('/api/admin/announcements');
                    const payload = await listRes.json();
                    setAnnouncements(payload.announcements || []);
                  }}
                  onCancel={() => {
                    setAnnouncementToCreate(false);
                    setAnnouncementToEdit(null);
                  }}
                />
              )}

              {/* Announcements List */}
              {!announcementToCreate && !announcementToEdit && (
                <section className="bg-slate-900/60 border border-white/5 rounded-2xl p-6">
                  <div className="flex items-center justify-between mb-4">
                    <div>
                      <h2 className="text-xl font-semibold">Manage Announcements & Surveys</h2>
                      <p className="text-sm text-slate-400">Create announcements, surveys, and quizzes for your users</p>
                    </div>
                    <button
                      onClick={() => setAnnouncementToCreate(true)}
                      className="bg-indigo-500 hover:bg-indigo-600 px-4 py-2 rounded-lg text-sm font-medium"
                    >
                      + New Announcement
                    </button>
                  </div>

                    {announcementsLoading ? (
                    <p className="text-slate-400">Loading announcements...</p>
                  ) : announcementsError ? (
                    <p className="text-rose-400">{announcementsError}</p>
                  ) : announcements.length === 0 ? (
                    <p className="text-slate-400">No announcements yet. Click "+ New Announcement" to create one.</p>
                  ) : (
                    <div className="space-y-3">
                      {(announcements as any[]).map((item: any) => (
                        <div key={item.id} className="rounded-lg border border-white/5 bg-slate-800/50 p-4">
                          <div className="flex items-center justify-between">
                            <div className="flex-1">
                              <div className="flex items-center gap-2">
                                <span className={`text-xs px-2 py-0.5 rounded ${item.kind === 'survey' ? 'bg-purple-500/20 text-purple-200' : 'bg-blue-500/20 text-blue-200'}`}>
                                  {item.kind === 'survey' ? '📋 Survey' : '📢 Announcement'}
                                </span>
                                <span className={`text-xs px-2 py-0.5 rounded ${item.surface === 'modal' ? 'bg-amber-500/20 text-amber-200' : item.surface === 'home_banner' ? 'bg-emerald-500/20 text-emerald-200' : 'bg-slate-500/20 text-slate-200'}`}>
                                  {item.surface?.replace('_', ' ')}
                                </span>
                              </div>
                              <p className="font-medium mt-2">{item.title}</p>
                              <p className="text-xs text-slate-400 mt-1">
                                Start: {formatDateTime(item.start_at)} • End: {item.end_at ? formatDateTime(item.end_at) : 'Never'}
                              </p>
                              {item.questions?.length > 0 && (
                                <p className="text-xs text-purple-300 mt-1">📝 {item.questions.length} question(s)</p>
                              )}
                            </div>
                            <div className="flex items-center gap-2">
                              <button
                                onClick={() => handleDuplicateAnnouncement(item)}
                                className="text-slate-400 hover:text-emerald-400 text-sm px-3 py-1 rounded border border-white/10 hover:border-emerald-500/50"
                                title="Duplicate as draft"
                              >
                                Duplicate
                              </button>
                              <button
                                onClick={() => handleToggleAnnouncementStatus(item.id, !item.is_active)}
                                className={`flex items-center gap-1.5 text-xs px-3 py-1.5 rounded border transition-all ${
                                  item.is_active
                                    ? 'bg-emerald-500/20 border-emerald-500/50 text-emerald-300 hover:bg-emerald-500/30'
                                    : 'bg-slate-700/30 border-slate-600/50 text-slate-400 hover:bg-slate-700/50'
                                }`}
                                title={item.is_active ? 'Click to set as Draft' : 'Click to set as Active'}
                              >
                                <span className={`w-2 h-2 rounded-full ${
                                  item.is_active ? 'bg-emerald-400' : 'bg-slate-500'
                                }`} />
                                {item.is_active ? 'Active' : 'Draft'}
                              </button>
                              <button
                                onClick={() => setAnnouncementToEdit(item)}
                                className="text-slate-400 hover:text-indigo-400 text-sm px-3 py-1 rounded border border-white/10 hover:border-indigo-500/50"
                              >
                                Edit
                              </button>
                              <button
                                onClick={() => handleDeleteAnnouncement(item.id)}
                                className="text-slate-400 hover:text-rose-400 text-sm px-3 py-1 rounded border border-white/10 hover:border-rose-500/50"
                              >
                                Delete
                              </button>
                            </div>
                          </div>
                        </div>
                      ))}
                    </div>
                  )}
                </section>
              )}

            </div>
          )}

          {/* RESPONSES TAB */}
          {activeTab === 'responses' && (
            <div className="space-y-6">
              <section className="bg-slate-900/60 border border-white/5 rounded-2xl p-6">
                <div className="flex items-center justify-between mb-4">
                  <div>
                    <h2 className="text-xl font-semibold">Survey & Quiz Responses</h2>
                    <p className="text-sm text-slate-400">View all user responses to surveys and quizzes</p>
                  </div>
                  <div className="flex items-center gap-2">
                    <select
                      value={selectedSurveyId || ''}
                      onChange={(e) => setSelectedSurveyId(e.target.value || null)}
                      className="bg-slate-800 border border-white/10 rounded-lg px-3 py-2 text-sm text-white"
                    >
                      <option value="">All Surveys</option>
                      {surveysList.map((s) => (
                        <option key={s.id} value={s.id}>
                          {s.title} ({s.responseCount} responses)
                        </option>
                      ))}
                    </select>
                  </div>
                </div>

                {/* Survey Stats */}
                <div className="grid gap-4 md:grid-cols-4 mb-6">
                  <StatCard label="Total Surveys" value={formatNumber(surveysList.length)} />
                  <StatCard label="Total Responses" value={formatNumber(surveyResponses.length)} />
                  <StatCard 
                    label="Unique Users" 
                    value={formatNumber(new Set(surveyResponses.map(r => r.userAuthUid).filter(Boolean)).size)} 
                  />
                  <StatCard 
                    label="Profile-Linked" 
                    value={formatNumber(surveyResponses.filter(r => r.linkToProfile).length)} 
                  />
                </div>

                {responsesLoading ? (
                  <p className="text-slate-400">Loading responses...</p>
                ) : responsesError ? (
                  <p className="text-rose-400">{responsesError}</p>
                ) : surveyResponses.length === 0 ? (
                  <p className="text-slate-400">No responses yet. Users will see their responses here after completing surveys.</p>
                ) : (
                  <div className="overflow-x-auto">
                    <table className="w-full text-sm">
                      <thead>
                        <tr className="text-left text-slate-400 border-b border-white/5">
                          <th className="py-2 px-2">Survey</th>
                          <th className="py-2 px-2">Question</th>
                          <th className="py-2 px-2">User</th>
                          <th className="py-2 px-2">First Answer</th>
                          <th className="py-2 px-2">Current Answer</th>
                          <th className="py-2 px-2">Profile Field</th>
                          <th className="py-2 px-2">Date</th>
                        </tr>
                      </thead>
                      <tbody>
                        {surveyResponses.map((r) => {
                          const currentAnswer = r.optionValue || r.textValue || r.numericValue || '—';
                          const firstAnswer = r.firstOptionValue || r.firstTextValue || r.firstNumericValue || currentAnswer;
                          const answerChanged = firstAnswer !== currentAnswer && firstAnswer !== '—';
                          return (
                          <tr key={r.id} className="border-t border-white/5 hover:bg-slate-800/30">
                            <td className="py-3 px-2">
                              <p className="font-medium text-indigo-100 text-xs">{r.announcementTitle}</p>
                            </td>
                            <td className="py-3 px-2">
                              <p className="text-slate-200 text-xs max-w-xs truncate" title={r.questionText}>
                                {r.questionText}
                              </p>
                            </td>
                            <td className="py-3 px-2">
                              <p className="text-slate-200 text-xs">{r.userName || r.userEmail || 'Anonymous'}</p>
                              {r.userAuthUid && (
                                <p className="text-slate-500 text-xs font-mono truncate max-w-[100px]" title={r.userAuthUid}>
                                  {r.userAuthUid.substring(0, 8)}...
                                </p>
                              )}
                            </td>
                            <td className="py-3 px-2">
                              <p className={`text-xs font-medium ${answerChanged ? 'text-amber-300' : 'text-slate-400'}`}>
                                {firstAnswer}
                              </p>
                              {r.firstAnsweredAt && (
                                <p className="text-slate-500 text-xs">{formatDateTime(r.firstAnsweredAt)}</p>
                              )}
                            </td>
                            <td className="py-3 px-2">
                              <p className={`text-xs font-medium ${answerChanged ? 'text-emerald-300' : 'text-emerald-300'}`}>
                                {currentAnswer}
                              </p>
                              {answerChanged && (
                                <span className="text-xs px-1.5 py-0.5 rounded bg-amber-500/20 text-amber-200">Changed Answer</span>
                              )}
                            </td>
                            <td className="py-3 px-2">
                              {r.linkToProfile ? (
                                <span className="text-xs px-2 py-0.5 rounded bg-purple-500/20 text-purple-200">
                                  {r.linkToProfile}
                                </span>
                              ) : (
                                <span className="text-slate-500 text-xs">—</span>
                              )}
                            </td>
                            <td className="py-3 px-2 text-slate-400 text-xs">{formatDateTime(r.createdAt)}</td>
                          </tr>
                        )})}
                      </tbody>
                    </table>
                  </div>
                )}
              </section>

              {/* Surveys Overview */}
              <section className="bg-slate-900/60 border border-white/5 rounded-2xl p-6">
                <h3 className="text-lg font-semibold mb-4">Surveys Overview</h3>
                <div className="grid gap-3 md:grid-cols-2 lg:grid-cols-3">
                  {surveysList.map((survey) => (
                    <div 
                      key={survey.id} 
                      className={`rounded-lg border p-4 cursor-pointer transition-colors ${
                        selectedSurveyId === survey.id 
                          ? 'border-indigo-500/50 bg-indigo-500/10' 
                          : 'border-white/5 bg-slate-800/50 hover:border-white/10'
                      }`}
                      onClick={() => setSelectedSurveyId(selectedSurveyId === survey.id ? null : survey.id)}
                    >
                      <p className="font-medium text-indigo-100">{survey.title}</p>
                      <div className="flex items-center gap-4 mt-2 text-xs text-slate-400">
                        <span>📝 {survey.questionCount} questions</span>
                        <span>💬 {survey.responseCount} responses</span>
                      </div>
                    </div>
                  ))}
                </div>
              </section>
            </div>
          )}

          {/* CLOSED TESTING TAB */}
          {activeTab === 'closedTesting' && (
            <div className="space-y-6">
              <section className="bg-slate-900/60 border border-white/5 rounded-2xl p-6">
                <div className="flex flex-wrap items-start justify-between gap-3 mb-4">
                  <div>
                    <h2 className="text-xl font-semibold">Closed testing signups</h2>
                    <p className="text-sm text-slate-400">Approve testers, track referrals, and copy invite emails.</p>
                  </div>
                  <div className="flex items-center gap-3">
                    <select
                      value={closedTestingFilter}
                      onChange={(e) => setClosedTestingFilter((e.target.value || 'all') as ClosedTestingStatus | 'all')}
                      className="bg-slate-800 border border-white/10 rounded-lg px-3 py-2 text-sm text-white"
                    >
                      <option value="all">All statuses</option>
                      {closedTestingStatuses.map((s) => (
                        <option key={s} value={s}>
                          {s}
                        </option>
                      ))}
                    </select>
                    <span className="text-xs bg-slate-800/80 border border-white/5 rounded-full px-3 py-1 text-slate-300">
                      {closedTesting.length} total
                    </span>
                  </div>
                </div>

                {closedTestingError && (
                  <p className="text-rose-300 text-sm mb-3 bg-rose-500/10 border border-rose-500/30 rounded-lg px-3 py-2">
                    {closedTestingError}
                  </p>
                )}
                {copyNotice && (
                  <p className="text-emerald-200 text-sm mb-3 bg-emerald-500/10 border border-emerald-500/30 rounded-lg px-3 py-2">
                    {copyNotice}
                  </p>
                )}

                {closedTestingLoading ? (
                  <p className="text-slate-400">Loading signups...</p>
                ) : filteredClosedTesting.length === 0 ? (
                  <p className="text-slate-400">No signups yet.</p>
                ) : (
                  <div className="overflow-x-auto">
                    <table className="w-full text-sm">
                      <thead>
                        <tr className="text-left text-slate-400 border-b border-white/5">
                          <th className="py-2 px-2">Tester</th>
                          <th className="py-2 px-2">Details</th>
                          <th className="py-2 px-2">Status</th>
                          <th className="py-2 px-2">Actions</th>
                        </tr>
                      </thead>
                      <tbody>
                        {filteredClosedTesting.map((signup) => (
                          <tr key={signup.id} className="border-t border-white/5 hover:bg-slate-800/30">
                            <td className="py-3 px-2 align-top">
                              <p className="font-semibold text-indigo-100">{signup.fullName}</p>
                              <p className="text-slate-300 text-xs">{signup.email}</p>
                              <p className="text-slate-500 text-xs mt-1">{formatDateTime(signup.createdAt)}</p>
                            </td>
                            <td className="py-3 px-2 align-top">
                              <div className="flex items-center gap-2 flex-wrap">
                                <span className="text-xs px-2 py-1 rounded bg-slate-800 border border-white/5 text-slate-200">
                                  {signup.country}
                                </span>
                                <span
                                  className={`text-xs px-2 py-1 rounded border ${
                                    signup.platform === 'android'
                                      ? 'bg-emerald-500/15 border-emerald-500/30 text-emerald-100'
                                      : 'bg-amber-500/15 border-amber-500/30 text-amber-100'
                                  }`}
                                >
                                  {signup.platform === 'android' ? 'Android' : 'iOS (coming soon)'}
                                </span>
                                <span className="text-xs px-2 py-1 rounded bg-indigo-500/15 border border-indigo-500/40 text-indigo-100 uppercase">
                                  {signup.referralCode}
                                </span>
                              </div>
                              {signup.note && (
                                <p className="text-xs text-slate-300 mt-2 border border-white/5 rounded-lg bg-slate-900/60 px-3 py-2">
                                  {signup.note}
                                </p>
                              )}
                            </td>
                            <td className="py-3 px-2 align-top">
                              <select
                                value={signup.status}
                                onChange={(e) => handleClosedTestingUpdate(signup.id, { status: e.target.value as ClosedTestingStatus })}
                                disabled={updatingSignupId === signup.id}
                                className="bg-slate-800 border border-white/10 rounded-lg px-3 py-2 text-xs text-white"
                              >
                                {closedTestingStatuses.map((s) => (
                                  <option key={s} value={s}>
                                    {s}
                                  </option>
                                ))}
                              </select>
                              <div className="text-xs text-slate-400 mt-2 space-y-1">
                                <p>Invited by: {signup.invitedBy || '—'}</p>
                                <p>Email sent: {signup.emailSentAt ? formatDateTime(signup.emailSentAt) : '—'}</p>
                              </div>
                            </td>
                            <td className="py-3 px-2 align-top">
                              <div className="flex flex-col gap-2">
                                <button
                                  onClick={() => handleCopyEmail(signup)}
                                  className="px-3 py-2 rounded-lg bg-slate-800 border border-white/10 text-xs text-slate-200 hover:border-indigo-400/60"
                                >
                                  Copy email template
                                </button>
                                <button
                                  onClick={() => handleClosedTestingUpdate(signup.id, { markEmailSent: true })}
                                  disabled={updatingSignupId === signup.id}
                                  className="px-3 py-2 rounded-lg bg-indigo-500 text-xs font-semibold text-white hover:bg-indigo-600 disabled:opacity-50"
                                >
                                  Mark email sent
                                </button>
                              </div>
                            </td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  </div>
                )}
              </section>
            </div>
          )}

          {/* USERS TAB */}
          {activeTab === 'users' && (
            <EnhancedUsersPanel onError={(err) => console.error('[admin] Users panel error:', err)} />
          )}

          {/* SESSIONS TAB */}
          {activeTab === 'sessions' && (
            <section className="bg-slate-900/60 border border-white/5 rounded-2xl p-6">
              <h2 className="text-xl font-semibold mb-4">Recent Sessions</h2>
              <div className="overflow-x-auto">
                <table className="w-full text-sm">
                  <thead>
                    <tr className="text-left text-slate-400 border-b border-white/5">
                      <th className="py-2 px-2">User</th>
                      <th className="py-2 px-2">Location</th>
                      <th className="py-2 px-2">Version</th>
                      <th className="py-2 px-2">Duration</th>
                      <th className="py-2 px-2">Start Time</th>
                    </tr>
                  </thead>
                  <tbody>
                    {(data?.recentSessions ?? []).slice(0, 10).map((session) => (
                      <tr key={session.id} className="border-t border-white/5">
                        <td className="py-3 px-2 text-xs">{session.userId.substring(0, 8)}</td>
                        <td className="py-3 px-2 text-xs">
                          {[session.city, session.country].filter(Boolean).join(', ') || 'Unknown'}
                        </td>
                        <td className="py-3 px-2 text-xs">{session.appVersion ?? '—'}</td>
                        <td className="py-3 px-2 text-xs">{(session.durationSeconds / 60).toFixed(1)} min</td>
                        <td className="py-3 px-2 text-xs text-slate-400">{formatDateTime(session.startTime)}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </section>
          )}

          {/* CREDITS TAB */}
          {activeTab === 'credits' && (
            <div className="space-y-6">
              {creditsError && (
                <div className="rounded-xl border border-rose-400/30 bg-rose-950/40 px-4 py-3 text-sm text-rose-200">
                  {creditsError}
                </div>
              )}

              {creditsLoading ? (
                <div className="text-center py-12 text-slate-400">Loading credits data...</div>
              ) : (
                <div className="grid gap-6 lg:grid-cols-3">
                  {/* Asset Types Column */}
                  <div className="bg-slate-900/60 border border-white/5 rounded-2xl p-6">
                    <div className="flex items-center justify-between mb-4">
                      <h2 className="text-lg font-semibold">Asset Types</h2>
                      <button
                        onClick={() => {
                          setCreditModalType('asset-type');
                          setEditingCreditItem(null);
                          setCreditFormData({ name: '', display_name: '', description: '', icon: '', sort_order: 0, is_active: true });
                        }}
                        className="px-3 py-1.5 text-xs font-medium bg-indigo-500 hover:bg-indigo-600 rounded-lg"
                      >
                        + Add Type
                      </button>
                    </div>
                    <div className="space-y-2">
                      {assetTypes.map(type => (
                        <div
                          key={type.id}
                          className={`p-3 rounded-lg border cursor-pointer transition-colors ${
                            selectedAssetType === type.id
                              ? 'border-indigo-500 bg-indigo-500/10'
                              : 'border-white/5 bg-slate-800/50 hover:bg-slate-800'
                          }`}
                          onClick={() => {
                            setSelectedAssetType(type.id);
                            setSelectedSite(null);
                          }}
                        >
                          <div className="flex items-center justify-between">
                            <div className="flex items-center gap-2">
                              {type.icon && <span className="text-lg">{type.icon}</span>}
                              <span className="font-medium">{type.display_name}</span>
                            </div>
                            <div className="flex items-center gap-1">
                              <span className={`text-xs px-2 py-0.5 rounded ${type.is_active ? 'bg-emerald-500/20 text-emerald-300' : 'bg-slate-500/20 text-slate-400'}`}>
                                {type.is_active ? 'Active' : 'Inactive'}
                              </span>
                              <button
                                onClick={(e) => { 
                                  e.stopPropagation(); 
                                  setCreditModalType('asset-type');
                                  setEditingCreditItem(type);
                                  setCreditFormData({ ...type });
                                }}
                                className="p-1 text-slate-400 hover:text-indigo-400"
                                title="Edit"
                              >
                                ✏️
                              </button>
                              <button
                                onClick={(e) => {
                                  e.stopPropagation();
                                  handleDeleteCredit('asset-type', type.id, type.display_name);
                                }}
                                className="p-1 text-slate-400 hover:text-rose-400"
                                title="Delete"
                              >
                                🗑️
                              </button>
                            </div>
                          </div>
                          <div className="text-xs text-slate-400 mt-1">
                            {sites.filter(s => s.asset_type_id === type.id).length} sites
                          </div>
                        </div>
                      ))}
                      {assetTypes.length === 0 && (
                        <div className="text-center py-8 text-slate-500">No asset types yet</div>
                      )}
                    </div>
                  </div>

                  {/* Sites Column */}
                  <div className="bg-slate-900/60 border border-white/5 rounded-2xl p-6">
                    <div className="flex items-center justify-between mb-4">
                      <h2 className="text-lg font-semibold">
                        Sites {selectedAssetType && <span className="text-sm text-slate-400">({assetTypes.find(t => t.id === selectedAssetType)?.display_name})</span>}
                      </h2>
                      <button
                        onClick={() => {
                          setCreditModalType('site');
                          setEditingCreditItem(null);
                          setCreditFormData({ asset_type_id: selectedAssetType || '', name: '', display_name: '', website_url: '', attribution_format: '', description: '', logo_url: '', sort_order: 0, is_active: true });
                        }}
                        disabled={!selectedAssetType}
                        className="px-3 py-1.5 text-xs font-medium bg-indigo-500 hover:bg-indigo-600 rounded-lg disabled:opacity-50 disabled:cursor-not-allowed"
                      >
                        + Add Site
                      </button>
                    </div>
                    <div className="space-y-2">
                      {sites.filter(s => !selectedAssetType || s.asset_type_id === selectedAssetType).map(site => (
                        <div
                          key={site.id}
                          className={`p-3 rounded-lg border cursor-pointer transition-colors ${
                            selectedSite === site.id
                              ? 'border-indigo-500 bg-indigo-500/10'
                              : 'border-white/5 bg-slate-800/50 hover:bg-slate-800'
                          }`}
                          onClick={() => setSelectedSite(site.id)}
                        >
                          <div className="flex items-center justify-between">
                            <span className="font-medium">{site.display_name}</span>
                            <div className="flex items-center gap-1">
                              <span className={`text-xs px-2 py-0.5 rounded ${site.is_active ? 'bg-emerald-500/20 text-emerald-300' : 'bg-slate-500/20 text-slate-400'}`}>
                                {site.is_active ? 'Active' : 'Inactive'}
                              </span>
                              <button
                                onClick={(e) => { 
                                  e.stopPropagation(); 
                                  setCreditModalType('site');
                                  setEditingCreditItem(site);
                                  setCreditFormData({ ...site });
                                }}
                                className="p-1 text-slate-400 hover:text-indigo-400"
                                title="Edit"
                              >
                                ✏️
                              </button>
                              <button
                                onClick={(e) => {
                                  e.stopPropagation();
                                  handleDeleteCredit('site', site.id, site.display_name);
                                }}
                                className="p-1 text-slate-400 hover:text-rose-400"
                                title="Delete"
                              >
                                🗑️
                              </button>
                            </div>
                          </div>
                          {site.website_url && (
                            <a
                              href={site.website_url}
                              target="_blank"
                              rel="noopener noreferrer"
                              className="text-xs text-indigo-400 hover:underline"
                              onClick={(e) => e.stopPropagation()}
                            >
                              {site.website_url}
                            </a>
                          )}
                          <div className="text-xs text-slate-400 mt-1">
                            {links.filter(l => l.site_id === site.id).length} credits
                          </div>
                        </div>
                      ))}
                      {sites.filter(s => !selectedAssetType || s.asset_type_id === selectedAssetType).length === 0 && (
                        <div className="text-center py-8 text-slate-500">
                          {selectedAssetType ? 'No sites for this type' : 'Select an asset type'}
                        </div>
                      )}
                    </div>
                  </div>

                  {/* Links Column */}
                  <div className="bg-slate-900/60 border border-white/5 rounded-2xl p-6">
                    <div className="flex items-center justify-between mb-4">
                      <h2 className="text-lg font-semibold">
                        Credits {selectedSite && <span className="text-sm text-slate-400">({sites.find(s => s.id === selectedSite)?.display_name})</span>}
                      </h2>
                      <button
                        onClick={() => {
                          setCreditModalType('link');
                          setEditingCreditItem(null);
                          setCreditFormData({ site_id: selectedSite || '', title: '', url: '', author: '', description: '', sort_order: 0, is_active: true });
                        }}
                        disabled={!selectedSite}
                        className="px-3 py-1.5 text-xs font-medium bg-indigo-500 hover:bg-indigo-600 rounded-lg disabled:opacity-50 disabled:cursor-not-allowed"
                      >
                        + Add Credit
                      </button>
                    </div>
                    <div className="space-y-2 max-h-[600px] overflow-y-auto">
                      {links.filter(l => !selectedSite || l.site_id === selectedSite).map(link => (
                        <div
                          key={link.id}
                          className="p-3 rounded-lg border border-white/5 bg-slate-800/50"
                        >
                          <div className="flex items-center justify-between">
                            <span className="font-medium text-sm">{link.title}</span>
                            <div className="flex items-center gap-1">
                              <span className={`text-xs px-2 py-0.5 rounded ${link.is_active ? 'bg-emerald-500/20 text-emerald-300' : 'bg-slate-500/20 text-slate-400'}`}>
                                {link.is_active ? 'Active' : 'Inactive'}
                              </span>
                              <button
                                onClick={() => {
                                  setCreditModalType('link');
                                  setEditingCreditItem(link);
                                  setCreditFormData({ ...link });
                                }}
                                className="p-1 text-slate-400 hover:text-indigo-400"
                                title="Edit"
                              >
                                ✏️
                              </button>
                              <button
                                onClick={() => {
                                  handleDeleteCredit('link', link.id, link.title);
                                }}
                                className="p-1 text-slate-400 hover:text-rose-400"
                                title="Delete"
                              >
                                🗑️
                              </button>
                            </div>
                          </div>
                          {link.author && (
                            <div className="text-xs text-slate-400">by {link.author}</div>
                          )}
                          <a
                            href={link.url}
                            target="_blank"
                            rel="noopener noreferrer"
                            className="text-xs text-indigo-400 hover:underline break-all"
                          >
                            {link.url}
                          </a>
                        </div>
                      ))}
                      {links.filter(l => !selectedSite || l.site_id === selectedSite).length === 0 && (
                        <div className="text-center py-8 text-slate-500">
                          {selectedSite ? 'No credits for this site' : 'Select a site'}
                        </div>
                      )}
                    </div>
                  </div>
                </div>
              )}
            </div>
          )}
        </main>

        {/* Credit Modal */}
        {creditModalType && (
          <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm px-4">
            <div className="w-full max-w-lg rounded-2xl bg-slate-950 border border-white/10 shadow-2xl p-6">
              <h3 className="text-lg font-semibold mb-4">
                {editingCreditItem ? 'Edit' : 'Add'} {creditModalType === 'asset-type' ? 'Asset Type' : creditModalType === 'site' ? 'Site' : 'Credit Link'}
              </h3>

              <div className="space-y-4">
                {creditModalType === 'asset-type' && (
                  <>
                    <div>
                      <label className="block text-sm text-slate-400 mb-1">Name (slug)</label>
                      <input
                        type="text"
                        value={creditFormData.name || ''}
                        onChange={(e) => setCreditFormData({ ...creditFormData, name: e.target.value })}
                        className="w-full px-3 py-2 bg-slate-800 border border-white/10 rounded-lg text-white"
                        placeholder="e.g., icon"
                      />
                    </div>
                    <div>
                      <label className="block text-sm text-slate-400 mb-1">Display Name</label>
                      <input
                        type="text"
                        value={creditFormData.display_name || ''}
                        onChange={(e) => setCreditFormData({ ...creditFormData, display_name: e.target.value })}
                        className="w-full px-3 py-2 bg-slate-800 border border-white/10 rounded-lg text-white"
                        placeholder="e.g., Icons"
                      />
                    </div>
                    <div>
                      <label className="block text-sm text-slate-400 mb-1">Icon (Ionicons name)</label>
                      <input
                        type="text"
                        value={creditFormData.icon || ''}
                        onChange={(e) => setCreditFormData({ ...creditFormData, icon: e.target.value })}
                        className="w-full px-3 py-2 bg-slate-800 border border-white/10 rounded-lg text-white"
                        placeholder="e.g., shapes-outline"
                      />
                    </div>
                    <div>
                      <label className="block text-sm text-slate-400 mb-1">Description</label>
                      <textarea
                        value={creditFormData.description || ''}
                        onChange={(e) => setCreditFormData({ ...creditFormData, description: e.target.value })}
                        className="w-full px-3 py-2 bg-slate-800 border border-white/10 rounded-lg text-white"
                        rows={2}
                      />
                    </div>
                  </>
                )}

                {creditModalType === 'site' && (
                  <>
                    <div>
                      <label className="block text-sm text-slate-400 mb-1">Asset Type</label>
                      <select
                        value={creditFormData.asset_type_id || ''}
                        onChange={(e) => setCreditFormData({ ...creditFormData, asset_type_id: e.target.value })}
                        className="w-full px-3 py-2 bg-slate-800 border border-white/10 rounded-lg text-white"
                      >
                        <option value="">Select type...</option>
                        {assetTypes.map(t => (
                          <option key={t.id} value={t.id}>{t.display_name}</option>
                        ))}
                      </select>
                    </div>
                    <div>
                      <label className="block text-sm text-slate-400 mb-1">Name (slug)</label>
                      <input
                        type="text"
                        value={creditFormData.name || ''}
                        onChange={(e) => setCreditFormData({ ...creditFormData, name: e.target.value })}
                        className="w-full px-3 py-2 bg-slate-800 border border-white/10 rounded-lg text-white"
                        placeholder="e.g., flaticon"
                      />
                    </div>
                    <div>
                      <label className="block text-sm text-slate-400 mb-1">Display Name</label>
                      <input
                        type="text"
                        value={creditFormData.display_name || ''}
                        onChange={(e) => setCreditFormData({ ...creditFormData, display_name: e.target.value })}
                        className="w-full px-3 py-2 bg-slate-800 border border-white/10 rounded-lg text-white"
                        placeholder="e.g., Flaticon"
                      />
                    </div>
                    <div>
                      <label className="block text-sm text-slate-400 mb-1">Website URL</label>
                      <input
                        type="url"
                        value={creditFormData.website_url || ''}
                        onChange={(e) => setCreditFormData({ ...creditFormData, website_url: e.target.value })}
                        className="w-full px-3 py-2 bg-slate-800 border border-white/10 rounded-lg text-white"
                        placeholder="https://www.flaticon.com"
                      />
                    </div>
                    <div>
                      <label className="block text-sm text-slate-400 mb-1">Attribution Format (optional)</label>
                      <textarea
                        value={creditFormData.attribution_format || ''}
                        onChange={(e) => setCreditFormData({ ...creditFormData, attribution_format: e.target.value })}
                        className="w-full px-3 py-2 bg-slate-800 border border-white/10 rounded-lg text-white text-sm"
                        rows={2}
                        placeholder='<a href="{url}" title="{title}">{title} by {author}</a>'
                      />
                    </div>
                  </>
                )}

                {creditModalType === 'link' && (
                  <>
                    <div>
                      <label className="block text-sm text-slate-400 mb-1">Site</label>
                      <select
                        value={creditFormData.site_id || ''}
                        onChange={(e) => setCreditFormData({ ...creditFormData, site_id: e.target.value })}
                        className="w-full px-3 py-2 bg-slate-800 border border-white/10 rounded-lg text-white"
                      >
                        <option value="">Select site...</option>
                        {sites.map(s => (
                          <option key={s.id} value={s.id}>{s.display_name}</option>
                        ))}
                      </select>
                    </div>
                    <div>
                      <label className="block text-sm text-slate-400 mb-1">Title</label>
                      <input
                        type="text"
                        value={creditFormData.title || ''}
                        onChange={(e) => setCreditFormData({ ...creditFormData, title: e.target.value })}
                        className="w-full px-3 py-2 bg-slate-800 border border-white/10 rounded-lg text-white"
                        placeholder="e.g., Introduction icons"
                      />
                    </div>
                    <div>
                      <label className="block text-sm text-slate-400 mb-1">URL</label>
                      <input
                        type="url"
                        value={creditFormData.url || ''}
                        onChange={(e) => setCreditFormData({ ...creditFormData, url: e.target.value })}
                        className="w-full px-3 py-2 bg-slate-800 border border-white/10 rounded-lg text-white"
                        placeholder="https://www.flaticon.com/free-icons/introduction"
                      />
                    </div>
                    <div>
                      <label className="block text-sm text-slate-400 mb-1">Author</label>
                      <input
                        type="text"
                        value={creditFormData.author || ''}
                        onChange={(e) => setCreditFormData({ ...creditFormData, author: e.target.value })}
                        className="w-full px-3 py-2 bg-slate-800 border border-white/10 rounded-lg text-white"
                        placeholder="e.g., Aficons studio"
                      />
                    </div>
                  </>
                )}

                <div className="flex items-center gap-4">
                  <div>
                    <label className="block text-sm text-slate-400 mb-1">Sort Order</label>
                    <input
                      type="number"
                      value={creditFormData.sort_order || 0}
                      onChange={(e) => setCreditFormData({ ...creditFormData, sort_order: parseInt(e.target.value) || 0 })}
                      className="w-24 px-3 py-2 bg-slate-800 border border-white/10 rounded-lg text-white"
                    />
                  </div>
                  <div className="flex items-center gap-2 mt-6">
                    <input
                      type="checkbox"
                      id="is_active"
                      checked={creditFormData.is_active !== false}
                      onChange={(e) => setCreditFormData({ ...creditFormData, is_active: e.target.checked })}
                      className="w-4 h-4"
                    />
                    <label htmlFor="is_active" className="text-sm text-slate-400">Active</label>
                  </div>
                </div>
              </div>

              <div className="flex justify-end gap-3 mt-6">
                <button
                  onClick={() => {
                    setCreditModalType(null);
                    setEditingCreditItem(null);
                    setCreditFormData({});
                  }}
                  className="px-4 py-2 text-sm text-slate-400 hover:text-white"
                >
                  Cancel
                </button>
                <button
                  onClick={handleSaveCredit}
                  disabled={savingCredit}
                  className="px-4 py-2 text-sm font-medium bg-indigo-500 hover:bg-indigo-600 rounded-lg disabled:opacity-50"
                >
                  {savingCredit ? 'Saving...' : 'Save'}
                </button>
              </div>
            </div>
          </div>
        )}
      </div>
    </>
  );
};

const StatCard = ({ label, value, isMono = false }: { label: string; value: string; isMono?: boolean }) => (
  <div className="rounded-2xl border border-white/5 bg-slate-900/60 p-4">
    <p className="text-sm text-slate-400">{label}</p>
    <p className={`mt-2 text-2xl font-semibold ${isMono ? 'font-mono text-slate-100' : ''}`}>{value}</p>
  </div>
);

export const getServerSideProps: GetServerSideProps<AdminPageProps> = async ({ req }) => {
  const session = getAdminSessionFromRequest(req);
  if (!session) {
    return {
      redirect: {
        destination: '/admin/login',
        permanent: false,
      },
    };
  }

  return {
    props: {
      admin: session,
    },
  };
};

export default AdminDashboardPage;
