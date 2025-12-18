-- Update Test Announcements with Thumbnails
-- Using Flaticon CDN for reliable, free icons
-- Date: 2025-12-17

-- Test 1: LASIK Tool - Medical/Eye icon
UPDATE public.announcements 
SET metadata = jsonb_set(
    COALESCE(metadata, '{}'::jsonb),
    '{thumbnail}',
    '"https://cdn-icons-png.flaticon.com/512/2913/2913133.png"'
)
WHERE title = 'Test CTA Button Click to Open LASIK Tool (open 2 times)';

-- Test 2: Carousel Limit - Info icon
UPDATE public.announcements 
SET metadata = jsonb_set(
    COALESCE(metadata, '{}'::jsonb),
    '{thumbnail}',
    '"https://cdn-icons-png.flaticon.com/512/471/471662.png"'
)
WHERE title = 'Test Carousel Limit - 6th Announcement (should not appear in first session)';

-- Test 3: Profile/Targeting - User profile icon
UPDATE public.announcements 
SET metadata = jsonb_set(
    COALESCE(metadata, '{}'::jsonb),
    '{thumbnail}',
    '"https://cdn-icons-png.flaticon.com/512/1077/1077114.png"'
)
WHERE title = 'Test Announcement - Only for Ophthalmologist with Training Subspecialty';

-- Test 4: Quiz - Question mark icon
UPDATE public.announcements 
SET metadata = jsonb_set(
    COALESCE(metadata, '{}'::jsonb),
    '{thumbnail}',
    '"https://cdn-icons-png.flaticon.com/512/3524/3524335.png"'
)
WHERE title = 'Test Quiz - Contains 2 Questions';

-- Test 5: Modal Remind Later - Web/Browser icon
UPDATE public.announcements 
SET metadata = jsonb_set(
    COALESCE(metadata, '{}'::jsonb),
    '{thumbnail}',
    '"https://cdn-icons-png.flaticon.com/512/1006/1006771.png"'
)
WHERE title = 'Test Modal Remind Me Later (opens 2 times with 1 session interval)';

-- Test 6: Keep Showing Mode - Settings icon
UPDATE public.announcements 
SET metadata = jsonb_set(
    COALESCE(metadata, '{}'::jsonb),
    '{thumbnail}',
    '"https://cdn-icons-png.flaticon.com/512/2040/2040504.png"'
)
WHERE title = 'Test Keep Showing Mode - CTA Click Should Hide Only for Current Session';

-- Test 7: User Insights Survey - Survey/Clipboard icon
UPDATE public.announcements 
SET metadata = jsonb_set(
    COALESCE(metadata, '{}'::jsonb),
    '{thumbnail}',
    '"https://cdn-icons-png.flaticon.com/512/3135/3135715.png"'
)
WHERE title = 'Test User Insights Survey - Updates Profile Data';

-- Test 8: Interval Hours - Clock icon
UPDATE public.announcements 
SET metadata = jsonb_set(
    COALESCE(metadata, '{}'::jsonb),
    '{thumbnail}',
    '"https://cdn-icons-png.flaticon.com/512/2838/2838779.png"'
)
WHERE title = 'Test Interval Hours Repeat - Every 1 Hour (Max 3 Times)';

-- Test 9: Anonymous Users - Login/Key icon
UPDATE public.announcements 
SET metadata = jsonb_set(
    COALESCE(metadata, '{}'::jsonb),
    '{thumbnail}',
    '"https://cdn-icons-png.flaticon.com/512/2889/2889676.png"'
)
WHERE title = 'Test Anonymous Users Only - Sign In Prompt';

-- Test 10: Country Targeting - Globe icon
UPDATE public.announcements 
SET metadata = jsonb_set(
    COALESCE(metadata, '{}'::jsonb),
    '{thumbnail}',
    '"https://cdn-icons-png.flaticon.com/512/814/814513.png"'
)
WHERE title = 'Test Logged In Users + Country Targeting (US,CA,UK)';

-- Test 11: Non-Dismissible - Important/Alert icon
UPDATE public.announcements 
SET metadata = jsonb_set(
    COALESCE(metadata, '{}'::jsonb),
    '{thumbnail}',
    '"https://cdn-icons-png.flaticon.com/512/564/564619.png"'
)
WHERE title = 'Test Non-Dismissible Announcement - Must Click CTA';

-- Test 12: Inbox Only - Inbox/Mail icon
UPDATE public.announcements 
SET metadata = jsonb_set(
    COALESCE(metadata, '{}'::jsonb),
    '{thumbnail}',
    '"https://cdn-icons-png.flaticon.com/512/561/561127.png"'
)
WHERE title = 'Test Inbox-Only Announcement - Should Not Appear in Carousel';

-- Verification Query
SELECT 
    title,
    metadata->>'thumbnail' as thumbnail_url,
    metadata->>'cta_label' as cta_label
FROM public.announcements 
WHERE title LIKE 'Test %' 
ORDER BY display_sequence;
