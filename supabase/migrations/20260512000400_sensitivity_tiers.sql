-- Phase 2.5: canonical sensitivity tiers + column→tier registry (Idea-Refined Part 5.2).

create type public.sensitivity_tier as enum (
  'public_family',
  'private_member',
  'health_locked',
  'finance_locked'
);

comment on type public.sensitivity_tier is 'Closed-set data sensitivity; ADR required for a fifth label.';

create table public.sensitivity_assignments (
  table_schema text not null default 'public',
  table_name text not null,
  column_name text not null,
  tier public.sensitivity_tier not null,
  updated_at timestamptz not null default now (),
  primary key (table_schema, table_name, column_name),
  constraint sensitivity_assignments_table_schema_chk check (table_schema = 'public')
);

comment on table public.sensitivity_assignments is 'Maps physical columns to canonical sensitivity tiers; see docs/privacy-tiers.md.';

alter table public.sensitivity_assignments enable row level security;

create policy sensitivity_assignments_select_authenticated on public.sensitivity_assignments for
select to authenticated using (true);

comment on policy sensitivity_assignments_select_authenticated on public.sensitivity_assignments is 'Global read reference; writes only via migrations/service role.';

grant select on table public.sensitivity_assignments to authenticated;

-- Phase 2.2 + 2.3 columns — default tier public_family (owners may tighten later per ADR).
insert into public.sensitivity_assignments (table_schema, table_name, column_name, tier)
values
  ('public', 'families', 'id', 'public_family'),
  ('public', 'families', 'name', 'public_family'),
  ('public', 'families', 'created_by', 'public_family'),
  ('public', 'families', 'created_at', 'public_family'),
  ('public', 'families', 'archived_at', 'public_family'),
  ('public', 'families', 'settings', 'public_family'),
  ('public', 'memberships', 'family_id', 'public_family'),
  ('public', 'memberships', 'user_id', 'public_family'),
  ('public', 'memberships', 'role', 'public_family'),
  ('public', 'memberships', 'joined_at', 'public_family'),
  ('public', 'memberships', 'removed_at', 'public_family'),
  ('public', 'memberships', 'updated_at', 'public_family'),
  ('public', 'family_invitations', 'id', 'public_family'),
  ('public', 'family_invitations', 'family_id', 'public_family'),
  ('public', 'family_invitations', 'email', 'public_family'),
  ('public', 'family_invitations', 'invited_role', 'public_family'),
  ('public', 'family_invitations', 'invited_by', 'public_family'),
  ('public', 'family_invitations', 'token_hash', 'public_family'),
  ('public', 'family_invitations', 'expires_at', 'public_family'),
  ('public', 'family_invitations', 'accepted_at', 'public_family'),
  ('public', 'family_invitations', 'revoked_at', 'public_family'),
  ('public', 'family_invitations', 'created_at', 'public_family'),
  ('public', 'family_invitations', 'updated_at', 'public_family'),
  ('public', 'profile', 'id', 'public_family'),
  ('public', 'profile', 'display_name', 'public_family'),
  ('public', 'profile', 'active_family_id', 'public_family'),
  ('public', 'capability_matrix_default', 'role', 'public_family'),
  ('public', 'capability_matrix_default', 'capability', 'public_family'),
  ('public', 'capability_matrix_default', 'granted', 'public_family'),
  ('public', 'capability_matrix_default', 'requires_parent_approval', 'public_family'),
  ('public', 'capability_matrix_default', 'require_photo_proof', 'public_family'),
  ('public', 'capability_matrix_default', 'require_parent_verification', 'public_family'),
  ('public', 'capability_matrix_default', 'updated_at', 'public_family'),
  ('public', 'capability_grants', 'family_id', 'public_family'),
  ('public', 'capability_grants', 'role', 'public_family'),
  ('public', 'capability_grants', 'capability', 'public_family'),
  ('public', 'capability_grants', 'granted', 'public_family'),
  ('public', 'capability_grants', 'requires_parent_approval', 'public_family'),
  ('public', 'capability_grants', 'require_photo_proof', 'public_family'),
  ('public', 'capability_grants', 'require_parent_verification', 'public_family'),
  ('public', 'capability_grants', 'updated_at', 'public_family'),
  ('public', 'approval_auto_rules', 'id', 'public_family'),
  ('public', 'approval_auto_rules', 'family_id', 'public_family'),
  ('public', 'approval_auto_rules', 'role', 'public_family'),
  ('public', 'approval_auto_rules', 'capability', 'public_family'),
  ('public', 'approval_auto_rules', 'label', 'public_family'),
  ('public', 'approval_auto_rules', 'enabled', 'public_family'),
  ('public', 'approval_auto_rules', 'match', 'public_family'),
  ('public', 'approval_auto_rules', 'created_at', 'public_family'),
  ('public', 'approval_auto_rules', 'updated_at', 'public_family'),
  ('public', 'approval_requests', 'id', 'public_family'),
  ('public', 'approval_requests', 'family_id', 'public_family'),
  ('public', 'approval_requests', 'requester_profile_id', 'public_family'),
  ('public', 'approval_requests', 'capability', 'public_family'),
  ('public', 'approval_requests', 'payload', 'public_family'),
  ('public', 'approval_requests', 'status', 'public_family'),
  ('public', 'approval_requests', 'resolver_profile_id', 'public_family'),
  ('public', 'approval_requests', 'applied_auto_rule_id', 'public_family'),
  ('public', 'approval_requests', 'expires_at', 'public_family'),
  ('public', 'approval_requests', 'resolved_at', 'public_family'),
  ('public', 'approval_requests', 'created_at', 'public_family'),
  ('public', 'approval_requests', 'updated_at', 'public_family')
on conflict (table_schema, table_name, column_name) do update set
  tier = excluded.tier,
  updated_at = now();
