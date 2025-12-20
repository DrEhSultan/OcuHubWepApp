--
-- PostgreSQL database dump
--

-- Dumped from database version 17.4
-- Dumped by pg_dump version 17.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA public;


--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA public IS 'standard public schema';


--
-- Name: check_merge_conflicts(text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.check_merge_conflicts(p_old_auth_uid text, p_new_auth_uid text) RETURNS TABLE(conflict_type text, conflict_count integer, details jsonb)
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
    -- Check app_settings conflicts
    RETURN QUERY
    SELECT
        'app_settings'::TEXT,
        COUNT(*)::INTEGER,
        jsonb_agg(jsonb_build_object(
            'setting_key', setting_key,
            'old_value', (SELECT setting_value FROM app_settings WHERE auth_uid = p_old_auth_uid AND app_settings.setting_key = s.setting_key),
            'new_value', s.setting_value
        ))
    FROM app_settings s
    WHERE s.auth_uid = p_new_auth_uid
    AND EXISTS (SELECT 1 FROM app_settings WHERE auth_uid = p_old_auth_uid AND setting_key = s.setting_key)
    GROUP BY 'app_settings';

    -- Check tool_settings conflicts
    RETURN QUERY
    SELECT
        'tool_settings'::TEXT,
        COUNT(*)::INTEGER,
        jsonb_agg(jsonb_build_object(
            'tool_id', tool_id,
            'old_favorited', (SELECT is_favorited FROM tool_settings WHERE auth_uid = p_old_auth_uid AND tool_settings.tool_id = t.tool_id),
            'new_favorited', t.is_favorited
        ))
    FROM tool_settings t
    WHERE t.auth_uid = p_new_auth_uid
    AND EXISTS (SELECT 1 FROM tool_settings WHERE auth_uid = p_old_auth_uid AND tool_id = t.tool_id)
    GROUP BY 'tool_settings';
END;
$$;


--
-- Name: compare_semver(text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.compare_semver(version_a text, version_b text) RETURNS integer
    LANGUAGE plpgsql IMMUTABLE
    AS $$
DECLARE a_parts INT[]; b_parts INT[]; idx INT;
BEGIN
    IF version_a IS NULL OR version_b IS NULL THEN RETURN 0; END IF;
    a_parts := ARRAY(SELECT COALESCE(NULLIF(part,''),'0')::INT FROM unnest(string_to_array(version_a,'.')) part);
    b_parts := ARRAY(SELECT COALESCE(NULLIF(part,''),'0')::INT FROM unnest(string_to_array(version_b,'.')) part);
    FOR idx IN 1..GREATEST(array_length(a_parts,1), array_length(b_parts,1)) LOOP
        IF COALESCE(a_parts[idx],0) > COALESCE(b_parts[idx],0) THEN RETURN 1;
        ELSIF COALESCE(a_parts[idx],0) < COALESCE(b_parts[idx],0) THEN RETURN -1;
        END IF;
    END LOOP;
    RETURN 0;
END;
$$;


--
-- Name: consolidate_users_by_auth_uid(text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.consolidate_users_by_auth_uid(p_old_auth_uid text, p_new_auth_uid text) RETURNS TABLE(consolidated_count integer, settings_migrated integer, sessions_migrated integer)
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    v_old_user_id TEXT;
    v_new_user_id TEXT;
    v_settings_count INTEGER := 0;
    v_sessions_count INTEGER := 0;
BEGIN
    -- Get user IDs
    SELECT user_id INTO v_old_user_id FROM users WHERE auth_uid = p_old_auth_uid;
    SELECT user_id INTO v_new_user_id FROM users WHERE auth_uid = p_new_auth_uid;

    IF v_old_user_id IS NOT NULL AND v_new_user_id IS NOT NULL THEN
        -- Migrate settings
        UPDATE app_settings SET auth_uid = p_new_auth_uid, user_id = v_new_user_id WHERE auth_uid = p_old_auth_uid;
        GET DIAGNOSTICS v_settings_count = ROW_COUNT;

        UPDATE screen_settings SET auth_uid = p_new_auth_uid, user_id = v_new_user_id WHERE auth_uid = p_old_auth_uid;
        UPDATE section_settings SET auth_uid = p_new_auth_uid, user_id = v_new_user_id WHERE auth_uid = p_old_auth_uid;
        UPDATE category_settings SET auth_uid = p_new_auth_uid, user_id = v_new_user_id WHERE auth_uid = p_old_auth_uid;
        UPDATE tool_settings SET auth_uid = p_new_auth_uid, user_id = v_new_user_id WHERE auth_uid = p_old_auth_uid;

        -- Migrate analytics
        UPDATE app_sessions SET auth_uid = p_new_auth_uid, user_id = v_new_user_id WHERE auth_uid = p_old_auth_uid;
        GET DIAGNOSTICS v_sessions_count = ROW_COUNT;

        UPDATE tool_usage_events SET auth_uid = p_new_auth_uid, user_id = v_new_user_id WHERE auth_uid = p_old_auth_uid;
        UPDATE feedbacks SET auth_uid = p_new_auth_uid, user_id = v_new_user_id WHERE auth_uid = p_old_auth_uid;

        -- Delete old user
        DELETE FROM users WHERE auth_uid = p_old_auth_uid;

        RETURN QUERY SELECT 1, v_settings_count, v_sessions_count;
    ELSE
        RETURN QUERY SELECT 0, 0, 0;
    END IF;
END;
$$;


--
-- Name: fetch_active_announcements(text, text, text, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fetch_active_announcements(p_user_id text, p_app_version text DEFAULT NULL::text, p_platform text DEFAULT NULL::text, p_limit integer DEFAULT 5) RETURNS TABLE(id uuid, title text, body_markdown text, severity text, status text, cta_label text, cta_url text, published_at timestamp with time zone, expires_at timestamp with time zone, user_status text, first_seen_at timestamp with time zone)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE v_now TIMESTAMPTZ := NOW();
BEGIN
    RETURN QUERY
    SELECT
        a.id, a.title, a.body_markdown, a.severity, a.status,
        a.cta_label, a.cta_url, a.published_at, a.expires_at,
        COALESCE(ua.status, 'delivered') AS user_status,
        ua.first_seen_at
    FROM app_announcements a
    LEFT JOIN user_announcements ua
      ON ua.announcement_id = a.id AND ua.user_id = p_user_id
    WHERE a.status = 'published'
      AND (a.expires_at IS NULL OR a.expires_at > v_now)
      AND (a.target_platform = 'all' OR p_platform IS NULL OR a.target_platform = p_platform)
      AND (a.min_app_version IS NULL OR p_app_version IS NULL OR compare_semver(p_app_version, a.min_app_version) >= 0)
      AND (a.max_app_version IS NULL OR p_app_version IS NULL OR compare_semver(p_app_version, a.max_app_version) <= 0)
    ORDER BY a.severity DESC, a.published_at DESC
    LIMIT COALESCE(p_limit, 5);
END;
$$;


--
-- Name: fn_process_tool_usage_event(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_process_tool_usage_event() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
    v_existing tool_usage_sessions;
    v_new_session BOOLEAN := false;
    v_duration DOUBLE PRECISION := 0;
    v_usage_date DATE := (NEW.event_timestamp AT TIME ZONE 'UTC')::DATE;
    v_unique_user_increment INTEGER := 0;
BEGIN
    SELECT * INTO v_existing FROM tool_usage_sessions WHERE tool_session_id = NEW.tool_session_id;
    IF NOT FOUND THEN
        v_new_session := true;
        INSERT INTO tool_usage_sessions(
            tool_session_id,user_id,tool_id,app_session_id,
            first_event_at,last_event_at,open_events,close_events,interaction_events
        ) VALUES (
            NEW.tool_session_id, NEW.user_id, NEW.tool_id, NEW.app_session_id,
            NEW.event_timestamp, NEW.event_timestamp,
            CASE WHEN NEW.event_type='open' THEN 1 ELSE 0 END,
            CASE WHEN NEW.event_type='close' THEN 1 ELSE 0 END,
            CASE WHEN NEW.event_type NOT IN ('open','close') THEN 1 ELSE 0 END
        );
    ELSE
        UPDATE tool_usage_sessions SET
            last_event_at = GREATEST(v_existing.last_event_at, NEW.event_timestamp),
            open_events = v_existing.open_events + CASE WHEN NEW.event_type='open' THEN 1 ELSE 0 END,
            close_events = v_existing.close_events + CASE WHEN NEW.event_type='close' THEN 1 ELSE 0 END,
            interaction_events = v_existing.interaction_events + CASE WHEN NEW.event_type NOT IN ('open','close') THEN 1 ELSE 0 END
        WHERE tool_session_id = NEW.tool_session_id;
    END IF;

    IF NEW.event_type = 'close' THEN
        v_duration := GREATEST(0, EXTRACT(EPOCH FROM (NEW.event_timestamp - COALESCE(v_existing.first_event_at, NEW.event_timestamp))));
        UPDATE tool_usage_sessions SET duration_seconds = GREATEST(COALESCE(duration_seconds,0), v_duration)
        WHERE tool_session_id = NEW.tool_session_id;
    END IF;

    INSERT INTO tool_usage_daily_users (usage_date, tool_id, user_id, first_event_at)
    VALUES (v_usage_date, NEW.tool_id, NEW.user_id, NEW.event_timestamp)
    ON CONFLICT DO NOTHING;
    GET DIAGNOSTICS v_unique_user_increment = ROW_COUNT;

    INSERT INTO tool_usage_totals (
        user_id, tool_id, total_events, open_events, close_events, calculate_events,
        save_events, error_events, unique_session_count, total_duration_seconds, last_event_at
    ) VALUES (
        NEW.user_id, NEW.tool_id, 1,
        CASE WHEN NEW.event_type='open' THEN 1 ELSE 0 END,
        CASE WHEN NEW.event_type='close' THEN 1 ELSE 0 END,
        CASE WHEN NEW.event_type='calculate' THEN 1 ELSE 0 END,
        CASE WHEN NEW.event_type='save' THEN 1 ELSE 0 END,
        CASE WHEN NEW.event_type='error' THEN 1 ELSE 0 END,
        CASE WHEN v_new_session THEN 1 ELSE 0 END,
        v_duration,
        NEW.event_timestamp
    )
    ON CONFLICT (user_id, tool_id) DO UPDATE SET
        total_events = tool_usage_totals.total_events + 1,
        open_events = tool_usage_totals.open_events + CASE WHEN NEW.event_type='open' THEN 1 ELSE 0 END,
        close_events = tool_usage_totals.close_events + CASE WHEN NEW.event_type='close' THEN 1 ELSE 0 END,
        calculate_events = tool_usage_totals.calculate_events + CASE WHEN NEW.event_type='calculate' THEN 1 ELSE 0 END,
        save_events = tool_usage_totals.save_events + CASE WHEN NEW.event_type='save' THEN 1 ELSE 0 END,
        error_events = tool_usage_totals.error_events + CASE WHEN NEW.event_type='error' THEN 1 ELSE 0 END,
        unique_session_count = tool_usage_totals.unique_session_count + CASE WHEN v_new_session THEN 1 ELSE 0 END,
        total_duration_seconds = tool_usage_totals.total_duration_seconds + v_duration,
        last_event_at = GREATEST(COALESCE(tool_usage_totals.last_event_at, NEW.event_timestamp), NEW.event_timestamp),
        updated_at = NOW();

    INSERT INTO tool_usage_daily_rollups (
        usage_date, tool_id, total_events, total_sessions, unique_users,
        open_events, close_events, calculate_events, save_events, error_events,
        total_duration_seconds, last_event_at
    ) VALUES (
        v_usage_date, NEW.tool_id, 1,
        CASE WHEN v_new_session THEN 1 ELSE 0 END,
        v_unique_user_increment,
        CASE WHEN NEW.event_type='open' THEN 1 ELSE 0 END,
        CASE WHEN NEW.event_type='close' THEN 1 ELSE 0 END,
        CASE WHEN NEW.event_type='calculate' THEN 1 ELSE 0 END,
        CASE WHEN NEW.event_type='save' THEN 1 ELSE 0 END,
        CASE WHEN NEW.event_type='error' THEN 1 ELSE 0 END,
        v_duration,
        NEW.event_timestamp
    )
    ON CONFLICT (usage_date, tool_id) DO UPDATE SET
        total_events = tool_usage_daily_rollups.total_events + 1,
        total_sessions = tool_usage_daily_rollups.total_sessions + CASE WHEN v_new_session THEN 1 ELSE 0 END,
        unique_users = tool_usage_daily_rollups.unique_users + v_unique_user_increment,
        open_events = tool_usage_daily_rollups.open_events + CASE WHEN NEW.event_type='open' THEN 1 ELSE 0 END,
        close_events = tool_usage_daily_rollups.close_events + CASE WHEN NEW.event_type='close' THEN 1 ELSE 0 END,
        calculate_events = tool_usage_daily_rollups.calculate_events + CASE WHEN NEW.event_type='calculate' THEN 1 ELSE 0 END,
        save_events = tool_usage_daily_rollups.save_events + CASE WHEN NEW.event_type='save' THEN 1 ELSE 0 END,
        error_events = tool_usage_daily_rollups.error_events + CASE WHEN NEW.event_type='error' THEN 1 ELSE 0 END,
        total_duration_seconds = tool_usage_daily_rollups.total_duration_seconds + v_duration,
        last_event_at = GREATEST(tool_usage_daily_rollups.last_event_at, NEW.event_timestamp),
        updated_at = NOW();

    RETURN NEW;
END;
$$;


--
-- Name: get_admin_overview_metrics(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_admin_overview_metrics(p_days integer DEFAULT 30) RETURNS TABLE(total_users bigint, active_users bigint, session_count bigint, avg_session_duration_seconds double precision, tool_event_count bigint, feedback_count bigint, country_count bigint, last_activity timestamp with time zone)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
    v_window INTERVAL;
    v_total_users BIGINT;
    v_active_users BIGINT;
    v_session_count BIGINT;
    v_avg_duration DOUBLE PRECISION;
    v_tool_events BIGINT;
    v_feedback_count BIGINT;
    v_country_count BIGINT;
    v_last_activity TIMESTAMPTZ;
BEGIN
    v_window := INTERVAL '1 day' * GREATEST(p_days, 1);

    SELECT COUNT(*)::BIGINT INTO v_total_users FROM users;

    SELECT COUNT(DISTINCT user_id)::BIGINT INTO v_active_users
    FROM app_sessions
    WHERE start_time >= NOW() - v_window;

    SELECT COUNT(*)::BIGINT INTO v_session_count
    FROM app_sessions
    WHERE start_time >= NOW() - v_window;

    SELECT COALESCE(AVG(EXTRACT(EPOCH FROM (COALESCE(end_time, NOW()) - start_time))), 0::DOUBLE PRECISION)
    INTO v_avg_duration
    FROM app_sessions
    WHERE start_time >= NOW() - v_window;

    SELECT COUNT(*)::BIGINT INTO v_tool_events
    FROM tool_usage_events
    WHERE event_timestamp >= NOW() - v_window;

    SELECT COUNT(*)::BIGINT INTO v_feedback_count
    FROM feedbacks
    WHERE submitted_at >= NOW() - v_window;

    SELECT COUNT(DISTINCT country)::BIGINT INTO v_country_count
    FROM app_sessions
    WHERE start_time >= NOW() - v_window AND country IS NOT NULL;

    SELECT MAX(event_timestamp) INTO v_last_activity
    FROM tool_usage_events;

    RETURN QUERY SELECT
        v_total_users,
        v_active_users,
        v_session_count,
        v_avg_duration,
        v_tool_events,
        v_feedback_count,
        v_country_count,
        v_last_activity;
END;
$$;


--
-- Name: get_carousel_announcements(text, text, text, text, text, text, text, boolean, text, text, text, text, boolean, integer, boolean); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_carousel_announcements(p_user_id text, p_device_id text DEFAULT NULL::text, p_auth_uid text DEFAULT NULL::text, p_platform text DEFAULT NULL::text, p_app_version text DEFAULT NULL::text, p_country text DEFAULT NULL::text, p_city text DEFAULT NULL::text, p_is_logged_in boolean DEFAULT false, p_profession text DEFAULT NULL::text, p_speciality text DEFAULT NULL::text, p_degree text DEFAULT NULL::text, p_experience text DEFAULT NULL::text, p_has_complete_profile boolean DEFAULT false, p_session_number integer DEFAULT 1, p_is_real_device boolean DEFAULT NULL::boolean) RETURNS TABLE(id uuid, title text, message text, body text, surface text, importance text, kind text, priority text, action_type text, action_value text, dismissible boolean, dismissible_mode text, remind_later_count integer, remind_later_sessions integer, repeat_mode text, repeat_interval_hours integer, repeat_session_interval integer, first_view_session_delay integer, max_times_seen_per_user integer, metadata jsonb, questions jsonb, user_status text, impression_count integer, is_partially_completed boolean, questions_answered integer, display_sequence integer, disappear_after_cta boolean, last_seen_session integer, defer_count integer, defer_until_session integer, first_seen_at timestamp with time zone, last_seen_at timestamp with time zone, is_read boolean, carousel_position integer)
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    v_max_items INTEGER;
BEGIN
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
                    CASE e.importance WHEN 'high' THEN 1 WHEN 'medium' THEN 2 WHEN 'low' THEN 3 END,
                    e.display_sequence ASC NULLS LAST,
                    CASE WHEN e.is_partially_completed THEN 0 ELSE 1 END,
                    e.id DESC
            ) AS pos
        FROM get_eligible_announcements(
            p_user_id, p_device_id, p_auth_uid, p_platform, p_app_version,
            p_country, p_city, p_is_logged_in, p_profession, p_speciality,
            p_degree, p_experience, p_has_complete_profile, p_session_number,
            'home_banner', p_is_real_device, 100, 0
        ) e
        WHERE e.surface IN ('home_banner', 'modal')
    )
    SELECT 
        eligible.id, eligible.title, eligible.message, eligible.body,
        eligible.surface, eligible.importance, eligible.kind, eligible.priority,
        eligible.action_type, eligible.action_value, eligible.dismissible,
        eligible.dismissible_mode, eligible.remind_later_count, eligible.remind_later_sessions,
        eligible.repeat_mode, eligible.repeat_interval_hours, eligible.repeat_session_interval,
        eligible.first_view_session_delay, eligible.max_times_seen_per_user,
        eligible.metadata, eligible.questions,
        eligible.user_status, eligible.impression_count, eligible.is_partially_completed,
        eligible.questions_answered, eligible.display_sequence,
        eligible.disappear_after_cta, eligible.last_seen_session, eligible.defer_count,
        eligible.defer_until_session, eligible.first_seen_at, eligible.last_seen_at,
        eligible.is_read, eligible.pos::INTEGER AS carousel_position
    FROM eligible
    WHERE eligible.pos <= v_max_items;
END;
$$;


--
-- Name: get_current_user_firebase_uid(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_current_user_firebase_uid() RETURNS text
    LANGUAGE sql STABLE
    AS $$
  SELECT COALESCE(
    (current_setting('request.jwt.claims', true)::json ->> 'sub'),
    ''
  );
$$;


--
-- Name: get_eligible_announcements(text, text, text, text, text, text, text, boolean, text, text, text, text, boolean, integer, text, boolean, integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_eligible_announcements(p_user_id text, p_device_id text DEFAULT NULL::text, p_auth_uid text DEFAULT NULL::text, p_platform text DEFAULT NULL::text, p_app_version text DEFAULT NULL::text, p_country text DEFAULT NULL::text, p_city text DEFAULT NULL::text, p_is_logged_in boolean DEFAULT false, p_profession text DEFAULT NULL::text, p_speciality text DEFAULT NULL::text, p_degree text DEFAULT NULL::text, p_experience text DEFAULT NULL::text, p_has_complete_profile boolean DEFAULT false, p_session_number integer DEFAULT 1, p_surface text DEFAULT 'home_banner'::text, p_is_real_device boolean DEFAULT NULL::boolean, p_limit integer DEFAULT 10, p_offset integer DEFAULT 0) RETURNS TABLE(id uuid, title text, message text, body text, surface text, importance text, kind text, priority text, action_type text, action_value text, dismissible boolean, dismissible_mode text, remind_later_count integer, remind_later_sessions integer, repeat_mode text, repeat_interval_hours integer, repeat_session_interval integer, first_view_session_delay integer, max_times_seen_per_user integer, metadata jsonb, questions jsonb, user_status text, impression_count integer, is_partially_completed boolean, questions_answered integer, display_sequence integer, disappear_after_cta boolean, last_seen_session integer, defer_count integer, defer_until_session integer, first_seen_at timestamp with time zone, last_seen_at timestamp with time zone, is_read boolean)
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    v_effective_user_id TEXT;
BEGIN
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
        COALESCE(a.remind_later_count, 3) AS remind_later_count,
        COALESCE(a.remind_later_sessions, 1) AS remind_later_sessions,
        COALESCE(a.repeat_mode, 'once') AS repeat_mode,
        a.repeat_interval_hours,
        COALESCE(a.repeat_session_interval, 1) AS repeat_session_interval,
        COALESCE(a.first_view_session_delay, 0) AS first_view_session_delay,
        a.max_times_seen_per_user,
        a.metadata,
        a.questions,
        COALESCE(uas.status, 'eligible') AS user_status,
        COALESCE(uas.impression_count, 0) AS impression_count,
        COALESCE(uas.is_partially_completed, FALSE) AS is_partially_completed,
        COALESCE(uas.questions_answered, 0) AS questions_answered,
        a.display_sequence,
        COALESCE(a.disappear_after_cta, TRUE) AS disappear_after_cta,
        COALESCE(uas.last_seen_session, 0) AS last_seen_session,
        COALESCE(uas.defer_count, 0) AS defer_count,
        uas.defer_until_session,
        uas.first_seen_at,
        uas.last_seen_at,
        -- CRITICAL FIX: For keep showing mode, only mark as read when dismissed
        CASE 
            WHEN COALESCE(a.disappear_after_cta, TRUE) = FALSE THEN 
                (uas.status = 'dismissed')
            ELSE 
                (COALESCE(uas.impression_count, 0) > 0)
        END AS is_read
    FROM public.announcements a
    LEFT JOIN public.user_announcement_state uas 
        ON uas.announcement_id = a.id 
        AND uas.user_id = v_effective_user_id
    WHERE 
        a.is_deleted = FALSE
        AND (
            -- INBOX
            (
                p_surface = 'inbox' 
                AND a.surface IN ('home_banner', 'modal', 'inbox')
                AND (
                    uas.status IS NOT NULL
                    OR (
                        a.is_active = TRUE
                        AND (a.status = 'live' OR a.status = 'published' OR a.status IS NULL)
                        AND a.start_at <= NOW()
                        AND (a.end_at IS NULL OR a.end_at > NOW())
                    )
                )
            )
            -- OTHER SURFACES
            OR (
                p_surface != 'inbox'
                AND a.is_active = TRUE
                AND (a.status = 'live' OR a.status = 'published' OR a.status IS NULL)
                AND a.start_at <= NOW()
                AND (a.end_at IS NULL OR a.end_at > NOW())
                AND (a.surface = p_surface OR a.surface = 'modal')
            )
        )
        
        -- TARGETING FILTERS
        AND (a.target_logged_in_only = FALSE OR p_is_logged_in = TRUE)
        AND (a.target_anonymous_only = FALSE OR p_is_logged_in = FALSE)
        AND (a.target_incomplete_profile = FALSE OR p_has_complete_profile = FALSE)
        AND (
            (a.target_country IS NULL OR a.target_country = '')
            OR (COALESCE(a.target_country_exclude, FALSE) = FALSE AND p_country = ANY(string_to_array(a.target_country, ',')))
            OR (a.target_country_exclude = TRUE AND (p_country IS NULL OR p_country NOT IN (SELECT unnest(string_to_array(a.target_country, ',')))))
        )
        AND (
            (a.target_city IS NULL OR a.target_city = '')
            OR (COALESCE(a.target_city_exclude, FALSE) = FALSE AND p_city = ANY(string_to_array(a.target_city, ',')))
            OR (a.target_city_exclude = TRUE AND (p_city IS NULL OR p_city NOT IN (SELECT unnest(string_to_array(a.target_city, ',')))))
        )
        AND (
            (a.target_profession IS NULL OR a.target_profession = '')
            OR (COALESCE(a.target_profession_exclude, FALSE) = FALSE AND p_profession = ANY(string_to_array(a.target_profession, ',')))
            OR (a.target_profession_exclude = TRUE AND (p_profession IS NULL OR p_profession NOT IN (SELECT unnest(string_to_array(a.target_profession, ',')))))
        )
        AND (
            (a.target_speciality IS NULL OR a.target_speciality = '')
            OR (COALESCE(a.target_speciality_exclude, FALSE) = FALSE AND p_speciality = ANY(string_to_array(a.target_speciality, ',')))
            OR (a.target_speciality_exclude = TRUE AND (p_speciality IS NULL OR p_speciality NOT IN (SELECT unnest(string_to_array(a.target_speciality, ',')))))
        )
        AND (
            (a.target_degree IS NULL OR a.target_degree = '')
            OR (COALESCE(a.target_degree_exclude, FALSE) = FALSE AND p_degree = ANY(string_to_array(a.target_degree, ',')))
            OR (a.target_degree_exclude = TRUE AND (p_degree IS NULL OR p_degree NOT IN (SELECT unnest(string_to_array(a.target_degree, ',')))))
        )
        AND (
            (a.target_years_experience IS NULL OR a.target_years_experience = '')
            OR (COALESCE(a.target_experience_exclude, FALSE) = FALSE AND p_experience = ANY(string_to_array(a.target_years_experience, ',')))
            OR (a.target_experience_exclude = TRUE AND (p_experience IS NULL OR p_experience NOT IN (SELECT unnest(string_to_array(a.target_years_experience, ',')))))
        )
        AND (a.target_platform IS NULL OR a.target_platform = '' OR p_platform = ANY(string_to_array(a.target_platform, ',')))
        
        -- DEVICE TYPE FILTER
        -- For inbox: show if user has interacted with it OR it matches current device filter
        -- For other surfaces: only show if matches current device filter
        AND (
            (p_surface = 'inbox' AND uas.status IS NOT NULL)
            OR a.target_is_real_device IS NULL
            OR (p_is_real_device IS NOT NULL AND a.target_is_real_device = p_is_real_device)
        )
        
        -- FIRST VIEW SESSION DELAY
        AND (
            p_surface = 'inbox'
            OR uas.status IS NOT NULL
            OR COALESCE(a.first_view_session_delay, 0) = 0
            OR p_session_number >= COALESCE(a.first_view_session_delay, 0)
        )
        
        -- ELIGIBILITY LOGIC
        AND (
            p_surface = 'inbox'
            OR uas.status IS NULL
            OR uas.status = 'eligible'
            -- SEEN: normal repeat mode (NOT for remind_later with defer_count > 0)
            OR (
                uas.status = 'seen'
                AND NOT (a.dismissible_mode = 'remind_later' AND COALESCE(uas.defer_count, 0) > 0)
                AND COALESCE(a.repeat_mode, 'once') = 'per_app_open'
                AND (p_session_number - COALESCE(uas.last_seen_session, 0)) >= COALESCE(a.repeat_session_interval, 1)
            )
            OR (
                uas.status = 'seen'
                AND NOT (a.dismissible_mode = 'remind_later' AND COALESCE(uas.defer_count, 0) > 0)
                AND COALESCE(a.repeat_mode, 'once') = 'interval_hours'
                AND (uas.last_seen_at IS NULL OR (NOW() - uas.last_seen_at) >= (COALESCE(a.repeat_interval_hours, 24) * INTERVAL '1 hour'))
            )
            -- DEFERRED: show when session >= defer_until_session AND defer_count < remind_later_count
            OR (
                uas.status = 'deferred'
                AND COALESCE(uas.defer_count, 0) < COALESCE(a.remind_later_count, 3)
                AND (uas.defer_until_session IS NULL OR p_session_number >= uas.defer_until_session)
            )
        )
        
        -- MAX VIEWS CHECK - Skip for remind_later mode
        AND (
            p_surface = 'inbox'
            OR (a.dismissible_mode = 'remind_later' AND uas.status = 'deferred')
            OR a.max_times_seen_per_user IS NULL
            OR a.max_times_seen_per_user = 0
            OR COALESCE(uas.impression_count, 0) < a.max_times_seen_per_user
        )
        
        -- REMIND LATER EXHAUSTED - Stop when defer_count >= remind_later_count
        AND (
            p_surface = 'inbox'
            OR a.dismissible_mode != 'remind_later'
            OR uas.status != 'deferred'
            OR COALESCE(uas.defer_count, 0) < COALESCE(a.remind_later_count, 3)
        )
        
        -- DISAPPEAR AFTER CTA
        AND (
            p_surface = 'inbox'
            OR COALESCE(a.disappear_after_cta, TRUE) = FALSE
            OR uas.status IS NULL
            OR uas.status != 'completed'
        )
        
        -- EXCLUDE DISMISSED
        AND (
            p_surface = 'inbox'
            OR uas.status IS NULL
            OR uas.status != 'dismissed'
        )
        
    ORDER BY 
        CASE WHEN p_surface = 'inbox' THEN 
            CASE WHEN COALESCE(uas.impression_count, 0) = 0 THEN 0 ELSE 1 END
        ELSE 0 END,
        CASE a.importance WHEN 'high' THEN 1 WHEN 'medium' THEN 2 WHEN 'low' THEN 3 END,
        a.display_sequence ASC NULLS LAST,
        a.created_at DESC
    LIMIT p_limit
    OFFSET p_offset;
END;
$$;


--
-- Name: get_eligible_announcements_fast(text, text, text, text, text, text, text, boolean, text, text, text, text, boolean, integer, text, integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_eligible_announcements_fast(p_user_id text, p_device_id text DEFAULT NULL::text, p_auth_uid text DEFAULT NULL::text, p_platform text DEFAULT NULL::text, p_app_version text DEFAULT NULL::text, p_country text DEFAULT NULL::text, p_city text DEFAULT NULL::text, p_is_logged_in boolean DEFAULT false, p_profession text DEFAULT NULL::text, p_speciality text DEFAULT NULL::text, p_degree text DEFAULT NULL::text, p_experience text DEFAULT NULL::text, p_has_complete_profile boolean DEFAULT false, p_session_number integer DEFAULT 1, p_surface text DEFAULT 'home_banner'::text, p_limit integer DEFAULT 10, p_offset integer DEFAULT 0) RETURNS TABLE(id uuid, title text, message text, body text, surface text, importance text, kind text, priority text, action_type text, action_value text, dismissible boolean, dismissible_mode text, metadata jsonb, questions jsonb, user_status text, impression_count integer, is_partially_completed boolean, questions_answered integer, display_sequence integer)
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    v_effective_user_id TEXT;
BEGIN
    -- Determine effective user ID (prefer auth_uid, fallback to device_id)
    v_effective_user_id := COALESCE(p_auth_uid, p_device_id, p_user_id);
    
    RETURN QUERY
    WITH filtered_announcements AS (
        SELECT a.*
        FROM public.announcements a
        WHERE 
            -- Use the optimized index
            a.is_active = TRUE
            AND a.is_deleted = FALSE
            AND a.status = 'live'
            AND (a.surface = p_surface OR a.surface = 'modal')
            AND a.start_at <= NOW()
            AND (a.end_at IS NULL OR a.end_at > NOW())
            
            -- Platform targeting (simple check first)
            AND (a.target_platform IS NULL OR a.target_platform = 'all' OR a.target_platform = p_platform)
            
            -- Login state targeting (simple boolean check)
            AND (
                (a.target_logged_in_only = FALSE AND a.target_anonymous_only = FALSE)
                OR (a.target_logged_in_only = TRUE AND p_is_logged_in = TRUE)
                OR (a.target_anonymous_only = TRUE AND p_is_logged_in = FALSE)
            )
            
            -- Incomplete profile targeting (simple boolean check)
            AND (
                a.target_incomplete_profile = FALSE
                OR (a.target_incomplete_profile = TRUE AND p_has_complete_profile = FALSE)
            )
    ),
    user_state_filtered AS (
        SELECT 
            fa.*,
            uas.status,
            uas.impression_count,
            uas.is_partially_completed,
            uas.questions_answered,
            uas.defer_until_session,
            uas.defer_until_time
        FROM filtered_announcements fa
        LEFT JOIN public.user_announcement_state uas 
            ON uas.announcement_id = fa.id 
            AND uas.user_id = v_effective_user_id
        WHERE 
            -- User state filtering
            (
                uas.status IS NULL  -- Never seen
                OR uas.status = 'eligible'
                OR uas.status = 'seen'
                OR (uas.status = 'deferred' AND (
                    (uas.defer_until_session IS NOT NULL AND uas.defer_until_session <= p_session_number)
                    OR (uas.defer_until_time IS NOT NULL AND uas.defer_until_time <= NOW())
                ))
                OR (uas.status = 'completed' AND fa.repeat_mode != 'once')
            )
            AND uas.status IS DISTINCT FROM 'dismissed'
            AND uas.status IS DISTINCT FROM 'expired'
            
            -- Max impressions check
            AND (fa.max_times_seen_per_user IS NULL OR COALESCE(uas.impression_count, 0) < fa.max_times_seen_per_user)
    ),
    targeting_filtered AS (
        SELECT usf.*
        FROM user_state_filtered usf
        WHERE 
            -- Country targeting (with exclusion support)
            (
                (usf.target_country IS NULL OR usf.target_country = '')
                OR (
                    usf.target_country_exclude = FALSE 
                    AND p_country = ANY(string_to_array(usf.target_country, ','))
                )
                OR (
                    usf.target_country_exclude = TRUE 
                    AND (p_country IS NULL OR p_country NOT IN (SELECT unnest(string_to_array(usf.target_country, ','))))
                )
            )
            
            -- City targeting (with exclusion support)
            AND (
                (usf.target_city IS NULL OR usf.target_city = '')
                OR (
                    usf.target_city_exclude = FALSE 
                    AND p_city = ANY(string_to_array(usf.target_city, ','))
                )
                OR (
                    usf.target_city_exclude = TRUE 
                    AND (p_city IS NULL OR p_city NOT IN (SELECT unnest(string_to_array(usf.target_city, ','))))
                )
            )
            
            -- Profession targeting (with exclusion support)
            AND (
                (usf.target_profession IS NULL OR usf.target_profession = '')
                OR (
                    usf.target_profession_exclude = FALSE 
                    AND p_profession = ANY(string_to_array(usf.target_profession, ','))
                )
                OR (
                    usf.target_profession_exclude = TRUE 
                    AND (p_profession IS NULL OR p_profession NOT IN (SELECT unnest(string_to_array(usf.target_profession, ','))))
                )
            )
            
            -- Speciality targeting (with exclusion support)
            AND (
                (usf.target_speciality IS NULL OR usf.target_speciality = '')
                OR (
                    usf.target_speciality_exclude = FALSE 
                    AND p_speciality = ANY(string_to_array(usf.target_speciality, ','))
                )
                OR (
                    usf.target_speciality_exclude = TRUE 
                    AND (p_speciality IS NULL OR p_speciality NOT IN (SELECT unnest(string_to_array(usf.target_speciality, ','))))
                )
            )
            
            -- Degree targeting (with exclusion support)
            AND (
                (usf.target_degree IS NULL OR usf.target_degree = '')
                OR (
                    COALESCE(usf.target_degree_exclude, FALSE) = FALSE 
                    AND p_degree = ANY(string_to_array(usf.target_degree, ','))
                )
                OR (
                    usf.target_degree_exclude = TRUE 
                    AND (p_degree IS NULL OR p_degree NOT IN (SELECT unnest(string_to_array(usf.target_degree, ','))))
                )
            )
            
            -- Experience targeting (with exclusion support)
            AND (
                (usf.target_experience IS NULL OR usf.target_experience = '')
                OR (
                    COALESCE(usf.target_experience_exclude, FALSE) = FALSE 
                    AND p_experience = ANY(string_to_array(usf.target_experience, ','))
                )
                OR (
                    usf.target_experience_exclude = TRUE 
                    AND (p_experience IS NULL OR p_experience NOT IN (SELECT unnest(string_to_array(usf.target_experience, ','))))
                )
            )
    )
    SELECT 
        tf.id,
        tf.title,
        tf.message,
        tf.body,
        tf.surface,
        tf.importance,
        tf.kind,
        tf.priority,
        tf.action_type,
        tf.action_value,
        tf.dismissible,
        tf.dismissible_mode,
        tf.metadata,
        tf.questions,
        COALESCE(tf.status, 'eligible') AS user_status,
        COALESCE(tf.impression_count, 0) AS impression_count,
        COALESCE(tf.is_partially_completed, FALSE) AS is_partially_completed,
        COALESCE(tf.questions_answered, 0) AS questions_answered,
        tf.display_sequence
    FROM targeting_filtered tf
    ORDER BY 
        -- Priority ordering: high > medium > low importance
        CASE tf.importance 
            WHEN 'high' THEN 1 
            WHEN 'medium' THEN 2 
            WHEN 'low' THEN 3 
        END,
        -- Within same importance, use display_sequence (admin-controlled)
        tf.display_sequence ASC NULLS LAST,
        -- Then by creation date (newest first for low importance)
        tf.created_at DESC
    LIMIT p_limit
    OFFSET p_offset;
END;
$$;


--
-- Name: get_inbox_announcements(text, text, text, text, text, text, boolean, text, text, text, text, boolean, integer, boolean, integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_inbox_announcements(p_user_id text, p_device_id text DEFAULT NULL::text, p_auth_uid text DEFAULT NULL::text, p_platform text DEFAULT NULL::text, p_country text DEFAULT NULL::text, p_city text DEFAULT NULL::text, p_is_logged_in boolean DEFAULT false, p_profession text DEFAULT NULL::text, p_speciality text DEFAULT NULL::text, p_degree text DEFAULT NULL::text, p_experience text DEFAULT NULL::text, p_has_complete_profile boolean DEFAULT false, p_session_number integer DEFAULT 1, p_is_real_device boolean DEFAULT NULL::boolean, p_page integer DEFAULT 1, p_page_size integer DEFAULT 20) RETURNS TABLE(id uuid, title text, message text, body text, surface text, importance text, kind text, priority text, action_type text, action_value text, dismissible boolean, dismissible_mode text, remind_later_count integer, remind_later_sessions integer, repeat_mode text, repeat_interval_hours integer, repeat_session_interval integer, first_view_session_delay integer, max_times_seen_per_user integer, metadata jsonb, questions jsonb, user_status text, impression_count integer, is_partially_completed boolean, questions_answered integer, display_sequence integer, disappear_after_cta boolean, last_seen_session integer, defer_count integer, defer_until_session integer, first_seen_at timestamp with time zone, last_seen_at timestamp with time zone, is_read boolean, total_count bigint)
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    v_offset INTEGER;
    v_total BIGINT;
BEGIN
    v_offset := (p_page - 1) * p_page_size;
    
    -- Get total count
    SELECT COUNT(*) INTO v_total
    FROM get_eligible_announcements(
        p_user_id, p_device_id, p_auth_uid, p_platform, NULL,
        p_country, p_city, p_is_logged_in, p_profession, p_speciality,
        p_degree, p_experience, p_has_complete_profile,
        p_session_number, 'inbox', p_is_real_device, 1000, 0
    );
    
    -- Get paginated results
    RETURN QUERY
    SELECT 
        e.id, e.title, e.message, e.body, e.surface, e.importance,
        e.kind, e.priority, e.action_type, e.action_value, e.dismissible,
        e.dismissible_mode, e.remind_later_count, e.remind_later_sessions,
        e.repeat_mode, e.repeat_interval_hours, e.repeat_session_interval,
        e.first_view_session_delay, e.max_times_seen_per_user,
        e.metadata, e.questions, e.user_status,
        e.impression_count, e.is_partially_completed, e.questions_answered,
        e.display_sequence, e.disappear_after_cta, e.last_seen_session,
        e.defer_count, e.defer_until_session, e.first_seen_at, e.last_seen_at,
        e.is_read, v_total AS total_count
    FROM get_eligible_announcements(
        p_user_id, p_device_id, p_auth_uid, p_platform, NULL,
        p_country, p_city, p_is_logged_in, p_profession, p_speciality,
        p_degree, p_experience, p_has_complete_profile,
        p_session_number, 'inbox', p_is_real_device, p_page_size, v_offset
    ) e
    ORDER BY
        -- Unread first (is_read = false first)
        e.is_read ASC,
        -- Then by importance
        CASE e.importance WHEN 'high' THEN 1 WHEN 'medium' THEN 2 WHEN 'low' THEN 3 END,
        -- Then by most recently seen
        e.last_seen_at DESC NULLS LAST;
END;
$$;


--
-- Name: get_targeted_announcements(text, text, text, text, text, text, boolean, text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_targeted_announcements(p_user_auth_uid text, p_surface text DEFAULT NULL::text, p_app_version text DEFAULT NULL::text, p_platform text DEFAULT NULL::text, p_country text DEFAULT NULL::text, p_city text DEFAULT NULL::text, p_is_real_device boolean DEFAULT NULL::boolean, p_device_brand text DEFAULT NULL::text, p_ip_address text DEFAULT NULL::text) RETURNS TABLE(id uuid, title text, message text, kind text, surface text, importance text, action_type text, action_value text, dismissible boolean, dismissible_mode text, remind_later_count integer, remind_later_sessions integer, repeat_mode text, repeat_interval_hours integer, max_times_seen_per_user integer, metadata jsonb, questions jsonb, created_at timestamp with time zone, updated_at timestamp with time zone, start_at timestamp with time zone, end_at timestamp with time zone, version integer)
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    AS $$
DECLARE
    v_user RECORD;
    v_is_logged_in BOOLEAN;
BEGIN
    -- Get user data including insights and last location
    SELECT 
        u.is_anonymous,
        u.insights,
        COALESCE(p_country, u.last_country) as effective_country,
        COALESCE(p_city, u.last_city) as effective_city,
        COALESCE(p_platform, u.last_platform) as effective_platform,
        COALESCE(p_is_real_device, u.last_is_real_device) as effective_is_real_device,
        COALESCE(p_device_brand, u.last_device_brand) as effective_device_brand,
        COALESCE(p_ip_address, u.last_ip) as effective_ip
    INTO v_user
    FROM public.users u
    WHERE u.auth_uid = p_user_auth_uid;
    
    -- Determine login status
    v_is_logged_in := v_user IS NOT NULL AND NOT COALESCE(v_user.is_anonymous, true);
    
    RETURN QUERY
    SELECT 
        a.id,
        a.title,
        a.message,
        a.kind,
        a.surface,
        a.importance,
        a.action_type,
        a.action_value,
        a.dismissible,
        a.dismissible_mode,
        a.remind_later_count,
        a.remind_later_sessions,
        a.repeat_mode,
        a.repeat_interval_hours,
        a.max_times_seen_per_user,
        a.metadata,
        a.questions,
        a.created_at,
        a.updated_at,
        a.start_at,
        a.end_at,
        a.version
    FROM public.announcements a
    WHERE 
        -- Basic filters
        a.is_active = TRUE
        AND a.is_deleted = FALSE
        AND a.start_at <= NOW()
        AND (a.end_at IS NULL OR a.end_at > NOW())
        
        -- Surface filter (if specified)
        AND (p_surface IS NULL OR a.surface = p_surface)
        
        -- Login status targeting
        AND (
            (a.target_logged_in_only = FALSE AND a.target_anonymous_only = FALSE)
            OR (a.target_logged_in_only = TRUE AND v_is_logged_in = TRUE)
            OR (a.target_anonymous_only = TRUE AND v_is_logged_in = FALSE)
        )
        
        -- App version targeting
        AND (
            a.target_min_app_version IS NULL 
            OR a.target_min_app_version = '' 
            OR p_app_version IS NULL
            OR p_app_version >= a.target_min_app_version
        )
        AND (
            a.target_max_app_version IS NULL 
            OR a.target_max_app_version = '' 
            OR p_app_version IS NULL
            OR p_app_version <= a.target_max_app_version
        )
        
        -- Country targeting (using full country names from IP geolocation)
        AND (
            a.target_country IS NULL 
            OR a.target_country = ''
            OR v_user.effective_country IS NULL
            OR EXISTS (
                SELECT 1 FROM unnest(string_to_array(v_user.effective_country, ',')) AS user_country
                WHERE TRIM(LOWER(user_country)) = ANY(
                    SELECT TRIM(LOWER(c)) FROM unnest(string_to_array(a.target_country, ',')) c
                )
            )
        )
        
        -- City targeting (both target and user can have multiple values)
        AND (
            a.target_city IS NULL 
            OR a.target_city = ''
            OR v_user.effective_city IS NULL
            OR EXISTS (
                SELECT 1 FROM unnest(string_to_array(v_user.effective_city, ',')) AS user_city
                WHERE TRIM(LOWER(user_city)) = ANY(
                    SELECT TRIM(LOWER(c)) FROM unnest(string_to_array(a.target_city, ',')) c
                )
            )
        )
        
        -- Platform targeting (both target and user can have multiple values)
        AND (
            a.target_platform IS NULL 
            OR a.target_platform = '' 
            OR a.target_platform = 'all'
            OR v_user.effective_platform IS NULL
            OR EXISTS (
                SELECT 1 FROM unnest(string_to_array(v_user.effective_platform, ',')) AS user_platform
                WHERE TRIM(LOWER(user_platform)) = ANY(
                    SELECT TRIM(LOWER(p)) FROM unnest(string_to_array(a.target_platform, ',')) p
                )
            )
        )
        
        -- Real device targeting
        AND (
            a.target_is_real_device IS NULL
            OR v_user.effective_is_real_device IS NULL
            OR a.target_is_real_device = v_user.effective_is_real_device
        )
        
        -- Device brand targeting (both target and user can have multiple values)
        AND (
            a.target_device_brand IS NULL 
            OR a.target_device_brand = ''
            OR v_user.effective_device_brand IS NULL
            OR EXISTS (
                SELECT 1 FROM unnest(string_to_array(v_user.effective_device_brand, ',')) AS user_brand
                WHERE TRIM(LOWER(user_brand)) = ANY(
                    SELECT TRIM(LOWER(b)) FROM unnest(string_to_array(a.target_device_brand, ',')) b
                )
            )
        )
        
        -- IP address targeting (for testing, both target and user can have multiple values)
        AND (
            a.target_ip_addresses IS NULL 
            OR a.target_ip_addresses = ''
            OR v_user.effective_ip IS NULL
            OR EXISTS (
                SELECT 1 FROM unnest(string_to_array(v_user.effective_ip, ',')) AS user_ip
                WHERE TRIM(user_ip) = ANY(
                    SELECT TRIM(ip) FROM unnest(string_to_array(a.target_ip_addresses, ',')) ip
                )
            )
        )
        
        -- Specialty targeting (user can have multiple specialties, check if ANY match)
        AND (
            a.target_speciality IS NULL 
            OR a.target_speciality = ''
            OR v_user.insights IS NULL
            OR v_user.insights->>'specialty' IS NULL
            OR EXISTS (
                SELECT 1 FROM unnest(string_to_array(v_user.insights->>'specialty', ',')) AS user_spec
                WHERE TRIM(LOWER(user_spec)) = ANY(
                    SELECT TRIM(LOWER(s)) FROM unnest(string_to_array(a.target_speciality, ',')) s
                )
            )
        )
        
        -- Subspecialty targeting (user can have multiple subspecialties, check if ANY match)
        AND (
            a.target_subspecialty IS NULL 
            OR a.target_subspecialty = ''
            OR v_user.insights IS NULL
            OR v_user.insights->>'subspecialty' IS NULL
            OR EXISTS (
                SELECT 1 FROM unnest(string_to_array(v_user.insights->>'subspecialty', ',')) AS user_sub
                WHERE TRIM(LOWER(user_sub)) = ANY(
                    SELECT TRIM(LOWER(s)) FROM unnest(string_to_array(a.target_subspecialty, ',')) s
                )
            )
        )
        
        -- Degree targeting (user can have multiple degrees, check if ANY match)
        AND (
            a.target_degree IS NULL 
            OR a.target_degree = ''
            OR v_user.insights IS NULL
            OR v_user.insights->>'degree' IS NULL
            OR EXISTS (
                SELECT 1 FROM unnest(string_to_array(v_user.insights->>'degree', ',')) AS user_deg
                WHERE TRIM(LOWER(user_deg)) = ANY(
                    SELECT TRIM(LOWER(d)) FROM unnest(string_to_array(a.target_degree, ',')) d
                )
            )
        )
        
        -- Profession targeting (user can have multiple professions, check if ANY match)
        AND (
            a.target_profession IS NULL 
            OR a.target_profession = ''
            OR v_user.insights IS NULL
            OR v_user.insights->>'profession' IS NULL
            OR EXISTS (
                SELECT 1 FROM unnest(string_to_array(v_user.insights->>'profession', ',')) AS user_prof
                WHERE TRIM(LOWER(user_prof)) = ANY(
                    SELECT TRIM(LOWER(p)) FROM unnest(string_to_array(a.target_profession, ',')) p
                )
            )
        )
        
        -- Years Experience targeting (user can have multiple values, check if ANY match)
        AND (
            a.target_years_experience IS NULL 
            OR a.target_years_experience = ''
            OR v_user.insights IS NULL
            OR v_user.insights->>'years_experience' IS NULL
            OR EXISTS (
                SELECT 1 FROM unnest(string_to_array(v_user.insights->>'years_experience', ',')) AS user_exp
                WHERE TRIM(LOWER(user_exp)) = ANY(
                    SELECT TRIM(LOWER(e)) FROM unnest(string_to_array(a.target_years_experience, ',')) e
                )
            )
        )
        
        -- Hospital targeting (partial match - checks if ANY target hospital is contained in user's hospital)
        AND (
            a.target_hospital IS NULL 
            OR a.target_hospital = ''
            OR v_user.insights IS NULL
            OR v_user.insights->>'hospital' IS NULL
            OR EXISTS (
                SELECT 1 FROM unnest(string_to_array(a.target_hospital, ',')) AS target_hosp
                WHERE LOWER(v_user.insights->>'hospital') LIKE '%' || TRIM(LOWER(target_hosp)) || '%'
            )
        )
        
    ORDER BY 
        CASE a.importance 
            WHEN 'high' THEN 1 
            WHEN 'medium' THEN 2 
            ELSE 3 
        END,
        a.created_at DESC;
END;
$$;


--
-- Name: get_tool_usage_by_period(timestamp with time zone, timestamp with time zone, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_tool_usage_by_period(p_start_date timestamp with time zone, p_end_date timestamp with time zone, p_tool_id text DEFAULT NULL::text) RETURNS TABLE(period_date date, tool_id text, usage_count bigint, unique_users bigint, calculate_events bigint)
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        DATE(t.event_timestamp) as period_date,
        t.tool_id,
        COUNT(DISTINCT t.tool_session_id) as usage_count,
        COUNT(DISTINCT t.user_id) as unique_users,
        COUNT(CASE WHEN t.event_type = 'calculate' THEN 1 END) as calculate_events
    FROM tool_usage_events t
    WHERE t.event_timestamp >= p_start_date
        AND t.event_timestamp < p_end_date
        AND (p_tool_id IS NULL OR t.tool_id = p_tool_id)
    GROUP BY DATE(t.event_timestamp), t.tool_id
    ORDER BY period_date DESC, usage_count DESC;
END;
$$;


--
-- Name: get_tool_usage_cities(text, integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_tool_usage_cities(p_tool_id text, p_days integer DEFAULT 30, p_limit integer DEFAULT 10) RETURNS TABLE(country text, city text, events bigint, unique_users bigint, unique_sessions bigint, last_event_at timestamp with time zone)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
    v_window INTERVAL := make_interval(days => GREATEST(p_days, 1));
BEGIN
    RETURN QUERY
    SELECT
        COALESCE(e.country, 'Unknown')::TEXT AS country,
        COALESCE(e.city, 'Unknown')::TEXT AS city,
        COUNT(*)::BIGINT AS events,
        COUNT(DISTINCT e.user_id)::BIGINT AS unique_users,
        COUNT(DISTINCT e.tool_session_id)::BIGINT AS unique_sessions,
        MAX(e.event_timestamp)::TIMESTAMPTZ AS last_event_at
    FROM tool_usage_events e
    WHERE e.tool_id = p_tool_id
      AND e.event_timestamp >= NOW() - v_window
    GROUP BY COALESCE(e.country, 'Unknown'), COALESCE(e.city, 'Unknown')
    ORDER BY events DESC
    LIMIT COALESCE(p_limit, 10);
END;
$$;


--
-- Name: get_tool_usage_countries(text, integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_tool_usage_countries(p_tool_id text, p_days integer DEFAULT 30, p_limit integer DEFAULT 10) RETURNS TABLE(country text, events bigint, unique_users bigint, unique_sessions bigint, last_event_at timestamp with time zone)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
    v_window INTERVAL := make_interval(days => GREATEST(p_days, 1));
BEGIN
    RETURN QUERY
    SELECT
        COALESCE(e.country, 'Unknown')::TEXT AS country,
        COUNT(*)::BIGINT AS events,
        COUNT(DISTINCT e.user_id)::BIGINT AS unique_users,
        COUNT(DISTINCT e.tool_session_id)::BIGINT AS unique_sessions,
        MAX(e.event_timestamp)::TIMESTAMPTZ AS last_event_at
    FROM tool_usage_events e
    WHERE e.tool_id = p_tool_id
      AND e.event_timestamp >= NOW() - v_window
    GROUP BY COALESCE(e.country, 'Unknown')
    ORDER BY events DESC
    LIMIT COALESCE(p_limit, 10);
END;
$$;


--
-- Name: get_tool_usage_daily(text, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_tool_usage_daily(p_tool_id text, p_days integer DEFAULT 30) RETURNS TABLE(usage_date date, events bigint, unique_users bigint, unique_sessions bigint)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
    v_window INTERVAL := make_interval(days => GREATEST(p_days, 1));
BEGIN
    RETURN QUERY
    SELECT
        DATE(e.event_timestamp)::DATE AS usage_date,
        COUNT(*)::BIGINT AS events,
        COUNT(DISTINCT e.user_id)::BIGINT AS unique_users,
        COUNT(DISTINCT e.tool_session_id)::BIGINT AS unique_sessions
    FROM tool_usage_events e
    WHERE e.tool_id = p_tool_id
      AND e.event_timestamp >= NOW() - v_window
    GROUP BY DATE(e.event_timestamp)
    ORDER BY usage_date ASC;
END;
$$;


--
-- Name: get_tool_usage_daily_by_country(text, integer, text[]); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_tool_usage_daily_by_country(p_tool_id text, p_days integer DEFAULT 30, p_countries text[] DEFAULT ARRAY[]::text[]) RETURNS TABLE(usage_date date, country text, events bigint)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
    v_window INTERVAL := make_interval(days => GREATEST(p_days, 1));
BEGIN
    RETURN QUERY
    SELECT
        DATE(e.event_timestamp)::DATE AS usage_date,
        COALESCE(e.country, 'Unknown')::TEXT AS country,
        COUNT(*)::BIGINT AS events
    FROM tool_usage_events e
    WHERE e.tool_id = p_tool_id
      AND e.event_timestamp >= NOW() - v_window
      AND COALESCE(e.country, 'Unknown') = ANY(p_countries)
    GROUP BY DATE(e.event_timestamp), COALESCE(e.country, 'Unknown')
    ORDER BY usage_date ASC;
END;
$$;


--
-- Name: get_tool_usage_leaderboard(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_tool_usage_leaderboard(p_days integer DEFAULT 30) RETURNS TABLE(tool_id text, tool_name text, events bigint, unique_users bigint, unique_sessions bigint, countries bigint, last_event_at timestamp with time zone)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
    v_window INTERVAL := make_interval(days => GREATEST(p_days, 1));
BEGIN
    RETURN QUERY
    SELECT
        e.tool_id,
        COALESCE(tc.display_name, e.tool_id) AS tool_name,
        COUNT(*) AS events,
        COUNT(DISTINCT e.user_id) AS unique_users,
        COUNT(DISTINCT e.tool_session_id) AS unique_sessions,
        COUNT(DISTINCT COALESCE(e.country, 'Unknown')) AS countries,
        MAX(e.event_timestamp) AS last_event_at
    FROM tool_usage_events e
    LEFT JOIN tool_catalog tc ON tc.tool_id = e.tool_id
    WHERE e.event_timestamp >= NOW() - v_window
    GROUP BY e.tool_id, tc.display_name
    ORDER BY events DESC;
END;
$$;


--
-- Name: get_user_analytics_summary(uuid, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_user_analytics_summary(p_user_id uuid, p_days integer DEFAULT 30) RETURNS json
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    result JSON;
    cutoff_date TIMESTAMPTZ;
BEGIN
    cutoff_date := NOW() - (p_days || ' days')::INTERVAL;
    
    SELECT json_build_object(
        'total_sessions', COALESCE(session_stats.total_sessions, 0),
        'total_events', COALESCE(event_stats.total_events, 0),
        'active_days', COALESCE(session_stats.active_days, 0),
        'avg_session_minutes', COALESCE(session_stats.avg_session_minutes, 0),
        'top_tools', COALESCE(tool_stats.top_tools, '[]'::json),
        'period_days', p_days
    ) INTO result
    FROM (
        SELECT 
            COUNT(*) as total_sessions,
            COUNT(DISTINCT DATE(start_timestamp)) as active_days,
            AVG(EXTRACT(EPOCH FROM (COALESCE(end_timestamp, NOW()) - start_timestamp))/60) as avg_session_minutes
        FROM app_sessions 
        WHERE user_id = p_user_id AND start_timestamp > cutoff_date
    ) session_stats
    CROSS JOIN (
        SELECT COUNT(*) as total_events
        FROM tool_usage_events 
        WHERE user_id = p_user_id AND event_timestamp > cutoff_date
    ) event_stats
    CROSS JOIN (
        SELECT json_agg(
            json_build_object(
                               'tool_id', tool_id,
                'tool_name', t.title,
                'usage_count', usage_count
            ) ORDER BY usage_count DESC
        ) as top_tools
        FROM (
            SELECT 
                tue.tool_id,
                COUNT(*) as usage_count
            FROM tool_usage_events tue
            WHERE tue.user_id = p_user_id 
                AND tue.event_timestamp > cutoff_date 
                AND tue.event_type = 'open'
            GROUP BY tue.tool_id
            ORDER BY usage_count DESC
            LIMIT 10
        ) top_tool_usage
        LEFT JOIN tools t ON top_tool_usage.tool_id = t.id
    ) tool_stats;
    
    RETURN result;
END;
$$;


--
-- Name: get_user_retention(date, date); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_user_retention(p_cohort_start date, p_cohort_end date) RETURNS TABLE(cohort_date date, total_users bigint, day_1_retention numeric, day_7_retention numeric, day_30_retention numeric)
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
    RETURN QUERY
    WITH cohort_users AS (
        SELECT DISTINCT
            DATE(MIN(start_time) OVER (PARTITION BY user_id)) as first_session_date,
            user_id
        FROM app_sessions
        WHERE DATE(start_time) BETWEEN p_cohort_start AND p_cohort_end
    ),
    retention_data AS (
        SELECT 
            cu.first_session_date,
            cu.user_id,
            MAX(CASE WHEN DATE(s.start_time) = cu.first_session_date + INTERVAL '1 day' THEN 1 ELSE 0 END) as day_1,
            MAX(CASE WHEN DATE(s.start_time) = cu.first_session_date + INTERVAL '7 days' THEN 1 ELSE 0 END) as day_7,
            MAX(CASE WHEN DATE(s.start_time) = cu.first_session_date + INTERVAL '30 days' THEN 1 ELSE 0 END) as day_30
        FROM cohort_users cu
        LEFT JOIN app_sessions s ON cu.user_id = s.user_id
        GROUP BY cu.first_session_date, cu.user_id
    )
    SELECT 
        first_session_date as cohort_date,
        COUNT(*) as total_users,
        ROUND(AVG(day_1) * 100, 2) as day_1_retention,
        ROUND(AVG(day_7) * 100, 2) as day_7_retention,
        ROUND(AVG(day_30) * 100, 2) as day_30_retention
    FROM retention_data
    GROUP BY first_session_date
    ORDER BY first_session_date;
END;
$$;


--
-- Name: mark_announcement_status(text, uuid, text, jsonb); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.mark_announcement_status(p_user_id text, p_announcement_id uuid, p_status text, p_metadata jsonb DEFAULT '{}'::jsonb) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
    IF p_status NOT IN ('delivered','opened','dismissed') THEN
        RAISE EXCEPTION 'Unsupported announcement status %', p_status;
    END IF;
    INSERT INTO user_announcements (
        announcement_id, user_id, status, metadata, first_seen_at, acted_at
    ) VALUES (
        p_announcement_id, p_user_id, p_status, p_metadata, NOW(),
        CASE WHEN p_status <> 'delivered' THEN NOW() ELSE NULL END
    )
    ON CONFLICT (announcement_id, user_id) DO UPDATE SET
        status = EXCLUDED.status,
        metadata = COALESCE(EXCLUDED.metadata, user_announcements.metadata),
        acted_at = CASE WHEN EXCLUDED.status <> 'delivered' THEN NOW() ELSE user_announcements.acted_at END,
        updated_at = NOW();
END;
$$;


--
-- Name: migrate_user_auth_uid(text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.migrate_user_auth_uid(p_user_id text, p_new_auth_uid text) RETURNS TABLE(success boolean, updated_count integer, error_message text)
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    v_total_updated INTEGER := 0;
    v_error_msg TEXT := '';
    v_row_count INTEGER;
BEGIN
    BEGIN
        -- Update users table
        UPDATE users SET auth_uid = p_new_auth_uid
        WHERE user_id = p_user_id;
        GET DIAGNOSTICS v_row_count = ROW_COUNT;
        v_total_updated := v_total_updated + COALESCE(v_row_count, 0);

        -- Update app_sessions
        UPDATE app_sessions SET auth_uid = p_new_auth_uid
        WHERE user_id = p_user_id;
        GET DIAGNOSTICS v_row_count = ROW_COUNT;
        v_total_updated := v_total_updated + COALESCE(v_row_count, 0);

        -- Update app_settings
        UPDATE app_settings SET auth_uid = p_new_auth_uid
        WHERE user_id = p_user_id;
        GET DIAGNOSTICS v_row_count = ROW_COUNT;
        v_total_updated := v_total_updated + COALESCE(v_row_count, 0);

        -- Update screen_settings
        UPDATE screen_settings SET auth_uid = p_new_auth_uid
        WHERE user_id = p_user_id;
        GET DIAGNOSTICS v_row_count = ROW_COUNT;
        v_total_updated := v_total_updated + COALESCE(v_row_count, 0);

        -- Update section_settings
        UPDATE section_settings SET auth_uid = p_new_auth_uid
        WHERE user_id = p_user_id;
        GET DIAGNOSTICS v_row_count = ROW_COUNT;
        v_total_updated := v_total_updated + COALESCE(v_row_count, 0);

        -- Update category_settings
        UPDATE category_settings SET auth_uid = p_new_auth_uid
        WHERE user_id = p_user_id;
        GET DIAGNOSTICS v_row_count = ROW_COUNT;
        v_total_updated := v_total_updated + COALESCE(v_row_count, 0);

        -- Update tool_settings
        UPDATE tool_settings SET auth_uid = p_new_auth_uid
        WHERE user_id = p_user_id;
        GET DIAGNOSTICS v_row_count = ROW_COUNT;
        v_total_updated := v_total_updated + COALESCE(v_row_count, 0);

        -- Update tool_usage_events
        UPDATE tool_usage_events SET auth_uid = p_new_auth_uid
        WHERE user_id = p_user_id;
        GET DIAGNOSTICS v_row_count = ROW_COUNT;
        v_total_updated := v_total_updated + COALESCE(v_row_count, 0);

        -- Update feedbacks
        UPDATE feedbacks SET auth_uid = p_new_auth_uid
        WHERE user_id = p_user_id;
        GET DIAGNOSTICS v_row_count = ROW_COUNT;
        v_total_updated := v_total_updated + COALESCE(v_row_count, 0);

        RETURN QUERY SELECT true, v_total_updated, NULL::TEXT;
    EXCEPTION WHEN OTHERS THEN
        v_error_msg := SQLERRM;
        RETURN QUERY SELECT false, v_total_updated, v_error_msg;
    END;
END;
$$;


--
-- Name: record_announcement_impression(uuid, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.record_announcement_impression(p_announcement_id uuid, p_user_id text) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
    PERFORM public.record_announcement_impression(p_announcement_id, p_user_id, NULL);
END;
$$;


--
-- Name: record_announcement_impression(uuid, text, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.record_announcement_impression(p_announcement_id uuid, p_user_id text, p_session_number integer DEFAULT NULL::integer) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    v_remind_later_sessions INTEGER := 1;
BEGIN
    -- Get remind_later_sessions from announcement
    SELECT COALESCE(remind_later_sessions, 1) INTO v_remind_later_sessions
    FROM public.announcements
    WHERE id = p_announcement_id;

    INSERT INTO public.user_announcement_state (
        announcement_id,
        user_id,
        status,
        impression_count,
        first_seen_at,
        last_seen_at,
        last_seen_session,
        defer_until_session,
        defer_count,
        updated_at
    ) VALUES (
        p_announcement_id,
        p_user_id,
        'seen',
        1,
        NOW(),
        NOW(),
        p_session_number,
        NULL,
        0,
        NOW()
    )
    ON CONFLICT (announcement_id, user_id) DO UPDATE SET
        -- Keep 'deferred' status if in remind_later mode
        status = CASE 
            WHEN user_announcement_state.status IN ('dismissed', 'completed') THEN user_announcement_state.status
            WHEN user_announcement_state.status = 'deferred' THEN 'deferred'
            ELSE 'seen'
        END,
        impression_count = user_announcement_state.impression_count + 1,
        last_seen_at = NOW(),
        last_seen_session = COALESCE(p_session_number, user_announcement_state.last_seen_session),
        -- For deferred: increment defer_count and set next defer_until_session
        defer_count = CASE 
            WHEN user_announcement_state.status = 'deferred' 
            THEN user_announcement_state.defer_count + 1
            ELSE user_announcement_state.defer_count
        END,
        defer_until_session = CASE 
            WHEN user_announcement_state.status = 'deferred' 
            THEN COALESCE(p_session_number, 0) + v_remind_later_sessions
            ELSE user_announcement_state.defer_until_session
        END,
        updated_at = NOW();
END;
$$;


--
-- Name: update_announcement_state(uuid, text, text, integer, integer, integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_announcement_state(p_announcement_id uuid, p_user_id text, p_status text, p_session_number integer DEFAULT NULL::integer, p_defer_sessions integer DEFAULT NULL::integer, p_defer_hours integer DEFAULT NULL::integer, p_questions_answered integer DEFAULT NULL::integer) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    v_result JSONB;
    v_defer_until_session INTEGER;
    v_defer_until_time TIMESTAMPTZ;
    v_is_partially_completed BOOLEAN;
    v_total_questions INTEGER;
    v_should_increment_impression BOOLEAN;
BEGIN
    -- Only increment impression count for 'seen' status (actual views)
    v_should_increment_impression := (p_status = 'seen');
    
    -- Calculate defer values if deferred
    IF p_status = 'deferred' THEN
        IF p_defer_sessions IS NOT NULL AND p_session_number IS NOT NULL THEN
            v_defer_until_session := p_session_number + p_defer_sessions;
        END IF;
        IF p_defer_hours IS NOT NULL THEN
            v_defer_until_time := NOW() + (p_defer_hours * INTERVAL '1 hour');
        END IF;
    END IF;
    
    -- Check if survey is partially completed
    IF p_questions_answered IS NOT NULL THEN
        SELECT jsonb_array_length(COALESCE(questions, '[]'::jsonb)) INTO v_total_questions
        FROM public.announcements
        WHERE id = p_announcement_id;
        
        v_is_partially_completed := p_questions_answered < COALESCE(v_total_questions, 0);
        
        IF p_questions_answered >= COALESCE(v_total_questions, 0) AND v_total_questions > 0 THEN
            p_status := 'completed';
            v_is_partially_completed := FALSE;
        END IF;
    END IF;
    
    -- Upsert user_announcement_state
    INSERT INTO public.user_announcement_state (
        announcement_id,
        user_id,
        status,
        first_seen_at,
        last_seen_at,
        last_seen_session,
        defer_until_session,
        defer_until_time,
        defer_count,
        is_partially_completed,
        questions_answered,
        impression_count,
        completed_at,
        dismissed_at,
        deferred_at,
        updated_at
    ) VALUES (
        p_announcement_id,
        p_user_id,
        p_status,
        CASE WHEN p_status = 'seen' THEN NOW() ELSE NULL END,
        NOW(),
        p_session_number,
        v_defer_until_session,
        v_defer_until_time,
        -- CRITICAL FIX: Start defer_count at 0, not 1
        -- The view where user clicks "Remind Later" doesn't count
        CASE WHEN p_status = 'deferred' THEN 0 ELSE 0 END,
        COALESCE(v_is_partially_completed, FALSE),
        COALESCE(p_questions_answered, 0),
        CASE WHEN v_should_increment_impression THEN 1 ELSE 0 END,
        CASE WHEN p_status = 'completed' THEN NOW() ELSE NULL END,
        CASE WHEN p_status = 'dismissed' THEN NOW() ELSE NULL END,
        CASE WHEN p_status = 'deferred' THEN NOW() ELSE NULL END,
        NOW()
    )
    ON CONFLICT (announcement_id, user_id) DO UPDATE SET
        status = EXCLUDED.status,
        first_seen_at = COALESCE(user_announcement_state.first_seen_at, 
            CASE WHEN EXCLUDED.status = 'seen' THEN NOW() ELSE NULL END),
        last_seen_at = NOW(),
        last_seen_session = COALESCE(EXCLUDED.last_seen_session, user_announcement_state.last_seen_session),
        defer_until_session = CASE 
            WHEN EXCLUDED.status = 'deferred' THEN EXCLUDED.defer_until_session 
            ELSE user_announcement_state.defer_until_session 
        END,
        defer_until_time = CASE 
            WHEN EXCLUDED.status = 'deferred' THEN EXCLUDED.defer_until_time 
            ELSE user_announcement_state.defer_until_time 
        END,
        -- When user clicks "Remind Later" again, keep incrementing from current count
        defer_count = CASE 
            WHEN EXCLUDED.status = 'deferred' THEN user_announcement_state.defer_count
            ELSE user_announcement_state.defer_count 
        END,
        is_partially_completed = COALESCE(EXCLUDED.is_partially_completed, user_announcement_state.is_partially_completed),
        questions_answered = GREATEST(COALESCE(EXCLUDED.questions_answered, 0), COALESCE(user_announcement_state.questions_answered, 0)),
        impression_count = CASE 
            WHEN EXCLUDED.status = 'seen' THEN user_announcement_state.impression_count + 1 
            ELSE user_announcement_state.impression_count 
        END,
        completed_at = CASE 
            WHEN EXCLUDED.status = 'completed' THEN NOW() 
            ELSE user_announcement_state.completed_at 
        END,
        dismissed_at = CASE 
            WHEN EXCLUDED.status = 'dismissed' THEN NOW() 
            ELSE user_announcement_state.dismissed_at 
        END,
        deferred_at = CASE 
            WHEN EXCLUDED.status = 'deferred' THEN NOW() 
            ELSE user_announcement_state.deferred_at 
        END,
        updated_at = NOW();
    
    -- Return the updated state
    SELECT jsonb_build_object(
        'announcement_id', p_announcement_id,
        'user_id', p_user_id,
        'status', p_status,
        'defer_count', CASE WHEN p_status = 'deferred' THEN 0 ELSE NULL END,
        'defer_until_session', v_defer_until_session,
        'is_remind_later_mode', (p_status = 'deferred')
    ) INTO v_result;
    
    RETURN v_result;
END;
$$;


--
-- Name: update_last_updated_column(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_last_updated_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.last_updated = NOW();
    RETURN NEW;
END;
$$;


--
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;


--
-- Name: update_user_insights_from_response(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_user_insights_from_response() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    response_value TEXT;
BEGIN
    -- Only process if link_to_profile is set and user_auth_uid is provided
    IF NEW.link_to_profile IS NOT NULL AND NEW.user_auth_uid IS NOT NULL THEN
        -- Get the response value (prefer option_value, then text_value, then numeric_value)
        response_value := COALESCE(NEW.option_value, NEW.text_value, NEW.numeric_value::TEXT);
        
        IF response_value IS NOT NULL THEN
            -- Update the user's insights JSON
            UPDATE public.users
            SET insights = jsonb_set(
                jsonb_set(
                    COALESCE(insights, '{}'::jsonb),
                    ARRAY[NEW.link_to_profile],
                    to_jsonb(response_value)
                ),
                ARRAY[NEW.link_to_profile || '_updated_at'],
                to_jsonb(NOW()::TEXT)
            ),
            updated_at = NOW()
            WHERE auth_uid = NEW.user_auth_uid;
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$;


--
-- Name: update_user_location_from_session(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_user_location_from_session() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Only update if we have location data and user exists
    IF NEW.country IS NOT NULL AND NEW.auth_uid IS NOT NULL THEN
        UPDATE public.users
        SET 
            last_country = NEW.country,
            last_city = NEW.city,
            last_platform = NEW.os_platform,
            last_device_brand = NEW.device_brand,
            last_is_real_device = NEW.is_device,
            last_ip = NEW.public_ip,
            last_location_updated_at = NOW(),
            updated_at = NOW()
        WHERE auth_uid = NEW.auth_uid;
    END IF;
    
    RETURN NEW;
END;
$$;


--
-- Name: user_owns_data(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.user_owns_data(target_user_id text) RETURNS boolean
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
    RETURN target_user_id IN (
        SELECT user_id FROM users 
        WHERE auth_uid = auth.uid()::text OR user_id = auth.uid()::text
    );
END;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: admin_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.admin_users (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id text NOT NULL,
    email text NOT NULL,
    password_hash text,
    display_name text,
    role text DEFAULT 'admin'::text NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    last_login_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by text,
    CONSTRAINT admin_users_role_check CHECK ((role = ANY (ARRAY['admin'::text, 'superadmin'::text])))
);


--
-- Name: announcement_config; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.announcement_config (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    config_key text NOT NULL,
    config_value jsonb NOT NULL,
    description text,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_by text
);


--
-- Name: announcement_impressions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.announcement_impressions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    announcement_id uuid,
    user_id uuid,
    impressions integer DEFAULT 0 NOT NULL,
    last_seen_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: announcement_responses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.announcement_responses (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    announcement_id uuid,
    question_id text NOT NULL,
    user_id uuid,
    user_auth_uid text,
    option_value text,
    text_value text,
    numeric_value numeric,
    link_to_profile text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now(),
    first_option_value text,
    first_text_value text,
    first_numeric_value numeric,
    first_answered_at timestamp with time zone
);


--
-- Name: COLUMN announcement_responses.first_option_value; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.announcement_responses.first_option_value IS 'User''s first answer for option-based questions (never changes after initial save)';


--
-- Name: COLUMN announcement_responses.first_text_value; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.announcement_responses.first_text_value IS 'User''s first answer for text-based questions (never changes after initial save)';


--
-- Name: COLUMN announcement_responses.first_numeric_value; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.announcement_responses.first_numeric_value IS 'User''s first answer for numeric questions (never changes after initial save)';


--
-- Name: COLUMN announcement_responses.first_answered_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.announcement_responses.first_answered_at IS 'Timestamp when user first answered this question';


--
-- Name: announcements; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.announcements (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    title text NOT NULL,
    message text,
    body text,
    surface text NOT NULL,
    importance text DEFAULT 'low'::text NOT NULL,
    kind text DEFAULT 'announcement'::text NOT NULL,
    priority text DEFAULT 'normal'::text NOT NULL,
    audience text DEFAULT 'all'::text NOT NULL,
    action_type text DEFAULT 'none'::text NOT NULL,
    action_value text,
    start_at timestamp with time zone DEFAULT now() NOT NULL,
    end_at timestamp with time zone,
    is_active boolean DEFAULT true NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    deleted_at timestamp with time zone,
    deleted_by text,
    dismissible boolean DEFAULT true NOT NULL,
    repeat_mode text DEFAULT 'once'::text NOT NULL,
    repeat_interval_hours integer,
    max_times_seen_per_user integer,
    max_impressions integer,
    show_in_carousel boolean DEFAULT true NOT NULL,
    show_in_notifications boolean DEFAULT true NOT NULL,
    status text DEFAULT 'scheduled'::text NOT NULL,
    target_country text,
    target_speciality text,
    target_min_app_version text,
    target_max_app_version text,
    target_logged_in_only boolean DEFAULT false NOT NULL,
    target_anonymous_only boolean DEFAULT false NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb,
    questions jsonb DEFAULT '[]'::jsonb,
    responses jsonb DEFAULT '[]'::jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by text,
    updated_by text,
    version integer DEFAULT 1 NOT NULL,
    dismissible_mode text DEFAULT 'yes'::text NOT NULL,
    remind_later_count integer DEFAULT 3,
    remind_later_sessions integer DEFAULT 1,
    target_degree text,
    target_subspecialty text,
    target_profession text,
    target_hospital text,
    target_years_experience text,
    target_platform text,
    target_is_real_device boolean,
    target_device_brand text,
    target_ip_addresses text,
    target_city text,
    disappear_after_cta boolean DEFAULT true NOT NULL,
    repeat_session_interval integer DEFAULT 1,
    display_sequence integer DEFAULT 0,
    carousel_max_count integer DEFAULT 5,
    target_profession_exclude boolean DEFAULT false,
    target_speciality_exclude boolean DEFAULT false,
    target_degree_exclude boolean DEFAULT false,
    target_experience_exclude boolean DEFAULT false,
    target_country_exclude boolean DEFAULT false,
    target_city_exclude boolean DEFAULT false,
    target_incomplete_profile boolean DEFAULT false,
    first_view_session_delay integer DEFAULT 0,
    CONSTRAINT announcements_action_type_check CHECK ((action_type = ANY (ARRAY['none'::text, 'open_link'::text, 'open_screen'::text, 'open_tool'::text]))),
    CONSTRAINT announcements_audience_check CHECK ((audience = ANY (ARRAY['all'::text, 'doctors'::text, 'residents'::text, 'students'::text]))),
    CONSTRAINT announcements_dismissible_mode_check CHECK ((dismissible_mode = ANY (ARRAY['yes'::text, 'no'::text, 'remind_later'::text]))),
    CONSTRAINT announcements_importance_check CHECK ((importance = ANY (ARRAY['low'::text, 'medium'::text, 'high'::text]))),
    CONSTRAINT announcements_kind_check CHECK ((kind = ANY (ARRAY['announcement'::text, 'survey'::text, 'quiz'::text, 'user_insights'::text]))),
    CONSTRAINT announcements_priority_check CHECK ((priority = ANY (ARRAY['low'::text, 'normal'::text, 'high'::text]))),
    CONSTRAINT announcements_repeat_mode_check CHECK ((repeat_mode = ANY (ARRAY['once'::text, 'per_app_open'::text, 'interval_hours'::text]))),
    CONSTRAINT announcements_status_check CHECK ((status = ANY (ARRAY['scheduled'::text, 'live'::text, 'ended'::text]))),
    CONSTRAINT announcements_surface_check CHECK ((surface = ANY (ARRAY['home_banner'::text, 'modal'::text, 'inbox'::text, 'tooltip'::text]))),
    CONSTRAINT check_targeting_exclusive CHECK ((NOT ((target_logged_in_only = true) AND (target_anonymous_only = true))))
);


--
-- Name: COLUMN announcements.kind; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.announcements.kind IS 'Type of announcement: 
- announcement: Simple notification/message
- survey: Questions without correct answers, collects anonymous feedback
- quiz: Questions WITH correct answers, shows right/wrong feedback
- user_insights: Questions linked to user profile (profession, specialty, etc.)';


--
-- Name: COLUMN announcements.disappear_after_cta; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.announcements.disappear_after_cta IS 'Whether announcement disappears after user clicks CTA button. Default TRUE.';


--
-- Name: COLUMN announcements.repeat_session_interval; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.announcements.repeat_session_interval IS 'Session interval for per_app_open repeat mode. Show announcement every X sessions. Default 1.';


--
-- Name: COLUMN announcements.first_view_session_delay; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.announcements.first_view_session_delay IS 'Number of app sessions to wait before showing announcement for the first time. 
Default 0 = show immediately on first session. 
Value 2 = show first time after user has opened app 2 times.
This only affects the FIRST view - subsequent views follow repeat_mode and repeat_session_interval settings.';


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    auth_uid text NOT NULL,
    user_id text NOT NULL,
    email text,
    name text,
    image_uri text,
    is_verified boolean DEFAULT false,
    is_anonymous boolean DEFAULT false,
    login_method text DEFAULT 'anonymous'::text,
    insights jsonb DEFAULT '{}'::jsonb,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    is_synced boolean DEFAULT false,
    last_synced_at timestamp with time zone,
    last_country text,
    last_city text,
    last_platform text,
    last_device_brand text,
    last_is_real_device boolean,
    last_ip text,
    last_location_updated_at timestamp with time zone,
    CONSTRAINT users_auth_user_match CHECK ((user_id = auth_uid))
);


--
-- Name: announcement_targeting_stats; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.announcement_targeting_stats WITH (security_invoker='true') AS
 SELECT id,
    title,
    kind,
    surface,
    is_active,
    target_country,
    target_city,
    target_speciality,
    target_subspecialty,
    target_degree,
    target_profession,
    target_platform,
    target_is_real_device,
    target_logged_in_only,
    target_anonymous_only,
    ( SELECT count(*) AS count
           FROM public.users u
          WHERE (((a.target_country IS NULL) OR (a.target_country = ''::text) OR (u.last_country = ANY (string_to_array(replace(a.target_country, ' '::text, ''::text), ','::text)))) AND ((a.target_platform IS NULL) OR (a.target_platform = ''::text) OR (a.target_platform = 'all'::text) OR (lower(u.last_platform) = lower(a.target_platform))))) AS potential_audience,
    created_at,
    updated_at
   FROM public.announcements a
  WHERE (is_deleted = false);


--
-- Name: app_sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.app_sessions (
    id text NOT NULL,
    user_id text NOT NULL,
    auth_uid text NOT NULL,
    start_time timestamp with time zone DEFAULT now(),
    end_time timestamp with time zone,
    public_ip text,
    country text,
    region text,
    city text,
    device_info jsonb,
    app_version text,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    is_synced boolean DEFAULT false,
    last_synced_at timestamp with time zone,
    os_platform text,
    device_brand text,
    device_model text,
    is_device boolean,
    device_type integer,
    os_version text,
    is_location_live boolean DEFAULT true,
    last_live_location_fetched_at timestamp with time zone,
    fallback_location_used_at timestamp with time zone,
    CONSTRAINT app_sessions_user_match CHECK ((user_id = auth_uid))
);


--
-- Name: app_settings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.app_settings (
    user_id text NOT NULL,
    setting_key text NOT NULL,
    auth_uid text NOT NULL,
    setting_value jsonb,
    custom_settings jsonb,
    is_archived boolean DEFAULT false,
    last_updated timestamp with time zone DEFAULT now(),
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    is_synced boolean DEFAULT false,
    last_synced_at timestamp with time zone,
    CONSTRAINT app_settings_user_match CHECK ((user_id = auth_uid))
);


--
-- Name: category_settings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.category_settings (
    user_id text NOT NULL,
    category_id text NOT NULL,
    auth_uid text NOT NULL,
    settings jsonb DEFAULT '{}'::jsonb,
    sort_order integer DEFAULT 0,
    is_expanded boolean DEFAULT false,
    is_visible boolean DEFAULT true,
    is_archived boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    is_synced boolean DEFAULT false,
    last_synced_at timestamp with time zone,
    CONSTRAINT category_settings_user_match CHECK ((user_id = auth_uid))
);


--
-- Name: credit_asset_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.credit_asset_types (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    display_name text NOT NULL,
    description text,
    icon text,
    sort_order integer DEFAULT 0 NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: credit_links; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.credit_links (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    site_id uuid NOT NULL,
    title text NOT NULL,
    url text NOT NULL,
    author text,
    description text,
    sort_order integer DEFAULT 0 NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: credit_sites; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.credit_sites (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    asset_type_id uuid NOT NULL,
    name text NOT NULL,
    display_name text NOT NULL,
    website_url text,
    attribution_format text,
    description text,
    logo_url text,
    sort_order integer DEFAULT 0 NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: credits_overview; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.credits_overview WITH (security_invoker='true') AS
 SELECT cat.id AS asset_type_id,
    cat.name AS asset_type_name,
    cat.display_name AS asset_type_display_name,
    cat.icon AS asset_type_icon,
    cat.sort_order AS asset_type_sort,
    count(DISTINCT cs.id) AS site_count,
    count(DISTINCT cl.id) AS link_count
   FROM ((public.credit_asset_types cat
     LEFT JOIN public.credit_sites cs ON (((cs.asset_type_id = cat.id) AND (cs.is_active = true))))
     LEFT JOIN public.credit_links cl ON (((cl.site_id = cs.id) AND (cl.is_active = true))))
  WHERE (cat.is_active = true)
  GROUP BY cat.id, cat.name, cat.display_name, cat.icon, cat.sort_order
  ORDER BY cat.sort_order;


--
-- Name: dashboard_announcements; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.dashboard_announcements WITH (security_invoker='true') AS
 SELECT id,
    title,
    COALESCE(body, message) AS body,
    COALESCE(kind, 'announcement'::text) AS kind,
    COALESCE(priority, importance, 'normal'::text) AS priority,
    COALESCE(audience, 'all'::text) AS audience,
    start_at,
    end_at,
    COALESCE(show_in_carousel, true) AS show_in_carousel,
    COALESCE(show_in_notifications, true) AS show_in_notifications,
    max_impressions,
    COALESCE(status, 'live'::text) AS status,
    COALESCE(questions, '[]'::jsonb) AS questions,
    COALESCE(responses, '[]'::jsonb) AS responses
   FROM public.announcements
  WHERE (is_deleted = false);


--
-- Name: feedbacks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.feedbacks (
    id text NOT NULL,
    user_id text NOT NULL,
    auth_uid text NOT NULL,
    type text,
    message text,
    tool_id text,
    screen_state jsonb,
    conclusion_data jsonb,
    rating integer,
    metadata jsonb,
    submitted_at timestamp with time zone DEFAULT now(),
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    is_synced boolean DEFAULT false,
    last_synced_at timestamp with time zone,
    CONSTRAINT feedbacks_rating_check CHECK (((rating >= 1) AND (rating <= 5))),
    CONSTRAINT feedbacks_user_match CHECK ((user_id = auth_uid))
);


--
-- Name: dashboard_feedbacks; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.dashboard_feedbacks WITH (security_invoker='true') AS
 SELECT id,
    message,
    tool_id AS tool_slug,
    type AS feedback_type,
    conclusion_data AS conclusion,
    submitted_at AS created_at
   FROM public.feedbacks;


--
-- Name: screen_settings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.screen_settings (
    user_id text NOT NULL,
    screen_id text NOT NULL,
    auth_uid text NOT NULL,
    settings jsonb,
    is_archived boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    is_synced boolean DEFAULT false,
    last_synced_at timestamp with time zone,
    CONSTRAINT screen_settings_user_match CHECK ((user_id = auth_uid))
);


--
-- Name: section_settings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.section_settings (
    user_id text NOT NULL,
    section_id text NOT NULL,
    auth_uid text NOT NULL,
    settings jsonb,
    filters jsonb,
    is_archived boolean DEFAULT false,
    last_updated timestamp with time zone DEFAULT now(),
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    is_synced boolean DEFAULT false,
    last_synced_at timestamp with time zone,
    CONSTRAINT section_settings_user_match CHECK ((user_id = auth_uid))
);


--
-- Name: tool_settings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tool_settings (
    user_id text NOT NULL,
    tool_id text NOT NULL,
    auth_uid text NOT NULL,
    settings jsonb,
    is_favourite boolean DEFAULT false,
    order_in_app integer DEFAULT 0,
    order_in_category integer DEFAULT 0,
    order_in_section integer DEFAULT 0,
    usage_count integer DEFAULT 0,
    usage_duration_sec integer DEFAULT 0,
    last_used_at timestamp with time zone,
    is_archived boolean DEFAULT false,
    last_updated timestamp with time zone DEFAULT now(),
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    is_synced boolean DEFAULT false,
    last_synced_at timestamp with time zone,
    CONSTRAINT tool_settings_user_match CHECK ((user_id = auth_uid))
);


--
-- Name: tool_usage_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tool_usage_events (
    id text NOT NULL,
    user_id text NOT NULL,
    auth_uid text NOT NULL,
    tool_id text NOT NULL,
    tool_session_id text,
    app_session_id text,
    event_type text NOT NULL,
    event_timestamp timestamp with time zone DEFAULT now(),
    event_data jsonb,
    created_at timestamp with time zone DEFAULT now(),
    is_synced boolean DEFAULT false,
    last_synced_at timestamp with time zone,
    CONSTRAINT tool_usage_events_user_match CHECK ((user_id = auth_uid))
);


--
-- Name: tool_usage_events_enriched; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.tool_usage_events_enriched WITH (security_invoker='true') AS
 SELECT e.id,
    e.user_id,
    e.auth_uid,
    e.tool_id,
    e.tool_session_id,
    e.app_session_id,
    e.event_type,
    e.event_timestamp,
    e.event_data,
    e.created_at,
    e.is_synced,
    e.last_synced_at,
    s.public_ip,
    s.country,
    s.region,
    s.city
   FROM (public.tool_usage_events e
     LEFT JOIN public.app_sessions s ON ((e.app_session_id = s.id)));


--
-- Name: tool_usage_summary; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tool_usage_summary (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tool_slug text NOT NULL,
    tool_name text,
    usage_count bigint DEFAULT 0 NOT NULL,
    total_duration_seconds bigint DEFAULT 0 NOT NULL,
    days_used integer DEFAULT 0 NOT NULL,
    months_used integer DEFAULT 0 NOT NULL,
    years_used integer DEFAULT 0 NOT NULL,
    last_used_at timestamp with time zone,
    unique_users integer DEFAULT 0 NOT NULL,
    session_count integer DEFAULT 0 NOT NULL,
    country_count integer DEFAULT 0 NOT NULL,
    city_count integer DEFAULT 0 NOT NULL,
    avg_usage_per_user numeric DEFAULT 0 NOT NULL,
    avg_time_per_user_seconds numeric DEFAULT 0 NOT NULL,
    avg_calc_time_ms numeric,
    usage_by_date jsonb DEFAULT '[]'::jsonb,
    duration_by_date jsonb DEFAULT '[]'::jsonb,
    country_breakdown jsonb DEFAULT '[]'::jsonb,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: user_announcement_state; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_announcement_state (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    announcement_id uuid NOT NULL,
    user_id text NOT NULL,
    status text DEFAULT 'eligible'::text NOT NULL,
    first_seen_at timestamp with time zone,
    last_seen_at timestamp with time zone,
    dismissed_at timestamp with time zone,
    deferred_at timestamp with time zone,
    completed_at timestamp with time zone,
    defer_count integer DEFAULT 0,
    defer_until_session integer,
    defer_until_time timestamp with time zone,
    impression_count integer DEFAULT 0,
    is_partially_completed boolean DEFAULT false,
    questions_answered integer DEFAULT 0,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    last_seen_session integer DEFAULT 0,
    CONSTRAINT user_announcement_state_status_check CHECK ((status = ANY (ARRAY['eligible'::text, 'seen'::text, 'dismissed'::text, 'deferred'::text, 'completed'::text, 'expired'::text])))
);


--
-- Name: user_sync_states; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_sync_states (
    id text NOT NULL,
    user_id text,
    auth_uid text NOT NULL,
    email text,
    decision text,
    reason text,
    decision_at timestamp with time zone DEFAULT now(),
    device_info jsonb,
    archived_previous_settings boolean DEFAULT false,
    CONSTRAINT user_sync_states_decision_check CHECK ((decision = ANY (ARRAY['restore'::text, 'decline'::text]))),
    CONSTRAINT user_sync_states_user_match CHECK (((user_id IS NULL) OR (user_id = auth_uid)))
);


--
-- Name: user_usage_summary; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_usage_summary (
    user_id uuid NOT NULL,
    full_name text,
    email text,
    country text,
    city text,
    total_sessions integer DEFAULT 0 NOT NULL,
    most_used_tool text,
    tools jsonb DEFAULT '[]'::jsonb,
    locations jsonb DEFAULT '[]'::jsonb,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Data for Name: admin_users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.admin_users (id, user_id, email, password_hash, display_name, role, is_active, last_login_at, created_at, created_by) FROM stdin;
f4271647-c15c-4776-be93-d46fe4185144	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	admin@ocuhub.com	\N	OcuHub Admin	superadmin	t	2025-12-19 18:37:53.737+00	2025-12-08 22:21:51.185018+00	system
\.


--
-- Data for Name: announcement_config; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.announcement_config (id, config_key, config_value, description, updated_at, updated_by) FROM stdin;
\.


--
-- Data for Name: announcement_impressions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.announcement_impressions (id, announcement_id, user_id, impressions, last_seen_at) FROM stdin;
\.


--
-- Data for Name: announcement_responses; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.announcement_responses (id, announcement_id, question_id, user_id, user_auth_uid, option_value, text_value, numeric_value, link_to_profile, created_at, updated_at, first_option_value, first_text_value, first_numeric_value, first_answered_at) FROM stdin;
\.


--
-- Data for Name: announcements; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.announcements (id, title, message, body, surface, importance, kind, priority, audience, action_type, action_value, start_at, end_at, is_active, is_deleted, deleted_at, deleted_by, dismissible, repeat_mode, repeat_interval_hours, max_times_seen_per_user, max_impressions, show_in_carousel, show_in_notifications, status, target_country, target_speciality, target_min_app_version, target_max_app_version, target_logged_in_only, target_anonymous_only, metadata, questions, responses, created_at, updated_at, created_by, updated_by, version, dismissible_mode, remind_later_count, remind_later_sessions, target_degree, target_subspecialty, target_profession, target_hospital, target_years_experience, target_platform, target_is_real_device, target_device_brand, target_ip_addresses, target_city, disappear_after_cta, repeat_session_interval, display_sequence, carousel_max_count, target_profession_exclude, target_speciality_exclude, target_degree_exclude, target_experience_exclude, target_country_exclude, target_city_exclude, target_incomplete_profile, first_view_session_delay) FROM stdin;
006ab62b-219b-425b-8e4d-641a343501d0	Only for KSA	Only for KSA	\N	modal	medium	announcement	normal	all	none	\N	2025-12-17 10:53:00+00	\N	f	f	\N	\N	t	per_app_open	24	10	\N	t	t	scheduled	Saudi Arabia	\N	\N	\N	f	f	{"cta_icon": "→", "thumbnail": "https://www.hospitalitynewsmag.com/wp-content/uploads/2021/12/saudi-arabia.jpg", "custom_color": "#38571a", "survey_category": "survey"}	[]	[]	2025-12-17 10:57:28.040132+00	2025-12-18 21:54:14.812061+00	f4271647-c15c-4776-be93-d46fe4185144	f4271647-c15c-4776-be93-d46fe4185144	1	yes	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	1	0	5	f	f	f	f	f	f	f	0
66f1c586-83c4-4ee2-a18f-c4071001b401	Only for KSA (Copy)	Only for KSA	\N	modal	medium	announcement	normal	all	none	\N	2025-12-18 06:29:00+00	\N	f	t	2025-12-18 09:37:28.282+00	f4271647-c15c-4776-be93-d46fe4185144	t	per_app_open	24	10	\N	t	t	live	Saudi Arabia	\N	\N	\N	f	f	{"cta_icon": "→", "thumbnail": "https://www.hospitalitynewsmag.com/wp-content/uploads/2021/12/saudi-arabia.jpg", "custom_color": "#38571a", "survey_category": "survey"}	[]	[]	2025-12-18 09:29:15.813294+00	2025-12-18 09:37:28.423593+00	f4271647-c15c-4776-be93-d46fe4185144	f4271647-c15c-4776-be93-d46fe4185144	1	yes	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	1	0	5	f	f	f	f	f	f	f	0
8387349a-83b9-45f8-bfc2-7af15e963a0c	Open after CTA 2 times 	Open after CTA - Keep showing after CTA	\N	home_banner	medium	announcement	normal	all	open_tool	pediatric-glasses	2025-12-18 21:32:00+00	\N	f	t	2025-12-19 08:33:56.498+00	f4271647-c15c-4776-be93-d46fe4185144	t	per_app_open	24	2	\N	t	t	live	\N	\N	\N	\N	f	f	{"cta_icon": "→", "cta_label": "Pediatric glasses", "survey_category": "survey"}	[]	[]	2025-12-18 22:12:49.454688+00	2025-12-19 08:33:57.434124+00	f4271647-c15c-4776-be93-d46fe4185144	f4271647-c15c-4776-be93-d46fe4185144	1	yes	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	1	0	5	f	f	f	f	f	f	f	0
c9f1f71b-41a2-4e62-9a3d-59f8243fcfd4	Display 0	Display 0	\N	home_banner	low	announcement	normal	all	none	\N	2025-12-18 21:32:00+00	\N	f	f	\N	\N	t	once	24	1	\N	t	t	scheduled	\N	\N	\N	\N	f	f	{"cta_icon": "→", "survey_category": "survey"}	[]	[]	2025-12-19 08:45:30.430613+00	2025-12-19 18:58:57.377199+00	f4271647-c15c-4776-be93-d46fe4185144	f4271647-c15c-4776-be93-d46fe4185144	1	yes	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	1	0	5	f	f	f	f	f	f	f	0
cc0ac110-e300-4657-94a9-05eebaf74c42	Try Remind Me later from first one 	Try Remind Me later from first one 	\N	home_banner	medium	announcement	normal	all	open_tool	pediatric-glasses	2025-12-19 22:14:00+00	\N	t	f	\N	\N	t	per_app_open	24	4	\N	t	t	live	\N	\N	\N	\N	f	f	{"cta_icon": "→", "cta_label": "Pediatric glasses", "survey_category": "survey"}	[]	[]	2025-12-20 01:14:48.138769+00	2025-12-20 02:38:13.737323+00	f4271647-c15c-4776-be93-d46fe4185144	f4271647-c15c-4776-be93-d46fe4185144	1	remind_later	3	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	1	0	5	f	f	f	f	f	f	f	2
03f94895-b7d9-4ade-a818-8ddf801a679e	Get More from OcuHub	Sign in within seconds to get full experience from OcuHub.	\N	home_banner	low	announcement	normal	all	open_screen	Login	2025-12-12 23:18:00+00	\N	f	f	\N	\N	f	per_app_open	24	10	\N	t	t	scheduled	\N	\N	\N	\N	f	t	{"cta_icon": "→", "cta_label": "Sign in Now", "thumbnail": "https://ocuhub.com/Icons/cloud.png", "custom_color": "#874efe", "survey_category": "survey"}	[]	[]	2025-12-12 23:27:19.600057+00	2025-12-18 22:17:37.844819+00	f4271647-c15c-4776-be93-d46fe4185144	f4271647-c15c-4776-be93-d46fe4185144	1	no	10	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f	1	0	5	f	f	f	f	f	f	f	0
323a3835-1bc8-4449-b8ea-cb1a762a8bb1	Test Remind Me Later 2 interval. 3 times	First Vierw : 2 - Interval 3 - Max 5 - est Remind Me Later 2 interval. 3 times	\N	home_banner	medium	announcement	normal	all	open_tool	pediatric-glasses	2025-12-19 19:41:00+00	\N	f	f	\N	\N	t	per_app_open	24	2	\N	t	t	scheduled	\N	\N	\N	\N	f	f	{"cta_icon": "→", "cta_label": "Pediatric glasses", "survey_category": "survey"}	[]	[]	2025-12-19 19:48:00.610322+00	2025-12-20 01:16:20.882645+00	f4271647-c15c-4776-be93-d46fe4185144	f4271647-c15c-4776-be93-d46fe4185144	1	remind_later	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	2	0	5	f	f	f	f	f	f	f	1
2bbb2357-e789-4a10-a569-e4f2a54ad7a0	Display 2	Display 2	\N	home_banner	medium	announcement	normal	all	none	\N	2025-12-18 21:32:00+00	\N	f	f	\N	\N	t	once	24	1	\N	t	t	scheduled	\N	\N	\N	\N	f	f	{"cta_icon": "→", "survey_category": "survey"}	[]	[]	2025-12-19 08:45:05.467393+00	2025-12-19 18:58:59.422813+00	f4271647-c15c-4776-be93-d46fe4185144	f4271647-c15c-4776-be93-d46fe4185144	1	yes	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	1	2	5	f	f	f	f	f	f	f	0
c682bd33-ae8f-4a3b-9b4b-c21ee90f622b	Display 3	Display 3	\N	home_banner	high	announcement	normal	all	none	\N	2025-12-18 21:32:00+00	\N	f	f	\N	\N	t	once	24	1	\N	t	t	scheduled	\N	\N	\N	\N	f	f	{"cta_icon": "→", "survey_category": "survey"}	[]	[]	2025-12-19 08:45:40.155922+00	2025-12-19 18:59:04.685576+00	f4271647-c15c-4776-be93-d46fe4185144	f4271647-c15c-4776-be93-d46fe4185144	1	yes	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	1	3	5	f	f	f	f	f	f	f	0
ee5f3d93-6aa0-4c73-8a63-3551f59abdd5	Brief about yourself	Help us personalize your experience	\N	home_banner	high	user_insights	normal	all	none	\N	2025-12-12 21:27:00+00	\N	f	f	\N	\N	t	per_app_open	24	10	\N	t	t	scheduled	\N	\N	\N	\N	t	f	{"cta_icon": "→", "cta_label": "Complete Profile", "thumbnail": "https://ocuhub.com/Icons/introduction.png", "survey_category": "survey", "survey_badge_text": "Get to Know You"}	[{"id": "q_1765575196587", "type": "single_choice", "images": [], "options": ["Ophthalmologist", "Optometrist", "Orthoptist", "GP", "Medical Student", "Other Healthcare Professional", "Not a Medical Professional"], "question": "What is your Profession ?", "required": true, "description": "", "responseActions": [{"actionType": "show_modal", "actionTitle": "", "actionValue": "OcuHub is for eye-care professionals. Please use the app for educational reference only and avoid using any tool for clinical decisions.", "triggerValue": "Not a Medical Professional"}], "linkToUserProfile": "profession"}, {"id": "q_1765580536433", "type": "single_choice", "options": ["Less than 1 year", "1-3 years", "3-5 years", "5-10 years", "10-20 years", "More than 20 years"], "question": "How many years of experience do you have in eye care?", "required": true, "description": "", "linkToUserProfile": "years_experience"}, {"id": "q_1765580684979", "type": "multiple_choice", "options": ["Pediatrics & Strabismus", "Cornea & Anterior Segment", "Glaucoma", "Vitreo-Retinal", "Oculoplastics", "Neuro-Ophthalmology", "General Ophthalmology", "Optometry", "None"], "question": "What Subspecialties are you interested in ? (Can select more than one)", "required": true, "description": "", "linkToUserProfile": "subspecialty"}, {"id": "q_1765580743982", "type": "single_choice", "options": ["Medical student", "Ophthalmology residency or general ophthalmology training", "Postgraduate ophthalmology training (specialist level, supervised practice)", "General ophthalmology practice (independent clinical role)", "Subspecialty training (supervised clinical practice)", "Subspecialty practice (completed advanced training, independent role)", "Academic or research-focused role (PhD or equivalent)", "Other"], "question": "Which best describes your current clinical stage in ophthalmology?", "required": true, "description": "", "linkToUserProfile": "degree"}]	[]	2025-12-12 23:07:45.003189+00	2025-12-19 23:20:16.883385+00	f4271647-c15c-4776-be93-d46fe4185144	f4271647-c15c-4776-be93-d46fe4185144	1	remind_later	10	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	1	0	5	f	f	f	f	f	f	t	0
520ac7fc-38ea-455f-a662-1ec7f156d19b	Emulator Only 	Emulator Only 	\N	home_banner	medium	announcement	normal	all	none	\N	2025-12-19 21:43:00+00	\N	t	f	\N	\N	t	once	24	1	\N	t	t	live	\N	\N	\N	\N	f	f	{"cta_icon": "→", "survey_category": "survey"}	[]	[]	2025-12-20 02:21:40.232502+00	2025-12-20 02:29:03.80094+00	f4271647-c15c-4776-be93-d46fe4185144	f4271647-c15c-4776-be93-d46fe4185144	1	yes	3	1	\N	\N	\N	\N	\N	\N	f	\N	\N	\N	t	1	0	5	f	f	f	f	f	f	f	0
5ffc89fe-e01b-40e5-a147-e53103c33ecc	Display 1	Display 1	\N	home_banner	low	announcement	normal	all	none	\N	2025-12-18 21:32:00+00	\N	f	f	\N	\N	t	once	24	1	\N	t	t	scheduled	\N	\N	\N	\N	f	f	{"cta_icon": "→", "survey_category": "survey"}	[]	[]	2025-12-19 08:45:20.878695+00	2025-12-19 18:58:58.842366+00	f4271647-c15c-4776-be93-d46fe4185144	f4271647-c15c-4776-be93-d46fe4185144	1	yes	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	1	2	5	f	f	f	f	f	f	f	0
3a26dcb0-f1c7-4656-95da-daaf90a8d449	Start in 3rd session 	Start in 3rd session - interval 2 - 3 times - kestenbaum - keep showing after cat	\N	modal	medium	announcement	normal	all	open_tool	kestenbaum-planner	2025-12-18 21:32:00+00	\N	f	f	\N	\N	t	per_app_open	24	3	\N	t	t	scheduled	\N	\N	\N	\N	f	f	{"cta_icon": "→", "cta_label": "Kestenbaum", "survey_category": "survey"}	[]	[]	2025-12-18 21:35:59.216031+00	2025-12-18 22:17:48.305576+00	f4271647-c15c-4776-be93-d46fe4185144	f4271647-c15c-4776-be93-d46fe4185144	1	remind_later	3	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f	2	0	5	f	f	f	f	f	f	f	3
0e7915f5-36de-4e7c-a769-989958338bc4	Non dismissible	Non dismissible	\N	home_banner	medium	announcement	normal	all	none	\N	2025-12-18 21:32:00+00	\N	f	f	\N	\N	f	once	24	1	\N	t	t	scheduled	\N	\N	\N	\N	f	f	{"cta_icon": "→", "survey_category": "survey"}	[]	[]	2025-12-19 08:46:56.705227+00	2025-12-19 19:47:18.040506+00	f4271647-c15c-4776-be93-d46fe4185144	f4271647-c15c-4776-be93-d46fe4185144	1	no	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	1	0	5	f	f	f	f	f	f	f	0
49a4724d-f3ba-4738-985e-f7e1943c7a0e	Try CTA to finish it 	Try CTA to finish it 	\N	home_banner	medium	announcement	normal	all	open_tool	pediatric-glasses	2025-12-19 22:13:00+00	\N	f	f	\N	\N	t	per_app_open	24	2	\N	t	t	scheduled	\N	\N	\N	\N	f	f	{"cta_icon": "→", "cta_label": "Pediatric glasses", "survey_category": "survey"}	[]	[]	2025-12-20 01:14:16.519811+00	2025-12-20 01:18:53.922151+00	f4271647-c15c-4776-be93-d46fe4185144	f4271647-c15c-4776-be93-d46fe4185144	1	remind_later	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	1	0	5	f	f	f	f	f	f	f	0
a1b454ac-fdcb-46d5-940e-f5de9b46f512	All	REela Only	\N	home_banner	medium	announcement	normal	all	none	\N	2025-12-19 23:33:00+00	\N	t	f	\N	\N	t	once	24	1	\N	t	t	live	\N	\N	\N	\N	f	f	{"cta_icon": "→", "survey_category": "survey"}	[]	[]	2025-12-20 02:33:17.081114+00	2025-12-20 03:19:38.385482+00	f4271647-c15c-4776-be93-d46fe4185144	f4271647-c15c-4776-be93-d46fe4185144	1	yes	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	1	0	5	f	f	f	f	f	f	f	0
7fc073b6-d1fa-404e-b443-0fe4d1000f52	Test your Knowledge	What is the most likely Diagnosis for lid Lesion ?	\N	modal	medium	quiz	normal	all	none	\N	2025-12-17 08:04:00+00	\N	f	f	\N	\N	t	per_app_open	24	10	\N	t	t	scheduled	\N	\N	\N	\N	f	f	{"cta_icon": "→", "cta_label": "Test yourself", "thumbnail": "https://eyewiki-images.s3.us-east-va.perf.cloud.ovh.us/8/80/Seborrheic_Blepharitis.jpg", "survey_category": "survey", "survey_badge_text": "Test Your Knowledge"}	[{"id": "q_1765652534217", "type": "single_choice", "images": ["https://eyewiki-images.s3.us-east-va.perf.cloud.ovh.us/8/80/Seborrheic_Blepharitis.jpg", "https://eyewiki-images.s3.us-east-va.perf.cloud.ovh.us/3/3f/Anterior_Blepharitis.jpg"], "options": ["Seborrheic Blepharitis", "Anterior Staphylococcal Blepharitis", "Posterior Blepharitis (MGD)", "Allergic Blepharitis"], "question": "", "required": true, "description": "A patient presents with eyelid scaling and irritation. Based on the image, what is the most likely diagnosis?", "correctAnswer": "Seborrheic Blepharitis", "feedbackWrong": {"actionType": "show_modal", "actionTitle": "Incorrect", "actionValue": "Review the eyelid margin findings and consider conditions associated with greasy scaling.\\n"}, "feedbackCorrect": {"actionType": "show_modal", "actionTitle": "Correct", "actionValue": "This appearance is typical of seborrheic blepharitis, characterized by greasy scales along the eyelid margins."}}]	[]	2025-12-13 19:10:14.180201+00	2025-12-19 19:47:01.422182+00	test-system	f4271647-c15c-4776-be93-d46fe4185144	1	remind_later	10	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	1	0	5	f	f	f	f	f	f	f	0
\.


--
-- Data for Name: app_sessions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.app_sessions (id, user_id, auth_uid, start_time, end_time, public_ip, country, region, city, device_info, app_version, is_active, created_at, updated_at, is_synced, last_synced_at, os_platform, device_brand, device_model, is_device, device_type, os_version, is_location_live, last_live_location_fetched_at, fallback_location_used_at) FROM stdin;
b792efed-2217-40c3-9ba1-a0955a1e50ce	6KAWj7gw9MUig2M8sK021ss8ilu2	6KAWj7gw9MUig2M8sK021ss8ilu2	2025-12-20 02:18:55.586+00	\N	176.18.101.75	Saudi Arabia	Makkah Region	Jeddah	{"brand": "google", "osName": "Android", "isDevice": false, "modelName": "sdk_gphone64_arm64", "osVersion": "16", "deviceType": 1, "supportedCpuArchitectures": ["arm64-v8a"]}	1.0.1	t	2025-12-20 02:19:02.563974+00	2025-12-20 02:19:02.563974+00	t	2025-12-20 02:19:01.332+00	Android	google	sdk_gphone64_arm64	f	1	16	t	\N	\N
cab09e7a-30ac-482d-a039-077f840e7953	6KAWj7gw9MUig2M8sK021ss8ilu2	6KAWj7gw9MUig2M8sK021ss8ilu2	2025-12-20 02:19:08.991+00	\N	176.18.101.75	Saudi Arabia	Makkah Region	Jeddah	{"brand": "google", "osName": "Android", "isDevice": false, "modelName": "sdk_gphone64_arm64", "osVersion": "16", "deviceType": 1, "supportedCpuArchitectures": ["arm64-v8a"]}	1.0.1	t	2025-12-20 02:19:15.784285+00	2025-12-20 02:19:15.784285+00	t	2025-12-20 02:19:14.573+00	Android	google	sdk_gphone64_arm64	f	1	16	t	\N	\N
25ef6e67-8df0-4b2f-9c59-5042c1772286	6KAWj7gw9MUig2M8sK021ss8ilu2	6KAWj7gw9MUig2M8sK021ss8ilu2	2025-12-20 02:19:23.214+00	\N	176.18.101.75	Saudi Arabia	Makkah Region	Jeddah	{"brand": "google", "osName": "Android", "isDevice": false, "modelName": "sdk_gphone64_arm64", "osVersion": "16", "deviceType": 1, "supportedCpuArchitectures": ["arm64-v8a"]}	1.0.1	t	2025-12-20 02:19:29.917342+00	2025-12-20 02:19:29.917342+00	t	2025-12-20 02:19:28.708+00	Android	google	sdk_gphone64_arm64	f	1	16	t	\N	\N
d7429b42-3d34-4f14-b240-576f022ff9ae	6KAWj7gw9MUig2M8sK021ss8ilu2	6KAWj7gw9MUig2M8sK021ss8ilu2	2025-12-20 02:19:34.011+00	2025-12-20 02:19:42.775+00	176.18.101.75	Saudi Arabia	Makkah Region	Jeddah	{"brand": "google", "osName": "Android", "isDevice": false, "modelName": "sdk_gphone64_arm64", "osVersion": "16", "deviceType": 1, "supportedCpuArchitectures": ["arm64-v8a"]}	1.0.1	f	2025-12-20 02:19:49.63418+00	2025-12-20 02:19:49.63418+00	t	2025-12-20 02:19:48.386+00	Android	google	sdk_gphone64_arm64	f	1	16	t	\N	\N
784baee2-a968-428d-a7b1-6c1090b6ae30	6KAWj7gw9MUig2M8sK021ss8ilu2	6KAWj7gw9MUig2M8sK021ss8ilu2	2025-12-20 02:19:42.923+00	\N	176.18.101.75	Saudi Arabia	Makkah Region	Jeddah	{"brand": "google", "osName": "Android", "isDevice": false, "modelName": "sdk_gphone64_arm64", "osVersion": "16", "deviceType": 1, "supportedCpuArchitectures": ["arm64-v8a"]}	1.0.1	t	2025-12-20 02:19:49.63418+00	2025-12-20 02:19:49.63418+00	t	2025-12-20 02:19:48.386+00	Android	google	sdk_gphone64_arm64	f	1	16	t	\N	\N
4dedde5d-eb16-437b-9d0f-232b8aa64427	6KAWj7gw9MUig2M8sK021ss8ilu2	6KAWj7gw9MUig2M8sK021ss8ilu2	2025-12-20 02:20:35.072+00	\N	176.18.101.75	Saudi Arabia	Makkah Region	Jeddah	{"brand": "google", "osName": "Android", "isDevice": false, "modelName": "sdk_gphone64_arm64", "osVersion": "16", "deviceType": 1, "supportedCpuArchitectures": ["arm64-v8a"]}	1.0.1	t	2025-12-20 02:20:42.076907+00	2025-12-20 02:20:42.076907+00	t	2025-12-20 02:20:40.86+00	Android	google	sdk_gphone64_arm64	f	1	16	t	\N	\N
744b0ab4-14ff-4cbe-a950-1764e7e740f7	PuHPi0pRr7ahVOsuT1ZWGlyPO0e2	PuHPi0pRr7ahVOsuT1ZWGlyPO0e2	2025-12-20 02:30:32.569+00	\N	176.18.101.75	Saudi Arabia	Makkah Region	Jeddah	{"brand": "google", "osName": "Android", "isDevice": false, "modelName": "sdk_gphone64_arm64", "osVersion": "16", "deviceType": 1, "supportedCpuArchitectures": ["arm64-v8a"]}	1.0.1	t	2025-12-20 02:30:38.387105+00	2025-12-20 02:30:38.387105+00	t	2025-12-20 02:30:37.986+00	Android	google	sdk_gphone64_arm64	f	1	16	t	\N	\N
fca11130-2c38-4667-b84f-31c06dffe344	pTKXEQqybTbXzfReB8NVBJrLJz83	pTKXEQqybTbXzfReB8NVBJrLJz83	2025-12-20 02:41:02.427+00	\N	176.18.101.75	Saudi Arabia	Makkah Region	Jeddah	{"brand": "google", "osName": "Android", "isDevice": false, "modelName": "sdk_gphone64_arm64", "osVersion": "16", "deviceType": 1, "supportedCpuArchitectures": ["arm64-v8a"]}	1.0.1	t	2025-12-20 02:41:08.381621+00	2025-12-20 02:41:08.381621+00	t	2025-12-20 02:41:07.991+00	Android	google	sdk_gphone64_arm64	f	1	16	t	\N	\N
6a7825ab-ca82-4bd1-806b-84e3c63f7ead	QJANe0IB0oXYA0GNGU3XKj6L1fA3	QJANe0IB0oXYA0GNGU3XKj6L1fA3	2025-12-20 02:45:32.524+00	2025-12-20 02:46:48.095+00	176.18.101.75	Saudi Arabia	Makkah Region	Jeddah	{"brand": "google", "osName": "Android", "isDevice": false, "modelName": "sdk_gphone64_arm64", "osVersion": "16", "deviceType": 1, "supportedCpuArchitectures": ["arm64-v8a"]}	1.0.1	f	2025-12-20 02:45:38.518369+00	2025-12-20 02:46:53.982949+00	t	2025-12-20 02:46:53.592+00	Android	google	sdk_gphone64_arm64	f	1	16	t	\N	\N
afb5689b-84f7-4b1e-928b-4ec013003604	QJANe0IB0oXYA0GNGU3XKj6L1fA3	QJANe0IB0oXYA0GNGU3XKj6L1fA3	2025-12-20 02:46:48.176+00	\N	176.18.101.75	Saudi Arabia	Makkah Region	Jeddah	{"brand": "google", "osName": "Android", "isDevice": false, "modelName": "sdk_gphone64_arm64", "osVersion": "16", "deviceType": 1, "supportedCpuArchitectures": ["arm64-v8a"]}	1.0.1	t	2025-12-20 02:46:53.982949+00	2025-12-20 02:46:53.982949+00	t	2025-12-20 02:46:53.592+00	Android	google	sdk_gphone64_arm64	f	1	16	t	\N	\N
761185da-108b-42d1-b712-e6f9ab06920d	5oxoxEwJPlNsnNYTbONvOSPikbn2	5oxoxEwJPlNsnNYTbONvOSPikbn2	2025-12-20 03:19:03.575+00	\N	176.18.101.75	Saudi Arabia	Makkah Region	Jeddah	{"brand": "google", "osName": "Android", "isDevice": false, "modelName": "sdk_gphone64_arm64", "osVersion": "16", "deviceType": 1, "supportedCpuArchitectures": ["arm64-v8a"]}	1.0.1	t	2025-12-20 03:19:09.592202+00	2025-12-20 03:19:09.592202+00	t	2025-12-20 03:19:09.187+00	Android	google	sdk_gphone64_arm64	f	1	16	t	\N	\N
\.


--
-- Data for Name: app_settings; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.app_settings (user_id, setting_key, auth_uid, setting_value, custom_settings, is_archived, last_updated, created_at, updated_at, is_synced, last_synced_at) FROM stdin;
pTKXEQqybTbXzfReB8NVBJrLJz83	default	pTKXEQqybTbXzfReB8NVBJrLJz83	{"display": {"theme": "light", "fontSize": "medium"}, "general": {"firstLaunch": true, "lastBackupDate": null, "tutorialCompleted": false}, "screenPPI": 140, "vaBadgeSize": "standard", "homeDefaultTab": "commonly-used", "homeToolsCount": 8, "kidsAutoChange": true, "screenDistance": 1.5, "preferredVALines": [{"feet": "20/200", "logMAR": 1, "metric": "6/60", "decimal": 0.1}, {"feet": "20/160", "logMAR": 0.9, "metric": "6/48", "decimal": 0.125}, {"feet": "20/125", "logMAR": 0.8, "metric": "6/37.5", "decimal": 0.16}, {"feet": "20/100", "logMAR": 0.7, "metric": "6/30", "decimal": 0.2}, {"feet": "20/80", "logMAR": 0.6, "metric": "6/24", "decimal": 0.25}, {"feet": "20/60", "logMAR": 0.48, "metric": "6/18", "decimal": 0.33}, {"feet": "20/50", "logMAR": 0.4, "metric": "6/15", "decimal": 0.4}, {"feet": "20/40", "logMAR": 0.3, "metric": "6/12", "decimal": 0.5}, {"feet": "20/30", "logMAR": 0.18, "metric": "6/9", "decimal": 0.67}, {"feet": "20/25", "logMAR": 0.1, "metric": "6/7.5", "decimal": 0.8}, {"feet": "20/20", "logMAR": 0, "metric": "6/6", "decimal": 1}], "visionToolsSound": false, "astigmaticFanSize": 0.95, "astigmaticFanStep": 10, "defaultVANotation": "decimal", "kidsFixationSound": false, "contrastTestVALine": 0.33, "lightTargetPattern": "fixed", "autoSavePreferences": true, "hasCalibratedScreen": false, "kidsAutoChangeTimer": 3, "lightTargetSpotSize": 95, "defaultRedFilterSide": "right", "preventScreenDimming": true, "nearVATestingDistance": 0.4, "screenBrightnessLevel": 1, "calibrationScreenWidth": 0, "calibrationScreenHeight": 0, "defaultCategoryExpansion": "last-used", "redGreenColorCalibration": null, "objectiveVATestingDistance": 0.6, "preferredRetinoscopyWorkingDistance": 0.67}	{"display": {"theme": "light", "fontSize": "medium"}, "general": {"firstLaunch": true, "lastBackupDate": null, "tutorialCompleted": false}, "screenPPI": 140, "vaBadgeSize": "standard", "homeDefaultTab": "commonly-used", "homeToolsCount": 8, "kidsAutoChange": true, "screenDistance": 1.5, "preferredVALines": [{"feet": "20/200", "logMAR": 1, "metric": "6/60", "decimal": 0.1}, {"feet": "20/160", "logMAR": 0.9, "metric": "6/48", "decimal": 0.125}, {"feet": "20/125", "logMAR": 0.8, "metric": "6/37.5", "decimal": 0.16}, {"feet": "20/100", "logMAR": 0.7, "metric": "6/30", "decimal": 0.2}, {"feet": "20/80", "logMAR": 0.6, "metric": "6/24", "decimal": 0.25}, {"feet": "20/60", "logMAR": 0.48, "metric": "6/18", "decimal": 0.33}, {"feet": "20/50", "logMAR": 0.4, "metric": "6/15", "decimal": 0.4}, {"feet": "20/40", "logMAR": 0.3, "metric": "6/12", "decimal": 0.5}, {"feet": "20/30", "logMAR": 0.18, "metric": "6/9", "decimal": 0.67}, {"feet": "20/25", "logMAR": 0.1, "metric": "6/7.5", "decimal": 0.8}, {"feet": "20/20", "logMAR": 0, "metric": "6/6", "decimal": 1}], "visionToolsSound": false, "astigmaticFanSize": 0.95, "astigmaticFanStep": 10, "defaultVANotation": "decimal", "kidsFixationSound": false, "contrastTestVALine": 0.33, "lightTargetPattern": "fixed", "autoSavePreferences": true, "hasCalibratedScreen": false, "kidsAutoChangeTimer": 3, "lightTargetSpotSize": 95, "defaultRedFilterSide": "right", "preventScreenDimming": true, "nearVATestingDistance": 0.4, "screenBrightnessLevel": 1, "calibrationScreenWidth": 0, "calibrationScreenHeight": 0, "defaultCategoryExpansion": "last-used", "redGreenColorCalibration": null, "objectiveVATestingDistance": 0.6, "preferredRetinoscopyWorkingDistance": 0.67}	f	2025-12-20 02:41:02.463+00	2025-12-20 02:41:08.643282+00	2025-12-20 02:41:08.643282+00	t	2025-12-20 02:41:08.244+00
QJANe0IB0oXYA0GNGU3XKj6L1fA3	default	QJANe0IB0oXYA0GNGU3XKj6L1fA3	{"display": {"theme": "light", "fontSize": "medium"}, "general": {"firstLaunch": true, "lastBackupDate": null, "tutorialCompleted": false}, "screenPPI": 140, "vaBadgeSize": "standard", "homeDefaultTab": "commonly-used", "homeToolsCount": 8, "kidsAutoChange": true, "screenDistance": 1.5, "preferredVALines": [{"feet": "20/200", "logMAR": 1, "metric": "6/60", "decimal": 0.1}, {"feet": "20/160", "logMAR": 0.9, "metric": "6/48", "decimal": 0.125}, {"feet": "20/125", "logMAR": 0.8, "metric": "6/37.5", "decimal": 0.16}, {"feet": "20/100", "logMAR": 0.7, "metric": "6/30", "decimal": 0.2}, {"feet": "20/80", "logMAR": 0.6, "metric": "6/24", "decimal": 0.25}, {"feet": "20/60", "logMAR": 0.48, "metric": "6/18", "decimal": 0.33}, {"feet": "20/50", "logMAR": 0.4, "metric": "6/15", "decimal": 0.4}, {"feet": "20/40", "logMAR": 0.3, "metric": "6/12", "decimal": 0.5}, {"feet": "20/30", "logMAR": 0.18, "metric": "6/9", "decimal": 0.67}, {"feet": "20/25", "logMAR": 0.1, "metric": "6/7.5", "decimal": 0.8}, {"feet": "20/20", "logMAR": 0, "metric": "6/6", "decimal": 1}], "visionToolsSound": false, "astigmaticFanSize": 0.95, "astigmaticFanStep": 10, "defaultVANotation": "decimal", "kidsFixationSound": false, "contrastTestVALine": 0.33, "lightTargetPattern": "fixed", "autoSavePreferences": true, "hasCalibratedScreen": false, "kidsAutoChangeTimer": 3, "lightTargetSpotSize": 95, "defaultRedFilterSide": "right", "preventScreenDimming": true, "nearVATestingDistance": 0.4, "screenBrightnessLevel": 1, "calibrationScreenWidth": 0, "calibrationScreenHeight": 0, "defaultCategoryExpansion": "last-used", "redGreenColorCalibration": null, "objectiveVATestingDistance": 0.6, "preferredRetinoscopyWorkingDistance": 0.67}	{"display": {"theme": "light", "fontSize": "medium"}, "general": {"firstLaunch": true, "lastBackupDate": null, "tutorialCompleted": false}, "screenPPI": 140, "vaBadgeSize": "standard", "homeDefaultTab": "commonly-used", "homeToolsCount": 8, "kidsAutoChange": true, "screenDistance": 1.5, "preferredVALines": [{"feet": "20/200", "logMAR": 1, "metric": "6/60", "decimal": 0.1}, {"feet": "20/160", "logMAR": 0.9, "metric": "6/48", "decimal": 0.125}, {"feet": "20/125", "logMAR": 0.8, "metric": "6/37.5", "decimal": 0.16}, {"feet": "20/100", "logMAR": 0.7, "metric": "6/30", "decimal": 0.2}, {"feet": "20/80", "logMAR": 0.6, "metric": "6/24", "decimal": 0.25}, {"feet": "20/60", "logMAR": 0.48, "metric": "6/18", "decimal": 0.33}, {"feet": "20/50", "logMAR": 0.4, "metric": "6/15", "decimal": 0.4}, {"feet": "20/40", "logMAR": 0.3, "metric": "6/12", "decimal": 0.5}, {"feet": "20/30", "logMAR": 0.18, "metric": "6/9", "decimal": 0.67}, {"feet": "20/25", "logMAR": 0.1, "metric": "6/7.5", "decimal": 0.8}, {"feet": "20/20", "logMAR": 0, "metric": "6/6", "decimal": 1}], "visionToolsSound": false, "astigmaticFanSize": 0.95, "astigmaticFanStep": 10, "defaultVANotation": "decimal", "kidsFixationSound": false, "contrastTestVALine": 0.33, "lightTargetPattern": "fixed", "autoSavePreferences": true, "hasCalibratedScreen": false, "kidsAutoChangeTimer": 3, "lightTargetSpotSize": 95, "defaultRedFilterSide": "right", "preventScreenDimming": true, "nearVATestingDistance": 0.4, "screenBrightnessLevel": 1, "calibrationScreenWidth": 0, "calibrationScreenHeight": 0, "defaultCategoryExpansion": "last-used", "redGreenColorCalibration": null, "objectiveVATestingDistance": 0.6, "preferredRetinoscopyWorkingDistance": 0.67}	f	2025-12-20 02:46:48.223+00	2025-12-20 02:45:38.749416+00	2025-12-20 02:46:54.174138+00	t	2025-12-20 02:46:53.768+00
6KAWj7gw9MUig2M8sK021ss8ilu2	default	6KAWj7gw9MUig2M8sK021ss8ilu2	{"display": {"theme": "light", "fontSize": "medium"}, "general": {"firstLaunch": true, "lastBackupDate": null, "tutorialCompleted": false}, "screenPPI": 140, "vaBadgeSize": "standard", "homeDefaultTab": "commonly-used", "homeToolsCount": 8, "kidsAutoChange": true, "screenDistance": 1.5, "preferredVALines": [{"feet": "20/200", "logMAR": 1, "metric": "6/60", "decimal": 0.1}, {"feet": "20/160", "logMAR": 0.9, "metric": "6/48", "decimal": 0.125}, {"feet": "20/125", "logMAR": 0.8, "metric": "6/37.5", "decimal": 0.16}, {"feet": "20/100", "logMAR": 0.7, "metric": "6/30", "decimal": 0.2}, {"feet": "20/80", "logMAR": 0.6, "metric": "6/24", "decimal": 0.25}, {"feet": "20/60", "logMAR": 0.48, "metric": "6/18", "decimal": 0.33}, {"feet": "20/50", "logMAR": 0.4, "metric": "6/15", "decimal": 0.4}, {"feet": "20/40", "logMAR": 0.3, "metric": "6/12", "decimal": 0.5}, {"feet": "20/30", "logMAR": 0.18, "metric": "6/9", "decimal": 0.67}, {"feet": "20/25", "logMAR": 0.1, "metric": "6/7.5", "decimal": 0.8}, {"feet": "20/20", "logMAR": 0, "metric": "6/6", "decimal": 1}], "visionToolsSound": false, "astigmaticFanSize": 0.95, "astigmaticFanStep": 10, "defaultVANotation": "decimal", "kidsFixationSound": false, "contrastTestVALine": 0.33, "lightTargetPattern": "fixed", "autoSavePreferences": true, "hasCalibratedScreen": false, "kidsAutoChangeTimer": 3, "lightTargetSpotSize": 95, "defaultRedFilterSide": "right", "preventScreenDimming": true, "announcementSessionId": 6, "nearVATestingDistance": 0.4, "screenBrightnessLevel": 1, "calibrationScreenWidth": 0, "calibrationScreenHeight": 0, "defaultCategoryExpansion": "last-used", "redGreenColorCalibration": null, "objectiveVATestingDistance": 0.6, "preferredRetinoscopyWorkingDistance": 0.67}	{"display": {"theme": "light", "fontSize": "medium"}, "general": {"firstLaunch": true, "lastBackupDate": null, "tutorialCompleted": false}, "screenPPI": 140, "vaBadgeSize": "standard", "homeDefaultTab": "commonly-used", "homeToolsCount": 8, "kidsAutoChange": true, "screenDistance": 1.5, "preferredVALines": [{"feet": "20/200", "logMAR": 1, "metric": "6/60", "decimal": 0.1}, {"feet": "20/160", "logMAR": 0.9, "metric": "6/48", "decimal": 0.125}, {"feet": "20/125", "logMAR": 0.8, "metric": "6/37.5", "decimal": 0.16}, {"feet": "20/100", "logMAR": 0.7, "metric": "6/30", "decimal": 0.2}, {"feet": "20/80", "logMAR": 0.6, "metric": "6/24", "decimal": 0.25}, {"feet": "20/60", "logMAR": 0.48, "metric": "6/18", "decimal": 0.33}, {"feet": "20/50", "logMAR": 0.4, "metric": "6/15", "decimal": 0.4}, {"feet": "20/40", "logMAR": 0.3, "metric": "6/12", "decimal": 0.5}, {"feet": "20/30", "logMAR": 0.18, "metric": "6/9", "decimal": 0.67}, {"feet": "20/25", "logMAR": 0.1, "metric": "6/7.5", "decimal": 0.8}, {"feet": "20/20", "logMAR": 0, "metric": "6/6", "decimal": 1}], "visionToolsSound": false, "astigmaticFanSize": 0.95, "astigmaticFanStep": 10, "defaultVANotation": "decimal", "kidsFixationSound": false, "contrastTestVALine": 0.33, "lightTargetPattern": "fixed", "autoSavePreferences": true, "hasCalibratedScreen": false, "kidsAutoChangeTimer": 3, "lightTargetSpotSize": 95, "defaultRedFilterSide": "right", "preventScreenDimming": true, "announcementSessionId": 6, "nearVATestingDistance": 0.4, "screenBrightnessLevel": 1, "calibrationScreenWidth": 0, "calibrationScreenHeight": 0, "defaultCategoryExpansion": "last-used", "redGreenColorCalibration": null, "objectiveVATestingDistance": 0.6, "preferredRetinoscopyWorkingDistance": 0.67}	f	2025-12-20 02:20:40.225+00	2025-12-20 02:19:02.774365+00	2025-12-20 02:20:42.266141+00	t	2025-12-20 02:20:41.042+00
PuHPi0pRr7ahVOsuT1ZWGlyPO0e2	default	PuHPi0pRr7ahVOsuT1ZWGlyPO0e2	{"display": {"theme": "light", "fontSize": "medium"}, "general": {"firstLaunch": true, "lastBackupDate": null, "tutorialCompleted": false}, "screenPPI": 140, "vaBadgeSize": "standard", "homeDefaultTab": "commonly-used", "homeToolsCount": 8, "kidsAutoChange": true, "screenDistance": 1.5, "preferredVALines": [{"feet": "20/200", "logMAR": 1, "metric": "6/60", "decimal": 0.1}, {"feet": "20/160", "logMAR": 0.9, "metric": "6/48", "decimal": 0.125}, {"feet": "20/125", "logMAR": 0.8, "metric": "6/37.5", "decimal": 0.16}, {"feet": "20/100", "logMAR": 0.7, "metric": "6/30", "decimal": 0.2}, {"feet": "20/80", "logMAR": 0.6, "metric": "6/24", "decimal": 0.25}, {"feet": "20/60", "logMAR": 0.48, "metric": "6/18", "decimal": 0.33}, {"feet": "20/50", "logMAR": 0.4, "metric": "6/15", "decimal": 0.4}, {"feet": "20/40", "logMAR": 0.3, "metric": "6/12", "decimal": 0.5}, {"feet": "20/30", "logMAR": 0.18, "metric": "6/9", "decimal": 0.67}, {"feet": "20/25", "logMAR": 0.1, "metric": "6/7.5", "decimal": 0.8}, {"feet": "20/20", "logMAR": 0, "metric": "6/6", "decimal": 1}], "visionToolsSound": false, "astigmaticFanSize": 0.95, "astigmaticFanStep": 10, "defaultVANotation": "decimal", "kidsFixationSound": false, "contrastTestVALine": 0.33, "lightTargetPattern": "fixed", "autoSavePreferences": true, "hasCalibratedScreen": false, "kidsAutoChangeTimer": 3, "lightTargetSpotSize": 95, "defaultRedFilterSide": "right", "preventScreenDimming": true, "nearVATestingDistance": 0.4, "screenBrightnessLevel": 1, "calibrationScreenWidth": 0, "calibrationScreenHeight": 0, "defaultCategoryExpansion": "last-used", "redGreenColorCalibration": null, "objectiveVATestingDistance": 0.6, "preferredRetinoscopyWorkingDistance": 0.67}	{"display": {"theme": "light", "fontSize": "medium"}, "general": {"firstLaunch": true, "lastBackupDate": null, "tutorialCompleted": false}, "screenPPI": 140, "vaBadgeSize": "standard", "homeDefaultTab": "commonly-used", "homeToolsCount": 8, "kidsAutoChange": true, "screenDistance": 1.5, "preferredVALines": [{"feet": "20/200", "logMAR": 1, "metric": "6/60", "decimal": 0.1}, {"feet": "20/160", "logMAR": 0.9, "metric": "6/48", "decimal": 0.125}, {"feet": "20/125", "logMAR": 0.8, "metric": "6/37.5", "decimal": 0.16}, {"feet": "20/100", "logMAR": 0.7, "metric": "6/30", "decimal": 0.2}, {"feet": "20/80", "logMAR": 0.6, "metric": "6/24", "decimal": 0.25}, {"feet": "20/60", "logMAR": 0.48, "metric": "6/18", "decimal": 0.33}, {"feet": "20/50", "logMAR": 0.4, "metric": "6/15", "decimal": 0.4}, {"feet": "20/40", "logMAR": 0.3, "metric": "6/12", "decimal": 0.5}, {"feet": "20/30", "logMAR": 0.18, "metric": "6/9", "decimal": 0.67}, {"feet": "20/25", "logMAR": 0.1, "metric": "6/7.5", "decimal": 0.8}, {"feet": "20/20", "logMAR": 0, "metric": "6/6", "decimal": 1}], "visionToolsSound": false, "astigmaticFanSize": 0.95, "astigmaticFanStep": 10, "defaultVANotation": "decimal", "kidsFixationSound": false, "contrastTestVALine": 0.33, "lightTargetPattern": "fixed", "autoSavePreferences": true, "hasCalibratedScreen": false, "kidsAutoChangeTimer": 3, "lightTargetSpotSize": 95, "defaultRedFilterSide": "right", "preventScreenDimming": true, "nearVATestingDistance": 0.4, "screenBrightnessLevel": 1, "calibrationScreenWidth": 0, "calibrationScreenHeight": 0, "defaultCategoryExpansion": "last-used", "redGreenColorCalibration": null, "objectiveVATestingDistance": 0.6, "preferredRetinoscopyWorkingDistance": 0.67}	f	2025-12-20 02:30:32.602+00	2025-12-20 02:30:38.700521+00	2025-12-20 02:30:38.700521+00	t	2025-12-20 02:30:38.288+00
u3DNVVvNMNU6Ct2rpA5hYZ1fPUd2	default	u3DNVVvNMNU6Ct2rpA5hYZ1fPUd2	{"display": {"theme": "light", "fontSize": "medium"}, "general": {"firstLaunch": true, "lastBackupDate": null, "tutorialCompleted": false}, "screenPPI": 140, "vaBadgeSize": "standard", "homeDefaultTab": "commonly-used", "homeToolsCount": 8, "kidsAutoChange": true, "screenDistance": 1.5, "preferredVALines": [{"feet": "20/200", "logMAR": 1, "metric": "6/60", "decimal": 0.1}, {"feet": "20/160", "logMAR": 0.9, "metric": "6/48", "decimal": 0.125}, {"feet": "20/125", "logMAR": 0.8, "metric": "6/37.5", "decimal": 0.16}, {"feet": "20/100", "logMAR": 0.7, "metric": "6/30", "decimal": 0.2}, {"feet": "20/80", "logMAR": 0.6, "metric": "6/24", "decimal": 0.25}, {"feet": "20/60", "logMAR": 0.48, "metric": "6/18", "decimal": 0.33}, {"feet": "20/50", "logMAR": 0.4, "metric": "6/15", "decimal": 0.4}, {"feet": "20/40", "logMAR": 0.3, "metric": "6/12", "decimal": 0.5}, {"feet": "20/30", "logMAR": 0.18, "metric": "6/9", "decimal": 0.67}, {"feet": "20/25", "logMAR": 0.1, "metric": "6/7.5", "decimal": 0.8}, {"feet": "20/20", "logMAR": 0, "metric": "6/6", "decimal": 1}], "visionToolsSound": false, "astigmaticFanSize": 0.95, "astigmaticFanStep": 10, "defaultVANotation": "decimal", "kidsFixationSound": false, "contrastTestVALine": 0.33, "lightTargetPattern": "fixed", "autoSavePreferences": true, "hasCalibratedScreen": false, "kidsAutoChangeTimer": 3, "lightTargetSpotSize": 95, "defaultRedFilterSide": "right", "preventScreenDimming": true, "nearVATestingDistance": 0.4, "screenBrightnessLevel": 1, "calibrationScreenWidth": 0, "calibrationScreenHeight": 0, "defaultCategoryExpansion": "last-used", "redGreenColorCalibration": null, "objectiveVATestingDistance": 0.6, "preferredRetinoscopyWorkingDistance": 0.67}	{"display": {"theme": "light", "fontSize": "medium"}, "general": {"firstLaunch": true, "lastBackupDate": null, "tutorialCompleted": false}, "screenPPI": 140, "vaBadgeSize": "standard", "homeDefaultTab": "commonly-used", "homeToolsCount": 8, "kidsAutoChange": true, "screenDistance": 1.5, "preferredVALines": [{"feet": "20/200", "logMAR": 1, "metric": "6/60", "decimal": 0.1}, {"feet": "20/160", "logMAR": 0.9, "metric": "6/48", "decimal": 0.125}, {"feet": "20/125", "logMAR": 0.8, "metric": "6/37.5", "decimal": 0.16}, {"feet": "20/100", "logMAR": 0.7, "metric": "6/30", "decimal": 0.2}, {"feet": "20/80", "logMAR": 0.6, "metric": "6/24", "decimal": 0.25}, {"feet": "20/60", "logMAR": 0.48, "metric": "6/18", "decimal": 0.33}, {"feet": "20/50", "logMAR": 0.4, "metric": "6/15", "decimal": 0.4}, {"feet": "20/40", "logMAR": 0.3, "metric": "6/12", "decimal": 0.5}, {"feet": "20/30", "logMAR": 0.18, "metric": "6/9", "decimal": 0.67}, {"feet": "20/25", "logMAR": 0.1, "metric": "6/7.5", "decimal": 0.8}, {"feet": "20/20", "logMAR": 0, "metric": "6/6", "decimal": 1}], "visionToolsSound": false, "astigmaticFanSize": 0.95, "astigmaticFanStep": 10, "defaultVANotation": "decimal", "kidsFixationSound": false, "contrastTestVALine": 0.33, "lightTargetPattern": "fixed", "autoSavePreferences": true, "hasCalibratedScreen": false, "kidsAutoChangeTimer": 3, "lightTargetSpotSize": 95, "defaultRedFilterSide": "right", "preventScreenDimming": true, "nearVATestingDistance": 0.4, "screenBrightnessLevel": 1, "calibrationScreenWidth": 0, "calibrationScreenHeight": 0, "defaultCategoryExpansion": "last-used", "redGreenColorCalibration": null, "objectiveVATestingDistance": 0.6, "preferredRetinoscopyWorkingDistance": 0.67}	f	2025-12-20 02:56:08.938+00	2025-12-20 03:10:58.870609+00	2025-12-20 03:10:58.870609+00	t	2025-12-20 03:10:58.391+00
5oxoxEwJPlNsnNYTbONvOSPikbn2	default	5oxoxEwJPlNsnNYTbONvOSPikbn2	{"display": {"theme": "light", "fontSize": "medium"}, "general": {"firstLaunch": true, "lastBackupDate": null, "tutorialCompleted": false}, "screenPPI": 140, "vaBadgeSize": "standard", "homeDefaultTab": "commonly-used", "homeToolsCount": 8, "kidsAutoChange": true, "screenDistance": 1.5, "preferredVALines": [{"feet": "20/200", "logMAR": 1, "metric": "6/60", "decimal": 0.1}, {"feet": "20/160", "logMAR": 0.9, "metric": "6/48", "decimal": 0.125}, {"feet": "20/125", "logMAR": 0.8, "metric": "6/37.5", "decimal": 0.16}, {"feet": "20/100", "logMAR": 0.7, "metric": "6/30", "decimal": 0.2}, {"feet": "20/80", "logMAR": 0.6, "metric": "6/24", "decimal": 0.25}, {"feet": "20/60", "logMAR": 0.48, "metric": "6/18", "decimal": 0.33}, {"feet": "20/50", "logMAR": 0.4, "metric": "6/15", "decimal": 0.4}, {"feet": "20/40", "logMAR": 0.3, "metric": "6/12", "decimal": 0.5}, {"feet": "20/30", "logMAR": 0.18, "metric": "6/9", "decimal": 0.67}, {"feet": "20/25", "logMAR": 0.1, "metric": "6/7.5", "decimal": 0.8}, {"feet": "20/20", "logMAR": 0, "metric": "6/6", "decimal": 1}], "visionToolsSound": false, "astigmaticFanSize": 0.95, "astigmaticFanStep": 10, "defaultVANotation": "decimal", "kidsFixationSound": false, "contrastTestVALine": 0.33, "lightTargetPattern": "fixed", "autoSavePreferences": true, "hasCalibratedScreen": false, "kidsAutoChangeTimer": 3, "lightTargetSpotSize": 95, "defaultRedFilterSide": "right", "preventScreenDimming": true, "nearVATestingDistance": 0.4, "screenBrightnessLevel": 1, "calibrationScreenWidth": 0, "calibrationScreenHeight": 0, "defaultCategoryExpansion": "last-used", "redGreenColorCalibration": null, "objectiveVATestingDistance": 0.6, "preferredRetinoscopyWorkingDistance": 0.67}	{"display": {"theme": "light", "fontSize": "medium"}, "general": {"firstLaunch": true, "lastBackupDate": null, "tutorialCompleted": false}, "screenPPI": 140, "vaBadgeSize": "standard", "homeDefaultTab": "commonly-used", "homeToolsCount": 8, "kidsAutoChange": true, "screenDistance": 1.5, "preferredVALines": [{"feet": "20/200", "logMAR": 1, "metric": "6/60", "decimal": 0.1}, {"feet": "20/160", "logMAR": 0.9, "metric": "6/48", "decimal": 0.125}, {"feet": "20/125", "logMAR": 0.8, "metric": "6/37.5", "decimal": 0.16}, {"feet": "20/100", "logMAR": 0.7, "metric": "6/30", "decimal": 0.2}, {"feet": "20/80", "logMAR": 0.6, "metric": "6/24", "decimal": 0.25}, {"feet": "20/60", "logMAR": 0.48, "metric": "6/18", "decimal": 0.33}, {"feet": "20/50", "logMAR": 0.4, "metric": "6/15", "decimal": 0.4}, {"feet": "20/40", "logMAR": 0.3, "metric": "6/12", "decimal": 0.5}, {"feet": "20/30", "logMAR": 0.18, "metric": "6/9", "decimal": 0.67}, {"feet": "20/25", "logMAR": 0.1, "metric": "6/7.5", "decimal": 0.8}, {"feet": "20/20", "logMAR": 0, "metric": "6/6", "decimal": 1}], "visionToolsSound": false, "astigmaticFanSize": 0.95, "astigmaticFanStep": 10, "defaultVANotation": "decimal", "kidsFixationSound": false, "contrastTestVALine": 0.33, "lightTargetPattern": "fixed", "autoSavePreferences": true, "hasCalibratedScreen": false, "kidsAutoChangeTimer": 3, "lightTargetSpotSize": 95, "defaultRedFilterSide": "right", "preventScreenDimming": true, "nearVATestingDistance": 0.4, "screenBrightnessLevel": 1, "calibrationScreenWidth": 0, "calibrationScreenHeight": 0, "defaultCategoryExpansion": "last-used", "redGreenColorCalibration": null, "objectiveVATestingDistance": 0.6, "preferredRetinoscopyWorkingDistance": 0.67}	f	2025-12-20 03:19:03.601+00	2025-12-20 03:19:09.86585+00	2025-12-20 03:19:09.86585+00	t	2025-12-20 03:19:09.423+00
\.


--
-- Data for Name: category_settings; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.category_settings (user_id, category_id, auth_uid, settings, sort_order, is_expanded, is_visible, is_archived, created_at, updated_at, is_synced, last_synced_at) FROM stdin;
\.


--
-- Data for Name: credit_asset_types; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.credit_asset_types (id, name, display_name, description, icon, sort_order, is_active, created_at, updated_at) FROM stdin;
16225d44-5407-42c8-b0cd-a9afe1d8610e	icon	Icons	Icon assets used throughout the application	shapes-outline	1	t	2025-12-13 16:11:58.226231+00	2025-12-13 16:11:58.226231+00
0156ba84-a807-45ff-91dc-9c2da558d349	illustration	Illustrations	Illustration and vector graphics	brush-outline	2	t	2025-12-13 16:11:58.226231+00	2025-12-13 16:11:58.226231+00
ab84ff65-2f92-4c17-a62d-c78ca78c0efe	image	Images	Photographic and raster images	image-outline	3	t	2025-12-13 16:11:58.226231+00	2025-12-13 16:11:58.226231+00
57ad3078-d652-48d6-9b89-f402ae2aa122	animation	Animations	Animated graphics and Lottie files	play-outline	4	t	2025-12-13 16:11:58.226231+00	2025-12-13 16:11:58.226231+00
24119eb2-c19b-491b-a20e-0e207cfe4d25	font	Fonts	Typography and font families	text-outline	5	t	2025-12-13 16:11:58.226231+00	2025-12-13 16:11:58.226231+00
88722b82-31e4-4661-b426-e6506cdfecbd	sound	Sounds	Audio and sound effects	musical-notes-outline	6	t	2025-12-13 16:11:58.226231+00	2025-12-13 16:11:58.226231+00
\.


--
-- Data for Name: credit_links; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.credit_links (id, site_id, title, url, author, description, sort_order, is_active, created_at, updated_at) FROM stdin;
9e69f0c5-e85b-4ca3-a87f-d14120ee6443	3efea691-607f-49ea-8119-ea6913b13a32	Introduction icon	https://www.flaticon.com/free-icon/introduction_6352943?term=introduce&page=1&position=21&origin=search&related_id=6352943	\N	\N	0	t	2025-12-13 16:23:22.248994+00	2025-12-13 16:23:22.248994+00
6c2367d2-8986-46fd-9e4b-2f7047158b31	3efea691-607f-49ea-8119-ea6913b13a32	LASIK Icon	https://www.flaticon.com/free-icon/lasik_2695547?term=lasik&page=1&position=8&origin=search&related_id=2695547	\N	\N	0	t	2025-12-13 16:23:51.808169+00	2025-12-13 16:23:51.808169+00
8c5eff3d-71f2-4089-b2b1-831d53b21620	3efea691-607f-49ea-8119-ea6913b13a32	Login Icon	https://www.flaticon.com/free-icon/cloud_5919385	\N	\N	0	t	2025-12-13 16:23:33.091796+00	2025-12-13 16:24:59.01028+00
\.


--
-- Data for Name: credit_sites; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.credit_sites (id, asset_type_id, name, display_name, website_url, attribution_format, description, logo_url, sort_order, is_active, created_at, updated_at) FROM stdin;
3efea691-607f-49ea-8119-ea6913b13a32	16225d44-5407-42c8-b0cd-a9afe1d8610e	Aficons studio - Flaticon	Aficons studio - Flaticon	https://www.flaticon.com	\N	Free vector icons	\N	1	t	2025-12-13 16:11:58.226231+00	2025-12-13 16:20:11.612597+00
\.


--
-- Data for Name: feedbacks; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.feedbacks (id, user_id, auth_uid, type, message, tool_id, screen_state, conclusion_data, rating, metadata, submitted_at, created_at, updated_at, is_synced, last_synced_at) FROM stdin;
\.


--
-- Data for Name: screen_settings; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.screen_settings (user_id, screen_id, auth_uid, settings, is_archived, created_at, updated_at, is_synced, last_synced_at) FROM stdin;
\.


--
-- Data for Name: section_settings; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.section_settings (user_id, section_id, auth_uid, settings, filters, is_archived, last_updated, created_at, updated_at, is_synced, last_synced_at) FROM stdin;
6KAWj7gw9MUig2M8sK021ss8ilu2	decision-support	6KAWj7gw9MUig2M8sK021ss8ilu2	\N	{"sortOption": "default", "searchQuery": "", "showFavoritesOnly": false}	f	2025-12-20 02:20:40.188+00	2025-12-20 02:20:42.440149+00	2025-12-20 02:20:42.440149+00	t	2025-12-20 02:20:41.23+00
\.


--
-- Data for Name: tool_settings; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.tool_settings (user_id, tool_id, auth_uid, settings, is_favourite, order_in_app, order_in_category, order_in_section, usage_count, usage_duration_sec, last_used_at, is_archived, last_updated, created_at, updated_at, is_synced, last_synced_at) FROM stdin;
6KAWj7gw9MUig2M8sK021ss8ilu2	pediatric-glasses	6KAWj7gw9MUig2M8sK021ss8ilu2	\N	f	0	0	0	1	0	2025-12-20 02:20:40.108+00	f	2025-12-20 02:20:40.108+00	2025-12-20 02:20:42.653279+00	2025-12-20 02:20:42.653279+00	t	2025-12-20 02:20:41.442+00
\.


--
-- Data for Name: tool_usage_events; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.tool_usage_events (id, user_id, auth_uid, tool_id, tool_session_id, app_session_id, event_type, event_timestamp, event_data, created_at, is_synced, last_synced_at) FROM stdin;
01d30056-55ec-402b-9e0d-dcfb1f0b6f7a	6KAWj7gw9MUig2M8sK021ss8ilu2	6KAWj7gw9MUig2M8sK021ss8ilu2	pediatric-glasses	c93b8aed-a0ce-4c15-ad3a-e9b4d1a2b7ae	4dedde5d-eb16-437b-9d0f-232b8aa64427	open	2025-12-20 02:20:40.369+00	{"section": "", "category": "Pediatrics", "toolName": "Pediatric Glasses"}	2025-12-20 02:20:42.984291+00	t	2025-12-20 02:20:41.692+00
\.


--
-- Data for Name: tool_usage_summary; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.tool_usage_summary (id, tool_slug, tool_name, usage_count, total_duration_seconds, days_used, months_used, years_used, last_used_at, unique_users, session_count, country_count, city_count, avg_usage_per_user, avg_time_per_user_seconds, avg_calc_time_ms, usage_by_date, duration_by_date, country_breakdown, updated_at) FROM stdin;
\.


--
-- Data for Name: user_announcement_state; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.user_announcement_state (id, announcement_id, user_id, status, first_seen_at, last_seen_at, dismissed_at, deferred_at, completed_at, defer_count, defer_until_session, defer_until_time, impression_count, is_partially_completed, questions_answered, created_at, updated_at, last_seen_session) FROM stdin;
513f3bcb-31a5-41f5-8397-9253c72e3661	cc0ac110-e300-4657-94a9-05eebaf74c42	6KAWj7gw9MUig2M8sK021ss8ilu2	completed	2025-12-20 02:19:01.639333+00	2025-12-20 02:20:41.158951+00	\N	\N	2025-12-20 02:20:41.158951+00	0	\N	\N	4	f	0	2025-12-20 02:19:01.639333+00	2025-12-20 02:20:41.158951+00	7
751a5d3a-0f0f-47d1-b042-b01a6a60a397	520ac7fc-38ea-455f-a662-1ec7f156d19b	6XOrRdbJ7BNZfE15dyAAGCmMu9g1	seen	2025-12-20 02:22:04.768456+00	2025-12-20 02:22:04.768456+00	\N	\N	\N	0	\N	\N	1	f	0	2025-12-20 02:22:04.768456+00	2025-12-20 02:22:04.768456+00	1
9de9b267-67c1-444b-8a71-37f33ee489df	520ac7fc-38ea-455f-a662-1ec7f156d19b	DN2C6pvgYoVybrHLch3Kaowkz0z1	seen	2025-12-20 02:22:49.591528+00	2025-12-20 02:22:49.591528+00	\N	\N	\N	0	\N	\N	1	f	0	2025-12-20 02:22:49.591528+00	2025-12-20 02:22:49.591528+00	1
ab4d684d-3f79-4780-b140-c2e1bf713f97	520ac7fc-38ea-455f-a662-1ec7f156d19b	XaL6JtOLNfMTOYaUgWSgq4iXKiW2	seen	2025-12-20 02:32:57.091763+00	2025-12-20 02:32:57.091763+00	\N	\N	\N	0	\N	\N	1	f	0	2025-12-20 02:32:57.091763+00	2025-12-20 02:32:57.091763+00	1
ca6da1fc-6727-48df-ae31-f6c7194445c2	520ac7fc-38ea-455f-a662-1ec7f156d19b	qiXJkZAh6jX47lsnodop0VLwwnC3	seen	2025-12-20 02:34:29.631295+00	2025-12-20 02:34:29.631295+00	\N	\N	\N	0	\N	\N	1	f	0	2025-12-20 02:34:29.631295+00	2025-12-20 02:34:29.631295+00	1
b844598f-f5dc-4818-a189-464606dbe306	520ac7fc-38ea-455f-a662-1ec7f156d19b	67unKl4JZYfMnu9Y1gAgkwOxuCB3	seen	2025-12-20 02:35:03.71809+00	2025-12-20 02:35:03.71809+00	\N	\N	\N	0	\N	\N	1	f	0	2025-12-20 02:35:03.71809+00	2025-12-20 02:35:03.71809+00	1
bd8d70fc-e293-4f02-bd8b-999cea953dca	520ac7fc-38ea-455f-a662-1ec7f156d19b	HMxCgyHFP3ZhaaZk19YP0EBWQkN2	seen	2025-12-20 02:37:35.436409+00	2025-12-20 02:37:35.436409+00	\N	\N	\N	0	\N	\N	1	f	0	2025-12-20 02:37:35.436409+00	2025-12-20 02:37:35.436409+00	1
d6b5b516-30ee-4572-be5a-2b01069743ef	a1b454ac-fdcb-46d5-940e-f5de9b46f512	HMxCgyHFP3ZhaaZk19YP0EBWQkN2	seen	2025-12-20 02:38:05.57532+00	2025-12-20 02:38:05.57532+00	\N	\N	\N	0	\N	\N	1	f	0	2025-12-20 02:38:05.57532+00	2025-12-20 02:38:05.57532+00	1
4a97afbc-2093-49af-9e75-a702fc92a90f	a1b454ac-fdcb-46d5-940e-f5de9b46f512	pTKXEQqybTbXzfReB8NVBJrLJz83	seen	2025-12-20 02:40:55.546192+00	2025-12-20 02:40:55.546192+00	\N	\N	\N	0	\N	\N	1	f	0	2025-12-20 02:40:55.546192+00	2025-12-20 02:40:55.546192+00	1
851c21f7-dfe6-48ef-a49f-c8d7d5b45e8c	cc0ac110-e300-4657-94a9-05eebaf74c42	pTKXEQqybTbXzfReB8NVBJrLJz83	seen	2025-12-20 02:41:07.400541+00	2025-12-20 02:41:07.400541+00	\N	\N	\N	0	\N	\N	1	f	0	2025-12-20 02:41:07.400541+00	2025-12-20 02:41:07.400541+00	2
e7a57629-4701-429e-84cd-fb15350b7944	520ac7fc-38ea-455f-a662-1ec7f156d19b	daGDWgXECDgq9HcI65Of3bewpAF3	seen	2025-12-20 02:41:44.58695+00	2025-12-20 02:41:44.58695+00	\N	\N	\N	0	\N	\N	1	f	0	2025-12-20 02:41:44.58695+00	2025-12-20 02:41:44.58695+00	1
0babb954-14a8-4d4b-b26e-46f459d8fec5	a1b454ac-fdcb-46d5-940e-f5de9b46f512	daGDWgXECDgq9HcI65Of3bewpAF3	seen	2025-12-20 02:43:11.187423+00	2025-12-20 02:43:11.187423+00	\N	\N	\N	0	\N	\N	1	f	0	2025-12-20 02:43:11.187423+00	2025-12-20 02:43:11.187423+00	\N
2e17f201-401d-4b1b-9b84-9a75d3e00b81	cc0ac110-e300-4657-94a9-05eebaf74c42	bw3d562PsydMTN8BBA2VrchR5z92	seen	2025-12-20 02:44:13.615549+00	2025-12-20 02:44:13.615549+00	\N	\N	\N	0	\N	\N	1	f	0	2025-12-20 02:44:13.615549+00	2025-12-20 02:44:13.615549+00	2
c40cdf01-864d-4d9b-9c3f-87482808bae2	cc0ac110-e300-4657-94a9-05eebaf74c42	QJANe0IB0oXYA0GNGU3XKj6L1fA3	deferred	2025-12-20 02:45:37.498505+00	2025-12-20 02:46:52.375749+00	\N	2025-12-20 02:46:52.375749+00	\N	0	5	\N	1	f	0	2025-12-20 02:45:37.498505+00	2025-12-20 02:46:52.375749+00	3
7de9716f-546d-4131-986a-3dd6821410a0	520ac7fc-38ea-455f-a662-1ec7f156d19b	Zuhv93CzFjUBPGtWdq8ujjq9cAq2	seen	2025-12-20 02:48:22.500572+00	2025-12-20 02:48:22.500572+00	\N	\N	\N	0	\N	\N	1	f	0	2025-12-20 02:48:22.500572+00	2025-12-20 02:48:22.500572+00	1
5d0b9661-565a-4342-ae72-34ce815811c3	a1b454ac-fdcb-46d5-940e-f5de9b46f512	Zuhv93CzFjUBPGtWdq8ujjq9cAq2	seen	2025-12-20 02:48:34.752429+00	2025-12-20 02:48:34.752429+00	\N	\N	\N	0	\N	\N	1	f	0	2025-12-20 02:48:34.752429+00	2025-12-20 02:48:34.752429+00	1
27d0bcff-1736-43be-b5c3-9cf5ccb71c30	520ac7fc-38ea-455f-a662-1ec7f156d19b	R0EfZ31H86WhJ0YZruyjMPW7X2h1	seen	2025-12-20 02:49:05.474926+00	2025-12-20 02:49:05.474926+00	\N	\N	\N	0	\N	\N	1	f	0	2025-12-20 02:49:05.474926+00	2025-12-20 02:49:05.474926+00	1
3500f7e6-d5fc-475e-a592-878fa383ce58	520ac7fc-38ea-455f-a662-1ec7f156d19b	u3DNVVvNMNU6Ct2rpA5hYZ1fPUd2	seen	2025-12-20 02:56:05.305674+00	2025-12-20 02:56:05.305674+00	\N	\N	\N	0	\N	\N	1	f	0	2025-12-20 02:56:05.305674+00	2025-12-20 02:56:05.305674+00	1
11ce8a3d-1a4d-43b4-a0bf-18ff2e15a4c6	520ac7fc-38ea-455f-a662-1ec7f156d19b	5oxoxEwJPlNsnNYTbONvOSPikbn2	seen	2025-12-20 03:18:47.486433+00	2025-12-20 03:18:47.486433+00	\N	\N	\N	0	\N	\N	1	f	0	2025-12-20 03:18:47.486433+00	2025-12-20 03:18:47.486433+00	1
13464626-ddeb-4113-9894-b83943d611e5	cc0ac110-e300-4657-94a9-05eebaf74c42	5oxoxEwJPlNsnNYTbONvOSPikbn2	seen	2025-12-20 03:19:08.738864+00	2025-12-20 03:19:08.738864+00	\N	\N	\N	0	\N	\N	1	f	0	2025-12-20 03:19:08.738864+00	2025-12-20 03:19:08.738864+00	2
1ade067d-0354-47ec-9b76-cdcac73a536f	a1b454ac-fdcb-46d5-940e-f5de9b46f512	5oxoxEwJPlNsnNYTbONvOSPikbn2	seen	2025-12-20 03:19:45.327822+00	2025-12-20 03:19:50.524361+00	\N	\N	\N	0	\N	\N	2	f	0	2025-12-20 03:19:45.327822+00	2025-12-20 03:19:50.524361+00	2
\.


--
-- Data for Name: user_sync_states; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.user_sync_states (id, user_id, auth_uid, email, decision, reason, decision_at, device_info, archived_previous_settings) FROM stdin;
\.


--
-- Data for Name: user_usage_summary; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.user_usage_summary (user_id, full_name, email, country, city, total_sessions, most_used_tool, tools, locations, updated_at) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.users (auth_uid, user_id, email, name, image_uri, is_verified, is_anonymous, login_method, insights, created_at, updated_at, is_synced, last_synced_at, last_country, last_city, last_platform, last_device_brand, last_is_real_device, last_ip, last_location_updated_at) FROM stdin;
OIOIRD8ZllZr51zjEZXul3Eb49p2	OIOIRD8ZllZr51zjEZXul3Eb49p2	\N	\N	\N	f	f	anonymous	{}	2025-12-20 02:18:45.733+00	2025-12-20 02:18:45.733+00	f	\N	\N	\N	\N	\N	\N	\N	\N
oFIu6w0O31U4okXqTW6HEVbeYLV2	oFIu6w0O31U4okXqTW6HEVbeYLV2	\N	\N	\N	t	f	firebase	{}	2025-12-20 02:44:45.069+00	2025-12-20 02:44:49.177912+00	t	2025-12-20 02:44:48.796+00	\N	\N	\N	\N	\N	\N	\N
6KAWj7gw9MUig2M8sK021ss8ilu2	6KAWj7gw9MUig2M8sK021ss8ilu2	egyeast@gmail.com	Ehab Sultan	https://lh3.googleusercontent.com/a/ACg8ocK-Cq4_0pr-RXTMc80RtDFn741ZWwWp3vDUIZkfSgFYJIBsJ1s7=s96-c	t	f	firebase	{}	2025-12-20 02:20:21.212+00	2025-12-20 02:20:42.076907+00	t	2025-12-20 02:20:40.679+00	Saudi Arabia	Jeddah	Android	google	f	176.18.101.75	2025-12-20 02:20:42.076907+00
6XOrRdbJ7BNZfE15dyAAGCmMu9g1	6XOrRdbJ7BNZfE15dyAAGCmMu9g1	\N	\N	\N	t	f	firebase	{}	2025-12-20 02:22:01.606+00	2025-12-20 02:22:02.826829+00	t	2025-12-20 02:21:58.022+00	\N	\N	\N	\N	\N	\N	\N
DN2C6pvgYoVybrHLch3Kaowkz0z1	DN2C6pvgYoVybrHLch3Kaowkz0z1	\N	\N	\N	t	f	firebase	{}	2025-12-20 02:28:37.391+00	2025-12-20 02:28:37.791974+00	t	2025-12-20 02:22:42.561+00	\N	\N	\N	\N	\N	\N	\N
QJANe0IB0oXYA0GNGU3XKj6L1fA3	QJANe0IB0oXYA0GNGU3XKj6L1fA3	\N	\N	\N	t	f	firebase	{}	2025-12-20 02:46:48.758+00	2025-12-20 02:46:53.982949+00	t	2025-12-20 02:45:23.556+00	Saudi Arabia	Jeddah	Android	google	f	176.18.101.75	2025-12-20 02:46:53.982949+00
PuHPi0pRr7ahVOsuT1ZWGlyPO0e2	PuHPi0pRr7ahVOsuT1ZWGlyPO0e2	\N	\N	\N	t	f	firebase	{}	2025-12-20 02:30:33.389+00	2025-12-20 02:30:38.387105+00	t	2025-12-20 02:29:26.714+00	Saudi Arabia	Jeddah	Android	google	f	176.18.101.75	2025-12-20 02:30:38.387105+00
T3mPOi9vcCVlU8UoUgVxv3YUfsn2	T3mPOi9vcCVlU8UoUgVxv3YUfsn2	\N	\N	\N	f	f	anonymous	{}	2025-12-20 02:20:23.602+00	2025-12-20 02:20:23.602+00	f	\N	\N	\N	\N	\N	\N	\N	\N
XaL6JtOLNfMTOYaUgWSgq4iXKiW2	XaL6JtOLNfMTOYaUgWSgq4iXKiW2	\N	\N	\N	t	f	firebase	{}	2025-12-20 02:32:51.692+00	2025-12-20 02:32:55.668746+00	t	2025-12-20 02:32:55.283+00	\N	\N	\N	\N	\N	\N	\N
qiXJkZAh6jX47lsnodop0VLwwnC3	qiXJkZAh6jX47lsnodop0VLwwnC3	\N	\N	\N	t	f	firebase	{}	2025-12-20 02:34:34.508+00	2025-12-20 02:34:34.904434+00	t	2025-12-20 02:34:28.549+00	\N	\N	\N	\N	\N	\N	\N
67unKl4JZYfMnu9Y1gAgkwOxuCB3	67unKl4JZYfMnu9Y1gAgkwOxuCB3	\N	\N	\N	t	f	firebase	{}	2025-12-20 02:34:59.084+00	2025-12-20 02:35:03.319947+00	t	2025-12-20 02:35:02.898+00	\N	\N	\N	\N	\N	\N	\N
HMxCgyHFP3ZhaaZk19YP0EBWQkN2	HMxCgyHFP3ZhaaZk19YP0EBWQkN2	\N	\N	\N	t	f	firebase	{}	2025-12-20 02:37:30.663+00	2025-12-20 02:37:34.303776+00	t	2025-12-20 02:37:33.916+00	\N	\N	\N	\N	\N	\N	\N
Zuhv93CzFjUBPGtWdq8ujjq9cAq2	Zuhv93CzFjUBPGtWdq8ujjq9cAq2	\N	\N	\N	t	f	firebase	{}	2025-12-20 02:48:15.904+00	2025-12-20 02:48:19.897138+00	t	2025-12-20 02:48:19.499+00	\N	\N	\N	\N	\N	\N	\N
pTKXEQqybTbXzfReB8NVBJrLJz83	pTKXEQqybTbXzfReB8NVBJrLJz83	\N	\N	\N	t	f	firebase	{}	2025-12-20 02:41:03.036+00	2025-12-20 02:41:08.381621+00	t	2025-12-20 02:40:54.148+00	Saudi Arabia	Jeddah	Android	google	f	176.18.101.75	2025-12-20 02:41:08.381621+00
daGDWgXECDgq9HcI65Of3bewpAF3	daGDWgXECDgq9HcI65Of3bewpAF3	\N	\N	\N	t	f	firebase	{}	2025-12-20 02:41:37.976+00	2025-12-20 02:41:41.900978+00	t	2025-12-20 02:41:41.516+00	\N	\N	\N	\N	\N	\N	\N
bw3d562PsydMTN8BBA2VrchR5z92	bw3d562PsydMTN8BBA2VrchR5z92	\N	\N	\N	t	f	firebase	{}	2025-12-20 02:44:08.637+00	2025-12-20 02:44:12.812041+00	t	2025-12-20 02:44:12.427+00	\N	\N	\N	\N	\N	\N	\N
R0EfZ31H86WhJ0YZruyjMPW7X2h1	R0EfZ31H86WhJ0YZruyjMPW7X2h1	\N	\N	\N	t	f	firebase	{}	2025-12-20 02:49:00.235+00	2025-12-20 02:49:04.441662+00	t	2025-12-20 02:49:04.051+00	\N	\N	\N	\N	\N	\N	\N
u3DNVVvNMNU6Ct2rpA5hYZ1fPUd2	u3DNVVvNMNU6Ct2rpA5hYZ1fPUd2	\N	\N	\N	t	f	firebase	{}	2025-12-20 02:55:59.374+00	2025-12-20 02:56:03.491935+00	t	2025-12-20 02:56:03.103+00	\N	\N	\N	\N	\N	\N	\N
5oxoxEwJPlNsnNYTbONvOSPikbn2	5oxoxEwJPlNsnNYTbONvOSPikbn2	\N	\N	\N	t	f	firebase	{}	2025-12-20 03:19:04.09+00	2025-12-20 03:19:09.592202+00	t	2025-12-20 03:18:45.161+00	Saudi Arabia	Jeddah	Android	google	f	176.18.101.75	2025-12-20 03:19:09.592202+00
\.


--
-- Name: admin_users admin_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_users
    ADD CONSTRAINT admin_users_pkey PRIMARY KEY (id);


--
-- Name: announcement_config announcement_config_config_key_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.announcement_config
    ADD CONSTRAINT announcement_config_config_key_key UNIQUE (config_key);


--
-- Name: announcement_config announcement_config_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.announcement_config
    ADD CONSTRAINT announcement_config_pkey PRIMARY KEY (id);


--
-- Name: announcement_impressions announcement_impressions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.announcement_impressions
    ADD CONSTRAINT announcement_impressions_pkey PRIMARY KEY (id);


--
-- Name: announcement_responses announcement_responses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.announcement_responses
    ADD CONSTRAINT announcement_responses_pkey PRIMARY KEY (id);


--
-- Name: announcement_responses announcement_responses_unique_user_response; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.announcement_responses
    ADD CONSTRAINT announcement_responses_unique_user_response UNIQUE (announcement_id, question_id, user_auth_uid);


--
-- Name: announcements announcements_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.announcements
    ADD CONSTRAINT announcements_pkey PRIMARY KEY (id);


--
-- Name: app_sessions app_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.app_sessions
    ADD CONSTRAINT app_sessions_pkey PRIMARY KEY (id);


--
-- Name: app_settings app_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.app_settings
    ADD CONSTRAINT app_settings_pkey PRIMARY KEY (user_id, setting_key);


--
-- Name: category_settings category_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.category_settings
    ADD CONSTRAINT category_settings_pkey PRIMARY KEY (user_id, category_id);


--
-- Name: credit_asset_types credit_asset_types_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.credit_asset_types
    ADD CONSTRAINT credit_asset_types_name_key UNIQUE (name);


--
-- Name: credit_asset_types credit_asset_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.credit_asset_types
    ADD CONSTRAINT credit_asset_types_pkey PRIMARY KEY (id);


--
-- Name: credit_links credit_links_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.credit_links
    ADD CONSTRAINT credit_links_pkey PRIMARY KEY (id);


--
-- Name: credit_sites credit_sites_asset_type_id_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.credit_sites
    ADD CONSTRAINT credit_sites_asset_type_id_name_key UNIQUE (asset_type_id, name);


--
-- Name: credit_sites credit_sites_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.credit_sites
    ADD CONSTRAINT credit_sites_pkey PRIMARY KEY (id);


--
-- Name: feedbacks feedbacks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.feedbacks
    ADD CONSTRAINT feedbacks_pkey PRIMARY KEY (id);


--
-- Name: announcement_impressions impressions_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.announcement_impressions
    ADD CONSTRAINT impressions_unique UNIQUE (announcement_id, user_id);


--
-- Name: screen_settings screen_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.screen_settings
    ADD CONSTRAINT screen_settings_pkey PRIMARY KEY (user_id, screen_id);


--
-- Name: section_settings section_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.section_settings
    ADD CONSTRAINT section_settings_pkey PRIMARY KEY (user_id, section_id);


--
-- Name: tool_settings tool_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tool_settings
    ADD CONSTRAINT tool_settings_pkey PRIMARY KEY (user_id, tool_id);


--
-- Name: tool_usage_events tool_usage_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tool_usage_events
    ADD CONSTRAINT tool_usage_events_pkey PRIMARY KEY (id);


--
-- Name: tool_usage_summary tool_usage_summary_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tool_usage_summary
    ADD CONSTRAINT tool_usage_summary_pkey PRIMARY KEY (id);


--
-- Name: user_announcement_state user_announcement_state_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_announcement_state
    ADD CONSTRAINT user_announcement_state_pkey PRIMARY KEY (id);


--
-- Name: user_announcement_state user_announcement_state_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_announcement_state
    ADD CONSTRAINT user_announcement_state_unique UNIQUE (announcement_id, user_id);


--
-- Name: user_sync_states user_sync_states_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_sync_states
    ADD CONSTRAINT user_sync_states_pkey PRIMARY KEY (id);


--
-- Name: user_usage_summary user_usage_summary_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_usage_summary
    ADD CONSTRAINT user_usage_summary_pkey PRIMARY KEY (user_id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (auth_uid);


--
-- Name: users users_user_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_user_id_key UNIQUE (user_id);


--
-- Name: idx_admin_users_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_admin_users_email ON public.admin_users USING btree (email);


--
-- Name: idx_announcement_impressions_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_announcement_impressions_user ON public.announcement_impressions USING btree (user_id);


--
-- Name: idx_announcement_responses_announcement; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_announcement_responses_announcement ON public.announcement_responses USING btree (announcement_id);


--
-- Name: idx_announcement_responses_question; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_announcement_responses_question ON public.announcement_responses USING btree (question_id);


--
-- Name: idx_announcement_responses_user_auth; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_announcement_responses_user_auth ON public.announcement_responses USING btree (user_auth_uid);


--
-- Name: idx_announcements_active_filtering; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_announcements_active_filtering ON public.announcements USING btree (is_active, is_deleted, status, start_at, end_at) WHERE ((is_active = true) AND (is_deleted = false) AND (status = 'live'::text));


--
-- Name: idx_announcements_active_time; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_announcements_active_time ON public.announcements USING btree (is_active, is_deleted, start_at, end_at);


--
-- Name: idx_announcements_city_targeting; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_announcements_city_targeting ON public.announcements USING btree (target_city, target_city_exclude) WHERE ((target_city IS NOT NULL) AND (target_city <> ''::text));


--
-- Name: idx_announcements_country_targeting; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_announcements_country_targeting ON public.announcements USING btree (target_country, target_country_exclude) WHERE ((target_country IS NOT NULL) AND (target_country <> ''::text));


--
-- Name: idx_announcements_degree_targeting; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_announcements_degree_targeting ON public.announcements USING btree (target_degree, target_degree_exclude) WHERE ((target_degree IS NOT NULL) AND (target_degree <> ''::text));


--
-- Name: idx_announcements_ordering; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_announcements_ordering ON public.announcements USING btree (importance, display_sequence, created_at DESC);


--
-- Name: idx_announcements_profession_targeting; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_announcements_profession_targeting ON public.announcements USING btree (target_profession, target_profession_exclude) WHERE ((target_profession IS NOT NULL) AND (target_profession <> ''::text));


--
-- Name: idx_announcements_sequence; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_announcements_sequence ON public.announcements USING btree (importance, display_sequence, created_at DESC);


--
-- Name: idx_announcements_speciality_targeting; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_announcements_speciality_targeting ON public.announcements USING btree (target_speciality, target_speciality_exclude) WHERE ((target_speciality IS NOT NULL) AND (target_speciality <> ''::text));


--
-- Name: idx_announcements_surface; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_announcements_surface ON public.announcements USING btree (surface) WHERE (is_deleted = false);


--
-- Name: idx_announcements_target_country; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_announcements_target_country ON public.announcements USING btree (target_country) WHERE (target_country IS NOT NULL);


--
-- Name: idx_announcements_target_degree; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_announcements_target_degree ON public.announcements USING btree (target_degree) WHERE (target_degree IS NOT NULL);


--
-- Name: idx_announcements_target_platform; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_announcements_target_platform ON public.announcements USING btree (target_platform) WHERE (target_platform IS NOT NULL);


--
-- Name: idx_announcements_target_profession; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_announcements_target_profession ON public.announcements USING btree (target_profession) WHERE (target_profession IS NOT NULL);


--
-- Name: idx_app_sessions_auth_uid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_app_sessions_auth_uid ON public.app_sessions USING btree (auth_uid) WHERE (auth_uid IS NOT NULL);


--
-- Name: idx_app_sessions_country; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_app_sessions_country ON public.app_sessions USING btree (country) WHERE (country IS NOT NULL);


--
-- Name: idx_app_sessions_is_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_app_sessions_is_active ON public.app_sessions USING btree (is_active) WHERE (is_active = true);


--
-- Name: idx_app_sessions_is_synced; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_app_sessions_is_synced ON public.app_sessions USING btree (is_synced) WHERE (is_synced = false);


--
-- Name: idx_app_sessions_start_time; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_app_sessions_start_time ON public.app_sessions USING btree (start_time);


--
-- Name: idx_app_sessions_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_app_sessions_user_id ON public.app_sessions USING btree (user_id);


--
-- Name: idx_app_settings_is_synced; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_app_settings_is_synced ON public.app_settings USING btree (is_synced) WHERE (is_synced = false);


--
-- Name: idx_app_settings_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_app_settings_user_id ON public.app_settings USING btree (user_id);


--
-- Name: idx_category_settings_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_category_settings_user_id ON public.category_settings USING btree (user_id);


--
-- Name: idx_credit_asset_types_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_credit_asset_types_active ON public.credit_asset_types USING btree (is_active) WHERE (is_active = true);


--
-- Name: idx_credit_asset_types_sort; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_credit_asset_types_sort ON public.credit_asset_types USING btree (sort_order);


--
-- Name: idx_credit_links_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_credit_links_active ON public.credit_links USING btree (is_active) WHERE (is_active = true);


--
-- Name: idx_credit_links_site; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_credit_links_site ON public.credit_links USING btree (site_id);


--
-- Name: idx_credit_links_sort; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_credit_links_sort ON public.credit_links USING btree (sort_order);


--
-- Name: idx_credit_sites_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_credit_sites_active ON public.credit_sites USING btree (is_active) WHERE (is_active = true);


--
-- Name: idx_credit_sites_asset_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_credit_sites_asset_type ON public.credit_sites USING btree (asset_type_id);


--
-- Name: idx_credit_sites_sort; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_credit_sites_sort ON public.credit_sites USING btree (sort_order);


--
-- Name: idx_feedbacks_submitted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_feedbacks_submitted_at ON public.feedbacks USING btree (submitted_at);


--
-- Name: idx_feedbacks_tool_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_feedbacks_tool_id ON public.feedbacks USING btree (tool_id) WHERE (tool_id IS NOT NULL);


--
-- Name: idx_feedbacks_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_feedbacks_user_id ON public.feedbacks USING btree (user_id);


--
-- Name: idx_screen_settings_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_screen_settings_user_id ON public.screen_settings USING btree (user_id);


--
-- Name: idx_section_settings_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_section_settings_user_id ON public.section_settings USING btree (user_id);


--
-- Name: idx_tool_settings_is_favourite; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_tool_settings_is_favourite ON public.tool_settings USING btree (is_favourite) WHERE (is_favourite = true);


--
-- Name: idx_tool_settings_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_tool_settings_user_id ON public.tool_settings USING btree (user_id);


--
-- Name: idx_tool_usage_events_event_timestamp; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_tool_usage_events_event_timestamp ON public.tool_usage_events USING btree (event_timestamp);


--
-- Name: idx_tool_usage_events_tool_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_tool_usage_events_tool_id ON public.tool_usage_events USING btree (tool_id);


--
-- Name: idx_tool_usage_events_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_tool_usage_events_user_id ON public.tool_usage_events USING btree (user_id);


--
-- Name: idx_tool_usage_summary_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_tool_usage_summary_slug ON public.tool_usage_summary USING btree (tool_slug);


--
-- Name: idx_user_announcement_state_announcement; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_user_announcement_state_announcement ON public.user_announcement_state USING btree (announcement_id);


--
-- Name: idx_user_announcement_state_deferred; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_user_announcement_state_deferred ON public.user_announcement_state USING btree (status, defer_until_session, defer_until_time) WHERE (status = 'deferred'::text);


--
-- Name: idx_user_announcement_state_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_user_announcement_state_status ON public.user_announcement_state USING btree (status);


--
-- Name: idx_user_announcement_state_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_user_announcement_state_user ON public.user_announcement_state USING btree (user_id);


--
-- Name: idx_user_announcement_state_user_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_user_announcement_state_user_status ON public.user_announcement_state USING btree (user_id, status);


--
-- Name: idx_user_announcement_state_user_status_fast; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_user_announcement_state_user_status_fast ON public.user_announcement_state USING btree (user_id, status, announcement_id);


--
-- Name: idx_users_auth_uid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_users_auth_uid ON public.users USING btree (auth_uid) WHERE (auth_uid IS NOT NULL);


--
-- Name: idx_users_email; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_users_email ON public.users USING btree (email) WHERE (email IS NOT NULL);


--
-- Name: idx_users_insights; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_users_insights ON public.users USING gin (insights);


--
-- Name: idx_users_insights_gin; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_users_insights_gin ON public.users USING gin (insights) WHERE ((insights IS NOT NULL) AND (insights <> '{}'::jsonb));


--
-- Name: idx_users_is_synced; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_users_is_synced ON public.users USING btree (is_synced) WHERE (is_synced = false);


--
-- Name: idx_users_last_country; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_users_last_country ON public.users USING btree (last_country) WHERE (last_country IS NOT NULL);


--
-- Name: idx_users_last_platform; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_users_last_platform ON public.users USING btree (last_platform) WHERE (last_platform IS NOT NULL);


--
-- Name: announcements trigger_announcements_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_announcements_updated_at BEFORE UPDATE ON public.announcements FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: app_sessions trigger_app_sessions_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_app_sessions_updated_at BEFORE UPDATE ON public.app_sessions FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: app_settings trigger_app_settings_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_app_settings_updated_at BEFORE UPDATE ON public.app_settings FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: category_settings trigger_category_settings_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_category_settings_updated_at BEFORE UPDATE ON public.category_settings FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: credit_asset_types trigger_credit_asset_types_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_credit_asset_types_updated_at BEFORE UPDATE ON public.credit_asset_types FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: credit_links trigger_credit_links_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_credit_links_updated_at BEFORE UPDATE ON public.credit_links FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: credit_sites trigger_credit_sites_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_credit_sites_updated_at BEFORE UPDATE ON public.credit_sites FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: feedbacks trigger_feedbacks_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_feedbacks_updated_at BEFORE UPDATE ON public.feedbacks FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: screen_settings trigger_screen_settings_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_screen_settings_updated_at BEFORE UPDATE ON public.screen_settings FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: section_settings trigger_section_settings_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_section_settings_updated_at BEFORE UPDATE ON public.section_settings FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: tool_settings trigger_tool_settings_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_tool_settings_updated_at BEFORE UPDATE ON public.tool_settings FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: announcement_responses trigger_update_user_insights; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_update_user_insights AFTER INSERT OR UPDATE ON public.announcement_responses FOR EACH ROW EXECUTE FUNCTION public.update_user_insights_from_response();


--
-- Name: app_sessions trigger_update_user_location; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_update_user_location AFTER INSERT OR UPDATE ON public.app_sessions FOR EACH ROW EXECUTE FUNCTION public.update_user_location_from_session();


--
-- Name: users trigger_users_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_users_updated_at BEFORE UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: user_announcement_state update_user_announcement_state_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_user_announcement_state_updated_at BEFORE UPDATE ON public.user_announcement_state FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: announcement_impressions announcement_impressions_announcement_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.announcement_impressions
    ADD CONSTRAINT announcement_impressions_announcement_id_fkey FOREIGN KEY (announcement_id) REFERENCES public.announcements(id) ON DELETE CASCADE;


--
-- Name: announcement_responses announcement_responses_announcement_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.announcement_responses
    ADD CONSTRAINT announcement_responses_announcement_id_fkey FOREIGN KEY (announcement_id) REFERENCES public.announcements(id) ON DELETE CASCADE;


--
-- Name: credit_links credit_links_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.credit_links
    ADD CONSTRAINT credit_links_site_id_fkey FOREIGN KEY (site_id) REFERENCES public.credit_sites(id) ON DELETE CASCADE;


--
-- Name: credit_sites credit_sites_asset_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.credit_sites
    ADD CONSTRAINT credit_sites_asset_type_id_fkey FOREIGN KEY (asset_type_id) REFERENCES public.credit_asset_types(id) ON DELETE CASCADE;


--
-- Name: user_announcement_state user_announcement_state_announcement_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_announcement_state
    ADD CONSTRAINT user_announcement_state_announcement_id_fkey FOREIGN KEY (announcement_id) REFERENCES public.announcements(id) ON DELETE CASCADE;


--
-- Name: admin_users; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.admin_users ENABLE ROW LEVEL SECURITY;

--
-- Name: admin_users admin_users_read_active; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY admin_users_read_active ON public.admin_users FOR SELECT USING ((is_active = true));


--
-- Name: admin_users admin_users_service_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY admin_users_service_all ON public.admin_users USING ((auth.role() = 'service_role'::text)) WITH CHECK ((auth.role() = 'service_role'::text));


--
-- Name: announcement_config; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.announcement_config ENABLE ROW LEVEL SECURITY;

--
-- Name: announcement_config announcement_config_admin; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY announcement_config_admin ON public.announcement_config USING ((auth.role() = 'service_role'::text));


--
-- Name: announcement_config announcement_config_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY announcement_config_read ON public.announcement_config FOR SELECT USING (true);


--
-- Name: announcement_impressions; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.announcement_impressions ENABLE ROW LEVEL SECURITY;

--
-- Name: announcement_impressions announcement_impressions_self; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY announcement_impressions_self ON public.announcement_impressions USING ((auth.uid() = user_id)) WITH CHECK ((auth.uid() = user_id));


--
-- Name: announcement_impressions announcement_impressions_service; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY announcement_impressions_service ON public.announcement_impressions USING ((auth.role() = 'service_role'::text));


--
-- Name: announcement_responses; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.announcement_responses ENABLE ROW LEVEL SECURITY;

--
-- Name: announcement_responses announcement_responses_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY announcement_responses_insert ON public.announcement_responses FOR INSERT WITH CHECK (true);


--
-- Name: announcement_responses announcement_responses_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY announcement_responses_select ON public.announcement_responses FOR SELECT USING (true);


--
-- Name: announcement_responses announcement_responses_service; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY announcement_responses_service ON public.announcement_responses USING ((auth.role() = 'service_role'::text));


--
-- Name: announcement_responses announcement_responses_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY announcement_responses_update ON public.announcement_responses FOR UPDATE USING (true) WITH CHECK (true);


--
-- Name: announcements; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.announcements ENABLE ROW LEVEL SECURITY;

--
-- Name: announcements announcements_read_active; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY announcements_read_active ON public.announcements FOR SELECT USING (((is_active = true) AND (is_deleted = false) AND (start_at <= now()) AND ((end_at IS NULL) OR (end_at > now()))));


--
-- Name: announcements announcements_service_role_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY announcements_service_role_all ON public.announcements USING ((auth.role() = 'service_role'::text));


--
-- Name: app_sessions; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.app_sessions ENABLE ROW LEVEL SECURITY;

--
-- Name: app_sessions app_sessions_access_policy; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY app_sessions_access_policy ON public.app_sessions USING ((((auth_uid IS NOT NULL) AND (auth_uid = (auth.jwt() ->> 'sub'::text))) OR (auth_uid IS NULL) OR (auth.role() = 'service_role'::text) OR ((auth.jwt() ->> 'sub'::text) IS NOT NULL)));


--
-- Name: app_settings; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.app_settings ENABLE ROW LEVEL SECURITY;

--
-- Name: app_settings app_settings_access_policy; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY app_settings_access_policy ON public.app_settings USING ((((auth_uid IS NOT NULL) AND (auth_uid = (auth.jwt() ->> 'sub'::text))) OR (auth_uid IS NULL) OR (auth.role() = 'service_role'::text) OR ((auth.jwt() ->> 'sub'::text) IS NOT NULL)));


--
-- Name: category_settings; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.category_settings ENABLE ROW LEVEL SECURITY;

--
-- Name: category_settings category_settings_access_policy; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY category_settings_access_policy ON public.category_settings USING ((((auth_uid IS NOT NULL) AND (auth_uid = (auth.jwt() ->> 'sub'::text))) OR (auth_uid IS NULL) OR (auth.role() = 'service_role'::text) OR ((auth.jwt() ->> 'sub'::text) IS NOT NULL)));


--
-- Name: credit_asset_types; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.credit_asset_types ENABLE ROW LEVEL SECURITY;

--
-- Name: credit_asset_types credit_asset_types_read_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY credit_asset_types_read_all ON public.credit_asset_types FOR SELECT USING ((is_active = true));


--
-- Name: credit_asset_types credit_asset_types_service_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY credit_asset_types_service_all ON public.credit_asset_types USING ((auth.role() = 'service_role'::text));


--
-- Name: credit_links; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.credit_links ENABLE ROW LEVEL SECURITY;

--
-- Name: credit_links credit_links_read_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY credit_links_read_all ON public.credit_links FOR SELECT USING ((is_active = true));


--
-- Name: credit_links credit_links_service_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY credit_links_service_all ON public.credit_links USING ((auth.role() = 'service_role'::text));


--
-- Name: credit_sites; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.credit_sites ENABLE ROW LEVEL SECURITY;

--
-- Name: credit_sites credit_sites_read_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY credit_sites_read_all ON public.credit_sites FOR SELECT USING ((is_active = true));


--
-- Name: credit_sites credit_sites_service_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY credit_sites_service_all ON public.credit_sites USING ((auth.role() = 'service_role'::text));


--
-- Name: feedbacks; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.feedbacks ENABLE ROW LEVEL SECURITY;

--
-- Name: feedbacks feedbacks_access_policy; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY feedbacks_access_policy ON public.feedbacks USING ((((auth_uid IS NOT NULL) AND (auth_uid = (auth.jwt() ->> 'sub'::text))) OR (auth_uid IS NULL) OR (auth.role() = 'service_role'::text) OR ((auth.jwt() ->> 'sub'::text) IS NOT NULL)));


--
-- Name: screen_settings; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.screen_settings ENABLE ROW LEVEL SECURITY;

--
-- Name: screen_settings screen_settings_access_policy; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY screen_settings_access_policy ON public.screen_settings USING ((((auth_uid IS NOT NULL) AND (auth_uid = (auth.jwt() ->> 'sub'::text))) OR (auth_uid IS NULL) OR (auth.role() = 'service_role'::text) OR ((auth.jwt() ->> 'sub'::text) IS NOT NULL)));


--
-- Name: section_settings; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.section_settings ENABLE ROW LEVEL SECURITY;

--
-- Name: section_settings section_settings_access_policy; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY section_settings_access_policy ON public.section_settings USING ((((auth_uid IS NOT NULL) AND (auth_uid = (auth.jwt() ->> 'sub'::text))) OR (auth_uid IS NULL) OR (auth.role() = 'service_role'::text) OR ((auth.jwt() ->> 'sub'::text) IS NOT NULL)));


--
-- Name: tool_settings; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.tool_settings ENABLE ROW LEVEL SECURITY;

--
-- Name: tool_settings tool_settings_access_policy; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tool_settings_access_policy ON public.tool_settings USING ((((auth_uid IS NOT NULL) AND (auth_uid = (auth.jwt() ->> 'sub'::text))) OR (auth_uid IS NULL) OR (auth.role() = 'service_role'::text) OR ((auth.jwt() ->> 'sub'::text) IS NOT NULL)));


--
-- Name: tool_usage_events; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.tool_usage_events ENABLE ROW LEVEL SECURITY;

--
-- Name: tool_usage_events tool_usage_events_access_policy; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tool_usage_events_access_policy ON public.tool_usage_events USING ((((auth_uid IS NOT NULL) AND (auth_uid = (auth.jwt() ->> 'sub'::text))) OR (auth_uid IS NULL) OR (auth.role() = 'service_role'::text) OR ((auth.jwt() ->> 'sub'::text) IS NOT NULL)));


--
-- Name: tool_usage_summary; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.tool_usage_summary ENABLE ROW LEVEL SECURITY;

--
-- Name: tool_usage_summary tool_usage_summary_service; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tool_usage_summary_service ON public.tool_usage_summary USING ((auth.role() = 'service_role'::text));


--
-- Name: user_announcement_state; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.user_announcement_state ENABLE ROW LEVEL SECURITY;

--
-- Name: user_announcement_state user_announcement_state_access; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY user_announcement_state_access ON public.user_announcement_state USING (((user_id = (auth.jwt() ->> 'sub'::text)) OR (auth.role() = 'service_role'::text)));


--
-- Name: user_sync_states; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.user_sync_states ENABLE ROW LEVEL SECURITY;

--
-- Name: user_sync_states user_sync_states_access_policy; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY user_sync_states_access_policy ON public.user_sync_states USING (((auth.role() = 'service_role'::text) OR ((auth.jwt() ->> 'sub'::text) IS NOT NULL)));


--
-- Name: user_usage_summary; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.user_usage_summary ENABLE ROW LEVEL SECURITY;

--
-- Name: user_usage_summary user_usage_summary_service; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY user_usage_summary_service ON public.user_usage_summary USING ((auth.role() = 'service_role'::text));


--
-- Name: users; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

--
-- Name: users users_access_policy; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY users_access_policy ON public.users USING ((((auth_uid IS NOT NULL) AND (auth_uid = (auth.jwt() ->> 'sub'::text))) OR (auth_uid IS NULL) OR (auth.role() = 'service_role'::text) OR ((auth.jwt() ->> 'sub'::text) IS NOT NULL)));


--
-- PostgreSQL database dump complete
--

