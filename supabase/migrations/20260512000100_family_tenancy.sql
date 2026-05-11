-- Phase 2.2: canonical family tenancy — `families`, `memberships`, `family_invitations`.
-- Replaces stub `family` / `membership`; profile tenancy moves to membership + `active_family_id`.

-- Hashing for invitation tokens (accept path lives in 20260512000110).
create extension if not exists pgcrypto with schema extensions;

-- ---------------------------------------------------------------------------
-- 1. Rename stub tenant table and extend columns
-- ---------------------------------------------------------------------------
alter table public.family rename to families;

alter table public.families rename column display_name to name;

alter table public.families
  add column if not exists created_by uuid references auth.users (id) on delete set null,
  add column if not exists created_at timestamptz not null default now(),
  add column if not exists archived_at timestamptz,
  add column if not exists settings jsonb not null default '{}'::jsonb;

comment on table public.families is 'Household / tenant; see docs/tenancy.md.';

comment on column public.families.settings is 'Family-scoped preferences (JSON).';

-- ---------------------------------------------------------------------------
-- 2. Replace `membership` with composite-key `memberships` (user_id = auth profile id)
-- ---------------------------------------------------------------------------
create table public.memberships (
  family_id uuid not null references public.families (id) on delete cascade,
  user_id uuid not null references public.profile (id) on delete cascade,
  role text not null default 'member',
  joined_at timestamptz not null default now(),
  removed_at timestamptz,
  updated_at timestamptz not null default now(),
  primary key (family_id, user_id)
);

comment on table public.memberships is 'User↔family membership; soft-remove via removed_at.';

comment on column public.memberships.role is 'Placeholder text until phase 2.3 role enum + policy engine.';

insert into public.memberships (family_id, user_id, role, joined_at, removed_at, updated_at)
select
  m.family_id,
  m.profile_id,
  m.role::text,
  coalesce(m.updated_at, now()),
  null,
  m.updated_at
from public.membership m;

drop table public.membership;

drop type public.membership_role;

create index memberships_user_id_idx on public.memberships (user_id)
where
  removed_at is null;

create index memberships_family_id_idx on public.memberships (family_id)
where
  removed_at is null;

create index memberships_updated_at_idx on public.memberships (updated_at);

-- ---------------------------------------------------------------------------
-- 3. Profile: drop legacy family_id; add active family pointer
-- ---------------------------------------------------------------------------
alter table public.profile drop column family_id;

alter table public.profile
  add column active_family_id uuid references public.families (id) on delete set null;

comment on column public.profile.active_family_id is 'Client/server source of truth for current family context.';

-- ---------------------------------------------------------------------------
-- 4. Invitations
-- ---------------------------------------------------------------------------
create table public.family_invitations (
  id uuid primary key default gen_random_uuid (),
  family_id uuid not null references public.families (id) on delete cascade,
  email text not null,
  invited_role text not null default 'member',
  invited_by uuid not null references public.profile (id) on delete cascade,
  token_hash text not null,
  expires_at timestamptz not null,
  accepted_at timestamptz,
  revoked_at timestamptz,
  created_at timestamptz not null default now (),
  updated_at timestamptz not null default now ()
);

comment on table public.family_invitations is 'Email invitation lifecycle; store only token_hash.';

create unique index family_invitations_token_hash_key on public.family_invitations (token_hash);

create index family_invitations_family_id_idx on public.family_invitations (family_id);

create index family_invitations_pending_email_idx on public.family_invitations (family_id, lower(email))
where
  accepted_at is null
  and revoked_at is null;

-- ---------------------------------------------------------------------------
-- 5. renamed indexes from 0011_sync_incremental_timestamps (was `family` / `membership`)
-- ---------------------------------------------------------------------------
alter index if exists family_updated_at_idx rename to families_updated_at_idx;

-- ---------------------------------------------------------------------------
-- 6. Row level security (baseline; tightened in phase 2.4)
-- ---------------------------------------------------------------------------
alter table public.families enable row level security;

alter table public.memberships enable row level security;

alter table public.family_invitations enable row level security;

-- families: creator can read immediately after insert; members read active families
create policy families_select_creator on public.families for
select to authenticated using (created_by = (select auth.uid ()));

-- families: members read; any authenticated user may create a family they own
create policy families_select_active_member on public.families for
select to authenticated using (
  exists (
    select 1 from public.memberships m
    where
      m.family_id = families.id
      and m.user_id = (select auth.uid ())
      and m.removed_at is null
      and families.archived_at is null
  )
);

create policy families_insert_self on public.families for insert to authenticated
with
  check (created_by = (select auth.uid ()));

create policy families_update_creator on public.families for
update to authenticated using (created_by = (select auth.uid ()))
with
  check (created_by = (select auth.uid ()));

-- memberships: read own rows or co-members in same family
create policy memberships_select_visible on public.memberships for
select to authenticated using (
  user_id = (select auth.uid ())
  or exists (
    select 1 from public.memberships me
    where
      me.family_id = memberships.family_id
      and me.user_id = (select auth.uid ())
      and me.removed_at is null
  )
);

-- Create family: creator inserts their own membership row
create policy memberships_insert_self on public.memberships for insert to authenticated
with
  check (user_id = (select auth.uid ()));

-- Leave / soft-delete own membership; admin removal deferred to 2.3 — allow self-update
create policy memberships_update_self on public.memberships for
update to authenticated using (user_id = (select auth.uid ()))
with
  check (user_id = (select auth.uid ()));

-- invitations: inviter and same-family active members can read; insert if member
create policy family_invitations_select on public.family_invitations for
select to authenticated using (
  exists (
    select 1 from public.memberships m
    where
      m.family_id = family_invitations.family_id
      and m.user_id = (select auth.uid ())
      and m.removed_at is null
  )
);

-- Invited person can see their own outstanding invites (recipient email must match JWT).
create policy family_invitations_select_recipient on public.family_invitations for
select to authenticated using (
  lower(trim(email)) = lower(trim((select auth.jwt () ->> 'email')))
  and revoked_at is null
  and accepted_at is null
  and expires_at > now ()
);

create policy family_invitations_insert_member on public.family_invitations for insert to authenticated
with
  check (
    invited_by = (select auth.uid ())
    and exists (
      select 1 from public.memberships m
      where
        m.family_id = family_invitations.family_id
        and m.user_id = (select auth.uid ())
        and m.removed_at is null
    )
  );

create policy family_invitations_update_inviter on public.family_invitations for
update to authenticated using (invited_by = (select auth.uid ()))
with
  check (invited_by = (select auth.uid ()));

-- profile: users update their own row (active_family_id switcher)
alter table public.profile enable row level security;

create policy profile_select_own on public.profile for
select to authenticated using (id = (select auth.uid ()));

create policy profile_update_own on public.profile for
update to authenticated using (id = (select auth.uid ()))
with
  check (id = (select auth.uid ()));

-- Service role / dashboard (migrations owner) retains bypass; anon has no grants by default.
