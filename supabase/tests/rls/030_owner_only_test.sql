-- owner_only template: capability_grants mutations require owner membership

\set ON_ERROR_STOP on

\ir fixtures/users_and_families.inc

begin;

set local role authenticated;

select plan(2);

-- Partner cannot update grants (RLS filters all rows — no error, zero rows updated)
select test_rls.set_auth ('a0000002-0001-4001-8001-000000000002'::uuid, 'partner@rls.test');

with
  up as (
    update public.capability_grants
    set
      granted = false,
      updated_at = now()
    where
      family_id = 'f0000001-0001-4001-8001-000000000001'::uuid
      and role = 'child'::public.family_role
      and capability = 'allowance.view'
    returning
      1
  )
select
  is (
    (
      select
        count(*)::int
      from
        up
    ),
    0,
    'partner capability_grants update affects zero rows (owner_only)'
  );

-- Owner can update grants
select test_rls.set_auth ('a0000001-0001-4001-8001-000000000001'::uuid, 'owner@rls.test');

select lives_ok (
  $$
  update public.capability_grants
  set
    granted = granted,
    updated_at = now()
  where
    family_id = 'f0000001-0001-4001-8001-000000000001'::uuid
    and role = 'child'::public.family_role
    and capability = 'allowance.view';
  $$,
  'owner updates capability_grants (owner_only)'
);

select * from finish();

rollback;
