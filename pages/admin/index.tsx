import Head from 'next/head';
import { useEffect, useMemo, useState } from 'react';
import type { GetServerSideProps } from 'next';
import { getAdminSessionFromRequest } from '../../lib/adminAuth';
import type {
  AdminSession,
  AnnouncementDigestItem,
  DashboardResponse,
  ToolUsageRow,
  UsageTimelinePoint,
} from '../../types/admin';

interface AdminPageProps {
  admin: AdminSession;
}

const RANGE_OPTIONS = [7, 30, 90];

const AdminDashboardPage = ({ admin }: AdminPageProps) => {
  const [days, setDays] = useState(30);
  const [data, setData] = useState<DashboardResponse | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

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

  const handleLogout = async () => {
    await fetch('/api/admin/logout', { method: 'POST' });
    window.location.href = '/admin/login';
  };

  const formatNumber = (value?: number | null) =>
    new Intl.NumberFormat('en-US', { maximumFractionDigits: 0 }).format(value ?? 0);

  const formatDateTime = (value?: string | null) =>
    value ? new Intl.DateTimeFormat('en-US', { dateStyle: 'medium', timeStyle: 'short' }).format(new Date(value)) : '—';

  const avgSessionMinutes = data?.overview ? (data.overview.avgSessionDurationSeconds / 60).toFixed(1) : '0.0';

  const maxTimelineValue = useMemo(() => {
    if (!data?.timeline?.length) return 0;
    return Math.max(...data.timeline.map((point) => point.toolEvents));
  }, [data]);

  const timelineData: UsageTimelinePoint[] = data?.timeline ?? [];
  const topTools: ToolUsageRow[] = data?.topTools ?? [];
  const announcements: AnnouncementDigestItem[] = data?.announcements ?? [];

  return (
    <>
      <Head>
        <title>OcuHub Admin Console</title>
      </Head>
      <div className="min-h-screen bg-slate-950 text-white">
        <header className="border-b border-white/5 bg-slate-900/60 backdrop-blur">
          <div className="max-w-7xl mx-auto flex flex-col gap-4 px-6 py-6 sm:flex-row sm:items-center sm:justify-between">
            <div>
              <p className="text-xs uppercase tracking-[0.5em] text-indigo-300">Admin Console</p>
              <h1 className="text-3xl font-semibold">OcuHub Intelligence Dashboard</h1>
              <p className="text-sm text-slate-400">Signed in as {admin.displayName ?? admin.email}</p>
            </div>
            <div className="flex items-center gap-3">
              <div className="rounded-full bg-emerald-500/20 px-4 py-2 text-sm text-emerald-200">Role: {admin.role}</div>
              <button
                onClick={handleLogout}
                className="rounded-xl bg-slate-800 px-4 py-2 text-sm font-medium text-white hover:bg-slate-700 border border-white/10"
              >
                Sign out
              </button>
            </div>
          </div>
        </header>

        <main className="max-w-7xl mx-auto px-4 py-10 space-y-8">
          <section className="bg-slate-900/60 border border-white/5 rounded-2xl p-6 shadow-2xl shadow-slate-900/40">
            <div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
              <div>
                <h2 className="text-xl font-semibold">Usage Overview</h2>
                <p className="text-sm text-slate-400">Real-time visibility into app activity and feedback trends.</p>
              </div>
              <div className="flex gap-2">
                {RANGE_OPTIONS.map((option) => (
                  <button
                    key={option}
                    onClick={() => setDays(option)}
                    className={`rounded-full px-4 py-2 text-sm font-medium border ${
                      days === option
                        ? 'bg-indigo-500 text-white border-indigo-400'
                        : 'bg-slate-800/60 text-slate-200 border-white/10 hover:border-indigo-500/40'
                    }`}
                  >
                    Last {option}d
                  </button>
                ))}
              </div>
            </div>

            {error && <p className="mt-4 rounded-xl border border-rose-400/30 bg-rose-950/40 px-4 py-3 text-sm text-rose-200">{error}</p>}

            <div className="mt-6 grid gap-4 md:grid-cols-2 lg:grid-cols-4">
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

          <section className="grid gap-6 lg:grid-cols-3">
            <div className="lg:col-span-2 rounded-2xl border border-white/5 bg-slate-900/60 p-6">
              <div className="flex items-center justify-between mb-4">
                <div>
                  <h3 className="text-lg font-semibold">Engagement Timeline</h3>
                  <p className="text-sm text-slate-400">Daily tool events for the selected window.</p>
                </div>
              </div>
              <div className="h-48 flex items-end gap-2 overflow-x-auto px-1">
                {loading && !data ? (
                  <p className="text-slate-500 text-sm">Loading timeline…</p>
                ) : timelineData.length === 0 ? (
                  <p className="text-slate-500 text-sm">No events yet.</p>
                ) : (
                  timelineData.map((point) => {
                    const height = maxTimelineValue ? Math.max((point.toolEvents / maxTimelineValue) * 100, 8) : 8;
                    return (
                      <div key={point.date} className="flex flex-col items-center gap-2">
                        <div className="text-[10px] text-slate-400">{new Date(point.date).toLocaleDateString(undefined, { month: 'short', day: 'numeric' })}</div>
                        <div className="w-6 rounded-full bg-gradient-to-t from-indigo-500 via-blue-500 to-sky-400" style={{ height: `${height}%` }} />
                        <div className="text-[10px] text-slate-300">{point.toolEvents}</div>
                      </div>
                    );
                  })
                )}
              </div>
            </div>
            <div className="rounded-2xl border border-white/5 bg-slate-900/60 p-6">
              <h3 className="text-lg font-semibold mb-2">Latest Admin Notes</h3>
              <p className="text-sm text-slate-400 mb-4">Announcement states synced to the mobile update banner.</p>
              <div className="space-y-3">
                {announcements.length === 0 ? (
                  <p className="text-slate-500 text-sm">No announcements yet.</p>
                ) : (
                  announcements.map((item) => (
                    <div key={item.id} className="rounded-xl border border-white/5 bg-slate-800/60 p-3">
                      <div className="flex items-center justify-between">
                        <p className="font-medium">{item.title}</p>
                        <span className={`text-xs px-2 py-0.5 rounded-full uppercase tracking-wide ${
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
                  ))
                )}
              </div>
            </div>
          </section>

          <section className="grid gap-6 lg:grid-cols-2">
            <div className="rounded-2xl border border-white/5 bg-slate-900/60 p-6">
              <div className="flex items-center justify-between mb-4">
                <div>
                  <h3 className="text-lg font-semibold">Top Tools</h3>
                  <p className="text-sm text-slate-400">Usage ranking across all users.</p>
                </div>
                <span className="text-xs text-slate-400">Sorted by opens</span>
              </div>
              <div className="overflow-x-auto">
                <table className="w-full text-sm">
                  <thead>
                    <tr className="text-left text-slate-400">
                      <th className="py-2">Tool</th>
                      <th className="py-2">Opens</th>
                      <th className="py-2">Sessions</th>
                      <th className="py-2">Users</th>
                    </tr>
                  </thead>
                  <tbody>
                    {topTools.length === 0 ? (
                      <tr>
                        <td colSpan={4} className="py-4 text-center text-slate-500">
                          No usage yet.
                        </td>
                      </tr>
                    ) : (
                      topTools.map((tool) => (
                        <tr key={tool.toolId} className="border-t border-white/5">
                          <td className="py-2">{tool.toolName}</td>
                          <td className="py-2">{formatNumber(tool.openEvents)}</td>
                          <td className="py-2">{formatNumber(tool.totalSessions)}</td>
                          <td className="py-2">{formatNumber(tool.uniqueUsers)}</td>
                        </tr>
                      ))
                    )}
                  </tbody>
                </table>
              </div>
            </div>

            <div className="rounded-2xl border border-white/5 bg-slate-900/60 p-6">
              <div className="mb-4">
                <h3 className="text-lg font-semibold">Location Hotspots</h3>
                <p className="text-sm text-slate-400">Aggregated session distribution.</p>
              </div>
              <div className="space-y-3 max-h-80 overflow-y-auto pr-1">
                {(data?.locationBreakdown ?? []).slice(0, 12).map((location) => (
                  <div key={`${location.country}-${location.city}`} className="flex items-center justify-between rounded-xl border border-white/5 bg-slate-800/50 px-4 py-3">
                    <div>
                      <p className="font-medium">{location.city}, {location.country}</p>
                      <p className="text-xs text-slate-400">Last session: {formatDateTime(location.lastSessionAt)}</p>
                    </div>
                    <div className="text-right">
                      <p className="text-sm font-semibold">{formatNumber(location.sessionCount)} sessions</p>
                      <p className="text-xs text-slate-400">{formatNumber(location.uniqueUsers)} unique users</p>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </section>

          <section className="grid gap-6 lg:grid-cols-2">
            <div className="rounded-2xl border border-white/5 bg-slate-900/60 p-6">
              <h3 className="text-lg font-semibold mb-4">Feedback Summary</h3>
              <div className="space-y-3">
                {(data?.feedbackSummary ?? []).map((item) => (
                  <div key={item.feedbackType} className="rounded-xl border border-white/5 bg-slate-800/60 px-4 py-3">
                    <div className="flex items-center justify-between">
                      <p className="font-medium capitalize">{item.feedbackType}</p>
                      <p className="text-sm text-slate-400">{formatNumber(item.feedbackCount)} entries</p>
                    </div>
                    <p className="text-xs text-slate-500">Last: {formatDateTime(item.lastFeedbackAt)}</p>
                    {item.avgRating && <p className="text-xs text-amber-300 mt-1">Avg rating: {item.avgRating.toFixed(1)}</p>}
                  </div>
                ))}
                {(data?.feedbackSummary ?? []).length === 0 && <p className="text-slate-500 text-sm">No feedback recorded yet.</p>}
              </div>
            </div>
            <div className="rounded-2xl border border-white/5 bg-slate-900/60 p-6">
              <h3 className="text-lg font-semibold mb-4">Recent Sessions</h3>
              <div className="overflow-x-auto">
                <table className="w-full text-sm">
                  <thead>
                    <tr className="text-left text-slate-400">
                      <th className="py-2">User</th>
                      <th className="py-2">Location</th>
                      <th className="py-2">Version</th>
                      <th className="py-2">Duration</th>
                    </tr>
                  </thead>
                  <tbody>
                    {(data?.recentSessions ?? []).slice(0, 10).map((session) => (
                      <tr key={session.id} className="border-t border-white/5">
                        <td className="py-2 text-xs">{session.userId}</td>
                        <td className="py-2 text-xs">
                          {[session.city, session.country].filter(Boolean).join(', ') || 'Unknown'}
                        </td>
                        <td className="py-2 text-xs">{session.appVersion ?? '—'}</td>
                        <td className="py-2 text-xs">{(session.durationSeconds / 60).toFixed(1)} min</td>
                      </tr>
                    ))}
                    {(data?.recentSessions ?? []).length === 0 && (
                      <tr>
                        <td colSpan={4} className="py-4 text-center text-slate-500">
                          No sessions logged yet.
                        </td>
                      </tr>
                    )}
                  </tbody>
                </table>
              </div>
            </div>
          </section>
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
