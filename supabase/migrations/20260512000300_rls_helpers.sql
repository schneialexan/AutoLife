-- Phase 2.4: shared RLS helper predicates for policy templates (docs/rls-templates.md).
-- Implemented as SECURITY DEFINER so policies on `memberships` can call these without RLS recursion.

-- ---------------------------------------------------------------------------
-- Membership: active row for current user in the given family
-- ---------------------------------------------------------------------------
create or replace function public.is_member_of (p_family_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select
      1
    from
      public.memberships m
    where
      m.family_id = p_family_id
      and m.user_id = auth.uid ()
      and m.removed_at is null
  );
$$;

comment on function public.is_member_of (uuid) is 'RLS helper: active membership; SECURITY DEFINER to avoid recursive RLS on memberships.';

-- ---------------------------------------------------------------------------
-- Role gate: active membership with an exact family_role
-- ---------------------------------------------------------------------------
create or replace function public.has_role (p_family_id uuid, p_role public.family_role)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select
      1
    from
      public.memberships m
    where
      m.family_id = p_family_id
      and m.user_id = auth.uid ()
      and m.removed_at is null
      and m.role = p_role
  );
$$;

comment on function public.has_role (uuid, public.family_role) is 'RLS helper: role check; SECURITY DEFINER to avoid recursive RLS on memberships.';

-- ---------------------------------------------------------------------------
-- Owner shortcut
-- ---------------------------------------------------------------------------
create or replace function public.is_owner_of (p_family_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select public.has_role (p_family_id, 'owner'::public.family_role);
$$;

comment on function public.is_owner_of (uuid) is 'RLS helper: owner role; chain uses SECURITY DEFINER helpers.';

-- ---------------------------------------------------------------------------
-- Babysitter predicate (see babysitter_scoped_read template; row-level flags narrow scope)
-- ---------------------------------------------------------------------------
create or replace function public.babysitter_can_read (p_family_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select public.has_role (p_family_id, 'babysitter'::public.family_role);
$$;

comment on function public.babysitter_can_read (uuid) is 'RLS helper: babysitter role; chain uses SECURITY DEFINER helpers.';

grant execute on function public.is_member_of (uuid) to authenticated;

grant execute on function public.has_role (uuid, public.family_role) to authenticated;

grant execute on function public.is_owner_of (uuid) to authenticated;

grant execute on function public.babysitter_can_read (uuid) to authenticated;
