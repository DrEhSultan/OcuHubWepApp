# Troubleshooting Guide

## Common Issues & Solutions

### 🔴 "Supabase env vars missing" Error

**Problem:** App crashes on startup with environment variable error.

**Solution:**
1. Ensure `.env.local` exists in project root
2. Check it contains:
   ```
   NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
   NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
   ```
3. Restart dev server: `npm run dev`

---

### 🔴 Cannot Login to Admin Dashboard

**Problem:** Login fails with "Invalid credentials" or similar error.

**Solutions:**

**Check 1: User exists in Supabase Auth**
```sql
SELECT * FROM auth.users WHERE email = 'your-email@example.com';
```

**Check 2: User is in admin_users table**
```sql
SELECT * FROM public.admin_users WHERE email = 'your-email@example.com';
```

**Check 3: User is active**
```sql
UPDATE public.admin_users 
SET is_active = true 
WHERE email = 'your-email@example.com';
```

**Check 4: RLS policies applied**
```sql
-- Verify policies exist
SELECT * FROM pg_policies WHERE tablename = 'admin_users';
```

---

### 🔴 Dashboard Shows No Data

**Problem:** All tabs show "No data" or sample data only.

**This is expected!** The dashboard falls back to sample data when tables are empty.

**To populate real data:**

1. **Analytics:** Set up aggregation job to populate `tool_usage_summary`
2. **Users:** Populate `user_usage_summary` from your app's usage data
3. **Feedback:** Mobile app should POST to feedback endpoint
4. **Announcements:** Create via dashboard UI

---

### 🔴 RLS Policy Errors

**Problem:** "permission denied for table" errors.

**Solution:**
```sql
-- Re-enable RLS
ALTER TABLE public.admin_users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tool_usage_summary ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.feedbacks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.announcements ENABLE ROW LEVEL SECURITY;

-- Verify policies
SELECT schemaname, tablename, policyname 
FROM pg_policies 
WHERE schemaname = 'public';
```

---

### 🔴 Node Version Warnings

**Problem:** npm install shows engine warnings about Node v20.

**Solution:**
- Warnings are safe to ignore if using Node v18+
- For best compatibility, upgrade to Node v20+:
  ```bash
  # Using nvm
  nvm install 20
  nvm use 20
  
  # Or using Homebrew
  brew install node@20
  ```

---

### 🔴 Port 3000 Already in Use

**Problem:** "Port 3000 is already in use"

**Solution:**
```bash
# Find and kill process on port 3000
lsof -ti:3000 | xargs kill -9

# Or use different port
npm run dev -- -p 3001
```

---

### 🔴 Charts Not Rendering

**Problem:** Analytics charts show blank or error.

**Solutions:**

**Check 1: recharts installed**
```bash
npm list recharts
# Should show recharts@2.12.7 or similar
```

**Check 2: Data format**
- Charts expect specific data structures
- Check browser console for errors
- Verify sample data loads correctly

---

### 🔴 Announcement Not Showing in App

**Problem:** Created announcement doesn't appear in mobile app.

**Check:**

1. **Time window:** Announcement must be between `start_at` and `end_at`
   ```sql
   SELECT id, title, start_at, end_at, status 
   FROM public.announcements 
   WHERE now() BETWEEN start_at AND end_at;
   ```

2. **Status:** Should be 'live' or 'scheduled'
   ```sql
   UPDATE public.announcements 
   SET status = 'live' 
   WHERE id = 'announcement-uuid';
   ```

3. **RLS policy:** App can read time-windowed announcements
   ```sql
   -- Test as anonymous user
   SET ROLE anon;
   SELECT * FROM public.announcements;
   RESET ROLE;
   ```

---

### 🔴 TypeScript Errors

**Problem:** Type errors in IDE or build.

**Solution:**
```bash
# Regenerate types
npm run build

# Check tsconfig.json is valid
npx tsc --noEmit
```

---

### 🔴 Session Not Persisting

**Problem:** Logged out after page refresh.

**Check:**
1. Browser allows cookies/localStorage
2. Supabase client config has `persistSession: true` (already set)
3. Clear browser cache and try again

---

## Still Having Issues?

1. Check browser console for errors
2. Check terminal for server errors
3. Verify Supabase project is active
4. Check Supabase logs in dashboard
5. Review `SETUP_GUIDE.md` for missed steps

## Debug Mode

Add to `.env.local` for verbose logging:
```
NEXT_PUBLIC_DEBUG=true
```

Then check browser console for detailed logs.
