-- Phase 2.4: replace baseline policies with documented templates (supabase/policies/*.tpl).

-- ---------------------------------------------------------------------------
-- Drop Phase 2.2 / 2.3 policies (names are stable across those migrations)
-- ---------------------------------------------------------------------------
drop policy if exists families_select_creator on public.families;

drop policy if exists families_select_active_member on public.families;

drop policy if exists families_insert_self on public.families;

drop policy if exists families_update_creator on public.families;

drop policy if exists memberships_select_visible on public.memberships;

drop policy if exists memberships_insert_self on public.memberships;

drop policy if exists memberships_update_self on public.memberships;

drop policy if exists family_invitations_select on public.family_invitations;

drop policy if exists family_invitations_select_recipient on public.family_invitations;

drop policy if exists family_invitations_insert_member on public.family_invitations;

drop policy if exists family_invitations_update_inviter on public.family_invitations;

drop policy if exists capability_matrix_default_read_authenticated on public.capability_matrix_default;

drop policy if exists capability_grants_select_members on public.capability_grants;

drop policy if exists capability_grants_insert_owner on public.capability_grants;

drop policy if exists capability_grants_update_owner on public.capability_grants;

drop policy if exists approval_auto_rules_select_members on public.approval_auto_rules;

drop policy if exists approval_auto_rules_write_owner on public.approval_auto_rules;

drop policy if exists approval_requests_select_members on public.approval_requests;

drop policy if exists approval_requests_insert_self on public.approval_requests;

drop policy if exists approval_requests_update_resolver on public.approval_requests;

-- ---------------------------------------------------------------------------
-- families — creator bootstrap + family membership (template: per_family_scope variant)
-- ---------------------------------------------------------------------------
create policy families_select_authenticated on public.families for
select to authenticated using (
  created_by = (select auth.uid ())
  or (
    public.is_member_of (id)
    and archived_at is null
  )
);

comment on policy families_select_authenticated on public.families is 'RLS template: per_family_scope (+ creator bootstrap for pre-membership read).';

create policy families_insert_authenticated on public.families for insert to authenticated
with
  check (created_by = (select auth.uid ()));

comment on policy families_insert_authenticated on public.families is 'RLS template: self_insert (created_by must be caller).';

create policy families_update_family_admin on public.families for
update to authenticated using (
  created_by = (select auth.uid ())
  or public.is_owner_of (id)
)
with
  check (
    created_by = (select auth.uid ())
    or public.is_owner_of (id)
  );

comment on policy families_update_family_admin on public.families is 'RLS template: owner_only variant (creator or owner role).';

-- ---------------------------------------------------------------------------
-- memberships
-- ---------------------------------------------------------------------------
create policy memberships_select_family on public.memberships for
select to authenticated using (public.is_member_of (family_id));

comment on policy memberships_select_family on public.memberships is 'RLS template: per_family_scope.';

create policy memberships_insert_self on public.memberships for insert to authenticated
with
  check (user_id = (select auth.uid ()));

comment on policy memberships_insert_self on public.memberships is 'RLS template: self membership insert.';

create policy memberships_update_self on public.memberships for
update to authenticated using (user_id = (select auth.uid ()))
with
  check (user_id = (select auth.uid ()));

comment on policy memberships_update_self on public.memberships is 'RLS template: self row update.';

-- ---------------------------------------------------------------------------
-- family_invitations
-- ---------------------------------------------------------------------------
create policy family_invitations_select_members on public.family_invitations for
select to authenticated using (public.is_member_of (family_id));

comment on policy family_invitations_select_members on public.family_invitations is 'RLS template: per_family_scope.';

create policy family_invitations_select_recipient on public.family_invitations for
select to authenticated using (
  lower(trim(email)) = lower(trim((select auth.jwt () ->> 'email')))
  and revoked_at is null
  and accepted_at is null
  and expires_at > now ()
);

comment on policy family_invitations_select_recipient on public.family_invitations is 'RLS template: invitation_recipient_email (JWT email match).';

create policy family_invitations_insert_member on public.family_invitations for insert to authenticated
with
  check (
    invited_by = (select auth.uid ())
    and public.is_member_of (family_id)
  );

comment on policy family_invitations_insert_member on public.family_invitations is 'RLS template: per_family_scope + inviter check.';

create policy family_invitations_update_inviter on public.family_invitations for
update to authenticated using (invited_by = (select auth.uid ()))
with
  check (invited_by = (select auth.uid ()));

comment on policy family_invitations_update_inviter on public.family_invitations is 'RLS template: inviter owns row updates.';

-- ---------------------------------------------------------------------------
-- capability_matrix_default — global reference
-- ---------------------------------------------------------------------------
create policy capability_matrix_default_select_authenticated on public.capability_matrix_default for
select to authenticated using (true);

comment on policy capability_matrix_default_select_authenticated on public.capability_matrix_default is 'RLS template: global_matrix_read (authenticated, read-only reference).';

-- ---------------------------------------------------------------------------
-- capability_grants
-- ---------------------------------------------------------------------------
create policy capability_grants_select_members on public.capability_grants for
select to authenticated using (public.is_member_of (family_id));

comment on policy capability_grants_select_members on public.capability_grants is 'RLS template: per_family_scope.';

create policy capability_grants_insert_owner on public.capability_grants for insert to authenticated
with
  check (public.is_owner_of (family_id));

comment on policy capability_grants_insert_owner on public.capability_grants is 'RLS template: owner_only.';

create policy capability_grants_update_owner on public.capability_grants for
update to authenticated using (public.is_owner_of (family_id))
with
  check (public.is_owner_of (family_id));

comment on policy capability_grants_update_owner on public.capability_grants is 'RLS template: owner_only.';

-- ---------------------------------------------------------------------------
-- approval_auto_rules (split FOR ALL into explicit commands)
-- ---------------------------------------------------------------------------
create policy approval_auto_rules_select_members on public.approval_auto_rules for
select to authenticated using (public.is_member_of (family_id));

comment on policy approval_auto_rules_select_members on public.approval_auto_rules is 'RLS template: per_family_scope.';

create policy approval_auto_rules_insert_owner on public.approval_auto_rules for insert to authenticated
with
  check (public.is_owner_of (family_id));

comment on policy approval_auto_rules_insert_owner on public.approval_auto_rules is 'RLS template: owner_only.';

create policy approval_auto_rules_update_owner on public.approval_auto_rules for
update to authenticated using (public.is_owner_of (family_id))
with
  check (public.is_owner_of (family_id));

comment on policy approval_auto_rules_update_owner on public.approval_auto_rules is 'RLS template: owner_only.';

create policy approval_auto_rules_delete_owner on public.approval_auto_rules for delete to authenticated using (public.is_owner_of (family_id));

comment on policy approval_auto_rules_delete_owner on public.approval_auto_rules is 'RLS template: owner_only.';

-- ---------------------------------------------------------------------------
-- approval_requests
-- ---------------------------------------------------------------------------
create policy approval_requests_select_members on public.approval_requests for
select to authenticated using (public.is_member_of (family_id));

comment on policy approval_requests_select_members on public.approval_requests is 'RLS template: per_family_scope.';

create policy approval_requests_insert_self on public.approval_requests for insert to authenticated
with
  check (
    requester_profile_id = (select auth.uid ())
    and public.is_member_of (family_id)
  );

comment on policy approval_requests_insert_self on public.approval_requests is 'RLS template: per_family_scope + requester profile.';

create policy approval_requests_update_resolver on public.approval_requests for
update to authenticated using (
  public.has_role (approval_requests.family_id, 'owner'::public.family_role)
  or public.has_role (approval_requests.family_id, 'partner'::public.family_role)
  or requester_profile_id = (select auth.uid ())
)
with
  check (
    exists (
      select
        1
      from
        public.memberships mx
      where
        mx.family_id = approval_requests.family_id
        and mx.removed_at is null
    )
  );

comment on policy approval_requests_update_resolver on public.approval_requests is 'RLS template: per_role_gate (owner/partner) OR requester; WITH CHECK family still exists.';

-- ---------------------------------------------------------------------------
-- Representative table for babysitter_scoped_read (used by pgTAP + docs)
-- ---------------------------------------------------------------------------
create table public.rls_babysitter_scope_demo (
  id uuid primary key default gen_random_uuid (),
  family_id uuid not null references public.families (id) on delete cascade,
  label text not null default '',
  babysitter_readable boolean not null default false
);

comment on table public.rls_babysitter_scope_demo is 'Phase 2.4: RLS template demo only; not a product table.';

alter table public.rls_babysitter_scope_demo enable row level security;

create policy rls_babysitter_scope_demo_select on public.rls_babysitter_scope_demo for
select to authenticated using (
  public.is_member_of (family_id)
  and (
    not public.babysitter_can_read (family_id)
    or babysitter_readable
  )
);

comment on policy rls_babysitter_scope_demo_select on public.rls_babysitter_scope_demo is 'RLS template: babysitter_scoped_read.';

grant select on table public.rls_babysitter_scope_demo to authenticated;
