-- Directory of referral codes and their owners
create extension if not exists "pgcrypto";

create table if not exists public.referral_codes (
  code text primary key,
  referrer_name text not null,
  country text,
  email text,
  phone text,
  note text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Ensure uppercase codes are unique
create unique index if not exists referral_codes_code_upper_idx on public.referral_codes (upper(code));

-- RLS
alter table public.referral_codes enable row level security;

-- Allow service role full access
do $$
begin
  if not exists (
    select 1 from pg_policies
    where schemaname = 'public'
      and tablename = 'referral_codes'
      and policyname = 'service_role_full_access_referrals'
  ) then
    create policy "service_role_full_access_referrals" on public.referral_codes
      for all using (auth.role() = 'service_role') with check (auth.role() = 'service_role');
  end if;
end$$;

-- Optional: allow admin inserts via service role only; keep clients read-only
do $$
begin
  if not exists (
    select 1 from pg_policies
    where schemaname = 'public'
      and tablename = 'referral_codes'
      and policyname = 'anon_referral_readonly'
  ) then
    create policy "anon_referral_readonly" on public.referral_codes
      for select using (true);
  end if;
end$$;
