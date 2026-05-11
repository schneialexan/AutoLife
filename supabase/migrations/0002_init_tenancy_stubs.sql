-- Stub tenancy tables — full schema: .cursor/plans/phase2.2_family_tenancy_model.plan.md
-- RLS: phase 2.4

create type public.membership_role as enum ('member', 'admin', 'owner');

-- TODO(phase 2.2): extend columns (prefs, links, lifecycle); avoid DROP — use ALTER migrations.
create table public.family (
  id uuid primary key default gen_random_uuid (),
  display_name text not null
);

comment on table public.family is 'Stub tenant row; expand in phase 2.2 (.cursor/plans/phase2.2_family_tenancy_model.plan.md).';

-- TODO(phase 2.2): add auth.users FK on id, soft-delete, audit fields as needed.
create table public.profile (
  id uuid primary key default gen_random_uuid (),
  display_name text not null,
  family_id uuid references public.family (id) on delete set null
);

comment on table public.profile is 'Stub profile; expand in phase 2.2; optional family_id for local seed.';

comment on column public.profile.family_id is 'TODO phase 2.2: tenancy placement may move to membership-only.';

-- TODO(phase 2.2): uniqueness constraints, invite state, approval fields.
create table public.membership (
  id uuid primary key default gen_random_uuid (),
  family_id uuid not null references public.family (id) on delete cascade,
  profile_id uuid not null references public.profile (id) on delete cascade,
  role public.membership_role not null default 'member'
);

comment on table public.membership is 'Stub join profile↔family; expand in phase 2.2 / roles in phase 2.3.';

create index membership_family_id_idx on public.membership (family_id);

create index membership_profile_id_idx on public.membership (profile_id);

alter table public.family enable row level security;

alter table public.profile enable row level security;

alter table public.membership enable row level security;
