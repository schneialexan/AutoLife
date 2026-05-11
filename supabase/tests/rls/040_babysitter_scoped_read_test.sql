-- babysitter_scoped_read on public.rls_babysitter_scope_demo

\set ON_ERROR_STOP on

\ir fixtures/users_and_families.inc

begin;

set local role authenticated;

select plan(3);

-- Babysitter sees only rows flagged babysitter_readable (1 of 2)
select test_rls.set_auth ('a0000007-0001-4001-8001-000000000007'::uuid, 'sit@rls.test');

select is (
  (
    select
      count(*)::int
    from
      public.rls_babysitter_scope_demo
    where
      family_id = 'f0000001-0001-4001-8001-000000000001'::uuid
  ),
  1,
  'babysitter reads babysitter_readable rows only'
);

-- Owner sees both demo rows
select test_rls.set_auth ('a0000001-0001-4001-8001-000000000001'::uuid, 'owner@rls.test');

select is (
  (
    select
      count(*)::int
    from
      public.rls_babysitter_scope_demo
    where
      family_id = 'f0000001-0001-4001-8001-000000000001'::uuid
  ),
  2,
  'owner reads full demo table'
);

-- Partner (non-babysitter) sees both
select test_rls.set_auth ('a0000002-0001-4001-8001-000000000002'::uuid, 'partner@rls.test');

select is (
  (
    select
      count(*)::int
    from
      public.rls_babysitter_scope_demo
    where
      family_id = 'f0000001-0001-4001-8001-000000000001'::uuid
  ),
  2,
  'partner reads full demo table (not babysitter scoped)'
);

select * from finish();

rollback;
