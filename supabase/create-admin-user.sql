-- Create Admin User for OcuHub Dashboard
-- 
-- INSTRUCTIONS:
-- 1. First, create an auth user in Supabase Dashboard:
--    Authentication → Users → Add User
--    Set email and password
-- 
-- 2. Copy the user's UUID from the users table
-- 
-- 3. Replace 'USER-UUID-HERE' below with the actual UUID
-- 
-- 4. Run this SQL in Supabase SQL Editor

INSERT INTO public.admin_users (
  user_id, 
  email, 
  role, 
  is_active
)
VALUES (
  'USER-UUID-HERE',           -- Replace with actual user UUID
  'admin@example.com',        -- Replace with actual email
  'superadmin',               -- 'admin' or 'superadmin'
  true
);

-- Verify the admin user was created
SELECT * FROM public.admin_users;

-- Optional: Update last_login_at when they first login
-- This happens automatically in the dashboard, but you can test:
-- UPDATE public.admin_users 
-- SET last_login_at = now() 
-- WHERE email = 'admin@example.com';
