-- Baseline schema for AutoLife (Milestone 1)

create extension if not exists "uuid-ossp";

create table public.families (
  id uuid primary key default uuid_generate_v4(),
  name text not null,
  created_at timestamptz not null default now()
);

alter table public.families enable row level security;

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  family_id uuid not null references public.families(id) on delete cascade,
  display_name text not null,
  role text not null default 'co-parent'
    check (role in ('co-parent','teenager','child','grandparent','guest')),
  created_at timestamptz not null default now()
);

alter table public.profiles enable row level security;
create index idx_profiles_family_id on public.profiles(family_id);

create table public.system_events (
  id uuid primary key default uuid_generate_v4(),
  idempotency_key text not null,
  type text not null,
  source_module text not null,
  payload jsonb not null default '{}',
  family_id uuid not null references public.families(id) on delete cascade,
  created_at timestamptz not null default now()
);

alter table public.system_events enable row level security;
create unique index idx_system_events_idempotency
  on public.system_events(family_id, idempotency_key);
create index idx_system_events_family_id on public.system_events(family_id);

create table public.event_deliveries (
  id uuid primary key default uuid_generate_v4(),
  event_id uuid not null references public.system_events(id) on delete cascade,
  consumer_module text not null,
  status text not null default 'pending'
    check (status in ('pending','processed','failed')),
  processed_at timestamptz,
  retry_count int not null default 0,
  last_error text,
  created_at timestamptz not null default now()
);

alter table public.event_deliveries enable row level security;
create unique index idx_event_deliveries_dedup
  on public.event_deliveries(event_id, consumer_module);
create index idx_event_deliveries_pending
  on public.event_deliveries(status) where status = 'pending';

