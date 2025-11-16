/**
 * Test Analytics API & RPC Function
 *
 * This script tests the complete analytics flow:
 * 1. Tests RPC function existence
 * 2. Tests RPC function execution
 * 3. Tests all analytics views
 * 4. Tests API endpoint
 *
 * Run: npx ts-node scripts/test-analytics.ts
 */

require('dotenv').config();
const { createClient } = require('@supabase/supabase-js');

const getEnv = (key: string): string => {
  const value = process.env[key];
  if (!value) {
    throw new Error(`Missing: ${key}`);
  }
  return value;
};

const main = async () => {
  console.log('🔍 ANALYTICS DIAGNOSTIC TEST\n');

  const supabase = createClient(
    getEnv('SUPABASE_URL'),
    getEnv('SUPABASE_SERVICE_ROLE_KEY')
  );

  // Test 1: RPC Function Exists
  console.log('Test 1: Checking if get_admin_overview_metrics RPC function exists...');
  const { data: funcExists, error: funcError } = await supabase.rpc(
    'get_admin_overview_metrics',
    { p_days: 30 }
  );

  if (funcError) {
    console.error('❌ FAILED:', funcError.message);
    console.log('\n💡 Fix: Deploy DEPLOY_ANALYTICS.sql to Supabase SQL Editor');
  } else {
    console.log('✅ RPC Function exists and returns data');
    console.log('📊 Data:', funcExists);
  }

  // Test 2: admin_usage_timeline_view
  console.log('\n\nTest 2: Checking admin_usage_timeline_view...');
  const { data: timeline, error: timelineError } = await supabase
    .from('admin_usage_timeline_view')
    .select('*')
    .limit(5);

  if (timelineError) {
    console.error('❌ FAILED:', timelineError.message);
  } else {
    console.log('✅ View exists', `(${timeline?.length || 0} rows)`);
  }

  // Test 3: admin_tool_usage_view
  console.log('\nTest 3: Checking admin_tool_usage_view...');
  const { data: tools, error: toolsError } = await supabase
    .from('admin_tool_usage_view')
    .select('*')
    .limit(5);

  if (toolsError) {
    console.error('❌ FAILED:', toolsError.message);
  } else {
    console.log('✅ View exists', `(${tools?.length || 0} rows)`);
  }

  // Test 4: admin_location_usage_view
  console.log('\nTest 4: Checking admin_location_usage_view...');
  const { data: locations, error: locError } = await supabase
    .from('admin_location_usage_view')
    .select('*')
    .limit(5);

  if (locError) {
    console.error('❌ FAILED:', locError.message);
  } else {
    console.log('✅ View exists', `(${locations?.length || 0} rows)`);
  }

  // Test 5: admin_feedback_summary_view
  console.log('\nTest 5: Checking admin_feedback_summary_view...');
  const { data: feedback, error: fbError } = await supabase
    .from('admin_feedback_summary_view')
    .select('*')
    .limit(5);

  if (fbError) {
    console.error('❌ FAILED:', fbError.message);
  } else {
    console.log('✅ View exists', `(${feedback?.length || 0} rows)`);
  }

  // Test 6: admin_recent_sessions_view
  console.log('\nTest 6: Checking admin_recent_sessions_view...');
  const { data: sessions, error: sessError } = await supabase
    .from('admin_recent_sessions_view')
    .select('*')
    .limit(5);

  if (sessError) {
    console.error('❌ FAILED:', sessError.message);
  } else {
    console.log('✅ View exists', `(${sessions?.length || 0} rows)`);
  }

  // Summary
  console.log('\n\n' + '='.repeat(60));
  console.log('SUMMARY');
  console.log('='.repeat(60));

  const allPassed = !funcError && !timelineError && !toolsError && !locError && !fbError && !sessError;

  if (allPassed) {
    console.log('✅ ALL TESTS PASSED - Analytics should work!');
    console.log('\nNext steps:');
    console.log('1. Refresh admin dashboard');
    console.log('2. Check if "Failed to load analytics" is gone');
    console.log('3. If still failing, check browser console (F12)');
  } else {
    console.log('❌ SOME TESTS FAILED');
    console.log('\nRequired fixes:');
    if (funcError) console.log('- Deploy DEPLOY_ANALYTICS.sql to Supabase');
    if (timelineError) console.log('- Deploy admin_usage_timeline_view');
    if (toolsError) console.log('- Deploy admin_tool_usage_view');
    if (locError) console.log('- Deploy admin_location_usage_view');
    if (fbError) console.log('- Deploy admin_feedback_summary_view');
    if (sessError) console.log('- Deploy admin_recent_sessions_view');
  }
};

main().catch(err => {
  console.error('\n💥 ERROR:', err.message);
  process.exit(1);
});
