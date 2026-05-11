-- Dev-only seed: one family, two profiles, memberships (no auth.users required for stub profile ids).

insert into public.family (id, display_name)
values (
    '11111111-1111-1111-1111-111111111111'::uuid,
    'Demo Family'
  )
on conflict (id) do nothing;

insert into public.profile (id, display_name, family_id)
values
  (
    '22222222-2222-2222-2222-222222222201'::uuid,
    'Alex Demo',
    '11111111-1111-1111-1111-111111111111'::uuid
  ),
  (
    '22222222-2222-2222-2222-222222222202'::uuid,
    'Sam Demo',
    '11111111-1111-1111-1111-111111111111'::uuid
  )
on conflict (id) do nothing;

insert into public.membership (id, family_id, profile_id, role)
values
  (
    '33333333-3333-3333-3333-333333333301'::uuid,
    '11111111-1111-1111-1111-111111111111'::uuid,
    '22222222-2222-2222-2222-222222222201'::uuid,
    'owner'
  ),
  (
    '33333333-3333-3333-3333-333333333302'::uuid,
    '11111111-1111-1111-1111-111111111111'::uuid,
    '22222222-2222-2222-2222-222222222202'::uuid,
    'member'
  )
on conflict (id) do nothing;
