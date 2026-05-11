-- public.babysitter_scope(token[, meta]) combinations

\set ON_ERROR_STOP on

\ir fixtures/users_and_families.inc

begin;

insert into public.babysitter_links (
  id,
  family_id,
  token_hash,
  label,
  wifi_credentials,
  emergency_contacts,
  allergies,
  locations,
  created_by,
  expires_at,
  revoked_at
)
values
  (
    'c0000001-0001-4001-8001-000000000001'::uuid,
    'f0000001-0001-4001-8001-000000000001'::uuid,
    encode(digest('scope-token-a', 'sha256'), 'hex'),
    'fixture a',
    true,
    false,
    true,
    false,
    'a0000001-0001-4001-8001-000000000001'::uuid,
    now() + interval '1 day',
    null
  ),
  (
    'c0000002-0001-4001-8001-000000000002'::uuid,
    'f0000001-0001-4001-8001-000000000001'::uuid,
    encode(digest('expired-token', 'sha256'), 'hex'),
    'expired',
    true,
    true,
    false,
    false,
    'a0000001-0001-4001-8001-000000000001'::uuid,
    now() - interval '1 hour',
    null
  ),
  (
    'c0000003-0001-4001-8001-000000000003'::uuid,
    'f0000001-0001-4001-8001-000000000001'::uuid,
    encode(digest('revoked-token', 'sha256'), 'hex'),
    'revoked',
    false,
    false,
    false,
    true,
    'a0000001-0001-4001-8001-000000000001'::uuid,
    now() + interval '1 day',
    now()
  ),
  (
    'c0000004-0001-4001-8001-000000000004'::uuid,
    'f0000001-0001-4001-8001-000000000001'::uuid,
    encode(digest('all-off-token', 'sha256'), 'hex'),
    'all off',
    false,
    false,
    false,
    false,
    'a0000001-0001-4001-8001-000000000001'::uuid,
    now() + interval '1 day',
    null
  ),
  (
    'c0000005-0001-4001-8001-000000000005'::uuid,
    'f0000001-0001-4001-8001-000000000001'::uuid,
    encode(digest('all-on-token', 'sha256'), 'hex'),
    'all on',
    true,
    true,
    true,
    true,
    'a0000001-0001-4001-8001-000000000001'::uuid,
    now() + interval '1 day',
    null
  );

set local role authenticated;

select plan(8);

select test_rls.set_auth ('a0000001-0001-4001-8001-000000000001'::uuid, 'owner@rls.test');

select is (
  public.babysitter_scope('scope-token-a')->>'status',
  'ok',
  'valid token: status ok'
);

select is (
  public.babysitter_scope('scope-token-a')->>'family_id',
  'f0000001-0001-4001-8001-000000000001',
  'valid token: family_id'
);

select cmp_ok (
  public.babysitter_scope('scope-token-a')->'resources',
  '=',
  '["wifi_credentials", "allergies"]'::jsonb,
  'valid token: resource toggles'
);

select is (
  public.babysitter_scope('expired-token')->>'status',
  'expired',
  'expired token'
);

select is (
  public.babysitter_scope('revoked-token')->>'status',
  'revoked',
  'revoked token'
);

select is (
  public.babysitter_scope('nope')->>'status',
  'invalid',
  'unknown token'
);

select cmp_ok (
  public.babysitter_scope('all-off-token')->'resources',
  '=',
  '[]'::jsonb,
  'no toggles → empty resources'
);

select cmp_ok (
  public.babysitter_scope('all-on-token')->'resources',
  '=',
  '["wifi_credentials", "emergency_contacts", "allergies", "locations"]'::jsonb,
  'all toggles on'
);

select * from finish();

rollback;
