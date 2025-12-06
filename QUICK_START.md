# 🚀 Quick Start - 3 Steps to Launch

## Step 1: Environment Setup (2 minutes)

```bash
# Copy environment template
cp .env.example .env.local

# Edit .env.local and add your Supabase credentials:
# - NEXT_PUBLIC_SUPABASE_URL (from Supabase Dashboard → Settings → API)
# - NEXT_PUBLIC_SUPABASE_ANON_KEY (from same location)
```

## Step 2: Database Setup (3 minutes)

1. Open Supabase SQL Editor
2. Copy & paste contents of `supabase/schema.sql`
3. Click "Run"

## Step 3: Create Admin User (2 minutes)

**In Supabase Dashboard:**
1. Go to Authentication → Users → Add User
2. Set email/password, copy the UUID

**In SQL Editor:**
```sql
INSERT INTO public.admin_users (user_id, email, role, is_active)
VALUES ('PASTE-UUID-HERE', 'your-email@example.com', 'superadmin', true);
```

## Launch! 🎉

```bash
npm run dev
```

Visit: **http://localhost:3000/admin**

Login with the credentials you created.

---

**Need help?** See `SETUP_GUIDE.md` for detailed instructions.
