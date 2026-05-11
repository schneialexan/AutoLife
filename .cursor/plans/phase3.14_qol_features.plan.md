---
name: phase3.14_qol_features
overview: Build the cross-cutting QoL features that touch every app - universal omnibar, Smart Morning/Evening briefings, voice routing, and printable PDF export - on top of the shared autolife-core primitives.
phase: 3.14
gate_owner: Full App Gate
isProject: false
---

# Phase 3.14 - QoL Features (Omnibar, Briefings, Voice, PDF Export)

## Objective
Deliver the four cross-cutting Quality-of-Life features promised in the product vision: a Universal Omnibar that searches across every module, Smart Morning / Evening briefings delivered as push notifications, Voice routing that maps speech to module actions, and Printable PDF export with multiple templates for lists, calendars, and meal plans. These features must compose on the shared primitives (`packages/autolife-core` search index, event bus, design tokens, integration gateway) and avoid app-specific copies.

## In scope
- Universal Omnibar: single search bar mounted in `apps/autolife-shell` that queries an in-process search service exposed by `packages/autolife-core`. Returns ranked results across calendar, tasks, assets, dine, health (respecting privacy), finance (respecting privacy), gallery, mail, pets, maintain, locate.
- Search index: in-memory tokenized index seeded from local caches; server-side fallback through a `search` Edge Function for unindexed corpora.
- Smart Morning / Evening Briefings: scheduled Edge Function builds a personalized summary (weather, today's events and tasks, anomalies like rain over a Beach Day), sends a push, and renders an in-app briefing screen.
- Voice routing: platform speech-to-text -> intent classifier -> module action dispatch via the event bus. Initial intents: create event, create task, add to grocery list, log meal, log medication, start SOS.
- Printable PDF export: server-side renderer producing themed PDFs (multiple templates: minimalist, family fridge, week planner) for lists, calendars, and meal plans.
- Settings ties to phase 3.13: briefing time, briefing channels, voice opt-in per device, PDF template choice.

## Out of scope
- Full-text indexing of Storage attachments (PDFs, video transcripts).
- Conversational LLM assistant beyond intent classification.
- Voice biometrics or speaker identification.
- Print-to-printer integration (export only; user prints themselves).

## Key deliverables
- `apps/autolife-shell/lib/src/widgets/omnibar/omnibar.dart`, `widgets/omnibar/result_row.dart`, `widgets/omnibar/result_group_header.dart`.
- `apps/autolife-shell/lib/src/screens/briefing/{morning_briefing_screen,evening_briefing_screen}.dart`.
- `apps/autolife-shell/lib/src/services/{voice_router,voice_intent_dispatcher,briefing_client,pdf_export_client}.dart`.
- `packages/autolife-core/lib/src/search/{search_service,search_index,search_query,search_result}.dart`.
- `packages/autolife-core/lib/src/search/providers/{calendar_provider,tasks_provider,assets_provider,dine_provider,health_provider,finance_provider,gallery_provider,mail_provider,pets_provider,maintain_provider,locate_provider}.dart`.
- `packages/autolife-core/lib/src/voice/{intent_schema,intent_classifier_client,voice_action_dispatcher}.dart`.
- `packages/autolife-core/lib/src/export/{pdf_request,pdf_template,pdf_export_client}.dart`.
- `packages/autolife-core/lib/src/events/qol_events.dart` (`omnibar.queried`, `briefing.delivered`, `voice.intent_received`, `export.pdf_requested`, `export.pdf_completed`).
- `supabase/migrations/20261101_qol_tables.sql` (briefing_runs, voice_intent_logs, pdf_exports).
- `supabase/functions/search/index.ts` (server-side fallback search across tenant data).
- `supabase/functions/briefing-builder/index.ts` (scheduled per-user; assembles morning and evening payloads).
- `supabase/functions/voice-intent/index.ts` (classifier + dispatcher; emits intents to the event bus).
- `supabase/functions/pdf-render/index.ts` (renders templated PDFs from a JSON spec; writes to Storage).

## Dependencies
- Phase 1.2 contracts: `.cursor/plans/phase1.2_autolife_core_contracts.plan.md` (search/voice/PDF DTOs live alongside other core models).
- Phase 1.3 design system: `.cursor/plans/phase1.3_autolife_ui_design_system.plan.md` (omnibar typography, briefing card).
- Phase 1.4 Supabase baseline: `.cursor/plans/phase1.4_supabase_baseline.plan.md`.
- Phase 1.5 event bus: `.cursor/plans/phase1.5_event_bus_process_event_worker.plan.md` (briefing pipeline, voice intents, export jobs).
- Phase 1.6 offline foundation: `.cursor/plans/phase1.6_offline_sync_foundation.plan.md` (omnibar must work over cached data).
- Phase 1.7 integration gateway (weather, speech-to-text, push provider): `.cursor/plans/phase1.7_integration_gateway_scaffold.plan.md`.
- Phase 2.2 tenancy: `.cursor/plans/phase2.2_family_tenancy_model.plan.md`.
- Phase 2.3 roles: `.cursor/plans/phase2.3_role_policy_model.plan.md` (voice intents respect role limits, e.g., kids cannot create finance rows).
- Phase 2.4 RLS: `.cursor/plans/phase2.4_rls_policies.plan.md` (search must never bypass RLS; results are projected through user-scoped queries).
- Phase 2.5 privacy controls: `.cursor/plans/phase2.5_privacy_controls.plan.md` (privacy-aware projections; biometric-locked modules return placeholder hits, never sensitive content).
- Phase 3.1 `autolife-shell`: `.cursor/plans/phase3.1_autolife_shell_dashboard.plan.md` (mounts omnibar + briefings).
- Phase 3.2 `auto-calendar`, 3.3 `auto-tasks`, 3.4 `auto-assets`, 3.5 `auto-dine`, 3.6 `auto-health`, 3.7 `auto-finance`, 3.8 `auto-gallery`, 3.9 `auto-mail`, 3.10 `auto-pets`, 3.11 `auto-maintain`, 3.12 `auto-locate`: each exposes a search provider implementation.
- Phase 3.13 control center: `.cursor/plans/phase3.13_control_center_settings.plan.md` (briefing time, voice opt-in, PDF template).

## Acceptance criteria (gate)
- [ ] Typing "Apple" in the omnibar returns ranked hits from at least four modules (e.g., asset "Apple Watch", task "Fix Apple Watch", grocery "Apples", calendar event "Apple Picking") within 200ms over cached data.
- [ ] Omnibar respects privacy: items from a biometric-locked module render as "Locked - tap to unlock" without revealing content, until the gate is satisfied. (privacy-critical test)
- [ ] Search results never include rows the requesting user cannot read under phase 2.4 RLS, verified by the harness.
- [ ] Morning briefing fires at the user-configured time, contains weather, today's event count, today's task count, and any anomalies (forecast change vs. scheduled outdoor event).
- [ ] Evening briefing fires at the user-configured time and lists tomorrow's prep items plus any unfinished chores.
- [ ] Voice routing: saying "Add milk to groceries" creates a grocery item in `auto-dine` and emits `voice.intent_received` followed by `grocery.item_added`. (event-bus integration test)
- [ ] Voice intent that exceeds the user's role permission (e.g., a child creating a finance row) is rejected with a clear voice response and a logged audit row.
- [ ] PDF export of a meal plan, a grocery list, and a week calendar produces three readable PDFs in distinct templates with the family's color tokens applied.
- [ ] PDF render job writes the artifact to a private Storage path, emits `export.pdf_completed`, and the client downloads it via a signed URL with a short TTL.
- [ ] All QoL tables pass the phase 2.4 RLS harness; briefing payloads exclude content from biometric-locked modules unless the user opted in.

## Risks + mitigations
- **Risk**: Search service leaks data through cross-tenancy joins or by bypassing RLS. **Mitigation**: every provider runs queries through the user's Supabase client (not the service role) so RLS is enforced at the source; the server fallback function authenticates with the requesting JWT and includes an RLS test suite.
- **Risk**: Voice intents misfire and create unintended rows. **Mitigation**: every voice intent is classified with a confidence score; below the threshold the user gets a clarifying prompt; high-impact intents (SOS, finance) require a confirmation tap or repeat phrase configured in phase 3.13.
- **Risk**: Briefing pipeline floods users with push notifications during outages or retries. **Mitigation**: briefing runs are idempotent on `(user_id, briefing_date, slot)`; failed runs retry through the phase 1.5 DLQ rather than spawning duplicates; users can mute briefings for the day from the notification action.

## Implementation outline
1. Land `qol_tables.sql` for `briefing_runs`, `voice_intent_logs`, `pdf_exports` with phase 2.4 RLS templates.
2. Implement `packages/autolife-core` search primitives (`search_service`, `search_index`, `search_query`) and the provider interface.
3. Implement per-module search providers in `packages/autolife-core/lib/src/search/providers/` that wrap each app's read API and respect privacy projections.
4. Build the omnibar widget in `autolife-shell` with grouped, ranked results and "locked" placeholders for biometric-gated modules.
5. Implement the server-side `search` Edge Function fallback for unindexed corpora with JWT-authenticated queries.
6. Implement the `briefing-builder` Edge Function scheduled per user; integrate weather via the phase 1.7 integration gateway.
7. Build the Morning / Evening briefing screens in `autolife-shell` and the push pipeline opening into them.
8. Implement `voice_router` on device (speech-to-text) and the `voice-intent` Edge Function (classifier + dispatcher); emit intents through the event bus.
9. Implement the `voice_action_dispatcher` in `autolife-core` mapping each intent to the appropriate module command, gated by phase 2.3 role limits.
10. Implement the `pdf-render` Edge Function and a small template library (minimalist, family fridge, week planner) using shared design tokens.
11. Wire `phase3.13` settings: briefing time, voice opt-in, PDF default template; assert propagation tests.
12. Run the phase 2.4 RLS harness for QoL tables and add integration tests covering omnibar privacy, voice intent dispatch, briefing idempotency, and PDF export.

## Artifacts/links
- PR: (link once opened)
- Search service docs: `packages/autolife-core/lib/src/search/README.md`
- Voice intent schema: `packages/autolife-core/lib/src/voice/intent_schema.dart`
- PDF templates reference: `supabase/functions/pdf-render/templates/README.md`
- RLS harness output: `supabase/tests/rls/qol.test.sql`
