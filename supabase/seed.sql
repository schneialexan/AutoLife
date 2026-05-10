-- Seed data for local development (Milestone 1)

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
  updated_at
)
values
  (
    '00000000-0000-0000-0000-000000000000',
    '00000000-0000-0000-0000-0000000000a1',
    'authenticated',
    'authenticated',
    'alex@schneider.local',
    '',
    now(),
    '{"provider": "email", "providers": ["email"]}'::jsonb,
    '{"display_name": "Alex"}'::jsonb,
    now(),
    now()
  ),
  (
    '00000000-0000-0000-0000-000000000000',
    '00000000-0000-0000-0000-0000000000b1',
    'authenticated',
    'authenticated',
    'jessica@schneider.local',
    '',
    now(),
    '{"provider": "email", "providers": ["email"]}'::jsonb,
    '{"display_name": "Jessica"}'::jsonb,
    now(),
    now()
  )
on conflict (id) do update set
  email = excluded.email,
  raw_user_meta_data = excluded.raw_user_meta_data,
  updated_at = now();

insert into public.families (id, name)
values ('00000000-0000-0000-0000-000000000001', 'Schneider')
on conflict (id) do update set name = excluded.name;

insert into public.profiles (id, family_id, display_name, role)
values
  (
    '00000000-0000-0000-0000-0000000000a1',
    '00000000-0000-0000-0000-000000000001',
    'Alex',
    'co-parent'
  ),
  (
    '00000000-0000-0000-0000-0000000000b1',
    '00000000-0000-0000-0000-000000000001',
    'Jessica',
    'co-parent'
  )
on conflict (id) do update set
  family_id = excluded.family_id,
  display_name = excluded.display_name,
  role = excluded.role;

