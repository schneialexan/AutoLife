---
name: phase3.13_control_center_settings
overview: Build the Control Center settings surface inside autolife-shell covering role and approval matrix, privacy and guest configuration, AI leash, notification batching, UI density, integration manager, and Download My Life encrypted export.
phase: 3.13
gate_owner: Full App Gate
isProject: false
---

# Phase 3.13 - Control Center + Settings Engine

## Objective
Deliver the family's master control surface inside `apps/autolife-shell` so the platform behaviors defined across the rest of the system (roles, privacy, automation, notifications, UI, integrations, backup) are configurable from one place. This phase does not redefine any primitive: it composes the role matrix from phase 2.3, the privacy tiers from phase 2.5, the integration lifecycle from phase 1.7, and the event/automation hooks from phase 1.5 into a unified settings UI that respects RLS and produces auditable changes.

## Settings surfaces
- **Permissions and Role Matrix**: per-tenant role templates, approval-engine toggles (strictness, auto-approve rules), chore enforcement (photo proof / parent verification).
- **Privacy and Guest Configuration**: per-module sharing toggles (cycle/health phase-only, finance owner-only), biometric app-lock per module, granular babysitter link generator with TTL and per-capability toggles.
- **Automation and AI Leash**: Manual / Suggest / Autonomous slider per family with per-module override; smart-switching rules (e.g., grocery threshold automation toggle).
- **Notification Tuning**: Nag mode calibration (Quiet vs Aggressive), notification batching window, per-module channel toggles.
- **UI and Accessibility**: dashboard density (Command Center vs Kids Mode) with profile-aware default; color override rules (member vs category color); text scaling; haptics.
- **Integration Manager**: per-connector status, OAuth tokens, one-way/two-way sync toggles, offline conflict resolution policy.
- **Data Backup**: "Download My Life" encrypted zip export with a passphrase and resumable download.

## In scope
- Hierarchical settings UI mounted at `apps/autolife-shell/lib/src/screens/settings/` with a search-friendly layout.
- Per-tenant settings storage backed by a single `family_settings` row with JSONB payload and migration helpers.
- Role matrix editor that reuses the phase 2.3 primitive (no duplicate models).
- Privacy + guest link generator that reuses the phase 2.5 primitive.
- AI leash slider that writes a single `ai_leash_level` value consumed by `auto-mail` and other AI features.
- Notification batching settings consumed by the shell push pipeline.
- Integration Manager that lists connectors from the phase 1.7 registry and exposes lifecycle actions.
- "Download My Life" job: encrypted zip export of all tenant-owned data across modules.

## Out of scope
- Standalone app or icon -- Control Center lives inside `autolife-shell`.
- Tenant billing / subscription management (deferred).
- Marketplace / plugin discovery beyond the registered connectors.
- Translating settings labels into more than the launch languages.

## Key deliverables
- `apps/autolife-shell/lib/src/screens/settings/settings_root_screen.dart`.
- `apps/autolife-shell/lib/src/screens/settings/permissions/{role_matrix_screen,approval_rules_screen,chore_enforcement_screen}.dart`.
- `apps/autolife-shell/lib/src/screens/settings/privacy/{privacy_overview_screen,babysitter_link_screen,biometric_locks_screen}.dart`.
- `apps/autolife-shell/lib/src/screens/settings/automation/{ai_leash_screen,smart_switches_screen}.dart`.
- `apps/autolife-shell/lib/src/screens/settings/notifications/{nag_mode_screen,batching_screen,channels_screen}.dart`.
- `apps/autolife-shell/lib/src/screens/settings/ui/{density_screen,color_override_screen,accessibility_screen}.dart`.
- `apps/autolife-shell/lib/src/screens/settings/integrations/{integration_list_screen,connector_detail_screen}.dart`.
- `apps/autolife-shell/lib/src/screens/settings/backup/download_my_life_screen.dart`.
- `apps/autolife-shell/lib/src/services/{settings_service,settings_audit_logger,export_job_client}.dart`.
- `packages/autolife-core/lib/src/models/settings/{family_settings,ai_leash_level,notification_policy,density_preset,integration_status}.dart`.
- `packages/autolife-core/lib/src/events/settings_events.dart` (`settings.changed`, `consent.changed`, `export.requested`, `export.completed`).
- `supabase/migrations/20261001_family_settings.sql` (single JSONB-backed table with strict per-tenant RLS).
- `supabase/migrations/20261001_export_jobs.sql` (job tracking, links to Storage artifact).
- `supabase/functions/export-my-life/index.ts` (long-running export: gathers data per module, zips, encrypts with user passphrase, writes to Storage with TTL).

## Dependencies
- Phase 1.2 contracts: `.cursor/plans/phase1.2_autolife_core_contracts.plan.md`.
- Phase 1.3 design system: `.cursor/plans/phase1.3_autolife_ui_design_system.plan.md`.
- Phase 1.4 Supabase baseline: `.cursor/plans/phase1.4_supabase_baseline.plan.md`.
- Phase 1.5 event bus (settings.changed propagation): `.cursor/plans/phase1.5_event_bus_process_event_worker.plan.md`.
- Phase 1.6 offline foundation (offline conflict resolution policy is configured here): `.cursor/plans/phase1.6_offline_sync_foundation.plan.md`.
- Phase 1.7 integration gateway (Integration Manager lists this registry): `.cursor/plans/phase1.7_integration_gateway_scaffold.plan.md`.
- Phase 2.2 tenancy: `.cursor/plans/phase2.2_family_tenancy_model.plan.md`.
- Phase 2.3 role policy: `.cursor/plans/phase2.3_role_policy_model.plan.md` (canonical role matrix).
- Phase 2.4 RLS: `.cursor/plans/phase2.4_rls_policies.plan.md`.
- Phase 2.5 privacy controls: `.cursor/plans/phase2.5_privacy_controls.plan.md` (canonical privacy tiers, biometric, babysitter scoping).
- Phase 3.1 `autolife-shell`: `.cursor/plans/phase3.1_autolife_shell_dashboard.plan.md` (host app).
- Phase 3.5 `auto-dine`, 3.6 `auto-health`, 3.7 `auto-finance`, 3.8 `auto-gallery`, 3.9 `auto-mail`, 3.10 `auto-pets`, 3.11 `auto-maintain`, 3.12 `auto-locate`: all consume settings written here.

## Acceptance criteria (gate)
- [ ] Settings UI is reachable from the shell's settings tab and shows seven top-level sections (Permissions, Privacy, Automation, Notifications, UI, Integrations, Backup).
- [ ] Updating the Role Matrix in this screen results in identical role evaluation behavior as updating it directly in the phase 2.3 primitive (no duplicate source of truth).
- [ ] Granting a babysitter link with specific toggles only exposes the toggled capabilities and the babysitter session is blocked from anything else.
- [ ] AI leash slider change is propagated within 30 seconds: `auto-mail` switches between Manual and Autonomous behavior accordingly. (event-bus integration test)
- [ ] Notification batching window change is honored by the shell push pipeline on the next event burst.
- [ ] Density toggle flips the shell home and a sampled app (`auto-tasks`) between Command Center and Kids Mode using shared design tokens.
- [ ] Integration Manager lists every registered connector from phase 1.7 with status (connected, error, paused) and exposes a working reconnect / revoke flow.
- [ ] "Download My Life" produces an encrypted zip containing rows and Storage attachments from all installed modules; decryption with the user passphrase yields readable JSON + files.
- [ ] All settings writes produce an audit row with actor, before/after diff, and timestamp.
- [ ] `family_settings` table passes the phase 2.4 RLS harness; non-owner writes are rejected.

## Risks + mitigations
- **Risk**: Settings become a "second source of truth" and drift from the underlying primitives in phase 2.3 / 2.5. **Mitigation**: every screen here reads/writes the canonical primitive via its service interface and never duplicates the model; tests assert that round-trip through this UI is identical to direct primitive updates.
- **Risk**: "Download My Life" leaks data because the export runs with elevated privileges. **Mitigation**: the Edge Function authenticates with the requesting user's JWT, enforces RLS at the SQL level, encrypts the zip with the user-supplied passphrase (Argon2id KDF), stores the artifact in a private bucket with a 24h TTL, and writes an audit row on every download.
- **Risk**: Misconfigured AI leash or notification batching silently disables critical alerts. **Mitigation**: SOS, medication refills, and finance trial-killer have a documented "minimum severity" floor that ignores batching/manual settings; this is asserted by tests.

## Implementation outline
1. Land the `family_settings` migration with a single JSONB payload, strict tenant RLS, and an `audit_settings_change` trigger.
2. Implement `packages/autolife-core` settings models, `settings_events.dart`, and a typed `SettingsService` that wraps the JSONB document.
3. Build the settings root screen with the seven sections and shared list-item primitives from `autolife-ui`.
4. Implement Permissions screens that delegate to the phase 2.3 primitive APIs.
5. Implement Privacy screens (biometric per module, granular sharing, babysitter link generator) that delegate to phase 2.5 primitives.
6. Implement Automation screens (AI leash + smart switches) writing to `family_settings.ai` and emitting `settings.changed`.
7. Implement Notifications screens (Nag mode, batching window, channel toggles); wire the shell push pipeline to read from settings.
8. Implement UI screens (density, color override, accessibility) wired to the shared design tokens.
9. Implement Integrations screen reading from the phase 1.7 connector registry with reconnect / revoke flows.
10. Implement "Download My Life": Edge Function gathers per-module exports, zips, encrypts with Argon2id + AES-GCM, writes to Storage; client polls via `export.completed` event.
11. Add an audit logger that records every settings mutation with diff + actor.
12. Run the phase 2.4 RLS harness and write integration tests for each surface, including the AI leash propagation to `auto-mail` and the export round-trip.

## Artifacts/links
- PR: (link once opened)
- Export format reference: `supabase/functions/export-my-life/README.md`
- Settings schema: `packages/autolife-core/lib/src/models/settings/family_settings.dart`
- RLS harness output: `supabase/tests/rls/family_settings.test.sql`
