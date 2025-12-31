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
  importance?: string;
  kind?: string;
  display_sequence?: number;
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

export interface AdminUserRow {
  id: string;
  displayName: string | null;
  email: string | null;
  createdAt: string;
  lastSeenAt: string | null;
  country: string | null;
  city: string | null;
  // User insights from surveys
  profession?: string | null;
  specialty?: string | null;
  subspecialty?: string | null;
  hospital?: string | null;
  yearsExperience?: string | null;
  insights?: Record<string, any>;
}

export interface EnhancedUserRow extends AdminUserRow {
  isAnonymous: boolean;
  isRealDevice: boolean | null;
  deviceBrand: string | null;
  deviceModel: string | null;
  osPlatform: string | null;
  osVersion: string | null;
  sessionCount: number;
  lastSessionAt: string | null;
  toolsUsedCount: number;
  totalToolTimeSeconds: number;
  firstSessionAt: string | null;
  feedbackCount: number;
  insightsCount: number;
  announcementResponsesCount: number;
}

export interface UserSessionLog {
  id: string;
  startTime: string;
  endTime: string | null;
  durationSeconds: number;
  country: string | null;
  city: string | null;
  appVersion: string | null;
  osPlatform: string | null;
  deviceBrand: string | null;
  deviceModel: string | null;
  isDevice: boolean | null;
}

export interface UserToolLog {
  toolId: string;
  toolName: string;
  usageCount: number;
  totalTimeSeconds: number;
  lastUsedAt: string | null;
  events: {
    id: string;
    eventType: string;
    eventTimestamp: string;
    appSessionId: string;
    eventData: any;
  }[];
}

export interface UserAnnouncementResponse {
  id: string;
  announcementId: string;
  announcementTitle: string;
  announcementKind: string;
  questionId: string | null;
  questionText: string | null;
  optionValue: string | null;
  textValue: string | null;
  numericValue: number | null;
  createdAt: string;
}

export interface UserAnnouncementInteraction {
  id: string;
  announcementId: string;
  announcementTitle: string;
  announcementKind: string;
  status: string;
  impressionCount: number;
  firstSeenAt: string | null;
  lastSeenAt: string | null;
  dismissedAt: string | null;
  completedAt: string | null;
  deferredAt: string | null;
  deferCount: number;
  isPartiallyCompleted: boolean;
  questionsAnswered: number;
}

export interface UserInsights {
  profession?: string | null;
  specialty?: string | null;
  subspecialty?: string | null;
  degree?: string | null;
  hospital?: string | null;
  yearsExperience?: string | null;
  country?: string | null;
  city?: string | null;
  [key: string]: any;
}

export interface UserFeedback {
  id: string;
  type: 'bug' | 'feature' | 'general';
  toolId: string | null;
  toolName: string | null;
  message: string | null;
  rating: number | null;
  metadata: any;
  submittedAt: string;
}

export interface UserDetailResponse {
  user: EnhancedUserRow;
  sessions: UserSessionLog[];
  toolUsage: UserToolLog[];
  insights: UserInsights;
  announcementResponses: UserAnnouncementResponse[];
  surveyResponses: UserAnnouncementResponse[];
  announcementInteractions: UserAnnouncementInteraction[];
  feedbacks: UserFeedback[];
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

export type ClosedTestingStatus = 'pending' | 'invited' | 'activated' | 'waitlist' | 'declined';

export interface ClosedTestingSignup {
  id: string;
  fullName: string;
  email: string;
  country: string;
  platform: 'android' | 'ios';
  referralCode: string;
  status: ClosedTestingStatus;
  note: string | null;
  invitedBy: string | null;
  invitedAt: string | null;
  emailSentAt: string | null;
  createdAt: string;
}
