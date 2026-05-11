-- Phase 2.3: Approval engine primitives + enforcement helper.

create type public.approval_request_status as enum ('pending', 'approved', 'rejected', 'expired', 'auto_approved');

create table public.approval_auto_rules (
  id uuid primary key default gen_random_uuid (),
  family_id uuid not null references public.families (id) on delete cascade,
  role public.family_role not null,
  capability text not null,
  label text not null default '',
  enabled boolean not null default true,
  match jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now (),
  updated_at timestamptz not null default now (),
  constraint approval_auto_rules_unique_label unique (
    family_id,
    role,
    capability,
    label
  )
);

comment on table public.approval_auto_rules is 'Auto-approve heuristics (e.g., teen events at School).';

create index approval_auto_rules_family_idx on public.approval_auto_rules (family_id);

create table public.approval_requests (
  id uuid primary key default gen_random_uuid (),
  family_id uuid not null references public.families (id) on delete cascade,
  requester_profile_id uuid not null references public.profile (id) on delete cascade,
  capability text not null,
  payload jsonb not null default '{}'::jsonb,
  status approval_request_status not null default 'pending',
  resolver_profile_id uuid references public.profile (id) on delete set null,
  applied_auto_rule_id uuid references public.approval_auto_rules (id) on delete set null,
  expires_at timestamptz not null default (now() + interval '72 hours'),
  resolved_at timestamptz,
  created_at timestamptz not null default now (),
  updated_at timestamptz not null default now ()
);

comment on table public.approval_requests is 'Manual / auto approvals for gated capabilities.';

create index approval_requests_family_status_idx on public.approval_requests (family_id, status);

create index approval_requests_pending_exp_idx on public.approval_requests (expires_at)
where
  status = 'pending'::public.approval_request_status;

-- ---------------------------------------------------------------------------
-- Core capability checks used by SECURITY DEFINER helpers and Phase 3 modules
-- ---------------------------------------------------------------------------
create or replace function public.family_role_for_membership (family uuid, usr uuid)
returns public.family_role
language sql
stable
as $$
  select m.role from public.memberships m
  where m.family_id = family
    and m.user_id = usr
    and m.removed_at is null;
$$;

create or replace function public.user_has_capability (family uuid, usr uuid, cap text)
returns boolean
language sql
stable
as $$
  select coalesce (
    exists (
      select 1 from public.memberships m
      join public.capability_grants g
        on g.family_id = m.family_id
          and g.role = m.role
          and g.capability = cap
          and g.granted
      where
        m.family_id = family and m.user_id = usr and m.removed_at is null
    ),
    false
  );
$$;

create or replace function public.capability_grant_row (family uuid, role public.family_role, cap text)
returns table (
  granted boolean,
  requires_parent_approval boolean,
  require_photo_proof boolean,
  require_parent_verification boolean
)
language sql
stable
as $$
  select pg.granted,
    pg.requires_parent_approval,
    pg.require_photo_proof,
    pg.require_parent_verification
  from public.capability_grants pg
  where pg.family_id = family
    and pg.role = role
    and pg.capability = cap;
$$;

create or replace function public.enforce_capability (family uuid, usr uuid, cap text)
returns void
language plpgsql
as $$
begin
  if not public.user_has_capability (family, usr, cap) then
    raise exception 'capability_denied' using errcode = 'P0001';
  end if;
end;
$$;

grant execute on function public.family_role_for_membership (uuid, uuid) to authenticated;

grant execute on function public.user_has_capability (uuid, uuid, text) to authenticated;

grant execute on function public.capability_grant_row (uuid, public.family_role, text) to authenticated;

grant execute on function public.enforce_capability (uuid, uuid, text) to authenticated;

-- ----------------------------------------------------------------------------
-- Approval engine RLS
-- ----------------------------------------------------------------------------
alter table public.approval_auto_rules enable row level security;

alter table public.approval_requests enable row level security;

create policy approval_auto_rules_select_members on public.approval_auto_rules for
select to authenticated using (
    exists (
      select 1 from public.memberships m
      where
        m.family_id = approval_auto_rules.family_id
        and m.user_id = (select auth.uid ())
        and m.removed_at is null
    )
  );

create policy approval_auto_rules_write_owner on public.approval_auto_rules for all to authenticated using (
    exists (
      select 1 from public.memberships mo
      where
        mo.family_id = approval_auto_rules.family_id
        and mo.user_id = (select auth.uid ())
        and mo.role = 'owner'::public.family_role
        and mo.removed_at is null
    )
  )
with
  check (
    exists (
      select 1 from public.memberships mo
      where
        mo.family_id = approval_auto_rules.family_id
        and mo.user_id = (select auth.uid ())
        and mo.role = 'owner'::public.family_role
        and mo.removed_at is null
    )
  );

create policy approval_requests_select_members on public.approval_requests for
select to authenticated using (
    exists (
      select 1 from public.memberships m
      where
        m.family_id = approval_requests.family_id
        and m.user_id = (select auth.uid ())
        and m.removed_at is null
    )
  );

create policy approval_requests_insert_self on public.approval_requests for insert to authenticated with
  check (
    requester_profile_id = (select auth.uid ())
      and exists (
        select 1 from public.memberships mx
        where
          mx.family_id = approval_requests.family_id
          and mx.user_id = (select auth.uid ())
          and mx.removed_at is null
      )
  );

create policy approval_requests_update_resolver on public.approval_requests for
update to authenticated using (
    exists (
      select 1 from public.memberships mo
      where
        mo.family_id = approval_requests.family_id
        and mo.user_id = (select auth.uid ())
        and mo.role in ('owner'::public.family_role, 'partner'::public.family_role)
        and mo.removed_at is null
    )
      or requester_profile_id = (select auth.uid ())
  )
with
  check (
    exists (
      select 1 from public.memberships mx
      where mx.family_id = approval_requests.family_id and mx.removed_at is null
    )
  );

grant select, insert, update, delete on table public.approval_auto_rules to authenticated;

grant select, insert, update on table public.approval_requests to authenticated;
