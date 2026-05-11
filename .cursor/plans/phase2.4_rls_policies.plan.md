---
name: phase2.4_rls_policies
overview: Canonical owner of the AutoLife RLS template library, the pgTAP-driven supabase test db harness, and a policy-drift detector, so every later table-introducing plan reuses the same four reusable policy templates instead of writing one-off rules.
phase: 2.4
gate_owner: Phase 2 Gate
isProject: false
---

# Phase 2.4 - RLS Policies

## Objective
Establish the canonical set of Row-Level Security templates - `per-family scope`, `per-role gate`, `owner-only`, and `babysitter-scoped read` - that every later table-introducing plan reuses. Ship a pgTAP-driven test harness driven by `supabase test db` that exercises each template against representative tables, plus a policy-drift detector that fails CI when a new table is added without a matching policy. From this plan onward, no plan introduces RLS by hand: it references one of the four templates by name.

## In scope
- A library of four reusable policy templates expressed as `CREATE POLICY` SQL fragments parameterized by table name and tenancy column.
- Application of the templates to the Phase 2.2 tables (`families`, `memberships`, `family_invitations`) and the Phase 2.3 tables (`capability_grants`, `approval_requests`).
- A pgTAP test harness driven by `supabase test db` that runs role-by-role allow/deny assertions per template.
- A policy-drift detector script that inspects the live schema against the documented policy registry and exits non-zero when a table is missing a policy or has an undocumented one.
- A `docs/rls-templates.md` reference page documenting each template's intent, SQL shape, and required columns.

## Out of scope
- Adding new business tables (each later plan owns its own table and references this library).
- Application-layer authorization (handled by [phase2.3_role_policy_model.plan.md](phase2.3_role_policy_model.plan.md)).
- Biometric / data-tier locking (owned by [phase2.5_privacy_controls.plan.md](phase2.5_privacy_controls.plan.md)).
- Pen-test execution (owned by [phase2.6_security_verification_hardening.plan.md](phase2.6_security_verification_hardening.plan.md)).

## Key deliverables
- `supabase/migrations/20260512000300_rls_helpers.sql` - shared SQL helpers (`is_member_of(family_id)`, `has_role(family_id, role)`, `is_owner_of(family_id)`, `babysitter_can_read(resource_id)`) underpinning every template.
- `supabase/policies/per_family_scope.sql.tpl`, `per_role_gate.sql.tpl`, `owner_only.sql.tpl`, `babysitter_scoped_read.sql.tpl` - parameterized template files.
- `supabase/migrations/20260512000310_apply_rls_phase2.sql` - applies the templates to the Phase 2.2 and 2.3 tables.
- `supabase/tests/rls/per_family_scope_test.sql`, `per_role_gate_test.sql`, `owner_only_test.sql`, `babysitter_scoped_read_test.sql` - pgTAP test files.
- `supabase/tests/fixtures/users_and_families.sql` - deterministic seed for tests.
- `scripts/policy_drift_check.dart` - drift detector run in CI.
- `.github/workflows/rls-tests.yml` - workflow running `supabase test db` and the drift detector on every PR.
- `docs/rls-templates.md` - template reference and adoption guide for later plans.

## Dependencies
- [phase1.4_supabase_baseline.plan.md](phase1.4_supabase_baseline.plan.md) - Supabase project and migration pipeline.
- [phase2.2_family_tenancy_model.plan.md](phase2.2_family_tenancy_model.plan.md) - tables that anchor the `is_member_of` helper.
- [phase2.3_role_policy_model.plan.md](phase2.3_role_policy_model.plan.md) - `family_role` enum used by the per-role-gate template.

## Acceptance criteria (gate)
- [ ] All four template SQL files exist, are documented in `docs/rls-templates.md`, and are applied to every Phase 2 table.
- [ ] `supabase test db` runs the pgTAP suite green in CI and locally on a fresh stack.
- [ ] pgTAP assertions reach at least 95% statement coverage of the `supabase/policies/*.tpl` helpers and the `supabase/migrations/20260512000300_rls_helpers.sql` functions, measured via `pg_prove --coverage` or equivalent, and the threshold is enforced in CI.
- [ ] Each template has at least one allow test and one deny test per role applicable to it (no role omitted).
- [ ] Application-layer integration tests cover at least 80% of the public `TenancyService` and `RolePolicyService` paths that round-trip through RLS.
- [ ] The drift detector exits non-zero when a table without a policy is introduced into a test schema and exits zero on the current canonical schema.
- [ ] Running the drift detector against the live Phase 2.2 + 2.3 schema produces a clean report.
- [ ] CI fails when `supabase test db` is skipped, when coverage drops below the documented threshold, or when a new migration adds a table without a matching policy entry in the registry.

## Risks + mitigations
- **Risk**: pgTAP / `supabase test db` matrix is flaky on Windows runners or local environments, eroding trust in the harness. **Mitigation**: Pin the Supabase CLI version, run tests inside the official Docker image both locally and in CI, and add a preflight smoke step that exits early with a clear error if the runtime is misconfigured.
- **Risk**: Templates accumulate edge-case overrides until they no longer feel templated, leading every plan to write bespoke policies anyway. **Mitigation**: Treat the four templates as a closed set; require an ADR before adding a fifth; reject migrations whose policies do not reference a template name in a SQL comment.
- **Risk**: Policy-drift detector produces false positives that get silenced over time. **Mitigation**: Make the detector output machine-readable JSON, require any suppression to live in a tracked `rls_drift_allowlist.yaml`, and add a periodic CI job that fails when allowlist entries age past 30 days.

## Implementation outline
1. Author the helper SQL functions (`is_member_of`, `has_role`, `is_owner_of`, `babysitter_can_read`) and their unit tests.
2. Write the four template SQL files with placeholders for table name and tenancy column.
3. Apply the templates to Phase 2.2 and 2.3 tables via `20260512000310_apply_rls_phase2.sql`.
4. Build the pgTAP fixtures (users, families, memberships across all roles) and one test file per template.
5. Configure `supabase test db` to discover tests in `supabase/tests/rls/` and report coverage via `pg_prove --coverage`.
6. Implement `scripts/policy_drift_check.dart` consuming `information_schema` / `pg_policies` and the policy registry.
7. Wire `.github/workflows/rls-tests.yml` to run the pgTAP suite, the drift detector, and the coverage gate on every PR.
8. Write `docs/rls-templates.md` with template-by-template usage instructions and a snippet other plans copy in.
9. Cross-link the doc from the meta-plan and update any earlier Phase 2 plan that introduced tables to reference a template by name.
10. Walk through an "adopt a template" exercise on a single Phase 3 table to validate the developer experience before locking the gate.

## Artifacts/links
- PR: (tbd)
- Migrations: `supabase/migrations/20260512000300_rls_helpers.sql`, `..._apply_rls_phase2.sql` (tbd)
- Test suite: `supabase/tests/rls/` (tbd)
- Drift report: `scripts/policy_drift_check.dart` output sample (tbd)
- Template guide: `docs/rls-templates.md` (tbd)
