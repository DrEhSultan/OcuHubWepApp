import { useCallback, useEffect, useMemo, useState } from 'react';
import type { EnhancedUserRow, UserSessionLog, UserToolLog, UserDetailResponse, UserAnnouncementResponse, UserAnnouncementInteraction, UserInsights, UserFeedback, UserDeviceProfile } from '../types/admin';

const formatDuration = (seconds: number) => {
  if (seconds < 60) return `${seconds}s`;
  const mins = Math.floor(seconds / 60);
  const secs = seconds % 60;
  if (mins < 60) {
    return secs > 0 ? `${mins}m ${secs}s` : `${mins}m`;
  }
  const hours = Math.floor(mins / 60);
  const remainingMins = mins % 60;
  return remainingMins > 0 ? `${hours}h ${remainingMins}m` : `${hours}h`;
};

const formatDate = (value: string | null) => (value ? new Date(value).toLocaleString() : '—');

const formatShortDate = (value: string | null) => {
  if (!value) return '—';
  const d = new Date(value);
  return d.toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' });
};

const formatRelativeTime = (value: string | null) => {
  if (!value) return '—';
  const now = new Date();
  const date = new Date(value);
  const diffMs = now.getTime() - date.getTime();
  const diffSeconds = Math.floor(diffMs / 1000);
  const diffMinutes = Math.floor(diffSeconds / 60);
  const diffHours = Math.floor(diffMinutes / 60);
  const diffDays = Math.floor(diffHours / 24);
  const diffMonths = Math.floor(diffDays / 30);
  const diffYears = Math.floor(diffDays / 365);

  if (diffYears > 0) {
    return `${diffYears} ${diffYears === 1 ? 'year' : 'years'} ago`;
  } else if (diffMonths > 0) {
    return `${diffMonths} ${diffMonths === 1 ? 'month' : 'months'} ago`;
  } else if (diffDays > 0) {
    return `${diffDays} ${diffDays === 1 ? 'day' : 'days'} ago`;
  } else if (diffHours > 0) {
    return `${diffHours} ${diffHours === 1 ? 'hour' : 'hours'} ago`;
  } else if (diffMinutes > 0) {
    return `${diffMinutes} ${diffMinutes === 1 ? 'minute' : 'minutes'} ago`;
  } else {
    return 'Just now';
  }
};

type SortField = 'createdAt' | 'sessionCount' | 'lastSessionAt' | 'toolsUsedCount' | 'totalToolTimeSeconds' | 'firstSessionAt';
type FilterAnonymous = 'all' | 'anonymous' | 'logged_in';
type FilterDevice = 'all' | 'real' | 'emulator' | 'other';

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
  const [filterDevice, setFilterDevice] = useState<FilterDevice>('other');
  const [sortBy, setSortBy] = useState<SortField>('lastSessionAt');
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
      else if (filterDevice === 'other') params.set('device', 'other');
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
    setUserDetail(null); // Reset previous data first
    setDetailLoading(true);
    try {
      console.log('[EnhancedUsersPanel] Fetching user detail for:', userId);
      const res = await fetch(`/api/admin/users?userId=${encodeURIComponent(userId)}`);
      console.log('[EnhancedUsersPanel] Response status:', res.status);
      
      if (!res.ok) {
        const errorData = await res.json().catch(() => ({}));
        console.error('[EnhancedUsersPanel] API error:', errorData);
        throw new Error(errorData.error || 'Failed to fetch user details');
      }
      
      const data: UserDetailResponse = await res.json();
      console.log('[EnhancedUsersPanel] User detail data:', data);
      setUserDetail(data);
      setShowDetailModal(true); // Open modal AFTER data is loaded
    } catch (err: any) {
      console.error('[EnhancedUsersPanel] Fetch error:', err);
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
            <option value="other">Other Devices</option>
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
                  <th className="text-left px-4 py-3 text-slate-300 font-medium">Device</th>
                  <th className="text-center px-4 py-3 text-slate-300 font-medium">Sessions</th>
                  <th className="text-left px-4 py-3 text-slate-300 font-medium">Last Session</th>
                  <th className="text-left px-4 py-3 text-slate-300 font-medium">First Session</th>
                  <th className="text-center px-4 py-3 text-slate-300 font-medium">Tools</th>
                  <th className="text-left px-4 py-3 text-slate-300 font-medium">Tool Time</th>
                  <th className="text-center px-4 py-3 text-slate-300 font-medium">Feedback</th>
                  <th className="text-center px-4 py-3 text-slate-300 font-medium">Insights</th>
                  <th className="text-center px-4 py-3 text-slate-300 font-medium" title="Announcements + Surveys + Interactions">Responses</th>
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
                        <div className="flex items-center gap-2 mt-1">
                          <span className={`px-2 py-0.5 rounded-full text-xs font-medium ${
                            user.isAnonymous 
                              ? 'bg-amber-500/20 text-amber-300 border border-amber-500/30' 
                              : 'bg-emerald-500/20 text-emerald-300 border border-emerald-500/30'
                          }`}>
                            {user.isAnonymous ? 'Anonymous' : 'Logged In'}
                          </span>
                          <span className="text-xs text-slate-400">
                            {user.country || '—'}{user.city ? `, ${user.city}` : ''}
                          </span>
                        </div>
                      </div>
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
                    <td className="px-4 py-3 text-center">
                      <span className="text-lg font-semibold text-white">{user.sessionCount}</span>
                    </td>
                    <td className="px-4 py-3">
                      <span className="text-slate-200">{formatRelativeTime(user.lastSessionAt)}</span>
                    </td>
                    <td className="px-4 py-3">
                      <span className="text-slate-200">{formatRelativeTime(user.firstSessionAt)}</span>
                    </td>
                    <td className="px-4 py-3 text-center">
                      <span className="text-lg font-semibold text-white">{user.toolsUsedCount}</span>
                    </td>
                    <td className="px-4 py-3">
                      <span className="text-slate-200">{formatDuration(user.totalToolTimeSeconds)}</span>
                    </td>
                    <td className="px-4 py-3 text-center">
                      <span className={`text-lg font-semibold ${user.feedbackCount > 0 ? 'text-rose-300' : 'text-slate-500'}`}>
                        {user.feedbackCount}
                      </span>
                    </td>
                    <td className="px-4 py-3 text-center">
                      <span className={`text-lg font-semibold ${user.insightsCount > 0 ? 'text-emerald-300' : 'text-slate-500'}`}>
                        {user.insightsCount}
                      </span>
                    </td>
                    <td className="px-4 py-3 text-center" title="Total responses (Announcements + Surveys + Interactions)">
                      <span className={`text-lg font-semibold ${user.announcementResponsesCount > 0 ? 'text-amber-300' : 'text-slate-500'}`}>
                        {user.announcementResponsesCount}
                      </span>
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
  const [activeTab, setActiveTab] = useState<'sessions' | 'tools' | 'insights' | 'announcements' | 'surveys' | 'interactions' | 'feedback' | 'devices'>('sessions');

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
                <InfoCard label="Total Responses" value={`${(userDetail.announcementResponses?.length || 0) + (userDetail.surveyResponses?.length || 0) + (userDetail.announcementInteractions?.length || 0)}`} />
                <InfoCard label="Device Profiles" value={`${userDetail.deviceProfiles?.length || 0}`} />
              </div>
            </div>

            {/* Tabs */}
            <div className="flex gap-2 px-6 pt-4 flex-wrap">
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
              <button
                onClick={() => setActiveTab('insights')}
                className={`px-4 py-2 rounded-xl text-sm font-medium transition ${
                  activeTab === 'insights'
                    ? 'bg-emerald-500 text-white'
                    : 'bg-white/10 text-slate-300 hover:bg-white/20'
                }`}
              >
                User Insights
              </button>
              <button
                onClick={() => setActiveTab('announcements')}
                className={`px-4 py-2 rounded-xl text-sm font-medium transition ${
                  activeTab === 'announcements'
                    ? 'bg-amber-500 text-white'
                    : 'bg-white/10 text-slate-300 hover:bg-white/20'
                }`}
              >
                Announcements ({userDetail.announcementResponses?.length || 0})
              </button>
              <button
                onClick={() => setActiveTab('surveys')}
                className={`px-4 py-2 rounded-xl text-sm font-medium transition ${
                  activeTab === 'surveys'
                    ? 'bg-purple-500 text-white'
                    : 'bg-white/10 text-slate-300 hover:bg-white/20'
                }`}
              >
                Surveys ({userDetail.surveyResponses?.length || 0})
              </button>
              <button
                onClick={() => setActiveTab('interactions')}
                className={`px-4 py-2 rounded-xl text-sm font-medium transition ${
                  activeTab === 'interactions'
                    ? 'bg-cyan-500 text-white'
                    : 'bg-white/10 text-slate-300 hover:bg-white/20'
                }`}
              >
                Interactions ({userDetail.announcementInteractions?.length || 0})
              </button>
              <button
                onClick={() => setActiveTab('feedback')}
                className={`px-4 py-2 rounded-xl text-sm font-medium transition ${
                  activeTab === 'feedback'
                    ? 'bg-rose-500 text-white'
                    : 'bg-white/10 text-slate-300 hover:bg-white/20'
                }`}
              >
                Feedback ({userDetail.feedbacks?.length || 0})
              </button>
              <button
                onClick={() => setActiveTab('devices')}
                className={`px-4 py-2 rounded-xl text-sm font-medium transition ${
                  activeTab === 'devices'
                    ? 'bg-teal-500 text-white'
                    : 'bg-white/10 text-slate-300 hover:bg-white/20'
                }`}
              >
                Devices ({userDetail.deviceProfiles?.length || 0})
              </button>
            </div>

            {/* Tab Content */}
            <div className="flex-1 overflow-y-auto p-6">
              {activeTab === 'sessions' ? (
                <SessionsTab sessions={userDetail.sessions} />
              ) : activeTab === 'tools' ? (
                <ToolsTab toolUsage={userDetail.toolUsage} />
              ) : activeTab === 'insights' ? (
                <InsightsTab insights={userDetail.insights} user={userDetail.user} />
              ) : activeTab === 'announcements' ? (
                <AnnouncementResponsesTab responses={userDetail.announcementResponses || []} />
              ) : activeTab === 'surveys' ? (
                <SurveyResponsesTab responses={userDetail.surveyResponses || []} />
              ) : activeTab === 'interactions' ? (
                <InteractionsTab interactions={userDetail.announcementInteractions || []} />
              ) : activeTab === 'feedback' ? (
                <FeedbackTab feedbacks={userDetail.feedbacks || []} />
              ) : (
                <DevicesTab deviceProfiles={userDetail.deviceProfiles || []} />
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
  const [sortBy, setSortBy] = useState<'lastUsed' | 'mostUsed'>('lastUsed');

  if (toolUsage.length === 0) {
    return <div className="text-slate-400 text-center py-8">No tool usage recorded</div>;
  }

  // Sort tools based on selected option
  const sortedTools = [...toolUsage].sort((a, b) => {
    if (sortBy === 'lastUsed') {
      // Sort by last used date (most recent first)
      if (!a.lastUsedAt && !b.lastUsedAt) return 0;
      if (!a.lastUsedAt) return 1;
      if (!b.lastUsedAt) return -1;
      return new Date(b.lastUsedAt).getTime() - new Date(a.lastUsedAt).getTime();
    } else {
      // Sort by usage count (most used first)
      return b.usageCount - a.usageCount;
    }
  });

  return (
    <div className="space-y-3">
      <div className="flex items-center justify-between mb-4">
        <p className="text-sm text-slate-400">All tools used by this user with event logs</p>
        <div className="flex items-center gap-2">
          <span className="text-xs text-slate-400">Sort by:</span>
          <select
            value={sortBy}
            onChange={(e) => setSortBy(e.target.value as 'lastUsed' | 'mostUsed')}
            className="rounded-lg bg-white/5 border border-white/10 px-3 py-1 text-xs text-white focus:ring-2 focus:ring-indigo-500 outline-none"
          >
            <option value="lastUsed">Last Used First</option>
            <option value="mostUsed">Most Used First</option>
          </select>
        </div>
      </div>
      {sortedTools.map((tool) => (
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

function InsightsTab({ insights, user }: { insights: UserInsights; user: EnhancedUserRow }) {
  // Combine user profile data with insights
  const allInsights = {
    profession: user.profession || insights?.profession,
    specialty: user.specialty || insights?.specialty,
    subspecialty: user.subspecialty || insights?.subspecialty,
    hospital: user.hospital || insights?.hospital,
    yearsExperience: user.yearsExperience || insights?.yearsExperience || insights?.years_experience,
    degree: insights?.degree,
    country: insights?.country,
    city: insights?.city,
    ...insights,
  };

  // Filter out null/undefined values and internal fields
  const displayInsights = Object.entries(allInsights).filter(
    ([key, value]) => value !== null && value !== undefined && value !== '' && !key.startsWith('_')
  );

  if (displayInsights.length === 0) {
    return <div className="text-slate-400 text-center py-8">No user insights recorded</div>;
  }

  const formatKey = (key: string) => {
    return key
      .replace(/([A-Z])/g, ' $1')
      .replace(/_/g, ' ')
      .replace(/^\w/, c => c.toUpperCase())
      .trim();
  };

  return (
    <div className="space-y-3">
      <p className="text-sm text-slate-400 mb-4">User profile and insights data collected from surveys and profile</p>
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        {displayInsights.map(([key, value]) => (
          <div key={key} className="rounded-xl bg-white/5 border border-white/10 p-4">
            <p className="text-xs text-emerald-300 uppercase tracking-wider mb-1">{formatKey(key)}</p>
            <p className="text-white font-medium">
              {typeof value === 'object' ? JSON.stringify(value) : String(value)}
            </p>
          </div>
        ))}
      </div>
    </div>
  );
}

function AnnouncementResponsesTab({ responses }: { responses: UserAnnouncementResponse[] }) {
  if (responses.length === 0) {
    return <div className="text-slate-400 text-center py-8">No announcement responses recorded</div>;
  }

  // Group responses by announcement
  const groupedResponses = responses.reduce((acc, response) => {
    if (!acc[response.announcementId]) {
      acc[response.announcementId] = {
        title: response.announcementTitle,
        responses: [],
      };
    }
    acc[response.announcementId].responses.push(response);
    return acc;
  }, {} as Record<string, { title: string; responses: UserAnnouncementResponse[] }>);

  return (
    <div className="space-y-4">
      <p className="text-sm text-slate-400 mb-4">User responses to announcements</p>
      {Object.entries(groupedResponses).map(([announcementId, { title, responses: annResponses }]) => (
        <div key={announcementId} className="rounded-xl border border-white/10 bg-white/5 overflow-hidden">
          <div className="p-4 border-b border-white/10 bg-amber-500/10">
            <h3 className="font-semibold text-amber-200">{title}</h3>
            <p className="text-xs text-slate-400 mt-1">{annResponses.length} response(s)</p>
          </div>
          <div className="p-4">
            <div className="rounded-lg border border-white/10 overflow-hidden">
              <table className="w-full text-sm">
                <thead>
                  <tr className="bg-white/5 border-b border-white/10">
                    <th className="text-left px-4 py-2 text-slate-300 font-medium">Response</th>
                    <th className="text-left px-4 py-2 text-slate-300 font-medium">Date</th>
                  </tr>
                </thead>
                <tbody>
                  {annResponses.map((response) => (
                    <tr key={response.id} className="border-b border-white/5 hover:bg-white/5">
                      <td className="px-4 py-3 text-white">
                        {response.optionValue || response.textValue || (response.numericValue !== null ? response.numericValue : '—')}
                      </td>
                      <td className="px-4 py-3 text-slate-400">{formatDate(response.createdAt)}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        </div>
      ))}
    </div>
  );
}

function SurveyResponsesTab({ responses }: { responses: UserAnnouncementResponse[] }) {
  if (responses.length === 0) {
    return <div className="text-slate-400 text-center py-8">No survey responses recorded</div>;
  }

  // Group responses by survey
  const groupedResponses = responses.reduce((acc, response) => {
    if (!acc[response.announcementId]) {
      acc[response.announcementId] = {
        title: response.announcementTitle,
        responses: [],
      };
    }
    acc[response.announcementId].responses.push(response);
    return acc;
  }, {} as Record<string, { title: string; responses: UserAnnouncementResponse[] }>);

  return (
    <div className="space-y-4">
      <p className="text-sm text-slate-400 mb-4">User responses to surveys</p>
      {Object.entries(groupedResponses).map(([surveyId, { title, responses: surveyResponses }]) => (
        <div key={surveyId} className="rounded-xl border border-white/10 bg-white/5 overflow-hidden">
          <div className="p-4 border-b border-white/10 bg-purple-500/10">
            <h3 className="font-semibold text-purple-200">{title}</h3>
            <p className="text-xs text-slate-400 mt-1">{surveyResponses.length} answer(s)</p>
          </div>
          <div className="p-4">
            <div className="rounded-lg border border-white/10 overflow-hidden">
              <table className="w-full text-sm">
                <thead>
                  <tr className="bg-white/5 border-b border-white/10">
                    <th className="text-left px-4 py-2 text-slate-300 font-medium">Question</th>
                    <th className="text-left px-4 py-2 text-slate-300 font-medium">Answer</th>
                    <th className="text-left px-4 py-2 text-slate-300 font-medium">Date</th>
                  </tr>
                </thead>
                <tbody>
                  {surveyResponses.map((response) => (
                    <tr key={response.id} className="border-b border-white/5 hover:bg-white/5">
                      <td className="px-4 py-3 text-slate-300">{response.questionText || response.questionId || '—'}</td>
                      <td className="px-4 py-3 text-white">
                        {response.optionValue || response.textValue || (response.numericValue !== null ? response.numericValue : '—')}
                      </td>
                      <td className="px-4 py-3 text-slate-400">{formatDate(response.createdAt)}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        </div>
      ))}
    </div>
  );
}

function InteractionsTab({ interactions }: { interactions: UserAnnouncementInteraction[] }) {
  if (interactions.length === 0) {
    return <div className="text-slate-400 text-center py-8">No announcement interactions recorded</div>;
  }

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'completed':
        return 'bg-green-500/20 text-green-300 border-green-500/30';
      case 'dismissed':
        return 'bg-red-500/20 text-red-300 border-red-500/30';
      case 'deferred':
        return 'bg-yellow-500/20 text-yellow-300 border-yellow-500/30';
      case 'seen':
        return 'bg-blue-500/20 text-blue-300 border-blue-500/30';
      default:
        return 'bg-slate-500/20 text-slate-300 border-slate-500/30';
    }
  };

  const getKindColor = (kind: string) => {
    switch (kind) {
      case 'survey':
        return 'bg-purple-500/20 text-purple-300';
      case 'quiz':
        return 'bg-orange-500/20 text-orange-300';
      case 'user_insights':
        return 'bg-emerald-500/20 text-emerald-300';
      default:
        return 'bg-cyan-500/20 text-cyan-300';
    }
  };

  return (
    <div className="space-y-4">
      <p className="text-sm text-slate-400 mb-4">User interactions with announcements (seen, dismissed, completed, etc.)</p>
      <div className="rounded-lg border border-white/10 overflow-hidden">
        <table className="w-full text-sm">
          <thead>
            <tr className="bg-white/5 border-b border-white/10">
              <th className="text-left px-4 py-2 text-slate-300 font-medium">Announcement</th>
              <th className="text-left px-4 py-2 text-slate-300 font-medium">Type</th>
              <th className="text-left px-4 py-2 text-slate-300 font-medium">Status</th>
              <th className="text-center px-4 py-2 text-slate-300 font-medium">Views</th>
              <th className="text-left px-4 py-2 text-slate-300 font-medium">First Seen</th>
              <th className="text-left px-4 py-2 text-slate-300 font-medium">Last Seen</th>
              <th className="text-left px-4 py-2 text-slate-300 font-medium">Action Date</th>
            </tr>
          </thead>
          <tbody>
            {interactions.map((interaction) => (
              <tr key={interaction.id} className="border-b border-white/5 hover:bg-white/5">
                <td className="px-4 py-3 text-white font-medium">{interaction.announcementTitle}</td>
                <td className="px-4 py-3">
                  <span className={`px-2 py-1 rounded-full text-xs font-medium ${getKindColor(interaction.announcementKind)}`}>
                    {interaction.announcementKind}
                  </span>
                </td>
                <td className="px-4 py-3">
                  <span className={`px-2 py-1 rounded-full text-xs font-medium border ${getStatusColor(interaction.status)}`}>
                    {interaction.status}
                  </span>
                </td>
                <td className="px-4 py-3 text-center text-slate-300">{interaction.impressionCount}</td>
                <td className="px-4 py-3 text-slate-400">{formatDate(interaction.firstSeenAt)}</td>
                <td className="px-4 py-3 text-slate-400">{formatDate(interaction.lastSeenAt)}</td>
                <td className="px-4 py-3 text-slate-400">
                  {interaction.completedAt ? formatDate(interaction.completedAt) :
                   interaction.dismissedAt ? formatDate(interaction.dismissedAt) :
                   interaction.deferredAt ? formatDate(interaction.deferredAt) : '—'}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}

function FeedbackTab({ feedbacks }: { feedbacks: UserFeedback[] }) {
  if (feedbacks.length === 0) {
    return <div className="text-slate-400 text-center py-8">No feedback submitted</div>;
  }

  const getTypeColor = (type: string) => {
    switch (type) {
      case 'bug':
        return 'bg-red-500/20 text-red-300 border-red-500/30';
      case 'feature':
        return 'bg-blue-500/20 text-blue-300 border-blue-500/30';
      default:
        return 'bg-slate-500/20 text-slate-300 border-slate-500/30';
    }
  };

  const renderRating = (rating: number | null) => {
    if (rating === null) return '—';
    return (
      <div className="flex items-center gap-1">
        {[1, 2, 3, 4, 5].map((star) => (
          <svg
            key={star}
            className={`w-4 h-4 ${star <= rating ? 'text-amber-400' : 'text-slate-600'}`}
            fill="currentColor"
            viewBox="0 0 20 20"
          >
            <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z" />
          </svg>
        ))}
        <span className="ml-1 text-slate-400">({rating})</span>
      </div>
    );
  };

  return (
    <div className="space-y-4">
      <p className="text-sm text-slate-400 mb-4">User feedback submissions</p>
      <div className="space-y-3">
        {feedbacks.map((feedback) => (
          <div key={feedback.id} className="rounded-xl border border-white/10 bg-white/5 overflow-hidden">
            <div className="p-4 border-b border-white/10 bg-rose-500/10 flex items-center justify-between">
              <div className="flex items-center gap-3">
                <span className={`px-2 py-1 rounded-full text-xs font-medium border ${getTypeColor(feedback.type)}`}>
                  {feedback.type.charAt(0).toUpperCase() + feedback.type.slice(1)}
                </span>
                {feedback.toolName && (
                  <span className="text-sm text-slate-300">
                    Tool: <span className="text-white font-medium">{feedback.toolName}</span>
                  </span>
                )}
              </div>
              <span className="text-xs text-slate-400">{formatDate(feedback.submittedAt)}</span>
            </div>
            <div className="p-4 space-y-3">
              {feedback.rating !== null && (
                <div className="flex items-center gap-2">
                  <span className="text-sm text-slate-400">Rating:</span>
                  {renderRating(feedback.rating)}
                </div>
              )}
              {feedback.message && (
                <div>
                  <p className="text-sm text-slate-400 mb-1">Message:</p>
                  <p className="text-white bg-black/20 rounded-lg p-3 text-sm">{feedback.message}</p>
                </div>
              )}
              {feedback.metadata && Object.keys(feedback.metadata).length > 0 && (
                <details className="cursor-pointer">
                  <summary className="text-sm text-indigo-300 hover:text-indigo-200">View metadata</summary>
                  <pre className="mt-2 text-xs text-slate-400 bg-black/20 rounded-lg p-3 overflow-x-auto">
                    {JSON.stringify(feedback.metadata, null, 2)}
                  </pre>
                </details>
              )}
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

function DevicesTab({ deviceProfiles }: { deviceProfiles: UserDeviceProfile[] }) {
  if (deviceProfiles.length === 0) {
    return <div className="text-slate-400 text-center py-8">No device profiles registered</div>;
  }

  const getPlatformIcon = (platformType: string) => {
    switch (platformType) {
      case 'mobile':
        return '📱';
      case 'casted_mobile':
        return '📲';
      case 'tablet':
        return '📟';
      case 'tv':
        return '📺';
      case 'web':
        return '🌐';
      default:
        return '📱';
    }
  };

  const getPlatformColor = (platformType: string) => {
    switch (platformType) {
      case 'mobile':
        return 'bg-blue-500/20 text-blue-300 border-blue-500/30';
      case 'casted_mobile':
        return 'bg-purple-500/20 text-purple-300 border-purple-500/30';
      case 'tablet':
        return 'bg-indigo-500/20 text-indigo-300 border-indigo-500/30';
      case 'tv':
        return 'bg-orange-500/20 text-orange-300 border-orange-500/30';
      case 'web':
        return 'bg-emerald-500/20 text-emerald-300 border-emerald-500/30';
      default:
        return 'bg-slate-500/20 text-slate-300 border-slate-500/30';
    }
  };

  const formatPlatformType = (platformType: string) => {
    switch (platformType) {
      case 'mobile':
        return 'Mobile';
      case 'casted_mobile':
        return 'Casted Mobile';
      case 'tablet':
        return 'Tablet';
      case 'tv':
        return 'TV / TV Box';
      case 'web':
        return 'Web';
      default:
        return platformType;
    }
  };

  return (
    <div className="space-y-4">
      <p className="text-sm text-slate-400 mb-4">
        Registered devices for this user with sync preferences
      </p>
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        {deviceProfiles.map((device) => (
          <div key={device.id} className="rounded-xl border border-white/10 bg-white/5 overflow-hidden">
            <div className="p-4 border-b border-white/10 bg-teal-500/10 flex items-center justify-between">
              <div className="flex items-center gap-3">
                <span className="text-2xl">{getPlatformIcon(device.platformType)}</span>
                <div>
                  <h3 className="font-semibold text-white">{device.deviceName}</h3>
                  <span className={`px-2 py-0.5 rounded-full text-xs font-medium border ${getPlatformColor(device.platformType)}`}>
                    {formatPlatformType(device.platformType)}
                  </span>
                </div>
              </div>
              {device.appVersion && (
                <span className="text-xs text-slate-400 bg-white/10 px-2 py-1 rounded">
                  v{device.appVersion}
                </span>
              )}
            </div>
            <div className="p-4 space-y-3">
              <div className="grid grid-cols-2 gap-3 text-sm">
                <div>
                  <p className="text-xs text-slate-400 uppercase tracking-wider">First Registered</p>
                  <p className="text-white">{formatShortDate(device.createdAt)}</p>
                </div>
                <div>
                  <p className="text-xs text-slate-400 uppercase tracking-wider">Last Active</p>
                  <p className="text-white">{formatRelativeTime(device.lastActiveAt)}</p>
                </div>
              </div>
              
              {device.syncPreferences && (
                <div className="pt-3 border-t border-white/10">
                  <p className="text-xs text-slate-400 uppercase tracking-wider mb-2">Sync Preferences</p>
                  <div className="flex flex-wrap gap-2">
                    <SyncBadge label="Favorites" enabled={device.syncPreferences.shareFavorites} />
                    <SyncBadge label="Tool Usage" enabled={device.syncPreferences.shareToolUsage} />
                    <SyncBadge label="Preferences" enabled={device.syncPreferences.sharePreferences} />
                    <SyncBadge label="Sections" enabled={device.syncPreferences.shareSectionSettings} />
                  </div>
                </div>
              )}
              
              <div className="pt-2">
                <details className="cursor-pointer">
                  <summary className="text-xs text-indigo-300 hover:text-indigo-200">View device ID</summary>
                  <p className="mt-1 text-xs text-slate-500 font-mono break-all">{device.deviceId}</p>
                </details>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

function SyncBadge({ label, enabled }: { label: string; enabled: boolean }) {
  return (
    <span className={`px-2 py-1 rounded text-xs font-medium ${
      enabled 
        ? 'bg-emerald-500/20 text-emerald-300 border border-emerald-500/30' 
        : 'bg-slate-500/20 text-slate-400 border border-slate-500/30'
    }`}>
      {enabled ? '✓' : '✗'} {label}
    </span>
  );
}

export default EnhancedUsersPanel;
