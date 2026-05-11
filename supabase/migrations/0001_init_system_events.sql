-- Phase 1.4: canonical event bus tables (contracts: packages/autolife-core SystemEvent / EventDelivery).

create type public.event_delivery_status as enum (
  'pending',
  'succeeded',
  'failed',
  'dead_letter'
);

create table public.system_event (
  id uuid primary key default gen_random_uuid (),
  tenant_id text not null,
  actor_id text not null,
  module text not null,
  type text not null,
  payload jsonb not null default '{}'::jsonb,
  idempotency_key text not null,
  occurred_at timestamptz not null,
  ordering_tag text not null,
  schema_version integer not null,
  constraint system_event_tenant_idempotency unique (tenant_id, idempotency_key)
);

create index system_event_tenant_occurred_at_idx on public.system_event (tenant_id, occurred_at);

create index system_event_idempotency_key_idx on public.system_event (idempotency_key);

create table public.event_delivery (
  id uuid primary key default gen_random_uuid (),
  event_id uuid not null references public.system_event (id) on delete cascade,
  consumer text not null,
  attempt integer not null default 0,
  status public.event_delivery_status not null default 'pending',
  last_error text,
  next_attempt_at timestamptz
);

create index event_delivery_event_id_idx on public.event_delivery (event_id);

create index event_delivery_status_next_attempt_idx on public.event_delivery (status, next_attempt_at);

alter table public.system_event enable row level security;

alter table public.event_delivery enable row level security;

comment on table public.system_event is 'Canonical persisted events; RLS in phase 2.4.';

comment on table public.event_delivery is 'Fan-out delivery attempts; RLS in phase 2.4.';
