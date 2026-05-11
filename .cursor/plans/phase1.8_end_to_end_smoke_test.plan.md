---
name: phase1.8_end_to_end_smoke_test
overview: Prove the full Phase 1 stack works by driving one happy-path flow end-to-end: create event in the shell, persist via offline queue, propagate via the event bus, and render on a dashboard widget.
phase: 1.8
gate_owner: Phase 1 Gate
isProject: false
---

# Phase 1.8 - End-to-End Smoke Test

## Objective
Demonstrate that the Phase 1 platform actually works together by implementing one minimal happy-path flow that exercises every primitive owned by phases 1.1 through 1.7. Concretely: a user taps "Add Event" in `apps/autolife-shell`, the event is persisted locally through the offline write queue, drained to Supabase, fanned out by `process-event` to a registered dashboard consumer, and the dashboard widget reflects the new event without a manual refresh. This plan does not introduce new primitives; it composes existing ones and adds whatever wiring/tests are missing.

## In scope
- A minimal `DashboardEventsConsumer` registered with the consumer registry from phase 1.5; it upserts received events into a Drift view that the dashboard reads.
- A minimal `AddEvent` screen in `apps/autolife-shell` that calls `SupabaseEventProducer` from phase 1.5 routed through the offline queue from phase 1.6.
- A minimal "Today" dashboard widget in `apps/autolife-shell` that streams events from the local Drift cache via Riverpod and updates in real time.
- A connectivity-toggle test harness (using `ConnectivityWatcher` overrides from phase 1.6) so the smoke test can prove offline -> online drain works.
- Use of `MockConnector` from phase 1.7 to assert the integration gateway is reachable from the shell (without calling any real external service).
- Integration test (`flutter_test` + Supabase local stack) that drives the full flow end-to-end with assertions at every hop.
- A scripted manual smoke run documented in `docs/phase1-smoke.md`.

## Out of scope
- Designing the full dashboard UX (owned by phase 3.1).
- Designing the full event-creation UX (owned by phase 3.2 auto-calendar).
- Auth flows beyond a single seeded test user (owned by phase 2.1).
- RLS enforcement (owned by phase 2.4); this smoke test runs as a service-role user where possible and as the seeded user for client-side flows.
- Real external integrations.

## Key deliverables
- [apps/autolife-shell/lib/src/screens/smoke/add_event_screen.dart](apps/autolife-shell/lib/src/screens/smoke/add_event_screen.dart) - minimal create-event screen used by the smoke flow.
- [apps/autolife-shell/lib/src/screens/smoke/today_widget.dart](apps/autolife-shell/lib/src/screens/smoke/today_widget.dart) - minimal dashboard widget consuming the cache.
- [apps/autolife-shell/lib/src/smoke/dashboard_events_consumer.dart](apps/autolife-shell/lib/src/smoke/dashboard_events_consumer.dart) - registered with the consumer registry.
- [supabase/functions/process-event/registry.ts](supabase/functions/process-event/registry.ts) - updated to include the dashboard consumer entry (registry file owned by phase 1.5; this plan only adds an entry).
- [apps/autolife-shell/integration_test/phase1_smoke_test.dart](apps/autolife-shell/integration_test/phase1_smoke_test.dart) - end-to-end test.
- [docs/phase1-smoke.md](docs/phase1-smoke.md) - manual smoke procedure + expected log lines.
- [.github/workflows/ci.yml](.github/workflows/ci.yml) - updated to run the integration test against a Supabase local stack on PRs.

## Dependencies
- [.cursor/plans/phase1.1_monorepo_workspace_setup.plan.md](.cursor/plans/phase1.1_monorepo_workspace_setup.plan.md) - workspace and CI.
- [.cursor/plans/phase1.2_autolife_core_contracts.plan.md](.cursor/plans/phase1.2_autolife_core_contracts.plan.md) - `SystemEvent`, producer/consumer interfaces.
- [.cursor/plans/phase1.3_autolife_ui_design_system.plan.md](.cursor/plans/phase1.3_autolife_ui_design_system.plan.md) - theme and shared widgets used by the screens.
- [.cursor/plans/phase1.4_supabase_baseline.plan.md](.cursor/plans/phase1.4_supabase_baseline.plan.md) - DB schema, auth, storage, function scaffolds.
- [.cursor/plans/phase1.5_event_bus_process_event_worker.plan.md](.cursor/plans/phase1.5_event_bus_process_event_worker.plan.md) - producer/consumer/retry/DLQ contract.
- [.cursor/plans/phase1.6_offline_sync_foundation.plan.md](.cursor/plans/phase1.6_offline_sync_foundation.plan.md) - Drift cache, write queue, conflict resolver.
- [.cursor/plans/phase1.7_integration_gateway_scaffold.plan.md](.cursor/plans/phase1.7_integration_gateway_scaffold.plan.md) - `IntegrationConnector` interface and `MockConnector` reference.

## Acceptance criteria (gate)
- [ ] Pressing "Add Event" while online produces one `system_event` row, one successful `event_delivery` row for the dashboard consumer, and one Drift cache row visible in the "Today" widget within 2 seconds.
- [ ] Pressing "Add Event" while offline enqueues one `pending_write` row; restoring connectivity drains it to Supabase and the event appears in the dashboard within 5 seconds, with no duplicates.
- [ ] The dashboard widget reads exclusively from the Drift cache via a Riverpod stream; turning off the network does not blank it out.
- [ ] `MockConnector` is registered in `ConnectorRegistry` and a `connector_healthcheck` call succeeds during app boot, proving the gateway scaffold is reachable.
- [ ] Theme used by the smoke screens comes from `AutoLifeTheme.light()` with no inline colors or paddings (grep verification documented in PR).
- [ ] `apps/autolife-shell/integration_test/phase1_smoke_test.dart` passes in CI against a local Supabase stack.
- [ ] `docs/phase1-smoke.md` walks a human through the same flow with expected screenshots/log lines and is up to date with the test.
- [ ] Phase 1 gate checkbox in [.cursor/plans/autolife_overarching_architecture_plan_e0168493.plan.md](.cursor/plans/autolife_overarching_architecture_plan_e0168493.plan.md) can be ticked on the merge of this PR.

## Risks + mitigations
- **Risk**: Flaky integration tests due to Supabase local-stack startup races. / **Mitigation**: Spawn the stack in a CI service container with a readiness probe (`pg_isready` + `supabase status`) and only start the test after both report ready; retry the whole test once on transient failures with `flutter test --reporter expanded` logs captured.
- **Risk**: Hidden coupling between the smoke screens and downstream Phase 3 designs forcing rework. / **Mitigation**: Keep smoke screens under `apps/autolife-shell/lib/src/screens/smoke/` and gate them behind a debug flag so they can be deleted once phases 3.1/3.2 land without touching Phase 3 code.
- **Risk**: Smoke proving Phase 1 works only in the optimistic path while hiding regressions in retry/DLQ behavior. / **Mitigation**: Extend the integration test with one explicit failure injection (consumer throws once, succeeds on retry) so the retry pipeline is also exercised on every CI run.

## Implementation outline
1. Confirm phases 1.1-1.7 have merged and their gates are green; if not, surface blockers in this plan's PR description.
2. Add `DashboardEventsConsumer` and register it in `supabase/functions/process-event/registry.ts`.
3. Implement the smoke `AddEventScreen` using shared widgets from `packages/autolife-ui`, wiring submit to `SupabaseEventProducer` routed through the offline queue.
4. Implement `TodayWidget` streaming from the Drift cache via a Riverpod provider.
5. Register `MockConnector` in the shell's bootstrap and call `healthcheck` once on boot.
6. Write the integration test in `apps/autolife-shell/integration_test/phase1_smoke_test.dart` covering online, offline, retry-success, and connector-healthcheck assertions.
7. Update CI workflow to spin up Supabase locally and run the integration test on every PR.
8. Author `docs/phase1-smoke.md` and capture log lines + screenshots from a successful local run.
9. Tick the Phase 1 gate in the overarching plan in a follow-up commit once this PR merges.

## Artifacts/links
- PR: (tbd)
- Migration: (tbd)
- Test report: (tbd)
