-- =====================================================
-- Backend-Driven Announcement & Quiz System Migration
-- =====================================================
-- This migration implements server-side eligibility evaluation,
-- user interaction persistence, and optimized sync for large-scale
-- announcement handling.
-- =====================================================

-- 1. USER_ANNOUNCEMENT_STATE TABLE
-- Tracks all user interactions with announcements (seen, dismissed, deferred, completed)
-- This ensures restored users never see the same content again
CREATE TABLE IF NOT EXISTS public.user_announcement_state (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    announcement_id UUID NOT NULL REFERENCES public.announcements(id) ON DELETE CASCADE,
    user_id TEXT NOT NULL,  -- Can be auth_uid or device_id for anonymous users
    
    -- Interaction states
    status TEXT NOT NULL DEFAULT 'eligible' CHECK (status IN (
        'eligible',      -- User can see this announcement
        'seen',          -- User has seen but not interacted
        'dismissed',     -- User dismissed the announcement
        'deferred',      -- User clicked "remind later"
        'completed',     -- User completed (survey/quiz submitted, CTA clicked)
        'expired'        -- Announcement expired for this user
    )),
    
    -- Tracking timestamps
    first_seen_at TIMESTAMPTZ,
    last_seen_at TIMESTAMPTZ,
    dismissed_at TIMESTAMPTZ,
    deferred_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    
    -- Defer/remind later tracking
    defer_count INTEGER DEFAULT 0,
    defer_until_session INTEGER,  -- Session number when to show again
    defer_until_time TIMESTAMPTZ, -- Time when to show again
    
    -- Impression tracking
    impression_count INTEGER DEFAULT 0,
    
    -- For surveys/quizzes - track partial completion
    is_partially_completed BOOLEAN DEFAULT FALSE,
    questions_answered INTEGER DEFAULT 0,
    
    -- Metadata
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    CONSTRAINT user_announcement_state_unique UNIQUE (announcement_id, user_id)
);

-- Indexes for efficient querying
CREATE INDEX idx_user_announcement_state_user ON public.user_announcement_state(user_id);
CREATE INDEX idx_user_announcement_state_status ON public.user_announcement_state(status);
CREATE INDEX idx_user_announcement_state_announcement ON public.user_announcement_state(announcement_id);
CREATE INDEX idx_user_announcement_state_user_status ON public.user_announcement_state(user_id, status);

-- 2. ADD SEQUENCE/ORDER COLUMN TO ANNOUNCEMENTS
-- For admin-controlled ordering of low-importance announcements
ALTER TABLE public.announcements 
ADD COLUMN IF NOT EXISTS display_sequence INTEGER DEFAULT 0;

ALTER TABLE public.announcements 
ADD COLUMN IF NOT EXISTS carousel_max_count INTEGER DEFAULT 5;

-- Index for ordering
CREATE INDEX IF NOT EXISTS idx_announcements_sequence ON public.announcements(importance, display_sequence, created_at DESC);

-- 3. SYSTEM CONFIGURATION TABLE
-- Server-controlled limits and settings
CREATE TABLE IF NOT EXISTS public.announcement_config (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    config_key TEXT UNIQUE NOT NULL,
    config_value JSONB NOT NULL,
    description TEXT,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by TEXT
);

-- Insert default configuration
INSERT INTO public.announcement_config (config_key, config_value, description) VALUES
    ('carousel_max_items', '5', 'Maximum number of announcements in carousel'),
    ('inbox_page_size', '20', 'Number of items per page in announcement inbox'),
    ('sync_batch_size', '50', 'Maximum announcements to sync per request'),
    ('low_importance_batch', '10', 'Number of low-importance items to load at once')
ON CONFLICT (config_key) DO NOTHING;



-- 4. ADD FIRST ANSWER TRACKING TO announcement_responses (if not exists)
ALTER TABLE public.announcement_responses 
ADD COLUMN IF NOT EXISTS first_option_value TEXT;

ALTER TABLE public.announcement_responses 
ADD COLUMN IF NOT EXISTS first_text_value TEXT;

ALTER TABLE public.announcement_responses 
ADD COLUMN IF NOT EXISTS first_numeric_value NUMERIC;

ALTER TABLE public.announcement_responses 
ADD COLUMN IF NOT EXISTS first_answered_at TIMESTAMPTZ;

-- 5. FUNCTION: Get eligible announcements for a user
-- This is the core server-side eligibility function
CREATE OR REPLACE FUNCTION get_eligible_announcements(
    p_user_id TEXT,
    p_device_id TEXT DEFAULT NULL,
    p_auth_uid TEXT DEFAULT NULL,
    p_platform TEXT DEFAULT NULL,
    p_app_version TEXT DEFAULT NULL,
    p_country TEXT DEFAULT NULL,
    p_city TEXT DEFAULT NULL,
    p_is_logged_in BOOLEAN DEFAULT FALSE,
    p_profession TEXT DEFAULT NULL,
    p_speciality TEXT DEFAULT NULL,
    p_session_number INTEGER DEFAULT 1,
    p_surface TEXT DEFAULT 'home_banner',
    p_limit INTEGER DEFAULT 10,
    p_offset INTEGER DEFAULT 0
)
RETURNS TABLE (
    id UUID,
    title TEXT,
    message TEXT,
    body TEXT,
    surface TEXT,
    importance TEXT,
    kind TEXT,
    priority TEXT,
    action_type TEXT,
    action_value TEXT,
    dismissible BOOLEAN,
    dismissible_mode TEXT,
    metadata JSONB,
    questions JSONB,
    user_status TEXT,
    impression_count INTEGER,
    is_partially_completed BOOLEAN,
    questions_answered INTEGER,
    display_sequence INTEGER
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_effective_user_id TEXT;
BEGIN
    -- Determine effective user ID (prefer auth_uid, fallback to device_id)
    v_effective_user_id := COALESCE(p_auth_uid, p_device_id, p_user_id);
    
    RETURN QUERY
    SELECT 
        a.id,
        a.title,
        a.message,
        a.body,
        a.surface,
        a.importance,
        a.kind,
        a.priority,
        a.action_type,
        a.action_value,
        a.dismissible,
        a.dismissible_mode,
        a.metadata,
        a.questions,
        COALESCE(uas.status, 'eligible') AS user_status,
        COALESCE(uas.impression_count, 0) AS impression_count,
        COALESCE(uas.is_partially_completed, FALSE) AS is_partially_completed,
        COALESCE(uas.questions_answered, 0) AS questions_answered,
        a.display_sequence
    FROM public.announcements a
    LEFT JOIN public.user_announcement_state uas 
        ON uas.announcement_id = a.id 
        AND uas.user_id = v_effective_user_id
    WHERE 
        -- Basic filters
        a.is_active = TRUE
        AND a.is_deleted = FALSE
        AND a.status = 'live'
        AND (a.surface = p_surface OR a.surface = 'modal')
        
        -- Date range
        AND a.start_at <= NOW()
        AND (a.end_at IS NULL OR a.end_at > NOW())
        
        -- User hasn't completed/dismissed (unless deferred and ready to show)
        AND (
            uas.status IS NULL  -- Never seen
            OR uas.status = 'eligible'
            OR uas.status = 'seen'
            OR (uas.status = 'deferred' AND (
                (uas.defer_until_session IS NOT NULL AND uas.defer_until_session <= p_session_number)
                OR (uas.defer_until_time IS NOT NULL AND uas.defer_until_time <= NOW())
            ))
            OR (uas.status = 'completed' AND a.repeat_mode != 'once')
        )
        AND uas.status IS DISTINCT FROM 'dismissed'
        AND uas.status IS DISTINCT FROM 'expired'
        
        -- Max impressions check
        AND (a.max_times_seen_per_user IS NULL OR COALESCE(uas.impression_count, 0) < a.max_times_seen_per_user)
        
        -- Platform targeting
        AND (a.target_platform IS NULL OR a.target_platform = 'all' OR a.target_platform = p_platform)
        
        -- Login state targeting
        AND (
            (a.target_logged_in_only = FALSE AND a.target_anonymous_only = FALSE)
            OR (a.target_logged_in_only = TRUE AND p_is_logged_in = TRUE)
            OR (a.target_anonymous_only = TRUE AND p_is_logged_in = FALSE)
        )
        
        -- Country targeting
        AND (a.target_country IS NULL OR a.target_country = '' OR p_country = ANY(string_to_array(a.target_country, ',')))
        
        -- City targeting
        AND (a.target_city IS NULL OR a.target_city = '' OR p_city = ANY(string_to_array(a.target_city, ',')))
        
        -- Profession targeting
        AND (a.target_profession IS NULL OR a.target_profession = '' OR p_profession = ANY(string_to_array(a.target_profession, ',')))
        
        -- Speciality targeting
        AND (a.target_speciality IS NULL OR a.target_speciality = '' OR p_speciality = ANY(string_to_array(a.target_speciality, ',')))
        
    ORDER BY 
        -- Priority ordering: high > medium > low importance
        CASE a.importance 
            WHEN 'high' THEN 1 
            WHEN 'medium' THEN 2 
            WHEN 'low' THEN 3 
        END,
        -- Within same importance, use display_sequence (admin-controlled)
        a.display_sequence ASC NULLS LAST,
        -- Then by creation date (newest first for low importance)
        a.created_at DESC
    LIMIT p_limit
    OFFSET p_offset;
END;
$$;


-- 6. FUNCTION: Get carousel announcements (limited, prioritized)
CREATE OR REPLACE FUNCTION get_carousel_announcements(
    p_user_id TEXT,
    p_device_id TEXT DEFAULT NULL,
    p_auth_uid TEXT DEFAULT NULL,
    p_platform TEXT DEFAULT NULL,
    p_app_version TEXT DEFAULT NULL,
    p_country TEXT DEFAULT NULL,
    p_city TEXT DEFAULT NULL,
    p_is_logged_in BOOLEAN DEFAULT FALSE,
    p_profession TEXT DEFAULT NULL,
    p_speciality TEXT DEFAULT NULL,
    p_session_number INTEGER DEFAULT 1
)
RETURNS TABLE (
    id UUID,
    title TEXT,
    message TEXT,
    body TEXT,
    surface TEXT,
    importance TEXT,
    kind TEXT,
    priority TEXT,
    action_type TEXT,
    action_value TEXT,
    dismissible BOOLEAN,
    dismissible_mode TEXT,
    metadata JSONB,
    questions JSONB,
    user_status TEXT,
    impression_count INTEGER,
    is_partially_completed BOOLEAN,
    questions_answered INTEGER,
    display_sequence INTEGER,
    carousel_position INTEGER
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_max_items INTEGER;
BEGIN
    -- Get max carousel items from config
    SELECT (config_value::TEXT)::INTEGER INTO v_max_items 
    FROM public.announcement_config 
    WHERE config_key = 'carousel_max_items';
    
    v_max_items := COALESCE(v_max_items, 5);
    
    RETURN QUERY
    WITH eligible AS (
        SELECT 
            e.*,
            ROW_NUMBER() OVER (
                ORDER BY 
                    CASE e.importance 
                        WHEN 'high' THEN 1 
                        WHEN 'medium' THEN 2 
                        WHEN 'low' THEN 3 
                    END,
                    e.display_sequence ASC NULLS LAST,
                    -- For low importance, prioritize partially completed first
                    CASE WHEN e.is_partially_completed THEN 0 ELSE 1 END,
                    -- Then newest
                    e.id DESC
            ) AS carousel_position
        FROM get_eligible_announcements(
            p_user_id,
            p_device_id,
            p_auth_uid,
            p_platform,
            p_app_version,
            p_country,
            p_city,
            p_is_logged_in,
            p_profession,
            p_speciality,
            p_session_number,
            'home_banner',
            100,  -- Get more than needed for filtering
            0
        ) e
        WHERE e.surface IN ('home_banner', 'modal')
    )
    SELECT 
        eligible.id,
        eligible.title,
        eligible.message,
        eligible.body,
        eligible.surface,
        eligible.importance,
        eligible.kind,
        eligible.priority,
        eligible.action_type,
        eligible.action_value,
        eligible.dismissible,
        eligible.dismissible_mode,
        eligible.metadata,
        eligible.questions,
        eligible.user_status,
        eligible.impression_count,
        eligible.is_partially_completed,
        eligible.questions_answered,
        eligible.display_sequence,
        eligible.carousel_position::INTEGER
    FROM eligible
    WHERE eligible.carousel_position <= v_max_items;
END;
$$;

-- 7. FUNCTION: Get inbox announcements with pagination
CREATE OR REPLACE FUNCTION get_inbox_announcements(
    p_user_id TEXT,
    p_device_id TEXT DEFAULT NULL,
    p_auth_uid TEXT DEFAULT NULL,
    p_platform TEXT DEFAULT NULL,
    p_is_logged_in BOOLEAN DEFAULT FALSE,
    p_profession TEXT DEFAULT NULL,
    p_speciality TEXT DEFAULT NULL,
    p_session_number INTEGER DEFAULT 1,
    p_page INTEGER DEFAULT 1,
    p_page_size INTEGER DEFAULT 20
)
RETURNS TABLE (
    id UUID,
    title TEXT,
    message TEXT,
    body TEXT,
    surface TEXT,
    importance TEXT,
    kind TEXT,
    priority TEXT,
    action_type TEXT,
    action_value TEXT,
    dismissible BOOLEAN,
    dismissible_mode TEXT,
    metadata JSONB,
    questions JSONB,
    user_status TEXT,
    impression_count INTEGER,
    is_partially_completed BOOLEAN,
    questions_answered INTEGER,
    display_sequence INTEGER,
    total_count BIGINT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_offset INTEGER;
    v_total BIGINT;
BEGIN
    v_offset := (p_page - 1) * p_page_size;
    
    -- Get total count first
    SELECT COUNT(*) INTO v_total
    FROM get_eligible_announcements(
        p_user_id, p_device_id, p_auth_uid, p_platform, NULL,
        NULL, NULL, p_is_logged_in, p_profession, p_speciality,
        p_session_number, 'inbox', 1000, 0
    );
    
    RETURN QUERY
    SELECT 
        e.id,
        e.title,
        e.message,
        e.body,
        e.surface,
        e.importance,
        e.kind,
        e.priority,
        e.action_type,
        e.action_value,
        e.dismissible,
        e.dismissible_mode,
        e.metadata,
        e.questions,
        e.user_status,
        e.impression_count,
        e.is_partially_completed,
        e.questions_answered,
        e.display_sequence,
        v_total AS total_count
    FROM get_eligible_announcements(
        p_user_id, p_device_id, p_auth_uid, p_platform, NULL,
        NULL, NULL, p_is_logged_in, p_profession, p_speciality,
        p_session_number, 'inbox', p_page_size, v_offset
    ) e;
END;
$$;


-- 8. FUNCTION: Update user announcement state
CREATE OR REPLACE FUNCTION update_announcement_state(
    p_announcement_id UUID,
    p_user_id TEXT,
    p_status TEXT,
    p_session_number INTEGER DEFAULT NULL,
    p_defer_sessions INTEGER DEFAULT NULL,
    p_defer_hours INTEGER DEFAULT NULL,
    p_questions_answered INTEGER DEFAULT NULL
)
RETURNS public.user_announcement_state
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_result public.user_announcement_state;
    v_defer_until_session INTEGER;
    v_defer_until_time TIMESTAMPTZ;
BEGIN
    -- Calculate defer values if deferring
    IF p_status = 'deferred' THEN
        IF p_defer_sessions IS NOT NULL AND p_session_number IS NOT NULL THEN
            v_defer_until_session := p_session_number + p_defer_sessions;
        END IF;
        IF p_defer_hours IS NOT NULL THEN
            v_defer_until_time := NOW() + (p_defer_hours || ' hours')::INTERVAL;
        END IF;
    END IF;
    
    INSERT INTO public.user_announcement_state (
        announcement_id,
        user_id,
        status,
        first_seen_at,
        last_seen_at,
        dismissed_at,
        deferred_at,
        completed_at,
        defer_count,
        defer_until_session,
        defer_until_time,
        impression_count,
        is_partially_completed,
        questions_answered,
        updated_at
    ) VALUES (
        p_announcement_id,
        p_user_id,
        p_status,
        CASE WHEN p_status IN ('seen', 'dismissed', 'deferred', 'completed') THEN NOW() ELSE NULL END,
        NOW(),
        CASE WHEN p_status = 'dismissed' THEN NOW() ELSE NULL END,
        CASE WHEN p_status = 'deferred' THEN NOW() ELSE NULL END,
        CASE WHEN p_status = 'completed' THEN NOW() ELSE NULL END,
        CASE WHEN p_status = 'deferred' THEN 1 ELSE 0 END,
        v_defer_until_session,
        v_defer_until_time,
        1,
        CASE WHEN p_questions_answered IS NOT NULL AND p_questions_answered > 0 THEN TRUE ELSE FALSE END,
        COALESCE(p_questions_answered, 0),
        NOW()
    )
    ON CONFLICT (announcement_id, user_id) DO UPDATE SET
        status = EXCLUDED.status,
        last_seen_at = NOW(),
        dismissed_at = CASE WHEN EXCLUDED.status = 'dismissed' THEN NOW() ELSE user_announcement_state.dismissed_at END,
        deferred_at = CASE WHEN EXCLUDED.status = 'deferred' THEN NOW() ELSE user_announcement_state.deferred_at END,
        completed_at = CASE WHEN EXCLUDED.status = 'completed' THEN NOW() ELSE user_announcement_state.completed_at END,
        defer_count = CASE WHEN EXCLUDED.status = 'deferred' THEN user_announcement_state.defer_count + 1 ELSE user_announcement_state.defer_count END,
        defer_until_session = COALESCE(v_defer_until_session, user_announcement_state.defer_until_session),
        defer_until_time = COALESCE(v_defer_until_time, user_announcement_state.defer_until_time),
        impression_count = user_announcement_state.impression_count + 1,
        is_partially_completed = CASE 
            WHEN EXCLUDED.status = 'completed' THEN FALSE 
            WHEN p_questions_answered IS NOT NULL AND p_questions_answered > 0 THEN TRUE 
            ELSE user_announcement_state.is_partially_completed 
        END,
        questions_answered = COALESCE(p_questions_answered, user_announcement_state.questions_answered),
        updated_at = NOW()
    RETURNING * INTO v_result;
    
    RETURN v_result;
END;
$$;

-- 9. FUNCTION: Record impression (lightweight, just increments counter)
CREATE OR REPLACE FUNCTION record_announcement_impression(
    p_announcement_id UUID,
    p_user_id TEXT
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    INSERT INTO public.user_announcement_state (
        announcement_id,
        user_id,
        status,
        first_seen_at,
        last_seen_at,
        impression_count
    ) VALUES (
        p_announcement_id,
        p_user_id,
        'seen',
        NOW(),
        NOW(),
        1
    )
    ON CONFLICT (announcement_id, user_id) DO UPDATE SET
        last_seen_at = NOW(),
        impression_count = user_announcement_state.impression_count + 1,
        first_seen_at = COALESCE(user_announcement_state.first_seen_at, NOW()),
        status = CASE 
            WHEN user_announcement_state.status = 'eligible' THEN 'seen'
            ELSE user_announcement_state.status
        END,
        updated_at = NOW();
END;
$$;

-- 10. RLS POLICIES for user_announcement_state
ALTER TABLE public.user_announcement_state ENABLE ROW LEVEL SECURITY;

CREATE POLICY "user_announcement_state_access" ON public.user_announcement_state
FOR ALL USING (
    user_id = auth.jwt() ->> 'sub'
    OR auth.role() = 'service_role'
);

-- 11. RLS POLICIES for announcement_config (read-only for users)
ALTER TABLE public.announcement_config ENABLE ROW LEVEL SECURITY;

CREATE POLICY "announcement_config_read" ON public.announcement_config
FOR SELECT USING (TRUE);

CREATE POLICY "announcement_config_admin" ON public.announcement_config
FOR ALL USING (auth.role() = 'service_role');

-- 12. Grant execute permissions on functions
GRANT EXECUTE ON FUNCTION get_eligible_announcements TO authenticated, anon;
GRANT EXECUTE ON FUNCTION get_carousel_announcements TO authenticated, anon;
GRANT EXECUTE ON FUNCTION get_inbox_announcements TO authenticated, anon;
GRANT EXECUTE ON FUNCTION update_announcement_state TO authenticated, anon;
GRANT EXECUTE ON FUNCTION record_announcement_impression TO authenticated, anon;

-- 13. Create updated_at trigger for user_announcement_state
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_user_announcement_state_updated_at ON public.user_announcement_state;
CREATE TRIGGER update_user_announcement_state_updated_at
    BEFORE UPDATE ON public.user_announcement_state
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
