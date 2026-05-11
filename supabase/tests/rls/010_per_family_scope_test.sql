-- Template coverage: per_family_scope (families + memberships visibility)

\set ON_ERROR_STOP on

\ir fixtures/users_and_families.inc

begin;

set local role authenticated;

select plan(9);

-- Outsider: no family row
select test_rls.set_auth ('a0000008-0001-4001-8001-000000000008'::uuid, 'out@rls.test');

select is (
  (
    select
      count(*)::int
    from
      public.families
    where
      id = 'f0000001-0001-4001-8001-000000000001'::uuid
  ),
  0,
  'outsider must not read fixture family'
);

-- Owner sees the family
select test_rls.set_auth ('a0000001-0001-4001-8001-000000000001'::uuid, 'owner@rls.test');

select is (
  (
    select
      count(*)::int
    from
      public.families
    where
      id = 'f0000001-0001-4001-8001-000000000001'::uuid
  ),
  1,
  'owner reads fixture family (per_family_scope)'
);

-- Partner, child, teenager, grandparent, guest, babysitter: must see family
select test_rls.set_auth ('a0000002-0001-4001-8001-000000000002'::uuid, 'partner@rls.test');

select is (
  (
    select
      count(*)::int
    from
      public.families
    where
      id = 'f0000001-0001-4001-8001-000000000001'::uuid
  ),
  1,
  'partner reads family'
);

select test_rls.set_auth ('a0000003-0001-4001-8001-000000000003'::uuid, 'child@rls.test');

select is (
  (
    select
      count(*)::int
    from
      public.families
    where
      id = 'f0000001-0001-4001-8001-000000000001'::uuid
  ),
  1,
  'child reads family'
);

select test_rls.set_auth ('a0000004-0001-4001-8001-000000000004'::uuid, 'teen@rls.test');

select is (
  (
    select
      count(*)::int
    from
      public.families
    where
      id = 'f0000001-0001-4001-8001-000000000001'::uuid
  ),
  1,
  'teenager reads family'
);

select test_rls.set_auth ('a0000005-0001-4001-8001-000000000005'::uuid, 'gp@rls.test');

select is (
  (
    select
      count(*)::int
    from
      public.families
    where
      id = 'f0000001-0001-4001-8001-000000000001'::uuid
  ),
  1,
  'grandparent reads family'
);

select test_rls.set_auth ('a0000006-0001-4001-8001-000000000006'::uuid, 'guest@rls.test');

select is (
  (
    select
      count(*)::int
    from
      public.families
    where
      id = 'f0000001-0001-4001-8001-000000000001'::uuid
  ),
  1,
  'guest reads family'
);

select test_rls.set_auth ('a0000007-0001-4001-8001-000000000007'::uuid, 'sit@rls.test');

select is (
  (
    select
      count(*)::int
    from
      public.families
    where
      id = 'f0000001-0001-4001-8001-000000000001'::uuid
  ),
  1,
  'babysitter reads family'
);

-- Memberships visible to member (sample: owner sees all fixture membership rows)
select test_rls.set_auth ('a0000001-0001-4001-8001-000000000001'::uuid, 'owner@rls.test');

select cmp_ok (
  (
    select
      count(*)::int
    from
      public.memberships
    where
      family_id = 'f0000001-0001-4001-8001-000000000001'::uuid
  ),
  '>=',
  5,
  'owner sees co-members (per_family_scope on memberships)'
);

select * from finish();

rollback;
