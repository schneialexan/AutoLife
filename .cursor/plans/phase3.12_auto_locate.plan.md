---
name: phase3.12_auto_locate
overview: Build the lowest-priority, privacy-critical auto-locate app for family location sharing, geofenced places, alert history, and an SOS protocol, governed by explicit consent and a full audit log.
phase: 3.12
gate_owner: Full App Gate
isProject: false
---

# Phase 3.12 - auto-locate (Family Safety + Location)

## Objective
Deliver `auto-locate` as the lowest-priority, privacy-critical expansion app. It provides a family map with consenting members, saved Places with geofences, an Alerts history, and an SOS protocol that notifies parents with precise location. Every location read is gated by explicit, revocable consent and recorded in an immutable audit log. The app must respect the phase 2.5 babysitter-scoped link primitive and never leak position to non-tenancy accounts.

**Priority note**: This is the lowest-priority expansion app. Schedule it last in the Full App Gate sequence.

## UI reference
![AutoLocate](../../assets/autolocate.png)

### Tabs and key surfaces (verbatim from overarching plan 3.12)
- **NOTE**: Lowest priority expansion app. Schedule last.
- **Top tabs**: Map, People, Places, Alerts
- **Map**: Full-screen map with colored family member pins (avatar + name label); location name annotations
- **Bottom sheet**: Family member list with current location, last-updated timestamp
- **Places**: Saved locations (home, school, work) with geofence config
- **Alerts**: Geofence notification history
- **SOS button**: Large red button (bottom-right) triggers emergency protocol with GPS to parents
- **Safety**: Explicit consent model; audit log for location access

## In scope
- Full-screen Map with family member pins, avatars, name labels, and reverse-geocoded annotations.
- People bottom sheet with last-updated timestamp and a per-person "Show on map" toggle.
- Places: home/school/work/custom with configurable geofence radius and arrival/leave alerts.
- Alerts: geofence notification history with member, place, direction, timestamp.
- SOS button: tap-and-hold gesture sends a high-priority push to all parents with current GPS, accuracy, and timestamp.
- Consent model: every member must opt in to share location, can pause sharing, and revokes immediately with TTL on cached pins.
- Audit log: every location read (UI render or API access) writes an immutable row scoped to the requesting user.
- "Where is my?" device pings for shared family devices (lost-phone case).

## Out of scope
- Tracking non-tenancy contacts (extended family, friends, pets in v1).
- Location history scrubbing of third-party services (Apple Find My, Google).
- Indoor positioning, BLE beacons, or AR overlays.
- Driving-behavior analytics (speed, harsh braking) beyond raw location.

## Key deliverables
- `apps/auto-locate/lib/src/app.dart` with consent gate on first launch.
- `apps/auto-locate/lib/src/screens/map/map_screen.dart`, `widgets/family_pin.dart`, `widgets/people_bottom_sheet.dart`, `widgets/sos_button.dart`.
- `apps/auto-locate/lib/src/screens/people/people_screen.dart`.
- `apps/auto-locate/lib/src/screens/places/{places_screen,place_editor_screen}.dart`, `widgets/geofence_radius_slider.dart`.
- `apps/auto-locate/lib/src/screens/alerts/alerts_screen.dart`.
- `apps/auto-locate/lib/src/services/{location_provider,geofence_engine,sos_dispatcher,consent_service,audit_logger}.dart`.
- `packages/autolife-core/lib/src/models/locate/{location_ping,place,geofence_rule,sos_event,consent_grant,location_audit}.dart`.
- `packages/autolife-core/lib/src/events/locate_events.dart` (`location.ping`, `geofence.crossed`, `sos.triggered`, `consent.changed`, `location.access_audited`).
- `supabase/migrations/20260915_auto_locate_tables.sql`.
- `supabase/migrations/20260915_auto_locate_rls.sql` (consent-aware policies).
- `supabase/functions/geofence-evaluator/index.ts` (runs on location pings, emits crossings).
- `supabase/functions/sos-dispatch/index.ts` (high-priority push fan-out to all parents).

## Dependencies
- Phase 1.2 contracts: `.cursor/plans/phase1.2_autolife_core_contracts.plan.md`.
- Phase 1.3 design system: `.cursor/plans/phase1.3_autolife_ui_design_system.plan.md`.
- Phase 1.4 Supabase baseline: `.cursor/plans/phase1.4_supabase_baseline.plan.md`.
- Phase 1.5 event bus: `.cursor/plans/phase1.5_event_bus_process_event_worker.plan.md`.
- Phase 1.6 offline foundation (queued pings on flaky networks): `.cursor/plans/phase1.6_offline_sync_foundation.plan.md`.
- Phase 1.7 integration gateway (map tiles, push provider): `.cursor/plans/phase1.7_integration_gateway_scaffold.plan.md`.
- Phase 2.2 tenancy: `.cursor/plans/phase2.2_family_tenancy_model.plan.md`.
- Phase 2.3 roles + approval engine (kid consent flows): `.cursor/plans/phase2.3_role_policy_model.plan.md`.
- Phase 2.4 RLS: `.cursor/plans/phase2.4_rls_policies.plan.md`.
- Phase 2.5 privacy controls (consent, audit, babysitter scope): `.cursor/plans/phase2.5_privacy_controls.plan.md` -- MANDATORY.
- Phase 3.1 `autolife-shell`: `.cursor/plans/phase3.1_autolife_shell_dashboard.plan.md` (SOS surfaces in shell).

## Acceptance criteria (gate)
- [ ] First launch shows the consent screen; the app cannot read or render location until consent is granted, and revoking consent clears cached pins within 5 seconds. (privacy-critical test)
- [ ] Every render of a member pin writes an `location_audit` row with requester id, target id, timestamp, and source (UI or API).
- [ ] Geofence crossing produces a `geofence.crossed` event consumed by the Alerts screen and surfaced as a push within 60 seconds. (event-bus integration test)
- [ ] SOS button: a 2-second long-press triggers a high-priority push to all parent role members with GPS, accuracy, and a deep link back to the SOS event detail.
- [ ] Consent pause toggle: paused members render as "Sharing paused" with no last-known location visible; resuming restores sharing only after a confirmation tap.
- [ ] Babysitter guest link from phase 2.5 can read only the parents' current location during the link's TTL and nothing else.
- [ ] All locate tables pass the phase 2.4 RLS test harness; cross-account reads without an active consent grant are rejected.
- [ ] Lost-phone ping: requesting a lost-device ping triggers a remote alert on the target device and is recorded in the audit log.

## Risks + mitigations
- **Risk**: Location data leaks beyond consenting family members. **Mitigation**: RLS policies require an active `consent_grant` row for every read, with deny-by-default and a dedicated test suite that asserts cross-account reads fail; revocation flushes cache TTL immediately on the client.
- **Risk**: SOS notification is missed because of OS-level Do Not Disturb. **Mitigation**: register SOS as a critical / time-sensitive notification class with the push provider, request the user to grant the elevated permission on onboarding, and fall back to repeated retries with audit logging.
- **Risk**: Background location drains battery and erodes adoption. **Mitigation**: use platform-recommended significant-change APIs by default, expose a clear "battery saver" toggle in settings, and document the trade-off in the consent screen copy.

## Implementation outline
1. Scaffold `apps/auto-locate` with the consent gate as the root route.
2. Apply migrations for `location_pings`, `places`, `geofence_rules`, `sos_events`, `consent_grants`, `location_audit`, with consent-aware RLS.
3. Implement `packages/autolife-core` DTOs and events under `models/locate/` and `events/locate_events.dart`.
4. Build the Map screen with a swappable map-tile provider behind the phase 1.7 integration gateway.
5. Implement `location_provider` (platform location streams with significant-change defaults) and the offline-friendly ping queue.
6. Implement the People bottom sheet, the per-person consent toggle, and pause/resume behavior with audit hooks.
7. Build the Places editor with geofence radius slider and the `geofence-evaluator` Edge Function.
8. Build the Alerts history screen and the geofence push pipeline.
9. Implement the SOS button (long-press), `sos-dispatch` Edge Function, and the critical-notification configuration.
10. Implement the "Where is my?" lost-device ping flow with a dedicated audit entry.
11. Wire the phase 2.5 babysitter guest link to a strictly scoped read of parents' last-known location.
12. Run the phase 2.4 RLS harness and add integration tests for consent revocation, geofence crossing, and SOS dispatch.

## Artifacts/links
- PR: (link once opened)
- Privacy controls reference: `.cursor/plans/phase2.5_privacy_controls.plan.md`
- Map provider notes: `packages/autolife-core/lib/src/integrations/map_provider.md`
- RLS harness output: `supabase/tests/rls/auto_locate.test.sql`
