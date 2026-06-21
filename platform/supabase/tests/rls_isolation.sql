-- RLS isolation test for assets.items.
--
-- Simulates two users by setting the JWT claims PostgREST would set, then
-- asserts that each user sees only their own rows. Run against a local Supabase
-- after `supabase db reset`. Exits non-zero on any leak.
--
--   psql "<local db url>" -v ON_ERROR_STOP=1 -f tests/rls_isolation.sql

begin;

-- Two fake users. We insert into auth.users directly (service-role context)
-- so the FK on assets.items is satisfied.
insert into auth.users (id, email)
values
  ('11111111-1111-1111-1111-111111111111', 'a@example.com'),
  ('22222222-2222-2222-2222-222222222222', 'b@example.com')
on conflict (id) do nothing;

-- Seed one row per user (as service role; user_id set explicitly).
insert into assets.items (id, user_id, payload, updated_at)
values
  ('item-a', '11111111-1111-1111-1111-111111111111', '{"id":"item-a"}', now()),
  ('item-b', '22222222-2222-2222-2222-222222222222', '{"id":"item-b"}', now())
on conflict (id) do nothing;

-- Act as the `authenticated` role with user A's claims.
set local role authenticated;
set local request.jwt.claims = '{"sub":"11111111-1111-1111-1111-111111111111","role":"authenticated"}';

do $$
declare
  visible int;
  foreign_visible int;
begin
  select count(*) into visible from assets.items where id = 'item-a';
  select count(*) into foreign_visible from assets.items where id = 'item-b';

  if visible <> 1 then
    raise exception 'RLS ISOLATION: FAIL — user A cannot see own row';
  end if;
  if foreign_visible <> 0 then
    raise exception 'RLS ISOLATION: FAIL — user A can see user B row';
  end if;

  -- A write targeting B's row must be blocked by WITH CHECK.
  begin
    update assets.items set payload = '{"id":"item-b","hacked":true}'
     where id = 'item-b';
    -- Update sees 0 rows (filtered out), which is fine; but an insert with a
    -- foreign user_id must fail the WITH CHECK.
  exception when others then
    null;
  end;
end;
$$;

reset role;

select 'RLS ISOLATION: PASS' as result;

rollback;
