-- Phase 1.6: incremental sync + LWW timestamps on mirrored tables.

alter table public.system_event
add column if not exists updated_at timestamptz not null default now();

update public.system_event set updated_at = occurred_at;

alter table public.event_delivery
add column if not exists updated_at timestamptz not null default now();

alter table public.family
add column if not exists updated_at timestamptz not null default now();

alter table public.profile
add column if not exists updated_at timestamptz not null default now();

alter table public.membership
add column if not exists updated_at timestamptz not null default now();

create index if not exists system_event_tenant_updated_at_idx on public.system_event (tenant_id, updated_at);

create index if not exists event_delivery_updated_at_idx on public.event_delivery (updated_at);

create index if not exists family_updated_at_idx on public.family (updated_at);

create index if not exists profile_updated_at_idx on public.profile (updated_at);

create index if not exists membership_updated_at_idx on public.membership (updated_at);
