-- ============================================
-- DEBUG: Why is unread count = 1 for this user?
-- ============================================
-- User: OINPPms0SAP2yHu6rRLcuOGYuj23
-- Issue: Shows unread count = 1 but no announcements in inbox
-- ============================================

-- Step 1: Check what announcements this user can see (inbox)
SELECT 
    a.id,
    a.title,
    a.surface,
    a.importance,
    a.kind,
    a.is_active,
    a.status,
    a.start_at,
    a.end_at,
    a.target_min_app_version,
    a.target_max_app_version,
    a.target_country,
    a.target_city,
    a.target_logged_in_only,
    a.target_anonymous_only,
    uas.status as user_status,
    uas.impression_count,
    uas.is_partially_completed,
    uas.questions_answered,
    -- Calculate is_read
    CASE 
        WHEN COALESCE(a.disappear_after_cta, TRUE) = FALSE THEN 
            (uas.status = 'dismissed')
        ELSE 
            (COALESCE(uas.impression_count, 0) > 0)
    END AS is_read
FROM announcements a
LEFT JOIN user_announcement_state uas 
    ON uas.announcement_id = a.id 
    AND uas.user_id = 'OINPPms0SAP2yHu6rRLcuOGYuj23'
WHERE 
    a.is_deleted = FALSE
    AND a.is_active = TRUE
    AND (a.status = 'live' OR a.status = 'published' OR a.status IS NULL)
    AND a.start_at <= NOW()
    AND (a.end_at IS NULL OR a.end_at > NOW())
    AND a.surface IN ('home_banner', 'modal', 'inbox')
ORDER BY a.created_at DESC;

-- ============================================
-- Step 2: Check user_announcement_state for this user
-- ============================================
SELECT 
    uas.announcement_id,
    a.title,
    uas.status,
    uas.impression_count,
    uas.is_partially_completed,
    uas.questions_answered,
    uas.first_seen_at,
    uas.last_seen_at,
    uas.defer_count,
    uas.defer_until_session
FROM user_announcement_state uas
LEFT JOIN announcements a ON a.id = uas.announcement_id
WHERE uas.user_id = 'OINPPms0SAP2yHu6rRLcuOGYuj23'
ORDER BY uas.last_seen_at DESC NULLS LAST;

-- ============================================
-- Step 3: Call get_inbox_announcements (what the app sees)
-- ============================================
SELECT 
    id,
    title,
    surface,
    importance,
    kind,
    user_status,
    impression_count,
    is_read
FROM get_inbox_announcements(
    'OINPPms0SAP2yHu6rRLcuOGYuj23',  -- p_user_id
    NULL,                              -- p_device_id
    'OINPPms0SAP2yHu6rRLcuOGYuj23',  -- p_auth_uid
    'Android',                         -- p_platform
    '1.0.1',                           -- p_app_version
    'Saudi Arabia',                    -- p_country
    'Jeddah',                          -- p_city
    TRUE,                              -- p_is_logged_in
    NULL,                              -- p_profession
    NULL,                              -- p_speciality
    NULL,                              -- p_degree
    NULL,                              -- p_experience
    FALSE,                             -- p_has_complete_profile
    1,                                 -- p_session_number
    FALSE,                             -- p_is_real_device (emulator)
    1,                                 -- p_page
    20                                 -- p_page_size
);

-- ============================================
-- Step 4: Count unread announcements (what should the badge show?)
-- ============================================
SELECT 
    COUNT(*) as unread_count
FROM get_inbox_announcements(
    'OINPPms0SAP2yHu6rRLcuOGYuj23',
    NULL,
    'OINPPms0SAP2yHu6rRLcuOGYuj23',
    'Android',
    '1.0.1',
    'Saudi Arabia',
    'Jeddah',
    TRUE,
    NULL,
    NULL,
    NULL,
    NULL,
    FALSE,
    1,
    FALSE,
    1,
    100
)
WHERE is_read = FALSE;

-- ============================================
-- Step 5: Check for orphaned survey responses
-- ============================================
SELECT 
    ar.announcement_id,
    a.title,
    COUNT(*) as response_count,
    MAX(ar.created_at) as last_response
FROM announcement_responses ar
LEFT JOIN announcements a ON a.id = ar.announcement_id
WHERE ar.user_auth_uid = 'OINPPms0SAP2yHu6rRLcuOGYuj23'
GROUP BY ar.announcement_id, a.title
ORDER BY last_response DESC;

-- ============================================
-- INSTRUCTIONS:
-- ============================================
-- 1. Run this entire file in Supabase SQL Editor
-- 2. Look at the results of each query
-- 3. Share the results with me to debug why unread count = 1
-- ============================================
