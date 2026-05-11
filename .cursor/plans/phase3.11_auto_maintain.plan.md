---
name: phase3.11_auto_maintain
overview: Build the auto-maintain capability for home and vehicle maintenance, with a documented decision checkpoint on whether to ship it as a standalone app or merge it into auto-assets as a Maintenance tab.
phase: 3.11
gate_owner: Full App Gate
isProject: false
---

# Phase 3.11 - auto-maintain (Home + Vehicles)

## Objective
Deliver the maintenance capability for home and vehicles: mileage and seasonal triggers that auto-schedule tasks, a provider directory with ratings and video-notes, and a "Home Tricks" video/photo log. Before any UI work begins, the team executes the decision checkpoint below to decide whether `auto-maintain` ships as its own app or as a Maintenance tab inside `auto-assets`.

## Decision checkpoint
Maintenance capability has high data overlap with `auto-assets` (vehicles and home equipment are already first-class assets). Before scaffolding a new app, evaluate the criteria below and select the shipping shape.

### Criteria
- **Data model overlap**: If maintenance entities (assets, schedules, providers) overlap with `auto-assets` schemas by >= 70%, prefer merging into `auto-assets` as a Maintenance tab. Concretely: an `asset` already has serial, warranty, purchase, claim timeline; maintenance adds schedule + provider + odometer triggers.
- **Team capacity**: If the platform team has fewer than 2 engineers available for a full milestone, prefer the merge path -- one app is cheaper to maintain than two.
- **UX coherence**: If a user looking at a vehicle expects to see maintenance inline (most likely yes), prefer merge. If users describe a separate mental model ("my home upkeep vs my purchases"), prefer standalone.
- **Release sequencing risk**: If `auto-assets` is already on its v1 gate and adding a Maintenance tab fits inside its next minor, prefer merge. If standalone unblocks a parallel team, prefer separate.
- **Provider directory ambition**: If a real provider marketplace (ratings, scheduling, payments) is on the roadmap within two phases, prefer standalone because the surface grows fast.

### Default recommendation
Merge into `auto-assets` as a Maintenance tab in v1. Rationale: data overlap is >= 70%, the calendar/tasks integration is identical, and the UX gain of "one tap from the vehicle asset to its maintenance plan" outweighs an extra app icon. Re-evaluate at the start of phase 4 if provider features take off; standalone migration is straightforward because all entities are already family-scoped.

### Decision output
The owner records the chosen shape (merge / standalone), the date, the decision-maker, and the trigger that would flip the decision later, in `apps/auto-assets/docs/maintenance_decision.md` (or `apps/auto-maintain/docs/decision.md` for standalone). The rest of this plan applies to whichever path is chosen; file paths below assume the standalone path and must be remapped to `apps/auto-assets/lib/src/screens/maintenance/...` if merge is selected.

## UI reference
<!-- Image pending: ../../assets/automaintain.png (to be created) -->

### Tabs and key surfaces (verbatim from overarching plan 3.11)
- **NOTE**: This app may be absorbed into AutoAssets as a "Maintenance" tab rather than existing as a standalone app. Decide during its planning phase.
- **Top tabs**: Schedule, Assets, Providers
- **Schedule**: Upcoming maintenance cards (icon, asset name, due trigger, urgency badge)
- **Asset detail**: Maintenance type, linked asset, odometer/trigger values, provider recommendation, "Mark as Complete" / "Reschedule"
- **Assets tab**: Home and vehicle profiles with maintenance history
- **Providers tab**: Contact list with notes, ratings, video-notes attached
- **Automation**: Auto-scheduled items from weather data or mileage triggers shown with "Auto-scheduled" badge

## In scope
- Schedule tab: list of upcoming maintenance items sorted by urgency, with mark-complete and reschedule.
- Asset detail surface for vehicles and home equipment with mileage / hours / season trigger configuration.
- Provider directory with contacts, ratings, notes, and attached video-notes.
- Mileage trigger engine: user updates odometer -> schedule "Change Oil" or similar.
- Seasonal automation: weather/season events emit `maintenance.seasonal_due` (e.g., "Winterize Sprinklers").
- Home Tricks log: short videos/photos pinned to a home subsystem with searchable notes.
- Cross-app: maintenance items create tasks in `auto-tasks`, mirror to `auto-calendar`, attach photos via `auto-gallery`.

## Out of scope
- Marketplace booking / payments with providers.
- Live OBD-II vehicle telemetry ingestion.
- Smart-home device integrations (HomeKit/Matter) -- deferred.
- AI cost estimation for repairs.

## Key deliverables
- `apps/auto-maintain/lib/src/app.dart` (or `apps/auto-assets/lib/src/screens/maintenance/` if the decision is merge).
- `apps/auto-maintain/lib/src/screens/schedule/schedule_screen.dart`, `widgets/maintenance_card.dart`, `widgets/urgency_badge.dart`.
- `apps/auto-maintain/lib/src/screens/assets/{asset_list_screen,asset_detail_screen}.dart`, `widgets/odometer_input.dart`, `widgets/trigger_config.dart`.
- `apps/auto-maintain/lib/src/screens/providers/{provider_list_screen,provider_detail_screen}.dart`, `widgets/rating_chips.dart`, `widgets/video_note_player.dart`.
- `apps/auto-maintain/lib/src/screens/tricks/home_tricks_screen.dart`.
- `apps/auto-maintain/lib/src/services/{mileage_trigger_service,seasonal_scheduler,provider_repository}.dart`.
- `packages/autolife-core/lib/src/models/maintain/{maintenance_item,provider,home_trick,trigger_rule}.dart`.
- `packages/autolife-core/lib/src/events/maintain_events.dart` (`maintenance.scheduled`, `maintenance.completed`, `maintenance.seasonal_due`, `provider.contacted`).
- `supabase/migrations/20260901_auto_maintain_tables.sql` (maintenance_items, providers, home_tricks, trigger_rules).
- `supabase/migrations/20260901_auto_maintain_rls.sql`.
- `supabase/functions/seasonal-maintenance-cron/index.ts` (weather/season triggers).

## Dependencies
- Phase 1.2 contracts: `.cursor/plans/phase1.2_autolife_core_contracts.plan.md`.
- Phase 1.3 design system: `.cursor/plans/phase1.3_autolife_ui_design_system.plan.md`.
- Phase 1.4 Supabase baseline: `.cursor/plans/phase1.4_supabase_baseline.plan.md`.
- Phase 1.5 event bus: `.cursor/plans/phase1.5_event_bus_process_event_worker.plan.md`.
- Phase 1.6 offline foundation: `.cursor/plans/phase1.6_offline_sync_foundation.plan.md`.
- Phase 2.2 tenancy: `.cursor/plans/phase2.2_family_tenancy_model.plan.md`.
- Phase 2.3 roles: `.cursor/plans/phase2.3_role_policy_model.plan.md`.
- Phase 2.4 RLS: `.cursor/plans/phase2.4_rls_policies.plan.md`.
- Phase 3.2 `auto-calendar`: `.cursor/plans/phase3.2_auto_calendar.plan.md` (mirroring scheduled maintenance).
- Phase 3.3 `auto-tasks`: `.cursor/plans/phase3.3_auto_tasks.plan.md` (task creation).
- Phase 3.4 `auto-assets`: `.cursor/plans/phase3.4_auto_assets.plan.md` (asset registry overlap; primary integration target).
- Phase 3.8 `auto-gallery`: `.cursor/plans/phase3.8_auto_gallery.plan.md` (video-notes, photos).

## Acceptance criteria (gate)
- [ ] Decision checkpoint documented in `apps/auto-assets/docs/maintenance_decision.md` (or `apps/auto-maintain/docs/decision.md`) with chosen path, criteria scoring, owner, and re-evaluation trigger.
- [ ] Updating odometer on a vehicle asset above a configured threshold schedules the linked maintenance item and emits a task in `auto-tasks`. (event-bus integration test)
- [ ] Seasonal cron generates the configured upcoming maintenance items idempotently across reruns.
- [ ] Scheduled maintenance items mirror to `auto-calendar` with the "Auto-scheduled" badge surfaced in the Schedule tab.
- [ ] Provider directory supports adding a contact, attaching a video-note via `auto-gallery`, and rating it on a 1-5 scale.
- [ ] Home Tricks search returns matching entries by tag and free-text within 200ms for a seeded set of 100 items.
- [ ] All maintenance tables pass the phase 2.4 RLS test harness with the merged-vs-standalone schemas matching exactly.
- [ ] Marking a maintenance item complete records the completion date, optional cost, optional linked provider, and emits `maintenance.completed`.

## Risks + mitigations
- **Risk**: The decision to merge vs. standalone is deferred and both paths get partially built. **Mitigation**: the decision checkpoint is a hard gate; no implementation work starts until `maintenance_decision.md` is committed and reviewed by the owner.
- **Risk**: Mileage and seasonal triggers misfire and spam the family with maintenance tasks. **Mitigation**: triggers are idempotent (deduped on `(asset_id, rule_id, period_bucket)`), default to manual confirmation under the phase 2.5 AI leash, and surface a "snooze" control on every generated card.
- **Risk**: Provider video-notes inflate storage costs. **Mitigation**: cap video-note length to 60 seconds, transcode server-side, and store under the existing `auto-gallery` quota with the same per-family limits.

## Implementation outline
1. Run the decision checkpoint, commit `maintenance_decision.md`, and rebase the file paths in this plan accordingly.
2. Scaffold the app or the new tab in `auto-assets` based on the decision.
3. Apply migrations for `maintenance_items`, `trigger_rules`, `providers`, `home_tricks` with phase 2.4 RLS.
4. Implement `packages/autolife-core` DTOs and events under `models/maintain/` and `events/maintain_events.dart`.
5. Build the Schedule tab with urgency sorting and the mark-complete / reschedule actions.
6. Build the Asset detail surface for vehicles and home equipment with odometer and trigger configuration.
7. Implement the mileage trigger service and wire it to `auto-tasks` and `auto-calendar`.
8. Implement the `seasonal-maintenance-cron` Edge Function using weather data via the phase 1.7 integration gateway.
9. Build the Providers directory and integrate video-note attachment from `auto-gallery`.
10. Build the Home Tricks screen with tag-based search.
11. Wire the "Auto-scheduled" badge and an "AI leash" check that respects phase 2.5 manual/autonomous mode.
12. Run the phase 2.4 RLS harness and add integration tests for trigger -> task -> calendar flows.

## Artifacts/links
- Decision doc: `apps/auto-assets/docs/maintenance_decision.md` (or `apps/auto-maintain/docs/decision.md`)
- PR: (link once opened)
- Trigger rules reference: `packages/autolife-core/lib/src/maintain/trigger_rules.md`
- RLS harness output: `supabase/tests/rls/auto_maintain.test.sql`
