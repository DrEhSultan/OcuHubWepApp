import { useCallback, useEffect, useMemo, useState } from 'react';
import type { EnhancedUserRow, UserSessionLog, UserToolLog, UserDetailResponse } from '../types/admin';

const formatDuration = (seconds: number) => {
  if (seconds < 60) return `${seconds}s`;
  const mins = Math.round(seconds / 60);
  if (mins < 60) return `${mins}m`;
  const hours = mins / 60;
  return `${hours.toFixed(1)}h`;
};

const formatDate = (value: string | null) => (value ? new Date(value).toLocaleString() : '—');

const formatShortDate = (value: string | null) => {
  if (!value) return '—';
  const d = new Date(value);
  return d.toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' });
};

type SortField = 'createdAt' | 'sessionCount' | 'lastSessionAt' | 'toolsUsedCount' | 'totalToolTimeSeconds' | 'firstSessionAt';
type FilterAnonymous = 'all' | 'anonymous' | 'logged_in';
type FilterDevice = 'all' | 'real' | 'emulator';

interface EnhancedUsersPanelProps {
  onError?: (error: string) => void;
}

export function EnhancedUsersPanel({ onError }: EnhancedUsersPanelProps) {
  const [users, setUsers] = useState<EnhancedUserRow[]>([]);
  const [loading, setLoading] = useState(true);
  const [selectedUserId, setSelectedUserId] = useState<string | null>(null);
  const [userDetail, setUserDetail] = useState<UserDetailResponse | null>(null);
  const [detailLoading, setDetailLoading] = useState(false);
  const [showDetailModal, setShowDetailModal] = useState(false);

  // Filters
  const [filterAnonymous, setFilterAnonymous] = useState<FilterAnonymous>('all');
  const [filterDevice, setFilterDevice] = useState<FilterDevice>('all');
  const [sortBy, setSortBy] = useState<SortField>('createdAt');
  const [sortOrder, setSortOrder] = useState<'asc' | 'desc'>('desc');

  const fetchUsers = useCallback(async () => {
    setLoading(true);
    try {
      const params = new URLSearchParams();
      params.set('limit', '500');
      if (filterAnonymous === 'anonymous') params.set('anonymous', 'true');
      else if (filterAnonymous === 'logged_in') params.set('anonymous', 'false');
      if (filterDevice === 'real') params.set('device', 'real');
      else if (filterDevice === 'emulator') params.set('device', 'emulator');
      params.set('sortBy', sortBy);
      params.set('sortOrder', sortOrder);

      const res = await fetch(`/api/admin/users?${params.toString()}`);
      if (!res.ok) throw new Error('Failed to fetch users');
      const data = await res.json();
      setUsers(data.users || []);
    } catch (err: any) {
      onError?.(err.message || 'Failed to load users');
    } finally {
      setLoading(false);
    }
  }, [filterAnonymous, filterDevice, sortBy, sortOrder, onError]);

  useEffect(() => {
    fetchUsers();
  }, [fetchUsers]);

  const fetchUserDetail = useCallback(async (userId: string) => {
    setDetailLoading(true);
    setShowDetailModal(true);
    try {
      const res = await fetch(`/api/admin/users?userId=${encodeURIComponent(userId)}`);
      if (!res.ok) throw new Error('Failed to fetch user details');
      const data: UserDetailResponse = await res.json();
      setUserDetail(data);
    } catch (err: any) {
      onError?.(err.message || 'Failed to load user details');
    } finally {
      setDetailLoading(false);
    }
  }, [onError]);

  const handleViewDetails = (userId: string) => {
    setSelectedUserId(userId);
    fetchUserDetail(userId);
  };

  const closeModal = () => {
    setShowDetailModal(false);
    setUserDetail(null);
    setSelectedUserId(null);
  };

  // Stats
  const stats = useMemo(() => {
    const total = users.length;
    const anonymous = users.filter(u => u.isAnonymous).length;
    const loggedIn = total - anonymous;
    const realDevice = users.filter(u => u.isRealDevice === true).length;
    const emulator = users.filter(u => u.isRealDevice === false).length;
    const activeToday = users.filter(u => {
      if (!u.lastSessionAt) return false;
      const lastSession = new Date(u.lastSessionAt);
      const today = new Date();
      return lastSession.toDateString() === today.toDateString();
    }).length;
    return { total, anonymous, loggedIn, realDevice, emulator, activeToday };
  }, [users]);

  return (
    <div className="space-y-6">
      {/* Stats Cards */}
      <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-6 gap-3">
        <StatCard label="Total Users" value={stats.total.toString()} />
        <StatCard label="Logged In" value={stats.loggedIn.toString()} color="emerald" />
        <StatCard label="Anonymous" value={stats.anonymous.toString()} color="amber" />
        <StatCard label="Real Devices" value={stats.realDevice.toString()} color="blue" />
        <StatCard label="Emulators" value={stats.emulator.toString()} color="purple" />
        <StatCard label="Active Today" value={stats.activeToday.toString()} color="rose" />
      </div>

      {/* Filters */}
      <div className="flex flex-wrap items-center gap-3 p-4 rounded-2xl bg-white/5 border border-white/10">
        <div className="flex items-center gap-2">
          <span className="text-sm text-slate-300">User Type:</span>
          <select
            value={filterAnonymous}
            onChange={(e) => setFilterAnonymous(e.target.value as FilterAnonymous)}
            className="rounded-xl bg-white/5 border border-white/10 px-3 py-2 text-sm text-white focus:ring-2 focus:ring-indigo-500 outline-none"
          >
            <option value="all">All Users</option>
            <option value="logged_in">Logged In</option>
            <option value="anonymous">Anonymous</option>
          </select>
        </div>

        <div className="flex items-center gap-2">
          <span className="text-sm text-slate-300">Device:</span>
          <select
            value={filterDevice}
            onChange={(e) => setFilterDevice(e.target.value as FilterDevice)}
            className="rounded-xl bg-white/5 border border-white/10 px-3 py-2 text-sm text-white focus:ring-2 focus:ring-indigo-500 outline-none"
          >
            <option value="all">All Devices</option>
            <option value="real">Real Devices</option>
            <option value="emulator">Emulators</option>
          </select>
        </div>

        <div className="flex items-center gap-2">
          <span className="text-sm text-slate-300">Sort By:</span>
          <select
            value={sortBy}
            onChange={(e) => setSortBy(e.target.value as SortField)}
            className="rounded-xl bg-white/5 border border-white/10 px-3 py-2 text-sm text-white focus:ring-2 focus:ring-indigo-500 outline-none"
          >
            <option value="createdAt">Sign Up Date</option>
            <option value="firstSessionAt">First Session</option>
            <option value="lastSessionAt">Last Session</option>
            <option value="sessionCount">Session Count</option>
            <option value="toolsUsedCount">Tools Used</option>
            <option value="totalToolTimeSeconds">Total Tool Time</option>
          </select>
        </div>

        <button
          onClick={() => setSortOrder(sortOrder === 'asc' ? 'desc' : 'asc')}
          className="px-3 py-2 rounded-xl bg-white/10 border border-white/10 text-sm text-white hover:bg-white/20 transition"
        >
          {sortOrder === 'desc' ? '↓ Desc' : '↑ Asc'}
        </button>

        <span className="ml-auto text-sm text-slate-400">
          Showing {users.length} users
        </span>
      </div>

      {/* Users Table */}
      {loading ? (
        <div className="w-full h-72 rounded-3xl bg-white/5 border border-white/10 flex items-center justify-center text-slate-200">
          Loading users…
        </div>
      ) : (
        <div className="rounded-2xl border border-white/10 bg-white/5 overflow-hidden">
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead>
                <tr className="border-b border-white/10 bg-white/5">
                  <th className="text-left px-4 py-3 text-slate-300 font-medium">User</th>
                  <th className="text-left px-4 py-3 text-slate-300 font-medium">Type</th>
                  <th className="text-left px-4 py-3 text-slate-300 font-medium">Device</th>
                  <th className="text-left px-4 py-3 text-slate-300 font-medium">Location</th>
                  <th className="text-center px-4 py-3 text-slate-300 font-medium">Sessions</th>
                  <th className="text-left px-4 py-3 text-slate-300 font-medium">Last Session</th>
                  <th className="text-center px-4 py-3 text-slate-300 font-medium">Tools</th>
                  <th className="text-left px-4 py-3 text-slate-300 font-medium">Tool Time</th>
                  <th className="text-left px-4 py-3 text-slate-300 font-medium">First Used</th>
                  <th className="text-center px-4 py-3 text-slate-300 font-medium">Actions</th>
                </tr>
              </thead>
              <tbody>
                {users.map((user) => (
                  <tr key={user.id} className="border-b border-white/5 hover:bg-white/5 transition">
                    <td className="px-4 py-3">
                      <div>
                        <p className="font-medium text-white">{user.displayName || 'Unnamed'}</p>
                        <p className="text-xs text-slate-400">{user.email || user.id.slice(0, 12) + '...'}</p>
                      </div>
                    </td>
                    <td className="px-4 py-3">
                      <span className={`px-2 py-1 rounded-full text-xs font-medium ${
                        user.isAnonymous 
                          ? 'bg-amber-500/20 text-amber-300 border border-amber-500/30' 
                          : 'bg-emerald-500/20 text-emerald-300 border border-emerald-500/30'
                      }`}>
                        {user.isAnonymous ? 'Anonymous' : 'Logged In'}
                      </span>
                    </td>
                    <td className="px-4 py-3">
                      <div className="flex flex-col">
                        <span className={`px-2 py-1 rounded-full text-xs font-medium w-fit ${
                          user.isRealDevice === true
                            ? 'bg-blue-500/20 text-blue-300 border border-blue-500/30'
                            : user.isRealDevice === false
                            ? 'bg-purple-500/20 text-purple-300 border border-purple-500/30'
                            : 'bg-slate-500/20 text-slate-300 border border-slate-500/30'
                        }`}>
                          {user.isRealDevice === true ? 'Real' : user.isRealDevice === false ? 'Emulator' : 'Unknown'}
                        </span>
                        {user.deviceBrand && (
                          <span className="text-xs text-slate-400 mt-1">{user.deviceBrand} {user.deviceModel}</span>
                        )}
                      </div>
                    </td>
                    <td className="px-4 py-3">
                      <span className="text-slate-200">{user.country || '—'}</span>
                      {user.city && <span className="text-slate-400">, {user.city}</span>}
                    </td>
                    <td className="px-4 py-3 text-center">
                      <span className="text-lg font-semibold text-white">{user.sessionCount}</span>
                    </td>
                    <td className="px-4 py-3">
                      <span className="text-slate-200">{formatShortDate(user.lastSessionAt)}</span>
                    </td>
                    <td className="px-4 py-3 text-center">
                      <span className="text-lg font-semibold text-white">{user.toolsUsedCount}</span>
                    </td>
                    <td className="px-4 py-3">
                      <span className="text-slate-200">{formatDuration(user.totalToolTimeSeconds)}</span>
                    </td>
                    <td className="px-4 py-3">
                      <span className="text-slate-200">{formatShortDate(user.firstSessionAt)}</span>
                    </td>
                    <td className="px-4 py-3 text-center">
                      <button
                        onClick={() => handleViewDetails(user.id)}
                        className="px-3 py-1.5 rounded-lg bg-indigo-500/20 text-indigo-300 border border-indigo-500/30 text-xs font-medium hover:bg-indigo-500/30 transition"
                      >
                        View Details
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {/* User Detail Modal */}
      {showDetailModal && (
        <UserDetailModal
          userDetail={userDetail}
          loading={detailLoading}
          onClose={closeModal}
        />
      )}
    </div>
  );
}

function StatCard({ label, value, color = 'indigo' }: { label: string; value: string; color?: string }) {
  const colorClasses: Record<string, string> = {
    indigo: 'text-indigo-100',
    emerald: 'text-emerald-100',
    amber: 'text-amber-100',
    blue: 'text-blue-100',
    purple: 'text-purple-100',
    rose: 'text-rose-100',
  };
  return (
    <div className="rounded-xl bg-white/5 border border-white/10 p-3">
      <p className={`text-xs uppercase tracking-wider ${colorClasses[color] || 'text-slate-300'}`}>{label}</p>
      <p className="text-2xl font-bold text-white">{value}</p>
    </div>
  );
}


function UserDetailModal({
  userDetail,
  loading,
  onClose,
}: {
  userDetail: UserDetailResponse | null;
  loading: boolean;
  onClose: () => void;
}) {
  const [activeTab, setActiveTab] = useState<'sessions' | 'tools'>('sessions');

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/60 backdrop-blur-sm">
      <div className="w-full max-w-5xl max-h-[90vh] rounded-3xl bg-slate-900 border border-white/10 shadow-2xl overflow-hidden flex flex-col">
        {/* Header */}
        <div className="flex items-center justify-between p-6 border-b border-white/10 bg-white/5">
          <div>
            <p className="text-sm text-indigo-200 uppercase tracking-wider">User Details</p>
            {userDetail && (
              <h2 className="text-2xl font-bold text-white">
                {userDetail.user.displayName || 'Unnamed User'}
              </h2>
            )}
          </div>
          <button
            onClick={onClose}
            className="p-2 rounded-xl bg-white/10 hover:bg-white/20 transition text-white"
          >
            <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>

        {loading ? (
          <div className="flex-1 flex items-center justify-center p-12">
            <div className="text-slate-300">Loading user details…</div>
          </div>
        ) : userDetail ? (
          <>
            {/* User Info Summary */}
            <div className="p-6 border-b border-white/10 bg-white/5">
              <div className="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-6 gap-4">
                <InfoCard label="Email" value={userDetail.user.email || '—'} />
                <InfoCard label="User Type" value={userDetail.user.isAnonymous ? 'Anonymous' : 'Logged In'} />
                <InfoCard label="Device" value={userDetail.user.isRealDevice === true ? 'Real Device' : userDetail.user.isRealDevice === false ? 'Emulator' : 'Unknown'} />
                <InfoCard label="Platform" value={userDetail.user.osPlatform || '—'} />
                <InfoCard label="Total Sessions" value={userDetail.user.sessionCount.toString()} />
                <InfoCard label="Tools Used" value={userDetail.user.toolsUsedCount.toString()} />
                <InfoCard label="Total Tool Time" value={formatDuration(userDetail.user.totalToolTimeSeconds)} />
                <InfoCard label="Location" value={`${userDetail.user.country || '—'}${userDetail.user.city ? ', ' + userDetail.user.city : ''}`} />
                <InfoCard label="First Session" value={formatShortDate(userDetail.user.firstSessionAt)} />
                <InfoCard label="Last Session" value={formatShortDate(userDetail.user.lastSessionAt)} />
                <InfoCard label="Device Brand" value={userDetail.user.deviceBrand || '—'} />
                <InfoCard label="Device Model" value={userDetail.user.deviceModel || '—'} />
              </div>
            </div>

            {/* Tabs */}
            <div className="flex gap-2 px-6 pt-4">
              <button
                onClick={() => setActiveTab('sessions')}
                className={`px-4 py-2 rounded-xl text-sm font-medium transition ${
                  activeTab === 'sessions'
                    ? 'bg-indigo-500 text-white'
                    : 'bg-white/10 text-slate-300 hover:bg-white/20'
                }`}
              >
                Sessions ({userDetail.sessions.length})
              </button>
              <button
                onClick={() => setActiveTab('tools')}
                className={`px-4 py-2 rounded-xl text-sm font-medium transition ${
                  activeTab === 'tools'
                    ? 'bg-indigo-500 text-white'
                    : 'bg-white/10 text-slate-300 hover:bg-white/20'
                }`}
              >
                Tool Usage ({userDetail.toolUsage.length})
              </button>
            </div>

            {/* Tab Content */}
            <div className="flex-1 overflow-y-auto p-6">
              {activeTab === 'sessions' ? (
                <SessionsTab sessions={userDetail.sessions} />
              ) : (
                <ToolsTab toolUsage={userDetail.toolUsage} />
              )}
            </div>
          </>
        ) : (
          <div className="flex-1 flex items-center justify-center p-12">
            <div className="text-slate-300">No user data available</div>
          </div>
        )}
      </div>
    </div>
  );
}

function InfoCard({ label, value }: { label: string; value: string }) {
  return (
    <div className="rounded-xl bg-white/5 border border-white/10 p-3">
      <p className="text-xs text-slate-400 uppercase tracking-wider">{label}</p>
      <p className="text-sm font-medium text-white truncate" title={value}>{value}</p>
    </div>
  );
}

function SessionsTab({ sessions }: { sessions: UserSessionLog[] }) {
  if (sessions.length === 0) {
    return <div className="text-slate-400 text-center py-8">No sessions recorded</div>;
  }

  return (
    <div className="space-y-3">
      <p className="text-sm text-slate-400 mb-4">All app sessions for this user, sorted by most recent first</p>
      <div className="rounded-xl border border-white/10 overflow-hidden">
        <table className="w-full text-sm">
          <thead>
            <tr className="bg-white/5 border-b border-white/10">
              <th className="text-left px-4 py-3 text-slate-300 font-medium">Start Time</th>
              <th className="text-left px-4 py-3 text-slate-300 font-medium">End Time</th>
              <th className="text-left px-4 py-3 text-slate-300 font-medium">Duration</th>
              <th className="text-left px-4 py-3 text-slate-300 font-medium">Location</th>
              <th className="text-left px-4 py-3 text-slate-300 font-medium">Device</th>
              <th className="text-left px-4 py-3 text-slate-300 font-medium">App Version</th>
            </tr>
          </thead>
          <tbody>
            {sessions.map((session) => (
              <tr key={session.id} className="border-b border-white/5 hover:bg-white/5">
                <td className="px-4 py-3 text-white">{formatDate(session.startTime)}</td>
                <td className="px-4 py-3 text-slate-300">{session.endTime ? formatDate(session.endTime) : 'Active'}</td>
                <td className="px-4 py-3 text-slate-300">{formatDuration(session.durationSeconds)}</td>
                <td className="px-4 py-3 text-slate-300">
                  {session.country || '—'}{session.city ? `, ${session.city}` : ''}
                </td>
                <td className="px-4 py-3">
                  <div className="flex flex-col">
                    <span className={`px-2 py-0.5 rounded text-xs w-fit ${
                      session.isDevice === true
                        ? 'bg-blue-500/20 text-blue-300'
                        : session.isDevice === false
                        ? 'bg-purple-500/20 text-purple-300'
                        : 'bg-slate-500/20 text-slate-300'
                    }`}>
                      {session.isDevice === true ? 'Real' : session.isDevice === false ? 'Emulator' : '?'}
                    </span>
                    {session.deviceBrand && (
                      <span className="text-xs text-slate-500 mt-1">{session.deviceBrand} {session.deviceModel}</span>
                    )}
                  </div>
                </td>
                <td className="px-4 py-3 text-slate-400">{session.appVersion || '—'}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}

function ToolsTab({ toolUsage }: { toolUsage: UserToolLog[] }) {
  const [expandedTool, setExpandedTool] = useState<string | null>(null);

  if (toolUsage.length === 0) {
    return <div className="text-slate-400 text-center py-8">No tool usage recorded</div>;
  }

  return (
    <div className="space-y-3">
      <p className="text-sm text-slate-400 mb-4">All tools used by this user with event logs</p>
      {toolUsage.map((tool) => (
        <div key={tool.toolId} className="rounded-xl border border-white/10 bg-white/5 overflow-hidden">
          <button
            onClick={() => setExpandedTool(expandedTool === tool.toolId ? null : tool.toolId)}
            className="w-full flex items-center justify-between p-4 hover:bg-white/5 transition"
          >
            <div className="flex items-center gap-4">
              <div className="h-10 w-10 rounded-xl bg-indigo-500/20 border border-indigo-500/30 flex items-center justify-center">
                <span className="text-indigo-300 font-bold">{tool.toolName.slice(0, 2).toUpperCase()}</span>
              </div>
              <div className="text-left">
                <p className="font-semibold text-white">{tool.toolName}</p>
                <p className="text-xs text-slate-400">{tool.toolId}</p>
              </div>
            </div>
            <div className="flex items-center gap-6">
              <div className="text-right">
                <p className="text-lg font-bold text-white">{tool.usageCount}</p>
                <p className="text-xs text-slate-400">uses</p>
              </div>
              <div className="text-right">
                <p className="text-lg font-bold text-white">{formatDuration(tool.totalTimeSeconds)}</p>
                <p className="text-xs text-slate-400">total time</p>
              </div>
              <div className="text-right">
                <p className="text-sm text-slate-300">{formatShortDate(tool.lastUsedAt)}</p>
                <p className="text-xs text-slate-400">last used</p>
              </div>
              <svg
                className={`w-5 h-5 text-slate-400 transition-transform ${expandedTool === tool.toolId ? 'rotate-180' : ''}`}
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
              </svg>
            </div>
          </button>

          {expandedTool === tool.toolId && (
            <div className="border-t border-white/10 p-4 bg-black/20">
              <p className="text-xs text-slate-400 mb-3 uppercase tracking-wider">Event Log (Last 50)</p>
              {tool.events.length === 0 ? (
                <p className="text-slate-500 text-sm">No events recorded</p>
              ) : (
                <div className="max-h-64 overflow-y-auto rounded-lg border border-white/10">
                  <table className="w-full text-xs">
                    <thead>
                      <tr className="bg-white/5 border-b border-white/10 sticky top-0">
                        <th className="text-left px-3 py-2 text-slate-400">Timestamp</th>
                        <th className="text-left px-3 py-2 text-slate-400">Event Type</th>
                        <th className="text-left px-3 py-2 text-slate-400">Session ID</th>
                        <th className="text-left px-3 py-2 text-slate-400">Data</th>
                      </tr>
                    </thead>
                    <tbody>
                      {tool.events.map((event) => (
                        <tr key={event.id} className="border-b border-white/5 hover:bg-white/5">
                          <td className="px-3 py-2 text-slate-300">{formatDate(event.eventTimestamp)}</td>
                          <td className="px-3 py-2">
                            <span className={`px-2 py-0.5 rounded text-xs ${
                              event.eventType === 'open' ? 'bg-emerald-500/20 text-emerald-300' :
                              event.eventType === 'close' ? 'bg-rose-500/20 text-rose-300' :
                              event.eventType === 'calculate' ? 'bg-blue-500/20 text-blue-300' :
                              event.eventType === 'save' ? 'bg-amber-500/20 text-amber-300' :
                              event.eventType === 'error' ? 'bg-red-500/20 text-red-300' :
                              'bg-slate-500/20 text-slate-300'
                            }`}>
                              {event.eventType}
                            </span>
                          </td>
                          <td className="px-3 py-2 text-slate-500 font-mono">{event.appSessionId?.slice(0, 8) || '—'}</td>
                          <td className="px-3 py-2 text-slate-500">
                            {event.eventData ? (
                              <details className="cursor-pointer">
                                <summary className="text-indigo-300 hover:text-indigo-200">View data</summary>
                                <pre className="mt-1 text-xs text-slate-400 whitespace-pre-wrap max-w-xs">
                                  {JSON.stringify(event.eventData, null, 2)}
                                </pre>
                              </details>
                            ) : '—'}
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              )}
            </div>
          )}
        </div>
      ))}
    </div>
  );
}

export default EnhancedUsersPanel;
