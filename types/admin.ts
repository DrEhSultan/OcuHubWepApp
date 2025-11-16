export type AdminRole = 'viewer' | 'analyst' | 'owner';

export interface AdminSession {
  id: string;
  email: string;
  role: AdminRole;
  displayName?: string | null;
}

export interface DashboardOverview {
  totalUsers: number;
  activeUsers: number;
  sessionCount: number;
  avgSessionDurationSeconds: number;
  toolEventCount: number;
  feedbackCount: number;
  countryCount: number;
  lastActivity: string | null;
}

export interface UsageTimelinePoint {
  date: string;
  activeUsers: number;
  sessionCount: number;
  toolEvents: number;
}

export interface ToolUsageRow {
  toolId: string;
  toolName: string;
  totalEvents: number;
  openEvents: number;
  closeEvents: number;
  calculateEvents: number;
  saveEvents: number;
  errorEvents: number;
  totalSessions: number;
  uniqueUsers: number;
  totalDurationSeconds: number;
  lastUsedAt: string | null;
}

export interface LocationBreakdownRow {
  country: string;
  city: string;
  sessionCount: number;
  uniqueUsers: number;
  lastSessionAt: string | null;
}

export interface FeedbackSummaryRow {
  feedbackType: string;
  feedbackCount: number;
  avgRating: number | null;
  lastFeedbackAt: string | null;
}

export interface RecentSessionRow {
  id: string;
  userId: string;
  country: string | null;
  city: string | null;
  region: string | null;
  appVersion: string | null;
  startTime: string;
  endTime: string | null;
  durationSeconds: number;
}

export interface AnnouncementDigestItem {
  id: string;
  title: string;
  severity: string;
  status: string;
  publishedAt: string | null;
  expiresAt: string | null;
}

export interface DashboardResponse {
  overview: DashboardOverview | null;
  timeline: UsageTimelinePoint[];
  topTools: ToolUsageRow[];
  locationBreakdown: LocationBreakdownRow[];
  feedbackSummary: FeedbackSummaryRow[];
  recentSessions: RecentSessionRow[];
  announcements: AnnouncementDigestItem[];
}

export interface ToolLeaderboardRow {
  toolId: string;
  toolName: string;
  events: number;
  uniqueUsers: number;
  uniqueSessions: number;
  countries: number;
  lastEventAt: string | null;
}

export interface ToolLeaderboardResponse {
  tools: ToolLeaderboardRow[];
}

export interface ToolCountrySeries {
  country: string;
  points: { date: string; events: number }[];
}

export interface ToolDrilldownResponse {
  summary: ToolLeaderboardRow;
  topCountries: Array<{
    country: string;
    events: number;
    uniqueUsers: number;
    uniqueSessions: number;
    lastEventAt: string | null;
  }>;
  topCities: Array<{
    country: string;
    city: string;
    events: number;
    uniqueUsers: number;
    uniqueSessions: number;
    lastEventAt: string | null;
  }>;
  daily: Array<{
    date: string;
    events: number;
    uniqueUsers: number;
    uniqueSessions: number;
  }>;
  countrySeries: ToolCountrySeries[];
}
