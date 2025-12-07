import Head from 'next/head';
import { useEffect, useMemo, useState } from 'react';
import type { GetServerSideProps } from 'next';
import { getAdminSessionFromRequest } from '../../lib/adminAuth';
import AnnouncementForm, { AnnouncementFormData } from '../../components/AnnouncementForm';
import type {
  AdminSession,
  AnnouncementDigestItem,
  DashboardResponse,
  ToolLeaderboardRow,
  ToolDrilldownResponse,
  AdminUserRow,
} from '../../types/admin';

interface AdminPageProps {
  admin: AdminSession;
}

type AdminTab = 'home' | 'feedbacks' | 'announcements' | 'tools' | 'users' | 'sessions';

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
  const [newAnnouncementForm, setNewAnnouncementForm] = useState({
    title: '',
    content: '',
    severity: 'info' as const,
    expiresAt: '',
  });

  const [usersLoading, setUsersLoading] = useState(false);
  const [usersError, setUsersError] = useState<string | null>(null);
  const [users, setUsers] = useState<AdminUserRow[]>([]);

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
                {(['home', 'tools', 'feedbacks', 'announcements', 'users', 'sessions'] as AdminTab[]).map((tab) => (
                  <button
                    key={tab}
                    onClick={() => setActiveTab(tab)}
                    className={`px-3 py-1.5 text-xs font-medium rounded transition-colors ${
                      activeTab === tab
                        ? 'bg-indigo-500/20 text-indigo-300'
                        : 'text-slate-400 hover:text-slate-200 hover:bg-slate-800'
                    }`}
                  >
                    {tab.charAt(0).toUpperCase() + tab.slice(1)}
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
              {announcementToCreate && (
                <AnnouncementForm
                  onSubmit={async (formData: AnnouncementFormData) => {
                    const response = await fetch('/api/admin/announcements', {
                      method: 'POST',
                      headers: { 'Content-Type': 'application/json' },
                      body: JSON.stringify(formData),
                    });
                    if (!response.ok) {
                      const err = await response.json();
                      throw new Error(err.error || 'Failed to create');
                    }
                    setAnnouncementToCreate(false);
                    // Reload announcements
                    const listRes = await fetch('/api/admin/announcements');
                    const payload = await listRes.json();
                    setAnnouncements(payload.announcements || []);
                  }}
                  onCancel={() => setAnnouncementToCreate(false)}
                />
              )}

              {/* Announcements List */}
              {!announcementToCreate && (
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
                                <span className={`text-xs px-2 py-0.5 rounded ${item.is_active ? 'bg-green-500/20 text-green-200' : 'bg-slate-500/20 text-slate-400'}`}>
                                  {item.is_active ? '✅ Active' : '⏸️ Inactive'}
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

          {/* USERS TAB */}
          {activeTab === 'users' && (
            <div className="space-y-6">
              <section className="bg-slate-900/60 border border-white/5 rounded-2xl p-6">
                <h2 className="text-xl font-semibold mb-4">User Analytics</h2>
                <div className="grid gap-4 md:grid-cols-3">
                  <StatCard label="Total Users" value={formatNumber(data?.overview?.totalUsers)} />
                  <StatCard label="Active Users (30d)" value={formatNumber(data?.overview?.activeUsers)} />
                  <StatCard label="New Users" value="TBD" />
                </div>
              </section>

              <section className="bg-slate-900/60 border border-white/5 rounded-2xl p-6">
                <div className="flex items-center justify-between mb-4">
                  <div>
                    <h2 className="text-xl font-semibold">All Users</h2>
                    <p className="text-sm text-slate-400">Sorted by most recent sign-up</p>
                  </div>
                  <span className="text-xs rounded-full bg-slate-800/80 border border-white/5 px-3 py-1 text-slate-300">
                    Showing {users.length} users
                  </span>
                </div>

                {usersLoading ? (
                  <p className="text-slate-400">Loading users…</p>
                ) : usersError ? (
                  <p className="text-rose-400">{usersError}</p>
                ) : users.length === 0 ? (
                  <p className="text-slate-400">No users found</p>
                ) : (
                  <div className="overflow-x-auto">
                    <table className="w-full text-sm">
                      <thead>
                        <tr className="text-left text-slate-400 border-b border-white/5">
                          <th className="py-2 px-2">User</th>
                          <th className="py-2 px-2">Email</th>
                          <th className="py-2 px-2">Joined</th>
                          <th className="py-2 px-2">Last Seen</th>
                          <th className="py-2 px-2">Location</th>
                        </tr>
                      </thead>
                      <tbody>
                        {users.map((u) => (
                          <tr key={u.id} className="border-t border-white/5">
                            <td className="py-3 px-2">
                              <p className="font-medium text-indigo-100">
                                {u.displayName || 'Unnamed'}
                              </p>
                              <p className="text-xs text-slate-400 font-mono">{u.id}</p>
                            </td>
                            <td className="py-3 px-2 text-slate-200">{u.email || '—'}</td>
                            <td className="py-3 px-2 text-slate-200 text-xs">{formatDateTime(u.createdAt)}</td>
                            <td className="py-3 px-2 text-slate-200 text-xs">{formatDateTime(u.lastSeenAt)}</td>
                            <td className="py-3 px-2 text-slate-200 text-xs">
                              {[u.city, u.country].filter(Boolean).join(', ') || '—'}
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
        </main>
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
