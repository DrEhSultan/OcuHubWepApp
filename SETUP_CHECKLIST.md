# Setup Checklist ✓

Use this checklist to track your setup progress:

## Prerequisites
- [ ] Node.js installed (v18+ recommended, v20+ ideal)
- [ ] Supabase project created
- [ ] Access to Supabase dashboard

## Setup Steps

### 1. Dependencies
- [x] Dependencies installed (`npm install` completed)
- [x] `@supabase/supabase-js` added
- [x] `recharts` added

### 2. Environment Configuration
- [ ] `.env.local` file created
- [ ] `NEXT_PUBLIC_SUPABASE_URL` added
- [ ] `NEXT_PUBLIC_SUPABASE_ANON_KEY` added
- [ ] (Optional) `SUPABASE_SERVICE_ROLE_KEY` added

### 3. Database Schema
- [ ] Opened Supabase SQL Editor
- [ ] Ran `supabase/schema.sql`
- [ ] Verified tables created:
  - [ ] `admin_users`
  - [ ] `tool_usage_summary`
  - [ ] `user_usage_summary`
  - [ ] `feedbacks`
  - [ ] `announcements`
  - [ ] `announcement_responses`
  - [ ] `announcement_impressions`

### 4. Admin User Creation
- [ ] Created auth user in Supabase (Authentication → Users)
- [ ] Copied user UUID
- [ ] Inserted into `admin_users` table
- [ ] Verified `is_active = true`

### 5. Testing
- [ ] Started dev server (`npm run dev`)
- [ ] Accessed http://localhost:3000/admin
- [ ] Successfully logged in
- [ ] Viewed Tools analytics tab
- [ ] Viewed Users & Sessions tab
- [ ] Viewed Feedback tab
- [ ] Viewed Announcements tab
- [ ] Created test announcement
- [ ] Created test survey

### 6. RLS Verification
- [ ] Verified admin can access dashboard
- [ ] Verified non-admin cannot access admin tables
- [ ] Tested announcement time-windowing
- [ ] Confirmed mobile app sync tables untouched

## Optional Enhancements
- [ ] Set up analytics aggregation cron job
- [ ] Configure feedback API endpoint
- [ ] Add additional admin users
- [ ] Customize announcement templates
- [ ] Set up email notifications for feedback

## Troubleshooting
If you encounter issues, check:
- [ ] `.env.local` has correct values
- [ ] Dev server restarted after env changes
- [ ] User exists in both `auth.users` and `admin_users`
- [ ] RLS policies applied correctly
- [ ] Browser console for errors

---

**Status:** _____ / 23 core steps completed

**Notes:**
_Add any notes or issues you encountered here_
