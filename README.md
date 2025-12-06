# OcuHub Admin Dashboard

A secure, Supabase-backed admin dashboard for OcuHub with analytics, feedback triage, and announcement/survey controls.

## 🚀 Quick Start

**Ready to launch in 7 minutes!**

1. **Setup environment** (2 min)
   ```bash
   cp .env.example .env.local
   # Add your Supabase credentials
   ```

2. **Apply database schema** (3 min)
   - Open Supabase SQL Editor
   - Run `supabase/schema.sql`

3. **Create admin user** (2 min)
   - Create user in Supabase Auth
   - Run `supabase/create-admin-user.sql`

4. **Launch!**
   ```bash
   npm run dev
   ```
   Visit: http://localhost:3000/admin

📖 **See [QUICK_START.md](QUICK_START.md) for detailed steps**

## 📚 Documentation

- **[COMPLETION_STATUS.md](COMPLETION_STATUS.md)** - What's done & what's next
- **[SETUP_GUIDE.md](SETUP_GUIDE.md)** - Detailed setup instructions
- **[SETUP_CHECKLIST.md](SETUP_CHECKLIST.md)** - Track your progress
- **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)** - Common issues & solutions
- **[ANNOUNCEMENT_ADMIN_DASHBOARD_PROMPT.md](ANNOUNCEMENT_ADMIN_DASHBOARD_PROMPT.md)** - Feature details

## ✨ Features

### 📊 Tools Analytics
- Usage metrics per tool
- Geographic distribution
- Trend charts
- Drill-in views

### 👥 Users & Sessions
- Per-user breakdowns
- Tool usage by location
- Session tracking

### 💬 Feedback Triage
- View by tool or latest
- Filter by type
- User details

### 📢 Announcements & Surveys
- Create announcements
- Build surveys with multiple question types
- Set audience targeting
- Configure time windows
- View live results

## 🔒 Security

- Row Level Security (RLS) on all tables
- Admin-only dashboard access
- Time-windowed announcements
- Existing mobile sync untouched

## 🛠️ Tech Stack

- **Framework:** Next.js
- **Database:** Supabase (PostgreSQL)
- **Auth:** Supabase Auth
- **Charts:** Recharts
- **Styling:** Tailwind CSS

## 📦 Project Structure

```
OcuHubWepApp/
├── pages/
│   └── admin.tsx              # Main admin dashboard
├── lib/
│   └── supabaseClient.ts      # Supabase configuration
├── supabase/
│   ├── schema.sql             # Database schema
│   └── create-admin-user.sql  # Admin user helper
├── .env.example               # Environment template
└── setup-admin.sh             # Setup automation script
```

## 🎯 Status

✅ **Ready to deploy!** All code is complete. Just add your Supabase credentials and apply the schema.

## 🆘 Need Help?

1. Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
2. Review [SETUP_GUIDE.md](SETUP_GUIDE.md)
3. Verify [SETUP_CHECKLIST.md](SETUP_CHECKLIST.md)

## 📝 License

Part of the OcuHub project.
