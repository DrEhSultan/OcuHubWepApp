#!/bin/bash

# OcuHub Admin Dashboard Setup Script
# This script helps you set up the admin dashboard step by step

echo "🚀 OcuHub Admin Dashboard Setup"
echo "================================"
echo ""

# Check if .env.local exists
if [ -f .env.local ]; then
    echo "✅ .env.local already exists"
else
    echo "📝 Creating .env.local from template..."
    cp .env.example .env.local
    echo "⚠️  Please edit .env.local and add your Supabase credentials"
    echo "   - NEXT_PUBLIC_SUPABASE_URL"
    echo "   - NEXT_PUBLIC_SUPABASE_ANON_KEY"
    echo ""
    echo "   Find these in: Supabase Dashboard → Settings → API"
    echo ""
fi

# Check if node_modules exists
if [ -d node_modules ]; then
    echo "✅ Dependencies already installed"
else
    echo "📦 Installing dependencies..."
    npm install
fi

echo ""
echo "📋 Next Steps:"
echo ""
echo "1. Edit .env.local with your Supabase credentials"
echo "2. Apply database schema:"
echo "   - Open Supabase SQL Editor"
echo "   - Run the contents of supabase/schema.sql"
echo ""
echo "3. Create an admin user:"
echo "   - Go to Supabase Authentication → Users"
echo "   - Create a new user"
echo "   - Run this SQL with the user's UUID:"
echo ""
echo "   INSERT INTO public.admin_users (user_id, email, role, is_active)"
echo "   VALUES ('USER-UUID', 'admin@example.com', 'superadmin', true);"
echo ""
echo "4. Start the dev server:"
echo "   npm run dev"
echo ""
echo "5. Visit http://localhost:3000/admin"
echo ""
echo "📖 See SETUP_GUIDE.md for detailed instructions"
