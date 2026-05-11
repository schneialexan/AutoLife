-- per_role_gate: owner-only capability grant writes (insert deny for non-owner roles)

\set ON_ERROR_STOP on

\ir fixtures/users_and_families.inc

begin;

set local role authenticated;

select plan(5);

-- Deny: partner insert
select test_rls.set_auth ('a0000002-0001-4001-8001-000000000002'::uuid, 'partner@rls.test');

select throws_matching (
  $$
  insert into public.capability_grants (
    family_id,
    role,
    capability,
    granted,
    updated_at
  )
    values (
      'f0000001-0001-4001-8001-000000000001'::uuid,
      'child'::public.family_role,
      'rls.gate.partner_probe',
      false,
      now()
    );
  $$,
  'row-level security policy',
  'partner denied capability_grants insert (per_role_gate / owner_only)'
);

-- Deny: child insert
select test_rls.set_auth ('a0000003-0001-4001-8001-000000000003'::uuid, 'child@rls.test');

select throws_matching (
  $$
  insert into public.capability_grants (
    family_id,
    role,
    capability,
    granted,
    updated_at
  )
    values (
      'f0000001-0001-4001-8001-000000000001'::uuid,
      'guest'::public.family_role,
      'rls.gate.child_probe',
      false,
      now()
    );
  $$,
  'row-level security policy',
  'child denied capability_grants insert'
);

-- Deny: babysitter insert
select test_rls.set_auth ('a0000007-0001-4001-8001-000000000007'::uuid, 'sit@rls.test');

select throws_matching (
  $$
  insert into public.capability_grants (
    family_id,
    role,
    capability,
    granted,
    updated_at
  )
    values (
      'f0000001-0001-4001-8001-000000000001'::uuid,
      'guest'::public.family_role,
      'rls.gate.sitter_probe',
      false,
      now()
    );
  $$,
  'row-level security policy',
  'babysitter denied capability_grants insert'
);

-- Allow: owner insert (per_role_gate: has_role owner)
select test_rls.set_auth ('a0000001-0001-4001-8001-000000000001'::uuid, 'owner@rls.test');

select lives_ok (
  $$
  insert into public.capability_grants (
    family_id,
    role,
    capability,
    granted,
    updated_at
  )
    values (
      'f0000001-0001-4001-8001-000000000001'::uuid,
      'child'::public.family_role,
      'rls.gate.owner_ok',
      false,
      now()
    );
  $$,
  'owner may insert capability_grants'
);

-- approval_requests UPDATE: grandparent denied — resolver uses has_role owner/partner
select test_rls.set_auth ('a0000003-0001-4001-8001-000000000003'::uuid, 'child@rls.test');

insert into public.approval_requests (
  id,
  family_id,
  requester_profile_id,
  capability,
  status,
  payload
)
  values (
    'c0000001-0001-4001-8001-000000000001'::uuid,
    'f0000001-0001-4001-8001-000000000001'::uuid,
    'a0000003-0001-4001-8001-000000000003'::uuid,
    'calendar.create_event',
    'pending'::public.approval_request_status,
    '{}'::jsonb
  )
on conflict (id) do update set
  updated_at = excluded.updated_at;

select test_rls.set_auth ('a0000005-0001-4001-8001-000000000005'::uuid, 'gp@rls.test');

update public.approval_requests
set
  status = 'rejected'::public.approval_request_status
where
  id = 'c0000001-0001-4001-8001-000000000001'::uuid;

select is (
  (
    select
      status::text
    from
      public.approval_requests
    where
      id = 'c0000001-0001-4001-8001-000000000001'::uuid
  ),
  'pending',
  'grandparent approval_requests row unchanged (per_role_gate)'
);

select * from finish();

rollback;
