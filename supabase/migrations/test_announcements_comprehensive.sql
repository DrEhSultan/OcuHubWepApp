-- Comprehensive Test Announcements for OcuHub
-- Date: 2025-12-17
-- Purpose: Test all announcement features and configurations
-- 
-- Run this SQL to insert test announcements covering:
-- 1. CTA button actions (open_tool, open_screen, open_link)
-- 2. Carousel limits and ordering
-- 3. Targeting (profession, subspecialty, etc.)
-- 4. Quiz functionality
-- 5. Modal remind later behavior
-- 6. Different repeat modes and dismissible modes
-- 7. disappear_after_cta settings

-- Test 1: CTA Button Click to Open LASIK Tool (repeat 2 times per app open)
INSERT INTO public.announcements (
    title,
    message,
    surface,
    importance,
    kind,
    action_type,
    action_value,
    repeat_mode,
    repeat_session_interval,
    max_times_seen_per_user,
    disappear_after_cta,
    status,
    metadata,
    display_sequence
) VALUES (
    'Test CTA Button Click to Open LASIK Tool (open 2 times)',
    'This announcement tests CTA button functionality. Click to open LASIK tool. Should appear 2 times per app session.',
    'home_banner',
    'high',
    'announcement',
    'open_tool',
    'lasik-calculator', -- Replace with actual tool ID from your database
    'per_app_open',
    1, -- Every session
    2, -- Max 2 times total
    true, -- Disappear after CTA click
    'live',
    '{"cta_label": "Open LASIK Tool", "cta_icon": "🔧", "thumbnail": "https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?w=400"}',
    1
);

-- Test 2: Carousel Limit Test (6th announcement - should not appear in first 5)
INSERT INTO public.announcements (
    title,
    message,
    surface,
    importance,
    kind,
    action_type,
    repeat_mode,
    status,
    metadata,
    display_sequence
) VALUES (
    'Test Carousel Limit - 6th Announcement (should not appear in first session)',
    'This is the 6th announcement to test carousel limits. Should not appear if carousel max is 5.',
    'home_banner',
    'low',
    'announcement',
    'none',
    'per_app_open',
    'live',
    '{"thumbnail": "https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?w=400"}',
    6 -- High sequence number to test ordering
);

-- Test 3: Targeting - Only Ophthalmologists with Training Subspecialty
INSERT INTO public.announcements (
    title,
    message,
    surface,
    importance,
    kind,
    action_type,
    action_value,
    repeat_mode,
    target_profession,
    target_subspecialty,
    status,
    metadata,
    display_sequence
) VALUES (
    'Test Announcement - Only for Ophthalmologist with Training Subspecialty',
    'This announcement should only appear to users with profession=Ophthalmologist AND subspecialty=Training. Tests targeting logic.',
    'home_banner',
    'medium',
    'announcement',
    'open_screen',
    'Profile',
    'once',
    'Ophthalmologist',
    'Training',
    'live',
    '{"cta_label": "Update Profile", "cta_icon": "👤", "thumbnail": "https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=400"}',
    2
);

-- Test 4: Quiz with 2 Questions
INSERT INTO public.announcements (
    title,
    message,
    surface,
    importance,
    kind,
    action_type,
    repeat_mode,
    dismissible_mode,
    status,
    metadata,
    questions,
    display_sequence
) VALUES (
    'Test Quiz - Contains 2 Questions',
    'This is a test quiz with 2 questions to verify quiz functionality and completion tracking.',
    'home_banner',
    'high',
    'quiz',
    'none',
    'once',
    'remind_later',
    'live',
    '{"survey_badge_text": "Quiz", "cta_label": "Start Quiz", "cta_icon": "❓", "thumbnail": "https://images.unsplash.com/photo-1606326608606-aa0b62935f2b?w=400"}',
    '[
        {
            "id": "q1",
            "type": "single_choice",
            "question": "What is the most common cause of blindness worldwide?",
            "options": ["Cataracts", "Glaucoma", "Diabetic Retinopathy", "Macular Degeneration"],
            "required": true,
            "correctAnswer": "Cataracts",
            "feedbackCorrect": {
                "actionType": "show_modal",
                "actionTitle": "Correct!",
                "actionValue": "Cataracts are indeed the leading cause of blindness globally."
            },
            "feedbackWrong": {
                "actionType": "show_modal", 
                "actionTitle": "Not quite",
                "actionValue": "The correct answer is Cataracts, which cause about 51% of world blindness."
            }
        },
        {
            "id": "q2",
            "type": "single_choice",
            "question": "Normal intraocular pressure range is:",
            "options": ["8-12 mmHg", "12-22 mmHg", "22-30 mmHg", "30-40 mmHg"],
            "required": true,
            "correctAnswer": "12-22 mmHg",
            "feedbackCorrect": {
                "actionType": "show_modal",
                "actionTitle": "Excellent!",
                "actionValue": "Correct! Normal IOP is typically 12-22 mmHg."
            },
            "feedbackWrong": {
                "actionType": "show_modal",
                "actionTitle": "Try again",
                "actionValue": "Normal IOP is 12-22 mmHg. Values above 22 mmHg may indicate glaucoma risk."
            }
        }
    ]',
    3
);

-- Test 5: Modal Remind Me Later (opens 2 times with 1 session interval)
INSERT INTO public.announcements (
    title,
    message,
    surface,
    importance,
    kind,
    action_type,
    action_value,
    repeat_mode,
    dismissible_mode,
    remind_later_count,
    remind_later_sessions,
    status,
    metadata,
    display_sequence
) VALUES (
    'Test Modal Remind Me Later (opens 2 times with 1 session interval)',
    'This modal tests remind later functionality. Should appear 2 times total with 1 session interval between reminders.',
    'modal',
    'medium',
    'announcement',
    'open_link',
    'https://ocuhub.com',
    'per_app_open',
    'remind_later',
    2, -- Show remind later 2 times
    1, -- 1 session interval between reminders
    'live',
    '{"cta_label": "Visit Website", "cta_icon": "🌐", "thumbnail": "https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=400"}',
    4
);

-- Test 6: Keep Showing Mode (disappear_after_cta = false)
INSERT INTO public.announcements (
    title,
    message,
    surface,
    importance,
    kind,
    action_type,
    action_value,
    repeat_mode,
    repeat_session_interval,
    disappear_after_cta,
    status,
    metadata,
    display_sequence
) VALUES (
    'Test Keep Showing Mode - CTA Click Should Hide Only for Current Session',
    'This announcement has disappear_after_cta=false. CTA click should hide it for current session only, then return next session.',
    'home_banner',
    'medium',
    'announcement',
    'open_screen',
    'Settings',
    'per_app_open',
    1, -- Every session
    false, -- Keep showing - don''t disappear after CTA
    'live',
    '{"cta_label": "Open Settings", "cta_icon": "⚙️", "thumbnail": "https://images.unsplash.com/photo-1484480974693-6ca0a78fb36b?w=400"}',
    5
);

-- Test 7: Survey with User Insights (links to profile)
INSERT INTO public.announcements (
    title,
    message,
    surface,
    importance,
    kind,
    action_type,
    repeat_mode,
    dismissible_mode,
    status,
    metadata,
    questions,
    display_sequence
) VALUES (
    'Test User Insights Survey - Updates Profile Data',
    'This survey collects user insights that update profile data. Tests linkToUserProfile functionality.',
    'home_banner',
    'high',
    'user_insights',
    'none',
    'once',
    'remind_later',
    'live',
    '{"survey_badge_text": "Profile Survey", "cta_label": "Complete Profile", "cta_icon": "📋", "thumbnail": "https://images.unsplash.com/photo-1434030216411-0b793f4b4173?w=400"}',
    '[
        {
            "id": "profession_q",
            "type": "dropdown",
            "question": "What is your medical profession?",
            "options": ["Ophthalmologist", "Optometrist", "Resident", "Medical Student", "Nurse", "Other"],
            "required": true,
            "linkToUserProfile": "profession"
        },
        {
            "id": "experience_q",
            "type": "dropdown", 
            "question": "How many years of experience do you have?",
            "options": ["0-2 years", "3-5 years", "6-10 years", "11-20 years", "20+ years"],
            "required": true,
            "linkToUserProfile": "years_experience"
        }
    ]',
    7
);

-- Test 8: Interval Hours Repeat Mode
INSERT INTO public.announcements (
    title,
    message,
    surface,
    importance,
    kind,
    action_type,
    repeat_mode,
    repeat_interval_hours,
    max_times_seen_per_user,
    status,
    metadata,
    display_sequence
) VALUES (
    'Test Interval Hours Repeat - Every 1 Hour (Max 3 Times)',
    'This announcement uses interval_hours repeat mode. Should appear every 1 hour, maximum 3 times total.',
    'home_banner',
    'low',
    'announcement',
    'none',
    'interval_hours',
    1, -- Every 1 hour
    3, -- Max 3 times
    'live',
    '{"thumbnail": "https://images.unsplash.com/photo-1501139083538-0139583c060f?w=400"}',
    8
);

-- Test 9: Anonymous Users Only
INSERT INTO public.announcements (
    title,
    message,
    surface,
    importance,
    kind,
    action_type,
    action_value,
    repeat_mode,
    target_anonymous_only,
    status,
    metadata,
    display_sequence
) VALUES (
    'Test Anonymous Users Only - Sign In Prompt',
    'This announcement should only appear to anonymous (not logged in) users. Tests anonymous targeting.',
    'home_banner',
    'medium',
    'announcement',
    'open_screen',
    'Login',
    'per_app_open',
    true, -- Anonymous only
    'live',
    '{"cta_label": "Sign In Now", "cta_icon": "🔑", "thumbnail": "https://images.unsplash.com/photo-1633265486064-086b219458ec?w=400"}',
    9
);

-- Test 10: Logged In Users Only with Country Targeting
INSERT INTO public.announcements (
    title,
    message,
    surface,
    importance,
    kind,
    action_type,
    repeat_mode,
    target_logged_in_only,
    target_country,
    status,
    metadata,
    display_sequence
) VALUES (
    'Test Logged In Users + Country Targeting (US,CA,UK)',
    'This announcement targets logged-in users in US, Canada, or UK only. Tests combined targeting.',
    'home_banner',
    'medium',
    'announcement',
    'none',
    'once',
    true, -- Logged in only
    'US,CA,UK', -- Multiple countries
    'live',
    '{"thumbnail": "https://images.unsplash.com/photo-1526778548025-fa2f459cd5c1?w=400"}',
    10
);

-- Test 11: Non-Dismissible Announcement
INSERT INTO public.announcements (
    title,
    message,
    surface,
    importance,
    kind,
    action_type,
    action_value,
    repeat_mode,
    dismissible,
    dismissible_mode,
    status,
    metadata,
    display_sequence
) VALUES (
    'Test Non-Dismissible Announcement - Must Click CTA',
    'This announcement cannot be dismissed. User must click the CTA button to make it go away.',
    'modal',
    'high',
    'announcement',
    'open_screen',
    'Home',
    'once',
    false, -- Not dismissible
    'no', -- Cannot dismiss
    'live',
    '{"cta_label": "Continue", "cta_icon": "▶️", "thumbnail": "https://images.unsplash.com/photo-1557804506-669a67965ba0?w=400"}',
    11
);

-- Test 12: Inbox-Only Announcement
INSERT INTO public.announcements (
    title,
    message,
    surface,
    importance,
    kind,
    action_type,
    repeat_mode,
    status,
    metadata,
    display_sequence
) VALUES (
    'Test Inbox-Only Announcement - Should Not Appear in Carousel',
    'This announcement has surface=inbox so should only appear in the inbox/notification center, not in carousel or modal.',
    'inbox',
    'low',
    'announcement',
    'none',
    'once',
    'live',
    '{"thumbnail": "https://images.unsplash.com/photo-1611162617474-5b21e879e113?w=400"}',
    12
);

-- Update all test announcements to have a consistent created_by and updated_by
UPDATE public.announcements 
SET 
    created_by = 'test-system',
    updated_by = 'test-system'
WHERE title LIKE 'Test %';

-- Set all test announcements to start immediately and never expire
UPDATE public.announcements 
SET 
    start_at = NOW(),
    end_at = NULL
WHERE title LIKE 'Test %';

-- Verification Query - Run this to see all test announcements
-- SELECT id, title, surface, importance, kind, action_type, repeat_mode, dismissible_mode, 
--        target_profession, target_subspecialty, target_anonymous_only, target_logged_in_only,
--        disappear_after_cta, display_sequence
-- FROM public.announcements 
-- WHERE title LIKE 'Test %' 
-- ORDER BY display_sequence;