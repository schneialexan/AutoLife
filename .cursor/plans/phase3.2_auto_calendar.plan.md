---
name: phase3.2_auto_calendar
overview: Deliver the family smart calendar with Day/Week/Month/Agenda views, member colors, weather overlays, auto-commute blocks via the integration gateway, two-way sync with Google/Apple/Outlook, and scoped babysitter read-only links.
phase: 3.2
gate_owner: MVP App Gate
isProject: false
---

# Phase 3.2 - Auto-Calendar (Smart Calendar)

## Objective
Build the AutoLife smart calendar that lets a family schedule, view, and share events across Day/Week/Month/Agenda views with member-colored entries, weather overlays, auto-commute travel blocks computed from Google Maps via the integration gateway, two-way sync with Google/Apple/Outlook, and a babysitter read-only link generator with explicit scope and duration. The app participates in the cross-module event bus by accepting `event.convert_to_task` from `auto-tasks` and emitting `event.created`, `event.updated`, and `event.deleted` envelopes that other modules consume.

## UI reference
### 3.2 `auto-calendar` -- Smart Calendar
![AutoCalendar](../../assets/autocalendar.png)
- **Top**: Segmented control -- Day / Week / Month (+ Agenda secondary view)
- **Month view**: Calendar grid with colored dots per family member; weather icons on days; red dot for flagged forecast changes
- **Day event list**: Time, title, location, colored left border per member
- **Special elements**: Auto-commute blocks shown as gray "travel" entries with car icon; weather overlays on day headers
- **Actions**: Floating "+" to create event; long-press to convert event to task; share babysitter read-only link from event detail

## In scope
- Flutter app at `apps/auto-calendar/` runnable standalone and embeddable in the shell.
- Day, Week, Month, and Agenda views with member-color borders, recurrence rendering, and timezone-correct rendering.
- Event create / edit / delete flows with location, attendees, reminders, and recurrence.
- Weather overlay on day headers and red-dot flag when a forecast change crosses a configurable threshold (e.g. precipitation > 50 percent).
- Auto-commute blocks: virtual gray entries computed from the integration gateway Maps connector and inserted around events with a location, gated by a Control Center toggle.
- Two-way sync with Google Calendar, Apple Calendar, and Outlook via the integration gateway connectors with deterministic external-id mapping and conflict policy.
- Long-press menu to convert an event into a task by emitting `event.convert_to_task` onto the event bus.
- Babysitter share-link generator (scope toggles + duration) backed by a Supabase edge function and projection view.
- Offline-first reads and writes through the `autolife-core` write queue with reconciliation on reconnect.
- Realtime updates over Supabase channels.

## Out of scope
- Task UI (delivered by [phase3.3_auto_tasks.plan.md](phase3.3_auto_tasks.plan.md)).
- Settings UI for commute / weather toggles (lives in `phase3.13_control_center_settings.plan.md`; this app reads the flags only).
- Inbound email parsing to create events (`phase3.9_auto_mail.plan.md`).
- Full-screen map view; the calendar shows only a small location thumbnail.
- Push notification scheduling (owned by `phase1.5_event_bus_process_event_worker.plan.md`).

## Key deliverables
- [`apps/auto-calendar/lib/main.dart`](../../apps/auto-calendar/lib/main.dart)
- [`apps/auto-calendar/lib/src/calendar_module.dart`](../../apps/auto-calendar/lib/src/calendar_module.dart)
- [`apps/auto-calendar/lib/src/screens/calendar/calendar_screen.dart`](../../apps/auto-calendar/lib/src/screens/calendar/calendar_screen.dart)
- [`apps/auto-calendar/lib/src/screens/calendar/views/day_view.dart`](../../apps/auto-calendar/lib/src/screens/calendar/views/day_view.dart)
- [`apps/auto-calendar/lib/src/screens/calendar/views/week_view.dart`](../../apps/auto-calendar/lib/src/screens/calendar/views/week_view.dart)
- [`apps/auto-calendar/lib/src/screens/calendar/views/month_view.dart`](../../apps/auto-calendar/lib/src/screens/calendar/views/month_view.dart)
- [`apps/auto-calendar/lib/src/screens/calendar/views/agenda_view.dart`](../../apps/auto-calendar/lib/src/screens/calendar/views/agenda_view.dart)
- [`apps/auto-calendar/lib/src/screens/calendar/widgets/event_card.dart`](../../apps/auto-calendar/lib/src/screens/calendar/widgets/event_card.dart)
- [`apps/auto-calendar/lib/src/screens/calendar/widgets/weather_overlay.dart`](../../apps/auto-calendar/lib/src/screens/calendar/widgets/weather_overlay.dart)
- [`apps/auto-calendar/lib/src/screens/calendar/widgets/commute_block.dart`](../../apps/auto-calendar/lib/src/screens/calendar/widgets/commute_block.dart)
- [`apps/auto-calendar/lib/src/screens/calendar/event_form_screen.dart`](../../apps/auto-calendar/lib/src/screens/calendar/event_form_screen.dart)
- [`apps/auto-calendar/lib/src/screens/calendar/event_detail_screen.dart`](../../apps/auto-calendar/lib/src/screens/calendar/event_detail_screen.dart)
- [`apps/auto-calendar/lib/src/screens/calendar/babysitter_link_screen.dart`](../../apps/auto-calendar/lib/src/screens/calendar/babysitter_link_screen.dart)
- [`apps/auto-calendar/lib/src/providers/calendar_providers.dart`](../../apps/auto-calendar/lib/src/providers/calendar_providers.dart)
- [`apps/auto-calendar/lib/src/providers/external_sync_provider.dart`](../../apps/auto-calendar/lib/src/providers/external_sync_provider.dart)
- [`apps/auto-calendar/lib/src/services/commute_planner_service.dart`](../../apps/auto-calendar/lib/src/services/commute_planner_service.dart)
- [`apps/auto-calendar/lib/src/services/babysitter_link_service.dart`](../../apps/auto-calendar/lib/src/services/babysitter_link_service.dart)
- [`apps/auto-calendar/lib/src/services/external_calendar_sync_service.dart`](../../apps/auto-calendar/lib/src/services/external_calendar_sync_service.dart)
- [`packages/autolife-core/lib/src/calendar/calendar_event.dart`](../../packages/autolife-core/lib/src/calendar/calendar_event.dart)
- [`packages/autolife-core/lib/src/calendar/calendar_repository.dart`](../../packages/autolife-core/lib/src/calendar/calendar_repository.dart)
- [`packages/autolife-core/lib/src/calendar/calendar_events_emitter.dart`](../../packages/autolife-core/lib/src/calendar/calendar_events_emitter.dart)
- [`supabase/migrations/<timestamp>_calendar_events.sql`](../../supabase/migrations)
- [`supabase/migrations/<timestamp>_calendar_sync_links.sql`](../../supabase/migrations)
- [`supabase/migrations/<timestamp>_babysitter_links.sql`](../../supabase/migrations)
- [`supabase/functions/calendar-share-link/index.ts`](../../supabase/functions/calendar-share-link/index.ts)
- [`apps/auto-calendar/test/views/calendar_view_test.dart`](../../apps/auto-calendar/test/views/calendar_view_test.dart)
- [`apps/auto-calendar/test/services/commute_planner_service_test.dart`](../../apps/auto-calendar/test/services/commute_planner_service_test.dart)
- [`apps/auto-calendar/integration_test/external_sync_round_trip_test.dart`](../../apps/auto-calendar/integration_test/external_sync_round_trip_test.dart)

## Dependencies
- [phase1.2_autolife_core_contracts.plan.md](phase1.2_autolife_core_contracts.plan.md) - the canonical `CalendarEvent` envelope and event bus contracts.
- [phase1.3_autolife_ui_design_system.plan.md](phase1.3_autolife_ui_design_system.plan.md) - colors, type ramp, and shared widgets used across the views.
- [phase1.4_supabase_baseline.plan.md](phase1.4_supabase_baseline.plan.md) - DB / storage / edge function baseline.
- [phase1.5_event_bus_process_event_worker.plan.md](phase1.5_event_bus_process_event_worker.plan.md) - the bus on which we emit and consume calendar envelopes.
- [phase1.6_offline_sync_foundation.plan.md](phase1.6_offline_sync_foundation.plan.md) - offline write queue and conflict rules.
- [phase1.7_integration_gateway_scaffold.plan.md](phase1.7_integration_gateway_scaffold.plan.md) - Google Maps, weather, and external calendar connectors.
- [phase2.2_family_tenancy_model.plan.md](phase2.2_family_tenancy_model.plan.md) - the active family scoping every query.
- [phase2.3_role_policy_model.plan.md](phase2.3_role_policy_model.plan.md) - approval engine for who can create or edit events.
- [phase2.4_rls_policies.plan.md](phase2.4_rls_policies.plan.md) - RLS templates for events, sync links, and babysitter links.
- [phase2.5_privacy_controls.plan.md](phase2.5_privacy_controls.plan.md) - babysitter scoping rules the share link enforces.

Reference only; do not redefine event schema, tenancy, RLS templates, offline queue, design tokens, or integration interfaces here.

## Acceptance criteria (gate)
- [ ] Day, Week, Month, and Agenda views render seeded family events with correct member-color borders and timezone handling.
- [ ] Weather overlay icons appear on day headers and a forecast change crossing the configured threshold flips the day to a red dot.
- [ ] Creating an event with a location automatically inserts a gray commute block computed via the integration gateway Maps connector (deterministic mock ETA used in tests) and removes the block when the location is cleared.
- [ ] Two-way sync with at least Google Calendar round-trips create / update / delete within 30 s and recovers idempotently after a forced reconnect.
- [ ] Long-pressing an event emits `event.convert_to_task` onto the event bus and `auto-tasks` consumes it to produce a corresponding task (cross-module event emission/consumption verified by integration test).
- [ ] Creating any event emits an `event.created` envelope that the shell activity feed and `auto-tasks` cross-module consumers see.
- [ ] Babysitter share-link generator mints a token with toggled scope (events on, finance off) and a chosen duration; expired tokens return 403.
- [ ] Offline create / edit / delete queues through the `autolife-core` write queue and reconciles without dropping recurrence exceptions on reconnect.
- [ ] RLS prevents non-family viewers; babysitter token reads only the scoped projection.
- [ ] Widget and integration tests cover view switching, commute insertion, external sync conflict cases, and bus round-trips.

## Risks + mitigations
1. External calendar sync produces duplicates or loses events on conflict. Mitigation: use a deterministic `external_uid` per provider, idempotent upserts keyed on it, last-write-wins guarded by `updated_at`, and a reconciler dry-run logger before any destructive write.
2. Commute computation hits Google Maps rate limits or quota. Mitigation: cache directions per `(origin, destination, arrival_hour_bucket)` for 30 minutes, batch identical lookups, and degrade to manual padding when the gateway returns 429.
3. Babysitter link leaks sensitive fields. Mitigation: the link is a server-rendered projection from `calendar-share-link` using an allowlisted column set, validated by RLS tests in the `phase2.4` harness; tokens are signed, scoped, and time-bound.

## Implementation outline
1. Add migrations `calendar_events`, `calendar_sync_links`, and `babysitter_links` with RLS templates from `phase2.4` and indices for `(family_id, starts_at)`.
2. Define `CalendarEvent`, `CalendarRepository`, and `CalendarEventsEmitter` in `packages/autolife-core/lib/src/calendar/` and export them from the package barrel.
3. Implement the repository against the `autolife-core` sync queue (`phase1.6`) plus Supabase realtime; wire the emitter to publish `event.created` / `event.updated` / `event.deleted` envelopes onto the bus from `phase1.5`.
4. Build the calendar view skeletons (`day_view`, `week_view`, `month_view`, `agenda_view`) reading from a shared `calendar_events_provider` and respecting the active-family scope from `phase2.2`.
5. Add the `weather_overlay` widget pulling from the integration gateway weather connector (`phase1.7`) and flagging forecast changes above the threshold.
6. Add `commute_planner_service` that calls the integration gateway Maps connector and inserts virtual `commute_block` entries around events with a location, gated by the Control Center commute flag.
7. Implement `external_sync_provider` and `external_calendar_sync_service` against the integration gateway connectors for Google, Apple, and Outlook; encode the conflict policy and dry-run reconciler.
8. Add the long-press menu in `event_detail_screen` and `event_card` that emits `event.convert_to_task` onto the event bus and document the consumer contract for `phase3.3`.
9. Implement `calendar-share-link` edge function that mints scoped babysitter tokens, plus the corresponding projection view in Postgres.
10. Build `event_form_screen` and `event_detail_screen`, honoring settings flags (commute on/off, weather flag on/off) read through Control Center stubs.
11. Add widget + service unit tests and the `external_sync_round_trip_test.dart` integration test that drives bus round-trips end-to-end.

## Artifacts/links
- [PR placeholder]
- [External sync conflict matrix]
- [Babysitter link projection spec]
- [Commute caching strategy doc]
