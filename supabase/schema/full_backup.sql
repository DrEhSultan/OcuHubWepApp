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
-- Name: auth; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA auth;


ALTER SCHEMA auth OWNER TO supabase_admin;

--
-- Name: extensions; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA extensions;


ALTER SCHEMA extensions OWNER TO postgres;

--
-- Name: graphql; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA graphql;


ALTER SCHEMA graphql OWNER TO supabase_admin;

--
-- Name: graphql_public; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA graphql_public;


ALTER SCHEMA graphql_public OWNER TO supabase_admin;

--
-- Name: pgbouncer; Type: SCHEMA; Schema: -; Owner: pgbouncer
--

CREATE SCHEMA pgbouncer;


ALTER SCHEMA pgbouncer OWNER TO pgbouncer;

--
-- Name: realtime; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA realtime;


ALTER SCHEMA realtime OWNER TO supabase_admin;

--
-- Name: storage; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA storage;


ALTER SCHEMA storage OWNER TO supabase_admin;

--
-- Name: vault; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA vault;


ALTER SCHEMA vault OWNER TO supabase_admin;

--
-- Name: pg_graphql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_graphql WITH SCHEMA graphql;


--
-- Name: EXTENSION pg_graphql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_graphql IS 'pg_graphql: GraphQL support';


--
-- Name: pg_stat_statements; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA extensions;


--
-- Name: EXTENSION pg_stat_statements; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_stat_statements IS 'track planning and execution statistics of all SQL statements executed';


--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA extensions;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: supabase_vault; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS supabase_vault WITH SCHEMA vault;


--
-- Name: EXTENSION supabase_vault; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION supabase_vault IS 'Supabase Vault Extension';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA extensions;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: aal_level; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.aal_level AS ENUM (
    'aal1',
    'aal2',
    'aal3'
);


ALTER TYPE auth.aal_level OWNER TO supabase_auth_admin;

--
-- Name: code_challenge_method; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.code_challenge_method AS ENUM (
    's256',
    'plain'
);


ALTER TYPE auth.code_challenge_method OWNER TO supabase_auth_admin;

--
-- Name: factor_status; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.factor_status AS ENUM (
    'unverified',
    'verified'
);


ALTER TYPE auth.factor_status OWNER TO supabase_auth_admin;

--
-- Name: factor_type; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.factor_type AS ENUM (
    'totp',
    'webauthn',
    'phone'
);


ALTER TYPE auth.factor_type OWNER TO supabase_auth_admin;

--
-- Name: oauth_authorization_status; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.oauth_authorization_status AS ENUM (
    'pending',
    'approved',
    'denied',
    'expired'
);


ALTER TYPE auth.oauth_authorization_status OWNER TO supabase_auth_admin;

--
-- Name: oauth_client_type; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.oauth_client_type AS ENUM (
    'public',
    'confidential'
);


ALTER TYPE auth.oauth_client_type OWNER TO supabase_auth_admin;

--
-- Name: oauth_registration_type; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.oauth_registration_type AS ENUM (
    'dynamic',
    'manual'
);


ALTER TYPE auth.oauth_registration_type OWNER TO supabase_auth_admin;

--
-- Name: oauth_response_type; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.oauth_response_type AS ENUM (
    'code'
);


ALTER TYPE auth.oauth_response_type OWNER TO supabase_auth_admin;

--
-- Name: one_time_token_type; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.one_time_token_type AS ENUM (
    'confirmation_token',
    'reauthentication_token',
    'recovery_token',
    'email_change_token_new',
    'email_change_token_current',
    'phone_change_token'
);


ALTER TYPE auth.one_time_token_type OWNER TO supabase_auth_admin;

--
-- Name: action; Type: TYPE; Schema: realtime; Owner: supabase_admin
--

CREATE TYPE realtime.action AS ENUM (
    'INSERT',
    'UPDATE',
    'DELETE',
    'TRUNCATE',
    'ERROR'
);


ALTER TYPE realtime.action OWNER TO supabase_admin;

--
-- Name: equality_op; Type: TYPE; Schema: realtime; Owner: supabase_admin
--

CREATE TYPE realtime.equality_op AS ENUM (
    'eq',
    'neq',
    'lt',
    'lte',
    'gt',
    'gte',
    'in'
);


ALTER TYPE realtime.equality_op OWNER TO supabase_admin;

--
-- Name: user_defined_filter; Type: TYPE; Schema: realtime; Owner: supabase_admin
--

CREATE TYPE realtime.user_defined_filter AS (
	column_name text,
	op realtime.equality_op,
	value text
);


ALTER TYPE realtime.user_defined_filter OWNER TO supabase_admin;

--
-- Name: wal_column; Type: TYPE; Schema: realtime; Owner: supabase_admin
--

CREATE TYPE realtime.wal_column AS (
	name text,
	type_name text,
	type_oid oid,
	value jsonb,
	is_pkey boolean,
	is_selectable boolean
);


ALTER TYPE realtime.wal_column OWNER TO supabase_admin;

--
-- Name: wal_rls; Type: TYPE; Schema: realtime; Owner: supabase_admin
--

CREATE TYPE realtime.wal_rls AS (
	wal jsonb,
	is_rls_enabled boolean,
	subscription_ids uuid[],
	errors text[]
);


ALTER TYPE realtime.wal_rls OWNER TO supabase_admin;

--
-- Name: buckettype; Type: TYPE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TYPE storage.buckettype AS ENUM (
    'STANDARD',
    'ANALYTICS',
    'VECTOR'
);


ALTER TYPE storage.buckettype OWNER TO supabase_storage_admin;

--
-- Name: email(); Type: FUNCTION; Schema: auth; Owner: supabase_auth_admin
--

CREATE FUNCTION auth.email() RETURNS text
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.email', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'email')
  )::text
$$;


ALTER FUNCTION auth.email() OWNER TO supabase_auth_admin;

--
-- Name: FUNCTION email(); Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON FUNCTION auth.email() IS 'Deprecated. Use auth.jwt() -> ''email'' instead.';


--
-- Name: jwt(); Type: FUNCTION; Schema: auth; Owner: supabase_auth_admin
--

CREATE FUNCTION auth.jwt() RETURNS jsonb
    LANGUAGE sql STABLE
    AS $$
  select 
    coalesce(
        nullif(current_setting('request.jwt.claim', true), ''),
        nullif(current_setting('request.jwt.claims', true), '')
    )::jsonb
$$;


ALTER FUNCTION auth.jwt() OWNER TO supabase_auth_admin;

--
-- Name: role(); Type: FUNCTION; Schema: auth; Owner: supabase_auth_admin
--

CREATE FUNCTION auth.role() RETURNS text
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.role', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'role')
  )::text
$$;


ALTER FUNCTION auth.role() OWNER TO supabase_auth_admin;

--
-- Name: FUNCTION role(); Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON FUNCTION auth.role() IS 'Deprecated. Use auth.jwt() -> ''role'' instead.';


--
-- Name: uid(); Type: FUNCTION; Schema: auth; Owner: supabase_auth_admin
--

CREATE FUNCTION auth.uid() RETURNS uuid
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.sub', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'sub')
  )::uuid
$$;


ALTER FUNCTION auth.uid() OWNER TO supabase_auth_admin;

--
-- Name: FUNCTION uid(); Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON FUNCTION auth.uid() IS 'Deprecated. Use auth.jwt() -> ''sub'' instead.';


--
-- Name: grant_pg_cron_access(); Type: FUNCTION; Schema: extensions; Owner: supabase_admin
--

CREATE FUNCTION extensions.grant_pg_cron_access() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF EXISTS (
    SELECT
    FROM pg_event_trigger_ddl_commands() AS ev
    JOIN pg_extension AS ext
    ON ev.objid = ext.oid
    WHERE ext.extname = 'pg_cron'
  )
  THEN
    grant usage on schema cron to postgres with grant option;

    alter default privileges in schema cron grant all on tables to postgres with grant option;
    alter default privileges in schema cron grant all on functions to postgres with grant option;
    alter default privileges in schema cron grant all on sequences to postgres with grant option;

    alter default privileges for user supabase_admin in schema cron grant all
        on sequences to postgres with grant option;
    alter default privileges for user supabase_admin in schema cron grant all
        on tables to postgres with grant option;
    alter default privileges for user supabase_admin in schema cron grant all
        on functions to postgres with grant option;

    grant all privileges on all tables in schema cron to postgres with grant option;
    revoke all on table cron.job from postgres;
    grant select on table cron.job to postgres with grant option;
  END IF;
END;
$$;


ALTER FUNCTION extensions.grant_pg_cron_access() OWNER TO supabase_admin;

--
-- Name: FUNCTION grant_pg_cron_access(); Type: COMMENT; Schema: extensions; Owner: supabase_admin
--

COMMENT ON FUNCTION extensions.grant_pg_cron_access() IS 'Grants access to pg_cron';


--
-- Name: grant_pg_graphql_access(); Type: FUNCTION; Schema: extensions; Owner: supabase_admin
--

CREATE FUNCTION extensions.grant_pg_graphql_access() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $_$
DECLARE
    func_is_graphql_resolve bool;
BEGIN
    func_is_graphql_resolve = (
        SELECT n.proname = 'resolve'
        FROM pg_event_trigger_ddl_commands() AS ev
        LEFT JOIN pg_catalog.pg_proc AS n
        ON ev.objid = n.oid
    );

    IF func_is_graphql_resolve
    THEN
        -- Update public wrapper to pass all arguments through to the pg_graphql resolve func
        DROP FUNCTION IF EXISTS graphql_public.graphql;
        create or replace function graphql_public.graphql(
            "operationName" text default null,
            query text default null,
            variables jsonb default null,
            extensions jsonb default null
        )
            returns jsonb
            language sql
        as $$
            select graphql.resolve(
                query := query,
                variables := coalesce(variables, '{}'),
                "operationName" := "operationName",
                extensions := extensions
            );
        $$;

        -- This hook executes when `graphql.resolve` is created. That is not necessarily the last
        -- function in the extension so we need to grant permissions on existing entities AND
        -- update default permissions to any others that are created after `graphql.resolve`
        grant usage on schema graphql to postgres, anon, authenticated, service_role;
        grant select on all tables in schema graphql to postgres, anon, authenticated, service_role;
        grant execute on all functions in schema graphql to postgres, anon, authenticated, service_role;
        grant all on all sequences in schema graphql to postgres, anon, authenticated, service_role;
        alter default privileges in schema graphql grant all on tables to postgres, anon, authenticated, service_role;
        alter default privileges in schema graphql grant all on functions to postgres, anon, authenticated, service_role;
        alter default privileges in schema graphql grant all on sequences to postgres, anon, authenticated, service_role;

        -- Allow postgres role to allow granting usage on graphql and graphql_public schemas to custom roles
        grant usage on schema graphql_public to postgres with grant option;
        grant usage on schema graphql to postgres with grant option;
    END IF;

END;
$_$;


ALTER FUNCTION extensions.grant_pg_graphql_access() OWNER TO supabase_admin;

--
-- Name: FUNCTION grant_pg_graphql_access(); Type: COMMENT; Schema: extensions; Owner: supabase_admin
--

COMMENT ON FUNCTION extensions.grant_pg_graphql_access() IS 'Grants access to pg_graphql';


--
-- Name: grant_pg_net_access(); Type: FUNCTION; Schema: extensions; Owner: supabase_admin
--

CREATE FUNCTION extensions.grant_pg_net_access() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM pg_event_trigger_ddl_commands() AS ev
    JOIN pg_extension AS ext
    ON ev.objid = ext.oid
    WHERE ext.extname = 'pg_net'
  )
  THEN
    IF NOT EXISTS (
      SELECT 1
      FROM pg_roles
      WHERE rolname = 'supabase_functions_admin'
    )
    THEN
      CREATE USER supabase_functions_admin NOINHERIT CREATEROLE LOGIN NOREPLICATION;
    END IF;

    GRANT USAGE ON SCHEMA net TO supabase_functions_admin, postgres, anon, authenticated, service_role;

    IF EXISTS (
      SELECT FROM pg_extension
      WHERE extname = 'pg_net'
      -- all versions in use on existing projects as of 2025-02-20
      -- version 0.12.0 onwards don't need these applied
      AND extversion IN ('0.2', '0.6', '0.7', '0.7.1', '0.8', '0.10.0', '0.11.0')
    ) THEN
      ALTER function net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) SECURITY DEFINER;
      ALTER function net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) SECURITY DEFINER;

      ALTER function net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) SET search_path = net;
      ALTER function net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) SET search_path = net;

      REVOKE ALL ON FUNCTION net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) FROM PUBLIC;
      REVOKE ALL ON FUNCTION net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) FROM PUBLIC;

      GRANT EXECUTE ON FUNCTION net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) TO supabase_functions_admin, postgres, anon, authenticated, service_role;
      GRANT EXECUTE ON FUNCTION net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) TO supabase_functions_admin, postgres, anon, authenticated, service_role;
    END IF;
  END IF;
END;
$$;


ALTER FUNCTION extensions.grant_pg_net_access() OWNER TO supabase_admin;

--
-- Name: FUNCTION grant_pg_net_access(); Type: COMMENT; Schema: extensions; Owner: supabase_admin
--

COMMENT ON FUNCTION extensions.grant_pg_net_access() IS 'Grants access to pg_net';


--
-- Name: pgrst_ddl_watch(); Type: FUNCTION; Schema: extensions; Owner: supabase_admin
--

CREATE FUNCTION extensions.pgrst_ddl_watch() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  cmd record;
BEGIN
  FOR cmd IN SELECT * FROM pg_event_trigger_ddl_commands()
  LOOP
    IF cmd.command_tag IN (
      'CREATE SCHEMA', 'ALTER SCHEMA'
    , 'CREATE TABLE', 'CREATE TABLE AS', 'SELECT INTO', 'ALTER TABLE'
    , 'CREATE FOREIGN TABLE', 'ALTER FOREIGN TABLE'
    , 'CREATE VIEW', 'ALTER VIEW'
    , 'CREATE MATERIALIZED VIEW', 'ALTER MATERIALIZED VIEW'
    , 'CREATE FUNCTION', 'ALTER FUNCTION'
    , 'CREATE TRIGGER'
    , 'CREATE TYPE', 'ALTER TYPE'
    , 'CREATE RULE'
    , 'COMMENT'
    )
    -- don't notify in case of CREATE TEMP table or other objects created on pg_temp
    AND cmd.schema_name is distinct from 'pg_temp'
    THEN
      NOTIFY pgrst, 'reload schema';
    END IF;
  END LOOP;
END; $$;


ALTER FUNCTION extensions.pgrst_ddl_watch() OWNER TO supabase_admin;

--
-- Name: pgrst_drop_watch(); Type: FUNCTION; Schema: extensions; Owner: supabase_admin
--

CREATE FUNCTION extensions.pgrst_drop_watch() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  obj record;
BEGIN
  FOR obj IN SELECT * FROM pg_event_trigger_dropped_objects()
  LOOP
    IF obj.object_type IN (
      'schema'
    , 'table'
    , 'foreign table'
    , 'view'
    , 'materialized view'
    , 'function'
    , 'trigger'
    , 'type'
    , 'rule'
    )
    AND obj.is_temporary IS false -- no pg_temp objects
    THEN
      NOTIFY pgrst, 'reload schema';
    END IF;
  END LOOP;
END; $$;


ALTER FUNCTION extensions.pgrst_drop_watch() OWNER TO supabase_admin;

--
-- Name: set_graphql_placeholder(); Type: FUNCTION; Schema: extensions; Owner: supabase_admin
--

CREATE FUNCTION extensions.set_graphql_placeholder() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $_$
    DECLARE
    graphql_is_dropped bool;
    BEGIN
    graphql_is_dropped = (
        SELECT ev.schema_name = 'graphql_public'
        FROM pg_event_trigger_dropped_objects() AS ev
        WHERE ev.schema_name = 'graphql_public'
    );

    IF graphql_is_dropped
    THEN
        create or replace function graphql_public.graphql(
            "operationName" text default null,
            query text default null,
            variables jsonb default null,
            extensions jsonb default null
        )
            returns jsonb
            language plpgsql
        as $$
            DECLARE
                server_version float;
            BEGIN
                server_version = (SELECT (SPLIT_PART((select version()), ' ', 2))::float);

                IF server_version >= 14 THEN
                    RETURN jsonb_build_object(
                        'errors', jsonb_build_array(
                            jsonb_build_object(
                                'message', 'pg_graphql extension is not enabled.'
                            )
                        )
                    );
                ELSE
                    RETURN jsonb_build_object(
                        'errors', jsonb_build_array(
                            jsonb_build_object(
                                'message', 'pg_graphql is only available on projects running Postgres 14 onwards.'
                            )
                        )
                    );
                END IF;
            END;
        $$;
    END IF;

    END;
$_$;


ALTER FUNCTION extensions.set_graphql_placeholder() OWNER TO supabase_admin;

--
-- Name: FUNCTION set_graphql_placeholder(); Type: COMMENT; Schema: extensions; Owner: supabase_admin
--

COMMENT ON FUNCTION extensions.set_graphql_placeholder() IS 'Reintroduces placeholder function for graphql_public.graphql';


--
-- Name: get_auth(text); Type: FUNCTION; Schema: pgbouncer; Owner: supabase_admin
--

CREATE FUNCTION pgbouncer.get_auth(p_usename text) RETURNS TABLE(username text, password text)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO ''
    AS $_$
  BEGIN
      RAISE DEBUG 'PgBouncer auth request: %', p_usename;

      RETURN QUERY
      SELECT
          rolname::text,
          CASE WHEN rolvaliduntil < now()
              THEN null
              ELSE rolpassword::text
          END
      FROM pg_authid
      WHERE rolname=$1 and rolcanlogin;
  END;
  $_$;


ALTER FUNCTION pgbouncer.get_auth(p_usename text) OWNER TO supabase_admin;

--
-- Name: check_merge_conflicts(text, text); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.check_merge_conflicts(p_old_auth_uid text, p_new_auth_uid text) OWNER TO postgres;

--
-- Name: compare_semver(text, text); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.compare_semver(version_a text, version_b text) OWNER TO postgres;

--
-- Name: consolidate_users_by_auth_uid(text, text); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.consolidate_users_by_auth_uid(p_old_auth_uid text, p_new_auth_uid text) OWNER TO postgres;

--
-- Name: fetch_active_announcements(text, text, text, integer); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.fetch_active_announcements(p_user_id text, p_app_version text, p_platform text, p_limit integer) OWNER TO postgres;

--
-- Name: fn_process_tool_usage_event(); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.fn_process_tool_usage_event() OWNER TO postgres;

--
-- Name: get_admin_overview_metrics(integer); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.get_admin_overview_metrics(p_days integer) OWNER TO postgres;

--
-- Name: get_carousel_announcements(text, text, text, text, text, text, text, boolean, text, text, text, text, boolean, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_carousel_announcements(p_user_id text, p_device_id text DEFAULT NULL::text, p_auth_uid text DEFAULT NULL::text, p_platform text DEFAULT NULL::text, p_app_version text DEFAULT NULL::text, p_country text DEFAULT NULL::text, p_city text DEFAULT NULL::text, p_is_logged_in boolean DEFAULT false, p_profession text DEFAULT NULL::text, p_speciality text DEFAULT NULL::text, p_degree text DEFAULT NULL::text, p_experience text DEFAULT NULL::text, p_has_complete_profile boolean DEFAULT false, p_session_number integer DEFAULT 1) RETURNS TABLE(id uuid, title text, message text, body text, surface text, importance text, kind text, priority text, action_type text, action_value text, dismissible boolean, dismissible_mode text, metadata jsonb, questions jsonb, user_status text, impression_count integer, is_partially_completed boolean, questions_answered integer, display_sequence integer, carousel_position integer)
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
            ) AS carousel_position
        FROM get_eligible_announcements(
            p_user_id, p_device_id, p_auth_uid, p_platform, p_app_version,
            p_country, p_city, p_is_logged_in, p_profession, p_speciality,
            p_degree, p_experience, p_has_complete_profile, p_session_number,
            'home_banner', 100, 0
        ) e
        WHERE e.surface IN ('home_banner', 'modal')
    )
    SELECT 
        eligible.id, eligible.title, eligible.message, eligible.body,
        eligible.surface, eligible.importance, eligible.kind, eligible.priority,
        eligible.action_type, eligible.action_value, eligible.dismissible,
        eligible.dismissible_mode, eligible.metadata, eligible.questions,
        eligible.user_status, eligible.impression_count, eligible.is_partially_completed,
        eligible.questions_answered, eligible.display_sequence,
        eligible.carousel_position::INTEGER
    FROM eligible
    WHERE eligible.carousel_position <= v_max_items;
END;
$$;


ALTER FUNCTION public.get_carousel_announcements(p_user_id text, p_device_id text, p_auth_uid text, p_platform text, p_app_version text, p_country text, p_city text, p_is_logged_in boolean, p_profession text, p_speciality text, p_degree text, p_experience text, p_has_complete_profile boolean, p_session_number integer) OWNER TO postgres;

--
-- Name: get_current_user_firebase_uid(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_current_user_firebase_uid() RETURNS text
    LANGUAGE sql STABLE
    AS $$
  SELECT COALESCE(
    (current_setting('request.jwt.claims', true)::json ->> 'sub'),
    ''
  );
$$;


ALTER FUNCTION public.get_current_user_firebase_uid() OWNER TO postgres;

--
-- Name: get_eligible_announcements(text, text, text, text, text, text, text, boolean, text, text, text, text, boolean, integer, text, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_eligible_announcements(p_user_id text, p_device_id text DEFAULT NULL::text, p_auth_uid text DEFAULT NULL::text, p_platform text DEFAULT NULL::text, p_app_version text DEFAULT NULL::text, p_country text DEFAULT NULL::text, p_city text DEFAULT NULL::text, p_is_logged_in boolean DEFAULT false, p_profession text DEFAULT NULL::text, p_speciality text DEFAULT NULL::text, p_degree text DEFAULT NULL::text, p_experience text DEFAULT NULL::text, p_has_complete_profile boolean DEFAULT false, p_session_number integer DEFAULT 1, p_surface text DEFAULT 'home_banner'::text, p_limit integer DEFAULT 10, p_offset integer DEFAULT 0) RETURNS TABLE(id uuid, title text, message text, body text, surface text, importance text, kind text, priority text, action_type text, action_value text, dismissible boolean, dismissible_mode text, metadata jsonb, questions jsonb, user_status text, impression_count integer, is_partially_completed boolean, questions_answered integer, display_sequence integer)
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
        AND (a.status = 'live' OR a.status = 'published' OR a.status IS NULL)
        AND a.start_at <= NOW()
        AND (a.end_at IS NULL OR a.end_at > NOW())
        
        -- Surface filtering
        AND (
            (p_surface = 'inbox' AND a.surface IN ('home_banner', 'modal', 'inbox'))
            OR a.surface = p_surface 
            OR a.surface = 'modal'
        )
        
        -- Login targeting
        AND (a.target_logged_in_only = FALSE OR p_is_logged_in = TRUE)
        AND (a.target_anonymous_only = FALSE OR p_is_logged_in = FALSE)
        
        -- Incomplete profile targeting
        AND (a.target_incomplete_profile = FALSE OR p_has_complete_profile = FALSE)
        
        -- Country targeting (with exclude support)
        AND (
            (a.target_country IS NULL OR a.target_country = '')
            OR (a.target_country_exclude = FALSE AND p_country = ANY(string_to_array(a.target_country, ',')))
            OR (a.target_country_exclude = TRUE AND (p_country IS NULL OR p_country NOT IN (SELECT unnest(string_to_array(a.target_country, ',')))))
        )
        
        -- City targeting (with exclude support)
        AND (
            (a.target_city IS NULL OR a.target_city = '')
            OR (a.target_city_exclude = FALSE AND p_city = ANY(string_to_array(a.target_city, ',')))
            OR (a.target_city_exclude = TRUE AND (p_city IS NULL OR p_city NOT IN (SELECT unnest(string_to_array(a.target_city, ',')))))
        )
        
        -- Profession targeting (with exclude support)
        AND (
            (a.target_profession IS NULL OR a.target_profession = '')
            OR (a.target_profession_exclude = FALSE AND p_profession = ANY(string_to_array(a.target_profession, ',')))
            OR (a.target_profession_exclude = TRUE AND (p_profession IS NULL OR p_profession NOT IN (SELECT unnest(string_to_array(a.target_profession, ',')))))
        )
        
        -- Speciality targeting (with exclude support)
        AND (
            (a.target_speciality IS NULL OR a.target_speciality = '')
            OR (a.target_speciality_exclude = FALSE AND p_speciality = ANY(string_to_array(a.target_speciality, ',')))
            OR (a.target_speciality_exclude = TRUE AND (p_speciality IS NULL OR p_speciality NOT IN (SELECT unnest(string_to_array(a.target_speciality, ',')))))
        )
        
        -- Degree targeting (with exclude support)
        AND (
            (a.target_degree IS NULL OR a.target_degree = '')
            OR (a.target_degree_exclude = FALSE AND p_degree = ANY(string_to_array(a.target_degree, ',')))
            OR (a.target_degree_exclude = TRUE AND (p_degree IS NULL OR p_degree NOT IN (SELECT unnest(string_to_array(a.target_degree, ',')))))
        )
        
        -- Experience targeting (with exclude support)
        AND (
            (a.target_years_experience IS NULL OR a.target_years_experience = '')
            OR (a.target_experience_exclude = FALSE AND p_experience = ANY(string_to_array(a.target_years_experience, ',')))
            OR (a.target_experience_exclude = TRUE AND (p_experience IS NULL OR p_experience NOT IN (SELECT unnest(string_to_array(a.target_years_experience, ',')))))
        )
        
        -- Platform targeting
        AND (a.target_platform IS NULL OR a.target_platform = '' OR p_platform = ANY(string_to_array(a.target_platform, ',')))
        
        -- Eligibility logic
        AND (
            p_surface = 'inbox'
            OR uas.status IS NULL
            OR uas.status = 'eligible'
            OR uas.status = 'seen'
            OR (a.kind IN ('survey', 'quiz', 'user_insights') AND a.dismissible_mode = 'remind_later' AND uas.status != 'completed')
        )
        
    ORDER BY 
        CASE a.importance WHEN 'high' THEN 1 WHEN 'medium' THEN 2 WHEN 'low' THEN 3 END,
        a.display_sequence ASC NULLS LAST,
        a.created_at DESC
    LIMIT p_limit
    OFFSET p_offset;
END;
$$;


ALTER FUNCTION public.get_eligible_announcements(p_user_id text, p_device_id text, p_auth_uid text, p_platform text, p_app_version text, p_country text, p_city text, p_is_logged_in boolean, p_profession text, p_speciality text, p_degree text, p_experience text, p_has_complete_profile boolean, p_session_number integer, p_surface text, p_limit integer, p_offset integer) OWNER TO postgres;

--
-- Name: get_eligible_announcements_fast(text, text, text, text, text, text, text, boolean, text, text, text, text, boolean, integer, text, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.get_eligible_announcements_fast(p_user_id text, p_device_id text, p_auth_uid text, p_platform text, p_app_version text, p_country text, p_city text, p_is_logged_in boolean, p_profession text, p_speciality text, p_degree text, p_experience text, p_has_complete_profile boolean, p_session_number integer, p_surface text, p_limit integer, p_offset integer) OWNER TO postgres;

--
-- Name: get_inbox_announcements(text, text, text, text, boolean, text, text, text, text, boolean, integer, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_inbox_announcements(p_user_id text, p_device_id text DEFAULT NULL::text, p_auth_uid text DEFAULT NULL::text, p_platform text DEFAULT NULL::text, p_is_logged_in boolean DEFAULT false, p_profession text DEFAULT NULL::text, p_speciality text DEFAULT NULL::text, p_degree text DEFAULT NULL::text, p_experience text DEFAULT NULL::text, p_has_complete_profile boolean DEFAULT false, p_session_number integer DEFAULT 1, p_page integer DEFAULT 1, p_page_size integer DEFAULT 20) RETURNS TABLE(id uuid, title text, message text, body text, surface text, importance text, kind text, priority text, action_type text, action_value text, dismissible boolean, dismissible_mode text, metadata jsonb, questions jsonb, user_status text, impression_count integer, is_partially_completed boolean, questions_answered integer, display_sequence integer, total_count bigint)
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    v_offset INTEGER;
    v_total BIGINT;
BEGIN
    v_offset := (p_page - 1) * p_page_size;
    
    SELECT COUNT(*) INTO v_total
    FROM get_eligible_announcements(
        p_user_id, p_device_id, p_auth_uid, p_platform, NULL,
        NULL, NULL, p_is_logged_in, p_profession, p_speciality,
        p_degree, p_experience, p_has_complete_profile,
        p_session_number, 'inbox', 1000, 0
    );
    
    RETURN QUERY
    SELECT 
        e.id, e.title, e.message, e.body, e.surface, e.importance,
        e.kind, e.priority, e.action_type, e.action_value, e.dismissible,
        e.dismissible_mode, e.metadata, e.questions, e.user_status,
        e.impression_count, e.is_partially_completed, e.questions_answered,
        e.display_sequence, v_total AS total_count
    FROM get_eligible_announcements(
        p_user_id, p_device_id, p_auth_uid, p_platform, NULL,
        NULL, NULL, p_is_logged_in, p_profession, p_speciality,
        p_degree, p_experience, p_has_complete_profile,
        p_session_number, 'inbox', p_page_size, v_offset
    ) e;
END;
$$;


ALTER FUNCTION public.get_inbox_announcements(p_user_id text, p_device_id text, p_auth_uid text, p_platform text, p_is_logged_in boolean, p_profession text, p_speciality text, p_degree text, p_experience text, p_has_complete_profile boolean, p_session_number integer, p_page integer, p_page_size integer) OWNER TO postgres;

--
-- Name: get_targeted_announcements(text, text, text, text, text, text, boolean, text, text); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.get_targeted_announcements(p_user_auth_uid text, p_surface text, p_app_version text, p_platform text, p_country text, p_city text, p_is_real_device boolean, p_device_brand text, p_ip_address text) OWNER TO postgres;

--
-- Name: get_tool_usage_by_period(timestamp with time zone, timestamp with time zone, text); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.get_tool_usage_by_period(p_start_date timestamp with time zone, p_end_date timestamp with time zone, p_tool_id text) OWNER TO postgres;

--
-- Name: get_tool_usage_cities(text, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.get_tool_usage_cities(p_tool_id text, p_days integer, p_limit integer) OWNER TO postgres;

--
-- Name: get_tool_usage_countries(text, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.get_tool_usage_countries(p_tool_id text, p_days integer, p_limit integer) OWNER TO postgres;

--
-- Name: get_tool_usage_daily(text, integer); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.get_tool_usage_daily(p_tool_id text, p_days integer) OWNER TO postgres;

--
-- Name: get_tool_usage_daily_by_country(text, integer, text[]); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.get_tool_usage_daily_by_country(p_tool_id text, p_days integer, p_countries text[]) OWNER TO postgres;

--
-- Name: get_tool_usage_leaderboard(integer); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.get_tool_usage_leaderboard(p_days integer) OWNER TO postgres;

--
-- Name: get_user_analytics_summary(uuid, integer); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.get_user_analytics_summary(p_user_id uuid, p_days integer) OWNER TO postgres;

--
-- Name: get_user_retention(date, date); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.get_user_retention(p_cohort_start date, p_cohort_end date) OWNER TO postgres;

--
-- Name: mark_announcement_status(text, uuid, text, jsonb); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.mark_announcement_status(p_user_id text, p_announcement_id uuid, p_status text, p_metadata jsonb) OWNER TO postgres;

--
-- Name: migrate_user_auth_uid(text, text); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.migrate_user_auth_uid(p_user_id text, p_new_auth_uid text) OWNER TO postgres;

--
-- Name: record_announcement_impression(uuid, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.record_announcement_impression(p_announcement_id uuid, p_user_id text) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
    INSERT INTO public.user_announcement_state (
        announcement_id,
        user_id,
        status,
        impression_count,
        first_seen_at,
        last_seen_at,
        updated_at
    ) VALUES (
        p_announcement_id,
        p_user_id,
        'seen',
        1,
        NOW(),
        NOW(),
        NOW()
    )
    ON CONFLICT (announcement_id, user_id) DO UPDATE SET
        impression_count = user_announcement_state.impression_count + 1,
        last_seen_at = NOW(),
        updated_at = NOW();
END;
$$;


ALTER FUNCTION public.record_announcement_impression(p_announcement_id uuid, p_user_id text) OWNER TO postgres;

--
-- Name: update_announcement_state(uuid, text, text, integer, integer, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
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
BEGIN
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
        -- Get total questions from announcement
        SELECT jsonb_array_length(COALESCE(questions, '[]'::jsonb)) INTO v_total_questions
        FROM public.announcements
        WHERE id = p_announcement_id;
        
        v_is_partially_completed := p_questions_answered < COALESCE(v_total_questions, 0);
        
        -- If all questions answered, mark as completed
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
        NOW(),
        p_session_number,
        v_defer_until_session,
        v_defer_until_time,
        CASE WHEN p_status = 'deferred' THEN 1 ELSE 0 END,
        COALESCE(v_is_partially_completed, FALSE),
        COALESCE(p_questions_answered, 0),
        1,
        CASE WHEN p_status = 'completed' THEN NOW() ELSE NULL END,
        CASE WHEN p_status = 'dismissed' THEN NOW() ELSE NULL END,
        CASE WHEN p_status = 'deferred' THEN NOW() ELSE NULL END,
        NOW()
    )
    ON CONFLICT (announcement_id, user_id) DO UPDATE SET
        status = EXCLUDED.status,
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
        defer_count = CASE 
            WHEN EXCLUDED.status = 'deferred' THEN user_announcement_state.defer_count + 1 
            ELSE user_announcement_state.defer_count 
        END,
        is_partially_completed = COALESCE(EXCLUDED.is_partially_completed, user_announcement_state.is_partially_completed),
        questions_answered = GREATEST(COALESCE(EXCLUDED.questions_answered, 0), COALESCE(user_announcement_state.questions_answered, 0)),
        impression_count = user_announcement_state.impression_count + 1,
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
        'is_partially_completed', COALESCE(v_is_partially_completed, FALSE),
        'questions_answered', COALESCE(p_questions_answered, 0)
    ) INTO v_result;
    
    RETURN v_result;
END;
$$;


ALTER FUNCTION public.update_announcement_state(p_announcement_id uuid, p_user_id text, p_status text, p_session_number integer, p_defer_sessions integer, p_defer_hours integer, p_questions_answered integer) OWNER TO postgres;

--
-- Name: update_last_updated_column(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_last_updated_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.last_updated = NOW();
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_last_updated_column() OWNER TO postgres;

--
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_updated_at_column() OWNER TO postgres;

--
-- Name: update_user_insights_from_response(); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.update_user_insights_from_response() OWNER TO postgres;

--
-- Name: update_user_location_from_session(); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.update_user_location_from_session() OWNER TO postgres;

--
-- Name: user_owns_data(text); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.user_owns_data(target_user_id text) OWNER TO postgres;

--
-- Name: apply_rls(jsonb, integer); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer DEFAULT (1024 * 1024)) RETURNS SETOF realtime.wal_rls
    LANGUAGE plpgsql
    AS $$
declare
-- Regclass of the table e.g. public.notes
entity_ regclass = (quote_ident(wal ->> 'schema') || '.' || quote_ident(wal ->> 'table'))::regclass;

-- I, U, D, T: insert, update ...
action realtime.action = (
    case wal ->> 'action'
        when 'I' then 'INSERT'
        when 'U' then 'UPDATE'
        when 'D' then 'DELETE'
        else 'ERROR'
    end
);

-- Is row level security enabled for the table
is_rls_enabled bool = relrowsecurity from pg_class where oid = entity_;

subscriptions realtime.subscription[] = array_agg(subs)
    from
        realtime.subscription subs
    where
        subs.entity = entity_;

-- Subscription vars
roles regrole[] = array_agg(distinct us.claims_role::text)
    from
        unnest(subscriptions) us;

working_role regrole;
claimed_role regrole;
claims jsonb;

subscription_id uuid;
subscription_has_access bool;
visible_to_subscription_ids uuid[] = '{}';

-- structured info for wal's columns
columns realtime.wal_column[];
-- previous identity values for update/delete
old_columns realtime.wal_column[];

error_record_exceeds_max_size boolean = octet_length(wal::text) > max_record_bytes;

-- Primary jsonb output for record
output jsonb;

begin
perform set_config('role', null, true);

columns =
    array_agg(
        (
            x->>'name',
            x->>'type',
            x->>'typeoid',
            realtime.cast(
                (x->'value') #>> '{}',
                coalesce(
                    (x->>'typeoid')::regtype, -- null when wal2json version <= 2.4
                    (x->>'type')::regtype
                )
            ),
            (pks ->> 'name') is not null,
            true
        )::realtime.wal_column
    )
    from
        jsonb_array_elements(wal -> 'columns') x
        left join jsonb_array_elements(wal -> 'pk') pks
            on (x ->> 'name') = (pks ->> 'name');

old_columns =
    array_agg(
        (
            x->>'name',
            x->>'type',
            x->>'typeoid',
            realtime.cast(
                (x->'value') #>> '{}',
                coalesce(
                    (x->>'typeoid')::regtype, -- null when wal2json version <= 2.4
                    (x->>'type')::regtype
                )
            ),
            (pks ->> 'name') is not null,
            true
        )::realtime.wal_column
    )
    from
        jsonb_array_elements(wal -> 'identity') x
        left join jsonb_array_elements(wal -> 'pk') pks
            on (x ->> 'name') = (pks ->> 'name');

for working_role in select * from unnest(roles) loop

    -- Update `is_selectable` for columns and old_columns
    columns =
        array_agg(
            (
                c.name,
                c.type_name,
                c.type_oid,
                c.value,
                c.is_pkey,
                pg_catalog.has_column_privilege(working_role, entity_, c.name, 'SELECT')
            )::realtime.wal_column
        )
        from
            unnest(columns) c;

    old_columns =
            array_agg(
                (
                    c.name,
                    c.type_name,
                    c.type_oid,
                    c.value,
                    c.is_pkey,
                    pg_catalog.has_column_privilege(working_role, entity_, c.name, 'SELECT')
                )::realtime.wal_column
            )
            from
                unnest(old_columns) c;

    if action <> 'DELETE' and count(1) = 0 from unnest(columns) c where c.is_pkey then
        return next (
            jsonb_build_object(
                'schema', wal ->> 'schema',
                'table', wal ->> 'table',
                'type', action
            ),
            is_rls_enabled,
            -- subscriptions is already filtered by entity
            (select array_agg(s.subscription_id) from unnest(subscriptions) as s where claims_role = working_role),
            array['Error 400: Bad Request, no primary key']
        )::realtime.wal_rls;

    -- The claims role does not have SELECT permission to the primary key of entity
    elsif action <> 'DELETE' and sum(c.is_selectable::int) <> count(1) from unnest(columns) c where c.is_pkey then
        return next (
            jsonb_build_object(
                'schema', wal ->> 'schema',
                'table', wal ->> 'table',
                'type', action
            ),
            is_rls_enabled,
            (select array_agg(s.subscription_id) from unnest(subscriptions) as s where claims_role = working_role),
            array['Error 401: Unauthorized']
        )::realtime.wal_rls;

    else
        output = jsonb_build_object(
            'schema', wal ->> 'schema',
            'table', wal ->> 'table',
            'type', action,
            'commit_timestamp', to_char(
                ((wal ->> 'timestamp')::timestamptz at time zone 'utc'),
                'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"'
            ),
            'columns', (
                select
                    jsonb_agg(
                        jsonb_build_object(
                            'name', pa.attname,
                            'type', pt.typname
                        )
                        order by pa.attnum asc
                    )
                from
                    pg_attribute pa
                    join pg_type pt
                        on pa.atttypid = pt.oid
                where
                    attrelid = entity_
                    and attnum > 0
                    and pg_catalog.has_column_privilege(working_role, entity_, pa.attname, 'SELECT')
            )
        )
        -- Add "record" key for insert and update
        || case
            when action in ('INSERT', 'UPDATE') then
                jsonb_build_object(
                    'record',
                    (
                        select
                            jsonb_object_agg(
                                -- if unchanged toast, get column name and value from old record
                                coalesce((c).name, (oc).name),
                                case
                                    when (c).name is null then (oc).value
                                    else (c).value
                                end
                            )
                        from
                            unnest(columns) c
                            full outer join unnest(old_columns) oc
                                on (c).name = (oc).name
                        where
                            coalesce((c).is_selectable, (oc).is_selectable)
                            and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                    )
                )
            else '{}'::jsonb
        end
        -- Add "old_record" key for update and delete
        || case
            when action = 'UPDATE' then
                jsonb_build_object(
                        'old_record',
                        (
                            select jsonb_object_agg((c).name, (c).value)
                            from unnest(old_columns) c
                            where
                                (c).is_selectable
                                and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                        )
                    )
            when action = 'DELETE' then
                jsonb_build_object(
                    'old_record',
                    (
                        select jsonb_object_agg((c).name, (c).value)
                        from unnest(old_columns) c
                        where
                            (c).is_selectable
                            and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                            and ( not is_rls_enabled or (c).is_pkey ) -- if RLS enabled, we can't secure deletes so filter to pkey
                    )
                )
            else '{}'::jsonb
        end;

        -- Create the prepared statement
        if is_rls_enabled and action <> 'DELETE' then
            if (select 1 from pg_prepared_statements where name = 'walrus_rls_stmt' limit 1) > 0 then
                deallocate walrus_rls_stmt;
            end if;
            execute realtime.build_prepared_statement_sql('walrus_rls_stmt', entity_, columns);
        end if;

        visible_to_subscription_ids = '{}';

        for subscription_id, claims in (
                select
                    subs.subscription_id,
                    subs.claims
                from
                    unnest(subscriptions) subs
                where
                    subs.entity = entity_
                    and subs.claims_role = working_role
                    and (
                        realtime.is_visible_through_filters(columns, subs.filters)
                        or (
                          action = 'DELETE'
                          and realtime.is_visible_through_filters(old_columns, subs.filters)
                        )
                    )
        ) loop

            if not is_rls_enabled or action = 'DELETE' then
                visible_to_subscription_ids = visible_to_subscription_ids || subscription_id;
            else
                -- Check if RLS allows the role to see the record
                perform
                    -- Trim leading and trailing quotes from working_role because set_config
                    -- doesn't recognize the role as valid if they are included
                    set_config('role', trim(both '"' from working_role::text), true),
                    set_config('request.jwt.claims', claims::text, true);

                execute 'execute walrus_rls_stmt' into subscription_has_access;

                if subscription_has_access then
                    visible_to_subscription_ids = visible_to_subscription_ids || subscription_id;
                end if;
            end if;
        end loop;

        perform set_config('role', null, true);

        return next (
            output,
            is_rls_enabled,
            visible_to_subscription_ids,
            case
                when error_record_exceeds_max_size then array['Error 413: Payload Too Large']
                else '{}'
            end
        )::realtime.wal_rls;

    end if;
end loop;

perform set_config('role', null, true);
end;
$$;


ALTER FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) OWNER TO supabase_admin;

--
-- Name: broadcast_changes(text, text, text, text, text, record, record, text); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.broadcast_changes(topic_name text, event_name text, operation text, table_name text, table_schema text, new record, old record, level text DEFAULT 'ROW'::text) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    -- Declare a variable to hold the JSONB representation of the row
    row_data jsonb := '{}'::jsonb;
BEGIN
    IF level = 'STATEMENT' THEN
        RAISE EXCEPTION 'function can only be triggered for each row, not for each statement';
    END IF;
    -- Check the operation type and handle accordingly
    IF operation = 'INSERT' OR operation = 'UPDATE' OR operation = 'DELETE' THEN
        row_data := jsonb_build_object('old_record', OLD, 'record', NEW, 'operation', operation, 'table', table_name, 'schema', table_schema);
        PERFORM realtime.send (row_data, event_name, topic_name);
    ELSE
        RAISE EXCEPTION 'Unexpected operation type: %', operation;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Failed to process the row: %', SQLERRM;
END;

$$;


ALTER FUNCTION realtime.broadcast_changes(topic_name text, event_name text, operation text, table_name text, table_schema text, new record, old record, level text) OWNER TO supabase_admin;

--
-- Name: build_prepared_statement_sql(text, regclass, realtime.wal_column[]); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) RETURNS text
    LANGUAGE sql
    AS $$
      /*
      Builds a sql string that, if executed, creates a prepared statement to
      tests retrive a row from *entity* by its primary key columns.
      Example
          select realtime.build_prepared_statement_sql('public.notes', '{"id"}'::text[], '{"bigint"}'::text[])
      */
          select
      'prepare ' || prepared_statement_name || ' as
          select
              exists(
                  select
                      1
                  from
                      ' || entity || '
                  where
                      ' || string_agg(quote_ident(pkc.name) || '=' || quote_nullable(pkc.value #>> '{}') , ' and ') || '
              )'
          from
              unnest(columns) pkc
          where
              pkc.is_pkey
          group by
              entity
      $$;


ALTER FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) OWNER TO supabase_admin;

--
-- Name: cast(text, regtype); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime."cast"(val text, type_ regtype) RETURNS jsonb
    LANGUAGE plpgsql IMMUTABLE
    AS $$
    declare
      res jsonb;
    begin
      execute format('select to_jsonb(%L::'|| type_::text || ')', val)  into res;
      return res;
    end
    $$;


ALTER FUNCTION realtime."cast"(val text, type_ regtype) OWNER TO supabase_admin;

--
-- Name: check_equality_op(realtime.equality_op, regtype, text, text); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
      /*
      Casts *val_1* and *val_2* as type *type_* and check the *op* condition for truthiness
      */
      declare
          op_symbol text = (
              case
                  when op = 'eq' then '='
                  when op = 'neq' then '!='
                  when op = 'lt' then '<'
                  when op = 'lte' then '<='
                  when op = 'gt' then '>'
                  when op = 'gte' then '>='
                  when op = 'in' then '= any'
                  else 'UNKNOWN OP'
              end
          );
          res boolean;
      begin
          execute format(
              'select %L::'|| type_::text || ' ' || op_symbol
              || ' ( %L::'
              || (
                  case
                      when op = 'in' then type_::text || '[]'
                      else type_::text end
              )
              || ')', val_1, val_2) into res;
          return res;
      end;
      $$;


ALTER FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) OWNER TO supabase_admin;

--
-- Name: is_visible_through_filters(realtime.wal_column[], realtime.user_defined_filter[]); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) RETURNS boolean
    LANGUAGE sql IMMUTABLE
    AS $_$
    /*
    Should the record be visible (true) or filtered out (false) after *filters* are applied
    */
        select
            -- Default to allowed when no filters present
            $2 is null -- no filters. this should not happen because subscriptions has a default
            or array_length($2, 1) is null -- array length of an empty array is null
            or bool_and(
                coalesce(
                    realtime.check_equality_op(
                        op:=f.op,
                        type_:=coalesce(
                            col.type_oid::regtype, -- null when wal2json version <= 2.4
                            col.type_name::regtype
                        ),
                        -- cast jsonb to text
                        val_1:=col.value #>> '{}',
                        val_2:=f.value
                    ),
                    false -- if null, filter does not match
                )
            )
        from
            unnest(filters) f
            join unnest(columns) col
                on f.column_name = col.name;
    $_$;


ALTER FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) OWNER TO supabase_admin;

--
-- Name: list_changes(name, name, integer, integer); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) RETURNS SETOF realtime.wal_rls
    LANGUAGE sql
    SET log_min_messages TO 'fatal'
    AS $$
      with pub as (
        select
          concat_ws(
            ',',
            case when bool_or(pubinsert) then 'insert' else null end,
            case when bool_or(pubupdate) then 'update' else null end,
            case when bool_or(pubdelete) then 'delete' else null end
          ) as w2j_actions,
          coalesce(
            string_agg(
              realtime.quote_wal2json(format('%I.%I', schemaname, tablename)::regclass),
              ','
            ) filter (where ppt.tablename is not null and ppt.tablename not like '% %'),
            ''
          ) w2j_add_tables
        from
          pg_publication pp
          left join pg_publication_tables ppt
            on pp.pubname = ppt.pubname
        where
          pp.pubname = publication
        group by
          pp.pubname
        limit 1
      ),
      w2j as (
        select
          x.*, pub.w2j_add_tables
        from
          pub,
          pg_logical_slot_get_changes(
            slot_name, null, max_changes,
            'include-pk', 'true',
            'include-transaction', 'false',
            'include-timestamp', 'true',
            'include-type-oids', 'true',
            'format-version', '2',
            'actions', pub.w2j_actions,
            'add-tables', pub.w2j_add_tables
          ) x
      )
      select
        xyz.wal,
        xyz.is_rls_enabled,
        xyz.subscription_ids,
        xyz.errors
      from
        w2j,
        realtime.apply_rls(
          wal := w2j.data::jsonb,
          max_record_bytes := max_record_bytes
        ) xyz(wal, is_rls_enabled, subscription_ids, errors)
      where
        w2j.w2j_add_tables <> ''
        and xyz.subscription_ids[1] is not null
    $$;


ALTER FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) OWNER TO supabase_admin;

--
-- Name: quote_wal2json(regclass); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.quote_wal2json(entity regclass) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $$
      select
        (
          select string_agg('' || ch,'')
          from unnest(string_to_array(nsp.nspname::text, null)) with ordinality x(ch, idx)
          where
            not (x.idx = 1 and x.ch = '"')
            and not (
              x.idx = array_length(string_to_array(nsp.nspname::text, null), 1)
              and x.ch = '"'
            )
        )
        || '.'
        || (
          select string_agg('' || ch,'')
          from unnest(string_to_array(pc.relname::text, null)) with ordinality x(ch, idx)
          where
            not (x.idx = 1 and x.ch = '"')
            and not (
              x.idx = array_length(string_to_array(nsp.nspname::text, null), 1)
              and x.ch = '"'
            )
          )
      from
        pg_class pc
        join pg_namespace nsp
          on pc.relnamespace = nsp.oid
      where
        pc.oid = entity
    $$;


ALTER FUNCTION realtime.quote_wal2json(entity regclass) OWNER TO supabase_admin;

--
-- Name: send(jsonb, text, text, boolean); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.send(payload jsonb, event text, topic text, private boolean DEFAULT true) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
  generated_id uuid;
  final_payload jsonb;
BEGIN
  BEGIN
    -- Generate a new UUID for the id
    generated_id := gen_random_uuid();

    -- Check if payload has an 'id' key, if not, add the generated UUID
    IF payload ? 'id' THEN
      final_payload := payload;
    ELSE
      final_payload := jsonb_set(payload, '{id}', to_jsonb(generated_id));
    END IF;

    -- Set the topic configuration
    EXECUTE format('SET LOCAL realtime.topic TO %L', topic);

    -- Attempt to insert the message
    INSERT INTO realtime.messages (id, payload, event, topic, private, extension)
    VALUES (generated_id, final_payload, event, topic, private, 'broadcast');
  EXCEPTION
    WHEN OTHERS THEN
      -- Capture and notify the error
      RAISE WARNING 'ErrorSendingBroadcastMessage: %', SQLERRM;
  END;
END;
$$;


ALTER FUNCTION realtime.send(payload jsonb, event text, topic text, private boolean) OWNER TO supabase_admin;

--
-- Name: subscription_check_filters(); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.subscription_check_filters() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    /*
    Validates that the user defined filters for a subscription:
    - refer to valid columns that the claimed role may access
    - values are coercable to the correct column type
    */
    declare
        col_names text[] = coalesce(
                array_agg(c.column_name order by c.ordinal_position),
                '{}'::text[]
            )
            from
                information_schema.columns c
            where
                format('%I.%I', c.table_schema, c.table_name)::regclass = new.entity
                and pg_catalog.has_column_privilege(
                    (new.claims ->> 'role'),
                    format('%I.%I', c.table_schema, c.table_name)::regclass,
                    c.column_name,
                    'SELECT'
                );
        filter realtime.user_defined_filter;
        col_type regtype;

        in_val jsonb;
    begin
        for filter in select * from unnest(new.filters) loop
            -- Filtered column is valid
            if not filter.column_name = any(col_names) then
                raise exception 'invalid column for filter %', filter.column_name;
            end if;

            -- Type is sanitized and safe for string interpolation
            col_type = (
                select atttypid::regtype
                from pg_catalog.pg_attribute
                where attrelid = new.entity
                      and attname = filter.column_name
            );
            if col_type is null then
                raise exception 'failed to lookup type for column %', filter.column_name;
            end if;

            -- Set maximum number of entries for in filter
            if filter.op = 'in'::realtime.equality_op then
                in_val = realtime.cast(filter.value, (col_type::text || '[]')::regtype);
                if coalesce(jsonb_array_length(in_val), 0) > 100 then
                    raise exception 'too many values for `in` filter. Maximum 100';
                end if;
            else
                -- raises an exception if value is not coercable to type
                perform realtime.cast(filter.value, col_type);
            end if;

        end loop;

        -- Apply consistent order to filters so the unique constraint on
        -- (subscription_id, entity, filters) can't be tricked by a different filter order
        new.filters = coalesce(
            array_agg(f order by f.column_name, f.op, f.value),
            '{}'
        ) from unnest(new.filters) f;

        return new;
    end;
    $$;


ALTER FUNCTION realtime.subscription_check_filters() OWNER TO supabase_admin;

--
-- Name: to_regrole(text); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.to_regrole(role_name text) RETURNS regrole
    LANGUAGE sql IMMUTABLE
    AS $$ select role_name::regrole $$;


ALTER FUNCTION realtime.to_regrole(role_name text) OWNER TO supabase_admin;

--
-- Name: topic(); Type: FUNCTION; Schema: realtime; Owner: supabase_realtime_admin
--

CREATE FUNCTION realtime.topic() RETURNS text
    LANGUAGE sql STABLE
    AS $$
select nullif(current_setting('realtime.topic', true), '')::text;
$$;


ALTER FUNCTION realtime.topic() OWNER TO supabase_realtime_admin;

--
-- Name: add_prefixes(text, text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.add_prefixes(_bucket_id text, _name text) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    prefixes text[];
BEGIN
    prefixes := "storage"."get_prefixes"("_name");

    IF array_length(prefixes, 1) > 0 THEN
        INSERT INTO storage.prefixes (name, bucket_id)
        SELECT UNNEST(prefixes) as name, "_bucket_id" ON CONFLICT DO NOTHING;
    END IF;
END;
$$;


ALTER FUNCTION storage.add_prefixes(_bucket_id text, _name text) OWNER TO supabase_storage_admin;

--
-- Name: can_insert_object(text, text, uuid, jsonb); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.can_insert_object(bucketid text, name text, owner uuid, metadata jsonb) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO "storage"."objects" ("bucket_id", "name", "owner", "metadata") VALUES (bucketid, name, owner, metadata);
  -- hack to rollback the successful insert
  RAISE sqlstate 'PT200' using
  message = 'ROLLBACK',
  detail = 'rollback successful insert';
END
$$;


ALTER FUNCTION storage.can_insert_object(bucketid text, name text, owner uuid, metadata jsonb) OWNER TO supabase_storage_admin;

--
-- Name: delete_leaf_prefixes(text[], text[]); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.delete_leaf_prefixes(bucket_ids text[], names text[]) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    v_rows_deleted integer;
BEGIN
    LOOP
        WITH candidates AS (
            SELECT DISTINCT
                t.bucket_id,
                unnest(storage.get_prefixes(t.name)) AS name
            FROM unnest(bucket_ids, names) AS t(bucket_id, name)
        ),
        uniq AS (
             SELECT
                 bucket_id,
                 name,
                 storage.get_level(name) AS level
             FROM candidates
             WHERE name <> ''
             GROUP BY bucket_id, name
        ),
        leaf AS (
             SELECT
                 p.bucket_id,
                 p.name,
                 p.level
             FROM storage.prefixes AS p
                  JOIN uniq AS u
                       ON u.bucket_id = p.bucket_id
                           AND u.name = p.name
                           AND u.level = p.level
             WHERE NOT EXISTS (
                 SELECT 1
                 FROM storage.objects AS o
                 WHERE o.bucket_id = p.bucket_id
                   AND o.level = p.level + 1
                   AND o.name COLLATE "C" LIKE p.name || '/%'
             )
             AND NOT EXISTS (
                 SELECT 1
                 FROM storage.prefixes AS c
                 WHERE c.bucket_id = p.bucket_id
                   AND c.level = p.level + 1
                   AND c.name COLLATE "C" LIKE p.name || '/%'
             )
        )
        DELETE
        FROM storage.prefixes AS p
            USING leaf AS l
        WHERE p.bucket_id = l.bucket_id
          AND p.name = l.name
          AND p.level = l.level;

        GET DIAGNOSTICS v_rows_deleted = ROW_COUNT;
        EXIT WHEN v_rows_deleted = 0;
    END LOOP;
END;
$$;


ALTER FUNCTION storage.delete_leaf_prefixes(bucket_ids text[], names text[]) OWNER TO supabase_storage_admin;

--
-- Name: delete_prefix(text, text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.delete_prefix(_bucket_id text, _name text) RETURNS boolean
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
    -- Check if we can delete the prefix
    IF EXISTS(
        SELECT FROM "storage"."prefixes"
        WHERE "prefixes"."bucket_id" = "_bucket_id"
          AND level = "storage"."get_level"("_name") + 1
          AND "prefixes"."name" COLLATE "C" LIKE "_name" || '/%'
        LIMIT 1
    )
    OR EXISTS(
        SELECT FROM "storage"."objects"
        WHERE "objects"."bucket_id" = "_bucket_id"
          AND "storage"."get_level"("objects"."name") = "storage"."get_level"("_name") + 1
          AND "objects"."name" COLLATE "C" LIKE "_name" || '/%'
        LIMIT 1
    ) THEN
    -- There are sub-objects, skip deletion
    RETURN false;
    ELSE
        DELETE FROM "storage"."prefixes"
        WHERE "prefixes"."bucket_id" = "_bucket_id"
          AND level = "storage"."get_level"("_name")
          AND "prefixes"."name" = "_name";
        RETURN true;
    END IF;
END;
$$;


ALTER FUNCTION storage.delete_prefix(_bucket_id text, _name text) OWNER TO supabase_storage_admin;

--
-- Name: delete_prefix_hierarchy_trigger(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.delete_prefix_hierarchy_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    prefix text;
BEGIN
    prefix := "storage"."get_prefix"(OLD."name");

    IF coalesce(prefix, '') != '' THEN
        PERFORM "storage"."delete_prefix"(OLD."bucket_id", prefix);
    END IF;

    RETURN OLD;
END;
$$;


ALTER FUNCTION storage.delete_prefix_hierarchy_trigger() OWNER TO supabase_storage_admin;

--
-- Name: enforce_bucket_name_length(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.enforce_bucket_name_length() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
    if length(new.name) > 100 then
        raise exception 'bucket name "%" is too long (% characters). Max is 100.', new.name, length(new.name);
    end if;
    return new;
end;
$$;


ALTER FUNCTION storage.enforce_bucket_name_length() OWNER TO supabase_storage_admin;

--
-- Name: extension(text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.extension(name text) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $$
DECLARE
    _parts text[];
    _filename text;
BEGIN
    SELECT string_to_array(name, '/') INTO _parts;
    SELECT _parts[array_length(_parts,1)] INTO _filename;
    RETURN reverse(split_part(reverse(_filename), '.', 1));
END
$$;


ALTER FUNCTION storage.extension(name text) OWNER TO supabase_storage_admin;

--
-- Name: filename(text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.filename(name text) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
_parts text[];
BEGIN
	select string_to_array(name, '/') into _parts;
	return _parts[array_length(_parts,1)];
END
$$;


ALTER FUNCTION storage.filename(name text) OWNER TO supabase_storage_admin;

--
-- Name: foldername(text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.foldername(name text) RETURNS text[]
    LANGUAGE plpgsql IMMUTABLE
    AS $$
DECLARE
    _parts text[];
BEGIN
    -- Split on "/" to get path segments
    SELECT string_to_array(name, '/') INTO _parts;
    -- Return everything except the last segment
    RETURN _parts[1 : array_length(_parts,1) - 1];
END
$$;


ALTER FUNCTION storage.foldername(name text) OWNER TO supabase_storage_admin;

--
-- Name: get_level(text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.get_level(name text) RETURNS integer
    LANGUAGE sql IMMUTABLE STRICT
    AS $$
SELECT array_length(string_to_array("name", '/'), 1);
$$;


ALTER FUNCTION storage.get_level(name text) OWNER TO supabase_storage_admin;

--
-- Name: get_prefix(text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.get_prefix(name text) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
SELECT
    CASE WHEN strpos("name", '/') > 0 THEN
             regexp_replace("name", '[\/]{1}[^\/]+\/?$', '')
         ELSE
             ''
        END;
$_$;


ALTER FUNCTION storage.get_prefix(name text) OWNER TO supabase_storage_admin;

--
-- Name: get_prefixes(text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.get_prefixes(name text) RETURNS text[]
    LANGUAGE plpgsql IMMUTABLE STRICT
    AS $$
DECLARE
    parts text[];
    prefixes text[];
    prefix text;
BEGIN
    -- Split the name into parts by '/'
    parts := string_to_array("name", '/');
    prefixes := '{}';

    -- Construct the prefixes, stopping one level below the last part
    FOR i IN 1..array_length(parts, 1) - 1 LOOP
            prefix := array_to_string(parts[1:i], '/');
            prefixes := array_append(prefixes, prefix);
    END LOOP;

    RETURN prefixes;
END;
$$;


ALTER FUNCTION storage.get_prefixes(name text) OWNER TO supabase_storage_admin;

--
-- Name: get_size_by_bucket(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.get_size_by_bucket() RETURNS TABLE(size bigint, bucket_id text)
    LANGUAGE plpgsql STABLE
    AS $$
BEGIN
    return query
        select sum((metadata->>'size')::bigint) as size, obj.bucket_id
        from "storage".objects as obj
        group by obj.bucket_id;
END
$$;


ALTER FUNCTION storage.get_size_by_bucket() OWNER TO supabase_storage_admin;

--
-- Name: list_multipart_uploads_with_delimiter(text, text, text, integer, text, text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.list_multipart_uploads_with_delimiter(bucket_id text, prefix_param text, delimiter_param text, max_keys integer DEFAULT 100, next_key_token text DEFAULT ''::text, next_upload_token text DEFAULT ''::text) RETURNS TABLE(key text, id text, created_at timestamp with time zone)
    LANGUAGE plpgsql
    AS $_$
BEGIN
    RETURN QUERY EXECUTE
        'SELECT DISTINCT ON(key COLLATE "C") * from (
            SELECT
                CASE
                    WHEN position($2 IN substring(key from length($1) + 1)) > 0 THEN
                        substring(key from 1 for length($1) + position($2 IN substring(key from length($1) + 1)))
                    ELSE
                        key
                END AS key, id, created_at
            FROM
                storage.s3_multipart_uploads
            WHERE
                bucket_id = $5 AND
                key ILIKE $1 || ''%'' AND
                CASE
                    WHEN $4 != '''' AND $6 = '''' THEN
                        CASE
                            WHEN position($2 IN substring(key from length($1) + 1)) > 0 THEN
                                substring(key from 1 for length($1) + position($2 IN substring(key from length($1) + 1))) COLLATE "C" > $4
                            ELSE
                                key COLLATE "C" > $4
                            END
                    ELSE
                        true
                END AND
                CASE
                    WHEN $6 != '''' THEN
                        id COLLATE "C" > $6
                    ELSE
                        true
                    END
            ORDER BY
                key COLLATE "C" ASC, created_at ASC) as e order by key COLLATE "C" LIMIT $3'
        USING prefix_param, delimiter_param, max_keys, next_key_token, bucket_id, next_upload_token;
END;
$_$;


ALTER FUNCTION storage.list_multipart_uploads_with_delimiter(bucket_id text, prefix_param text, delimiter_param text, max_keys integer, next_key_token text, next_upload_token text) OWNER TO supabase_storage_admin;

--
-- Name: list_objects_with_delimiter(text, text, text, integer, text, text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.list_objects_with_delimiter(bucket_id text, prefix_param text, delimiter_param text, max_keys integer DEFAULT 100, start_after text DEFAULT ''::text, next_token text DEFAULT ''::text) RETURNS TABLE(name text, id uuid, metadata jsonb, updated_at timestamp with time zone)
    LANGUAGE plpgsql
    AS $_$
BEGIN
    RETURN QUERY EXECUTE
        'SELECT DISTINCT ON(name COLLATE "C") * from (
            SELECT
                CASE
                    WHEN position($2 IN substring(name from length($1) + 1)) > 0 THEN
                        substring(name from 1 for length($1) + position($2 IN substring(name from length($1) + 1)))
                    ELSE
                        name
                END AS name, id, metadata, updated_at
            FROM
                storage.objects
            WHERE
                bucket_id = $5 AND
                name ILIKE $1 || ''%'' AND
                CASE
                    WHEN $6 != '''' THEN
                    name COLLATE "C" > $6
                ELSE true END
                AND CASE
                    WHEN $4 != '''' THEN
                        CASE
                            WHEN position($2 IN substring(name from length($1) + 1)) > 0 THEN
                                substring(name from 1 for length($1) + position($2 IN substring(name from length($1) + 1))) COLLATE "C" > $4
                            ELSE
                                name COLLATE "C" > $4
                            END
                    ELSE
                        true
                END
            ORDER BY
                name COLLATE "C" ASC) as e order by name COLLATE "C" LIMIT $3'
        USING prefix_param, delimiter_param, max_keys, next_token, bucket_id, start_after;
END;
$_$;


ALTER FUNCTION storage.list_objects_with_delimiter(bucket_id text, prefix_param text, delimiter_param text, max_keys integer, start_after text, next_token text) OWNER TO supabase_storage_admin;

--
-- Name: lock_top_prefixes(text[], text[]); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.lock_top_prefixes(bucket_ids text[], names text[]) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    v_bucket text;
    v_top text;
BEGIN
    FOR v_bucket, v_top IN
        SELECT DISTINCT t.bucket_id,
            split_part(t.name, '/', 1) AS top
        FROM unnest(bucket_ids, names) AS t(bucket_id, name)
        WHERE t.name <> ''
        ORDER BY 1, 2
        LOOP
            PERFORM pg_advisory_xact_lock(hashtextextended(v_bucket || '/' || v_top, 0));
        END LOOP;
END;
$$;


ALTER FUNCTION storage.lock_top_prefixes(bucket_ids text[], names text[]) OWNER TO supabase_storage_admin;

--
-- Name: objects_delete_cleanup(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.objects_delete_cleanup() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    v_bucket_ids text[];
    v_names      text[];
BEGIN
    IF current_setting('storage.gc.prefixes', true) = '1' THEN
        RETURN NULL;
    END IF;

    PERFORM set_config('storage.gc.prefixes', '1', true);

    SELECT COALESCE(array_agg(d.bucket_id), '{}'),
           COALESCE(array_agg(d.name), '{}')
    INTO v_bucket_ids, v_names
    FROM deleted AS d
    WHERE d.name <> '';

    PERFORM storage.lock_top_prefixes(v_bucket_ids, v_names);
    PERFORM storage.delete_leaf_prefixes(v_bucket_ids, v_names);

    RETURN NULL;
END;
$$;


ALTER FUNCTION storage.objects_delete_cleanup() OWNER TO supabase_storage_admin;

--
-- Name: objects_insert_prefix_trigger(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.objects_insert_prefix_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    PERFORM "storage"."add_prefixes"(NEW."bucket_id", NEW."name");
    NEW.level := "storage"."get_level"(NEW."name");

    RETURN NEW;
END;
$$;


ALTER FUNCTION storage.objects_insert_prefix_trigger() OWNER TO supabase_storage_admin;

--
-- Name: objects_update_cleanup(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.objects_update_cleanup() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    -- NEW - OLD (destinations to create prefixes for)
    v_add_bucket_ids text[];
    v_add_names      text[];

    -- OLD - NEW (sources to prune)
    v_src_bucket_ids text[];
    v_src_names      text[];
BEGIN
    IF TG_OP <> 'UPDATE' THEN
        RETURN NULL;
    END IF;

    -- 1) Compute NEW−OLD (added paths) and OLD−NEW (moved-away paths)
    WITH added AS (
        SELECT n.bucket_id, n.name
        FROM new_rows n
        WHERE n.name <> '' AND position('/' in n.name) > 0
        EXCEPT
        SELECT o.bucket_id, o.name FROM old_rows o WHERE o.name <> ''
    ),
    moved AS (
         SELECT o.bucket_id, o.name
         FROM old_rows o
         WHERE o.name <> ''
         EXCEPT
         SELECT n.bucket_id, n.name FROM new_rows n WHERE n.name <> ''
    )
    SELECT
        -- arrays for ADDED (dest) in stable order
        COALESCE( (SELECT array_agg(a.bucket_id ORDER BY a.bucket_id, a.name) FROM added a), '{}' ),
        COALESCE( (SELECT array_agg(a.name      ORDER BY a.bucket_id, a.name) FROM added a), '{}' ),
        -- arrays for MOVED (src) in stable order
        COALESCE( (SELECT array_agg(m.bucket_id ORDER BY m.bucket_id, m.name) FROM moved m), '{}' ),
        COALESCE( (SELECT array_agg(m.name      ORDER BY m.bucket_id, m.name) FROM moved m), '{}' )
    INTO v_add_bucket_ids, v_add_names, v_src_bucket_ids, v_src_names;

    -- Nothing to do?
    IF (array_length(v_add_bucket_ids, 1) IS NULL) AND (array_length(v_src_bucket_ids, 1) IS NULL) THEN
        RETURN NULL;
    END IF;

    -- 2) Take per-(bucket, top) locks: ALL prefixes in consistent global order to prevent deadlocks
    DECLARE
        v_all_bucket_ids text[];
        v_all_names text[];
    BEGIN
        -- Combine source and destination arrays for consistent lock ordering
        v_all_bucket_ids := COALESCE(v_src_bucket_ids, '{}') || COALESCE(v_add_bucket_ids, '{}');
        v_all_names := COALESCE(v_src_names, '{}') || COALESCE(v_add_names, '{}');

        -- Single lock call ensures consistent global ordering across all transactions
        IF array_length(v_all_bucket_ids, 1) IS NOT NULL THEN
            PERFORM storage.lock_top_prefixes(v_all_bucket_ids, v_all_names);
        END IF;
    END;

    -- 3) Create destination prefixes (NEW−OLD) BEFORE pruning sources
    IF array_length(v_add_bucket_ids, 1) IS NOT NULL THEN
        WITH candidates AS (
            SELECT DISTINCT t.bucket_id, unnest(storage.get_prefixes(t.name)) AS name
            FROM unnest(v_add_bucket_ids, v_add_names) AS t(bucket_id, name)
            WHERE name <> ''
        )
        INSERT INTO storage.prefixes (bucket_id, name)
        SELECT c.bucket_id, c.name
        FROM candidates c
        ON CONFLICT DO NOTHING;
    END IF;

    -- 4) Prune source prefixes bottom-up for OLD−NEW
    IF array_length(v_src_bucket_ids, 1) IS NOT NULL THEN
        -- re-entrancy guard so DELETE on prefixes won't recurse
        IF current_setting('storage.gc.prefixes', true) <> '1' THEN
            PERFORM set_config('storage.gc.prefixes', '1', true);
        END IF;

        PERFORM storage.delete_leaf_prefixes(v_src_bucket_ids, v_src_names);
    END IF;

    RETURN NULL;
END;
$$;


ALTER FUNCTION storage.objects_update_cleanup() OWNER TO supabase_storage_admin;

--
-- Name: objects_update_level_trigger(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.objects_update_level_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Ensure this is an update operation and the name has changed
    IF TG_OP = 'UPDATE' AND (NEW."name" <> OLD."name" OR NEW."bucket_id" <> OLD."bucket_id") THEN
        -- Set the new level
        NEW."level" := "storage"."get_level"(NEW."name");
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION storage.objects_update_level_trigger() OWNER TO supabase_storage_admin;

--
-- Name: objects_update_prefix_trigger(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.objects_update_prefix_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    old_prefixes TEXT[];
BEGIN
    -- Ensure this is an update operation and the name has changed
    IF TG_OP = 'UPDATE' AND (NEW."name" <> OLD."name" OR NEW."bucket_id" <> OLD."bucket_id") THEN
        -- Retrieve old prefixes
        old_prefixes := "storage"."get_prefixes"(OLD."name");

        -- Remove old prefixes that are only used by this object
        WITH all_prefixes as (
            SELECT unnest(old_prefixes) as prefix
        ),
        can_delete_prefixes as (
             SELECT prefix
             FROM all_prefixes
             WHERE NOT EXISTS (
                 SELECT 1 FROM "storage"."objects"
                 WHERE "bucket_id" = OLD."bucket_id"
                   AND "name" <> OLD."name"
                   AND "name" LIKE (prefix || '%')
             )
         )
        DELETE FROM "storage"."prefixes" WHERE name IN (SELECT prefix FROM can_delete_prefixes);

        -- Add new prefixes
        PERFORM "storage"."add_prefixes"(NEW."bucket_id", NEW."name");
    END IF;
    -- Set the new level
    NEW."level" := "storage"."get_level"(NEW."name");

    RETURN NEW;
END;
$$;


ALTER FUNCTION storage.objects_update_prefix_trigger() OWNER TO supabase_storage_admin;

--
-- Name: operation(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.operation() RETURNS text
    LANGUAGE plpgsql STABLE
    AS $$
BEGIN
    RETURN current_setting('storage.operation', true);
END;
$$;


ALTER FUNCTION storage.operation() OWNER TO supabase_storage_admin;

--
-- Name: prefixes_delete_cleanup(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.prefixes_delete_cleanup() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    v_bucket_ids text[];
    v_names      text[];
BEGIN
    IF current_setting('storage.gc.prefixes', true) = '1' THEN
        RETURN NULL;
    END IF;

    PERFORM set_config('storage.gc.prefixes', '1', true);

    SELECT COALESCE(array_agg(d.bucket_id), '{}'),
           COALESCE(array_agg(d.name), '{}')
    INTO v_bucket_ids, v_names
    FROM deleted AS d
    WHERE d.name <> '';

    PERFORM storage.lock_top_prefixes(v_bucket_ids, v_names);
    PERFORM storage.delete_leaf_prefixes(v_bucket_ids, v_names);

    RETURN NULL;
END;
$$;


ALTER FUNCTION storage.prefixes_delete_cleanup() OWNER TO supabase_storage_admin;

--
-- Name: prefixes_insert_trigger(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.prefixes_insert_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    PERFORM "storage"."add_prefixes"(NEW."bucket_id", NEW."name");
    RETURN NEW;
END;
$$;


ALTER FUNCTION storage.prefixes_insert_trigger() OWNER TO supabase_storage_admin;

--
-- Name: search(text, text, integer, integer, integer, text, text, text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.search(prefix text, bucketname text, limits integer DEFAULT 100, levels integer DEFAULT 1, offsets integer DEFAULT 0, search text DEFAULT ''::text, sortcolumn text DEFAULT 'name'::text, sortorder text DEFAULT 'asc'::text) RETURNS TABLE(name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, metadata jsonb)
    LANGUAGE plpgsql
    AS $$
declare
    can_bypass_rls BOOLEAN;
begin
    SELECT rolbypassrls
    INTO can_bypass_rls
    FROM pg_roles
    WHERE rolname = coalesce(nullif(current_setting('role', true), 'none'), current_user);

    IF can_bypass_rls THEN
        RETURN QUERY SELECT * FROM storage.search_v1_optimised(prefix, bucketname, limits, levels, offsets, search, sortcolumn, sortorder);
    ELSE
        RETURN QUERY SELECT * FROM storage.search_legacy_v1(prefix, bucketname, limits, levels, offsets, search, sortcolumn, sortorder);
    END IF;
end;
$$;


ALTER FUNCTION storage.search(prefix text, bucketname text, limits integer, levels integer, offsets integer, search text, sortcolumn text, sortorder text) OWNER TO supabase_storage_admin;

--
-- Name: search_legacy_v1(text, text, integer, integer, integer, text, text, text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.search_legacy_v1(prefix text, bucketname text, limits integer DEFAULT 100, levels integer DEFAULT 1, offsets integer DEFAULT 0, search text DEFAULT ''::text, sortcolumn text DEFAULT 'name'::text, sortorder text DEFAULT 'asc'::text) RETURNS TABLE(name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, metadata jsonb)
    LANGUAGE plpgsql STABLE
    AS $_$
declare
    v_order_by text;
    v_sort_order text;
begin
    case
        when sortcolumn = 'name' then
            v_order_by = 'name';
        when sortcolumn = 'updated_at' then
            v_order_by = 'updated_at';
        when sortcolumn = 'created_at' then
            v_order_by = 'created_at';
        when sortcolumn = 'last_accessed_at' then
            v_order_by = 'last_accessed_at';
        else
            v_order_by = 'name';
        end case;

    case
        when sortorder = 'asc' then
            v_sort_order = 'asc';
        when sortorder = 'desc' then
            v_sort_order = 'desc';
        else
            v_sort_order = 'asc';
        end case;

    v_order_by = v_order_by || ' ' || v_sort_order;

    return query execute
        'with folders as (
           select path_tokens[$1] as folder
           from storage.objects
             where objects.name ilike $2 || $3 || ''%''
               and bucket_id = $4
               and array_length(objects.path_tokens, 1) <> $1
           group by folder
           order by folder ' || v_sort_order || '
     )
     (select folder as "name",
            null as id,
            null as updated_at,
            null as created_at,
            null as last_accessed_at,
            null as metadata from folders)
     union all
     (select path_tokens[$1] as "name",
            id,
            updated_at,
            created_at,
            last_accessed_at,
            metadata
     from storage.objects
     where objects.name ilike $2 || $3 || ''%''
       and bucket_id = $4
       and array_length(objects.path_tokens, 1) = $1
     order by ' || v_order_by || ')
     limit $5
     offset $6' using levels, prefix, search, bucketname, limits, offsets;
end;
$_$;


ALTER FUNCTION storage.search_legacy_v1(prefix text, bucketname text, limits integer, levels integer, offsets integer, search text, sortcolumn text, sortorder text) OWNER TO supabase_storage_admin;

--
-- Name: search_v1_optimised(text, text, integer, integer, integer, text, text, text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.search_v1_optimised(prefix text, bucketname text, limits integer DEFAULT 100, levels integer DEFAULT 1, offsets integer DEFAULT 0, search text DEFAULT ''::text, sortcolumn text DEFAULT 'name'::text, sortorder text DEFAULT 'asc'::text) RETURNS TABLE(name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, metadata jsonb)
    LANGUAGE plpgsql STABLE
    AS $_$
declare
    v_order_by text;
    v_sort_order text;
begin
    case
        when sortcolumn = 'name' then
            v_order_by = 'name';
        when sortcolumn = 'updated_at' then
            v_order_by = 'updated_at';
        when sortcolumn = 'created_at' then
            v_order_by = 'created_at';
        when sortcolumn = 'last_accessed_at' then
            v_order_by = 'last_accessed_at';
        else
            v_order_by = 'name';
        end case;

    case
        when sortorder = 'asc' then
            v_sort_order = 'asc';
        when sortorder = 'desc' then
            v_sort_order = 'desc';
        else
            v_sort_order = 'asc';
        end case;

    v_order_by = v_order_by || ' ' || v_sort_order;

    return query execute
        'with folders as (
           select (string_to_array(name, ''/''))[level] as name
           from storage.prefixes
             where lower(prefixes.name) like lower($2 || $3) || ''%''
               and bucket_id = $4
               and level = $1
           order by name ' || v_sort_order || '
     )
     (select name,
            null as id,
            null as updated_at,
            null as created_at,
            null as last_accessed_at,
            null as metadata from folders)
     union all
     (select path_tokens[level] as "name",
            id,
            updated_at,
            created_at,
            last_accessed_at,
            metadata
     from storage.objects
     where lower(objects.name) like lower($2 || $3) || ''%''
       and bucket_id = $4
       and level = $1
     order by ' || v_order_by || ')
     limit $5
     offset $6' using levels, prefix, search, bucketname, limits, offsets;
end;
$_$;


ALTER FUNCTION storage.search_v1_optimised(prefix text, bucketname text, limits integer, levels integer, offsets integer, search text, sortcolumn text, sortorder text) OWNER TO supabase_storage_admin;

--
-- Name: search_v2(text, text, integer, integer, text, text, text, text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.search_v2(prefix text, bucket_name text, limits integer DEFAULT 100, levels integer DEFAULT 1, start_after text DEFAULT ''::text, sort_order text DEFAULT 'asc'::text, sort_column text DEFAULT 'name'::text, sort_column_after text DEFAULT ''::text) RETURNS TABLE(key text, name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, metadata jsonb)
    LANGUAGE plpgsql STABLE
    AS $_$
DECLARE
    sort_col text;
    sort_ord text;
    cursor_op text;
    cursor_expr text;
    sort_expr text;
BEGIN
    -- Validate sort_order
    sort_ord := lower(sort_order);
    IF sort_ord NOT IN ('asc', 'desc') THEN
        sort_ord := 'asc';
    END IF;

    -- Determine cursor comparison operator
    IF sort_ord = 'asc' THEN
        cursor_op := '>';
    ELSE
        cursor_op := '<';
    END IF;
    
    sort_col := lower(sort_column);
    -- Validate sort column  
    IF sort_col IN ('updated_at', 'created_at') THEN
        cursor_expr := format(
            '($5 = '''' OR ROW(date_trunc(''milliseconds'', %I), name COLLATE "C") %s ROW(COALESCE(NULLIF($6, '''')::timestamptz, ''epoch''::timestamptz), $5))',
            sort_col, cursor_op
        );
        sort_expr := format(
            'COALESCE(date_trunc(''milliseconds'', %I), ''epoch''::timestamptz) %s, name COLLATE "C" %s',
            sort_col, sort_ord, sort_ord
        );
    ELSE
        cursor_expr := format('($5 = '''' OR name COLLATE "C" %s $5)', cursor_op);
        sort_expr := format('name COLLATE "C" %s', sort_ord);
    END IF;

    RETURN QUERY EXECUTE format(
        $sql$
        SELECT * FROM (
            (
                SELECT
                    split_part(name, '/', $4) AS key,
                    name,
                    NULL::uuid AS id,
                    updated_at,
                    created_at,
                    NULL::timestamptz AS last_accessed_at,
                    NULL::jsonb AS metadata
                FROM storage.prefixes
                WHERE name COLLATE "C" LIKE $1 || '%%'
                    AND bucket_id = $2
                    AND level = $4
                    AND %s
                ORDER BY %s
                LIMIT $3
            )
            UNION ALL
            (
                SELECT
                    split_part(name, '/', $4) AS key,
                    name,
                    id,
                    updated_at,
                    created_at,
                    last_accessed_at,
                    metadata
                FROM storage.objects
                WHERE name COLLATE "C" LIKE $1 || '%%'
                    AND bucket_id = $2
                    AND level = $4
                    AND %s
                ORDER BY %s
                LIMIT $3
            )
        ) obj
        ORDER BY %s
        LIMIT $3
        $sql$,
        cursor_expr,    -- prefixes WHERE
        sort_expr,      -- prefixes ORDER BY
        cursor_expr,    -- objects WHERE
        sort_expr,      -- objects ORDER BY
        sort_expr       -- final ORDER BY
    )
    USING prefix, bucket_name, limits, levels, start_after, sort_column_after;
END;
$_$;


ALTER FUNCTION storage.search_v2(prefix text, bucket_name text, limits integer, levels integer, start_after text, sort_order text, sort_column text, sort_column_after text) OWNER TO supabase_storage_admin;

--
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW; 
END;
$$;


ALTER FUNCTION storage.update_updated_at_column() OWNER TO supabase_storage_admin;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: audit_log_entries; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.audit_log_entries (
    instance_id uuid,
    id uuid NOT NULL,
    payload json,
    created_at timestamp with time zone,
    ip_address character varying(64) DEFAULT ''::character varying NOT NULL
);


ALTER TABLE auth.audit_log_entries OWNER TO supabase_auth_admin;

--
-- Name: TABLE audit_log_entries; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.audit_log_entries IS 'Auth: Audit trail for user actions.';


--
-- Name: flow_state; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.flow_state (
    id uuid NOT NULL,
    user_id uuid,
    auth_code text NOT NULL,
    code_challenge_method auth.code_challenge_method NOT NULL,
    code_challenge text NOT NULL,
    provider_type text NOT NULL,
    provider_access_token text,
    provider_refresh_token text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    authentication_method text NOT NULL,
    auth_code_issued_at timestamp with time zone
);


ALTER TABLE auth.flow_state OWNER TO supabase_auth_admin;

--
-- Name: TABLE flow_state; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.flow_state IS 'stores metadata for pkce logins';


--
-- Name: identities; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.identities (
    provider_id text NOT NULL,
    user_id uuid NOT NULL,
    identity_data jsonb NOT NULL,
    provider text NOT NULL,
    last_sign_in_at timestamp with time zone,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    email text GENERATED ALWAYS AS (lower((identity_data ->> 'email'::text))) STORED,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


ALTER TABLE auth.identities OWNER TO supabase_auth_admin;

--
-- Name: TABLE identities; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.identities IS 'Auth: Stores identities associated to a user.';


--
-- Name: COLUMN identities.email; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON COLUMN auth.identities.email IS 'Auth: Email is a generated column that references the optional email property in the identity_data';


--
-- Name: instances; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.instances (
    id uuid NOT NULL,
    uuid uuid,
    raw_base_config text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE auth.instances OWNER TO supabase_auth_admin;

--
-- Name: TABLE instances; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.instances IS 'Auth: Manages users across multiple sites.';


--
-- Name: mfa_amr_claims; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.mfa_amr_claims (
    session_id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    authentication_method text NOT NULL,
    id uuid NOT NULL
);


ALTER TABLE auth.mfa_amr_claims OWNER TO supabase_auth_admin;

--
-- Name: TABLE mfa_amr_claims; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.mfa_amr_claims IS 'auth: stores authenticator method reference claims for multi factor authentication';


--
-- Name: mfa_challenges; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.mfa_challenges (
    id uuid NOT NULL,
    factor_id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    verified_at timestamp with time zone,
    ip_address inet NOT NULL,
    otp_code text,
    web_authn_session_data jsonb
);


ALTER TABLE auth.mfa_challenges OWNER TO supabase_auth_admin;

--
-- Name: TABLE mfa_challenges; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.mfa_challenges IS 'auth: stores metadata about challenge requests made';


--
-- Name: mfa_factors; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.mfa_factors (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    friendly_name text,
    factor_type auth.factor_type NOT NULL,
    status auth.factor_status NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    secret text,
    phone text,
    last_challenged_at timestamp with time zone,
    web_authn_credential jsonb,
    web_authn_aaguid uuid,
    last_webauthn_challenge_data jsonb
);


ALTER TABLE auth.mfa_factors OWNER TO supabase_auth_admin;

--
-- Name: TABLE mfa_factors; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.mfa_factors IS 'auth: stores metadata about factors';


--
-- Name: COLUMN mfa_factors.last_webauthn_challenge_data; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON COLUMN auth.mfa_factors.last_webauthn_challenge_data IS 'Stores the latest WebAuthn challenge data including attestation/assertion for customer verification';


--
-- Name: oauth_authorizations; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.oauth_authorizations (
    id uuid NOT NULL,
    authorization_id text NOT NULL,
    client_id uuid NOT NULL,
    user_id uuid,
    redirect_uri text NOT NULL,
    scope text NOT NULL,
    state text,
    resource text,
    code_challenge text,
    code_challenge_method auth.code_challenge_method,
    response_type auth.oauth_response_type DEFAULT 'code'::auth.oauth_response_type NOT NULL,
    status auth.oauth_authorization_status DEFAULT 'pending'::auth.oauth_authorization_status NOT NULL,
    authorization_code text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    expires_at timestamp with time zone DEFAULT (now() + '00:03:00'::interval) NOT NULL,
    approved_at timestamp with time zone,
    nonce text,
    CONSTRAINT oauth_authorizations_authorization_code_length CHECK ((char_length(authorization_code) <= 255)),
    CONSTRAINT oauth_authorizations_code_challenge_length CHECK ((char_length(code_challenge) <= 128)),
    CONSTRAINT oauth_authorizations_expires_at_future CHECK ((expires_at > created_at)),
    CONSTRAINT oauth_authorizations_nonce_length CHECK ((char_length(nonce) <= 255)),
    CONSTRAINT oauth_authorizations_redirect_uri_length CHECK ((char_length(redirect_uri) <= 2048)),
    CONSTRAINT oauth_authorizations_resource_length CHECK ((char_length(resource) <= 2048)),
    CONSTRAINT oauth_authorizations_scope_length CHECK ((char_length(scope) <= 4096)),
    CONSTRAINT oauth_authorizations_state_length CHECK ((char_length(state) <= 4096))
);


ALTER TABLE auth.oauth_authorizations OWNER TO supabase_auth_admin;

--
-- Name: oauth_client_states; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.oauth_client_states (
    id uuid NOT NULL,
    provider_type text NOT NULL,
    code_verifier text,
    created_at timestamp with time zone NOT NULL
);


ALTER TABLE auth.oauth_client_states OWNER TO supabase_auth_admin;

--
-- Name: TABLE oauth_client_states; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.oauth_client_states IS 'Stores OAuth states for third-party provider authentication flows where Supabase acts as the OAuth client.';


--
-- Name: oauth_clients; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.oauth_clients (
    id uuid NOT NULL,
    client_secret_hash text,
    registration_type auth.oauth_registration_type NOT NULL,
    redirect_uris text NOT NULL,
    grant_types text NOT NULL,
    client_name text,
    client_uri text,
    logo_uri text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    client_type auth.oauth_client_type DEFAULT 'confidential'::auth.oauth_client_type NOT NULL,
    CONSTRAINT oauth_clients_client_name_length CHECK ((char_length(client_name) <= 1024)),
    CONSTRAINT oauth_clients_client_uri_length CHECK ((char_length(client_uri) <= 2048)),
    CONSTRAINT oauth_clients_logo_uri_length CHECK ((char_length(logo_uri) <= 2048))
);


ALTER TABLE auth.oauth_clients OWNER TO supabase_auth_admin;

--
-- Name: oauth_consents; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.oauth_consents (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    client_id uuid NOT NULL,
    scopes text NOT NULL,
    granted_at timestamp with time zone DEFAULT now() NOT NULL,
    revoked_at timestamp with time zone,
    CONSTRAINT oauth_consents_revoked_after_granted CHECK (((revoked_at IS NULL) OR (revoked_at >= granted_at))),
    CONSTRAINT oauth_consents_scopes_length CHECK ((char_length(scopes) <= 2048)),
    CONSTRAINT oauth_consents_scopes_not_empty CHECK ((char_length(TRIM(BOTH FROM scopes)) > 0))
);


ALTER TABLE auth.oauth_consents OWNER TO supabase_auth_admin;

--
-- Name: one_time_tokens; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.one_time_tokens (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    token_type auth.one_time_token_type NOT NULL,
    token_hash text NOT NULL,
    relates_to text NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT one_time_tokens_token_hash_check CHECK ((char_length(token_hash) > 0))
);


ALTER TABLE auth.one_time_tokens OWNER TO supabase_auth_admin;

--
-- Name: refresh_tokens; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.refresh_tokens (
    instance_id uuid,
    id bigint NOT NULL,
    token character varying(255),
    user_id character varying(255),
    revoked boolean,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    parent character varying(255),
    session_id uuid
);


ALTER TABLE auth.refresh_tokens OWNER TO supabase_auth_admin;

--
-- Name: TABLE refresh_tokens; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.refresh_tokens IS 'Auth: Store of tokens used to refresh JWT tokens once they expire.';


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE; Schema: auth; Owner: supabase_auth_admin
--

CREATE SEQUENCE auth.refresh_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE auth.refresh_tokens_id_seq OWNER TO supabase_auth_admin;

--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: auth; Owner: supabase_auth_admin
--

ALTER SEQUENCE auth.refresh_tokens_id_seq OWNED BY auth.refresh_tokens.id;


--
-- Name: saml_providers; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.saml_providers (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    entity_id text NOT NULL,
    metadata_xml text NOT NULL,
    metadata_url text,
    attribute_mapping jsonb,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    name_id_format text,
    CONSTRAINT "entity_id not empty" CHECK ((char_length(entity_id) > 0)),
    CONSTRAINT "metadata_url not empty" CHECK (((metadata_url = NULL::text) OR (char_length(metadata_url) > 0))),
    CONSTRAINT "metadata_xml not empty" CHECK ((char_length(metadata_xml) > 0))
);


ALTER TABLE auth.saml_providers OWNER TO supabase_auth_admin;

--
-- Name: TABLE saml_providers; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.saml_providers IS 'Auth: Manages SAML Identity Provider connections.';


--
-- Name: saml_relay_states; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.saml_relay_states (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    request_id text NOT NULL,
    for_email text,
    redirect_to text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    flow_state_id uuid,
    CONSTRAINT "request_id not empty" CHECK ((char_length(request_id) > 0))
);


ALTER TABLE auth.saml_relay_states OWNER TO supabase_auth_admin;

--
-- Name: TABLE saml_relay_states; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.saml_relay_states IS 'Auth: Contains SAML Relay State information for each Service Provider initiated login.';


--
-- Name: schema_migrations; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.schema_migrations (
    version character varying(255) NOT NULL
);


ALTER TABLE auth.schema_migrations OWNER TO supabase_auth_admin;

--
-- Name: TABLE schema_migrations; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.schema_migrations IS 'Auth: Manages updates to the auth system.';


--
-- Name: sessions; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.sessions (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    factor_id uuid,
    aal auth.aal_level,
    not_after timestamp with time zone,
    refreshed_at timestamp without time zone,
    user_agent text,
    ip inet,
    tag text,
    oauth_client_id uuid,
    refresh_token_hmac_key text,
    refresh_token_counter bigint,
    scopes text,
    CONSTRAINT sessions_scopes_length CHECK ((char_length(scopes) <= 4096))
);


ALTER TABLE auth.sessions OWNER TO supabase_auth_admin;

--
-- Name: TABLE sessions; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.sessions IS 'Auth: Stores session data associated to a user.';


--
-- Name: COLUMN sessions.not_after; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON COLUMN auth.sessions.not_after IS 'Auth: Not after is a nullable column that contains a timestamp after which the session should be regarded as expired.';


--
-- Name: COLUMN sessions.refresh_token_hmac_key; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON COLUMN auth.sessions.refresh_token_hmac_key IS 'Holds a HMAC-SHA256 key used to sign refresh tokens for this session.';


--
-- Name: COLUMN sessions.refresh_token_counter; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON COLUMN auth.sessions.refresh_token_counter IS 'Holds the ID (counter) of the last issued refresh token.';


--
-- Name: sso_domains; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.sso_domains (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    domain text NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    CONSTRAINT "domain not empty" CHECK ((char_length(domain) > 0))
);


ALTER TABLE auth.sso_domains OWNER TO supabase_auth_admin;

--
-- Name: TABLE sso_domains; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.sso_domains IS 'Auth: Manages SSO email address domain mapping to an SSO Identity Provider.';


--
-- Name: sso_providers; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.sso_providers (
    id uuid NOT NULL,
    resource_id text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    disabled boolean,
    CONSTRAINT "resource_id not empty" CHECK (((resource_id = NULL::text) OR (char_length(resource_id) > 0)))
);


ALTER TABLE auth.sso_providers OWNER TO supabase_auth_admin;

--
-- Name: TABLE sso_providers; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.sso_providers IS 'Auth: Manages SSO identity provider information; see saml_providers for SAML.';


--
-- Name: COLUMN sso_providers.resource_id; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON COLUMN auth.sso_providers.resource_id IS 'Auth: Uniquely identifies a SSO provider according to a user-chosen resource ID (case insensitive), useful in infrastructure as code.';


--
-- Name: users; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.users (
    instance_id uuid,
    id uuid NOT NULL,
    aud character varying(255),
    role character varying(255),
    email character varying(255),
    encrypted_password character varying(255),
    email_confirmed_at timestamp with time zone,
    invited_at timestamp with time zone,
    confirmation_token character varying(255),
    confirmation_sent_at timestamp with time zone,
    recovery_token character varying(255),
    recovery_sent_at timestamp with time zone,
    email_change_token_new character varying(255),
    email_change character varying(255),
    email_change_sent_at timestamp with time zone,
    last_sign_in_at timestamp with time zone,
    raw_app_meta_data jsonb,
    raw_user_meta_data jsonb,
    is_super_admin boolean,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    phone text DEFAULT NULL::character varying,
    phone_confirmed_at timestamp with time zone,
    phone_change text DEFAULT ''::character varying,
    phone_change_token character varying(255) DEFAULT ''::character varying,
    phone_change_sent_at timestamp with time zone,
    confirmed_at timestamp with time zone GENERATED ALWAYS AS (LEAST(email_confirmed_at, phone_confirmed_at)) STORED,
    email_change_token_current character varying(255) DEFAULT ''::character varying,
    email_change_confirm_status smallint DEFAULT 0,
    banned_until timestamp with time zone,
    reauthentication_token character varying(255) DEFAULT ''::character varying,
    reauthentication_sent_at timestamp with time zone,
    is_sso_user boolean DEFAULT false NOT NULL,
    deleted_at timestamp with time zone,
    is_anonymous boolean DEFAULT false NOT NULL,
    CONSTRAINT users_email_change_confirm_status_check CHECK (((email_change_confirm_status >= 0) AND (email_change_confirm_status <= 2)))
);


ALTER TABLE auth.users OWNER TO supabase_auth_admin;

--
-- Name: TABLE users; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.users IS 'Auth: Stores user login data within a secure schema.';


--
-- Name: COLUMN users.is_sso_user; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON COLUMN auth.users.is_sso_user IS 'Auth: Set this column to true when the account comes from SSO. These accounts can have duplicate emails.';


--
-- Name: admin_users; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE public.admin_users OWNER TO postgres;

--
-- Name: announcement_config; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.announcement_config (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    config_key text NOT NULL,
    config_value jsonb NOT NULL,
    description text,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_by text
);


ALTER TABLE public.announcement_config OWNER TO postgres;

--
-- Name: announcement_impressions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.announcement_impressions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    announcement_id uuid,
    user_id uuid,
    impressions integer DEFAULT 0 NOT NULL,
    last_seen_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.announcement_impressions OWNER TO postgres;

--
-- Name: announcement_responses; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE public.announcement_responses OWNER TO postgres;

--
-- Name: COLUMN announcement_responses.first_option_value; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.announcement_responses.first_option_value IS 'User''s first answer for option-based questions (never changes after initial save)';


--
-- Name: COLUMN announcement_responses.first_text_value; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.announcement_responses.first_text_value IS 'User''s first answer for text-based questions (never changes after initial save)';


--
-- Name: COLUMN announcement_responses.first_numeric_value; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.announcement_responses.first_numeric_value IS 'User''s first answer for numeric questions (never changes after initial save)';


--
-- Name: COLUMN announcement_responses.first_answered_at; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.announcement_responses.first_answered_at IS 'Timestamp when user first answered this question';


--
-- Name: announcements; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE public.announcements OWNER TO postgres;

--
-- Name: COLUMN announcements.kind; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.announcements.kind IS 'Type of announcement: 
- announcement: Simple notification/message
- survey: Questions without correct answers, collects anonymous feedback
- quiz: Questions WITH correct answers, shows right/wrong feedback
- user_insights: Questions linked to user profile (profession, specialty, etc.)';


--
-- Name: COLUMN announcements.disappear_after_cta; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.announcements.disappear_after_cta IS 'Whether announcement disappears after user clicks CTA button. Default TRUE.';


--
-- Name: COLUMN announcements.repeat_session_interval; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.announcements.repeat_session_interval IS 'Session interval for per_app_open repeat mode. Show announcement every X sessions. Default 1.';


--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: announcement_targeting_stats; Type: VIEW; Schema: public; Owner: postgres
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


ALTER VIEW public.announcement_targeting_stats OWNER TO postgres;

--
-- Name: app_sessions; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE public.app_sessions OWNER TO postgres;

--
-- Name: app_settings; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE public.app_settings OWNER TO postgres;

--
-- Name: category_settings; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE public.category_settings OWNER TO postgres;

--
-- Name: credit_asset_types; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE public.credit_asset_types OWNER TO postgres;

--
-- Name: credit_links; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE public.credit_links OWNER TO postgres;

--
-- Name: credit_sites; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE public.credit_sites OWNER TO postgres;

--
-- Name: credits_overview; Type: VIEW; Schema: public; Owner: postgres
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


ALTER VIEW public.credits_overview OWNER TO postgres;

--
-- Name: dashboard_announcements; Type: VIEW; Schema: public; Owner: postgres
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


ALTER VIEW public.dashboard_announcements OWNER TO postgres;

--
-- Name: feedbacks; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE public.feedbacks OWNER TO postgres;

--
-- Name: dashboard_feedbacks; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.dashboard_feedbacks WITH (security_invoker='true') AS
 SELECT id,
    message,
    tool_id AS tool_slug,
    type AS feedback_type,
    conclusion_data AS conclusion,
    submitted_at AS created_at
   FROM public.feedbacks;


ALTER VIEW public.dashboard_feedbacks OWNER TO postgres;

--
-- Name: screen_settings; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE public.screen_settings OWNER TO postgres;

--
-- Name: section_settings; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE public.section_settings OWNER TO postgres;

--
-- Name: tool_settings; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE public.tool_settings OWNER TO postgres;

--
-- Name: tool_usage_events; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE public.tool_usage_events OWNER TO postgres;

--
-- Name: tool_usage_events_enriched; Type: VIEW; Schema: public; Owner: postgres
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


ALTER VIEW public.tool_usage_events_enriched OWNER TO postgres;

--
-- Name: tool_usage_summary; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE public.tool_usage_summary OWNER TO postgres;

--
-- Name: user_announcement_state; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE public.user_announcement_state OWNER TO postgres;

--
-- Name: user_sync_states; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE public.user_sync_states OWNER TO postgres;

--
-- Name: user_usage_summary; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE public.user_usage_summary OWNER TO postgres;

--
-- Name: messages; Type: TABLE; Schema: realtime; Owner: supabase_realtime_admin
--

CREATE TABLE realtime.messages (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL
)
PARTITION BY RANGE (inserted_at);


ALTER TABLE realtime.messages OWNER TO supabase_realtime_admin;

--
-- Name: schema_migrations; Type: TABLE; Schema: realtime; Owner: supabase_admin
--

CREATE TABLE realtime.schema_migrations (
    version bigint NOT NULL,
    inserted_at timestamp(0) without time zone
);


ALTER TABLE realtime.schema_migrations OWNER TO supabase_admin;

--
-- Name: subscription; Type: TABLE; Schema: realtime; Owner: supabase_admin
--

CREATE TABLE realtime.subscription (
    id bigint NOT NULL,
    subscription_id uuid NOT NULL,
    entity regclass NOT NULL,
    filters realtime.user_defined_filter[] DEFAULT '{}'::realtime.user_defined_filter[] NOT NULL,
    claims jsonb NOT NULL,
    claims_role regrole GENERATED ALWAYS AS (realtime.to_regrole((claims ->> 'role'::text))) STORED NOT NULL,
    created_at timestamp without time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);


ALTER TABLE realtime.subscription OWNER TO supabase_admin;

--
-- Name: subscription_id_seq; Type: SEQUENCE; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE realtime.subscription ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME realtime.subscription_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: buckets; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.buckets (
    id text NOT NULL,
    name text NOT NULL,
    owner uuid,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    public boolean DEFAULT false,
    avif_autodetection boolean DEFAULT false,
    file_size_limit bigint,
    allowed_mime_types text[],
    owner_id text,
    type storage.buckettype DEFAULT 'STANDARD'::storage.buckettype NOT NULL
);


ALTER TABLE storage.buckets OWNER TO supabase_storage_admin;

--
-- Name: COLUMN buckets.owner; Type: COMMENT; Schema: storage; Owner: supabase_storage_admin
--

COMMENT ON COLUMN storage.buckets.owner IS 'Field is deprecated, use owner_id instead';


--
-- Name: buckets_analytics; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.buckets_analytics (
    name text NOT NULL,
    type storage.buckettype DEFAULT 'ANALYTICS'::storage.buckettype NOT NULL,
    format text DEFAULT 'ICEBERG'::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE storage.buckets_analytics OWNER TO supabase_storage_admin;

--
-- Name: buckets_vectors; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.buckets_vectors (
    id text NOT NULL,
    type storage.buckettype DEFAULT 'VECTOR'::storage.buckettype NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE storage.buckets_vectors OWNER TO supabase_storage_admin;

--
-- Name: migrations; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.migrations (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    hash character varying(40) NOT NULL,
    executed_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE storage.migrations OWNER TO supabase_storage_admin;

--
-- Name: objects; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.objects (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    bucket_id text,
    name text,
    owner uuid,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    last_accessed_at timestamp with time zone DEFAULT now(),
    metadata jsonb,
    path_tokens text[] GENERATED ALWAYS AS (string_to_array(name, '/'::text)) STORED,
    version text,
    owner_id text,
    user_metadata jsonb,
    level integer
);


ALTER TABLE storage.objects OWNER TO supabase_storage_admin;

--
-- Name: COLUMN objects.owner; Type: COMMENT; Schema: storage; Owner: supabase_storage_admin
--

COMMENT ON COLUMN storage.objects.owner IS 'Field is deprecated, use owner_id instead';


--
-- Name: prefixes; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.prefixes (
    bucket_id text NOT NULL,
    name text NOT NULL COLLATE pg_catalog."C",
    level integer GENERATED ALWAYS AS (storage.get_level(name)) STORED NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE storage.prefixes OWNER TO supabase_storage_admin;

--
-- Name: s3_multipart_uploads; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.s3_multipart_uploads (
    id text NOT NULL,
    in_progress_size bigint DEFAULT 0 NOT NULL,
    upload_signature text NOT NULL,
    bucket_id text NOT NULL,
    key text NOT NULL COLLATE pg_catalog."C",
    version text NOT NULL,
    owner_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    user_metadata jsonb
);


ALTER TABLE storage.s3_multipart_uploads OWNER TO supabase_storage_admin;

--
-- Name: s3_multipart_uploads_parts; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.s3_multipart_uploads_parts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    upload_id text NOT NULL,
    size bigint DEFAULT 0 NOT NULL,
    part_number integer NOT NULL,
    bucket_id text NOT NULL,
    key text NOT NULL COLLATE pg_catalog."C",
    etag text NOT NULL,
    owner_id text,
    version text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE storage.s3_multipart_uploads_parts OWNER TO supabase_storage_admin;

--
-- Name: vector_indexes; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.vector_indexes (
    id text DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL COLLATE pg_catalog."C",
    bucket_id text NOT NULL,
    data_type text NOT NULL,
    dimension integer NOT NULL,
    distance_metric text NOT NULL,
    metadata_configuration jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE storage.vector_indexes OWNER TO supabase_storage_admin;

--
-- Name: refresh_tokens id; Type: DEFAULT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.refresh_tokens ALTER COLUMN id SET DEFAULT nextval('auth.refresh_tokens_id_seq'::regclass);


--
-- Data for Name: audit_log_entries; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.audit_log_entries (instance_id, id, payload, created_at, ip_address) FROM stdin;
00000000-0000-0000-0000-000000000000	77eaadab-5ec2-4e02-bebf-de4186d9b849	{"action":"user_signedup","actor_id":"74a2ee9e-fe11-45d6-b4ef-0a668f9f6455","actor_name":"OcuHub Admin","actor_username":"admin@ocuhub.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"google"}}	2025-12-06 20:06:52.987302+00	
00000000-0000-0000-0000-000000000000	01c50fa2-ec84-48a6-8697-9d011b3b50ea	{"action":"login","actor_id":"74a2ee9e-fe11-45d6-b4ef-0a668f9f6455","actor_name":"OcuHub Admin","actor_username":"admin@ocuhub.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-12-06 20:07:22.780791+00	
00000000-0000-0000-0000-000000000000	71f33c64-5eba-4a79-989f-5e97dab4bb00	{"action":"login","actor_id":"74a2ee9e-fe11-45d6-b4ef-0a668f9f6455","actor_name":"OcuHub Admin","actor_username":"admin@ocuhub.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-12-06 20:10:17.193959+00	
00000000-0000-0000-0000-000000000000	11669a94-cfb0-4a5e-88e0-9c57a7d754eb	{"action":"login","actor_id":"74a2ee9e-fe11-45d6-b4ef-0a668f9f6455","actor_name":"OcuHub Admin","actor_username":"admin@ocuhub.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-12-06 20:10:27.25863+00	
00000000-0000-0000-0000-000000000000	757c7159-7e76-4032-8b44-237a079964f5	{"action":"login","actor_id":"74a2ee9e-fe11-45d6-b4ef-0a668f9f6455","actor_name":"OcuHub Admin","actor_username":"admin@ocuhub.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-12-06 20:10:56.376766+00	
00000000-0000-0000-0000-000000000000	560ca88d-2673-46d8-9008-e408fced1c55	{"action":"login","actor_id":"74a2ee9e-fe11-45d6-b4ef-0a668f9f6455","actor_name":"OcuHub Admin","actor_username":"admin@ocuhub.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-12-06 20:30:52.240712+00	
00000000-0000-0000-0000-000000000000	27b64451-d501-4da9-af1a-1cdacdc7a2b3	{"action":"login","actor_id":"74a2ee9e-fe11-45d6-b4ef-0a668f9f6455","actor_name":"OcuHub Admin","actor_username":"admin@ocuhub.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-12-06 21:01:35.768485+00	
00000000-0000-0000-0000-000000000000	c8989a08-5a59-4481-937c-639534397e40	{"action":"login","actor_id":"74a2ee9e-fe11-45d6-b4ef-0a668f9f6455","actor_name":"OcuHub Admin","actor_username":"admin@ocuhub.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-12-06 21:03:05.241699+00	
00000000-0000-0000-0000-000000000000	f603eac8-a2e4-4d4c-b5bd-395e1cd2e4b6	{"action":"login","actor_id":"74a2ee9e-fe11-45d6-b4ef-0a668f9f6455","actor_name":"OcuHub Admin","actor_username":"admin@ocuhub.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-12-06 21:56:14.586014+00	
00000000-0000-0000-0000-000000000000	44770abc-94cd-4364-9f8b-d9d36814f6ff	{"action":"login","actor_id":"74a2ee9e-fe11-45d6-b4ef-0a668f9f6455","actor_name":"OcuHub Admin","actor_username":"admin@ocuhub.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-12-06 22:24:09.209688+00	
00000000-0000-0000-0000-000000000000	62d76466-eabc-4ffc-892e-56df6afa5fce	{"action":"user_signedup","actor_id":"60ad28a7-2abf-432e-87ed-dedd4b0d432e","actor_name":"Ehab Sultan","actor_username":"egyeast@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"google"}}	2025-12-06 22:36:56.17274+00	
00000000-0000-0000-0000-000000000000	3b7df79c-073b-43e4-bc74-c3055124484d	{"action":"login","actor_id":"74a2ee9e-fe11-45d6-b4ef-0a668f9f6455","actor_name":"OcuHub Admin","actor_username":"admin@ocuhub.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-12-06 22:37:06.494883+00	
00000000-0000-0000-0000-000000000000	d8735868-c8ab-4455-932c-2aafc940f7bb	{"action":"login","actor_id":"74a2ee9e-fe11-45d6-b4ef-0a668f9f6455","actor_name":"OcuHub Admin","actor_username":"admin@ocuhub.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-12-06 22:37:15.839895+00	
00000000-0000-0000-0000-000000000000	a349a484-7247-42ad-a4da-93296c35fa53	{"action":"login","actor_id":"74a2ee9e-fe11-45d6-b4ef-0a668f9f6455","actor_name":"OcuHub Admin","actor_username":"admin@ocuhub.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-12-06 22:40:20.823184+00	
00000000-0000-0000-0000-000000000000	6eba8057-59d7-4db9-a43b-6fc99349f72e	{"action":"login","actor_id":"74a2ee9e-fe11-45d6-b4ef-0a668f9f6455","actor_name":"OcuHub Admin","actor_username":"admin@ocuhub.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-12-06 22:42:41.538041+00	
00000000-0000-0000-0000-000000000000	d088234c-18ae-4569-958d-288afa7855e6	{"action":"login","actor_id":"74a2ee9e-fe11-45d6-b4ef-0a668f9f6455","actor_name":"OcuHub Admin","actor_username":"admin@ocuhub.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-12-06 23:02:10.31768+00	
00000000-0000-0000-0000-000000000000	e5f0a472-cdb4-47f6-855c-b50129c0ee3f	{"action":"login","actor_id":"74a2ee9e-fe11-45d6-b4ef-0a668f9f6455","actor_name":"OcuHub Admin","actor_username":"admin@ocuhub.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-12-06 23:02:44.686191+00	
00000000-0000-0000-0000-000000000000	ca407c1f-22b2-417f-8ce2-fcaea92e059b	{"action":"login","actor_id":"74a2ee9e-fe11-45d6-b4ef-0a668f9f6455","actor_name":"OcuHub Admin","actor_username":"admin@ocuhub.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-12-06 23:02:52.643674+00	
00000000-0000-0000-0000-000000000000	770b4d71-c89a-435f-89c2-03e990270be9	{"action":"login","actor_id":"74a2ee9e-fe11-45d6-b4ef-0a668f9f6455","actor_name":"OcuHub Admin","actor_username":"admin@ocuhub.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-12-06 23:02:57.441823+00	
00000000-0000-0000-0000-000000000000	68009084-44dc-4046-a008-ce685d0240ad	{"action":"login","actor_id":"74a2ee9e-fe11-45d6-b4ef-0a668f9f6455","actor_name":"OcuHub Admin","actor_username":"admin@ocuhub.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-12-06 23:03:02.39622+00	
00000000-0000-0000-0000-000000000000	bee87a41-6991-495f-b0b4-971e7e9f2cd2	{"action":"login","actor_id":"74a2ee9e-fe11-45d6-b4ef-0a668f9f6455","actor_name":"OcuHub Admin","actor_username":"admin@ocuhub.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-12-06 23:04:55.406043+00	
00000000-0000-0000-0000-000000000000	8484e7de-2dd2-4a0d-bab4-d4dbb86dd969	{"action":"login","actor_id":"74a2ee9e-fe11-45d6-b4ef-0a668f9f6455","actor_name":"OcuHub Admin","actor_username":"admin@ocuhub.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-12-06 23:05:17.561361+00	
00000000-0000-0000-0000-000000000000	e1448d3c-e3ad-45a1-854f-7fd616fbc6ac	{"action":"login","actor_id":"74a2ee9e-fe11-45d6-b4ef-0a668f9f6455","actor_name":"OcuHub Admin","actor_username":"admin@ocuhub.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-12-06 23:05:47.296868+00	
00000000-0000-0000-0000-000000000000	20917ade-8e85-440c-9fa8-b5dac534caae	{"action":"login","actor_id":"74a2ee9e-fe11-45d6-b4ef-0a668f9f6455","actor_name":"OcuHub Admin","actor_username":"admin@ocuhub.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-12-06 23:08:50.467801+00	
00000000-0000-0000-0000-000000000000	385fddbf-61ba-4815-82fc-0977b5035df6	{"action":"login","actor_id":"74a2ee9e-fe11-45d6-b4ef-0a668f9f6455","actor_name":"OcuHub Admin","actor_username":"admin@ocuhub.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-12-06 23:24:57.703211+00	
00000000-0000-0000-0000-000000000000	81ed3ae1-bd5b-42e6-bf8e-2506b6c082f5	{"action":"login","actor_id":"74a2ee9e-fe11-45d6-b4ef-0a668f9f6455","actor_name":"OcuHub Admin","actor_username":"admin@ocuhub.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-12-06 23:25:18.624092+00	
00000000-0000-0000-0000-000000000000	de67c777-965a-405e-889f-dc8e861a4a15	{"action":"login","actor_id":"74a2ee9e-fe11-45d6-b4ef-0a668f9f6455","actor_name":"OcuHub Admin","actor_username":"admin@ocuhub.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-12-06 23:25:23.432898+00	
00000000-0000-0000-0000-000000000000	feb93d9f-0358-4cad-9a26-6c342e95b2a5	{"action":"login","actor_id":"74a2ee9e-fe11-45d6-b4ef-0a668f9f6455","actor_name":"OcuHub Admin","actor_username":"admin@ocuhub.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-12-06 23:25:46.641822+00	
00000000-0000-0000-0000-000000000000	59a509d7-4e68-4b99-8462-25ec6fc67992	{"action":"login","actor_id":"74a2ee9e-fe11-45d6-b4ef-0a668f9f6455","actor_name":"OcuHub Admin","actor_username":"admin@ocuhub.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-12-06 23:25:51.481805+00	
00000000-0000-0000-0000-000000000000	81ff9f33-2c4d-4b45-bd92-bc4ea667895e	{"action":"login","actor_id":"74a2ee9e-fe11-45d6-b4ef-0a668f9f6455","actor_name":"OcuHub Admin","actor_username":"admin@ocuhub.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-12-06 23:26:07.520957+00	
00000000-0000-0000-0000-000000000000	4f0edebf-4310-40b3-996c-aa7df862ebc4	{"action":"user_recovery_requested","actor_id":"74a2ee9e-fe11-45d6-b4ef-0a668f9f6455","actor_name":"OcuHub Admin","actor_username":"admin@ocuhub.com","actor_via_sso":false,"log_type":"user"}	2025-12-06 23:29:08.263234+00	
00000000-0000-0000-0000-000000000000	7ca0432c-f594-46c4-b6e7-244630fea203	{"action":"login","actor_id":"74a2ee9e-fe11-45d6-b4ef-0a668f9f6455","actor_name":"OcuHub Admin","actor_username":"admin@ocuhub.com","actor_via_sso":false,"log_type":"account"}	2025-12-06 23:29:51.030289+00	
00000000-0000-0000-0000-000000000000	732c39a5-7b94-480b-b5f6-bfb939c59a88	{"action":"login","actor_id":"74a2ee9e-fe11-45d6-b4ef-0a668f9f6455","actor_name":"OcuHub Admin","actor_username":"admin@ocuhub.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-12-07 00:14:20.958712+00	
00000000-0000-0000-0000-000000000000	1a8de000-bb06-4898-b281-e2659cab75a5	{"action":"login","actor_id":"74a2ee9e-fe11-45d6-b4ef-0a668f9f6455","actor_name":"OcuHub Admin","actor_username":"admin@ocuhub.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-12-07 00:14:28.517543+00	
00000000-0000-0000-0000-000000000000	2280dbab-d7c7-49ed-bb79-89966c108a1f	{"action":"login","actor_id":"74a2ee9e-fe11-45d6-b4ef-0a668f9f6455","actor_name":"OcuHub Admin","actor_username":"admin@ocuhub.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-12-07 00:14:30.880603+00	
00000000-0000-0000-0000-000000000000	a91bf958-f1c7-443f-8311-ab4423905e8f	{"action":"login","actor_id":"74a2ee9e-fe11-45d6-b4ef-0a668f9f6455","actor_name":"OcuHub Admin","actor_username":"admin@ocuhub.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-12-07 00:15:02.148503+00	
00000000-0000-0000-0000-000000000000	3676dd66-32ba-43db-8f29-4fac55e87fdd	{"action":"login","actor_id":"74a2ee9e-fe11-45d6-b4ef-0a668f9f6455","actor_name":"OcuHub Admin","actor_username":"admin@ocuhub.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-12-07 00:17:32.919802+00	
00000000-0000-0000-0000-000000000000	7d99bf01-b997-4f41-9b5d-23e632896c4b	{"action":"login","actor_id":"74a2ee9e-fe11-45d6-b4ef-0a668f9f6455","actor_name":"OcuHub Admin","actor_username":"admin@ocuhub.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-12-07 00:18:16.736913+00	
00000000-0000-0000-0000-000000000000	afbe2135-27ee-46ca-b5f2-74543a6131b0	{"action":"login","actor_id":"60ad28a7-2abf-432e-87ed-dedd4b0d432e","actor_name":"Ehab Sultan","actor_username":"egyeast@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-12-07 00:18:50.286769+00	
00000000-0000-0000-0000-000000000000	8b1212ce-975a-4bff-b6f5-830806bca40b	{"action":"logout","actor_id":"60ad28a7-2abf-432e-87ed-dedd4b0d432e","actor_name":"Ehab Sultan","actor_username":"egyeast@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-12-07 00:18:51.897073+00	
00000000-0000-0000-0000-000000000000	c7b699ff-99be-409a-a8a4-510f0d705533	{"action":"login","actor_id":"60ad28a7-2abf-432e-87ed-dedd4b0d432e","actor_name":"Ehab Sultan","actor_username":"egyeast@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-12-07 00:18:57.454+00	
00000000-0000-0000-0000-000000000000	7e058b24-86ea-428f-9703-44a41227e2dd	{"action":"logout","actor_id":"60ad28a7-2abf-432e-87ed-dedd4b0d432e","actor_name":"Ehab Sultan","actor_username":"egyeast@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-12-07 00:18:58.978782+00	
00000000-0000-0000-0000-000000000000	31e5594b-c78c-46d5-a79f-d81cdc5b6601	{"action":"login","actor_id":"74a2ee9e-fe11-45d6-b4ef-0a668f9f6455","actor_name":"OcuHub Admin","actor_username":"admin@ocuhub.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-12-07 00:19:28.691888+00	
00000000-0000-0000-0000-000000000000	0a8a1def-7d7a-4fd3-bd7b-60994586b8ff	{"action":"token_refreshed","actor_id":"74a2ee9e-fe11-45d6-b4ef-0a668f9f6455","actor_name":"OcuHub Admin","actor_username":"admin@ocuhub.com","actor_via_sso":false,"log_type":"token"}	2025-12-07 00:27:32.646229+00	
00000000-0000-0000-0000-000000000000	22957fb9-31d1-4446-a47c-49d8701e3ac8	{"action":"token_revoked","actor_id":"74a2ee9e-fe11-45d6-b4ef-0a668f9f6455","actor_name":"OcuHub Admin","actor_username":"admin@ocuhub.com","actor_via_sso":false,"log_type":"token"}	2025-12-07 00:27:32.655594+00	
00000000-0000-0000-0000-000000000000	936d9cb7-e59b-4548-9ca7-724a4afc4677	{"action":"login","actor_id":"74a2ee9e-fe11-45d6-b4ef-0a668f9f6455","actor_name":"OcuHub Admin","actor_username":"admin@ocuhub.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-12-07 00:27:38.429989+00	
00000000-0000-0000-0000-000000000000	54a90d04-3d1b-4fd0-81c9-4415987fc3fe	{"action":"token_refreshed","actor_id":"74a2ee9e-fe11-45d6-b4ef-0a668f9f6455","actor_name":"OcuHub Admin","actor_username":"admin@ocuhub.com","actor_via_sso":false,"log_type":"token"}	2025-12-07 07:33:59.542215+00	
00000000-0000-0000-0000-000000000000	ecd409bf-8cb5-4bdf-a29c-246cb3a29a2f	{"action":"token_revoked","actor_id":"74a2ee9e-fe11-45d6-b4ef-0a668f9f6455","actor_name":"OcuHub Admin","actor_username":"admin@ocuhub.com","actor_via_sso":false,"log_type":"token"}	2025-12-07 07:33:59.570068+00	
00000000-0000-0000-0000-000000000000	ebc149c7-802e-46af-afc5-15cd46c084de	{"action":"token_refreshed","actor_id":"74a2ee9e-fe11-45d6-b4ef-0a668f9f6455","actor_name":"OcuHub Admin","actor_username":"admin@ocuhub.com","actor_via_sso":false,"log_type":"token"}	2025-12-07 12:30:34.92539+00	
00000000-0000-0000-0000-000000000000	df1b92d7-5956-4832-a9fb-dcf49acf9de5	{"action":"token_revoked","actor_id":"74a2ee9e-fe11-45d6-b4ef-0a668f9f6455","actor_name":"OcuHub Admin","actor_username":"admin@ocuhub.com","actor_via_sso":false,"log_type":"token"}	2025-12-07 12:30:34.947393+00	
00000000-0000-0000-0000-000000000000	e6b1ab59-ab35-4940-9b82-8b52f30e0b1a	{"action":"login","actor_id":"74a2ee9e-fe11-45d6-b4ef-0a668f9f6455","actor_name":"OcuHub Admin","actor_username":"admin@ocuhub.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-12-07 12:30:41.872494+00	
00000000-0000-0000-0000-000000000000	a939809e-fdfa-465e-813a-dcfc9681c912	{"action":"token_refreshed","actor_id":"74a2ee9e-fe11-45d6-b4ef-0a668f9f6455","actor_name":"OcuHub Admin","actor_username":"admin@ocuhub.com","actor_via_sso":false,"log_type":"token"}	2025-12-08 08:03:30.435762+00	
00000000-0000-0000-0000-000000000000	486201e4-99c9-4417-8057-308f1a96e5c3	{"action":"token_revoked","actor_id":"74a2ee9e-fe11-45d6-b4ef-0a668f9f6455","actor_name":"OcuHub Admin","actor_username":"admin@ocuhub.com","actor_via_sso":false,"log_type":"token"}	2025-12-08 08:03:30.460211+00	
00000000-0000-0000-0000-000000000000	4ebbec8c-0376-43e1-933e-b47d4329a2fa	{"action":"token_refreshed","actor_id":"74a2ee9e-fe11-45d6-b4ef-0a668f9f6455","actor_name":"OcuHub Admin","actor_username":"admin@ocuhub.com","actor_via_sso":false,"log_type":"token"}	2025-12-08 08:03:30.754419+00	
00000000-0000-0000-0000-000000000000	0313bd58-8f74-478d-9adb-b5e98ca3b821	{"action":"login","actor_id":"74a2ee9e-fe11-45d6-b4ef-0a668f9f6455","actor_name":"OcuHub Admin","actor_username":"admin@ocuhub.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-12-08 08:03:46.902827+00	
00000000-0000-0000-0000-000000000000	0d7a335c-35cb-4d28-acd2-9bd8001cd4ad	{"action":"token_refreshed","actor_id":"74a2ee9e-fe11-45d6-b4ef-0a668f9f6455","actor_name":"OcuHub Admin","actor_username":"admin@ocuhub.com","actor_via_sso":false,"log_type":"token"}	2025-12-08 21:40:45.617267+00	
00000000-0000-0000-0000-000000000000	6da1580a-180d-44da-8d1f-9e59e06bc533	{"action":"token_revoked","actor_id":"74a2ee9e-fe11-45d6-b4ef-0a668f9f6455","actor_name":"OcuHub Admin","actor_username":"admin@ocuhub.com","actor_via_sso":false,"log_type":"token"}	2025-12-08 21:40:45.636149+00	
00000000-0000-0000-0000-000000000000	1abb1ffc-f551-4be0-ad56-980dfff0ec9b	{"action":"token_refreshed","actor_id":"74a2ee9e-fe11-45d6-b4ef-0a668f9f6455","actor_name":"OcuHub Admin","actor_username":"admin@ocuhub.com","actor_via_sso":false,"log_type":"token"}	2025-12-09 12:02:41.665474+00	
00000000-0000-0000-0000-000000000000	707a977e-7eb1-4e4a-972d-e9b3df519029	{"action":"token_revoked","actor_id":"74a2ee9e-fe11-45d6-b4ef-0a668f9f6455","actor_name":"OcuHub Admin","actor_username":"admin@ocuhub.com","actor_via_sso":false,"log_type":"token"}	2025-12-09 12:02:41.698795+00	
00000000-0000-0000-0000-000000000000	798ea9d2-581e-41f8-ba35-1cf266a2388e	{"action":"token_refreshed","actor_id":"74a2ee9e-fe11-45d6-b4ef-0a668f9f6455","actor_name":"OcuHub Admin","actor_username":"admin@ocuhub.com","actor_via_sso":false,"log_type":"token"}	2025-12-10 12:23:12.324923+00	
00000000-0000-0000-0000-000000000000	e8695a29-76f1-43f9-9b9d-9bf54695cb9f	{"action":"token_revoked","actor_id":"74a2ee9e-fe11-45d6-b4ef-0a668f9f6455","actor_name":"OcuHub Admin","actor_username":"admin@ocuhub.com","actor_via_sso":false,"log_type":"token"}	2025-12-10 12:23:12.355846+00	
00000000-0000-0000-0000-000000000000	9e9821f8-0a9e-41dd-96dc-f2775106a78b	{"action":"token_refreshed","actor_id":"74a2ee9e-fe11-45d6-b4ef-0a668f9f6455","actor_name":"OcuHub Admin","actor_username":"admin@ocuhub.com","actor_via_sso":false,"log_type":"token"}	2025-12-10 13:21:38.625152+00	
00000000-0000-0000-0000-000000000000	1bdcfaf4-1889-4dd7-b2b8-671b76719651	{"action":"token_revoked","actor_id":"74a2ee9e-fe11-45d6-b4ef-0a668f9f6455","actor_name":"OcuHub Admin","actor_username":"admin@ocuhub.com","actor_via_sso":false,"log_type":"token"}	2025-12-10 13:21:38.648613+00	
00000000-0000-0000-0000-000000000000	88213d8c-dc33-448f-a38a-9bf261726d66	{"action":"token_refreshed","actor_id":"74a2ee9e-fe11-45d6-b4ef-0a668f9f6455","actor_name":"OcuHub Admin","actor_username":"admin@ocuhub.com","actor_via_sso":false,"log_type":"token"}	2025-12-10 16:05:41.388572+00	
00000000-0000-0000-0000-000000000000	b5f9c075-c17b-4ede-aab9-01973ab6837c	{"action":"token_revoked","actor_id":"74a2ee9e-fe11-45d6-b4ef-0a668f9f6455","actor_name":"OcuHub Admin","actor_username":"admin@ocuhub.com","actor_via_sso":false,"log_type":"token"}	2025-12-10 16:05:41.412697+00	
00000000-0000-0000-0000-000000000000	28b45348-ba1b-4f09-9e03-9c799c729312	{"action":"token_refreshed","actor_id":"74a2ee9e-fe11-45d6-b4ef-0a668f9f6455","actor_name":"OcuHub Admin","actor_username":"admin@ocuhub.com","actor_via_sso":false,"log_type":"token"}	2025-12-10 17:29:08.283517+00	
00000000-0000-0000-0000-000000000000	87ce6ab8-b179-4ae3-8112-905422960519	{"action":"token_revoked","actor_id":"74a2ee9e-fe11-45d6-b4ef-0a668f9f6455","actor_name":"OcuHub Admin","actor_username":"admin@ocuhub.com","actor_via_sso":false,"log_type":"token"}	2025-12-10 17:29:08.307987+00	
00000000-0000-0000-0000-000000000000	f54d3edd-646e-4713-9cc7-391bba33be40	{"action":"token_refreshed","actor_id":"74a2ee9e-fe11-45d6-b4ef-0a668f9f6455","actor_name":"OcuHub Admin","actor_username":"admin@ocuhub.com","actor_via_sso":false,"log_type":"token"}	2025-12-10 20:07:52.377055+00	
00000000-0000-0000-0000-000000000000	8403736c-fdca-4b93-b291-2690e90d7de2	{"action":"token_revoked","actor_id":"74a2ee9e-fe11-45d6-b4ef-0a668f9f6455","actor_name":"OcuHub Admin","actor_username":"admin@ocuhub.com","actor_via_sso":false,"log_type":"token"}	2025-12-10 20:07:52.398392+00	
00000000-0000-0000-0000-000000000000	f05e4131-7754-4024-823c-1e0fb46a8fc9	{"action":"token_refreshed","actor_id":"74a2ee9e-fe11-45d6-b4ef-0a668f9f6455","actor_name":"OcuHub Admin","actor_username":"admin@ocuhub.com","actor_via_sso":false,"log_type":"token"}	2025-12-11 12:48:32.753037+00	
00000000-0000-0000-0000-000000000000	101c497a-5fa0-4a0f-956b-357b65a5f305	{"action":"token_revoked","actor_id":"74a2ee9e-fe11-45d6-b4ef-0a668f9f6455","actor_name":"OcuHub Admin","actor_username":"admin@ocuhub.com","actor_via_sso":false,"log_type":"token"}	2025-12-11 12:48:32.769326+00	
00000000-0000-0000-0000-000000000000	3b7dedf9-5369-40ad-96c1-f91e81a5c428	{"action":"login","actor_id":"74a2ee9e-fe11-45d6-b4ef-0a668f9f6455","actor_name":"OcuHub Admin","actor_username":"admin@ocuhub.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-12-11 12:48:42.339038+00	
00000000-0000-0000-0000-000000000000	7a05bee2-a7df-419a-8b63-c3671288ff37	{"action":"login","actor_id":"74a2ee9e-fe11-45d6-b4ef-0a668f9f6455","actor_name":"OcuHub Admin","actor_username":"admin@ocuhub.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-12-11 12:48:50.556568+00	
00000000-0000-0000-0000-000000000000	105f6030-0d2e-463c-a773-fe009e0d6e6d	{"action":"login","actor_id":"74a2ee9e-fe11-45d6-b4ef-0a668f9f6455","actor_name":"OcuHub Admin","actor_username":"admin@ocuhub.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-12-12 08:32:33.616772+00	
00000000-0000-0000-0000-000000000000	3269decc-29d0-4ee7-8038-bdf7a6fecf6d	{"action":"login","actor_id":"74a2ee9e-fe11-45d6-b4ef-0a668f9f6455","actor_name":"OcuHub Admin","actor_username":"admin@ocuhub.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-12-12 08:32:41.811739+00	
00000000-0000-0000-0000-000000000000	bf9f6347-1203-4bcb-87b9-e2ce6703be87	{"action":"token_refreshed","actor_id":"74a2ee9e-fe11-45d6-b4ef-0a668f9f6455","actor_name":"OcuHub Admin","actor_username":"admin@ocuhub.com","actor_via_sso":false,"log_type":"token"}	2025-12-12 20:33:43.99179+00	
00000000-0000-0000-0000-000000000000	f9baa9c2-abd8-40f9-9655-00fd46069221	{"action":"token_revoked","actor_id":"74a2ee9e-fe11-45d6-b4ef-0a668f9f6455","actor_name":"OcuHub Admin","actor_username":"admin@ocuhub.com","actor_via_sso":false,"log_type":"token"}	2025-12-12 20:33:44.009804+00	
00000000-0000-0000-0000-000000000000	961a2c44-c049-49c5-b12e-5e28501bb721	{"action":"token_refreshed","actor_id":"74a2ee9e-fe11-45d6-b4ef-0a668f9f6455","actor_name":"OcuHub Admin","actor_username":"admin@ocuhub.com","actor_via_sso":false,"log_type":"token"}	2025-12-12 20:33:44.150769+00	
00000000-0000-0000-0000-000000000000	f35bd4e7-12c8-400a-9d02-7a2b58a64a71	{"action":"login","actor_id":"74a2ee9e-fe11-45d6-b4ef-0a668f9f6455","actor_name":"OcuHub Admin","actor_username":"admin@ocuhub.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-12-12 20:39:30.095299+00	
00000000-0000-0000-0000-000000000000	2fd1d06c-b2ed-48c0-bb9e-bfb562f69f4c	{"action":"token_refreshed","actor_id":"74a2ee9e-fe11-45d6-b4ef-0a668f9f6455","actor_name":"OcuHub Admin","actor_username":"admin@ocuhub.com","actor_via_sso":false,"log_type":"token"}	2025-12-13 13:13:46.468252+00	
00000000-0000-0000-0000-000000000000	bdc216d5-1e7e-4c25-85d2-053b2b9075f1	{"action":"token_revoked","actor_id":"74a2ee9e-fe11-45d6-b4ef-0a668f9f6455","actor_name":"OcuHub Admin","actor_username":"admin@ocuhub.com","actor_via_sso":false,"log_type":"token"}	2025-12-13 13:13:46.482614+00	
00000000-0000-0000-0000-000000000000	4c228854-59a1-43fe-8628-3ade58077b8a	{"action":"token_refreshed","actor_id":"74a2ee9e-fe11-45d6-b4ef-0a668f9f6455","actor_name":"OcuHub Admin","actor_username":"admin@ocuhub.com","actor_via_sso":false,"log_type":"token"}	2025-12-13 13:13:46.665355+00	
00000000-0000-0000-0000-000000000000	70d2ba30-1892-494d-9778-25390a3e5ea2	{"action":"login","actor_id":"74a2ee9e-fe11-45d6-b4ef-0a668f9f6455","actor_name":"OcuHub Admin","actor_username":"admin@ocuhub.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-12-13 13:14:09.131978+00	
00000000-0000-0000-0000-000000000000	86e58ab9-138d-40cf-963b-b29385dcfa0e	{"action":"token_refreshed","actor_id":"74a2ee9e-fe11-45d6-b4ef-0a668f9f6455","actor_name":"OcuHub Admin","actor_username":"admin@ocuhub.com","actor_via_sso":false,"log_type":"token"}	2025-12-14 08:25:06.641898+00	
00000000-0000-0000-0000-000000000000	e14e2965-cdb1-4684-aa59-d0f55b2f8c6e	{"action":"token_revoked","actor_id":"74a2ee9e-fe11-45d6-b4ef-0a668f9f6455","actor_name":"OcuHub Admin","actor_username":"admin@ocuhub.com","actor_via_sso":false,"log_type":"token"}	2025-12-14 08:25:06.661971+00	
00000000-0000-0000-0000-000000000000	39d53848-2d0c-4568-8e98-8d92a1809833	{"action":"token_refreshed","actor_id":"74a2ee9e-fe11-45d6-b4ef-0a668f9f6455","actor_name":"OcuHub Admin","actor_username":"admin@ocuhub.com","actor_via_sso":false,"log_type":"token"}	2025-12-15 12:55:11.419186+00	
00000000-0000-0000-0000-000000000000	70a613ef-2a37-4c37-bcd9-a1238f723a6f	{"action":"token_revoked","actor_id":"74a2ee9e-fe11-45d6-b4ef-0a668f9f6455","actor_name":"OcuHub Admin","actor_username":"admin@ocuhub.com","actor_via_sso":false,"log_type":"token"}	2025-12-15 12:55:11.440548+00	
00000000-0000-0000-0000-000000000000	14d5b902-d5d7-4e31-8565-05989982008a	{"action":"token_refreshed","actor_id":"74a2ee9e-fe11-45d6-b4ef-0a668f9f6455","actor_name":"OcuHub Admin","actor_username":"admin@ocuhub.com","actor_via_sso":false,"log_type":"token"}	2025-12-15 12:55:11.663135+00	
00000000-0000-0000-0000-000000000000	c16027a8-b490-479f-b997-2c92c0dd2cc4	{"action":"login","actor_id":"74a2ee9e-fe11-45d6-b4ef-0a668f9f6455","actor_name":"OcuHub Admin","actor_username":"admin@ocuhub.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-12-15 12:55:29.134502+00	
00000000-0000-0000-0000-000000000000	12d1dff3-b8dc-4553-ae6f-fd1ec08d4ccd	{"action":"login","actor_id":"74a2ee9e-fe11-45d6-b4ef-0a668f9f6455","actor_name":"OcuHub Admin","actor_username":"admin@ocuhub.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-12-16 08:03:19.568657+00	
\.


--
-- Data for Name: flow_state; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.flow_state (id, user_id, auth_code, code_challenge_method, code_challenge, provider_type, provider_access_token, provider_refresh_token, created_at, updated_at, authentication_method, auth_code_issued_at) FROM stdin;
\.


--
-- Data for Name: identities; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.identities (provider_id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at, id) FROM stdin;
110598595785728879745	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	{"iss": "https://accounts.google.com", "sub": "110598595785728879745", "name": "OcuHub Admin", "email": "admin@ocuhub.com", "picture": "https://lh3.googleusercontent.com/a/ACg8ocLHok1JFAkKy_wBBamjU7laUsU-By1hfU5b9zO5dEp4y_WRFQ=s96-c", "full_name": "OcuHub Admin", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocLHok1JFAkKy_wBBamjU7laUsU-By1hfU5b9zO5dEp4y_WRFQ=s96-c", "provider_id": "110598595785728879745", "email_verified": true, "phone_verified": false}	google	2025-12-06 20:06:52.969477+00	2025-12-06 20:06:52.96954+00	2025-12-16 08:03:19.549461+00	8471182d-3392-4dff-bf4a-8d9ebfdb9afa
115206877679424484173	60ad28a7-2abf-432e-87ed-dedd4b0d432e	{"iss": "https://accounts.google.com", "sub": "115206877679424484173", "name": "Ehab Sultan", "email": "egyeast@gmail.com", "picture": "https://lh3.googleusercontent.com/a/ACg8ocK-Cq4_0pr-RXTMc80RtDFn741ZWwWp3vDUIZkfSgFYJIBsJ1s7=s96-c", "full_name": "Ehab Sultan", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocK-Cq4_0pr-RXTMc80RtDFn741ZWwWp3vDUIZkfSgFYJIBsJ1s7=s96-c", "provider_id": "115206877679424484173", "email_verified": true, "phone_verified": false}	google	2025-12-06 22:36:56.163769+00	2025-12-06 22:36:56.16383+00	2025-12-07 00:18:57.451672+00	d2212e5d-944f-41db-9190-09066f3f7ad8
\.


--
-- Data for Name: instances; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.instances (id, uuid, raw_base_config, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: mfa_amr_claims; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.mfa_amr_claims (session_id, created_at, updated_at, authentication_method, id) FROM stdin;
12dd33ea-1b67-43b9-84b9-c9d6ee528899	2025-12-06 20:06:53.092561+00	2025-12-06 20:06:53.092561+00	oauth	6f80f386-fbf7-48ee-94ab-04374e1909fa
55dc5ac6-3595-4fbb-ab71-2e55382f5e40	2025-12-06 20:07:22.785788+00	2025-12-06 20:07:22.785788+00	oauth	9f4cf4d0-5d16-4a35-bf3e-8079adabc497
3b4dc703-dd8f-48cb-a5d5-2e5b448efa10	2025-12-06 20:10:17.198697+00	2025-12-06 20:10:17.198697+00	oauth	a56ce3ea-6655-48a0-be4e-a91d0930a88c
dc92b39a-f5be-4b9a-9e3e-bbbc9edbd68b	2025-12-06 20:10:27.261039+00	2025-12-06 20:10:27.261039+00	oauth	372725b9-7ea4-4558-a428-fdeaa1ca1cf9
fd8b6f69-2a46-4912-8458-fce43b3bd725	2025-12-06 20:10:56.379426+00	2025-12-06 20:10:56.379426+00	oauth	72ec294d-5668-4df8-8617-19c3a54f844d
85168bb9-2244-4920-9bd0-a315679f732c	2025-12-06 20:30:52.27701+00	2025-12-06 20:30:52.27701+00	oauth	f36276c5-8236-487d-a67c-ec167bb4b86a
0bf14103-c3d9-4c03-babe-bc3d7660d4b8	2025-12-06 21:01:35.808417+00	2025-12-06 21:01:35.808417+00	oauth	b69ebf30-f033-454e-aed2-55aab0faf622
b23be278-7ce3-4dcb-9d6c-66218ccadfff	2025-12-06 21:03:05.247689+00	2025-12-06 21:03:05.247689+00	oauth	49df3259-816f-4c16-8029-ac07c4d69546
3a1abd85-9491-4cd8-aee9-1fbbe3708ac6	2025-12-06 21:56:14.658992+00	2025-12-06 21:56:14.658992+00	oauth	c9f0bbdd-5b7f-46a2-b6f7-7917dfa077b3
703ad227-33eb-4786-a699-25242f46a483	2025-12-06 22:24:09.257061+00	2025-12-06 22:24:09.257061+00	oauth	74cda495-fa4d-4d6e-b224-48a5bea21d52
86206dd0-a6a4-4896-a238-a3e3bb201c61	2025-12-06 22:37:06.4977+00	2025-12-06 22:37:06.4977+00	oauth	6260c0c2-01c7-47bd-bb65-3e076f2d0750
56688f46-f39e-4a53-9a2e-99a36ae8180f	2025-12-06 22:37:15.842829+00	2025-12-06 22:37:15.842829+00	oauth	d3eb1959-c9c8-4eab-9dd9-8c96b159a4e4
cf2f17d6-75fb-45e1-bcf6-b02df2d12e10	2025-12-06 22:40:20.827877+00	2025-12-06 22:40:20.827877+00	oauth	17191454-3316-4517-a815-9cf39fc53c36
95a974cd-4623-4b32-9bc2-80b8ac42d70a	2025-12-06 22:42:41.554881+00	2025-12-06 22:42:41.554881+00	oauth	ab52074b-f966-4124-a164-65b350608f97
1e105b5e-9337-498a-b65c-1710eab90708	2025-12-06 23:02:10.356747+00	2025-12-06 23:02:10.356747+00	oauth	30c22845-8963-416b-bbc9-0505d043c4bd
6c74226c-a7f9-4d32-97a6-76acbd123102	2025-12-06 23:02:44.691011+00	2025-12-06 23:02:44.691011+00	oauth	4f39ade5-401a-4997-bc63-5443189d2329
764b3153-5711-4a66-9583-e915604dcc53	2025-12-06 23:02:52.646757+00	2025-12-06 23:02:52.646757+00	oauth	7f20b791-15a7-40ab-a1e4-4b23d7562c98
b9877538-0773-44db-9a71-063ce5981f1c	2025-12-06 23:02:57.444971+00	2025-12-06 23:02:57.444971+00	oauth	f510c9b4-7e08-43e9-a469-d061ba7ec517
e47e31ce-f08f-47e9-b1f6-9850b22d32f1	2025-12-06 23:03:02.399051+00	2025-12-06 23:03:02.399051+00	oauth	fd0e2e34-43ac-486b-b5cb-4496fddc2d3e
dc20213d-a9b8-4064-9cbb-131ca9f722f9	2025-12-06 23:04:55.444667+00	2025-12-06 23:04:55.444667+00	oauth	1e7b198b-18de-4195-be39-ebbb56af1a49
ad71e765-95e3-4551-ada8-ff29707a4274	2025-12-06 23:05:17.568763+00	2025-12-06 23:05:17.568763+00	oauth	a5a10f29-2137-42aa-8cc9-50bf2601f601
fef379ae-e316-4e1e-9201-bc0b954ef329	2025-12-06 23:05:47.300534+00	2025-12-06 23:05:47.300534+00	oauth	e5b7e9df-148b-42ce-b73e-c3bc9d1fc4a9
a48cd718-4850-40b3-9a90-32a193e37d51	2025-12-06 23:08:50.47473+00	2025-12-06 23:08:50.47473+00	oauth	42648f54-aa44-4601-a70b-7b03d5a02a72
05e3e9d2-cd15-416c-b2a6-f96f2309af96	2025-12-06 23:24:57.720493+00	2025-12-06 23:24:57.720493+00	oauth	68359e1d-2001-4e95-9b3d-72a7a0c7bfec
45aef182-d33d-4ca5-9622-59c2b3f1a172	2025-12-06 23:25:18.627468+00	2025-12-06 23:25:18.627468+00	oauth	9e8bf686-f922-47b4-8045-97347852a9b3
a4396db8-6a14-4eea-bb86-1ce22615d49e	2025-12-06 23:25:23.435534+00	2025-12-06 23:25:23.435534+00	oauth	3894470e-574e-4d95-8111-dab47e1ec26b
91c1e805-e12f-43c7-b54d-c45b35e188a1	2025-12-06 23:25:46.645683+00	2025-12-06 23:25:46.645683+00	oauth	d16508a9-b2ca-4dd5-a3ca-5cfdf91ef70d
056a9545-f332-4892-af3e-645bc1707eba	2025-12-06 23:25:51.484601+00	2025-12-06 23:25:51.484601+00	oauth	1cd8e93e-67f8-448f-aaaf-b7782f1fd205
0687037e-d12e-4703-be11-d13afb254df3	2025-12-06 23:26:07.523997+00	2025-12-06 23:26:07.523997+00	oauth	f1a11013-6d0f-424b-9bcf-1401d873b1ed
41366896-6621-443f-9ff3-6ef4e05c901b	2025-12-06 23:29:51.062532+00	2025-12-06 23:29:51.062532+00	otp	3a8e370b-6f06-47d6-bdab-70a1c34c8388
2470eb96-4e70-4b35-8b90-5f848e5af9e5	2025-12-07 00:14:21.034111+00	2025-12-07 00:14:21.034111+00	oauth	81be7c89-b98e-4261-b7ff-375e43071e79
764929c1-03e3-4813-a888-23c717840ed0	2025-12-07 00:14:28.523107+00	2025-12-07 00:14:28.523107+00	oauth	ecbb22da-fb0f-4f52-a955-24006e72d02f
bec43278-c80b-47ce-a4e5-4189d87f439a	2025-12-07 00:14:30.88664+00	2025-12-07 00:14:30.88664+00	oauth	f772da50-4881-4d3e-88eb-2a4a441a0abd
aac81517-a475-4ba5-b0c5-641f728c9f70	2025-12-07 00:15:02.153052+00	2025-12-07 00:15:02.153052+00	oauth	f6558d15-5cbd-47c4-ab00-40991dc39028
0fbc5fd6-3bc3-47ce-b12f-f73375a58248	2025-12-07 00:17:32.928185+00	2025-12-07 00:17:32.928185+00	oauth	a8a39c01-4b4c-4bb6-8d1c-ce09fdb9e5c6
f48b9f2a-8f5f-4d81-be68-a556c40c12b4	2025-12-07 00:18:16.740194+00	2025-12-07 00:18:16.740194+00	oauth	5b253b49-61c8-440a-bc7f-93610dd46f76
3250b24c-bafa-4921-b6b5-de62af728720	2025-12-07 00:19:28.69587+00	2025-12-07 00:19:28.69587+00	oauth	b4efd9a4-78e0-4911-a427-4dd738420343
689b8323-6053-4a04-bb4c-d1e8c56dea62	2025-12-07 00:27:38.442325+00	2025-12-07 00:27:38.442325+00	oauth	62c395ce-3730-44e2-87b3-dc1601fa6918
870b8b24-7c58-486b-87ba-1a9c7899ae4f	2025-12-07 12:30:41.884072+00	2025-12-07 12:30:41.884072+00	oauth	fc9918f9-79cb-467c-bf37-ba642cda134e
87ac74d3-913d-4ce8-bbad-6d47e3b9dd6f	2025-12-08 08:03:46.920556+00	2025-12-08 08:03:46.920556+00	oauth	62398c3c-5d64-4ea4-a8e8-7b912d43690c
8f0b931e-69c8-4fe1-aa6d-f73f20251f1a	2025-12-11 12:48:42.350218+00	2025-12-11 12:48:42.350218+00	oauth	d49be1f1-7e8e-4423-8449-63289461f43f
592b4559-315e-43e0-80f6-404537216869	2025-12-11 12:48:50.565605+00	2025-12-11 12:48:50.565605+00	oauth	a3e3c61c-614a-4810-83ec-7db7acd27d5e
51ff3b27-d3f7-4e65-886d-54b1b27baf95	2025-12-12 08:32:33.685984+00	2025-12-12 08:32:33.685984+00	oauth	4a612b4c-2c73-4f5a-b471-f78948d3ab65
aa1813f6-8b4a-412f-9f46-c8162923611e	2025-12-12 08:32:41.817095+00	2025-12-12 08:32:41.817095+00	oauth	abeb5fa7-0b40-4c65-90de-c4749824b9f0
9f58ce15-ea08-4709-bbd6-e8b40d78b6df	2025-12-12 20:39:30.115447+00	2025-12-12 20:39:30.115447+00	oauth	fc0a9b60-0fb5-4353-ad02-b969a1984119
cd69a420-3013-481e-8e60-0201b9a5cf2a	2025-12-13 13:14:09.145448+00	2025-12-13 13:14:09.145448+00	oauth	1014d2be-2d2d-4504-a614-905fd516cb5f
613f822e-2622-415b-9a45-c06861b52b49	2025-12-15 12:55:29.14113+00	2025-12-15 12:55:29.14113+00	oauth	d5d16471-61cc-4fea-a531-28a12b6afdbc
109e999a-0b89-4d63-952d-3777b02afa7d	2025-12-16 08:03:19.622169+00	2025-12-16 08:03:19.622169+00	oauth	cd613ef8-619b-488e-a575-bf791f976989
\.


--
-- Data for Name: mfa_challenges; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.mfa_challenges (id, factor_id, created_at, verified_at, ip_address, otp_code, web_authn_session_data) FROM stdin;
\.


--
-- Data for Name: mfa_factors; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.mfa_factors (id, user_id, friendly_name, factor_type, status, created_at, updated_at, secret, phone, last_challenged_at, web_authn_credential, web_authn_aaguid, last_webauthn_challenge_data) FROM stdin;
\.


--
-- Data for Name: oauth_authorizations; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.oauth_authorizations (id, authorization_id, client_id, user_id, redirect_uri, scope, state, resource, code_challenge, code_challenge_method, response_type, status, authorization_code, created_at, expires_at, approved_at, nonce) FROM stdin;
\.


--
-- Data for Name: oauth_client_states; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.oauth_client_states (id, provider_type, code_verifier, created_at) FROM stdin;
\.


--
-- Data for Name: oauth_clients; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.oauth_clients (id, client_secret_hash, registration_type, redirect_uris, grant_types, client_name, client_uri, logo_uri, created_at, updated_at, deleted_at, client_type) FROM stdin;
\.


--
-- Data for Name: oauth_consents; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.oauth_consents (id, user_id, client_id, scopes, granted_at, revoked_at) FROM stdin;
\.


--
-- Data for Name: one_time_tokens; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.one_time_tokens (id, user_id, token_type, token_hash, relates_to, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: refresh_tokens; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.refresh_tokens (instance_id, id, token, user_id, revoked, created_at, updated_at, parent, session_id) FROM stdin;
00000000-0000-0000-0000-000000000000	1	yprun7ffysb6	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	f	2025-12-06 20:06:53.055687+00	2025-12-06 20:06:53.055687+00	\N	12dd33ea-1b67-43b9-84b9-c9d6ee528899
00000000-0000-0000-0000-000000000000	2	4yl63pw7tlrj	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	f	2025-12-06 20:07:22.783326+00	2025-12-06 20:07:22.783326+00	\N	55dc5ac6-3595-4fbb-ab71-2e55382f5e40
00000000-0000-0000-0000-000000000000	3	w2dxyj6h4x46	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	f	2025-12-06 20:10:17.196984+00	2025-12-06 20:10:17.196984+00	\N	3b4dc703-dd8f-48cb-a5d5-2e5b448efa10
00000000-0000-0000-0000-000000000000	4	7xmrk6uhhcyf	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	f	2025-12-06 20:10:27.259947+00	2025-12-06 20:10:27.259947+00	\N	dc92b39a-f5be-4b9a-9e3e-bbbc9edbd68b
00000000-0000-0000-0000-000000000000	5	bscdnmcywe3f	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	f	2025-12-06 20:10:56.378129+00	2025-12-06 20:10:56.378129+00	\N	fd8b6f69-2a46-4912-8458-fce43b3bd725
00000000-0000-0000-0000-000000000000	6	nfymvbqawzwf	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	f	2025-12-06 20:30:52.266147+00	2025-12-06 20:30:52.266147+00	\N	85168bb9-2244-4920-9bd0-a315679f732c
00000000-0000-0000-0000-000000000000	7	n7veytmfmjtw	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	f	2025-12-06 21:01:35.792174+00	2025-12-06 21:01:35.792174+00	\N	0bf14103-c3d9-4c03-babe-bc3d7660d4b8
00000000-0000-0000-0000-000000000000	8	xe7iwniosue3	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	f	2025-12-06 21:03:05.244918+00	2025-12-06 21:03:05.244918+00	\N	b23be278-7ce3-4dcb-9d6c-66218ccadfff
00000000-0000-0000-0000-000000000000	9	5wl2dgkcbbqy	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	f	2025-12-06 21:56:14.632624+00	2025-12-06 21:56:14.632624+00	\N	3a1abd85-9491-4cd8-aee9-1fbbe3708ac6
00000000-0000-0000-0000-000000000000	10	azzebanbo7vm	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	f	2025-12-06 22:24:09.23591+00	2025-12-06 22:24:09.23591+00	\N	703ad227-33eb-4786-a699-25242f46a483
00000000-0000-0000-0000-000000000000	12	c6l3lywwq4rj	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	f	2025-12-06 22:37:06.496575+00	2025-12-06 22:37:06.496575+00	\N	86206dd0-a6a4-4896-a238-a3e3bb201c61
00000000-0000-0000-0000-000000000000	13	asfwu4cjkcaj	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	f	2025-12-06 22:37:15.841584+00	2025-12-06 22:37:15.841584+00	\N	56688f46-f39e-4a53-9a2e-99a36ae8180f
00000000-0000-0000-0000-000000000000	14	c2mie5voetvl	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	f	2025-12-06 22:40:20.825972+00	2025-12-06 22:40:20.825972+00	\N	cf2f17d6-75fb-45e1-bcf6-b02df2d12e10
00000000-0000-0000-0000-000000000000	15	wp4ka44nce64	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	f	2025-12-06 22:42:41.550612+00	2025-12-06 22:42:41.550612+00	\N	95a974cd-4623-4b32-9bc2-80b8ac42d70a
00000000-0000-0000-0000-000000000000	16	s6hjkfenipny	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	f	2025-12-06 23:02:10.341825+00	2025-12-06 23:02:10.341825+00	\N	1e105b5e-9337-498a-b65c-1710eab90708
00000000-0000-0000-0000-000000000000	17	fy3u6hwrdu72	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	f	2025-12-06 23:02:44.687773+00	2025-12-06 23:02:44.687773+00	\N	6c74226c-a7f9-4d32-97a6-76acbd123102
00000000-0000-0000-0000-000000000000	18	gcwh3c7qxtaz	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	f	2025-12-06 23:02:52.645597+00	2025-12-06 23:02:52.645597+00	\N	764b3153-5711-4a66-9583-e915604dcc53
00000000-0000-0000-0000-000000000000	19	424dbao4o5th	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	f	2025-12-06 23:02:57.443776+00	2025-12-06 23:02:57.443776+00	\N	b9877538-0773-44db-9a71-063ce5981f1c
00000000-0000-0000-0000-000000000000	20	5klkhb5trjyr	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	f	2025-12-06 23:03:02.397833+00	2025-12-06 23:03:02.397833+00	\N	e47e31ce-f08f-47e9-b1f6-9850b22d32f1
00000000-0000-0000-0000-000000000000	21	plyacumlc6t5	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	f	2025-12-06 23:04:55.434166+00	2025-12-06 23:04:55.434166+00	\N	dc20213d-a9b8-4064-9cbb-131ca9f722f9
00000000-0000-0000-0000-000000000000	22	y2y62kyyhrcj	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	f	2025-12-06 23:05:17.563433+00	2025-12-06 23:05:17.563433+00	\N	ad71e765-95e3-4551-ada8-ff29707a4274
00000000-0000-0000-0000-000000000000	23	rd3k5zpnvufj	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	f	2025-12-06 23:05:47.299287+00	2025-12-06 23:05:47.299287+00	\N	fef379ae-e316-4e1e-9201-bc0b954ef329
00000000-0000-0000-0000-000000000000	24	hi3dwseuazzh	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	f	2025-12-06 23:08:50.471481+00	2025-12-06 23:08:50.471481+00	\N	a48cd718-4850-40b3-9a90-32a193e37d51
00000000-0000-0000-0000-000000000000	25	ev54zekrld7m	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	f	2025-12-06 23:24:57.714508+00	2025-12-06 23:24:57.714508+00	\N	05e3e9d2-cd15-416c-b2a6-f96f2309af96
00000000-0000-0000-0000-000000000000	26	snpza2m75y67	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	f	2025-12-06 23:25:18.625587+00	2025-12-06 23:25:18.625587+00	\N	45aef182-d33d-4ca5-9622-59c2b3f1a172
00000000-0000-0000-0000-000000000000	27	vbg6ta46y3fx	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	f	2025-12-06 23:25:23.434361+00	2025-12-06 23:25:23.434361+00	\N	a4396db8-6a14-4eea-bb86-1ce22615d49e
00000000-0000-0000-0000-000000000000	28	khwvqwelkjbk	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	f	2025-12-06 23:25:46.644481+00	2025-12-06 23:25:46.644481+00	\N	91c1e805-e12f-43c7-b54d-c45b35e188a1
00000000-0000-0000-0000-000000000000	29	6d474vboior4	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	f	2025-12-06 23:25:51.483454+00	2025-12-06 23:25:51.483454+00	\N	056a9545-f332-4892-af3e-645bc1707eba
00000000-0000-0000-0000-000000000000	31	6fzmh2ohgaju	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	f	2025-12-06 23:29:51.048311+00	2025-12-06 23:29:51.048311+00	\N	41366896-6621-443f-9ff3-6ef4e05c901b
00000000-0000-0000-0000-000000000000	32	rl4fbzns5p4j	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	f	2025-12-07 00:14:21.007995+00	2025-12-07 00:14:21.007995+00	\N	2470eb96-4e70-4b35-8b90-5f848e5af9e5
00000000-0000-0000-0000-000000000000	33	kyof4y3vujuc	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	f	2025-12-07 00:14:28.519073+00	2025-12-07 00:14:28.519073+00	\N	764929c1-03e3-4813-a888-23c717840ed0
00000000-0000-0000-0000-000000000000	34	vyngooacvzbw	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	f	2025-12-07 00:14:30.883285+00	2025-12-07 00:14:30.883285+00	\N	bec43278-c80b-47ce-a4e5-4189d87f439a
00000000-0000-0000-0000-000000000000	35	xy2xkt6pb7c5	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	f	2025-12-07 00:15:02.150172+00	2025-12-07 00:15:02.150172+00	\N	aac81517-a475-4ba5-b0c5-641f728c9f70
00000000-0000-0000-0000-000000000000	36	vftvet2yp4se	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	f	2025-12-07 00:17:32.925133+00	2025-12-07 00:17:32.925133+00	\N	0fbc5fd6-3bc3-47ce-b12f-f73375a58248
00000000-0000-0000-0000-000000000000	37	pnljpiwe4b53	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	f	2025-12-07 00:18:16.739032+00	2025-12-07 00:18:16.739032+00	\N	f48b9f2a-8f5f-4d81-be68-a556c40c12b4
00000000-0000-0000-0000-000000000000	30	7bc2ogdcmi2k	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	t	2025-12-06 23:26:07.522751+00	2025-12-07 00:27:32.656308+00	\N	0687037e-d12e-4703-be11-d13afb254df3
00000000-0000-0000-0000-000000000000	42	syh3xh7efjo2	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	f	2025-12-07 00:27:38.439839+00	2025-12-07 00:27:38.439839+00	\N	689b8323-6053-4a04-bb4c-d1e8c56dea62
00000000-0000-0000-0000-000000000000	40	gxpeiuajl45s	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	t	2025-12-07 00:19:28.694722+00	2025-12-07 07:33:59.574871+00	\N	3250b24c-bafa-4921-b6b5-de62af728720
00000000-0000-0000-0000-000000000000	43	6wx6vtyzs6ay	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	f	2025-12-07 07:33:59.597014+00	2025-12-07 07:33:59.597014+00	gxpeiuajl45s	3250b24c-bafa-4921-b6b5-de62af728720
00000000-0000-0000-0000-000000000000	41	vx3fgm5tkd3i	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	t	2025-12-07 00:27:32.668419+00	2025-12-07 12:30:34.948977+00	7bc2ogdcmi2k	0687037e-d12e-4703-be11-d13afb254df3
00000000-0000-0000-0000-000000000000	44	qip6chl6pzpi	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	f	2025-12-07 12:30:34.960735+00	2025-12-07 12:30:34.960735+00	vx3fgm5tkd3i	0687037e-d12e-4703-be11-d13afb254df3
00000000-0000-0000-0000-000000000000	45	wkgzctyp7ktt	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	t	2025-12-07 12:30:41.880988+00	2025-12-08 08:03:30.464182+00	\N	870b8b24-7c58-486b-87ba-1a9c7899ae4f
00000000-0000-0000-0000-000000000000	46	q23ld2nlyqxy	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	f	2025-12-08 08:03:30.485173+00	2025-12-08 08:03:30.485173+00	wkgzctyp7ktt	870b8b24-7c58-486b-87ba-1a9c7899ae4f
00000000-0000-0000-0000-000000000000	47	vqddicvk5qxq	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	t	2025-12-08 08:03:46.91843+00	2025-12-08 21:40:45.644416+00	\N	87ac74d3-913d-4ce8-bbad-6d47e3b9dd6f
00000000-0000-0000-0000-000000000000	48	v5moefiff6rd	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	t	2025-12-08 21:40:45.659826+00	2025-12-09 12:02:41.701351+00	vqddicvk5qxq	87ac74d3-913d-4ce8-bbad-6d47e3b9dd6f
00000000-0000-0000-0000-000000000000	49	6ohs6sq2dnms	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	t	2025-12-09 12:02:41.730738+00	2025-12-10 12:23:12.357706+00	v5moefiff6rd	87ac74d3-913d-4ce8-bbad-6d47e3b9dd6f
00000000-0000-0000-0000-000000000000	50	zuhu2kpsh2lx	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	t	2025-12-10 12:23:12.378869+00	2025-12-10 13:21:38.650621+00	6ohs6sq2dnms	87ac74d3-913d-4ce8-bbad-6d47e3b9dd6f
00000000-0000-0000-0000-000000000000	51	gbpudmuqy4pl	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	t	2025-12-10 13:21:38.668279+00	2025-12-10 16:05:41.414616+00	zuhu2kpsh2lx	87ac74d3-913d-4ce8-bbad-6d47e3b9dd6f
00000000-0000-0000-0000-000000000000	52	mqinulscj65t	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	t	2025-12-10 16:05:41.435092+00	2025-12-10 17:29:08.309855+00	gbpudmuqy4pl	87ac74d3-913d-4ce8-bbad-6d47e3b9dd6f
00000000-0000-0000-0000-000000000000	53	mj2furj23o3y	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	t	2025-12-10 17:29:08.327168+00	2025-12-10 20:07:52.400311+00	mqinulscj65t	87ac74d3-913d-4ce8-bbad-6d47e3b9dd6f
00000000-0000-0000-0000-000000000000	54	cvltrcaledqk	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	t	2025-12-10 20:07:52.421073+00	2025-12-11 12:48:32.770753+00	mj2furj23o3y	87ac74d3-913d-4ce8-bbad-6d47e3b9dd6f
00000000-0000-0000-0000-000000000000	55	esrrvslv4isn	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	f	2025-12-11 12:48:32.779175+00	2025-12-11 12:48:32.779175+00	cvltrcaledqk	87ac74d3-913d-4ce8-bbad-6d47e3b9dd6f
00000000-0000-0000-0000-000000000000	56	6cjh2atmojac	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	f	2025-12-11 12:48:42.348969+00	2025-12-11 12:48:42.348969+00	\N	8f0b931e-69c8-4fe1-aa6d-f73f20251f1a
00000000-0000-0000-0000-000000000000	57	nalz2o4ncspo	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	f	2025-12-11 12:48:50.558688+00	2025-12-11 12:48:50.558688+00	\N	592b4559-315e-43e0-80f6-404537216869
00000000-0000-0000-0000-000000000000	58	7ternjy4gxbk	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	f	2025-12-12 08:32:33.661407+00	2025-12-12 08:32:33.661407+00	\N	51ff3b27-d3f7-4e65-886d-54b1b27baf95
00000000-0000-0000-0000-000000000000	59	efxcydprjpks	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	t	2025-12-12 08:32:41.81529+00	2025-12-12 20:33:44.010744+00	\N	aa1813f6-8b4a-412f-9f46-c8162923611e
00000000-0000-0000-0000-000000000000	60	fy7rkppgumvc	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	f	2025-12-12 20:33:44.022869+00	2025-12-12 20:33:44.022869+00	efxcydprjpks	aa1813f6-8b4a-412f-9f46-c8162923611e
00000000-0000-0000-0000-000000000000	61	x3y66kfp6hz4	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	t	2025-12-12 20:39:30.108462+00	2025-12-13 13:13:46.484337+00	\N	9f58ce15-ea08-4709-bbd6-e8b40d78b6df
00000000-0000-0000-0000-000000000000	62	lll6vtkdpgoo	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	f	2025-12-13 13:13:46.490895+00	2025-12-13 13:13:46.490895+00	x3y66kfp6hz4	9f58ce15-ea08-4709-bbd6-e8b40d78b6df
00000000-0000-0000-0000-000000000000	63	v2gq6ydgkpub	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	t	2025-12-13 13:14:09.143418+00	2025-12-14 08:25:06.663929+00	\N	cd69a420-3013-481e-8e60-0201b9a5cf2a
00000000-0000-0000-0000-000000000000	64	3ptqlzg2xm36	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	t	2025-12-14 08:25:06.685076+00	2025-12-15 12:55:11.441681+00	v2gq6ydgkpub	cd69a420-3013-481e-8e60-0201b9a5cf2a
00000000-0000-0000-0000-000000000000	65	roeybti5obf2	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	f	2025-12-15 12:55:11.451102+00	2025-12-15 12:55:11.451102+00	3ptqlzg2xm36	cd69a420-3013-481e-8e60-0201b9a5cf2a
00000000-0000-0000-0000-000000000000	66	pe5shur2mb22	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	f	2025-12-15 12:55:29.139909+00	2025-12-15 12:55:29.139909+00	\N	613f822e-2622-415b-9a45-c06861b52b49
00000000-0000-0000-0000-000000000000	67	qk2chl2hfi7w	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	f	2025-12-16 08:03:19.598851+00	2025-12-16 08:03:19.598851+00	\N	109e999a-0b89-4d63-952d-3777b02afa7d
\.


--
-- Data for Name: saml_providers; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.saml_providers (id, sso_provider_id, entity_id, metadata_xml, metadata_url, attribute_mapping, created_at, updated_at, name_id_format) FROM stdin;
\.


--
-- Data for Name: saml_relay_states; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.saml_relay_states (id, sso_provider_id, request_id, for_email, redirect_to, created_at, updated_at, flow_state_id) FROM stdin;
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.schema_migrations (version) FROM stdin;
20171026211738
20171026211808
20171026211834
20180103212743
20180108183307
20180119214651
20180125194653
00
20210710035447
20210722035447
20210730183235
20210909172000
20210927181326
20211122151130
20211124214934
20211202183645
20220114185221
20220114185340
20220224000811
20220323170000
20220429102000
20220531120530
20220614074223
20220811173540
20221003041349
20221003041400
20221011041400
20221020193600
20221021073300
20221021082433
20221027105023
20221114143122
20221114143410
20221125140132
20221208132122
20221215195500
20221215195800
20221215195900
20230116124310
20230116124412
20230131181311
20230322519590
20230402418590
20230411005111
20230508135423
20230523124323
20230818113222
20230914180801
20231027141322
20231114161723
20231117164230
20240115144230
20240214120130
20240306115329
20240314092811
20240427152123
20240612123726
20240729123726
20240802193726
20240806073726
20241009103726
20250717082212
20250731150234
20250804100000
20250901200500
20250903112500
20250904133000
20250925093508
20251007112900
20251104100000
20251111201300
20251201000000
\.


--
-- Data for Name: sessions; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.sessions (id, user_id, created_at, updated_at, factor_id, aal, not_after, refreshed_at, user_agent, ip, tag, oauth_client_id, refresh_token_hmac_key, refresh_token_counter, scopes) FROM stdin;
12dd33ea-1b67-43b9-84b9-c9d6ee528899	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	2025-12-06 20:06:53.010541+00	2025-12-06 20:06:53.010541+00	\N	aal1	\N	\N	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.6 Safari/605.1.15	82.197.61.223	\N	\N	\N	\N	\N
55dc5ac6-3595-4fbb-ab71-2e55382f5e40	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	2025-12-06 20:07:22.78263+00	2025-12-06 20:07:22.78263+00	\N	aal1	\N	\N	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.6 Safari/605.1.15	82.197.61.223	\N	\N	\N	\N	\N
3b4dc703-dd8f-48cb-a5d5-2e5b448efa10	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	2025-12-06 20:10:17.195773+00	2025-12-06 20:10:17.195773+00	\N	aal1	\N	\N	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.6 Safari/605.1.15	82.197.61.223	\N	\N	\N	\N	\N
dc92b39a-f5be-4b9a-9e3e-bbbc9edbd68b	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	2025-12-06 20:10:27.259264+00	2025-12-06 20:10:27.259264+00	\N	aal1	\N	\N	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.6 Safari/605.1.15	82.197.61.223	\N	\N	\N	\N	\N
fd8b6f69-2a46-4912-8458-fce43b3bd725	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	2025-12-06 20:10:56.377388+00	2025-12-06 20:10:56.377388+00	\N	aal1	\N	\N	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.6 Safari/605.1.15	82.197.61.223	\N	\N	\N	\N	\N
85168bb9-2244-4920-9bd0-a315679f732c	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	2025-12-06 20:30:52.248647+00	2025-12-06 20:30:52.248647+00	\N	aal1	\N	\N	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.6 Safari/605.1.15	82.197.61.223	\N	\N	\N	\N	\N
0bf14103-c3d9-4c03-babe-bc3d7660d4b8	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	2025-12-06 21:01:35.773865+00	2025-12-06 21:01:35.773865+00	\N	aal1	\N	\N	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.6 Safari/605.1.15	82.197.61.223	\N	\N	\N	\N	\N
b23be278-7ce3-4dcb-9d6c-66218ccadfff	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	2025-12-06 21:03:05.243375+00	2025-12-06 21:03:05.243375+00	\N	aal1	\N	\N	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.6 Safari/605.1.15	82.197.61.223	\N	\N	\N	\N	\N
3a1abd85-9491-4cd8-aee9-1fbbe3708ac6	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	2025-12-06 21:56:14.601573+00	2025-12-06 21:56:14.601573+00	\N	aal1	\N	\N	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.6 Safari/605.1.15	176.19.18.13	\N	\N	\N	\N	\N
703ad227-33eb-4786-a699-25242f46a483	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	2025-12-06 22:24:09.220656+00	2025-12-06 22:24:09.220656+00	\N	aal1	\N	\N	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.6 Safari/605.1.15	176.19.18.13	\N	\N	\N	\N	\N
86206dd0-a6a4-4896-a238-a3e3bb201c61	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	2025-12-06 22:37:06.495811+00	2025-12-06 22:37:06.495811+00	\N	aal1	\N	\N	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.6 Safari/605.1.15	176.19.18.13	\N	\N	\N	\N	\N
56688f46-f39e-4a53-9a2e-99a36ae8180f	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	2025-12-06 22:37:15.840834+00	2025-12-06 22:37:15.840834+00	\N	aal1	\N	\N	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.6 Safari/605.1.15	176.19.18.13	\N	\N	\N	\N	\N
cf2f17d6-75fb-45e1-bcf6-b02df2d12e10	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	2025-12-06 22:40:20.824711+00	2025-12-06 22:40:20.824711+00	\N	aal1	\N	\N	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	176.19.18.13	\N	\N	\N	\N	\N
95a974cd-4623-4b32-9bc2-80b8ac42d70a	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	2025-12-06 22:42:41.54237+00	2025-12-06 22:42:41.54237+00	\N	aal1	\N	\N	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	176.19.18.13	\N	\N	\N	\N	\N
1e105b5e-9337-498a-b65c-1710eab90708	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	2025-12-06 23:02:10.328076+00	2025-12-06 23:02:10.328076+00	\N	aal1	\N	\N	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.6 Safari/605.1.15	176.19.18.13	\N	\N	\N	\N	\N
6c74226c-a7f9-4d32-97a6-76acbd123102	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	2025-12-06 23:02:44.686999+00	2025-12-06 23:02:44.686999+00	\N	aal1	\N	\N	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	176.19.18.13	\N	\N	\N	\N	\N
764b3153-5711-4a66-9583-e915604dcc53	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	2025-12-06 23:02:52.644863+00	2025-12-06 23:02:52.644863+00	\N	aal1	\N	\N	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	176.19.18.13	\N	\N	\N	\N	\N
b9877538-0773-44db-9a71-063ce5981f1c	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	2025-12-06 23:02:57.443027+00	2025-12-06 23:02:57.443027+00	\N	aal1	\N	\N	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	176.19.18.13	\N	\N	\N	\N	\N
e47e31ce-f08f-47e9-b1f6-9850b22d32f1	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	2025-12-06 23:03:02.396968+00	2025-12-06 23:03:02.396968+00	\N	aal1	\N	\N	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	176.19.18.13	\N	\N	\N	\N	\N
dc20213d-a9b8-4064-9cbb-131ca9f722f9	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	2025-12-06 23:04:55.41217+00	2025-12-06 23:04:55.41217+00	\N	aal1	\N	\N	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	176.19.18.13	\N	\N	\N	\N	\N
ad71e765-95e3-4551-ada8-ff29707a4274	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	2025-12-06 23:05:17.561971+00	2025-12-06 23:05:17.561971+00	\N	aal1	\N	\N	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	176.19.18.13	\N	\N	\N	\N	\N
fef379ae-e316-4e1e-9201-bc0b954ef329	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	2025-12-06 23:05:47.29858+00	2025-12-06 23:05:47.29858+00	\N	aal1	\N	\N	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	176.19.18.13	\N	\N	\N	\N	\N
a48cd718-4850-40b3-9a90-32a193e37d51	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	2025-12-06 23:08:50.469508+00	2025-12-06 23:08:50.469508+00	\N	aal1	\N	\N	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	176.19.18.13	\N	\N	\N	\N	\N
05e3e9d2-cd15-416c-b2a6-f96f2309af96	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	2025-12-06 23:24:57.707839+00	2025-12-06 23:24:57.707839+00	\N	aal1	\N	\N	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	176.19.18.13	\N	\N	\N	\N	\N
45aef182-d33d-4ca5-9622-59c2b3f1a172	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	2025-12-06 23:25:18.624773+00	2025-12-06 23:25:18.624773+00	\N	aal1	\N	\N	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	176.19.18.13	\N	\N	\N	\N	\N
a4396db8-6a14-4eea-bb86-1ce22615d49e	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	2025-12-06 23:25:23.433609+00	2025-12-06 23:25:23.433609+00	\N	aal1	\N	\N	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	176.19.18.13	\N	\N	\N	\N	\N
91c1e805-e12f-43c7-b54d-c45b35e188a1	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	2025-12-06 23:25:46.643666+00	2025-12-06 23:25:46.643666+00	\N	aal1	\N	\N	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	176.19.18.13	\N	\N	\N	\N	\N
056a9545-f332-4892-af3e-645bc1707eba	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	2025-12-06 23:25:51.482549+00	2025-12-06 23:25:51.482549+00	\N	aal1	\N	\N	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	176.19.18.13	\N	\N	\N	\N	\N
41366896-6621-443f-9ff3-6ef4e05c901b	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	2025-12-06 23:29:51.040325+00	2025-12-06 23:29:51.040325+00	\N	aal1	\N	\N	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Mobile/15E148 Safari/604.1	176.19.18.13	\N	\N	\N	\N	\N
2470eb96-4e70-4b35-8b90-5f848e5af9e5	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	2025-12-07 00:14:20.973981+00	2025-12-07 00:14:20.973981+00	\N	aal1	\N	\N	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	176.19.18.13	\N	\N	\N	\N	\N
764929c1-03e3-4813-a888-23c717840ed0	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	2025-12-07 00:14:28.518323+00	2025-12-07 00:14:28.518323+00	\N	aal1	\N	\N	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	176.19.18.13	\N	\N	\N	\N	\N
bec43278-c80b-47ce-a4e5-4189d87f439a	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	2025-12-07 00:14:30.881271+00	2025-12-07 00:14:30.881271+00	\N	aal1	\N	\N	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	176.19.18.13	\N	\N	\N	\N	\N
aac81517-a475-4ba5-b0c5-641f728c9f70	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	2025-12-07 00:15:02.1493+00	2025-12-07 00:15:02.1493+00	\N	aal1	\N	\N	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	176.19.18.13	\N	\N	\N	\N	\N
0fbc5fd6-3bc3-47ce-b12f-f73375a58248	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	2025-12-07 00:17:32.923393+00	2025-12-07 00:17:32.923393+00	\N	aal1	\N	\N	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	176.19.18.13	\N	\N	\N	\N	\N
f48b9f2a-8f5f-4d81-be68-a556c40c12b4	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	2025-12-07 00:18:16.737684+00	2025-12-07 00:18:16.737684+00	\N	aal1	\N	\N	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	176.19.18.13	\N	\N	\N	\N	\N
689b8323-6053-4a04-bb4c-d1e8c56dea62	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	2025-12-07 00:27:38.432621+00	2025-12-07 00:27:38.432621+00	\N	aal1	\N	\N	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.6 Safari/605.1.15	176.19.18.13	\N	\N	\N	\N	\N
3250b24c-bafa-4921-b6b5-de62af728720	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	2025-12-07 00:19:28.693964+00	2025-12-07 07:33:59.631607+00	\N	aal1	\N	2025-12-07 07:33:59.629709	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	176.19.127.203	\N	\N	\N	\N	\N
0687037e-d12e-4703-be11-d13afb254df3	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	2025-12-06 23:26:07.521945+00	2025-12-07 12:30:34.982938+00	\N	aal1	\N	2025-12-07 12:30:34.982807	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.6 Safari/605.1.15	176.19.18.13	\N	\N	\N	\N	\N
870b8b24-7c58-486b-87ba-1a9c7899ae4f	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	2025-12-07 12:30:41.876269+00	2025-12-08 08:03:30.757279+00	\N	aal1	\N	2025-12-08 08:03:30.757172	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.6 Safari/605.1.15	176.19.127.203	\N	\N	\N	\N	\N
87ac74d3-913d-4ce8-bbad-6d47e3b9dd6f	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	2025-12-08 08:03:46.904128+00	2025-12-11 12:48:32.797356+00	\N	aal1	\N	2025-12-11 12:48:32.795628	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.6 Safari/605.1.15	176.19.19.183	\N	\N	\N	\N	\N
8f0b931e-69c8-4fe1-aa6d-f73f20251f1a	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	2025-12-11 12:48:42.340294+00	2025-12-11 12:48:42.340294+00	\N	aal1	\N	\N	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.6 Safari/605.1.15	176.19.19.183	\N	\N	\N	\N	\N
592b4559-315e-43e0-80f6-404537216869	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	2025-12-11 12:48:50.557782+00	2025-12-11 12:48:50.557782+00	\N	aal1	\N	\N	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.6 Safari/605.1.15	176.19.19.183	\N	\N	\N	\N	\N
51ff3b27-d3f7-4e65-886d-54b1b27baf95	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	2025-12-12 08:32:33.631269+00	2025-12-12 08:32:33.631269+00	\N	aal1	\N	\N	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.6 Safari/605.1.15	176.19.126.139	\N	\N	\N	\N	\N
aa1813f6-8b4a-412f-9f46-c8162923611e	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	2025-12-12 08:32:41.814501+00	2025-12-12 20:33:44.159271+00	\N	aal1	\N	2025-12-12 20:33:44.159142	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.6 Safari/605.1.15	176.19.126.139	\N	\N	\N	\N	\N
9f58ce15-ea08-4709-bbd6-e8b40d78b6df	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	2025-12-12 20:39:30.097598+00	2025-12-13 13:13:46.670872+00	\N	aal1	\N	2025-12-13 13:13:46.670222	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.6 Safari/605.1.15	93.112.174.51	\N	\N	\N	\N	\N
cd69a420-3013-481e-8e60-0201b9a5cf2a	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	2025-12-13 13:14:09.133597+00	2025-12-15 12:55:11.66637+00	\N	aal1	\N	2025-12-15 12:55:11.666261	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.6 Safari/605.1.15	37.127.62.39	\N	\N	\N	\N	\N
613f822e-2622-415b-9a45-c06861b52b49	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	2025-12-15 12:55:29.135102+00	2025-12-15 12:55:29.135102+00	\N	aal1	\N	\N	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.6 Safari/605.1.15	37.127.62.39	\N	\N	\N	\N	\N
109e999a-0b89-4d63-952d-3777b02afa7d	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	2025-12-16 08:03:19.579796+00	2025-12-16 08:03:19.579796+00	\N	aal1	\N	\N	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.6 Safari/605.1.15	176.19.127.203	\N	\N	\N	\N	\N
\.


--
-- Data for Name: sso_domains; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.sso_domains (id, sso_provider_id, domain, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: sso_providers; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.sso_providers (id, resource_id, created_at, updated_at, disabled) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, invited_at, confirmation_token, confirmation_sent_at, recovery_token, recovery_sent_at, email_change_token_new, email_change, email_change_sent_at, last_sign_in_at, raw_app_meta_data, raw_user_meta_data, is_super_admin, created_at, updated_at, phone, phone_confirmed_at, phone_change, phone_change_token, phone_change_sent_at, email_change_token_current, email_change_confirm_status, banned_until, reauthentication_token, reauthentication_sent_at, is_sso_user, deleted_at, is_anonymous) FROM stdin;
00000000-0000-0000-0000-000000000000	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	authenticated	authenticated	admin@ocuhub.com	\N	2025-12-06 20:06:52.997254+00	\N		\N		2025-12-06 23:29:08.274257+00			\N	2025-12-16 08:03:19.579072+00	{"provider": "google", "providers": ["google"]}	{"iss": "https://accounts.google.com", "sub": "110598595785728879745", "name": "OcuHub Admin", "email": "admin@ocuhub.com", "picture": "https://lh3.googleusercontent.com/a/ACg8ocLHok1JFAkKy_wBBamjU7laUsU-By1hfU5b9zO5dEp4y_WRFQ=s96-c", "full_name": "OcuHub Admin", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocLHok1JFAkKy_wBBamjU7laUsU-By1hfU5b9zO5dEp4y_WRFQ=s96-c", "provider_id": "110598595785728879745", "email_verified": true, "phone_verified": false}	\N	2025-12-06 20:06:52.900458+00	2025-12-16 08:03:19.620975+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	60ad28a7-2abf-432e-87ed-dedd4b0d432e	authenticated	authenticated	egyeast@gmail.com	\N	2025-12-06 22:36:56.180953+00	\N		\N		\N			\N	2025-12-07 00:18:57.454523+00	{"provider": "google", "providers": ["google"]}	{"iss": "https://accounts.google.com", "sub": "115206877679424484173", "name": "Ehab Sultan", "email": "egyeast@gmail.com", "picture": "https://lh3.googleusercontent.com/a/ACg8ocK-Cq4_0pr-RXTMc80RtDFn741ZWwWp3vDUIZkfSgFYJIBsJ1s7=s96-c", "full_name": "Ehab Sultan", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocK-Cq4_0pr-RXTMc80RtDFn741ZWwWp3vDUIZkfSgFYJIBsJ1s7=s96-c", "provider_id": "115206877679424484173", "email_verified": true, "phone_verified": false}	\N	2025-12-06 22:36:56.1273+00	2025-12-07 00:18:57.456753+00	\N	\N			\N		0	\N		\N	f	\N	f
\.


--
-- Data for Name: admin_users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.admin_users (id, user_id, email, password_hash, display_name, role, is_active, last_login_at, created_at, created_by) FROM stdin;
f4271647-c15c-4776-be93-d46fe4185144	74a2ee9e-fe11-45d6-b4ef-0a668f9f6455	admin@ocuhub.com	\N	OcuHub Admin	superadmin	t	2025-12-16 08:03:22.959+00	2025-12-08 22:21:51.185018+00	system
\.


--
-- Data for Name: announcement_config; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.announcement_config (id, config_key, config_value, description, updated_at, updated_by) FROM stdin;
\.


--
-- Data for Name: announcement_impressions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.announcement_impressions (id, announcement_id, user_id, impressions, last_seen_at) FROM stdin;
\.


--
-- Data for Name: announcement_responses; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.announcement_responses (id, announcement_id, question_id, user_id, user_auth_uid, option_value, text_value, numeric_value, link_to_profile, created_at, updated_at, first_option_value, first_text_value, first_numeric_value, first_answered_at) FROM stdin;
c6c4a35b-c55a-4e19-887f-d153e4e47a51	7fc073b6-d1fa-404e-b443-0fe4d1000f52	q_1765652534217	\N	6KAWj7gw9MUig2M8sK021ss8ilu2	Seborrheic Blepharitis	\N	\N	\N	2025-12-16 13:15:02.435+00	2025-12-16 13:15:54.635+00	Seborrheic Blepharitis	\N	\N	2025-12-16 13:15:01.432+00
0ad48ace-021c-432d-ae07-c7d268397f1b	ee5f3d93-6aa0-4c73-8a63-3551f59abdd5	q_1765575196587	\N	6KAWj7gw9MUig2M8sK021ss8ilu2	Ophthalmologist	\N	\N	profession	2025-12-16 13:15:54.05+00	2025-12-16 13:15:54.635+00	Ophthalmologist	\N	\N	2025-12-16 13:15:48.665+00
e626ff3c-1e28-4fce-842b-bb4b598039e5	ee5f3d93-6aa0-4c73-8a63-3551f59abdd5	q_1765580536433	\N	6KAWj7gw9MUig2M8sK021ss8ilu2	10-20 years	\N	\N	years_experience	2025-12-16 13:15:54.05+00	2025-12-16 13:15:54.635+00	10-20 years	\N	\N	2025-12-16 13:15:50.96+00
f354f5be-271b-4c7c-8e90-3ab96ff0b347	ee5f3d93-6aa0-4c73-8a63-3551f59abdd5	q_1765580684979	\N	6KAWj7gw9MUig2M8sK021ss8ilu2	Pediatrics & Strabismus	\N	\N	subspecialty	2025-12-16 13:15:54.05+00	2025-12-16 13:15:54.635+00	Pediatrics & Strabismus	\N	\N	2025-12-16 13:15:52.227+00
18cd5b23-1255-43e5-bf92-03e399d5a5cc	ee5f3d93-6aa0-4c73-8a63-3551f59abdd5	q_1765580743982	\N	6KAWj7gw9MUig2M8sK021ss8ilu2	Subspecialty practice (completed advanced training, independent role)	\N	\N	degree	2025-12-16 13:15:54.05+00	2025-12-16 13:15:54.635+00	Subspecialty practice (completed advanced training, independent role)	\N	\N	2025-12-16 13:15:54.031+00
\.


--
-- Data for Name: announcements; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.announcements (id, title, message, body, surface, importance, kind, priority, audience, action_type, action_value, start_at, end_at, is_active, is_deleted, deleted_at, deleted_by, dismissible, repeat_mode, repeat_interval_hours, max_times_seen_per_user, max_impressions, show_in_carousel, show_in_notifications, status, target_country, target_speciality, target_min_app_version, target_max_app_version, target_logged_in_only, target_anonymous_only, metadata, questions, responses, created_at, updated_at, created_by, updated_by, version, dismissible_mode, remind_later_count, remind_later_sessions, target_degree, target_subspecialty, target_profession, target_hospital, target_years_experience, target_platform, target_is_real_device, target_device_brand, target_ip_addresses, target_city, disappear_after_cta, repeat_session_interval, display_sequence, carousel_max_count, target_profession_exclude, target_speciality_exclude, target_degree_exclude, target_experience_exclude, target_country_exclude, target_city_exclude, target_incomplete_profile) FROM stdin;
ee5f3d93-6aa0-4c73-8a63-3551f59abdd5	Brief about yourself	Help us personalize your experience	\N	home_banner	high	user_insights	normal	all	none	\N	2025-12-12 21:27:00+00	\N	t	f	\N	\N	t	per_app_open	24	10	\N	t	t	live	\N	\N	\N	\N	t	f	{"cta_icon": "→", "cta_label": "Complete Profile", "thumbnail": "https://ocuhub.com/Icons/introduction.png", "survey_category": "survey", "survey_badge_text": "Get to Know You"}	[{"id": "q_1765575196587", "type": "single_choice", "images": [], "options": ["Ophthalmologist", "Optometrist", "Orthoptist", "GP", "Medical Student", "Other Healthcare Professional", "Not a Medical Professional"], "question": "What is your Profession ?", "required": true, "description": "", "responseActions": [{"actionType": "show_modal", "actionTitle": "", "actionValue": "OcuHub is for eye-care professionals. Please use the app for educational reference only and avoid using any tool for clinical decisions.", "triggerValue": "Not a Medical Professional"}], "linkToUserProfile": "profession"}, {"id": "q_1765580536433", "type": "single_choice", "options": ["Less than 1 year", "1-3 years", "3-5 years", "5-10 years", "10-20 years", "More than 20 years"], "question": "How many years of experience do you have in eye care?", "required": true, "description": "", "linkToUserProfile": "years_experience"}, {"id": "q_1765580684979", "type": "multiple_choice", "options": ["Pediatrics & Strabismus", "Cornea & Anterior Segment", "Glaucoma", "Vitreo-Retinal", "Oculoplastics", "Neuro-Ophthalmology", "General Ophthalmology", "Optometry", "None"], "question": "What Subspecialties are you interested in ? (Can select more than one)", "required": true, "description": "", "linkToUserProfile": "subspecialty"}, {"id": "q_1765580743982", "type": "single_choice", "options": ["Medical student", "Ophthalmology residency or general ophthalmology training", "Postgraduate ophthalmology training (specialist level, supervised practice)", "General ophthalmology practice (independent clinical role)", "Advanced subspecialty training (supervised clinical practice)", "Subspecialty practice (completed advanced training, independent role)", "Academic or research-focused role (PhD or equivalent)", "Other"], "question": "Which best describes your current clinical stage in ophthalmology?", "required": true, "description": "", "linkToUserProfile": "degree"}]	[]	2025-12-12 23:07:45.003189+00	2025-12-16 08:25:26.081086+00	f4271647-c15c-4776-be93-d46fe4185144	f4271647-c15c-4776-be93-d46fe4185144	1	remind_later	10	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	1	0	5	f	f	f	f	f	f	t
f80f08b4-63a9-43df-a7ab-10b82fc5635f	Not Completed Profile Logged in	Not Completed Profile Logged in	\N	home_banner	medium	announcement	normal	all	none	\N	2025-12-14 14:06:00+00	\N	t	f	\N	\N	t	per_app_open	24	10	\N	t	t	live	\N	\N	\N	\N	t	f	{"cta_icon": "→", "survey_category": "survey"}	[]	[]	2025-12-14 14:07:13.882589+00	2025-12-14 21:54:49.068656+00	f4271647-c15c-4776-be93-d46fe4185144	f4271647-c15c-4776-be93-d46fe4185144	1	yes	3	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	1	0	5	f	f	f	f	f	f	t
2e9ea271-7900-4959-9c1f-838e1585d433	Non Ophthalmologist	Non Ophthalmologist	\N	home_banner	medium	announcement	normal	all	none	\N	2025-12-14 14:06:00+00	\N	t	f	\N	\N	t	per_app_open	24	10	\N	t	t	live	\N	\N	\N	\N	f	f	{"cta_icon": "→", "survey_category": "survey"}	[]	[]	2025-12-14 15:00:48.382+00	2025-12-14 21:54:49.068656+00	f4271647-c15c-4776-be93-d46fe4185144	f4271647-c15c-4776-be93-d46fe4185144	1	yes	3	1	\N	\N	Ophthalmologist	\N	\N	\N	\N	\N	\N	\N	t	1	0	5	t	f	f	f	f	f	f
03f94895-b7d9-4ade-a818-8ddf801a679e	Get More from OcuHub	Sign in within seconds using Google sign in to save your favorites, sync preferences, and get the best OcuHub experience.	\N	home_banner	low	announcement	normal	all	open_screen	Login	2025-12-12 23:18:00+00	\N	t	f	\N	\N	f	per_app_open	24	10	\N	t	t	live	\N	\N	\N	\N	f	t	{"cta_icon": "→", "cta_label": "Sign in Now", "thumbnail": "https://ocuhub.com/Icons/cloud.png", "custom_color": "#874efe", "survey_category": "survey"}	[]	[]	2025-12-12 23:27:19.600057+00	2025-12-14 21:54:49.068656+00	f4271647-c15c-4776-be93-d46fe4185144	f4271647-c15c-4776-be93-d46fe4185144	1	no	10	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f	1	0	5	f	f	f	f	f	f	f
7fc073b6-d1fa-404e-b443-0fe4d1000f52	Test your Knowledge	What is the most likely Diagnosis for lid Lesion ?	\N	modal	medium	quiz	normal	all	none	\N	2025-12-13 18:49:00+00	\N	t	f	\N	\N	t	per_app_open	24	10	\N	t	t	live	\N	\N	\N	\N	f	f	{"cta_icon": "→", "cta_label": "Test yourself", "thumbnail": "https://eyewiki-images.s3.us-east-va.perf.cloud.ovh.us/8/80/Seborrheic_Blepharitis.jpg", "survey_category": "survey", "survey_badge_text": "Test Your Knowledge"}	[{"id": "q_1765652534217", "type": "single_choice", "images": ["https://eyewiki-images.s3.us-east-va.perf.cloud.ovh.us/8/80/Seborrheic_Blepharitis.jpg", "https://eyewiki-images.s3.us-east-va.perf.cloud.ovh.us/3/3f/Anterior_Blepharitis.jpg"], "options": ["Seborrheic Blepharitis", "Anterior Staphylococcal Blepharitis", "Posterior Blepharitis (MGD)", "Allergic Blepharitis"], "question": "", "required": true, "description": "A patient presents with eyelid scaling and irritation. Based on the image, what is the most likely diagnosis?", "correctAnswer": "Seborrheic Blepharitis", "feedbackWrong": {"actionType": "show_modal", "actionTitle": "Incorrect", "actionValue": "Review the eyelid margin findings and consider conditions associated with greasy scaling.\\n"}, "feedbackCorrect": {"actionType": "show_modal", "actionTitle": "Correct", "actionValue": "This appearance is typical of seborrheic blepharitis, characterized by greasy scales along the eyelid margins."}}]	[]	2025-12-13 19:10:14.180201+00	2025-12-15 13:28:43.592258+00	f4271647-c15c-4776-be93-d46fe4185144	f4271647-c15c-4776-be93-d46fe4185144	1	remind_later	10	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	1	0	5	f	f	f	f	f	f	f
\.


--
-- Data for Name: app_sessions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.app_sessions (id, user_id, auth_uid, start_time, end_time, public_ip, country, region, city, device_info, app_version, is_active, created_at, updated_at, is_synced, last_synced_at, os_platform, device_brand, device_model, is_device, device_type, os_version, is_location_live, last_live_location_fetched_at, fallback_location_used_at) FROM stdin;
\.


--
-- Data for Name: app_settings; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.app_settings (user_id, setting_key, auth_uid, setting_value, custom_settings, is_archived, last_updated, created_at, updated_at, is_synced, last_synced_at) FROM stdin;
6KAWj7gw9MUig2M8sK021ss8ilu2	default	6KAWj7gw9MUig2M8sK021ss8ilu2	{"display": {"theme": "light", "fontSize": "medium"}, "general": {"firstLaunch": true, "lastBackupDate": null, "tutorialCompleted": false}, "screenPPI": 140, "vaBadgeSize": "standard", "homeDefaultTab": "favourites", "homeToolsCount": 8, "kidsAutoChange": true, "screenDistance": 1.5, "preferredVALines": [{"feet": "20/200", "logMAR": 1, "metric": "6/60", "decimal": 0.1}, {"feet": "20/160", "logMAR": 0.9, "metric": "6/48", "decimal": 0.125}, {"feet": "20/125", "logMAR": 0.8, "metric": "6/37.5", "decimal": 0.16}, {"feet": "20/100", "logMAR": 0.7, "metric": "6/30", "decimal": 0.2}, {"feet": "20/80", "logMAR": 0.6, "metric": "6/24", "decimal": 0.25}, {"feet": "20/60", "logMAR": 0.48, "metric": "6/18", "decimal": 0.33}, {"feet": "20/50", "logMAR": 0.4, "metric": "6/15", "decimal": 0.4}, {"feet": "20/40", "logMAR": 0.3, "metric": "6/12", "decimal": 0.5}, {"feet": "20/30", "logMAR": 0.18, "metric": "6/9", "decimal": 0.67}, {"feet": "20/25", "logMAR": 0.1, "metric": "6/7.5", "decimal": 0.8}, {"feet": "20/20", "logMAR": 0, "metric": "6/6", "decimal": 1}], "visionToolsSound": false, "astigmaticFanSize": 0.95, "astigmaticFanStep": 10, "defaultVANotation": "decimal", "kidsFixationSound": false, "contrastTestVALine": 0.33, "lightTargetPattern": "fixed", "autoSavePreferences": true, "hasCalibratedScreen": false, "kidsAutoChangeTimer": 3, "lightTargetSpotSize": 95, "defaultRedFilterSide": "right", "preventScreenDimming": true, "nearVATestingDistance": 0.4, "screenBrightnessLevel": 1, "defaultCategoryExpansion": "last-used", "redGreenColorCalibration": null, "objectiveVATestingDistance": 0.6, "preferredRetinoscopyWorkingDistance": 0.67}	{"display": {"theme": "light", "fontSize": "medium"}, "general": {"firstLaunch": true, "lastBackupDate": null, "tutorialCompleted": false}, "screenPPI": 140, "vaBadgeSize": "standard", "homeDefaultTab": "favourites", "homeToolsCount": 8, "kidsAutoChange": true, "screenDistance": 1.5, "preferredVALines": [{"feet": "20/200", "logMAR": 1, "metric": "6/60", "decimal": 0.1}, {"feet": "20/160", "logMAR": 0.9, "metric": "6/48", "decimal": 0.125}, {"feet": "20/125", "logMAR": 0.8, "metric": "6/37.5", "decimal": 0.16}, {"feet": "20/100", "logMAR": 0.7, "metric": "6/30", "decimal": 0.2}, {"feet": "20/80", "logMAR": 0.6, "metric": "6/24", "decimal": 0.25}, {"feet": "20/60", "logMAR": 0.48, "metric": "6/18", "decimal": 0.33}, {"feet": "20/50", "logMAR": 0.4, "metric": "6/15", "decimal": 0.4}, {"feet": "20/40", "logMAR": 0.3, "metric": "6/12", "decimal": 0.5}, {"feet": "20/30", "logMAR": 0.18, "metric": "6/9", "decimal": 0.67}, {"feet": "20/25", "logMAR": 0.1, "metric": "6/7.5", "decimal": 0.8}, {"feet": "20/20", "logMAR": 0, "metric": "6/6", "decimal": 1}], "visionToolsSound": false, "astigmaticFanSize": 0.95, "astigmaticFanStep": 10, "defaultVANotation": "decimal", "kidsFixationSound": false, "contrastTestVALine": 0.33, "lightTargetPattern": "fixed", "autoSavePreferences": true, "hasCalibratedScreen": false, "kidsAutoChangeTimer": 3, "lightTargetSpotSize": 95, "defaultRedFilterSide": "right", "preventScreenDimming": true, "nearVATestingDistance": 0.4, "screenBrightnessLevel": 1, "defaultCategoryExpansion": "last-used", "redGreenColorCalibration": null, "objectiveVATestingDistance": 0.6, "preferredRetinoscopyWorkingDistance": 0.67}	f	2025-12-16 13:34:44.304+00	2025-12-16 13:14:39.896908+00	2025-12-16 13:35:03.151242+00	t	2025-12-16 13:35:02.746+00
\.


--
-- Data for Name: category_settings; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.category_settings (user_id, category_id, auth_uid, settings, sort_order, is_expanded, is_visible, is_archived, created_at, updated_at, is_synced, last_synced_at) FROM stdin;
\.


--
-- Data for Name: credit_asset_types; Type: TABLE DATA; Schema: public; Owner: postgres
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
-- Data for Name: credit_links; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.credit_links (id, site_id, title, url, author, description, sort_order, is_active, created_at, updated_at) FROM stdin;
9e69f0c5-e85b-4ca3-a87f-d14120ee6443	3efea691-607f-49ea-8119-ea6913b13a32	Introduction icon	https://www.flaticon.com/free-icon/introduction_6352943?term=introduce&page=1&position=21&origin=search&related_id=6352943	\N	\N	0	t	2025-12-13 16:23:22.248994+00	2025-12-13 16:23:22.248994+00
6c2367d2-8986-46fd-9e4b-2f7047158b31	3efea691-607f-49ea-8119-ea6913b13a32	LASIK Icon	https://www.flaticon.com/free-icon/lasik_2695547?term=lasik&page=1&position=8&origin=search&related_id=2695547	\N	\N	0	t	2025-12-13 16:23:51.808169+00	2025-12-13 16:23:51.808169+00
8c5eff3d-71f2-4089-b2b1-831d53b21620	3efea691-607f-49ea-8119-ea6913b13a32	Login Icon	https://www.flaticon.com/free-icon/cloud_5919385	\N	\N	0	t	2025-12-13 16:23:33.091796+00	2025-12-13 16:24:59.01028+00
\.


--
-- Data for Name: credit_sites; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.credit_sites (id, asset_type_id, name, display_name, website_url, attribution_format, description, logo_url, sort_order, is_active, created_at, updated_at) FROM stdin;
3efea691-607f-49ea-8119-ea6913b13a32	16225d44-5407-42c8-b0cd-a9afe1d8610e	Aficons studio - Flaticon	Aficons studio - Flaticon	https://www.flaticon.com	\N	Free vector icons	\N	1	t	2025-12-13 16:11:58.226231+00	2025-12-13 16:20:11.612597+00
\.


--
-- Data for Name: feedbacks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.feedbacks (id, user_id, auth_uid, type, message, tool_id, screen_state, conclusion_data, rating, metadata, submitted_at, created_at, updated_at, is_synced, last_synced_at) FROM stdin;
\.


--
-- Data for Name: screen_settings; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.screen_settings (user_id, screen_id, auth_uid, settings, is_archived, created_at, updated_at, is_synced, last_synced_at) FROM stdin;
\.


--
-- Data for Name: section_settings; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.section_settings (user_id, section_id, auth_uid, settings, filters, is_archived, last_updated, created_at, updated_at, is_synced, last_synced_at) FROM stdin;
6KAWj7gw9MUig2M8sK021ss8ilu2	vision-tools	6KAWj7gw9MUig2M8sK021ss8ilu2	\N	{"sortOption": "default", "searchQuery": "", "showFavoritesOnly": false}	f	2025-12-16 13:34:34.08+00	2025-12-16 13:35:03.397765+00	2025-12-16 13:35:03.397765+00	t	2025-12-16 13:35:03.039+00
6KAWj7gw9MUig2M8sK021ss8ilu2	decision-support	6KAWj7gw9MUig2M8sK021ss8ilu2	\N	{"sortOption": "default", "searchQuery": "", "showFavoritesOnly": false}	f	2025-12-16 13:34:34.698+00	2025-12-16 13:35:03.397765+00	2025-12-16 13:35:03.397765+00	t	2025-12-16 13:35:03.039+00
\.


--
-- Data for Name: tool_settings; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tool_settings (user_id, tool_id, auth_uid, settings, is_favourite, order_in_app, order_in_category, order_in_section, usage_count, usage_duration_sec, last_used_at, is_archived, last_updated, created_at, updated_at, is_synced, last_synced_at) FROM stdin;
\.


--
-- Data for Name: tool_usage_events; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tool_usage_events (id, user_id, auth_uid, tool_id, tool_session_id, app_session_id, event_type, event_timestamp, event_data, created_at, is_synced, last_synced_at) FROM stdin;
\.


--
-- Data for Name: tool_usage_summary; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tool_usage_summary (id, tool_slug, tool_name, usage_count, total_duration_seconds, days_used, months_used, years_used, last_used_at, unique_users, session_count, country_count, city_count, avg_usage_per_user, avg_time_per_user_seconds, avg_calc_time_ms, usage_by_date, duration_by_date, country_breakdown, updated_at) FROM stdin;
\.


--
-- Data for Name: user_announcement_state; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_announcement_state (id, announcement_id, user_id, status, first_seen_at, last_seen_at, dismissed_at, deferred_at, completed_at, defer_count, defer_until_session, defer_until_time, impression_count, is_partially_completed, questions_answered, created_at, updated_at, last_seen_session) FROM stdin;
ab67f75b-13a7-40a4-a826-e28a41a237d4	03f94895-b7d9-4ade-a818-8ddf801a679e	zW7dvZksmlYOp6j7siiY0pqmpj32	dismissed	2025-12-16 13:04:47.210557+00	2025-12-16 13:15:07.279897+00	2025-12-16 13:15:07.279897+00	\N	\N	0	\N	\N	3	f	0	2025-12-16 13:04:47.210557+00	2025-12-16 13:15:07.279897+00	4
24381b3c-9bb7-4bac-ac40-609ba736f2b2	2e9ea271-7900-4959-9c1f-838e1585d433	zW7dvZksmlYOp6j7siiY0pqmpj32	seen	2025-12-16 13:14:39.712031+00	2025-12-16 13:15:23.442304+00	\N	\N	\N	0	\N	\N	4	f	0	2025-12-16 13:14:39.712031+00	2025-12-16 13:15:23.442304+00	0
4d068892-4866-48c5-b4bd-9b40b819a4d4	7fc073b6-d1fa-404e-b443-0fe4d1000f52	zW7dvZksmlYOp6j7siiY0pqmpj32	completed	2025-12-16 13:04:44.032233+00	2025-12-16 13:15:27.970652+00	\N	2025-12-16 13:14:49.116214+00	2025-12-16 13:15:27.970652+00	3	4	\N	13	f	1	2025-12-16 13:04:44.032233+00	2025-12-16 13:15:27.970652+00	5
bf4d6ed7-6c0a-4045-ac04-027cb8919f6c	7fc073b6-d1fa-404e-b443-0fe4d1000f52	6KAWj7gw9MUig2M8sK021ss8ilu2	completed	\N	2025-12-16 13:16:09.70054+00	\N	\N	2025-12-16 13:16:09.70054+00	0	\N	\N	4	f	0	2025-12-16 13:16:06.888631+00	2025-12-16 13:16:09.70054+00	7
551ae5a1-0d1f-4787-aedb-98de6bae1536	ee5f3d93-6aa0-4c73-8a63-3551f59abdd5	6KAWj7gw9MUig2M8sK021ss8ilu2	completed	2025-12-16 13:15:39.653525+00	2025-12-16 13:16:10.117174+00	2025-12-16 13:15:55.792218+00	\N	2025-12-16 13:16:10.117174+00	0	\N	\N	8	f	4	2025-12-16 13:15:39.653525+00	2025-12-16 13:16:10.117174+00	7
05c8e5a9-62a4-4c56-a21c-43dbb91a1c97	7fc073b6-d1fa-404e-b443-0fe4d1000f52	1B2ODRkAWmZsf8eUn5xmPK32ZPw1	deferred	2025-12-16 13:16:38.055024+00	2025-12-16 13:16:40.78466+00	\N	2025-12-16 13:16:40.78466+00	\N	1	2	\N	2	f	0	2025-12-16 13:16:38.055024+00	2025-12-16 13:16:40.78466+00	1
7ea4eff4-d265-401a-ab63-f059e0857eed	2e9ea271-7900-4959-9c1f-838e1585d433	1B2ODRkAWmZsf8eUn5xmPK32ZPw1	seen	2025-12-16 13:16:41.192366+00	2025-12-16 13:16:41.192366+00	\N	\N	\N	0	\N	\N	1	f	0	2025-12-16 13:16:41.192366+00	2025-12-16 13:16:41.192366+00	0
9ac0b413-4665-4e71-9873-5c278ef2b2c8	03f94895-b7d9-4ade-a818-8ddf801a679e	1B2ODRkAWmZsf8eUn5xmPK32ZPw1	dismissed	\N	2025-12-16 13:16:46.477915+00	2025-12-16 13:16:46.477915+00	\N	\N	0	\N	\N	1	f	0	2025-12-16 13:16:46.477915+00	2025-12-16 13:16:46.477915+00	1
222ce075-e73c-4922-8082-ae4622ce08fd	2e9ea271-7900-4959-9c1f-838e1585d433	6KAWj7gw9MUig2M8sK021ss8ilu2	seen	2025-12-16 13:17:58.805642+00	2025-12-16 13:17:58.805642+00	\N	\N	\N	0	\N	\N	1	f	0	2025-12-16 13:17:58.805642+00	2025-12-16 13:17:58.805642+00	0
0768be5e-e375-4cf1-a420-f687442af001	7fc073b6-d1fa-404e-b443-0fe4d1000f52	VLQvw8gWIbVGYKnFiPGkHpvNsq43	deferred	2025-12-16 13:30:25.15583+00	2025-12-16 13:30:28.330918+00	\N	2025-12-16 13:30:28.330918+00	\N	1	2	\N	2	f	0	2025-12-16 13:30:25.15583+00	2025-12-16 13:30:28.330918+00	1
cf6312dd-e09e-4cbd-bfda-258338d09c92	2e9ea271-7900-4959-9c1f-838e1585d433	VLQvw8gWIbVGYKnFiPGkHpvNsq43	seen	2025-12-16 13:30:28.428882+00	2025-12-16 13:30:28.428882+00	\N	\N	\N	0	\N	\N	1	f	0	2025-12-16 13:30:28.428882+00	2025-12-16 13:30:28.428882+00	0
17178376-f26e-4ae1-9d6b-60f029042acf	7fc073b6-d1fa-404e-b443-0fe4d1000f52	BFX6sQQSoahsDrm2GASnk52wYMj1	deferred	2025-12-16 13:33:43.793616+00	2025-12-16 13:33:46.299628+00	\N	2025-12-16 13:33:46.299628+00	\N	1	2	\N	2	f	0	2025-12-16 13:33:43.793616+00	2025-12-16 13:33:46.299628+00	1
34be412d-e40b-4c30-934c-b984eac5d544	2e9ea271-7900-4959-9c1f-838e1585d433	BFX6sQQSoahsDrm2GASnk52wYMj1	seen	2025-12-16 13:33:47.075504+00	2025-12-16 13:33:47.075504+00	\N	\N	\N	0	\N	\N	1	f	0	2025-12-16 13:33:47.075504+00	2025-12-16 13:33:47.075504+00	0
bab177ba-af5e-41d4-b2ed-84ac14f93fc1	03f94895-b7d9-4ade-a818-8ddf801a679e	BFX6sQQSoahsDrm2GASnk52wYMj1	dismissed	\N	2025-12-16 13:33:48.812597+00	2025-12-16 13:33:48.812597+00	\N	\N	0	\N	\N	1	f	0	2025-12-16 13:33:48.812597+00	2025-12-16 13:33:48.812597+00	1
\.


--
-- Data for Name: user_sync_states; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_sync_states (id, user_id, auth_uid, email, decision, reason, decision_at, device_info, archived_previous_settings) FROM stdin;
\.


--
-- Data for Name: user_usage_summary; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_usage_summary (user_id, full_name, email, country, city, total_sessions, most_used_tool, tools, locations, updated_at) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (auth_uid, user_id, email, name, image_uri, is_verified, is_anonymous, login_method, insights, created_at, updated_at, is_synced, last_synced_at, last_country, last_city, last_platform, last_device_brand, last_is_real_device, last_ip, last_location_updated_at) FROM stdin;
BFX6sQQSoahsDrm2GASnk52wYMj1	BFX6sQQSoahsDrm2GASnk52wYMj1	\N	\N	\N	t	f	firebase	{}	2025-12-16 13:33:42.024+00	2025-12-16 13:33:46.140003+00	t	2025-12-16 13:33:45.769+00	\N	\N	\N	\N	\N	\N	\N
VLQvw8gWIbVGYKnFiPGkHpvNsq43	VLQvw8gWIbVGYKnFiPGkHpvNsq43	\N	\N	\N	t	f	firebase	{}	2025-12-16 13:30:22.842+00	2025-12-16 13:30:26.751704+00	t	2025-12-16 13:30:26.367+00	\N	\N	\N	\N	\N	\N	\N
1B2ODRkAWmZsf8eUn5xmPK32ZPw1	1B2ODRkAWmZsf8eUn5xmPK32ZPw1	\N	\N	\N	t	f	firebase	{}	2025-12-16 13:16:36.389+00	2025-12-16 13:16:40.680406+00	t	2025-12-16 13:16:40.331+00	\N	\N	\N	\N	\N	\N	\N
6KAWj7gw9MUig2M8sK021ss8ilu2	6KAWj7gw9MUig2M8sK021ss8ilu2	egyeast@gmail.com	Ehab Sultan	https://lh3.googleusercontent.com/a/ACg8ocK-Cq4_0pr-RXTMc80RtDFn741ZWwWp3vDUIZkfSgFYJIBsJ1s7=s96-c	t	f	firebase	{"degree": "Subspecialty practice (completed advanced training, independent role)", "profession": "Ophthalmologist", "updated_at": "2025-12-16T13:18:07.250Z", "subspecialty": "Pediatrics & Strabismus", "years_experience": "10-20 years", "degree_updated_at": "2025-12-16T13:15:54.074Z", "profession_updated_at": "2025-12-16T13:15:54.074Z", "subspecialty_updated_at": "2025-12-16T13:15:54.074Z", "years_experience_updated_at": "2025-12-16T13:15:54.074Z"}	2025-12-16 13:33:56.453+00	2025-12-16 13:35:02.889886+00	t	2025-12-16 13:35:02.502+00	\N	\N	\N	\N	\N	\N	\N
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: realtime; Owner: supabase_admin
--

COPY realtime.schema_migrations (version, inserted_at) FROM stdin;
20211116024918	2025-07-19 21:28:26
20211116045059	2025-07-19 21:28:29
20211116050929	2025-07-19 21:28:30
20211116051442	2025-07-19 21:28:32
20211116212300	2025-07-19 21:28:34
20211116213355	2025-07-19 21:28:35
20211116213934	2025-07-19 21:28:37
20211116214523	2025-07-19 21:28:39
20211122062447	2025-07-19 21:28:41
20211124070109	2025-07-19 21:28:42
20211202204204	2025-07-19 21:28:44
20211202204605	2025-07-19 21:28:45
20211210212804	2025-07-19 21:28:50
20211228014915	2025-07-19 21:28:52
20220107221237	2025-07-19 21:28:54
20220228202821	2025-07-19 21:28:55
20220312004840	2025-07-19 21:28:57
20220603231003	2025-07-19 21:28:59
20220603232444	2025-07-19 21:29:01
20220615214548	2025-07-19 21:29:03
20220712093339	2025-07-19 21:29:04
20220908172859	2025-07-19 21:29:06
20220916233421	2025-07-19 21:29:08
20230119133233	2025-07-19 21:29:09
20230128025114	2025-07-19 21:29:11
20230128025212	2025-07-19 21:29:13
20230227211149	2025-07-19 21:29:14
20230228184745	2025-07-19 21:29:16
20230308225145	2025-07-19 21:29:18
20230328144023	2025-07-19 21:29:19
20231018144023	2025-07-19 21:29:21
20231204144023	2025-07-19 21:29:24
20231204144024	2025-07-19 21:29:25
20231204144025	2025-07-19 21:29:27
20240108234812	2025-07-19 21:29:28
20240109165339	2025-07-19 21:29:30
20240227174441	2025-07-19 21:29:33
20240311171622	2025-07-19 21:29:35
20240321100241	2025-07-19 21:29:38
20240401105812	2025-07-19 21:29:43
20240418121054	2025-07-19 21:29:45
20240523004032	2025-07-19 21:29:51
20240618124746	2025-07-19 21:29:52
20240801235015	2025-07-19 21:29:54
20240805133720	2025-07-19 21:29:56
20240827160934	2025-07-19 21:29:57
20240919163303	2025-07-19 21:29:59
20240919163305	2025-07-19 21:30:01
20241019105805	2025-07-19 21:30:02
20241030150047	2025-07-19 21:30:08
20241108114728	2025-07-19 21:30:11
20241121104152	2025-07-19 21:30:12
20241130184212	2025-07-19 21:30:14
20241220035512	2025-07-19 21:30:16
20241220123912	2025-07-19 21:30:17
20241224161212	2025-07-19 21:30:19
20250107150512	2025-07-19 21:30:20
20250110162412	2025-07-19 21:30:22
20250123174212	2025-07-19 21:30:24
20250128220012	2025-07-19 21:30:25
20250506224012	2025-07-19 21:30:26
20250523164012	2025-07-19 21:30:28
20250714121412	2025-07-19 21:30:30
20250905041441	2025-10-10 22:08:34
20251103001201	2025-11-15 15:07:05
\.


--
-- Data for Name: subscription; Type: TABLE DATA; Schema: realtime; Owner: supabase_admin
--

COPY realtime.subscription (id, subscription_id, entity, filters, claims, created_at) FROM stdin;
\.


--
-- Data for Name: buckets; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

COPY storage.buckets (id, name, owner, created_at, updated_at, public, avif_autodetection, file_size_limit, allowed_mime_types, owner_id, type) FROM stdin;
\.


--
-- Data for Name: buckets_analytics; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

COPY storage.buckets_analytics (name, type, format, created_at, updated_at, id, deleted_at) FROM stdin;
\.


--
-- Data for Name: buckets_vectors; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

COPY storage.buckets_vectors (id, type, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: migrations; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

COPY storage.migrations (id, name, hash, executed_at) FROM stdin;
0	create-migrations-table	e18db593bcde2aca2a408c4d1100f6abba2195df	2025-07-19 21:28:24.084902
1	initialmigration	6ab16121fbaa08bbd11b712d05f358f9b555d777	2025-07-19 21:28:24.092188
2	storage-schema	5c7968fd083fcea04050c1b7f6253c9771b99011	2025-07-19 21:28:24.096557
3	pathtoken-column	2cb1b0004b817b29d5b0a971af16bafeede4b70d	2025-07-19 21:28:24.113621
4	add-migrations-rls	427c5b63fe1c5937495d9c635c263ee7a5905058	2025-07-19 21:28:24.12506
5	add-size-functions	79e081a1455b63666c1294a440f8ad4b1e6a7f84	2025-07-19 21:28:24.13074
6	change-column-name-in-get-size	f93f62afdf6613ee5e7e815b30d02dc990201044	2025-07-19 21:28:24.135925
7	add-rls-to-buckets	e7e7f86adbc51049f341dfe8d30256c1abca17aa	2025-07-19 21:28:24.142483
8	add-public-to-buckets	fd670db39ed65f9d08b01db09d6202503ca2bab3	2025-07-19 21:28:24.146993
9	fix-search-function	3a0af29f42e35a4d101c259ed955b67e1bee6825	2025-07-19 21:28:24.154309
10	search-files-search-function	68dc14822daad0ffac3746a502234f486182ef6e	2025-07-19 21:28:24.162249
11	add-trigger-to-auto-update-updated_at-column	7425bdb14366d1739fa8a18c83100636d74dcaa2	2025-07-19 21:28:24.169093
12	add-automatic-avif-detection-flag	8e92e1266eb29518b6a4c5313ab8f29dd0d08df9	2025-07-19 21:28:24.1765
13	add-bucket-custom-limits	cce962054138135cd9a8c4bcd531598684b25e7d	2025-07-19 21:28:24.18242
14	use-bytes-for-max-size	941c41b346f9802b411f06f30e972ad4744dad27	2025-07-19 21:28:24.188871
15	add-can-insert-object-function	934146bc38ead475f4ef4b555c524ee5d66799e5	2025-07-19 21:28:24.206344
16	add-version	76debf38d3fd07dcfc747ca49096457d95b1221b	2025-07-19 21:28:24.210957
17	drop-owner-foreign-key	f1cbb288f1b7a4c1eb8c38504b80ae2a0153d101	2025-07-19 21:28:24.215534
18	add_owner_id_column_deprecate_owner	e7a511b379110b08e2f214be852c35414749fe66	2025-07-19 21:28:24.220564
19	alter-default-value-objects-id	02e5e22a78626187e00d173dc45f58fa66a4f043	2025-07-19 21:28:24.226325
20	list-objects-with-delimiter	cd694ae708e51ba82bf012bba00caf4f3b6393b7	2025-07-19 21:28:24.231469
21	s3-multipart-uploads	8c804d4a566c40cd1e4cc5b3725a664a9303657f	2025-07-19 21:28:24.238577
22	s3-multipart-uploads-big-ints	9737dc258d2397953c9953d9b86920b8be0cdb73	2025-07-19 21:28:24.250528
23	optimize-search-function	9d7e604cddc4b56a5422dc68c9313f4a1b6f132c	2025-07-19 21:28:24.261213
24	operation-function	8312e37c2bf9e76bbe841aa5fda889206d2bf8aa	2025-07-19 21:28:24.266318
25	custom-metadata	d974c6057c3db1c1f847afa0e291e6165693b990	2025-07-19 21:28:24.272096
26	objects-prefixes	ef3f7871121cdc47a65308e6702519e853422ae2	2025-08-26 06:26:26.935269
27	search-v2	33b8f2a7ae53105f028e13e9fcda9dc4f356b4a2	2025-08-26 06:26:27.638902
28	object-bucket-name-sorting	ba85ec41b62c6a30a3f136788227ee47f311c436	2025-08-26 06:26:27.836595
29	create-prefixes	a7b1a22c0dc3ab630e3055bfec7ce7d2045c5b7b	2025-08-26 06:26:28.541078
30	update-object-levels	6c6f6cc9430d570f26284a24cf7b210599032db7	2025-08-26 06:26:28.731659
31	objects-level-index	33f1fef7ec7fea08bb892222f4f0f5d79bab5eb8	2025-08-26 06:26:29.140116
32	backward-compatible-index-on-objects	2d51eeb437a96868b36fcdfb1ddefdf13bef1647	2025-08-26 06:26:29.338537
33	backward-compatible-index-on-prefixes	fe473390e1b8c407434c0e470655945b110507bf	2025-08-26 06:26:29.729165
34	optimize-search-function-v1	82b0e469a00e8ebce495e29bfa70a0797f7ebd2c	2025-08-26 06:26:30.036703
35	add-insert-trigger-prefixes	63bb9fd05deb3dc5e9fa66c83e82b152f0caf589	2025-08-26 06:26:30.750743
36	optimise-existing-functions	81cf92eb0c36612865a18016a38496c530443899	2025-08-26 06:26:31.237881
37	add-bucket-name-length-trigger	3944135b4e3e8b22d6d4cbb568fe3b0b51df15c1	2025-08-26 06:26:31.438604
38	iceberg-catalog-flag-on-buckets	19a8bd89d5dfa69af7f222a46c726b7c41e462c5	2025-08-26 06:26:31.52937
39	add-search-v2-sort-support	39cf7d1e6bf515f4b02e41237aba845a7b492853	2025-10-04 18:50:07.166601
40	fix-prefix-race-conditions-optimized	fd02297e1c67df25a9fc110bf8c8a9af7fb06d1f	2025-10-04 18:50:07.305686
41	add-object-level-update-trigger	44c22478bf01744b2129efc480cd2edc9a7d60e9	2025-10-04 18:50:07.361082
42	rollback-prefix-triggers	f2ab4f526ab7f979541082992593938c05ee4b47	2025-10-04 18:50:07.372118
43	fix-object-level	ab837ad8f1c7d00cc0b7310e989a23388ff29fc6	2025-10-04 18:50:07.389933
44	vector-bucket-type	99c20c0ffd52bb1ff1f32fb992f3b351e3ef8fb3	2025-11-17 22:47:31.941252
45	vector-buckets	049e27196d77a7cb76497a85afae669d8b230953	2025-11-17 22:47:31.95202
46	buckets-objects-grants	fedeb96d60fefd8e02ab3ded9fbde05632f84aed	2025-11-17 22:47:31.972045
47	iceberg-table-metadata	649df56855c24d8b36dd4cc1aeb8251aa9ad42c2	2025-11-17 22:47:31.976592
48	iceberg-catalog-ids	2666dff93346e5d04e0a878416be1d5fec345d6f	2025-11-17 22:47:31.980794
\.


--
-- Data for Name: objects; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

COPY storage.objects (id, bucket_id, name, owner, created_at, updated_at, last_accessed_at, metadata, version, owner_id, user_metadata, level) FROM stdin;
\.


--
-- Data for Name: prefixes; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

COPY storage.prefixes (bucket_id, name, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: s3_multipart_uploads; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

COPY storage.s3_multipart_uploads (id, in_progress_size, upload_signature, bucket_id, key, version, owner_id, created_at, user_metadata) FROM stdin;
\.


--
-- Data for Name: s3_multipart_uploads_parts; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

COPY storage.s3_multipart_uploads_parts (id, upload_id, size, part_number, bucket_id, key, etag, owner_id, version, created_at) FROM stdin;
\.


--
-- Data for Name: vector_indexes; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

COPY storage.vector_indexes (id, name, bucket_id, data_type, dimension, distance_metric, metadata_configuration, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: secrets; Type: TABLE DATA; Schema: vault; Owner: supabase_admin
--

COPY vault.secrets (id, name, description, secret, key_id, nonce, created_at, updated_at) FROM stdin;
\.


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE SET; Schema: auth; Owner: supabase_auth_admin
--

SELECT pg_catalog.setval('auth.refresh_tokens_id_seq', 67, true);


--
-- Name: subscription_id_seq; Type: SEQUENCE SET; Schema: realtime; Owner: supabase_admin
--

SELECT pg_catalog.setval('realtime.subscription_id_seq', 1, false);


--
-- Name: mfa_amr_claims amr_id_pk; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT amr_id_pk PRIMARY KEY (id);


--
-- Name: audit_log_entries audit_log_entries_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.audit_log_entries
    ADD CONSTRAINT audit_log_entries_pkey PRIMARY KEY (id);


--
-- Name: flow_state flow_state_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.flow_state
    ADD CONSTRAINT flow_state_pkey PRIMARY KEY (id);


--
-- Name: identities identities_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_pkey PRIMARY KEY (id);


--
-- Name: identities identities_provider_id_provider_unique; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_provider_id_provider_unique UNIQUE (provider_id, provider);


--
-- Name: instances instances_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.instances
    ADD CONSTRAINT instances_pkey PRIMARY KEY (id);


--
-- Name: mfa_amr_claims mfa_amr_claims_session_id_authentication_method_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT mfa_amr_claims_session_id_authentication_method_pkey UNIQUE (session_id, authentication_method);


--
-- Name: mfa_challenges mfa_challenges_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_challenges
    ADD CONSTRAINT mfa_challenges_pkey PRIMARY KEY (id);


--
-- Name: mfa_factors mfa_factors_last_challenged_at_key; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_last_challenged_at_key UNIQUE (last_challenged_at);


--
-- Name: mfa_factors mfa_factors_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_pkey PRIMARY KEY (id);


--
-- Name: oauth_authorizations oauth_authorizations_authorization_code_key; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_authorization_code_key UNIQUE (authorization_code);


--
-- Name: oauth_authorizations oauth_authorizations_authorization_id_key; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_authorization_id_key UNIQUE (authorization_id);


--
-- Name: oauth_authorizations oauth_authorizations_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_pkey PRIMARY KEY (id);


--
-- Name: oauth_client_states oauth_client_states_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.oauth_client_states
    ADD CONSTRAINT oauth_client_states_pkey PRIMARY KEY (id);


--
-- Name: oauth_clients oauth_clients_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.oauth_clients
    ADD CONSTRAINT oauth_clients_pkey PRIMARY KEY (id);


--
-- Name: oauth_consents oauth_consents_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.oauth_consents
    ADD CONSTRAINT oauth_consents_pkey PRIMARY KEY (id);


--
-- Name: oauth_consents oauth_consents_user_client_unique; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.oauth_consents
    ADD CONSTRAINT oauth_consents_user_client_unique UNIQUE (user_id, client_id);


--
-- Name: one_time_tokens one_time_tokens_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.one_time_tokens
    ADD CONSTRAINT one_time_tokens_pkey PRIMARY KEY (id);


--
-- Name: refresh_tokens refresh_tokens_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_pkey PRIMARY KEY (id);


--
-- Name: refresh_tokens refresh_tokens_token_unique; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_token_unique UNIQUE (token);


--
-- Name: saml_providers saml_providers_entity_id_key; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_entity_id_key UNIQUE (entity_id);


--
-- Name: saml_providers saml_providers_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_pkey PRIMARY KEY (id);


--
-- Name: saml_relay_states saml_relay_states_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: sso_domains sso_domains_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sso_domains
    ADD CONSTRAINT sso_domains_pkey PRIMARY KEY (id);


--
-- Name: sso_providers sso_providers_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sso_providers
    ADD CONSTRAINT sso_providers_pkey PRIMARY KEY (id);


--
-- Name: users users_phone_key; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_phone_key UNIQUE (phone);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: admin_users admin_users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.admin_users
    ADD CONSTRAINT admin_users_pkey PRIMARY KEY (id);


--
-- Name: announcement_config announcement_config_config_key_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.announcement_config
    ADD CONSTRAINT announcement_config_config_key_key UNIQUE (config_key);


--
-- Name: announcement_config announcement_config_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.announcement_config
    ADD CONSTRAINT announcement_config_pkey PRIMARY KEY (id);


--
-- Name: announcement_impressions announcement_impressions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.announcement_impressions
    ADD CONSTRAINT announcement_impressions_pkey PRIMARY KEY (id);


--
-- Name: announcement_responses announcement_responses_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.announcement_responses
    ADD CONSTRAINT announcement_responses_pkey PRIMARY KEY (id);


--
-- Name: announcement_responses announcement_responses_unique_user_response; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.announcement_responses
    ADD CONSTRAINT announcement_responses_unique_user_response UNIQUE (announcement_id, question_id, user_auth_uid);


--
-- Name: announcements announcements_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.announcements
    ADD CONSTRAINT announcements_pkey PRIMARY KEY (id);


--
-- Name: app_sessions app_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.app_sessions
    ADD CONSTRAINT app_sessions_pkey PRIMARY KEY (id);


--
-- Name: app_settings app_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.app_settings
    ADD CONSTRAINT app_settings_pkey PRIMARY KEY (user_id, setting_key);


--
-- Name: category_settings category_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.category_settings
    ADD CONSTRAINT category_settings_pkey PRIMARY KEY (user_id, category_id);


--
-- Name: credit_asset_types credit_asset_types_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.credit_asset_types
    ADD CONSTRAINT credit_asset_types_name_key UNIQUE (name);


--
-- Name: credit_asset_types credit_asset_types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.credit_asset_types
    ADD CONSTRAINT credit_asset_types_pkey PRIMARY KEY (id);


--
-- Name: credit_links credit_links_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.credit_links
    ADD CONSTRAINT credit_links_pkey PRIMARY KEY (id);


--
-- Name: credit_sites credit_sites_asset_type_id_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.credit_sites
    ADD CONSTRAINT credit_sites_asset_type_id_name_key UNIQUE (asset_type_id, name);


--
-- Name: credit_sites credit_sites_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.credit_sites
    ADD CONSTRAINT credit_sites_pkey PRIMARY KEY (id);


--
-- Name: feedbacks feedbacks_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.feedbacks
    ADD CONSTRAINT feedbacks_pkey PRIMARY KEY (id);


--
-- Name: announcement_impressions impressions_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.announcement_impressions
    ADD CONSTRAINT impressions_unique UNIQUE (announcement_id, user_id);


--
-- Name: screen_settings screen_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.screen_settings
    ADD CONSTRAINT screen_settings_pkey PRIMARY KEY (user_id, screen_id);


--
-- Name: section_settings section_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.section_settings
    ADD CONSTRAINT section_settings_pkey PRIMARY KEY (user_id, section_id);


--
-- Name: tool_settings tool_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tool_settings
    ADD CONSTRAINT tool_settings_pkey PRIMARY KEY (user_id, tool_id);


--
-- Name: tool_usage_events tool_usage_events_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tool_usage_events
    ADD CONSTRAINT tool_usage_events_pkey PRIMARY KEY (id);


--
-- Name: tool_usage_summary tool_usage_summary_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tool_usage_summary
    ADD CONSTRAINT tool_usage_summary_pkey PRIMARY KEY (id);


--
-- Name: user_announcement_state user_announcement_state_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_announcement_state
    ADD CONSTRAINT user_announcement_state_pkey PRIMARY KEY (id);


--
-- Name: user_announcement_state user_announcement_state_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_announcement_state
    ADD CONSTRAINT user_announcement_state_unique UNIQUE (announcement_id, user_id);


--
-- Name: user_sync_states user_sync_states_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_sync_states
    ADD CONSTRAINT user_sync_states_pkey PRIMARY KEY (id);


--
-- Name: user_usage_summary user_usage_summary_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_usage_summary
    ADD CONSTRAINT user_usage_summary_pkey PRIMARY KEY (user_id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (auth_uid);


--
-- Name: users users_user_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_user_id_key UNIQUE (user_id);


--
-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER TABLE ONLY realtime.messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id, inserted_at);


--
-- Name: subscription pk_subscription; Type: CONSTRAINT; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.subscription
    ADD CONSTRAINT pk_subscription PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: buckets_analytics buckets_analytics_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.buckets_analytics
    ADD CONSTRAINT buckets_analytics_pkey PRIMARY KEY (id);


--
-- Name: buckets buckets_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.buckets
    ADD CONSTRAINT buckets_pkey PRIMARY KEY (id);


--
-- Name: buckets_vectors buckets_vectors_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.buckets_vectors
    ADD CONSTRAINT buckets_vectors_pkey PRIMARY KEY (id);


--
-- Name: migrations migrations_name_key; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.migrations
    ADD CONSTRAINT migrations_name_key UNIQUE (name);


--
-- Name: migrations migrations_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.migrations
    ADD CONSTRAINT migrations_pkey PRIMARY KEY (id);


--
-- Name: objects objects_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.objects
    ADD CONSTRAINT objects_pkey PRIMARY KEY (id);


--
-- Name: prefixes prefixes_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.prefixes
    ADD CONSTRAINT prefixes_pkey PRIMARY KEY (bucket_id, level, name);


--
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.s3_multipart_uploads_parts
    ADD CONSTRAINT s3_multipart_uploads_parts_pkey PRIMARY KEY (id);


--
-- Name: s3_multipart_uploads s3_multipart_uploads_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.s3_multipart_uploads
    ADD CONSTRAINT s3_multipart_uploads_pkey PRIMARY KEY (id);


--
-- Name: vector_indexes vector_indexes_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.vector_indexes
    ADD CONSTRAINT vector_indexes_pkey PRIMARY KEY (id);


--
-- Name: audit_logs_instance_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX audit_logs_instance_id_idx ON auth.audit_log_entries USING btree (instance_id);


--
-- Name: confirmation_token_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX confirmation_token_idx ON auth.users USING btree (confirmation_token) WHERE ((confirmation_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: email_change_token_current_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX email_change_token_current_idx ON auth.users USING btree (email_change_token_current) WHERE ((email_change_token_current)::text !~ '^[0-9 ]*$'::text);


--
-- Name: email_change_token_new_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX email_change_token_new_idx ON auth.users USING btree (email_change_token_new) WHERE ((email_change_token_new)::text !~ '^[0-9 ]*$'::text);


--
-- Name: factor_id_created_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX factor_id_created_at_idx ON auth.mfa_factors USING btree (user_id, created_at);


--
-- Name: flow_state_created_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX flow_state_created_at_idx ON auth.flow_state USING btree (created_at DESC);


--
-- Name: identities_email_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX identities_email_idx ON auth.identities USING btree (email text_pattern_ops);


--
-- Name: INDEX identities_email_idx; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON INDEX auth.identities_email_idx IS 'Auth: Ensures indexed queries on the email column';


--
-- Name: identities_user_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX identities_user_id_idx ON auth.identities USING btree (user_id);


--
-- Name: idx_auth_code; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX idx_auth_code ON auth.flow_state USING btree (auth_code);


--
-- Name: idx_oauth_client_states_created_at; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX idx_oauth_client_states_created_at ON auth.oauth_client_states USING btree (created_at);


--
-- Name: idx_user_id_auth_method; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX idx_user_id_auth_method ON auth.flow_state USING btree (user_id, authentication_method);


--
-- Name: mfa_challenge_created_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX mfa_challenge_created_at_idx ON auth.mfa_challenges USING btree (created_at DESC);


--
-- Name: mfa_factors_user_friendly_name_unique; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX mfa_factors_user_friendly_name_unique ON auth.mfa_factors USING btree (friendly_name, user_id) WHERE (TRIM(BOTH FROM friendly_name) <> ''::text);


--
-- Name: mfa_factors_user_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX mfa_factors_user_id_idx ON auth.mfa_factors USING btree (user_id);


--
-- Name: oauth_auth_pending_exp_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX oauth_auth_pending_exp_idx ON auth.oauth_authorizations USING btree (expires_at) WHERE (status = 'pending'::auth.oauth_authorization_status);


--
-- Name: oauth_clients_deleted_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX oauth_clients_deleted_at_idx ON auth.oauth_clients USING btree (deleted_at);


--
-- Name: oauth_consents_active_client_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX oauth_consents_active_client_idx ON auth.oauth_consents USING btree (client_id) WHERE (revoked_at IS NULL);


--
-- Name: oauth_consents_active_user_client_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX oauth_consents_active_user_client_idx ON auth.oauth_consents USING btree (user_id, client_id) WHERE (revoked_at IS NULL);


--
-- Name: oauth_consents_user_order_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX oauth_consents_user_order_idx ON auth.oauth_consents USING btree (user_id, granted_at DESC);


--
-- Name: one_time_tokens_relates_to_hash_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX one_time_tokens_relates_to_hash_idx ON auth.one_time_tokens USING hash (relates_to);


--
-- Name: one_time_tokens_token_hash_hash_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX one_time_tokens_token_hash_hash_idx ON auth.one_time_tokens USING hash (token_hash);


--
-- Name: one_time_tokens_user_id_token_type_key; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX one_time_tokens_user_id_token_type_key ON auth.one_time_tokens USING btree (user_id, token_type);


--
-- Name: reauthentication_token_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX reauthentication_token_idx ON auth.users USING btree (reauthentication_token) WHERE ((reauthentication_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: recovery_token_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX recovery_token_idx ON auth.users USING btree (recovery_token) WHERE ((recovery_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: refresh_tokens_instance_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX refresh_tokens_instance_id_idx ON auth.refresh_tokens USING btree (instance_id);


--
-- Name: refresh_tokens_instance_id_user_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX refresh_tokens_instance_id_user_id_idx ON auth.refresh_tokens USING btree (instance_id, user_id);


--
-- Name: refresh_tokens_parent_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX refresh_tokens_parent_idx ON auth.refresh_tokens USING btree (parent);


--
-- Name: refresh_tokens_session_id_revoked_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX refresh_tokens_session_id_revoked_idx ON auth.refresh_tokens USING btree (session_id, revoked);


--
-- Name: refresh_tokens_updated_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX refresh_tokens_updated_at_idx ON auth.refresh_tokens USING btree (updated_at DESC);


--
-- Name: saml_providers_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX saml_providers_sso_provider_id_idx ON auth.saml_providers USING btree (sso_provider_id);


--
-- Name: saml_relay_states_created_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX saml_relay_states_created_at_idx ON auth.saml_relay_states USING btree (created_at DESC);


--
-- Name: saml_relay_states_for_email_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX saml_relay_states_for_email_idx ON auth.saml_relay_states USING btree (for_email);


--
-- Name: saml_relay_states_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX saml_relay_states_sso_provider_id_idx ON auth.saml_relay_states USING btree (sso_provider_id);


--
-- Name: sessions_not_after_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX sessions_not_after_idx ON auth.sessions USING btree (not_after DESC);


--
-- Name: sessions_oauth_client_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX sessions_oauth_client_id_idx ON auth.sessions USING btree (oauth_client_id);


--
-- Name: sessions_user_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX sessions_user_id_idx ON auth.sessions USING btree (user_id);


--
-- Name: sso_domains_domain_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX sso_domains_domain_idx ON auth.sso_domains USING btree (lower(domain));


--
-- Name: sso_domains_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX sso_domains_sso_provider_id_idx ON auth.sso_domains USING btree (sso_provider_id);


--
-- Name: sso_providers_resource_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX sso_providers_resource_id_idx ON auth.sso_providers USING btree (lower(resource_id));


--
-- Name: sso_providers_resource_id_pattern_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX sso_providers_resource_id_pattern_idx ON auth.sso_providers USING btree (resource_id text_pattern_ops);


--
-- Name: unique_phone_factor_per_user; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX unique_phone_factor_per_user ON auth.mfa_factors USING btree (user_id, phone);


--
-- Name: user_id_created_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX user_id_created_at_idx ON auth.sessions USING btree (user_id, created_at);


--
-- Name: users_email_partial_key; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX users_email_partial_key ON auth.users USING btree (email) WHERE (is_sso_user = false);


--
-- Name: INDEX users_email_partial_key; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON INDEX auth.users_email_partial_key IS 'Auth: A partial unique index that applies only when is_sso_user is false';


--
-- Name: users_instance_id_email_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX users_instance_id_email_idx ON auth.users USING btree (instance_id, lower((email)::text));


--
-- Name: users_instance_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX users_instance_id_idx ON auth.users USING btree (instance_id);


--
-- Name: users_is_anonymous_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX users_is_anonymous_idx ON auth.users USING btree (is_anonymous);


--
-- Name: idx_admin_users_email; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_admin_users_email ON public.admin_users USING btree (email);


--
-- Name: idx_announcement_impressions_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_announcement_impressions_user ON public.announcement_impressions USING btree (user_id);


--
-- Name: idx_announcement_responses_announcement; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_announcement_responses_announcement ON public.announcement_responses USING btree (announcement_id);


--
-- Name: idx_announcement_responses_question; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_announcement_responses_question ON public.announcement_responses USING btree (question_id);


--
-- Name: idx_announcement_responses_user_auth; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_announcement_responses_user_auth ON public.announcement_responses USING btree (user_auth_uid);


--
-- Name: idx_announcements_active_filtering; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_announcements_active_filtering ON public.announcements USING btree (is_active, is_deleted, status, start_at, end_at) WHERE ((is_active = true) AND (is_deleted = false) AND (status = 'live'::text));


--
-- Name: idx_announcements_active_time; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_announcements_active_time ON public.announcements USING btree (is_active, is_deleted, start_at, end_at);


--
-- Name: idx_announcements_city_targeting; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_announcements_city_targeting ON public.announcements USING btree (target_city, target_city_exclude) WHERE ((target_city IS NOT NULL) AND (target_city <> ''::text));


--
-- Name: idx_announcements_country_targeting; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_announcements_country_targeting ON public.announcements USING btree (target_country, target_country_exclude) WHERE ((target_country IS NOT NULL) AND (target_country <> ''::text));


--
-- Name: idx_announcements_degree_targeting; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_announcements_degree_targeting ON public.announcements USING btree (target_degree, target_degree_exclude) WHERE ((target_degree IS NOT NULL) AND (target_degree <> ''::text));


--
-- Name: idx_announcements_ordering; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_announcements_ordering ON public.announcements USING btree (importance, display_sequence, created_at DESC);


--
-- Name: idx_announcements_profession_targeting; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_announcements_profession_targeting ON public.announcements USING btree (target_profession, target_profession_exclude) WHERE ((target_profession IS NOT NULL) AND (target_profession <> ''::text));


--
-- Name: idx_announcements_sequence; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_announcements_sequence ON public.announcements USING btree (importance, display_sequence, created_at DESC);


--
-- Name: idx_announcements_speciality_targeting; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_announcements_speciality_targeting ON public.announcements USING btree (target_speciality, target_speciality_exclude) WHERE ((target_speciality IS NOT NULL) AND (target_speciality <> ''::text));


--
-- Name: idx_announcements_surface; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_announcements_surface ON public.announcements USING btree (surface) WHERE (is_deleted = false);


--
-- Name: idx_announcements_target_country; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_announcements_target_country ON public.announcements USING btree (target_country) WHERE (target_country IS NOT NULL);


--
-- Name: idx_announcements_target_degree; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_announcements_target_degree ON public.announcements USING btree (target_degree) WHERE (target_degree IS NOT NULL);


--
-- Name: idx_announcements_target_platform; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_announcements_target_platform ON public.announcements USING btree (target_platform) WHERE (target_platform IS NOT NULL);


--
-- Name: idx_announcements_target_profession; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_announcements_target_profession ON public.announcements USING btree (target_profession) WHERE (target_profession IS NOT NULL);


--
-- Name: idx_app_sessions_auth_uid; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_app_sessions_auth_uid ON public.app_sessions USING btree (auth_uid) WHERE (auth_uid IS NOT NULL);


--
-- Name: idx_app_sessions_country; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_app_sessions_country ON public.app_sessions USING btree (country) WHERE (country IS NOT NULL);


--
-- Name: idx_app_sessions_is_active; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_app_sessions_is_active ON public.app_sessions USING btree (is_active) WHERE (is_active = true);


--
-- Name: idx_app_sessions_is_synced; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_app_sessions_is_synced ON public.app_sessions USING btree (is_synced) WHERE (is_synced = false);


--
-- Name: idx_app_sessions_start_time; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_app_sessions_start_time ON public.app_sessions USING btree (start_time);


--
-- Name: idx_app_sessions_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_app_sessions_user_id ON public.app_sessions USING btree (user_id);


--
-- Name: idx_app_settings_is_synced; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_app_settings_is_synced ON public.app_settings USING btree (is_synced) WHERE (is_synced = false);


--
-- Name: idx_app_settings_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_app_settings_user_id ON public.app_settings USING btree (user_id);


--
-- Name: idx_category_settings_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_category_settings_user_id ON public.category_settings USING btree (user_id);


--
-- Name: idx_credit_asset_types_active; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_credit_asset_types_active ON public.credit_asset_types USING btree (is_active) WHERE (is_active = true);


--
-- Name: idx_credit_asset_types_sort; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_credit_asset_types_sort ON public.credit_asset_types USING btree (sort_order);


--
-- Name: idx_credit_links_active; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_credit_links_active ON public.credit_links USING btree (is_active) WHERE (is_active = true);


--
-- Name: idx_credit_links_site; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_credit_links_site ON public.credit_links USING btree (site_id);


--
-- Name: idx_credit_links_sort; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_credit_links_sort ON public.credit_links USING btree (sort_order);


--
-- Name: idx_credit_sites_active; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_credit_sites_active ON public.credit_sites USING btree (is_active) WHERE (is_active = true);


--
-- Name: idx_credit_sites_asset_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_credit_sites_asset_type ON public.credit_sites USING btree (asset_type_id);


--
-- Name: idx_credit_sites_sort; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_credit_sites_sort ON public.credit_sites USING btree (sort_order);


--
-- Name: idx_feedbacks_submitted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_feedbacks_submitted_at ON public.feedbacks USING btree (submitted_at);


--
-- Name: idx_feedbacks_tool_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_feedbacks_tool_id ON public.feedbacks USING btree (tool_id) WHERE (tool_id IS NOT NULL);


--
-- Name: idx_feedbacks_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_feedbacks_user_id ON public.feedbacks USING btree (user_id);


--
-- Name: idx_screen_settings_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_screen_settings_user_id ON public.screen_settings USING btree (user_id);


--
-- Name: idx_section_settings_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_section_settings_user_id ON public.section_settings USING btree (user_id);


--
-- Name: idx_tool_settings_is_favourite; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tool_settings_is_favourite ON public.tool_settings USING btree (is_favourite) WHERE (is_favourite = true);


--
-- Name: idx_tool_settings_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tool_settings_user_id ON public.tool_settings USING btree (user_id);


--
-- Name: idx_tool_usage_events_event_timestamp; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tool_usage_events_event_timestamp ON public.tool_usage_events USING btree (event_timestamp);


--
-- Name: idx_tool_usage_events_tool_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tool_usage_events_tool_id ON public.tool_usage_events USING btree (tool_id);


--
-- Name: idx_tool_usage_events_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tool_usage_events_user_id ON public.tool_usage_events USING btree (user_id);


--
-- Name: idx_tool_usage_summary_slug; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tool_usage_summary_slug ON public.tool_usage_summary USING btree (tool_slug);


--
-- Name: idx_user_announcement_state_announcement; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_announcement_state_announcement ON public.user_announcement_state USING btree (announcement_id);


--
-- Name: idx_user_announcement_state_deferred; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_announcement_state_deferred ON public.user_announcement_state USING btree (status, defer_until_session, defer_until_time) WHERE (status = 'deferred'::text);


--
-- Name: idx_user_announcement_state_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_announcement_state_status ON public.user_announcement_state USING btree (status);


--
-- Name: idx_user_announcement_state_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_announcement_state_user ON public.user_announcement_state USING btree (user_id);


--
-- Name: idx_user_announcement_state_user_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_announcement_state_user_status ON public.user_announcement_state USING btree (user_id, status);


--
-- Name: idx_user_announcement_state_user_status_fast; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_announcement_state_user_status_fast ON public.user_announcement_state USING btree (user_id, status, announcement_id);


--
-- Name: idx_users_auth_uid; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_users_auth_uid ON public.users USING btree (auth_uid) WHERE (auth_uid IS NOT NULL);


--
-- Name: idx_users_email; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_users_email ON public.users USING btree (email) WHERE (email IS NOT NULL);


--
-- Name: idx_users_insights; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_users_insights ON public.users USING gin (insights);


--
-- Name: idx_users_insights_gin; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_users_insights_gin ON public.users USING gin (insights) WHERE ((insights IS NOT NULL) AND (insights <> '{}'::jsonb));


--
-- Name: idx_users_is_synced; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_users_is_synced ON public.users USING btree (is_synced) WHERE (is_synced = false);


--
-- Name: idx_users_last_country; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_users_last_country ON public.users USING btree (last_country) WHERE (last_country IS NOT NULL);


--
-- Name: idx_users_last_platform; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_users_last_platform ON public.users USING btree (last_platform) WHERE (last_platform IS NOT NULL);


--
-- Name: ix_realtime_subscription_entity; Type: INDEX; Schema: realtime; Owner: supabase_admin
--

CREATE INDEX ix_realtime_subscription_entity ON realtime.subscription USING btree (entity);


--
-- Name: messages_inserted_at_topic_index; Type: INDEX; Schema: realtime; Owner: supabase_realtime_admin
--

CREATE INDEX messages_inserted_at_topic_index ON ONLY realtime.messages USING btree (inserted_at DESC, topic) WHERE ((extension = 'broadcast'::text) AND (private IS TRUE));


--
-- Name: subscription_subscription_id_entity_filters_key; Type: INDEX; Schema: realtime; Owner: supabase_admin
--

CREATE UNIQUE INDEX subscription_subscription_id_entity_filters_key ON realtime.subscription USING btree (subscription_id, entity, filters);


--
-- Name: bname; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE UNIQUE INDEX bname ON storage.buckets USING btree (name);


--
-- Name: bucketid_objname; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE UNIQUE INDEX bucketid_objname ON storage.objects USING btree (bucket_id, name);


--
-- Name: buckets_analytics_unique_name_idx; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE UNIQUE INDEX buckets_analytics_unique_name_idx ON storage.buckets_analytics USING btree (name) WHERE (deleted_at IS NULL);


--
-- Name: idx_multipart_uploads_list; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE INDEX idx_multipart_uploads_list ON storage.s3_multipart_uploads USING btree (bucket_id, key, created_at);


--
-- Name: idx_name_bucket_level_unique; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE UNIQUE INDEX idx_name_bucket_level_unique ON storage.objects USING btree (name COLLATE "C", bucket_id, level);


--
-- Name: idx_objects_bucket_id_name; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE INDEX idx_objects_bucket_id_name ON storage.objects USING btree (bucket_id, name COLLATE "C");


--
-- Name: idx_objects_lower_name; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE INDEX idx_objects_lower_name ON storage.objects USING btree ((path_tokens[level]), lower(name) text_pattern_ops, bucket_id, level);


--
-- Name: idx_prefixes_lower_name; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE INDEX idx_prefixes_lower_name ON storage.prefixes USING btree (bucket_id, level, ((string_to_array(name, '/'::text))[level]), lower(name) text_pattern_ops);


--
-- Name: name_prefix_search; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE INDEX name_prefix_search ON storage.objects USING btree (name text_pattern_ops);


--
-- Name: objects_bucket_id_level_idx; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE UNIQUE INDEX objects_bucket_id_level_idx ON storage.objects USING btree (bucket_id, level, name COLLATE "C");


--
-- Name: vector_indexes_name_bucket_id_idx; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE UNIQUE INDEX vector_indexes_name_bucket_id_idx ON storage.vector_indexes USING btree (name, bucket_id);


--
-- Name: announcements trigger_announcements_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_announcements_updated_at BEFORE UPDATE ON public.announcements FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: app_sessions trigger_app_sessions_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_app_sessions_updated_at BEFORE UPDATE ON public.app_sessions FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: app_settings trigger_app_settings_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_app_settings_updated_at BEFORE UPDATE ON public.app_settings FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: category_settings trigger_category_settings_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_category_settings_updated_at BEFORE UPDATE ON public.category_settings FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: credit_asset_types trigger_credit_asset_types_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_credit_asset_types_updated_at BEFORE UPDATE ON public.credit_asset_types FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: credit_links trigger_credit_links_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_credit_links_updated_at BEFORE UPDATE ON public.credit_links FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: credit_sites trigger_credit_sites_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_credit_sites_updated_at BEFORE UPDATE ON public.credit_sites FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: feedbacks trigger_feedbacks_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_feedbacks_updated_at BEFORE UPDATE ON public.feedbacks FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: screen_settings trigger_screen_settings_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_screen_settings_updated_at BEFORE UPDATE ON public.screen_settings FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: section_settings trigger_section_settings_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_section_settings_updated_at BEFORE UPDATE ON public.section_settings FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: tool_settings trigger_tool_settings_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_tool_settings_updated_at BEFORE UPDATE ON public.tool_settings FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: announcement_responses trigger_update_user_insights; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_update_user_insights AFTER INSERT OR UPDATE ON public.announcement_responses FOR EACH ROW EXECUTE FUNCTION public.update_user_insights_from_response();


--
-- Name: app_sessions trigger_update_user_location; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_update_user_location AFTER INSERT OR UPDATE ON public.app_sessions FOR EACH ROW EXECUTE FUNCTION public.update_user_location_from_session();


--
-- Name: users trigger_users_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_users_updated_at BEFORE UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: user_announcement_state update_user_announcement_state_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_user_announcement_state_updated_at BEFORE UPDATE ON public.user_announcement_state FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: subscription tr_check_filters; Type: TRIGGER; Schema: realtime; Owner: supabase_admin
--

CREATE TRIGGER tr_check_filters BEFORE INSERT OR UPDATE ON realtime.subscription FOR EACH ROW EXECUTE FUNCTION realtime.subscription_check_filters();


--
-- Name: buckets enforce_bucket_name_length_trigger; Type: TRIGGER; Schema: storage; Owner: supabase_storage_admin
--

CREATE TRIGGER enforce_bucket_name_length_trigger BEFORE INSERT OR UPDATE OF name ON storage.buckets FOR EACH ROW EXECUTE FUNCTION storage.enforce_bucket_name_length();


--
-- Name: objects objects_delete_delete_prefix; Type: TRIGGER; Schema: storage; Owner: supabase_storage_admin
--

CREATE TRIGGER objects_delete_delete_prefix AFTER DELETE ON storage.objects FOR EACH ROW EXECUTE FUNCTION storage.delete_prefix_hierarchy_trigger();


--
-- Name: objects objects_insert_create_prefix; Type: TRIGGER; Schema: storage; Owner: supabase_storage_admin
--

CREATE TRIGGER objects_insert_create_prefix BEFORE INSERT ON storage.objects FOR EACH ROW EXECUTE FUNCTION storage.objects_insert_prefix_trigger();


--
-- Name: objects objects_update_create_prefix; Type: TRIGGER; Schema: storage; Owner: supabase_storage_admin
--

CREATE TRIGGER objects_update_create_prefix BEFORE UPDATE ON storage.objects FOR EACH ROW WHEN (((new.name <> old.name) OR (new.bucket_id <> old.bucket_id))) EXECUTE FUNCTION storage.objects_update_prefix_trigger();


--
-- Name: prefixes prefixes_create_hierarchy; Type: TRIGGER; Schema: storage; Owner: supabase_storage_admin
--

CREATE TRIGGER prefixes_create_hierarchy BEFORE INSERT ON storage.prefixes FOR EACH ROW WHEN ((pg_trigger_depth() < 1)) EXECUTE FUNCTION storage.prefixes_insert_trigger();


--
-- Name: prefixes prefixes_delete_hierarchy; Type: TRIGGER; Schema: storage; Owner: supabase_storage_admin
--

CREATE TRIGGER prefixes_delete_hierarchy AFTER DELETE ON storage.prefixes FOR EACH ROW EXECUTE FUNCTION storage.delete_prefix_hierarchy_trigger();


--
-- Name: objects update_objects_updated_at; Type: TRIGGER; Schema: storage; Owner: supabase_storage_admin
--

CREATE TRIGGER update_objects_updated_at BEFORE UPDATE ON storage.objects FOR EACH ROW EXECUTE FUNCTION storage.update_updated_at_column();


--
-- Name: identities identities_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: mfa_amr_claims mfa_amr_claims_session_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT mfa_amr_claims_session_id_fkey FOREIGN KEY (session_id) REFERENCES auth.sessions(id) ON DELETE CASCADE;


--
-- Name: mfa_challenges mfa_challenges_auth_factor_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_challenges
    ADD CONSTRAINT mfa_challenges_auth_factor_id_fkey FOREIGN KEY (factor_id) REFERENCES auth.mfa_factors(id) ON DELETE CASCADE;


--
-- Name: mfa_factors mfa_factors_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: oauth_authorizations oauth_authorizations_client_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_client_id_fkey FOREIGN KEY (client_id) REFERENCES auth.oauth_clients(id) ON DELETE CASCADE;


--
-- Name: oauth_authorizations oauth_authorizations_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: oauth_consents oauth_consents_client_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.oauth_consents
    ADD CONSTRAINT oauth_consents_client_id_fkey FOREIGN KEY (client_id) REFERENCES auth.oauth_clients(id) ON DELETE CASCADE;


--
-- Name: oauth_consents oauth_consents_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.oauth_consents
    ADD CONSTRAINT oauth_consents_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: one_time_tokens one_time_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.one_time_tokens
    ADD CONSTRAINT one_time_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: refresh_tokens refresh_tokens_session_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_session_id_fkey FOREIGN KEY (session_id) REFERENCES auth.sessions(id) ON DELETE CASCADE;


--
-- Name: saml_providers saml_providers_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: saml_relay_states saml_relay_states_flow_state_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_flow_state_id_fkey FOREIGN KEY (flow_state_id) REFERENCES auth.flow_state(id) ON DELETE CASCADE;


--
-- Name: saml_relay_states saml_relay_states_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: sessions sessions_oauth_client_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_oauth_client_id_fkey FOREIGN KEY (oauth_client_id) REFERENCES auth.oauth_clients(id) ON DELETE CASCADE;


--
-- Name: sessions sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: sso_domains sso_domains_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sso_domains
    ADD CONSTRAINT sso_domains_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: announcement_impressions announcement_impressions_announcement_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.announcement_impressions
    ADD CONSTRAINT announcement_impressions_announcement_id_fkey FOREIGN KEY (announcement_id) REFERENCES public.announcements(id) ON DELETE CASCADE;


--
-- Name: announcement_responses announcement_responses_announcement_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.announcement_responses
    ADD CONSTRAINT announcement_responses_announcement_id_fkey FOREIGN KEY (announcement_id) REFERENCES public.announcements(id) ON DELETE CASCADE;


--
-- Name: credit_links credit_links_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.credit_links
    ADD CONSTRAINT credit_links_site_id_fkey FOREIGN KEY (site_id) REFERENCES public.credit_sites(id) ON DELETE CASCADE;


--
-- Name: credit_sites credit_sites_asset_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.credit_sites
    ADD CONSTRAINT credit_sites_asset_type_id_fkey FOREIGN KEY (asset_type_id) REFERENCES public.credit_asset_types(id) ON DELETE CASCADE;


--
-- Name: user_announcement_state user_announcement_state_announcement_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_announcement_state
    ADD CONSTRAINT user_announcement_state_announcement_id_fkey FOREIGN KEY (announcement_id) REFERENCES public.announcements(id) ON DELETE CASCADE;


--
-- Name: objects objects_bucketId_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.objects
    ADD CONSTRAINT "objects_bucketId_fkey" FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- Name: prefixes prefixes_bucketId_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.prefixes
    ADD CONSTRAINT "prefixes_bucketId_fkey" FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- Name: s3_multipart_uploads s3_multipart_uploads_bucket_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.s3_multipart_uploads
    ADD CONSTRAINT s3_multipart_uploads_bucket_id_fkey FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_bucket_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.s3_multipart_uploads_parts
    ADD CONSTRAINT s3_multipart_uploads_parts_bucket_id_fkey FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_upload_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.s3_multipart_uploads_parts
    ADD CONSTRAINT s3_multipart_uploads_parts_upload_id_fkey FOREIGN KEY (upload_id) REFERENCES storage.s3_multipart_uploads(id) ON DELETE CASCADE;


--
-- Name: vector_indexes vector_indexes_bucket_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.vector_indexes
    ADD CONSTRAINT vector_indexes_bucket_id_fkey FOREIGN KEY (bucket_id) REFERENCES storage.buckets_vectors(id);


--
-- Name: audit_log_entries; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.audit_log_entries ENABLE ROW LEVEL SECURITY;

--
-- Name: flow_state; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.flow_state ENABLE ROW LEVEL SECURITY;

--
-- Name: identities; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.identities ENABLE ROW LEVEL SECURITY;

--
-- Name: instances; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.instances ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_amr_claims; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.mfa_amr_claims ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_challenges; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.mfa_challenges ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_factors; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.mfa_factors ENABLE ROW LEVEL SECURITY;

--
-- Name: one_time_tokens; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.one_time_tokens ENABLE ROW LEVEL SECURITY;

--
-- Name: refresh_tokens; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.refresh_tokens ENABLE ROW LEVEL SECURITY;

--
-- Name: saml_providers; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.saml_providers ENABLE ROW LEVEL SECURITY;

--
-- Name: saml_relay_states; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.saml_relay_states ENABLE ROW LEVEL SECURITY;

--
-- Name: schema_migrations; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.schema_migrations ENABLE ROW LEVEL SECURITY;

--
-- Name: sessions; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.sessions ENABLE ROW LEVEL SECURITY;

--
-- Name: sso_domains; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.sso_domains ENABLE ROW LEVEL SECURITY;

--
-- Name: sso_providers; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.sso_providers ENABLE ROW LEVEL SECURITY;

--
-- Name: users; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.users ENABLE ROW LEVEL SECURITY;

--
-- Name: admin_users; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.admin_users ENABLE ROW LEVEL SECURITY;

--
-- Name: admin_users admin_users_read_active; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY admin_users_read_active ON public.admin_users FOR SELECT USING ((is_active = true));


--
-- Name: admin_users admin_users_service_all; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY admin_users_service_all ON public.admin_users USING ((auth.role() = 'service_role'::text)) WITH CHECK ((auth.role() = 'service_role'::text));


--
-- Name: announcement_config; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.announcement_config ENABLE ROW LEVEL SECURITY;

--
-- Name: announcement_config announcement_config_admin; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY announcement_config_admin ON public.announcement_config USING ((auth.role() = 'service_role'::text));


--
-- Name: announcement_config announcement_config_read; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY announcement_config_read ON public.announcement_config FOR SELECT USING (true);


--
-- Name: announcement_impressions; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.announcement_impressions ENABLE ROW LEVEL SECURITY;

--
-- Name: announcement_impressions announcement_impressions_self; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY announcement_impressions_self ON public.announcement_impressions USING ((auth.uid() = user_id)) WITH CHECK ((auth.uid() = user_id));


--
-- Name: announcement_impressions announcement_impressions_service; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY announcement_impressions_service ON public.announcement_impressions USING ((auth.role() = 'service_role'::text));


--
-- Name: announcement_responses; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.announcement_responses ENABLE ROW LEVEL SECURITY;

--
-- Name: announcement_responses announcement_responses_insert; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY announcement_responses_insert ON public.announcement_responses FOR INSERT WITH CHECK (true);


--
-- Name: announcement_responses announcement_responses_select; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY announcement_responses_select ON public.announcement_responses FOR SELECT USING (true);


--
-- Name: announcement_responses announcement_responses_service; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY announcement_responses_service ON public.announcement_responses USING ((auth.role() = 'service_role'::text));


--
-- Name: announcement_responses announcement_responses_update; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY announcement_responses_update ON public.announcement_responses FOR UPDATE USING (true) WITH CHECK (true);


--
-- Name: announcements; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.announcements ENABLE ROW LEVEL SECURITY;

--
-- Name: announcements announcements_read_active; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY announcements_read_active ON public.announcements FOR SELECT USING (((is_active = true) AND (is_deleted = false) AND (start_at <= now()) AND ((end_at IS NULL) OR (end_at > now()))));


--
-- Name: announcements announcements_service_role_all; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY announcements_service_role_all ON public.announcements USING ((auth.role() = 'service_role'::text));


--
-- Name: app_sessions; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.app_sessions ENABLE ROW LEVEL SECURITY;

--
-- Name: app_sessions app_sessions_access_policy; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY app_sessions_access_policy ON public.app_sessions USING ((((auth_uid IS NOT NULL) AND (auth_uid = (auth.jwt() ->> 'sub'::text))) OR (auth_uid IS NULL) OR (auth.role() = 'service_role'::text) OR ((auth.jwt() ->> 'sub'::text) IS NOT NULL)));


--
-- Name: app_settings; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.app_settings ENABLE ROW LEVEL SECURITY;

--
-- Name: app_settings app_settings_access_policy; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY app_settings_access_policy ON public.app_settings USING ((((auth_uid IS NOT NULL) AND (auth_uid = (auth.jwt() ->> 'sub'::text))) OR (auth_uid IS NULL) OR (auth.role() = 'service_role'::text) OR ((auth.jwt() ->> 'sub'::text) IS NOT NULL)));


--
-- Name: category_settings; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.category_settings ENABLE ROW LEVEL SECURITY;

--
-- Name: category_settings category_settings_access_policy; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY category_settings_access_policy ON public.category_settings USING ((((auth_uid IS NOT NULL) AND (auth_uid = (auth.jwt() ->> 'sub'::text))) OR (auth_uid IS NULL) OR (auth.role() = 'service_role'::text) OR ((auth.jwt() ->> 'sub'::text) IS NOT NULL)));


--
-- Name: credit_asset_types; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.credit_asset_types ENABLE ROW LEVEL SECURITY;

--
-- Name: credit_asset_types credit_asset_types_read_all; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY credit_asset_types_read_all ON public.credit_asset_types FOR SELECT USING ((is_active = true));


--
-- Name: credit_asset_types credit_asset_types_service_all; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY credit_asset_types_service_all ON public.credit_asset_types USING ((auth.role() = 'service_role'::text));


--
-- Name: credit_links; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.credit_links ENABLE ROW LEVEL SECURITY;

--
-- Name: credit_links credit_links_read_all; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY credit_links_read_all ON public.credit_links FOR SELECT USING ((is_active = true));


--
-- Name: credit_links credit_links_service_all; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY credit_links_service_all ON public.credit_links USING ((auth.role() = 'service_role'::text));


--
-- Name: credit_sites; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.credit_sites ENABLE ROW LEVEL SECURITY;

--
-- Name: credit_sites credit_sites_read_all; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY credit_sites_read_all ON public.credit_sites FOR SELECT USING ((is_active = true));


--
-- Name: credit_sites credit_sites_service_all; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY credit_sites_service_all ON public.credit_sites USING ((auth.role() = 'service_role'::text));


--
-- Name: feedbacks; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.feedbacks ENABLE ROW LEVEL SECURITY;

--
-- Name: feedbacks feedbacks_access_policy; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY feedbacks_access_policy ON public.feedbacks USING ((((auth_uid IS NOT NULL) AND (auth_uid = (auth.jwt() ->> 'sub'::text))) OR (auth_uid IS NULL) OR (auth.role() = 'service_role'::text) OR ((auth.jwt() ->> 'sub'::text) IS NOT NULL)));


--
-- Name: screen_settings; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.screen_settings ENABLE ROW LEVEL SECURITY;

--
-- Name: screen_settings screen_settings_access_policy; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY screen_settings_access_policy ON public.screen_settings USING ((((auth_uid IS NOT NULL) AND (auth_uid = (auth.jwt() ->> 'sub'::text))) OR (auth_uid IS NULL) OR (auth.role() = 'service_role'::text) OR ((auth.jwt() ->> 'sub'::text) IS NOT NULL)));


--
-- Name: section_settings; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.section_settings ENABLE ROW LEVEL SECURITY;

--
-- Name: section_settings section_settings_access_policy; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY section_settings_access_policy ON public.section_settings USING ((((auth_uid IS NOT NULL) AND (auth_uid = (auth.jwt() ->> 'sub'::text))) OR (auth_uid IS NULL) OR (auth.role() = 'service_role'::text) OR ((auth.jwt() ->> 'sub'::text) IS NOT NULL)));


--
-- Name: tool_settings; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.tool_settings ENABLE ROW LEVEL SECURITY;

--
-- Name: tool_settings tool_settings_access_policy; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY tool_settings_access_policy ON public.tool_settings USING ((((auth_uid IS NOT NULL) AND (auth_uid = (auth.jwt() ->> 'sub'::text))) OR (auth_uid IS NULL) OR (auth.role() = 'service_role'::text) OR ((auth.jwt() ->> 'sub'::text) IS NOT NULL)));


--
-- Name: tool_usage_events; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.tool_usage_events ENABLE ROW LEVEL SECURITY;

--
-- Name: tool_usage_events tool_usage_events_access_policy; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY tool_usage_events_access_policy ON public.tool_usage_events USING ((((auth_uid IS NOT NULL) AND (auth_uid = (auth.jwt() ->> 'sub'::text))) OR (auth_uid IS NULL) OR (auth.role() = 'service_role'::text) OR ((auth.jwt() ->> 'sub'::text) IS NOT NULL)));


--
-- Name: tool_usage_summary; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.tool_usage_summary ENABLE ROW LEVEL SECURITY;

--
-- Name: tool_usage_summary tool_usage_summary_service; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY tool_usage_summary_service ON public.tool_usage_summary USING ((auth.role() = 'service_role'::text));


--
-- Name: user_announcement_state; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.user_announcement_state ENABLE ROW LEVEL SECURITY;

--
-- Name: user_announcement_state user_announcement_state_access; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY user_announcement_state_access ON public.user_announcement_state USING (((user_id = (auth.jwt() ->> 'sub'::text)) OR (auth.role() = 'service_role'::text)));


--
-- Name: user_sync_states; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.user_sync_states ENABLE ROW LEVEL SECURITY;

--
-- Name: user_sync_states user_sync_states_access_policy; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY user_sync_states_access_policy ON public.user_sync_states USING (((auth.role() = 'service_role'::text) OR ((auth.jwt() ->> 'sub'::text) IS NOT NULL)));


--
-- Name: user_usage_summary; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.user_usage_summary ENABLE ROW LEVEL SECURITY;

--
-- Name: user_usage_summary user_usage_summary_service; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY user_usage_summary_service ON public.user_usage_summary USING ((auth.role() = 'service_role'::text));


--
-- Name: users; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

--
-- Name: users users_access_policy; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY users_access_policy ON public.users USING ((((auth_uid IS NOT NULL) AND (auth_uid = (auth.jwt() ->> 'sub'::text))) OR (auth_uid IS NULL) OR (auth.role() = 'service_role'::text) OR ((auth.jwt() ->> 'sub'::text) IS NOT NULL)));


--
-- Name: messages; Type: ROW SECURITY; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER TABLE realtime.messages ENABLE ROW LEVEL SECURITY;

--
-- Name: buckets; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.buckets ENABLE ROW LEVEL SECURITY;

--
-- Name: buckets_analytics; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.buckets_analytics ENABLE ROW LEVEL SECURITY;

--
-- Name: buckets_vectors; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.buckets_vectors ENABLE ROW LEVEL SECURITY;

--
-- Name: migrations; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.migrations ENABLE ROW LEVEL SECURITY;

--
-- Name: objects; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

--
-- Name: prefixes; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.prefixes ENABLE ROW LEVEL SECURITY;

--
-- Name: s3_multipart_uploads; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.s3_multipart_uploads ENABLE ROW LEVEL SECURITY;

--
-- Name: s3_multipart_uploads_parts; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.s3_multipart_uploads_parts ENABLE ROW LEVEL SECURITY;

--
-- Name: vector_indexes; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.vector_indexes ENABLE ROW LEVEL SECURITY;

--
-- Name: supabase_realtime; Type: PUBLICATION; Schema: -; Owner: postgres
--

CREATE PUBLICATION supabase_realtime WITH (publish = 'insert, update, delete, truncate');


ALTER PUBLICATION supabase_realtime OWNER TO postgres;

--
-- Name: SCHEMA auth; Type: ACL; Schema: -; Owner: supabase_admin
--

GRANT USAGE ON SCHEMA auth TO anon;
GRANT USAGE ON SCHEMA auth TO authenticated;
GRANT USAGE ON SCHEMA auth TO service_role;
GRANT ALL ON SCHEMA auth TO supabase_auth_admin;
GRANT ALL ON SCHEMA auth TO dashboard_user;
GRANT USAGE ON SCHEMA auth TO postgres;


--
-- Name: SCHEMA extensions; Type: ACL; Schema: -; Owner: postgres
--

GRANT USAGE ON SCHEMA extensions TO anon;
GRANT USAGE ON SCHEMA extensions TO authenticated;
GRANT USAGE ON SCHEMA extensions TO service_role;
GRANT ALL ON SCHEMA extensions TO dashboard_user;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: pg_database_owner
--

GRANT USAGE ON SCHEMA public TO postgres;
GRANT USAGE ON SCHEMA public TO anon;
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT USAGE ON SCHEMA public TO service_role;


--
-- Name: SCHEMA realtime; Type: ACL; Schema: -; Owner: supabase_admin
--

GRANT USAGE ON SCHEMA realtime TO postgres;
GRANT USAGE ON SCHEMA realtime TO anon;
GRANT USAGE ON SCHEMA realtime TO authenticated;
GRANT USAGE ON SCHEMA realtime TO service_role;
GRANT ALL ON SCHEMA realtime TO supabase_realtime_admin;


--
-- Name: SCHEMA storage; Type: ACL; Schema: -; Owner: supabase_admin
--

GRANT USAGE ON SCHEMA storage TO postgres WITH GRANT OPTION;
GRANT USAGE ON SCHEMA storage TO anon;
GRANT USAGE ON SCHEMA storage TO authenticated;
GRANT USAGE ON SCHEMA storage TO service_role;
GRANT ALL ON SCHEMA storage TO supabase_storage_admin;
GRANT ALL ON SCHEMA storage TO dashboard_user;


--
-- Name: SCHEMA vault; Type: ACL; Schema: -; Owner: supabase_admin
--

GRANT USAGE ON SCHEMA vault TO postgres WITH GRANT OPTION;
GRANT USAGE ON SCHEMA vault TO service_role;


--
-- Name: FUNCTION gtrgm_in(cstring); Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION public.gtrgm_in(cstring) TO postgres;
GRANT ALL ON FUNCTION public.gtrgm_in(cstring) TO anon;
GRANT ALL ON FUNCTION public.gtrgm_in(cstring) TO authenticated;
GRANT ALL ON FUNCTION public.gtrgm_in(cstring) TO service_role;


--
-- Name: FUNCTION gtrgm_out(public.gtrgm); Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION public.gtrgm_out(public.gtrgm) TO postgres;
GRANT ALL ON FUNCTION public.gtrgm_out(public.gtrgm) TO anon;
GRANT ALL ON FUNCTION public.gtrgm_out(public.gtrgm) TO authenticated;
GRANT ALL ON FUNCTION public.gtrgm_out(public.gtrgm) TO service_role;


--
-- Name: FUNCTION email(); Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON FUNCTION auth.email() TO dashboard_user;
GRANT ALL ON FUNCTION auth.email() TO postgres;


--
-- Name: FUNCTION jwt(); Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON FUNCTION auth.jwt() TO postgres;
GRANT ALL ON FUNCTION auth.jwt() TO dashboard_user;


--
-- Name: FUNCTION role(); Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON FUNCTION auth.role() TO dashboard_user;
GRANT ALL ON FUNCTION auth.role() TO postgres;


--
-- Name: FUNCTION uid(); Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON FUNCTION auth.uid() TO dashboard_user;
GRANT ALL ON FUNCTION auth.uid() TO postgres;


--
-- Name: FUNCTION armor(bytea); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.armor(bytea) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.armor(bytea) TO dashboard_user;


--
-- Name: FUNCTION armor(bytea, text[], text[]); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.armor(bytea, text[], text[]) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.armor(bytea, text[], text[]) TO dashboard_user;


--
-- Name: FUNCTION crypt(text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.crypt(text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.crypt(text, text) TO dashboard_user;


--
-- Name: FUNCTION dearmor(text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.dearmor(text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.dearmor(text) TO dashboard_user;


--
-- Name: FUNCTION decrypt(bytea, bytea, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.decrypt(bytea, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.decrypt(bytea, bytea, text) TO dashboard_user;


--
-- Name: FUNCTION decrypt_iv(bytea, bytea, bytea, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.decrypt_iv(bytea, bytea, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.decrypt_iv(bytea, bytea, bytea, text) TO dashboard_user;


--
-- Name: FUNCTION digest(bytea, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.digest(bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.digest(bytea, text) TO dashboard_user;


--
-- Name: FUNCTION digest(text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.digest(text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.digest(text, text) TO dashboard_user;


--
-- Name: FUNCTION encrypt(bytea, bytea, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.encrypt(bytea, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.encrypt(bytea, bytea, text) TO dashboard_user;


--
-- Name: FUNCTION encrypt_iv(bytea, bytea, bytea, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.encrypt_iv(bytea, bytea, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.encrypt_iv(bytea, bytea, bytea, text) TO dashboard_user;


--
-- Name: FUNCTION gen_random_bytes(integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.gen_random_bytes(integer) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.gen_random_bytes(integer) TO dashboard_user;


--
-- Name: FUNCTION gen_random_uuid(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.gen_random_uuid() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.gen_random_uuid() TO dashboard_user;


--
-- Name: FUNCTION gen_salt(text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.gen_salt(text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.gen_salt(text) TO dashboard_user;


--
-- Name: FUNCTION gen_salt(text, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.gen_salt(text, integer) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.gen_salt(text, integer) TO dashboard_user;


--
-- Name: FUNCTION grant_pg_cron_access(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

REVOKE ALL ON FUNCTION extensions.grant_pg_cron_access() FROM supabase_admin;
GRANT ALL ON FUNCTION extensions.grant_pg_cron_access() TO supabase_admin WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.grant_pg_cron_access() TO dashboard_user;
GRANT ALL ON FUNCTION extensions.grant_pg_cron_access() TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION grant_pg_graphql_access(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.grant_pg_graphql_access() TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION grant_pg_net_access(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

REVOKE ALL ON FUNCTION extensions.grant_pg_net_access() FROM supabase_admin;
GRANT ALL ON FUNCTION extensions.grant_pg_net_access() TO supabase_admin WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.grant_pg_net_access() TO dashboard_user;
GRANT ALL ON FUNCTION extensions.grant_pg_net_access() TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION hmac(bytea, bytea, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.hmac(bytea, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.hmac(bytea, bytea, text) TO dashboard_user;


--
-- Name: FUNCTION hmac(text, text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.hmac(text, text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.hmac(text, text, text) TO dashboard_user;


--
-- Name: FUNCTION pg_stat_statements(showtext boolean, OUT userid oid, OUT dbid oid, OUT toplevel boolean, OUT queryid bigint, OUT query text, OUT plans bigint, OUT total_plan_time double precision, OUT min_plan_time double precision, OUT max_plan_time double precision, OUT mean_plan_time double precision, OUT stddev_plan_time double precision, OUT calls bigint, OUT total_exec_time double precision, OUT min_exec_time double precision, OUT max_exec_time double precision, OUT mean_exec_time double precision, OUT stddev_exec_time double precision, OUT rows bigint, OUT shared_blks_hit bigint, OUT shared_blks_read bigint, OUT shared_blks_dirtied bigint, OUT shared_blks_written bigint, OUT local_blks_hit bigint, OUT local_blks_read bigint, OUT local_blks_dirtied bigint, OUT local_blks_written bigint, OUT temp_blks_read bigint, OUT temp_blks_written bigint, OUT shared_blk_read_time double precision, OUT shared_blk_write_time double precision, OUT local_blk_read_time double precision, OUT local_blk_write_time double precision, OUT temp_blk_read_time double precision, OUT temp_blk_write_time double precision, OUT wal_records bigint, OUT wal_fpi bigint, OUT wal_bytes numeric, OUT jit_functions bigint, OUT jit_generation_time double precision, OUT jit_inlining_count bigint, OUT jit_inlining_time double precision, OUT jit_optimization_count bigint, OUT jit_optimization_time double precision, OUT jit_emission_count bigint, OUT jit_emission_time double precision, OUT jit_deform_count bigint, OUT jit_deform_time double precision, OUT stats_since timestamp with time zone, OUT minmax_stats_since timestamp with time zone); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pg_stat_statements(showtext boolean, OUT userid oid, OUT dbid oid, OUT toplevel boolean, OUT queryid bigint, OUT query text, OUT plans bigint, OUT total_plan_time double precision, OUT min_plan_time double precision, OUT max_plan_time double precision, OUT mean_plan_time double precision, OUT stddev_plan_time double precision, OUT calls bigint, OUT total_exec_time double precision, OUT min_exec_time double precision, OUT max_exec_time double precision, OUT mean_exec_time double precision, OUT stddev_exec_time double precision, OUT rows bigint, OUT shared_blks_hit bigint, OUT shared_blks_read bigint, OUT shared_blks_dirtied bigint, OUT shared_blks_written bigint, OUT local_blks_hit bigint, OUT local_blks_read bigint, OUT local_blks_dirtied bigint, OUT local_blks_written bigint, OUT temp_blks_read bigint, OUT temp_blks_written bigint, OUT shared_blk_read_time double precision, OUT shared_blk_write_time double precision, OUT local_blk_read_time double precision, OUT local_blk_write_time double precision, OUT temp_blk_read_time double precision, OUT temp_blk_write_time double precision, OUT wal_records bigint, OUT wal_fpi bigint, OUT wal_bytes numeric, OUT jit_functions bigint, OUT jit_generation_time double precision, OUT jit_inlining_count bigint, OUT jit_inlining_time double precision, OUT jit_optimization_count bigint, OUT jit_optimization_time double precision, OUT jit_emission_count bigint, OUT jit_emission_time double precision, OUT jit_deform_count bigint, OUT jit_deform_time double precision, OUT stats_since timestamp with time zone, OUT minmax_stats_since timestamp with time zone) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pg_stat_statements(showtext boolean, OUT userid oid, OUT dbid oid, OUT toplevel boolean, OUT queryid bigint, OUT query text, OUT plans bigint, OUT total_plan_time double precision, OUT min_plan_time double precision, OUT max_plan_time double precision, OUT mean_plan_time double precision, OUT stddev_plan_time double precision, OUT calls bigint, OUT total_exec_time double precision, OUT min_exec_time double precision, OUT max_exec_time double precision, OUT mean_exec_time double precision, OUT stddev_exec_time double precision, OUT rows bigint, OUT shared_blks_hit bigint, OUT shared_blks_read bigint, OUT shared_blks_dirtied bigint, OUT shared_blks_written bigint, OUT local_blks_hit bigint, OUT local_blks_read bigint, OUT local_blks_dirtied bigint, OUT local_blks_written bigint, OUT temp_blks_read bigint, OUT temp_blks_written bigint, OUT shared_blk_read_time double precision, OUT shared_blk_write_time double precision, OUT local_blk_read_time double precision, OUT local_blk_write_time double precision, OUT temp_blk_read_time double precision, OUT temp_blk_write_time double precision, OUT wal_records bigint, OUT wal_fpi bigint, OUT wal_bytes numeric, OUT jit_functions bigint, OUT jit_generation_time double precision, OUT jit_inlining_count bigint, OUT jit_inlining_time double precision, OUT jit_optimization_count bigint, OUT jit_optimization_time double precision, OUT jit_emission_count bigint, OUT jit_emission_time double precision, OUT jit_deform_count bigint, OUT jit_deform_time double precision, OUT stats_since timestamp with time zone, OUT minmax_stats_since timestamp with time zone) TO dashboard_user;


--
-- Name: FUNCTION pg_stat_statements_info(OUT dealloc bigint, OUT stats_reset timestamp with time zone); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pg_stat_statements_info(OUT dealloc bigint, OUT stats_reset timestamp with time zone) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pg_stat_statements_info(OUT dealloc bigint, OUT stats_reset timestamp with time zone) TO dashboard_user;


--
-- Name: FUNCTION pg_stat_statements_reset(userid oid, dbid oid, queryid bigint, minmax_only boolean); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pg_stat_statements_reset(userid oid, dbid oid, queryid bigint, minmax_only boolean) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pg_stat_statements_reset(userid oid, dbid oid, queryid bigint, minmax_only boolean) TO dashboard_user;


--
-- Name: FUNCTION pgp_armor_headers(text, OUT key text, OUT value text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_armor_headers(text, OUT key text, OUT value text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_armor_headers(text, OUT key text, OUT value text) TO dashboard_user;


--
-- Name: FUNCTION pgp_key_id(bytea); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_key_id(bytea) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_key_id(bytea) TO dashboard_user;


--
-- Name: FUNCTION pgp_pub_decrypt(bytea, bytea); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea) TO dashboard_user;


--
-- Name: FUNCTION pgp_pub_decrypt(bytea, bytea, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_pub_decrypt(bytea, bytea, text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea, text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea, text, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_pub_decrypt_bytea(bytea, bytea); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea) TO dashboard_user;


--
-- Name: FUNCTION pgp_pub_decrypt_bytea(bytea, bytea, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_pub_decrypt_bytea(bytea, bytea, text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea, text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea, text, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_pub_encrypt(text, bytea); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt(text, bytea) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt(text, bytea) TO dashboard_user;


--
-- Name: FUNCTION pgp_pub_encrypt(text, bytea, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt(text, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt(text, bytea, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_pub_encrypt_bytea(bytea, bytea); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt_bytea(bytea, bytea) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt_bytea(bytea, bytea) TO dashboard_user;


--
-- Name: FUNCTION pgp_pub_encrypt_bytea(bytea, bytea, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt_bytea(bytea, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt_bytea(bytea, bytea, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_sym_decrypt(bytea, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt(bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt(bytea, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_sym_decrypt(bytea, text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt(bytea, text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt(bytea, text, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_sym_decrypt_bytea(bytea, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt_bytea(bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt_bytea(bytea, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_sym_decrypt_bytea(bytea, text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt_bytea(bytea, text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt_bytea(bytea, text, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_sym_encrypt(text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt(text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt(text, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_sym_encrypt(text, text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt(text, text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt(text, text, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_sym_encrypt_bytea(bytea, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt_bytea(bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt_bytea(bytea, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_sym_encrypt_bytea(bytea, text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt_bytea(bytea, text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt_bytea(bytea, text, text) TO dashboard_user;


--
-- Name: FUNCTION pgrst_ddl_watch(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgrst_ddl_watch() TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pgrst_drop_watch(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgrst_drop_watch() TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION set_graphql_placeholder(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.set_graphql_placeholder() TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION uuid_generate_v1(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.uuid_generate_v1() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_generate_v1() TO dashboard_user;


--
-- Name: FUNCTION uuid_generate_v1mc(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.uuid_generate_v1mc() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_generate_v1mc() TO dashboard_user;


--
-- Name: FUNCTION uuid_generate_v3(namespace uuid, name text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.uuid_generate_v3(namespace uuid, name text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_generate_v3(namespace uuid, name text) TO dashboard_user;


--
-- Name: FUNCTION uuid_generate_v4(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.uuid_generate_v4() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_generate_v4() TO dashboard_user;


--
-- Name: FUNCTION uuid_generate_v5(namespace uuid, name text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.uuid_generate_v5(namespace uuid, name text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_generate_v5(namespace uuid, name text) TO dashboard_user;


--
-- Name: FUNCTION uuid_nil(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.uuid_nil() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_nil() TO dashboard_user;


--
-- Name: FUNCTION uuid_ns_dns(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.uuid_ns_dns() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_ns_dns() TO dashboard_user;


--
-- Name: FUNCTION uuid_ns_oid(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.uuid_ns_oid() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_ns_oid() TO dashboard_user;


--
-- Name: FUNCTION uuid_ns_url(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.uuid_ns_url() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_ns_url() TO dashboard_user;


--
-- Name: FUNCTION uuid_ns_x500(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.uuid_ns_x500() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_ns_x500() TO dashboard_user;


--
-- Name: FUNCTION graphql("operationName" text, query text, variables jsonb, extensions jsonb); Type: ACL; Schema: graphql_public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION graphql_public.graphql("operationName" text, query text, variables jsonb, extensions jsonb) TO postgres;
GRANT ALL ON FUNCTION graphql_public.graphql("operationName" text, query text, variables jsonb, extensions jsonb) TO anon;
GRANT ALL ON FUNCTION graphql_public.graphql("operationName" text, query text, variables jsonb, extensions jsonb) TO authenticated;
GRANT ALL ON FUNCTION graphql_public.graphql("operationName" text, query text, variables jsonb, extensions jsonb) TO service_role;


--
-- Name: FUNCTION get_auth(p_usename text); Type: ACL; Schema: pgbouncer; Owner: supabase_admin
--

REVOKE ALL ON FUNCTION pgbouncer.get_auth(p_usename text) FROM PUBLIC;
GRANT ALL ON FUNCTION pgbouncer.get_auth(p_usename text) TO pgbouncer;


--
-- Name: FUNCTION check_merge_conflicts(p_old_auth_uid text, p_new_auth_uid text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.check_merge_conflicts(p_old_auth_uid text, p_new_auth_uid text) TO anon;
GRANT ALL ON FUNCTION public.check_merge_conflicts(p_old_auth_uid text, p_new_auth_uid text) TO authenticated;
GRANT ALL ON FUNCTION public.check_merge_conflicts(p_old_auth_uid text, p_new_auth_uid text) TO service_role;


--
-- Name: FUNCTION compare_semver(version_a text, version_b text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.compare_semver(version_a text, version_b text) TO anon;
GRANT ALL ON FUNCTION public.compare_semver(version_a text, version_b text) TO authenticated;
GRANT ALL ON FUNCTION public.compare_semver(version_a text, version_b text) TO service_role;


--
-- Name: FUNCTION consolidate_users_by_auth_uid(p_old_auth_uid text, p_new_auth_uid text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.consolidate_users_by_auth_uid(p_old_auth_uid text, p_new_auth_uid text) TO anon;
GRANT ALL ON FUNCTION public.consolidate_users_by_auth_uid(p_old_auth_uid text, p_new_auth_uid text) TO authenticated;
GRANT ALL ON FUNCTION public.consolidate_users_by_auth_uid(p_old_auth_uid text, p_new_auth_uid text) TO service_role;


--
-- Name: FUNCTION fetch_active_announcements(p_user_id text, p_app_version text, p_platform text, p_limit integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.fetch_active_announcements(p_user_id text, p_app_version text, p_platform text, p_limit integer) TO anon;
GRANT ALL ON FUNCTION public.fetch_active_announcements(p_user_id text, p_app_version text, p_platform text, p_limit integer) TO authenticated;
GRANT ALL ON FUNCTION public.fetch_active_announcements(p_user_id text, p_app_version text, p_platform text, p_limit integer) TO service_role;


--
-- Name: FUNCTION fn_process_tool_usage_event(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.fn_process_tool_usage_event() TO anon;
GRANT ALL ON FUNCTION public.fn_process_tool_usage_event() TO authenticated;
GRANT ALL ON FUNCTION public.fn_process_tool_usage_event() TO service_role;


--
-- Name: FUNCTION get_admin_overview_metrics(p_days integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.get_admin_overview_metrics(p_days integer) TO anon;
GRANT ALL ON FUNCTION public.get_admin_overview_metrics(p_days integer) TO authenticated;
GRANT ALL ON FUNCTION public.get_admin_overview_metrics(p_days integer) TO service_role;


--
-- Name: FUNCTION get_carousel_announcements(p_user_id text, p_device_id text, p_auth_uid text, p_platform text, p_app_version text, p_country text, p_city text, p_is_logged_in boolean, p_profession text, p_speciality text, p_degree text, p_experience text, p_has_complete_profile boolean, p_session_number integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.get_carousel_announcements(p_user_id text, p_device_id text, p_auth_uid text, p_platform text, p_app_version text, p_country text, p_city text, p_is_logged_in boolean, p_profession text, p_speciality text, p_degree text, p_experience text, p_has_complete_profile boolean, p_session_number integer) TO anon;
GRANT ALL ON FUNCTION public.get_carousel_announcements(p_user_id text, p_device_id text, p_auth_uid text, p_platform text, p_app_version text, p_country text, p_city text, p_is_logged_in boolean, p_profession text, p_speciality text, p_degree text, p_experience text, p_has_complete_profile boolean, p_session_number integer) TO authenticated;
GRANT ALL ON FUNCTION public.get_carousel_announcements(p_user_id text, p_device_id text, p_auth_uid text, p_platform text, p_app_version text, p_country text, p_city text, p_is_logged_in boolean, p_profession text, p_speciality text, p_degree text, p_experience text, p_has_complete_profile boolean, p_session_number integer) TO service_role;


--
-- Name: FUNCTION get_current_user_firebase_uid(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.get_current_user_firebase_uid() TO anon;
GRANT ALL ON FUNCTION public.get_current_user_firebase_uid() TO authenticated;
GRANT ALL ON FUNCTION public.get_current_user_firebase_uid() TO service_role;


--
-- Name: FUNCTION get_eligible_announcements(p_user_id text, p_device_id text, p_auth_uid text, p_platform text, p_app_version text, p_country text, p_city text, p_is_logged_in boolean, p_profession text, p_speciality text, p_degree text, p_experience text, p_has_complete_profile boolean, p_session_number integer, p_surface text, p_limit integer, p_offset integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.get_eligible_announcements(p_user_id text, p_device_id text, p_auth_uid text, p_platform text, p_app_version text, p_country text, p_city text, p_is_logged_in boolean, p_profession text, p_speciality text, p_degree text, p_experience text, p_has_complete_profile boolean, p_session_number integer, p_surface text, p_limit integer, p_offset integer) TO anon;
GRANT ALL ON FUNCTION public.get_eligible_announcements(p_user_id text, p_device_id text, p_auth_uid text, p_platform text, p_app_version text, p_country text, p_city text, p_is_logged_in boolean, p_profession text, p_speciality text, p_degree text, p_experience text, p_has_complete_profile boolean, p_session_number integer, p_surface text, p_limit integer, p_offset integer) TO authenticated;
GRANT ALL ON FUNCTION public.get_eligible_announcements(p_user_id text, p_device_id text, p_auth_uid text, p_platform text, p_app_version text, p_country text, p_city text, p_is_logged_in boolean, p_profession text, p_speciality text, p_degree text, p_experience text, p_has_complete_profile boolean, p_session_number integer, p_surface text, p_limit integer, p_offset integer) TO service_role;


--
-- Name: FUNCTION get_eligible_announcements_fast(p_user_id text, p_device_id text, p_auth_uid text, p_platform text, p_app_version text, p_country text, p_city text, p_is_logged_in boolean, p_profession text, p_speciality text, p_degree text, p_experience text, p_has_complete_profile boolean, p_session_number integer, p_surface text, p_limit integer, p_offset integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.get_eligible_announcements_fast(p_user_id text, p_device_id text, p_auth_uid text, p_platform text, p_app_version text, p_country text, p_city text, p_is_logged_in boolean, p_profession text, p_speciality text, p_degree text, p_experience text, p_has_complete_profile boolean, p_session_number integer, p_surface text, p_limit integer, p_offset integer) TO anon;
GRANT ALL ON FUNCTION public.get_eligible_announcements_fast(p_user_id text, p_device_id text, p_auth_uid text, p_platform text, p_app_version text, p_country text, p_city text, p_is_logged_in boolean, p_profession text, p_speciality text, p_degree text, p_experience text, p_has_complete_profile boolean, p_session_number integer, p_surface text, p_limit integer, p_offset integer) TO authenticated;
GRANT ALL ON FUNCTION public.get_eligible_announcements_fast(p_user_id text, p_device_id text, p_auth_uid text, p_platform text, p_app_version text, p_country text, p_city text, p_is_logged_in boolean, p_profession text, p_speciality text, p_degree text, p_experience text, p_has_complete_profile boolean, p_session_number integer, p_surface text, p_limit integer, p_offset integer) TO service_role;


--
-- Name: FUNCTION get_inbox_announcements(p_user_id text, p_device_id text, p_auth_uid text, p_platform text, p_is_logged_in boolean, p_profession text, p_speciality text, p_degree text, p_experience text, p_has_complete_profile boolean, p_session_number integer, p_page integer, p_page_size integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.get_inbox_announcements(p_user_id text, p_device_id text, p_auth_uid text, p_platform text, p_is_logged_in boolean, p_profession text, p_speciality text, p_degree text, p_experience text, p_has_complete_profile boolean, p_session_number integer, p_page integer, p_page_size integer) TO anon;
GRANT ALL ON FUNCTION public.get_inbox_announcements(p_user_id text, p_device_id text, p_auth_uid text, p_platform text, p_is_logged_in boolean, p_profession text, p_speciality text, p_degree text, p_experience text, p_has_complete_profile boolean, p_session_number integer, p_page integer, p_page_size integer) TO authenticated;
GRANT ALL ON FUNCTION public.get_inbox_announcements(p_user_id text, p_device_id text, p_auth_uid text, p_platform text, p_is_logged_in boolean, p_profession text, p_speciality text, p_degree text, p_experience text, p_has_complete_profile boolean, p_session_number integer, p_page integer, p_page_size integer) TO service_role;


--
-- Name: FUNCTION get_targeted_announcements(p_user_auth_uid text, p_surface text, p_app_version text, p_platform text, p_country text, p_city text, p_is_real_device boolean, p_device_brand text, p_ip_address text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.get_targeted_announcements(p_user_auth_uid text, p_surface text, p_app_version text, p_platform text, p_country text, p_city text, p_is_real_device boolean, p_device_brand text, p_ip_address text) TO anon;
GRANT ALL ON FUNCTION public.get_targeted_announcements(p_user_auth_uid text, p_surface text, p_app_version text, p_platform text, p_country text, p_city text, p_is_real_device boolean, p_device_brand text, p_ip_address text) TO authenticated;
GRANT ALL ON FUNCTION public.get_targeted_announcements(p_user_auth_uid text, p_surface text, p_app_version text, p_platform text, p_country text, p_city text, p_is_real_device boolean, p_device_brand text, p_ip_address text) TO service_role;


--
-- Name: FUNCTION get_tool_usage_by_period(p_start_date timestamp with time zone, p_end_date timestamp with time zone, p_tool_id text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.get_tool_usage_by_period(p_start_date timestamp with time zone, p_end_date timestamp with time zone, p_tool_id text) TO anon;
GRANT ALL ON FUNCTION public.get_tool_usage_by_period(p_start_date timestamp with time zone, p_end_date timestamp with time zone, p_tool_id text) TO authenticated;
GRANT ALL ON FUNCTION public.get_tool_usage_by_period(p_start_date timestamp with time zone, p_end_date timestamp with time zone, p_tool_id text) TO service_role;


--
-- Name: FUNCTION get_tool_usage_cities(p_tool_id text, p_days integer, p_limit integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.get_tool_usage_cities(p_tool_id text, p_days integer, p_limit integer) TO anon;
GRANT ALL ON FUNCTION public.get_tool_usage_cities(p_tool_id text, p_days integer, p_limit integer) TO authenticated;
GRANT ALL ON FUNCTION public.get_tool_usage_cities(p_tool_id text, p_days integer, p_limit integer) TO service_role;


--
-- Name: FUNCTION get_tool_usage_countries(p_tool_id text, p_days integer, p_limit integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.get_tool_usage_countries(p_tool_id text, p_days integer, p_limit integer) TO anon;
GRANT ALL ON FUNCTION public.get_tool_usage_countries(p_tool_id text, p_days integer, p_limit integer) TO authenticated;
GRANT ALL ON FUNCTION public.get_tool_usage_countries(p_tool_id text, p_days integer, p_limit integer) TO service_role;


--
-- Name: FUNCTION get_tool_usage_daily(p_tool_id text, p_days integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.get_tool_usage_daily(p_tool_id text, p_days integer) TO anon;
GRANT ALL ON FUNCTION public.get_tool_usage_daily(p_tool_id text, p_days integer) TO authenticated;
GRANT ALL ON FUNCTION public.get_tool_usage_daily(p_tool_id text, p_days integer) TO service_role;


--
-- Name: FUNCTION get_tool_usage_daily_by_country(p_tool_id text, p_days integer, p_countries text[]); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.get_tool_usage_daily_by_country(p_tool_id text, p_days integer, p_countries text[]) TO anon;
GRANT ALL ON FUNCTION public.get_tool_usage_daily_by_country(p_tool_id text, p_days integer, p_countries text[]) TO authenticated;
GRANT ALL ON FUNCTION public.get_tool_usage_daily_by_country(p_tool_id text, p_days integer, p_countries text[]) TO service_role;


--
-- Name: FUNCTION get_tool_usage_leaderboard(p_days integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.get_tool_usage_leaderboard(p_days integer) TO anon;
GRANT ALL ON FUNCTION public.get_tool_usage_leaderboard(p_days integer) TO authenticated;
GRANT ALL ON FUNCTION public.get_tool_usage_leaderboard(p_days integer) TO service_role;


--
-- Name: FUNCTION get_user_analytics_summary(p_user_id uuid, p_days integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.get_user_analytics_summary(p_user_id uuid, p_days integer) TO anon;
GRANT ALL ON FUNCTION public.get_user_analytics_summary(p_user_id uuid, p_days integer) TO authenticated;
GRANT ALL ON FUNCTION public.get_user_analytics_summary(p_user_id uuid, p_days integer) TO service_role;


--
-- Name: FUNCTION get_user_retention(p_cohort_start date, p_cohort_end date); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.get_user_retention(p_cohort_start date, p_cohort_end date) TO anon;
GRANT ALL ON FUNCTION public.get_user_retention(p_cohort_start date, p_cohort_end date) TO authenticated;
GRANT ALL ON FUNCTION public.get_user_retention(p_cohort_start date, p_cohort_end date) TO service_role;


--
-- Name: FUNCTION gin_extract_query_trgm(text, internal, smallint, internal, internal, internal, internal); Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION public.gin_extract_query_trgm(text, internal, smallint, internal, internal, internal, internal) TO postgres;
GRANT ALL ON FUNCTION public.gin_extract_query_trgm(text, internal, smallint, internal, internal, internal, internal) TO anon;
GRANT ALL ON FUNCTION public.gin_extract_query_trgm(text, internal, smallint, internal, internal, internal, internal) TO authenticated;
GRANT ALL ON FUNCTION public.gin_extract_query_trgm(text, internal, smallint, internal, internal, internal, internal) TO service_role;


--
-- Name: FUNCTION gin_extract_value_trgm(text, internal); Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION public.gin_extract_value_trgm(text, internal) TO postgres;
GRANT ALL ON FUNCTION public.gin_extract_value_trgm(text, internal) TO anon;
GRANT ALL ON FUNCTION public.gin_extract_value_trgm(text, internal) TO authenticated;
GRANT ALL ON FUNCTION public.gin_extract_value_trgm(text, internal) TO service_role;


--
-- Name: FUNCTION gin_trgm_consistent(internal, smallint, text, integer, internal, internal, internal, internal); Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION public.gin_trgm_consistent(internal, smallint, text, integer, internal, internal, internal, internal) TO postgres;
GRANT ALL ON FUNCTION public.gin_trgm_consistent(internal, smallint, text, integer, internal, internal, internal, internal) TO anon;
GRANT ALL ON FUNCTION public.gin_trgm_consistent(internal, smallint, text, integer, internal, internal, internal, internal) TO authenticated;
GRANT ALL ON FUNCTION public.gin_trgm_consistent(internal, smallint, text, integer, internal, internal, internal, internal) TO service_role;


--
-- Name: FUNCTION gin_trgm_triconsistent(internal, smallint, text, integer, internal, internal, internal); Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION public.gin_trgm_triconsistent(internal, smallint, text, integer, internal, internal, internal) TO postgres;
GRANT ALL ON FUNCTION public.gin_trgm_triconsistent(internal, smallint, text, integer, internal, internal, internal) TO anon;
GRANT ALL ON FUNCTION public.gin_trgm_triconsistent(internal, smallint, text, integer, internal, internal, internal) TO authenticated;
GRANT ALL ON FUNCTION public.gin_trgm_triconsistent(internal, smallint, text, integer, internal, internal, internal) TO service_role;


--
-- Name: FUNCTION gtrgm_compress(internal); Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION public.gtrgm_compress(internal) TO postgres;
GRANT ALL ON FUNCTION public.gtrgm_compress(internal) TO anon;
GRANT ALL ON FUNCTION public.gtrgm_compress(internal) TO authenticated;
GRANT ALL ON FUNCTION public.gtrgm_compress(internal) TO service_role;


--
-- Name: FUNCTION gtrgm_consistent(internal, text, smallint, oid, internal); Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION public.gtrgm_consistent(internal, text, smallint, oid, internal) TO postgres;
GRANT ALL ON FUNCTION public.gtrgm_consistent(internal, text, smallint, oid, internal) TO anon;
GRANT ALL ON FUNCTION public.gtrgm_consistent(internal, text, smallint, oid, internal) TO authenticated;
GRANT ALL ON FUNCTION public.gtrgm_consistent(internal, text, smallint, oid, internal) TO service_role;


--
-- Name: FUNCTION gtrgm_decompress(internal); Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION public.gtrgm_decompress(internal) TO postgres;
GRANT ALL ON FUNCTION public.gtrgm_decompress(internal) TO anon;
GRANT ALL ON FUNCTION public.gtrgm_decompress(internal) TO authenticated;
GRANT ALL ON FUNCTION public.gtrgm_decompress(internal) TO service_role;


--
-- Name: FUNCTION gtrgm_distance(internal, text, smallint, oid, internal); Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION public.gtrgm_distance(internal, text, smallint, oid, internal) TO postgres;
GRANT ALL ON FUNCTION public.gtrgm_distance(internal, text, smallint, oid, internal) TO anon;
GRANT ALL ON FUNCTION public.gtrgm_distance(internal, text, smallint, oid, internal) TO authenticated;
GRANT ALL ON FUNCTION public.gtrgm_distance(internal, text, smallint, oid, internal) TO service_role;


--
-- Name: FUNCTION gtrgm_options(internal); Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION public.gtrgm_options(internal) TO postgres;
GRANT ALL ON FUNCTION public.gtrgm_options(internal) TO anon;
GRANT ALL ON FUNCTION public.gtrgm_options(internal) TO authenticated;
GRANT ALL ON FUNCTION public.gtrgm_options(internal) TO service_role;


--
-- Name: FUNCTION gtrgm_penalty(internal, internal, internal); Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION public.gtrgm_penalty(internal, internal, internal) TO postgres;
GRANT ALL ON FUNCTION public.gtrgm_penalty(internal, internal, internal) TO anon;
GRANT ALL ON FUNCTION public.gtrgm_penalty(internal, internal, internal) TO authenticated;
GRANT ALL ON FUNCTION public.gtrgm_penalty(internal, internal, internal) TO service_role;


--
-- Name: FUNCTION gtrgm_picksplit(internal, internal); Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION public.gtrgm_picksplit(internal, internal) TO postgres;
GRANT ALL ON FUNCTION public.gtrgm_picksplit(internal, internal) TO anon;
GRANT ALL ON FUNCTION public.gtrgm_picksplit(internal, internal) TO authenticated;
GRANT ALL ON FUNCTION public.gtrgm_picksplit(internal, internal) TO service_role;


--
-- Name: FUNCTION gtrgm_same(public.gtrgm, public.gtrgm, internal); Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION public.gtrgm_same(public.gtrgm, public.gtrgm, internal) TO postgres;
GRANT ALL ON FUNCTION public.gtrgm_same(public.gtrgm, public.gtrgm, internal) TO anon;
GRANT ALL ON FUNCTION public.gtrgm_same(public.gtrgm, public.gtrgm, internal) TO authenticated;
GRANT ALL ON FUNCTION public.gtrgm_same(public.gtrgm, public.gtrgm, internal) TO service_role;


--
-- Name: FUNCTION gtrgm_union(internal, internal); Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION public.gtrgm_union(internal, internal) TO postgres;
GRANT ALL ON FUNCTION public.gtrgm_union(internal, internal) TO anon;
GRANT ALL ON FUNCTION public.gtrgm_union(internal, internal) TO authenticated;
GRANT ALL ON FUNCTION public.gtrgm_union(internal, internal) TO service_role;


--
-- Name: FUNCTION mark_announcement_status(p_user_id text, p_announcement_id uuid, p_status text, p_metadata jsonb); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.mark_announcement_status(p_user_id text, p_announcement_id uuid, p_status text, p_metadata jsonb) TO anon;
GRANT ALL ON FUNCTION public.mark_announcement_status(p_user_id text, p_announcement_id uuid, p_status text, p_metadata jsonb) TO authenticated;
GRANT ALL ON FUNCTION public.mark_announcement_status(p_user_id text, p_announcement_id uuid, p_status text, p_metadata jsonb) TO service_role;


--
-- Name: FUNCTION migrate_user_auth_uid(p_user_id text, p_new_auth_uid text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.migrate_user_auth_uid(p_user_id text, p_new_auth_uid text) TO anon;
GRANT ALL ON FUNCTION public.migrate_user_auth_uid(p_user_id text, p_new_auth_uid text) TO authenticated;
GRANT ALL ON FUNCTION public.migrate_user_auth_uid(p_user_id text, p_new_auth_uid text) TO service_role;


--
-- Name: FUNCTION record_announcement_impression(p_announcement_id uuid, p_user_id text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.record_announcement_impression(p_announcement_id uuid, p_user_id text) TO anon;
GRANT ALL ON FUNCTION public.record_announcement_impression(p_announcement_id uuid, p_user_id text) TO authenticated;
GRANT ALL ON FUNCTION public.record_announcement_impression(p_announcement_id uuid, p_user_id text) TO service_role;


--
-- Name: FUNCTION set_limit(real); Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION public.set_limit(real) TO postgres;
GRANT ALL ON FUNCTION public.set_limit(real) TO anon;
GRANT ALL ON FUNCTION public.set_limit(real) TO authenticated;
GRANT ALL ON FUNCTION public.set_limit(real) TO service_role;


--
-- Name: FUNCTION show_limit(); Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION public.show_limit() TO postgres;
GRANT ALL ON FUNCTION public.show_limit() TO anon;
GRANT ALL ON FUNCTION public.show_limit() TO authenticated;
GRANT ALL ON FUNCTION public.show_limit() TO service_role;


--
-- Name: FUNCTION show_trgm(text); Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION public.show_trgm(text) TO postgres;
GRANT ALL ON FUNCTION public.show_trgm(text) TO anon;
GRANT ALL ON FUNCTION public.show_trgm(text) TO authenticated;
GRANT ALL ON FUNCTION public.show_trgm(text) TO service_role;


--
-- Name: FUNCTION similarity(text, text); Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION public.similarity(text, text) TO postgres;
GRANT ALL ON FUNCTION public.similarity(text, text) TO anon;
GRANT ALL ON FUNCTION public.similarity(text, text) TO authenticated;
GRANT ALL ON FUNCTION public.similarity(text, text) TO service_role;


--
-- Name: FUNCTION similarity_dist(text, text); Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION public.similarity_dist(text, text) TO postgres;
GRANT ALL ON FUNCTION public.similarity_dist(text, text) TO anon;
GRANT ALL ON FUNCTION public.similarity_dist(text, text) TO authenticated;
GRANT ALL ON FUNCTION public.similarity_dist(text, text) TO service_role;


--
-- Name: FUNCTION similarity_op(text, text); Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION public.similarity_op(text, text) TO postgres;
GRANT ALL ON FUNCTION public.similarity_op(text, text) TO anon;
GRANT ALL ON FUNCTION public.similarity_op(text, text) TO authenticated;
GRANT ALL ON FUNCTION public.similarity_op(text, text) TO service_role;


--
-- Name: FUNCTION strict_word_similarity(text, text); Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION public.strict_word_similarity(text, text) TO postgres;
GRANT ALL ON FUNCTION public.strict_word_similarity(text, text) TO anon;
GRANT ALL ON FUNCTION public.strict_word_similarity(text, text) TO authenticated;
GRANT ALL ON FUNCTION public.strict_word_similarity(text, text) TO service_role;


--
-- Name: FUNCTION strict_word_similarity_commutator_op(text, text); Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION public.strict_word_similarity_commutator_op(text, text) TO postgres;
GRANT ALL ON FUNCTION public.strict_word_similarity_commutator_op(text, text) TO anon;
GRANT ALL ON FUNCTION public.strict_word_similarity_commutator_op(text, text) TO authenticated;
GRANT ALL ON FUNCTION public.strict_word_similarity_commutator_op(text, text) TO service_role;


--
-- Name: FUNCTION strict_word_similarity_dist_commutator_op(text, text); Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION public.strict_word_similarity_dist_commutator_op(text, text) TO postgres;
GRANT ALL ON FUNCTION public.strict_word_similarity_dist_commutator_op(text, text) TO anon;
GRANT ALL ON FUNCTION public.strict_word_similarity_dist_commutator_op(text, text) TO authenticated;
GRANT ALL ON FUNCTION public.strict_word_similarity_dist_commutator_op(text, text) TO service_role;


--
-- Name: FUNCTION strict_word_similarity_dist_op(text, text); Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION public.strict_word_similarity_dist_op(text, text) TO postgres;
GRANT ALL ON FUNCTION public.strict_word_similarity_dist_op(text, text) TO anon;
GRANT ALL ON FUNCTION public.strict_word_similarity_dist_op(text, text) TO authenticated;
GRANT ALL ON FUNCTION public.strict_word_similarity_dist_op(text, text) TO service_role;


--
-- Name: FUNCTION strict_word_similarity_op(text, text); Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION public.strict_word_similarity_op(text, text) TO postgres;
GRANT ALL ON FUNCTION public.strict_word_similarity_op(text, text) TO anon;
GRANT ALL ON FUNCTION public.strict_word_similarity_op(text, text) TO authenticated;
GRANT ALL ON FUNCTION public.strict_word_similarity_op(text, text) TO service_role;


--
-- Name: FUNCTION update_announcement_state(p_announcement_id uuid, p_user_id text, p_status text, p_session_number integer, p_defer_sessions integer, p_defer_hours integer, p_questions_answered integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.update_announcement_state(p_announcement_id uuid, p_user_id text, p_status text, p_session_number integer, p_defer_sessions integer, p_defer_hours integer, p_questions_answered integer) TO anon;
GRANT ALL ON FUNCTION public.update_announcement_state(p_announcement_id uuid, p_user_id text, p_status text, p_session_number integer, p_defer_sessions integer, p_defer_hours integer, p_questions_answered integer) TO authenticated;
GRANT ALL ON FUNCTION public.update_announcement_state(p_announcement_id uuid, p_user_id text, p_status text, p_session_number integer, p_defer_sessions integer, p_defer_hours integer, p_questions_answered integer) TO service_role;


--
-- Name: FUNCTION update_last_updated_column(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.update_last_updated_column() TO anon;
GRANT ALL ON FUNCTION public.update_last_updated_column() TO authenticated;
GRANT ALL ON FUNCTION public.update_last_updated_column() TO service_role;


--
-- Name: FUNCTION update_updated_at_column(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.update_updated_at_column() TO anon;
GRANT ALL ON FUNCTION public.update_updated_at_column() TO authenticated;
GRANT ALL ON FUNCTION public.update_updated_at_column() TO service_role;


--
-- Name: FUNCTION update_user_insights_from_response(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.update_user_insights_from_response() TO anon;
GRANT ALL ON FUNCTION public.update_user_insights_from_response() TO authenticated;
GRANT ALL ON FUNCTION public.update_user_insights_from_response() TO service_role;


--
-- Name: FUNCTION update_user_location_from_session(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.update_user_location_from_session() TO anon;
GRANT ALL ON FUNCTION public.update_user_location_from_session() TO authenticated;
GRANT ALL ON FUNCTION public.update_user_location_from_session() TO service_role;


--
-- Name: FUNCTION user_owns_data(target_user_id text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.user_owns_data(target_user_id text) TO anon;
GRANT ALL ON FUNCTION public.user_owns_data(target_user_id text) TO authenticated;
GRANT ALL ON FUNCTION public.user_owns_data(target_user_id text) TO service_role;


--
-- Name: FUNCTION word_similarity(text, text); Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION public.word_similarity(text, text) TO postgres;
GRANT ALL ON FUNCTION public.word_similarity(text, text) TO anon;
GRANT ALL ON FUNCTION public.word_similarity(text, text) TO authenticated;
GRANT ALL ON FUNCTION public.word_similarity(text, text) TO service_role;


--
-- Name: FUNCTION word_similarity_commutator_op(text, text); Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION public.word_similarity_commutator_op(text, text) TO postgres;
GRANT ALL ON FUNCTION public.word_similarity_commutator_op(text, text) TO anon;
GRANT ALL ON FUNCTION public.word_similarity_commutator_op(text, text) TO authenticated;
GRANT ALL ON FUNCTION public.word_similarity_commutator_op(text, text) TO service_role;


--
-- Name: FUNCTION word_similarity_dist_commutator_op(text, text); Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION public.word_similarity_dist_commutator_op(text, text) TO postgres;
GRANT ALL ON FUNCTION public.word_similarity_dist_commutator_op(text, text) TO anon;
GRANT ALL ON FUNCTION public.word_similarity_dist_commutator_op(text, text) TO authenticated;
GRANT ALL ON FUNCTION public.word_similarity_dist_commutator_op(text, text) TO service_role;


--
-- Name: FUNCTION word_similarity_dist_op(text, text); Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION public.word_similarity_dist_op(text, text) TO postgres;
GRANT ALL ON FUNCTION public.word_similarity_dist_op(text, text) TO anon;
GRANT ALL ON FUNCTION public.word_similarity_dist_op(text, text) TO authenticated;
GRANT ALL ON FUNCTION public.word_similarity_dist_op(text, text) TO service_role;


--
-- Name: FUNCTION word_similarity_op(text, text); Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION public.word_similarity_op(text, text) TO postgres;
GRANT ALL ON FUNCTION public.word_similarity_op(text, text) TO anon;
GRANT ALL ON FUNCTION public.word_similarity_op(text, text) TO authenticated;
GRANT ALL ON FUNCTION public.word_similarity_op(text, text) TO service_role;


--
-- Name: FUNCTION apply_rls(wal jsonb, max_record_bytes integer); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) TO postgres;
GRANT ALL ON FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) TO anon;
GRANT ALL ON FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) TO authenticated;
GRANT ALL ON FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) TO service_role;
GRANT ALL ON FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) TO supabase_realtime_admin;


--
-- Name: FUNCTION broadcast_changes(topic_name text, event_name text, operation text, table_name text, table_schema text, new record, old record, level text); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.broadcast_changes(topic_name text, event_name text, operation text, table_name text, table_schema text, new record, old record, level text) TO postgres;
GRANT ALL ON FUNCTION realtime.broadcast_changes(topic_name text, event_name text, operation text, table_name text, table_schema text, new record, old record, level text) TO dashboard_user;


--
-- Name: FUNCTION build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) TO postgres;
GRANT ALL ON FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) TO anon;
GRANT ALL ON FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) TO authenticated;
GRANT ALL ON FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) TO service_role;
GRANT ALL ON FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) TO supabase_realtime_admin;


--
-- Name: FUNCTION "cast"(val text, type_ regtype); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime."cast"(val text, type_ regtype) TO postgres;
GRANT ALL ON FUNCTION realtime."cast"(val text, type_ regtype) TO dashboard_user;
GRANT ALL ON FUNCTION realtime."cast"(val text, type_ regtype) TO anon;
GRANT ALL ON FUNCTION realtime."cast"(val text, type_ regtype) TO authenticated;
GRANT ALL ON FUNCTION realtime."cast"(val text, type_ regtype) TO service_role;
GRANT ALL ON FUNCTION realtime."cast"(val text, type_ regtype) TO supabase_realtime_admin;


--
-- Name: FUNCTION check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) TO postgres;
GRANT ALL ON FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) TO anon;
GRANT ALL ON FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) TO authenticated;
GRANT ALL ON FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) TO service_role;
GRANT ALL ON FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) TO supabase_realtime_admin;


--
-- Name: FUNCTION is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) TO postgres;
GRANT ALL ON FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) TO anon;
GRANT ALL ON FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) TO authenticated;
GRANT ALL ON FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) TO service_role;
GRANT ALL ON FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) TO supabase_realtime_admin;


--
-- Name: FUNCTION list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) TO postgres;
GRANT ALL ON FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) TO anon;
GRANT ALL ON FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) TO authenticated;
GRANT ALL ON FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) TO service_role;
GRANT ALL ON FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) TO supabase_realtime_admin;


--
-- Name: FUNCTION quote_wal2json(entity regclass); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.quote_wal2json(entity regclass) TO postgres;
GRANT ALL ON FUNCTION realtime.quote_wal2json(entity regclass) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.quote_wal2json(entity regclass) TO anon;
GRANT ALL ON FUNCTION realtime.quote_wal2json(entity regclass) TO authenticated;
GRANT ALL ON FUNCTION realtime.quote_wal2json(entity regclass) TO service_role;
GRANT ALL ON FUNCTION realtime.quote_wal2json(entity regclass) TO supabase_realtime_admin;


--
-- Name: FUNCTION send(payload jsonb, event text, topic text, private boolean); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.send(payload jsonb, event text, topic text, private boolean) TO postgres;
GRANT ALL ON FUNCTION realtime.send(payload jsonb, event text, topic text, private boolean) TO dashboard_user;


--
-- Name: FUNCTION subscription_check_filters(); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO postgres;
GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO dashboard_user;
GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO anon;
GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO authenticated;
GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO service_role;
GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO supabase_realtime_admin;


--
-- Name: FUNCTION to_regrole(role_name text); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.to_regrole(role_name text) TO postgres;
GRANT ALL ON FUNCTION realtime.to_regrole(role_name text) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.to_regrole(role_name text) TO anon;
GRANT ALL ON FUNCTION realtime.to_regrole(role_name text) TO authenticated;
GRANT ALL ON FUNCTION realtime.to_regrole(role_name text) TO service_role;
GRANT ALL ON FUNCTION realtime.to_regrole(role_name text) TO supabase_realtime_admin;


--
-- Name: FUNCTION topic(); Type: ACL; Schema: realtime; Owner: supabase_realtime_admin
--

GRANT ALL ON FUNCTION realtime.topic() TO postgres;
GRANT ALL ON FUNCTION realtime.topic() TO dashboard_user;


--
-- Name: FUNCTION can_insert_object(bucketid text, name text, owner uuid, metadata jsonb); Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON FUNCTION storage.can_insert_object(bucketid text, name text, owner uuid, metadata jsonb) TO postgres;


--
-- Name: FUNCTION extension(name text); Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON FUNCTION storage.extension(name text) TO postgres;


--
-- Name: FUNCTION filename(name text); Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON FUNCTION storage.filename(name text) TO postgres;


--
-- Name: FUNCTION foldername(name text); Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON FUNCTION storage.foldername(name text) TO postgres;


--
-- Name: FUNCTION list_multipart_uploads_with_delimiter(bucket_id text, prefix_param text, delimiter_param text, max_keys integer, next_key_token text, next_upload_token text); Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON FUNCTION storage.list_multipart_uploads_with_delimiter(bucket_id text, prefix_param text, delimiter_param text, max_keys integer, next_key_token text, next_upload_token text) TO postgres;


--
-- Name: FUNCTION list_objects_with_delimiter(bucket_id text, prefix_param text, delimiter_param text, max_keys integer, start_after text, next_token text); Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON FUNCTION storage.list_objects_with_delimiter(bucket_id text, prefix_param text, delimiter_param text, max_keys integer, start_after text, next_token text) TO postgres;


--
-- Name: FUNCTION operation(); Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON FUNCTION storage.operation() TO postgres;


--
-- Name: FUNCTION search(prefix text, bucketname text, limits integer, levels integer, offsets integer, search text, sortcolumn text, sortorder text); Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON FUNCTION storage.search(prefix text, bucketname text, limits integer, levels integer, offsets integer, search text, sortcolumn text, sortorder text) TO postgres;


--
-- Name: FUNCTION update_updated_at_column(); Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON FUNCTION storage.update_updated_at_column() TO postgres;


--
-- Name: FUNCTION _crypto_aead_det_decrypt(message bytea, additional bytea, key_id bigint, context bytea, nonce bytea); Type: ACL; Schema: vault; Owner: supabase_admin
--

GRANT ALL ON FUNCTION vault._crypto_aead_det_decrypt(message bytea, additional bytea, key_id bigint, context bytea, nonce bytea) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION vault._crypto_aead_det_decrypt(message bytea, additional bytea, key_id bigint, context bytea, nonce bytea) TO service_role;


--
-- Name: FUNCTION create_secret(new_secret text, new_name text, new_description text, new_key_id uuid); Type: ACL; Schema: vault; Owner: supabase_admin
--

GRANT ALL ON FUNCTION vault.create_secret(new_secret text, new_name text, new_description text, new_key_id uuid) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION vault.create_secret(new_secret text, new_name text, new_description text, new_key_id uuid) TO service_role;


--
-- Name: FUNCTION update_secret(secret_id uuid, new_secret text, new_name text, new_description text, new_key_id uuid); Type: ACL; Schema: vault; Owner: supabase_admin
--

GRANT ALL ON FUNCTION vault.update_secret(secret_id uuid, new_secret text, new_name text, new_description text, new_key_id uuid) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION vault.update_secret(secret_id uuid, new_secret text, new_name text, new_description text, new_key_id uuid) TO service_role;


--
-- Name: TABLE audit_log_entries; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.audit_log_entries TO dashboard_user;
GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.audit_log_entries TO postgres;
GRANT SELECT ON TABLE auth.audit_log_entries TO postgres WITH GRANT OPTION;


--
-- Name: TABLE flow_state; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.flow_state TO postgres;
GRANT SELECT ON TABLE auth.flow_state TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.flow_state TO dashboard_user;


--
-- Name: TABLE identities; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.identities TO postgres;
GRANT SELECT ON TABLE auth.identities TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.identities TO dashboard_user;


--
-- Name: TABLE instances; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.instances TO dashboard_user;
GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.instances TO postgres;
GRANT SELECT ON TABLE auth.instances TO postgres WITH GRANT OPTION;


--
-- Name: TABLE mfa_amr_claims; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.mfa_amr_claims TO postgres;
GRANT SELECT ON TABLE auth.mfa_amr_claims TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.mfa_amr_claims TO dashboard_user;


--
-- Name: TABLE mfa_challenges; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.mfa_challenges TO postgres;
GRANT SELECT ON TABLE auth.mfa_challenges TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.mfa_challenges TO dashboard_user;


--
-- Name: TABLE mfa_factors; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.mfa_factors TO postgres;
GRANT SELECT ON TABLE auth.mfa_factors TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.mfa_factors TO dashboard_user;


--
-- Name: TABLE oauth_authorizations; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.oauth_authorizations TO postgres;
GRANT ALL ON TABLE auth.oauth_authorizations TO dashboard_user;


--
-- Name: TABLE oauth_client_states; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.oauth_client_states TO postgres;
GRANT ALL ON TABLE auth.oauth_client_states TO dashboard_user;


--
-- Name: TABLE oauth_clients; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.oauth_clients TO postgres;
GRANT ALL ON TABLE auth.oauth_clients TO dashboard_user;


--
-- Name: TABLE oauth_consents; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.oauth_consents TO postgres;
GRANT ALL ON TABLE auth.oauth_consents TO dashboard_user;


--
-- Name: TABLE one_time_tokens; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.one_time_tokens TO postgres;
GRANT SELECT ON TABLE auth.one_time_tokens TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.one_time_tokens TO dashboard_user;


--
-- Name: TABLE refresh_tokens; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.refresh_tokens TO dashboard_user;
GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.refresh_tokens TO postgres;
GRANT SELECT ON TABLE auth.refresh_tokens TO postgres WITH GRANT OPTION;


--
-- Name: SEQUENCE refresh_tokens_id_seq; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON SEQUENCE auth.refresh_tokens_id_seq TO dashboard_user;
GRANT ALL ON SEQUENCE auth.refresh_tokens_id_seq TO postgres;


--
-- Name: TABLE saml_providers; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.saml_providers TO postgres;
GRANT SELECT ON TABLE auth.saml_providers TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.saml_providers TO dashboard_user;


--
-- Name: TABLE saml_relay_states; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.saml_relay_states TO postgres;
GRANT SELECT ON TABLE auth.saml_relay_states TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.saml_relay_states TO dashboard_user;


--
-- Name: TABLE sessions; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.sessions TO postgres;
GRANT SELECT ON TABLE auth.sessions TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.sessions TO dashboard_user;


--
-- Name: TABLE sso_domains; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.sso_domains TO postgres;
GRANT SELECT ON TABLE auth.sso_domains TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.sso_domains TO dashboard_user;


--
-- Name: TABLE sso_providers; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.sso_providers TO postgres;
GRANT SELECT ON TABLE auth.sso_providers TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.sso_providers TO dashboard_user;


--
-- Name: TABLE users; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.users TO dashboard_user;
GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.users TO postgres;
GRANT SELECT ON TABLE auth.users TO postgres WITH GRANT OPTION;


--
-- Name: TABLE pg_stat_statements; Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON TABLE extensions.pg_stat_statements TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE extensions.pg_stat_statements TO dashboard_user;


--
-- Name: TABLE pg_stat_statements_info; Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON TABLE extensions.pg_stat_statements_info TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE extensions.pg_stat_statements_info TO dashboard_user;


--
-- Name: TABLE admin_users; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.admin_users TO anon;
GRANT ALL ON TABLE public.admin_users TO authenticated;
GRANT ALL ON TABLE public.admin_users TO service_role;


--
-- Name: TABLE announcement_config; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.announcement_config TO anon;
GRANT ALL ON TABLE public.announcement_config TO authenticated;
GRANT ALL ON TABLE public.announcement_config TO service_role;


--
-- Name: TABLE announcement_impressions; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.announcement_impressions TO anon;
GRANT ALL ON TABLE public.announcement_impressions TO authenticated;
GRANT ALL ON TABLE public.announcement_impressions TO service_role;


--
-- Name: TABLE announcement_responses; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.announcement_responses TO anon;
GRANT ALL ON TABLE public.announcement_responses TO authenticated;
GRANT ALL ON TABLE public.announcement_responses TO service_role;


--
-- Name: TABLE announcements; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.announcements TO anon;
GRANT ALL ON TABLE public.announcements TO authenticated;
GRANT ALL ON TABLE public.announcements TO service_role;


--
-- Name: TABLE users; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.users TO anon;
GRANT ALL ON TABLE public.users TO authenticated;
GRANT ALL ON TABLE public.users TO service_role;


--
-- Name: TABLE announcement_targeting_stats; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.announcement_targeting_stats TO anon;
GRANT ALL ON TABLE public.announcement_targeting_stats TO authenticated;
GRANT ALL ON TABLE public.announcement_targeting_stats TO service_role;


--
-- Name: TABLE app_sessions; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.app_sessions TO anon;
GRANT ALL ON TABLE public.app_sessions TO authenticated;
GRANT ALL ON TABLE public.app_sessions TO service_role;


--
-- Name: TABLE app_settings; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.app_settings TO anon;
GRANT ALL ON TABLE public.app_settings TO authenticated;
GRANT ALL ON TABLE public.app_settings TO service_role;


--
-- Name: TABLE category_settings; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.category_settings TO anon;
GRANT ALL ON TABLE public.category_settings TO authenticated;
GRANT ALL ON TABLE public.category_settings TO service_role;


--
-- Name: TABLE credit_asset_types; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.credit_asset_types TO anon;
GRANT ALL ON TABLE public.credit_asset_types TO authenticated;
GRANT ALL ON TABLE public.credit_asset_types TO service_role;


--
-- Name: TABLE credit_links; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.credit_links TO anon;
GRANT ALL ON TABLE public.credit_links TO authenticated;
GRANT ALL ON TABLE public.credit_links TO service_role;


--
-- Name: TABLE credit_sites; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.credit_sites TO anon;
GRANT ALL ON TABLE public.credit_sites TO authenticated;
GRANT ALL ON TABLE public.credit_sites TO service_role;


--
-- Name: TABLE credits_overview; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.credits_overview TO anon;
GRANT ALL ON TABLE public.credits_overview TO authenticated;
GRANT ALL ON TABLE public.credits_overview TO service_role;


--
-- Name: TABLE dashboard_announcements; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.dashboard_announcements TO anon;
GRANT ALL ON TABLE public.dashboard_announcements TO authenticated;
GRANT ALL ON TABLE public.dashboard_announcements TO service_role;


--
-- Name: TABLE feedbacks; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.feedbacks TO anon;
GRANT ALL ON TABLE public.feedbacks TO authenticated;
GRANT ALL ON TABLE public.feedbacks TO service_role;


--
-- Name: TABLE dashboard_feedbacks; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.dashboard_feedbacks TO anon;
GRANT ALL ON TABLE public.dashboard_feedbacks TO authenticated;
GRANT ALL ON TABLE public.dashboard_feedbacks TO service_role;


--
-- Name: TABLE screen_settings; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.screen_settings TO anon;
GRANT ALL ON TABLE public.screen_settings TO authenticated;
GRANT ALL ON TABLE public.screen_settings TO service_role;


--
-- Name: TABLE section_settings; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.section_settings TO anon;
GRANT ALL ON TABLE public.section_settings TO authenticated;
GRANT ALL ON TABLE public.section_settings TO service_role;


--
-- Name: TABLE tool_settings; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.tool_settings TO anon;
GRANT ALL ON TABLE public.tool_settings TO authenticated;
GRANT ALL ON TABLE public.tool_settings TO service_role;


--
-- Name: TABLE tool_usage_events; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.tool_usage_events TO anon;
GRANT ALL ON TABLE public.tool_usage_events TO authenticated;
GRANT ALL ON TABLE public.tool_usage_events TO service_role;


--
-- Name: TABLE tool_usage_events_enriched; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.tool_usage_events_enriched TO anon;
GRANT ALL ON TABLE public.tool_usage_events_enriched TO authenticated;
GRANT ALL ON TABLE public.tool_usage_events_enriched TO service_role;


--
-- Name: TABLE tool_usage_summary; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.tool_usage_summary TO anon;
GRANT ALL ON TABLE public.tool_usage_summary TO authenticated;
GRANT ALL ON TABLE public.tool_usage_summary TO service_role;


--
-- Name: TABLE user_announcement_state; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.user_announcement_state TO anon;
GRANT ALL ON TABLE public.user_announcement_state TO authenticated;
GRANT ALL ON TABLE public.user_announcement_state TO service_role;


--
-- Name: TABLE user_sync_states; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.user_sync_states TO anon;
GRANT ALL ON TABLE public.user_sync_states TO authenticated;
GRANT ALL ON TABLE public.user_sync_states TO service_role;


--
-- Name: TABLE user_usage_summary; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.user_usage_summary TO anon;
GRANT ALL ON TABLE public.user_usage_summary TO authenticated;
GRANT ALL ON TABLE public.user_usage_summary TO service_role;


--
-- Name: TABLE messages; Type: ACL; Schema: realtime; Owner: supabase_realtime_admin
--

GRANT ALL ON TABLE realtime.messages TO postgres;
GRANT ALL ON TABLE realtime.messages TO dashboard_user;
GRANT SELECT,INSERT,UPDATE ON TABLE realtime.messages TO anon;
GRANT SELECT,INSERT,UPDATE ON TABLE realtime.messages TO authenticated;
GRANT SELECT,INSERT,UPDATE ON TABLE realtime.messages TO service_role;


--
-- Name: TABLE schema_migrations; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON TABLE realtime.schema_migrations TO postgres;
GRANT ALL ON TABLE realtime.schema_migrations TO dashboard_user;
GRANT SELECT ON TABLE realtime.schema_migrations TO anon;
GRANT SELECT ON TABLE realtime.schema_migrations TO authenticated;
GRANT SELECT ON TABLE realtime.schema_migrations TO service_role;
GRANT ALL ON TABLE realtime.schema_migrations TO supabase_realtime_admin;


--
-- Name: TABLE subscription; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON TABLE realtime.subscription TO postgres;
GRANT ALL ON TABLE realtime.subscription TO dashboard_user;
GRANT SELECT ON TABLE realtime.subscription TO anon;
GRANT SELECT ON TABLE realtime.subscription TO authenticated;
GRANT SELECT ON TABLE realtime.subscription TO service_role;
GRANT ALL ON TABLE realtime.subscription TO supabase_realtime_admin;


--
-- Name: SEQUENCE subscription_id_seq; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON SEQUENCE realtime.subscription_id_seq TO postgres;
GRANT ALL ON SEQUENCE realtime.subscription_id_seq TO dashboard_user;
GRANT USAGE ON SEQUENCE realtime.subscription_id_seq TO anon;
GRANT USAGE ON SEQUENCE realtime.subscription_id_seq TO authenticated;
GRANT USAGE ON SEQUENCE realtime.subscription_id_seq TO service_role;
GRANT ALL ON SEQUENCE realtime.subscription_id_seq TO supabase_realtime_admin;


--
-- Name: TABLE buckets; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

REVOKE ALL ON TABLE storage.buckets FROM supabase_storage_admin;
GRANT ALL ON TABLE storage.buckets TO supabase_storage_admin WITH GRANT OPTION;
GRANT ALL ON TABLE storage.buckets TO anon;
GRANT ALL ON TABLE storage.buckets TO authenticated;
GRANT ALL ON TABLE storage.buckets TO service_role;
GRANT ALL ON TABLE storage.buckets TO postgres WITH GRANT OPTION;


--
-- Name: TABLE buckets_analytics; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON TABLE storage.buckets_analytics TO service_role;
GRANT ALL ON TABLE storage.buckets_analytics TO authenticated;
GRANT ALL ON TABLE storage.buckets_analytics TO anon;


--
-- Name: TABLE buckets_vectors; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT SELECT ON TABLE storage.buckets_vectors TO service_role;
GRANT SELECT ON TABLE storage.buckets_vectors TO authenticated;
GRANT SELECT ON TABLE storage.buckets_vectors TO anon;


--
-- Name: TABLE objects; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

REVOKE ALL ON TABLE storage.objects FROM supabase_storage_admin;
GRANT ALL ON TABLE storage.objects TO supabase_storage_admin WITH GRANT OPTION;
GRANT ALL ON TABLE storage.objects TO anon;
GRANT ALL ON TABLE storage.objects TO authenticated;
GRANT ALL ON TABLE storage.objects TO service_role;
GRANT ALL ON TABLE storage.objects TO postgres WITH GRANT OPTION;


--
-- Name: TABLE prefixes; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON TABLE storage.prefixes TO service_role;
GRANT ALL ON TABLE storage.prefixes TO authenticated;
GRANT ALL ON TABLE storage.prefixes TO anon;


--
-- Name: TABLE s3_multipart_uploads; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON TABLE storage.s3_multipart_uploads TO service_role;
GRANT SELECT ON TABLE storage.s3_multipart_uploads TO authenticated;
GRANT SELECT ON TABLE storage.s3_multipart_uploads TO anon;
GRANT ALL ON TABLE storage.s3_multipart_uploads TO postgres;


--
-- Name: TABLE s3_multipart_uploads_parts; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON TABLE storage.s3_multipart_uploads_parts TO service_role;
GRANT SELECT ON TABLE storage.s3_multipart_uploads_parts TO authenticated;
GRANT SELECT ON TABLE storage.s3_multipart_uploads_parts TO anon;
GRANT ALL ON TABLE storage.s3_multipart_uploads_parts TO postgres;


--
-- Name: TABLE vector_indexes; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT SELECT ON TABLE storage.vector_indexes TO service_role;
GRANT SELECT ON TABLE storage.vector_indexes TO authenticated;
GRANT SELECT ON TABLE storage.vector_indexes TO anon;


--
-- Name: TABLE secrets; Type: ACL; Schema: vault; Owner: supabase_admin
--

GRANT SELECT,REFERENCES,DELETE,TRUNCATE ON TABLE vault.secrets TO postgres WITH GRANT OPTION;
GRANT SELECT,DELETE ON TABLE vault.secrets TO service_role;


--
-- Name: TABLE decrypted_secrets; Type: ACL; Schema: vault; Owner: supabase_admin
--

GRANT SELECT,REFERENCES,DELETE,TRUNCATE ON TABLE vault.decrypted_secrets TO postgres WITH GRANT OPTION;
GRANT SELECT,DELETE ON TABLE vault.decrypted_secrets TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: auth; Owner: supabase_auth_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON SEQUENCES TO dashboard_user;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: auth; Owner: supabase_auth_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON FUNCTIONS TO dashboard_user;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: auth; Owner: supabase_auth_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON TABLES TO dashboard_user;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: extensions; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA extensions GRANT ALL ON SEQUENCES TO postgres WITH GRANT OPTION;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: extensions; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA extensions GRANT ALL ON FUNCTIONS TO postgres WITH GRANT OPTION;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: extensions; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA extensions GRANT ALL ON TABLES TO postgres WITH GRANT OPTION;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: graphql; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON SEQUENCES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON SEQUENCES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON SEQUENCES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: graphql; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON FUNCTIONS TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON FUNCTIONS TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON FUNCTIONS TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: graphql; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON TABLES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON TABLES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: graphql_public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON SEQUENCES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON SEQUENCES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON SEQUENCES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: graphql_public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON FUNCTIONS TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON FUNCTIONS TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON FUNCTIONS TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: graphql_public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON TABLES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON TABLES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON TABLES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON TABLES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: realtime; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON SEQUENCES TO dashboard_user;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: realtime; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON FUNCTIONS TO dashboard_user;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: realtime; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON TABLES TO dashboard_user;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: storage; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON SEQUENCES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON SEQUENCES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON SEQUENCES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: storage; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON FUNCTIONS TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON FUNCTIONS TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON FUNCTIONS TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: storage; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON TABLES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON TABLES TO service_role;


--
-- Name: issue_graphql_placeholder; Type: EVENT TRIGGER; Schema: -; Owner: supabase_admin
--

CREATE EVENT TRIGGER issue_graphql_placeholder ON sql_drop
         WHEN TAG IN ('DROP EXTENSION')
   EXECUTE FUNCTION extensions.set_graphql_placeholder();


ALTER EVENT TRIGGER issue_graphql_placeholder OWNER TO supabase_admin;

--
-- Name: issue_pg_cron_access; Type: EVENT TRIGGER; Schema: -; Owner: supabase_admin
--

CREATE EVENT TRIGGER issue_pg_cron_access ON ddl_command_end
         WHEN TAG IN ('CREATE EXTENSION')
   EXECUTE FUNCTION extensions.grant_pg_cron_access();


ALTER EVENT TRIGGER issue_pg_cron_access OWNER TO supabase_admin;

--
-- Name: issue_pg_graphql_access; Type: EVENT TRIGGER; Schema: -; Owner: supabase_admin
--

CREATE EVENT TRIGGER issue_pg_graphql_access ON ddl_command_end
         WHEN TAG IN ('CREATE FUNCTION')
   EXECUTE FUNCTION extensions.grant_pg_graphql_access();


ALTER EVENT TRIGGER issue_pg_graphql_access OWNER TO supabase_admin;

--
-- Name: issue_pg_net_access; Type: EVENT TRIGGER; Schema: -; Owner: supabase_admin
--

CREATE EVENT TRIGGER issue_pg_net_access ON ddl_command_end
         WHEN TAG IN ('CREATE EXTENSION')
   EXECUTE FUNCTION extensions.grant_pg_net_access();


ALTER EVENT TRIGGER issue_pg_net_access OWNER TO supabase_admin;

--
-- Name: pgrst_ddl_watch; Type: EVENT TRIGGER; Schema: -; Owner: supabase_admin
--

CREATE EVENT TRIGGER pgrst_ddl_watch ON ddl_command_end
   EXECUTE FUNCTION extensions.pgrst_ddl_watch();


ALTER EVENT TRIGGER pgrst_ddl_watch OWNER TO supabase_admin;

--
-- Name: pgrst_drop_watch; Type: EVENT TRIGGER; Schema: -; Owner: supabase_admin
--

CREATE EVENT TRIGGER pgrst_drop_watch ON sql_drop
   EXECUTE FUNCTION extensions.pgrst_drop_watch();


ALTER EVENT TRIGGER pgrst_drop_watch OWNER TO supabase_admin;

--
-- PostgreSQL database dump complete
--

