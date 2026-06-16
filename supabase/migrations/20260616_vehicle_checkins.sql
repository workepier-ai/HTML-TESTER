-- New-Vehicle check-in rows pushed from the paddock VIN scanner (index.html)
-- and consumed by the printing portal (portal.html).
-- Apply via Supabase SQL editor, `supabase db push`, or the apply_migration MCP tool.

create table if not exists public.vehicle_checkins (
  id           uuid primary key default gen_random_uuid(),
  created_at   timestamptz not null default now(),
  client_t     bigint unique,                 -- scanner record id; makes re-sends idempotent
  batch_id     text,                          -- one "Send to PC" tap = one batch
  brand        text,                          -- 'mitsubishi' | 'suzuki' -> picks m_/s_ fields
  vin          text,
  stock        text,
  model        text,
  colour       text,
  trim         text,
  trans        text,
  kilometers   text,
  build        text,
  engine       text,
  logbooks     text,
  two_keys     text,
  keynumber    text,
  damage       text,
  checkin      text,
  arrivaldate  text,
  source       text default 'vin-scanner',
  printed_at   timestamptz                     -- set by the portal once printed
);

-- Fast lookup of the portal's poll query (unprinted rows, oldest first).
create index if not exists vehicle_checkins_unprinted_idx
  on public.vehicle_checkins (created_at)
  where printed_at is null;

alter table public.vehicle_checkins enable row level security;

-- Internal dealership tool: the publishable (anon) key may insert, read, and
-- mark-printed. This mirrors the project's other anon-accessible tables.
drop policy if exists "anon insert checkins" on public.vehicle_checkins;
drop policy if exists "anon select checkins" on public.vehicle_checkins;
drop policy if exists "anon update checkins" on public.vehicle_checkins;

create policy "anon insert checkins" on public.vehicle_checkins
  for insert to anon with check (true);
create policy "anon select checkins" on public.vehicle_checkins
  for select to anon using (true);
create policy "anon update checkins" on public.vehicle_checkins
  for update to anon using (true) with check (true);
