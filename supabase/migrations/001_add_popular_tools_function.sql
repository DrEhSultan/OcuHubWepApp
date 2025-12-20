-- Migration: Add function to get popular tools across all users
-- This function aggregates tool usage statistics to find the most popular tools
-- Only includes data from real devices (excludes emulators)

-- Create a function to get popular tools from real devices only
CREATE OR REPLACE FUNCTION get_popular_tools(limit_count INTEGER DEFAULT 10)
RETURNS TABLE (
  tool_id TEXT,
  total_usage_count BIGINT,
  unique_users_count BIGINT
) 
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    ts.tool_id,
    SUM(ts.usage_count)::BIGINT as total_usage_count,
    COUNT(DISTINCT ts.auth_uid)::BIGINT as unique_users_count
  FROM tool_settings ts
  WHERE ts.usage_count > 0
    AND ts.is_archived IS NOT TRUE
    -- Only include users who have at least one real device session
    AND EXISTS (
      SELECT 1 
      FROM app_sessions aps 
      WHERE aps.auth_uid = ts.auth_uid 
        AND aps.is_device = TRUE
        AND aps.is_archived IS NOT TRUE
    )
  GROUP BY ts.tool_id
  ORDER BY total_usage_count DESC, unique_users_count DESC
  LIMIT limit_count;
END;
$$;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION get_popular_tools(INTEGER) TO authenticated;
GRANT EXECUTE ON FUNCTION get_popular_tools(INTEGER) TO anon;

-- Add comment
COMMENT ON FUNCTION get_popular_tools IS 'Returns the most popular tools based on aggregated usage across all users with real devices (excludes emulators)';

