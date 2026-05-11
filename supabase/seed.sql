-- Dev-only seed: one family, two profiles, memberships (no auth.users required for stub profile ids).

insert into public.families (id, name, created_by, created_at, archived_at, settings)
values (
    '11111111-1111-1111-1111-111111111111'::uuid,
    'Demo Family',
    null,
    now(),
    null,
    '{}'::jsonb
  )
on conflict (id) do nothing;

insert into public.profile (id, display_name, active_family_id)
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

insert into public.memberships (family_id, user_id, role, joined_at, removed_at, updated_at)
values
  (
    '11111111-1111-1111-1111-111111111111'::uuid,
    '22222222-2222-2222-2222-222222222201'::uuid,
    'owner',
    now(),
    null,
    now()
  ),
  (
    '11111111-1111-1111-1111-111111111111'::uuid,
    '22222222-2222-2222-2222-222222222202'::uuid,
    'partner',
    now(),
    null,
    now()
  )
on conflict (family_id, user_id) do nothing;

insert into public.approval_auto_rules (
  family_id,
  role,
  capability,
  label,
  enabled,
  match
)
values
  (
    '11111111-1111-1111-1111-111111111111'::uuid,
    'teenager'::family_role,
    'calendar.create_event',
    'school_location',
    true,
    '{"location_normalized":"school"}'::jsonb
  )
on conflict on constraint approval_auto_rules_unique_label do nothing;
