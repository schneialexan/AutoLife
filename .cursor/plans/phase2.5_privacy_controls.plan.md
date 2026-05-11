---
name: phase2.5_privacy_controls
overview: Canonical owner of AutoLife sensitive-data tiers, the biometric app-lock contract via local_auth, and babysitter link-scoping toggles, implementing the privacy-and-guest-configuration model from Idea-Refined Part 5.2.
phase: 2.5
gate_owner: Phase 2 Gate
isProject: false
---

# Phase 2.5 - Privacy Controls

## Objective
Make AutoLife trustworthy with sensitive household data by codifying four canonical sensitivity tiers - `public_family`, `private_member`, `health_locked`, `finance_locked` - along with a biometric app-lock contract (powered by the `local_auth` Flutter package) and a babysitter link-scoping system that lets owners toggle exactly what a temporary guest can see, per Idea-Refined Part 5.2. From this plan onward, any module that surfaces sensitive content declares its tier, and biometric and babysitter rules apply automatically.

## In scope
- A `sensitivity_tier` Postgres enum (`public_family`, `private_member`, `health_locked`, `finance_locked`) plus a `sensitivity_assignments` table mapping (table_name, column_name) -> tier.
- A `BiometricLockService` in `autolife-core` wrapping `local_auth` with platform fallbacks and a typed contract any module imports to gate a screen.
- A `BabysitterLinkService` and `babysitter_links` table holding tokenized, time-limited, capability-scoped read-only links with per-link toggles (WiFi credentials, emergency contacts, allergies, locations, etc., per Idea-Refined Part 5.2).
- A `babysitter_scope(token text)` SQL function returning the set of resources a given token may read, consumed by the `babysitter-scoped read` RLS template from Phase 2.4.
- Shell screens for biometric lock setup, per-module lock toggles, and babysitter link generation.

## Out of scope
- The RLS template that enforces babysitter scope (owned by [phase2.4_rls_policies.plan.md](phase2.4_rls_policies.plan.md); this plan supplies the helper function and link table the template consumes).
- Pen-test execution for the privacy surface (owned by [phase2.6_security_verification_hardening.plan.md](phase2.6_security_verification_hardening.plan.md)).
- Per-module application of biometric locks beyond a single reference module (each Phase 3 app plan opts its sensitive screens in).
- Sharing models for other guests beyond babysitter (post-MVP).

## Key deliverables
- `supabase/migrations/20260512000400_sensitivity_tiers.sql` - install the enum and `sensitivity_assignments` table; seed Phase 2.2 + 2.3 columns with `public_family` defaults.
- `supabase/migrations/20260512000410_babysitter_links.sql` - `babysitter_links` table and `babysitter_scope(token text)` SQL function.
- `packages/autolife-core/lib/src/privacy/sensitivity_tier.dart`, `biometric_lock_service.dart`, `babysitter_link_service.dart`.
- `packages/autolife-core/lib/src/privacy/models/babysitter_link.dart`, `babysitter_scope_toggles.dart`.
- `packages/autolife-core/test/privacy/biometric_lock_service_test.dart`, `babysitter_link_service_test.dart`.
- `apps/autolife-shell/lib/src/screens/control_center/biometric_locks_screen.dart`.
- `apps/autolife-shell/lib/src/screens/control_center/babysitter_link_screen.dart`.
- `apps/autolife-shell/lib/src/widgets/biometric_gate.dart` - reusable widget any module wraps around a sensitive screen.
- `apps/autolife-shell/android/app/src/main/AndroidManifest.xml` - add `USE_BIOMETRIC` permission entries.
- `apps/autolife-shell/ios/Runner/Info.plist` - add `NSFaceIDUsageDescription`.
- `docs/privacy-tiers.md` - tier definitions, biometric contract, and babysitter scope semantics.

## Dependencies
- [phase1.3_autolife_ui_design_system.plan.md](phase1.3_autolife_ui_design_system.plan.md) - design tokens used by lock-prompt screens.
- [phase2.2_family_tenancy_model.plan.md](phase2.2_family_tenancy_model.plan.md) - the `family_id` scoping every babysitter link inherits.
- [phase2.3_role_policy_model.plan.md](phase2.3_role_policy_model.plan.md) - the `babysitter` role and its capability matrix.
- [phase2.4_rls_policies.plan.md](phase2.4_rls_policies.plan.md) - the `babysitter-scoped read` template that consumes the `babysitter_scope` helper.

## Acceptance criteria (gate)
- [ ] The `sensitivity_tier` enum and `sensitivity_assignments` table are installed and seeded for every column introduced in Phases 2.2 and 2.3.
- [ ] `BiometricLockService.lock(moduleId)` succeeds on Android (BiometricPrompt) and iOS (Face/Touch ID); failed authentication blocks the gated screen and emits a `privacy.lock_failed` event.
- [ ] A user can generate a babysitter link with explicit toggles, share it, and a recipient using the token sees exactly the toggled-on resources and nothing else.
- [ ] Babysitter links honor `expires_at` and `revoked_at` and produce typed errors when expired or revoked.
- [ ] The `babysitter_scope(token)` SQL helper returns the correct resource set for every documented toggle combination, verified by pgTAP cases under Phase 2.4's harness.
- [ ] Toggling a module's biometric lock from the control center persists across app restarts and applies on next launch.
- [ ] `BiometricLockService` and `BabysitterLinkService` unit tests reach at least 80% line coverage of `packages/autolife-core/lib/src/privacy/`.
- [ ] `docs/privacy-tiers.md` documents each tier with one concrete example per tier and is cited by at least one Phase 3 app plan stub.

## Risks + mitigations
- **Risk**: `local_auth` behavior diverges across OS versions and device capabilities, locking users out. **Mitigation**: Implement a typed fallback chain (biometric -> device passcode -> app PIN), expose a clear recovery flow in `biometric_locks_screen.dart`, and add device-matrix tests for the top supported OS versions.
- **Risk**: Babysitter link tokens are shared more broadly than intended and leak family data. **Mitigation**: Default expiry to 24 hours, store only token hashes, log every access with IP and user-agent for owner review, and offer an in-app "revoke now" with one tap.
- **Risk**: Sensitivity tiers proliferate informally and the model becomes meaningless. **Mitigation**: Treat the four tiers as a closed set, require an ADR to add a fifth, and add a CI lint that rejects migrations introducing tier names outside the enum.

## Implementation outline
1. Author migration `20260512000400_sensitivity_tiers.sql` with the enum, the assignment table, and seeded assignments for existing columns.
2. Author migration `20260512000410_babysitter_links.sql` with the link table and `babysitter_scope(token text)` SQL function.
3. Implement `BiometricLockService` in `autolife-core` wrapping `local_auth` with platform-specific fallbacks and a stable interface.
4. Implement `BabysitterLinkService` covering create, list, revoke, and accept (token introspection) operations.
5. Build the control-center screens for biometric locks and babysitter link generation, plus the reusable `BiometricGate` widget.
6. Wire one reference module (for example a placeholder Health stub) behind `BiometricGate` to prove the end-to-end contract.
7. Write unit tests for both services plus pgTAP cases for `babysitter_scope` covering every toggle combination.
8. Add an integration test that creates a babysitter link, opens it as an anonymous client, and asserts the visible resource set matches the toggles.
9. Document tiers, the biometric contract, and the babysitter scope in `docs/privacy-tiers.md` with worked examples.
10. Coordinate with Phase 2.4 to confirm the `babysitter-scoped read` RLS template uses the helper introduced here.

## Artifacts/links
- PR: (tbd)
- Migrations: `supabase/migrations/20260512000400_sensitivity_tiers.sql`, `..._babysitter_links.sql` (tbd)
- Privacy docs: `docs/privacy-tiers.md` (tbd)
- Reference module wiring: `apps/autolife-shell/lib/src/widgets/biometric_gate.dart` (tbd)
