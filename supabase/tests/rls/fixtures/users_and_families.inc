-- Deterministic users + one family used by pgTAP RLS tests (Phase 2.4).
-- Include only (.inc — not auto-run by pg_prove). Requires superuser for auth.users.
-- Path: supabase/tests/rls/fixtures/users_and_families.inc

create extension if not exists pgcrypto with schema extensions;

create schema if not exists test_rls;

grant usage on schema test_rls to authenticated;

-- Set JWT claims the same way PostgREST / GoTrue do for RLS tests.
create or replace function test_rls.set_auth (uid uuid, email text default null)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  perform set_config('request.jwt.claim.sub', uid::text, true);
  if email is not null then
    perform set_config('request.jwt.claim.email', email, true);
  end if;
  perform set_config(
    'request.jwt.claims',
    json_build_object('sub', uid::text, 'email', coalesce(email, ''))::text,
    true
  );
end;
$$;

grant execute on function test_rls.set_auth (uuid, text) to authenticated;

-- ---------------------------------------------------------------------------
-- Fixed UUID v4 constants (deterministic test identities)
-- ---------------------------------------------------------------------------

do $$
declare
  fid uuid := 'f0000001-0001-4001-8001-000000000001'::uuid;
  iid uuid := '00000000-0000-0000-0000-000000000000'::uuid;
begin
  insert into auth.users (
    instance_id,
    id,
    aud,
    role,
    email,
    encrypted_password,
    email_confirmed_at,
    raw_app_meta_data,
    raw_user_meta_data,
    created_at,
    updated_at,
    confirmation_token,
    email_change,
    email_change_token_new,
    recovery_token
  )
    values
      (
        iid,
        'a0000001-0001-4001-8001-000000000001'::uuid,
        'authenticated',
        'authenticated',
        'owner@rls.test',
        extensions.crypt('pw', extensions.gen_salt('bf')),
        now(),
        '{}',
        '{}',
        now(),
        now(),
        '',
        '',
        '',
        ''
      ),
      (
        iid,
        'a0000002-0001-4001-8001-000000000002'::uuid,
        'authenticated',
        'authenticated',
        'partner@rls.test',
        extensions.crypt('pw', extensions.gen_salt('bf')),
        now(),
        '{}',
        '{}',
        now(),
        now(),
        '',
        '',
        '',
        ''
      ),
      (
        iid,
        'a0000003-0001-4001-8001-000000000003'::uuid,
        'authenticated',
        'authenticated',
        'child@rls.test',
        extensions.crypt('pw', extensions.gen_salt('bf')),
        now(),
        '{}',
        '{}',
        now(),
        now(),
        '',
        '',
        '',
        ''
      ),
      (
        iid,
        'a0000004-0001-4001-8001-000000000004'::uuid,
        'authenticated',
        'authenticated',
        'teen@rls.test',
        extensions.crypt('pw', extensions.gen_salt('bf')),
        now(),
        '{}',
        '{}',
        now(),
        now(),
        '',
        '',
        '',
        ''
      ),
      (
        iid,
        'a0000005-0001-4001-8001-000000000005'::uuid,
        'authenticated',
        'authenticated',
        'gp@rls.test',
        extensions.crypt('pw', extensions.gen_salt('bf')),
        now(),
        '{}',
        '{}',
        now(),
        now(),
        '',
        '',
        '',
        ''
      ),
      (
        iid,
        'a0000006-0001-4001-8001-000000000006'::uuid,
        'authenticated',
        'authenticated',
        'guest@rls.test',
        extensions.crypt('pw', extensions.gen_salt('bf')),
        now(),
        '{}',
        '{}',
        now(),
        now(),
        '',
        '',
        '',
        ''
      ),
      (
        iid,
        'a0000007-0001-4001-8001-000000000007'::uuid,
        'authenticated',
        'authenticated',
        'sit@rls.test',
        extensions.crypt('pw', extensions.gen_salt('bf')),
        now(),
        '{}',
        '{}',
        now(),
        now(),
        '',
        '',
        '',
        ''
      ),
      (
        iid,
        'a0000008-0001-4001-8001-000000000008'::uuid,
        'authenticated',
        'authenticated',
        'out@rls.test',
        extensions.crypt('pw', extensions.gen_salt('bf')),
        now(),
        '{}',
        '{}',
        now(),
        now(),
        '',
        '',
        '',
        ''
      )
  on conflict (id) do nothing;

  insert into public.families (id, name, created_by, created_at, archived_at, settings)
    values (fid, 'RLS Fixture Family', 'a0000001-0001-4001-8001-000000000001'::uuid, now(), null, '{}'::jsonb)
  on conflict (id) do nothing;

  insert into public.profile (id, display_name, active_family_id)
    values
      ('a0000001-0001-4001-8001-000000000001'::uuid, 'RLS Owner', fid),
      ('a0000002-0001-4001-8001-000000000002'::uuid, 'RLS Partner', fid),
      ('a0000003-0001-4001-8001-000000000003'::uuid, 'RLS Child', fid),
      ('a0000004-0001-4001-8001-000000000004'::uuid, 'RLS Teen', fid),
      ('a0000005-0001-4001-8001-000000000005'::uuid, 'RLS GP', fid),
      ('a0000006-0001-4001-8001-000000000006'::uuid, 'RLS Guest', fid),
      ('a0000007-0001-4001-8001-000000000007'::uuid, 'RLS Sitter', fid),
      ('a0000008-0001-4001-8001-000000000008'::uuid, 'RLS Outsider', null)
  on conflict (id) do nothing;

  insert into public.memberships (family_id, user_id, role, joined_at, removed_at, updated_at)
    values
      (fid, 'a0000001-0001-4001-8001-000000000001'::uuid, 'owner', now(), null, now()),
      (fid, 'a0000002-0001-4001-8001-000000000002'::uuid, 'partner', now(), null, now()),
      (fid, 'a0000003-0001-4001-8001-000000000003'::uuid, 'child', now(), null, now()),
      (fid, 'a0000004-0001-4001-8001-000000000004'::uuid, 'teenager', now(), null, now()),
      (fid, 'a0000005-0001-4001-8001-000000000005'::uuid, 'grandparent', now(), null, now()),
      (fid, 'a0000006-0001-4001-8001-000000000006'::uuid, 'guest', now(), null, now()),
      (fid, 'a0000007-0001-4001-8001-000000000007'::uuid, 'babysitter', now(), null, now())
  on conflict (family_id, user_id) do update set
    role = excluded.role,
    removed_at = excluded.removed_at,
    updated_at = excluded.updated_at;

  insert into public.rls_babysitter_scope_demo (id, family_id, label, babysitter_readable)
    values
      (
        'b0000001-0001-4001-8001-000000000001'::uuid,
        fid,
        'open-to-babysitter',
        true
      ),
      (
        'b0000002-0001-4001-8001-000000000002'::uuid,
        fid,
        'members-only',
        false
      )
  on conflict (id) do nothing;
end;
$$;
