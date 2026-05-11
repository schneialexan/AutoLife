-- Phase 2.3: `family_role` enum and migrate tenancy role columns away from loose text.



create type public.family_role as enum (
  'owner',
  'partner',
  'child',
  'teenager',
  'grandparent',
  'guest',
  'babysitter'
);

alter table public.memberships add column role_new public.family_role;

update public.memberships
set role_new =
  case
    lower(trim(role))
      when 'owner' then 'owner'::public.family_role
      when 'partner' then 'partner'::public.family_role
      when 'member' then 'partner'::public.family_role
      when 'admin' then 'partner'::public.family_role
      when 'child' then 'child'::public.family_role
      when 'teenager' then 'teenager'::public.family_role
      when 'grandparent' then 'grandparent'::public.family_role
      when 'guest' then 'guest'::public.family_role
      when 'babysitter' then 'babysitter'::public.family_role
      else 'guest'::public.family_role
    end;

alter table public.memberships drop column role;

alter table public.memberships rename column role_new to role;

alter table public.memberships
  alter column role set default 'guest'::public.family_role,
  alter column role set not null;

alter table public.family_invitations add column invited_role_new public.family_role;

update public.family_invitations
set invited_role_new =
  case
    lower(trim(invited_role))
      when 'owner' then 'owner'::public.family_role
      when 'partner' then 'partner'::public.family_role
      when 'member' then 'partner'::public.family_role
      when 'admin' then 'partner'::public.family_role
      when 'child' then 'child'::public.family_role
      when 'teenager' then 'teenager'::public.family_role
      when 'grandparent' then 'grandparent'::public.family_role
      when 'guest' then 'guest'::public.family_role
      when 'babysitter' then 'babysitter'::public.family_role
      else 'partner'::public.family_role
    end;

alter table public.family_invitations drop column invited_role;

alter table public.family_invitations rename column invited_role_new to invited_role;

alter table public.family_invitations
  alter column invited_role set default 'partner'::public.family_role,
  alter column invited_role set not null;

comment on column public.memberships.role is 'Structured family_role (phase 2.3 policy engine).';

comment on column public.family_invitations.invited_role is 'Role granted on accept; family_role enum.';
