-- Closed testing signups table
create extension if not exists "pgcrypto";

create table if not exists public.closed_testing_signups (
  id uuid primary key default gen_random_uuid(),
  full_name text not null,
  email text not null,
  country text not null,
  platform text not null check (platform in ('android', 'ios')),
  referral_code text not null,
  note text,
  status text not null default 'pending' check (status in ('pending','invited','activated','waitlist','declined')),
  invited_by text,
  invited_at timestamptz,
  email_sent_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Ensure one signup per email
create unique index if not exists closed_testing_signups_email_key on public.closed_testing_signups (lower(email));

-- Helpful indexes
create index if not exists closed_testing_signups_status_idx on public.closed_testing_signups (status);
create index if not exists closed_testing_signups_platform_idx on public.closed_testing_signups (platform);
create index if not exists closed_testing_signups_referral_idx on public.closed_testing_signups (referral_code);
create index if not exists closed_testing_signups_created_idx on public.closed_testing_signups (created_at desc);

-- RLS
alter table public.closed_testing_signups enable row level security;

-- Allow service role to read/write (service role bypasses RLS, this is defensive)
do $$
begin
  if not exists (
    select 1 from pg_policies
    where schemaname = 'public'
      and tablename = 'closed_testing_signups'
      and policyname = 'service_role_full_access'
  ) then
    create policy "service_role_full_access" on public.closed_testing_signups
      for all using (auth.role() = 'service_role') with check (auth.role() = 'service_role');
  end if;
end$$;

-- Allow anon inserts if you ever need client-side submission (API currently uses service role)
do $$
begin
  if not exists (
    select 1 from pg_policies
    where schemaname = 'public'
      and tablename = 'closed_testing_signups'
      and policyname = 'anon_can_submit_closed_testing'
  ) then
    create policy "anon_can_submit_closed_testing" on public.closed_testing_signups
      for insert with check (true);
  end if;
end$$;
