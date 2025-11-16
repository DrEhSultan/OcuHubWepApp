-- FIX: Corrected RPC Function for Admin Analytics
-- This replaces the broken get_admin_overview_metrics function
--
-- The issue: The subqueries were returning wrong types
-- This version properly casts and handles NULL values

DROP FUNCTION IF EXISTS get_admin_overview_metrics(INTEGER);

CREATE OR REPLACE FUNCTION get_admin_overview_metrics(p_days INTEGER DEFAULT 30)
RETURNS TABLE (
    total_users BIGINT,
    active_users BIGINT,
    session_count BIGINT,
    avg_session_duration_seconds DOUBLE PRECISION,
    tool_event_count BIGINT,
    feedback_count BIGINT,
    country_count BIGINT,
    last_activity TIMESTAMPTZ
) AS $$
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

    -- Get all metrics
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

    -- Return the metrics
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
$$ LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public;

GRANT EXECUTE ON FUNCTION get_admin_overview_metrics(INTEGER) TO service_role;

-- Test it
SELECT * FROM get_admin_overview_metrics(30);
