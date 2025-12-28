-- Migration: Improved Popular Tools Function
-- Date: December 28, 2025
-- 
-- SCORING WEIGHTS:
-- - User Diversity: 50% (most important - prevents single-user manipulation)
-- - Usage Count: 25% (frequency of opens)
-- - Usage Time: 25% (engagement duration)
--
-- This ensures tools used by many users rank highest, even if individual usage is moderate

-- Drop existing function first
DROP FUNCTION IF EXISTS get_popular_tools(INTEGER);

-- Create improved function
CREATE OR REPLACE FUNCTION get_popular_tools(limit_count INTEGER DEFAULT 10)
RETURNS TABLE (
  tool_id TEXT,
  total_usage_count BIGINT,
  total_usage_time_sec BIGINT,
  unique_users_count BIGINT,
  popularity_score NUMERIC
) 
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  max_usage_count NUMERIC;
  max_usage_time NUMERIC;
  max_unique_users NUMERIC;
BEGIN
  -- Calculate maximum values for normalization (0-1 scale)
  SELECT 
    COALESCE(MAX(agg.sum_count), 1),
    COALESCE(MAX(agg.sum_time), 1),
    COALESCE(MAX(agg.user_count), 1)
  INTO max_usage_count, max_usage_time, max_unique_users
  FROM (
    SELECT 
      ts.tool_id,
      SUM(ts.usage_count) as sum_count,
      SUM(LEAST(COALESCE(ts.usage_duration_sec, 0), 1800)) as sum_time,
      COUNT(DISTINCT ts.auth_uid) as user_count
    FROM tool_settings ts
    WHERE ts.usage_count > 0
      AND COALESCE(ts.usage_duration_sec, 0) > 0
      AND EXISTS (
        SELECT 1 
        FROM app_sessions aps 
        WHERE aps.auth_uid = ts.auth_uid 
          AND aps.is_device = TRUE
          AND aps.is_active = TRUE
      )
    GROUP BY ts.tool_id
  ) agg;

  -- Return ranked tools with weighted score
  RETURN QUERY
  WITH tool_aggregates AS (
    SELECT 
      ts.tool_id,
      SUM(ts.usage_count)::BIGINT as total_count,
      SUM(LEAST(COALESCE(ts.usage_duration_sec, 0), 1800))::BIGINT as total_time,
      COUNT(DISTINCT ts.auth_uid)::BIGINT as unique_users
    FROM tool_settings ts
    WHERE ts.usage_count > 0
      AND COALESCE(ts.usage_duration_sec, 0) > 0
      AND EXISTS (
        SELECT 1 
        FROM app_sessions aps 
        WHERE aps.auth_uid = ts.auth_uid 
          AND aps.is_device = TRUE
          AND aps.is_active = TRUE
      )
    GROUP BY ts.tool_id
  )
  SELECT 
    ta.tool_id,
    ta.total_count as total_usage_count,
    ta.total_time as total_usage_time_sec,
    ta.unique_users as unique_users_count,
    -- Weighted score: User Diversity 50%, Usage Count 25%, Usage Time 25%
    ROUND(
      (
        (ta.unique_users::NUMERIC / max_unique_users) * 0.5 +
        (ta.total_count::NUMERIC / max_usage_count) * 0.25 + 
        (ta.total_time::NUMERIC / max_usage_time) * 0.25
      ) * 100,
      2
    ) as popularity_score
  FROM tool_aggregates ta
  -- Order by weighted score (user diversity has 50% weight)
  ORDER BY 
    (
      (ta.unique_users::NUMERIC / max_unique_users) * 0.5 +
      (ta.total_count::NUMERIC / max_usage_count) * 0.25 + 
      (ta.total_time::NUMERIC / max_usage_time) * 0.25
    ) DESC
  LIMIT limit_count;
END;
$$;

-- Grant permissions
GRANT EXECUTE ON FUNCTION get_popular_tools(INTEGER) TO authenticated;
GRANT EXECUTE ON FUNCTION get_popular_tools(INTEGER) TO anon;

-- Add descriptive comment
COMMENT ON FUNCTION get_popular_tools IS 
'Returns the most popular tools with WEIGHTED scoring:
- User Diversity: 50% (most important - prevents single-user manipulation)
- Usage Count: 25% (frequency of opens)
- Usage Time: 25% (engagement duration)

FILTERS:
- Excludes emulator/test devices (real devices only)
- Excludes tools with 0 usage time (no actual engagement)
- Caps session time at 30 minutes to filter idle/fake sessions

RESULT:
Tools used by many users rank highest, even if individual usage is moderate.
Single-user heavy usage cannot dominate rankings.';

-- Test it
SELECT * FROM get_popular_tools(10);
