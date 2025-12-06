# OcuHub Admin Dashboard - Setup Guide

## ✅ Completed
- [x] Dependencies installed (`@supabase/supabase-js`, `recharts`)
- [x] Supabase client configured (`lib/supabaseClient.ts`)
- [x] Admin dashboard built (`pages/admin.tsx`)
- [x] Database schema prepared (`supabase/schema.sql`)

## 🚀 Next Steps

### 1. Configure Environment Variables

Create `.env.local` in the project root:

```bash
NEXT_PUBLIC_SUPABASE_URL=https://YOUR-PROJECT.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key-here
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key-here
```

**Where to find these:**
- Go to your Supabase project dashboard
- Navigate to Settings → API
- Copy the Project URL and anon/public key

### 2. Apply Database Schema

1. Open your Supabase project dashboard
2. Go to SQL Editor
3. Copy the contents of `supabase/schema.sql`
4. Paste and run it in the SQL editor

This creates:
- `admin_users` - Admin authentication
- `tool_usage_summary` - Analytics aggregates
- `user_usage_summary` - User activity snapshots
- `feedbacks` - User feedback collection
- `announcements` - Announcements & surveys
- `announcement_responses` - Survey responses
- `announcement_impressions` - Impression tracking

### 3. Create Admin User

After applying the schema:

**Option A: Via Supabase Dashboard**
1. Go to Authentication → Users
2. Add a new user with email/password
3. Copy the user's UUID
4. Go to SQL Editor and run:

```sql
INSERT INTO public.admin_users (user_id, email, role, is_active)
VALUES ('USER-UUID-HERE', 'admin@example.com', 'superadmin', true);
```

**Option B: Via SQL Editor (all at once)**
```sql
-- This creates both auth user and admin entry
-- Note: You'll need to set the password via Supabase Auth UI
INSERT INTO public.admin_users (email, role, is_active)
VALUES ('admin@example.com', 'superadmin', true);
```

### 4. Start Development Server

```bash
npm run dev
```

Visit: http://localhost:3000/admin

### 5. Test the Dashboard

1. **Login**: Use the admin credentials you created
2. **Tools Tab**: View analytics (will show sample data until real data is synced)
3. **Users & Sessions**: See per-user breakdowns
4. **Feedback**: Review user feedback by tool
5. **Announcements**: Create announcements or surveys

### 6. Verify RLS Policies

The schema includes Row Level Security policies:
- Admins can only access data when authenticated
- Mobile app can insert feedback anonymously
- Announcements are time-windowed for app users
- Existing mobile sync tables remain untouched

Test by:
1. Creating an announcement with start/end dates
2. Verifying it appears in the dashboard
3. Checking that mobile app can fetch active announcements

## 📊 Data Population

The dashboard works with sample data initially. To populate real data:

1. **Analytics**: Set up a cron job or Edge Function to aggregate tool usage into `tool_usage_summary` and `user_usage_summary`
2. **Feedback**: Mobile app should POST to `/api/feedback` endpoint
3. **Announcements**: Create via the dashboard UI

## 🔒 Security Notes

- Never commit `.env.local` to git
- Use service role key only for server-side operations
- RLS policies protect all admin tables
- Admin users must be explicitly added to `admin_users` table

## 🐛 Troubleshooting

**"Supabase env vars missing" error:**
- Ensure `.env.local` exists with correct values
- Restart dev server after adding env vars

**Can't login:**
- Verify user exists in Supabase Auth
- Check user UUID is in `admin_users` with `is_active=true`
- Confirm RLS policies are applied

**No data showing:**
- Dashboard falls back to sample data if tables are empty
- This is expected until you populate analytics tables

## 📝 Additional Resources

- [Supabase Documentation](https://supabase.com/docs)
- [Next.js Documentation](https://nextjs.org/docs)
- See `ANNOUNCEMENT_ADMIN_DASHBOARD_PROMPT.md` for feature details
