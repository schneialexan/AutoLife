-- Phase 2.3: Capability default matrix (`capability_matrix_default`) and per-family `capability_grants`.

create table public.capability_matrix_default (
  role public.family_role not null,
  capability text not null,
  granted boolean not null,
  requires_parent_approval boolean not null default false,
  require_photo_proof boolean not null default false,
  require_parent_verification boolean not null default false,
  updated_at timestamptz not null default now(),
  primary key (role, capability)
);

comment on table public.capability_matrix_default is 'Global template seeded from packages/autolife-core/policy/matrix.yaml (codegen).';

create table public.capability_grants (
  family_id uuid not null references public.families (id) on delete cascade,
  role public.family_role not null,
  capability text not null,
  granted boolean not null,
  requires_parent_approval boolean not null default false,
  require_photo_proof boolean not null default false,
  require_parent_verification boolean not null default false,
  updated_at timestamptz not null default now(),
  primary key (family_id, role, capability)
);

comment on table public.capability_grants is 'Family-scoped overrides; copied from defaults at family bootstrap.';

create index capability_grants_family_idx on public.capability_grants (family_id);

-- ---------------------------------------------------------------------------
-- Populate defaults (generated INSERTs patched by codegen)
-- ---------------------------------------------------------------------------
-- @autolife-codegen:policy-matrix-seed-begin
insert into public.capability_matrix_default (
  role,
  capability,
  granted,
  requires_parent_approval,
  require_photo_proof,
  require_parent_verification
)
values 
  ('owner'::family_role, 'allowance.manage', true, false, false, false),
  ('owner'::family_role, 'allowance.view', true, false, false, false),
  ('owner'::family_role, 'calendar.create_event', true, false, false, false),
  ('owner'::family_role, 'calendar.edit_own_event', true, false, false, false),
  ('owner'::family_role, 'calendar.view', true, false, false, false),
  ('owner'::family_role, 'chores.complete_task', true, false, false, false),
  ('owner'::family_role, 'chores.manage_assignments', true, false, false, false),
  ('owner'::family_role, 'chores.view_assigned', true, false, false, false),
  ('owner'::family_role, 'dashboard.customize_family_default', true, false, false, false),
  ('owner'::family_role, 'dashboard.customize_own', true, false, false, false),
  ('owner'::family_role, 'family.invite_members', true, false, false, false),
  ('owner'::family_role, 'family.manage_policy', true, false, false, false),
  ('owner'::family_role, 'family.view_members', true, false, false, false),
  ('partner'::family_role, 'allowance.manage', true, false, false, false),
  ('partner'::family_role, 'allowance.view', true, false, false, false),
  ('partner'::family_role, 'calendar.create_event', true, false, false, false),
  ('partner'::family_role, 'calendar.edit_own_event', true, false, false, false),
  ('partner'::family_role, 'calendar.view', true, false, false, false),
  ('partner'::family_role, 'chores.complete_task', true, false, false, false),
  ('partner'::family_role, 'chores.manage_assignments', true, false, false, false),
  ('partner'::family_role, 'chores.view_assigned', true, false, false, false),
  ('partner'::family_role, 'dashboard.customize_family_default', false, false, false, false),
  ('partner'::family_role, 'dashboard.customize_own', true, false, false, false),
  ('partner'::family_role, 'family.invite_members', true, false, false, false),
  ('partner'::family_role, 'family.manage_policy', false, false, false, false),
  ('partner'::family_role, 'family.view_members', true, false, false, false),
  ('child'::family_role, 'allowance.manage', false, false, false, false),
  ('child'::family_role, 'allowance.view', true, false, false, false),
  ('child'::family_role, 'calendar.create_event', true, true, false, false),
  ('child'::family_role, 'calendar.edit_own_event', false, false, false, false),
  ('child'::family_role, 'calendar.view', true, false, false, false),
  ('child'::family_role, 'chores.complete_task', true, false, true, true),
  ('child'::family_role, 'chores.manage_assignments', false, false, false, false),
  ('child'::family_role, 'chores.view_assigned', true, false, false, false),
  ('child'::family_role, 'dashboard.customize_family_default', false, false, false, false),
  ('child'::family_role, 'dashboard.customize_own', true, false, false, false),
  ('child'::family_role, 'family.invite_members', false, false, false, false),
  ('child'::family_role, 'family.manage_policy', false, false, false, false),
  ('child'::family_role, 'family.view_members', true, false, false, false),
  ('teenager'::family_role, 'allowance.manage', false, false, false, false),
  ('teenager'::family_role, 'allowance.view', true, false, false, false),
  ('teenager'::family_role, 'calendar.create_event', true, true, false, false),
  ('teenager'::family_role, 'calendar.edit_own_event', true, false, false, false),
  ('teenager'::family_role, 'calendar.view', true, false, false, false),
  ('teenager'::family_role, 'chores.complete_task', true, false, false, true),
  ('teenager'::family_role, 'chores.manage_assignments', false, false, false, false),
  ('teenager'::family_role, 'chores.view_assigned', true, false, false, false),
  ('teenager'::family_role, 'dashboard.customize_family_default', false, false, false, false),
  ('teenager'::family_role, 'dashboard.customize_own', true, false, false, false),
  ('teenager'::family_role, 'family.invite_members', false, false, false, false),
  ('teenager'::family_role, 'family.manage_policy', false, false, false, false),
  ('teenager'::family_role, 'family.view_members', true, false, false, false),
  ('grandparent'::family_role, 'allowance.manage', false, false, false, false),
  ('grandparent'::family_role, 'allowance.view', false, false, false, false),
  ('grandparent'::family_role, 'calendar.create_event', true, true, false, false),
  ('grandparent'::family_role, 'calendar.edit_own_event', true, false, false, false),
  ('grandparent'::family_role, 'calendar.view', true, false, false, false),
  ('grandparent'::family_role, 'chores.complete_task', false, false, false, false),
  ('grandparent'::family_role, 'chores.manage_assignments', false, false, false, false),
  ('grandparent'::family_role, 'chores.view_assigned', false, false, false, false),
  ('grandparent'::family_role, 'dashboard.customize_family_default', false, false, false, false),
  ('grandparent'::family_role, 'dashboard.customize_own', true, false, false, false),
  ('grandparent'::family_role, 'family.invite_members', false, false, false, false),
  ('grandparent'::family_role, 'family.manage_policy', false, false, false, false),
  ('grandparent'::family_role, 'family.view_members', true, false, false, false),
  ('guest'::family_role, 'allowance.manage', false, false, false, false),
  ('guest'::family_role, 'allowance.view', false, false, false, false),
  ('guest'::family_role, 'calendar.create_event', false, false, false, false),
  ('guest'::family_role, 'calendar.edit_own_event', false, false, false, false),
  ('guest'::family_role, 'calendar.view', true, false, false, false),
  ('guest'::family_role, 'chores.complete_task', false, false, false, false),
  ('guest'::family_role, 'chores.manage_assignments', false, false, false, false),
  ('guest'::family_role, 'chores.view_assigned', false, false, false, false),
  ('guest'::family_role, 'dashboard.customize_family_default', false, false, false, false),
  ('guest'::family_role, 'dashboard.customize_own', false, false, false, false),
  ('guest'::family_role, 'family.invite_members', false, false, false, false),
  ('guest'::family_role, 'family.manage_policy', false, false, false, false),
  ('guest'::family_role, 'family.view_members', false, false, false, false),
  ('babysitter'::family_role, 'allowance.manage', false, false, false, false),
  ('babysitter'::family_role, 'allowance.view', false, false, false, false),
  ('babysitter'::family_role, 'calendar.create_event', true, true, false, false),
  ('babysitter'::family_role, 'calendar.edit_own_event', true, false, false, false),
  ('babysitter'::family_role, 'calendar.view', true, false, false, false),
  ('babysitter'::family_role, 'chores.complete_task', true, false, false, false),
  ('babysitter'::family_role, 'chores.manage_assignments', false, false, false, false),
  ('babysitter'::family_role, 'chores.view_assigned', true, false, false, false),
  ('babysitter'::family_role, 'dashboard.customize_family_default', false, false, false, false),
  ('babysitter'::family_role, 'dashboard.customize_own', true, false, false, false),
  ('babysitter'::family_role, 'family.invite_members', false, false, false, false),
  ('babysitter'::family_role, 'family.manage_policy', false, false, false, false),
  ('babysitter'::family_role, 'family.view_members', true, false, false, false)
on conflict (role, capability) do update set
  granted = excluded.granted,
  requires_parent_approval = excluded.requires_parent_approval,
  require_photo_proof = excluded.require_photo_proof,
  require_parent_verification = excluded.require_parent_verification;

-- @autolife-codegen:policy-matrix-seed-end

-- ---------------------------------------------------------------------------
-- Seed function + trigger + historical backfill
-- ---------------------------------------------------------------------------
create or replace function public.seed_capability_grants_from_defaults (target_family uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.capability_grants (
    family_id,
    role,
    capability,
    granted,
    requires_parent_approval,
    require_photo_proof,
    require_parent_verification,
    updated_at
  )
  select
    target_family,
    d.role,
    d.capability,
    d.granted,
    d.requires_parent_approval,
    d.require_photo_proof,
    d.require_parent_verification,
    now()
  from public.capability_matrix_default d
on conflict (family_id, role, capability) do nothing;
end;
$$;

grant execute on function public.seed_capability_grants_from_defaults (uuid) to authenticated;

create or replace function public._autolife_seed_capabilities_on_membership ()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if NEW.removed_at is null and NEW.role = 'owner'::public.family_role then
    if not exists (
      select 1 from public.capability_grants cg
      where cg.family_id = NEW.family_id
    ) then perform public.seed_capability_grants_from_defaults (NEW.family_id);
    end if;
  end if;
  return NEW;
end;
$$;

drop trigger if exists trig_seed_capabilities_on_membership_insert on public.memberships;

create trigger trig_seed_capabilities_on_membership_insert
after insert on public.memberships for each row
execute procedure public._autolife_seed_capabilities_on_membership ();

do $$
declare
  r record;
begin
for r in
select
  id
from public.families f
where not exists (
  select 1 from public.capability_grants cg where cg.family_id = f.id
)
loop
  perform public.seed_capability_grants_from_defaults (r.id);
end loop;
end;
$$;

-- ---------------------------------------------------------------------------
-- Baseline RLS (stricter layering in phase 2.4)
-- ---------------------------------------------------------------------------
alter table public.capability_matrix_default enable row level security;

create policy capability_matrix_default_read_authenticated on public.capability_matrix_default for
select to authenticated using (true);

alter table public.capability_grants enable row level security;

create policy capability_grants_select_members on public.capability_grants for
select to authenticated using (
    exists (
      select 1 from public.memberships m
      where
        m.family_id = capability_grants.family_id
        and m.user_id = (select auth.uid ())
        and m.removed_at is null
    )
  );

create policy capability_grants_insert_owner on public.capability_grants for insert to authenticated with
  check (
    exists (
      select 1 from public.memberships mo
      where
        mo.family_id = capability_grants.family_id
        and mo.user_id = (select auth.uid ())
        and mo.role = 'owner'::public.family_role
        and mo.removed_at is null
    )
  );

create policy capability_grants_update_owner on public.capability_grants for
update to authenticated using (
    exists (
      select 1 from public.memberships mo
      where
        mo.family_id = capability_grants.family_id
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
        mo.family_id = capability_grants.family_id
        and mo.user_id = (select auth.uid ())
        and mo.role = 'owner'::public.family_role
        and mo.removed_at is null
    )
  );

grant select on table public.capability_matrix_default to authenticated;

grant select, insert, update on table public.capability_grants to authenticated;
