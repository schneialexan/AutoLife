---
name: phase2.2_family_tenancy_model
overview: Canonical owner of the AutoLife family tenancy model - families, memberships, multi-family membership, and the full invitation lifecycle - establishing the per-family scope every downstream module must respect.
phase: 2.2
gate_owner: Phase 2 Gate
isProject: false
---

# Phase 2.2 - Family Tenancy Model

## Objective
Define and implement the canonical multi-tenant data model that lets a single AutoLife user belong to one or more families, with explicit invitation, acceptance, and removal semantics. This plan owns the `families`, `memberships`, and `family_invitations` tables, their service layer in `autolife-core`, and the shell-level family switcher. Foundational `families` and `memberships` stubs from Phase 1.4 are normalized and finalized here; every later plan that introduces a per-family table references this plan's tenancy column convention rather than redefining it.

## In scope
- `families` table (id, name, created_by, created_at, archived_at, settings JSONB).
- `memberships` table (family_id, user_id, role placeholder, joined_at, removed_at) with composite primary key and partial-unique constraints to allow multi-family users while preventing duplicate active memberships.
- `family_invitations` table (id, family_id, email, invited_role, invited_by, token_hash, expires_at, accepted_at, revoked_at).
- Invitation lifecycle: create, send email, accept, revoke, expire, resend.
- A `TenancyService` in `autolife-core` covering family CRUD, switch-active-family, invite, accept, leave, and member removal.
- Shell screens for create-family, family switcher, and pending invitations.
- The standardized `family_id uuid not null references families(id)` column convention that every later table-introducing plan adopts.

## Out of scope
- Role definitions and capability matrix (owned by [phase2.3_role_policy_model.plan.md](phase2.3_role_policy_model.plan.md); this plan stores role only as a `text` placeholder column the next plan converts to an enum).
- RLS policy templates protecting these tables (owned by [phase2.4_rls_policies.plan.md](phase2.4_rls_policies.plan.md)).
- Sensitivity tiers and babysitter link scoping (owned by [phase2.5_privacy_controls.plan.md](phase2.5_privacy_controls.plan.md)).
- Billing/subscription per family (post-MVP).

## Key deliverables
- `supabase/migrations/20260512000100_family_tenancy.sql` - `families`, `memberships`, and `family_invitations` tables with indexes and constraints.
- `supabase/migrations/20260512000110_family_tenancy_functions.sql` - `accept_invitation(token text)` and `revoke_invitation(invitation_id uuid)` SECURITY DEFINER functions.
- `packages/autolife-core/lib/src/tenancy/tenancy_service.dart`.
- `packages/autolife-core/lib/src/tenancy/models/family.dart`, `membership.dart`, `family_invitation.dart`.
- `packages/autolife-core/test/tenancy/tenancy_service_test.dart`.
- `apps/autolife-shell/lib/src/screens/onboarding/create_family_screen.dart`.
- `apps/autolife-shell/lib/src/screens/family/family_switcher_screen.dart`.
- `apps/autolife-shell/lib/src/screens/family/invitations_screen.dart`.
- `apps/autolife-shell/lib/src/providers/tenancy_provider.dart`.
- `supabase/functions/send-invitation/index.ts` - edge function that emails the tokenized accept link.
- `docs/tenancy.md` - column convention every later plan must adopt.

## Dependencies
- [phase1.2_autolife_core_contracts.plan.md](phase1.2_autolife_core_contracts.plan.md) - core service-interface conventions.
- [phase1.4_supabase_baseline.plan.md](phase1.4_supabase_baseline.plan.md) - initial `families`/`memberships` stubs and Supabase project setup.
- [phase2.1_auth_flows.plan.md](phase2.1_auth_flows.plan.md) - authenticated user context required to call tenancy APIs.

## Acceptance criteria (gate)
- [ ] Migrations apply cleanly on a fresh database and on top of the Phase 1.4 stubs without data loss (verified by `supabase db reset`).
- [ ] A signed-in user can create a family, becomes its first member, and lands on the family dashboard.
- [ ] An invited email completes acceptance with a tokenized link, producing a new active membership in the target family.
- [ ] Invitations expire after the configured window, can be revoked by the inviter, and revoked tokens fail acceptance with a typed error.
- [ ] A single user can hold active memberships in two or more families simultaneously and switch between them from the family switcher.
- [ ] Leaving a family soft-deletes the membership (`removed_at` set) and the user can no longer query that family's data.
- [ ] `TenancyService` unit tests pass with at least 80% line coverage of `packages/autolife-core/lib/src/tenancy/`.
- [ ] `docs/tenancy.md` documents the `family_id` column convention and is linked from the meta-plan.

## Risks + mitigations
- **Risk**: Schema churn breaks the Phase 1.4 stubs and forces destructive migrations downstream. **Mitigation**: Treat the Phase 1.4 tables as `IF NOT EXISTS` stubs, write additive `ALTER` migrations only, and add a CI check that diffs the schema against the documented contract.
- **Risk**: Invitation tokens leak via email or URL logging. **Mitigation**: Store only `token_hash`, sign tokens with HMAC, expire within 7 days by default, and rate-limit acceptance attempts inside the edge function.
- **Risk**: Multi-family users are confused about which family context is active, leading to cross-family data leaks. **Mitigation**: Persist `active_family_id` in a single source of truth, surface it in the app header, and refuse any tenancy-scoped write that does not match the active family.

## Implementation outline
1. Audit the Phase 1.4 family/membership stubs and capture the diff needed to reach the canonical schema.
2. Author migration `20260512000100_family_tenancy.sql` with full table definitions, indexes, and FK constraints.
3. Author migration `20260512000110_family_tenancy_functions.sql` adding the SECURITY DEFINER acceptance/revocation helpers.
4. Define Dart models and the `TenancyService` interface in `packages/autolife-core`.
5. Implement the Supabase-backed `TenancyService`, including the active-family persistence contract.
6. Build the edge function `supabase/functions/send-invitation` to email tokenized invitation links via the configured provider.
7. Build shell screens for create-family, family switcher, and pending invitations.
8. Write unit tests for the service and an integration test for the full invite-accept loop against the local Supabase stack.
9. Update `docs/tenancy.md` with the canonical `family_id` column convention and link it from the meta-plan.
10. Coordinate with the Phase 2.4 plan owner to ensure RLS policies layered on these tables match the convention.

## Artifacts/links
- PR: (tbd)
- Migrations: `supabase/migrations/20260512000100_family_tenancy.sql`, `..._functions.sql` (tbd)
- Tenancy docs: `docs/tenancy.md` (tbd)
- Edge function: `supabase/functions/send-invitation/` (tbd)
