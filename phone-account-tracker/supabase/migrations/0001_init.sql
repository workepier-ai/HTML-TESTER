-- Phone Account Tracker — initial schema
-- Applied to Supabase project lpnvlofzqzfqeaumcxxz (phone-account-tracker)

-- Accounts: one row per phone number, with its auto-created mail.tm email
create table public.accounts (
  id uuid primary key default gen_random_uuid(),
  phone text not null unique,
  email text,
  email_password text,
  mailtm_account_id text,
  notes text default '',
  created_at timestamptz not null default now()
);

-- Fields: user-defined column headers shown across the top of the grid
create table public.fields (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  position int not null default 0,
  created_at timestamptz not null default now()
);

-- Checks: one checkbox state per (account, field)
create table public.checks (
  account_id uuid not null references public.accounts(id) on delete cascade,
  field_id uuid not null references public.fields(id) on delete cascade,
  checked boolean not null default false,
  updated_at timestamptz not null default now(),
  primary key (account_id, field_id)
);

-- RLS on, with full access for the anon key (single-user tool; key lives in the private repo)
alter table public.accounts enable row level security;
alter table public.fields enable row level security;
alter table public.checks enable row level security;

create policy "anon full access accounts" on public.accounts
  for all to anon using (true) with check (true);
create policy "anon full access fields" on public.fields
  for all to anon using (true) with check (true);
create policy "anon full access checks" on public.checks
  for all to anon using (true) with check (true);

-- Starter fields
insert into public.fields (name, position) values
  ('Google', 0),
  ('Facebook', 1),
  ('Verified', 2);
