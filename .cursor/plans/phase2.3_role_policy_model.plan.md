---
name: phase2.3_role_policy_model
overview: Canonical owner of the AutoLife role enum, capability/policy matrix, approval-engine state machine, and chore-enforcement toggles, codifying the Idea-Refined Part 5.1 permissions model in schema and shared code.
phase: 2.3
gate_owner: Phase 2 Gate
isProject: false
---

# Phase 2.3 - Role + Policy Model

## Objective
Codify the AutoLife role system - owner, partner, child, teenager, grandparent, guest, babysitter - as a typed enum at the database level, a capability/policy matrix usable from any module, and an approval-engine state machine that enforces the manual-vs-auto-approve and chore-enforcement toggles described in Idea-Refined Part 5.1. Every later module that gates an action on "who is the user" calls into this plan's matrix rather than hard-coding role checks.

Idea-Refined Part 5.1 anchors this model:
> "Custom Roles: Templates for Co-Parent, Teenager, Young Child, Grandparent, Guest/Babysitter, Child."
> "RSVP & Approval Engine: Strictness toggles ('Child accounts require Parent approval to add calendar events.'), Auto-Approve rules ('Auto-approve teen's events if the location is set to "School".'), Turn off if not necessary."
> "Chore Enforcement: Toggle if a kid's chore requires a 'Photo Proof' upload or Parent 'Verification' before granting allowance."

## In scope
- A `family_role` Postgres enum (`owner`, `partner`, `child`, `teenager`, `grandparent`, `guest`, `babysitter`) installed at the database level and replacing the placeholder column from Phase 2.2.
- A capability/policy matrix expressed as both a Dart constant and a SQL seed so client and server agree on truth.
- The approval-engine state machine (`pending -> approved | rejected | expired | auto_approved`) with rules per role and per capability.
- Chore-enforcement toggles (`require_photo_proof`, `require_parent_verification`) wired into the matrix.
- A `RolePolicyService` and `ApprovalEngine` in `autolife-core`.
- Settings UI in `autolife-shell` exposing the toggles to family owners.

## Out of scope
- The tenancy tables themselves (owned by [phase2.2_family_tenancy_model.plan.md](phase2.2_family_tenancy_model.plan.md)).
- The RLS policies that consume this enum (owned by [phase2.4_rls_policies.plan.md](phase2.4_rls_policies.plan.md)).
- Biometric module locks and data-tier definitions (owned by [phase2.5_privacy_controls.plan.md](phase2.5_privacy_controls.plan.md)).
- Specific approval flows for each module (each Phase 3 app plan wires its own actions into the approval engine).

## Key deliverables
- `supabase/migrations/20260512000200_role_enum.sql` - install the `family_role` enum and convert `memberships.role` from text to enum.
- `supabase/migrations/20260512000210_capability_matrix.sql` - `capability_grants` table plus a seed function loading the default matrix.
- `supabase/migrations/20260512000220_approval_engine.sql` - `approval_requests` table and `enforce_capability(family_id uuid, user_id uuid, capability text)` SQL helper.
- `packages/autolife-core/lib/src/policy/role.dart` - Dart `Role` enum mirroring the SQL enum.
- `packages/autolife-core/lib/src/policy/capability.dart` - `Capability` enum and default matrix constant.
- `packages/autolife-core/lib/src/policy/role_policy_service.dart`.
- `packages/autolife-core/lib/src/policy/approval_engine.dart` - state-machine implementation.
- `packages/autolife-core/policy/matrix.yaml` - single source of truth for generated Dart + SQL outputs.
- `packages/autolife-core/test/policy/role_policy_service_test.dart`, `approval_engine_test.dart`.
- `apps/autolife-shell/lib/src/screens/control_center/role_matrix_screen.dart`.
- `apps/autolife-shell/lib/src/screens/control_center/approval_engine_screen.dart`.
- `docs/role-policy.md` - source-of-truth matrix and Idea-Refined Part 5.1 mapping.

## Dependencies
- [phase1.2_autolife_core_contracts.plan.md](phase1.2_autolife_core_contracts.plan.md) - shared enum and service patterns.
- [phase1.5_event_bus_process_event_worker.plan.md](phase1.5_event_bus_process_event_worker.plan.md) - bus where approval events publish.
- [phase2.2_family_tenancy_model.plan.md](phase2.2_family_tenancy_model.plan.md) - the `memberships` table whose `role` column this plan upgrades.

## Acceptance criteria (gate)
- [ ] The `family_role` Postgres enum is installed and `memberships.role` is migrated from text to the enum without data loss.
- [ ] The capability matrix in Dart (`Capability` constant) and SQL (`capability_grants` seed) match byte-for-byte, verified by a generated comparison test in CI.
- [ ] The approval engine state machine enforces the four documented transitions, rejects illegal transitions with a typed error, and emits `approval.requested` / `approval.resolved` events on the Phase 1.5 bus.
- [ ] Auto-approve rules (for example, teen events at location `School`) bypass manual approval and write an `auto_approved` row with the matching rule id.
- [ ] Chore-enforcement toggles `require_photo_proof` and `require_parent_verification` are read by a sample task-module call and block completion when unmet.
- [ ] The control-center role-matrix screen lets owners view and toggle capability assignments per role, persisted to `capability_grants`.
- [ ] `RolePolicyService` and `ApprovalEngine` unit tests reach at least 85% line coverage across `packages/autolife-core/lib/src/policy/`.
- [ ] `docs/role-policy.md` cites Idea-Refined Part 5.1 inline and the table of capabilities matches the seeded SQL.

## Risks + mitigations
- **Risk**: Dart and SQL matrices drift, producing client-side allow / server-side deny bugs. **Mitigation**: Generate both from the single YAML source at `packages/autolife-core/policy/matrix.yaml`, add a CI step that fails when generated outputs are stale.
- **Risk**: The approval-engine accumulates orphaned `pending` rows. **Mitigation**: Add an `expires_at` column with a default of 72 hours, a nightly cron edge function to expire stale rows, and metrics on pending-queue depth.
- **Risk**: Role enum changes later require destructive migrations. **Mitigation**: Use `alter type ... add value` migrations only, never reorder, and centralize the Dart enum so renames are caught at compile time.

## Implementation outline
1. Extract the Idea-Refined Part 5.1 narrative into a YAML matrix at `packages/autolife-core/policy/matrix.yaml` (roles x capabilities x default grant + approval rule).
2. Write a code-gen script that emits the SQL seed and Dart constants from the YAML and wire it into Melos.
3. Author migration `20260512000200_role_enum.sql` to install the enum and migrate the placeholder column.
4. Author migrations for the `capability_grants` table and `approval_requests` table plus the `enforce_capability` helper.
5. Implement `RolePolicyService` and `ApprovalEngine` in `autolife-core` with explicit state-machine transitions and event emission.
6. Build the control-center screens to visualize and edit grants and approval rules.
7. Write unit tests for the service, the state machine, and the YAML-to-output generator.
8. Add an integration test that runs an end-to-end "child creates event -> approval requested -> owner approves" loop against the local Supabase stack.
9. Document the matrix in `docs/role-policy.md` with the Idea-Refined Part 5.1 quote and per-role examples.
10. Coordinate with Phase 2.4 to wire the enum into the per-role-gate RLS template.

## Artifacts/links
- PR: (tbd)
- Migrations: `supabase/migrations/20260512000200_role_enum.sql`, `..._capability_matrix.sql`, `..._approval_engine.sql` (tbd)
- Policy docs: `docs/role-policy.md` (tbd)
- Matrix source: `packages/autolife-core/policy/matrix.yaml` (tbd)
