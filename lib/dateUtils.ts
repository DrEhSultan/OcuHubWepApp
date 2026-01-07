// Centralized date formatting utilities for admin panel
// All dates are displayed in Riyadh timezone (UTC+3) with AM/PM format

const RIYADH_TIMEZONE = 'Asia/Riyadh'; // UTC+3

/**
 * Format a date string to full date and time in Riyadh timezone with AM/PM
 * Example: "1/7/2026, 4:19:16 PM"
 */
export const formatDate = (value: string | null): string => {
  if (!value) return '—';
  const date = new Date(value);
  
  // Get date parts in Riyadh timezone
  const datePart = date.toLocaleDateString('en-US', {
    timeZone: RIYADH_TIMEZONE,
    month: '2-digit',
    day: '2-digit',
    year: 'numeric',
  });
  
  // Get time parts in Riyadh timezone with AM/PM
  const timePart = date.toLocaleTimeString('en-US', {
    timeZone: RIYADH_TIMEZONE,
    hour: 'numeric',
    minute: '2-digit',
    second: '2-digit',
    hour12: true,
  });
  
  return `${datePart}, ${timePart}`;
};

/**
 * Format a date string to short date in Riyadh timezone
 * Example: "Jan 7, 2026"
 */
export const formatShortDate = (value: string | null): string => {
  if (!value) return '—';
  const date = new Date(value);
  return date.toLocaleDateString('en-US', {
    timeZone: RIYADH_TIMEZONE,
    month: 'short',
    day: 'numeric',
    year: 'numeric',
  });
};

/**
 * Format a date string to time only in Riyadh timezone with AM/PM
 * Example: "4:19:16 PM"
 */
export const formatTime = (value: string | null): string => {
  if (!value) return '—';
  const date = new Date(value);
  
  // Force AM/PM format
  const timePart = date.toLocaleTimeString('en-US', {
    timeZone: RIYADH_TIMEZONE,
    hour: 'numeric',
    minute: '2-digit',
    second: '2-digit',
    hour12: true,
  });
  
  return timePart;
};

/**
 * Format a date string to date and time without seconds in Riyadh timezone with AM/PM
 * Example: "1/7/2026, 4:19 PM"
 */
export const formatDateTime = (value: string | null): string => {
  if (!value) return '—';
  const date = new Date(value);
  
  // Get date parts in Riyadh timezone
  const datePart = date.toLocaleDateString('en-US', {
    timeZone: RIYADH_TIMEZONE,
    month: '2-digit',
    day: '2-digit',
    year: 'numeric',
  });
  
  // Get time parts in Riyadh timezone with AM/PM (no seconds)
  const timePart = date.toLocaleTimeString('en-US', {
    timeZone: RIYADH_TIMEZONE,
    hour: 'numeric',
    minute: '2-digit',
    hour12: true,
  });
  
  return `${datePart}, ${timePart}`;
};

/**
 * Format relative time (e.g., "2 hours ago", "3 days ago")
 * Calculated based on Riyadh timezone
 */
export const formatRelativeTime = (value: string | null): string => {
  if (!value) return '—';
  
  // Get current time in Riyadh timezone
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

/**
 * Format duration in seconds to human-readable format
 * Example: "5m 11s", "1h 23m", "2h"
 */
export const formatDuration = (seconds: number): string => {
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
