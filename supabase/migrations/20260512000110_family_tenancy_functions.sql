-- Phase 2.2: SECURITY DEFINER helpers for invitations and admin membership removal.

-- Replace auth profile sync to match profile schema (no family_id).
create or replace function public.sync_auth_profile_from_user ()
  returns trigger
  language plpgsql
  security definer
  set search_path = public, extensions
as $$
declare
  display_name text;
begin
  display_name := coalesce(
    nullif(trim(coalesce(NEW.raw_user_meta_data ->> 'full_name', '')), ''),
    nullif(trim(coalesce(NEW.raw_user_meta_data ->> 'name', '')), ''),
    nullif(trim(split_part(coalesce(NEW.email::text, ''), '@', 1)), ''),
    'AutoLife member'
  );

  insert into public.profile (id, display_name, active_family_id)
    values (NEW.id, display_name, null)
  on conflict (id)
    do update set
      display_name = excluded.display_name;

  return NEW;
end;
$$;

-- ---------------------------------------------------------------------------
-- Accept invitation: validates token hash + signed-in email, upserts membership.
-- ---------------------------------------------------------------------------
create or replace function public.accept_invitation (token text)
  returns jsonb
  language plpgsql
  security definer
  set search_path = public, extensions
as $$
declare
  v_hash text;
  inv public.family_invitations%rowtype;
  jwt_email text;
begin
  if token is null or trim(token) = '' then
    raise exception 'invitation_token_missing' using errcode = 'P0001';
  end if;

  v_hash := encode(
    extensions.digest(convert_to(trim(token), 'UTF8'), 'sha256'),
    'hex'
  );

  select *
    into inv
  from public.family_invitations fi
  where fi.token_hash = v_hash
    and fi.revoked_at is null
    and fi.accepted_at is null
    and fi.expires_at > now();

  if not found then
    raise exception 'invitation_invalid_or_expired' using errcode = 'P0001';
  end if;

  jwt_email := nullif(lower(trim(auth.jwt () ->> 'email')), '');
  if jwt_email is null or jwt_email <> lower(trim(inv.email)) then
    raise exception 'invitation_email_mismatch' using errcode = 'P0001';
  end if;

  insert into public.memberships as m (family_id, user_id, role, joined_at, removed_at, updated_at)
    values (inv.family_id, auth.uid (), inv.invited_role, now(), null, now())
  on conflict (family_id, user_id) do update
    set
      removed_at = null,
      role = excluded.role,
      joined_at = now(),
      updated_at = now();

  update public.family_invitations
    set
      accepted_at = now(),
      updated_at = now()
    where
      id = inv.id;

  update public.profile
    set
      active_family_id = inv.family_id,
      updated_at = now()
    where
      id = auth.uid ();

  return jsonb_build_object(
    'family_id', inv.family_id,
    'role', inv.invited_role
  );
end;
$$;

-- ---------------------------------------------------------------------------
-- Revoke (inviter only).
-- ---------------------------------------------------------------------------
create or replace function public.revoke_invitation (invitation_id uuid)
  returns void
  language plpgsql
  security definer
  set search_path = public, extensions
as $$
declare
  updated_id uuid;
begin
  update public.family_invitations fi
  set
    revoked_at = now(),
    updated_at = now()
  where
    fi.id = invitation_id
    and fi.invited_by = auth.uid ()
    and fi.accepted_at is null
    and fi.revoked_at is null
  returning
    fi.id into updated_id;

  if updated_id is null then
    raise exception 'revoke_invitation_failed' using errcode = 'P0001';
  end if;
end;
$$;

-- ---------------------------------------------------------------------------
-- Family creator may soft-remove another member (not self; not creator guard optional).
-- ---------------------------------------------------------------------------
create or replace function public.remove_family_membership (p_family_id uuid, p_user_id uuid)
  returns void
  language plpgsql
  security definer
  set search_path = public, extensions
as $$
declare
  n integer;
begin
  if p_user_id = auth.uid () then
    raise exception 'use_leave_family_for_self' using errcode = 'P0001';
  end if;

  if not exists (
    select 1
    from public.families f
    where
      f.id = p_family_id
      and f.created_by = auth.uid ()
      and f.archived_at is null
  ) then
    raise exception 'not_authorized_to_remove_members' using errcode = 'P0001';
  end if;

  update public.memberships m
  set
    removed_at = now(),
    updated_at = now()
  where
    m.family_id = p_family_id
    and m.user_id = p_user_id
    and m.removed_at is null;

  get diagnostics n = row_count;
  if n = 0 then
    raise exception 'membership_not_found' using errcode = 'P0001';
  end if;
end;
$$;

grant execute on function public.accept_invitation (text) to authenticated;

grant execute on function public.revoke_invitation (uuid) to authenticated;

grant execute on function public.remove_family_membership (uuid, uuid) to authenticated;
