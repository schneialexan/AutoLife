-- Milestone 2: bootstrap family + profile for new auth users.

create or replace function public.handle_new_auth_user()
returns trigger
language plpgsql
security definer
set search_path = public, auth
as $$
declare
  v_family_id uuid;
  v_display_name text;
  v_family_name text;
begin
  -- Ensure we always satisfy NOT NULL constraints for profile rows.
  v_display_name := nullif(trim(coalesce(new.raw_user_meta_data->>'display_name', '')), '');
  if v_display_name is null then
    v_display_name := nullif(trim(coalesce(split_part(new.email, '@', 1), '')), '');
  end if;
  if v_display_name is null then
    v_display_name := 'User';
  end if;

  v_family_name := nullif(trim(coalesce(new.raw_user_meta_data->>'family_name', '')), '');
  if v_family_name is null then
    v_family_name := v_display_name || '''s Family';
  end if;

  -- Create a new family for the user (idempotent: same user insert should not duplicate profile).
  insert into public.families (name)
  values (v_family_name)
  returning id into v_family_id;

  insert into public.profiles (id, family_id, display_name)
  values (new.id, v_family_id, v_display_name)
  on conflict (id) do update set
    family_id = excluded.family_id,
    display_name = excluded.display_name;

  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row
execute function public.handle_new_auth_user();
