---
name: phase1.6_offline_sync_foundation
overview: Implement the canonical local Drift/SQLite cache, write queue schema, and conflict resolution strategy (last-writer-wins with parent-override option) for the AutoLife offline sync layer.
phase: 1.6
gate_owner: Phase 1 Gate
isProject: false
---

# Phase 1.6 - Offline Sync Foundation

## Objective
Provide the canonical offline-first data layer: a Drift-backed SQLite cache that mirrors core Supabase tables, a durable write queue that drains to Supabase when connectivity returns, and a conflict resolution strategy implementing last-writer-wins with an optional parent-override hook (Idea-Refined Part 5.6). This plan owns those semantics; later plans must reference this file rather than redefining queue schema or conflict rules.

## In scope
- Drift database living inside `packages/autolife-core` that mirrors `system_event`, `event_delivery`, `profile`, `family`, `membership`, plus a `pending_write` queue table.
- Concrete `OfflineWriteQueue` implementation backed by Drift.
- Sync engine that:
  - Reads the latest server state via Supabase (paged by `updated_at`) and upserts into Drift.
  - Drains `pending_write` rows to Supabase with retries, marking each row `succeeded`, `failed`, or `conflict`.
- Conflict resolution: default last-writer-wins by `updated_at`; override hook receives `(localRow, remoteRow, actorRole)` and returns the winner; the default override resolves parent-vs-child collisions in favor of the parent row.
- Connectivity awareness: a `ConnectivityWatcher` (wraps `connectivity_plus`) drives the engine state machine (`idle`, `syncing`, `offline`, `error`).
- Surface in Riverpod providers so apps can read sync status (`SyncStatus`) and queue depth.
- Encryption: write queue rows containing sensitive payloads are stored encrypted at rest using a key derived from the device keychain.
- Unit and integration tests for the queue lifecycle, the LWW default, the parent-override default, and an injected custom resolver.

## Out of scope
- Per-module repositories that consume the cache (each Phase 3 app declares its own).
- RLS-level conflict handling on the server (owned by phase 2.4).
- Background sync scheduling on iOS/Android (deferred to phase 3.14 QoL; this plan ships a foreground-only engine).
- Multi-device end-to-end conflict scenarios beyond the LWW + override unit tests (covered as part of phase 1.8 smoke test).

## Key deliverables
- [packages/autolife-core/lib/src/sync/autolife_database.dart](packages/autolife-core/lib/src/sync/autolife_database.dart) - Drift database class.
- [packages/autolife-core/lib/src/sync/tables/system_event_cache.dart](packages/autolife-core/lib/src/sync/tables/system_event_cache.dart).
- [packages/autolife-core/lib/src/sync/tables/event_delivery_cache.dart](packages/autolife-core/lib/src/sync/tables/event_delivery_cache.dart).
- [packages/autolife-core/lib/src/sync/tables/profile_cache.dart](packages/autolife-core/lib/src/sync/tables/profile_cache.dart).
- [packages/autolife-core/lib/src/sync/tables/family_cache.dart](packages/autolife-core/lib/src/sync/tables/family_cache.dart).
- [packages/autolife-core/lib/src/sync/tables/membership_cache.dart](packages/autolife-core/lib/src/sync/tables/membership_cache.dart).
- [packages/autolife-core/lib/src/sync/tables/pending_write.dart](packages/autolife-core/lib/src/sync/tables/pending_write.dart) - queue schema.
- [packages/autolife-core/lib/src/sync/drift_offline_write_queue.dart](packages/autolife-core/lib/src/sync/drift_offline_write_queue.dart) - `OfflineWriteQueue` impl.
- [packages/autolife-core/lib/src/sync/sync_engine.dart](packages/autolife-core/lib/src/sync/sync_engine.dart) - state machine.
- [packages/autolife-core/lib/src/sync/conflict_resolver.dart](packages/autolife-core/lib/src/sync/conflict_resolver.dart) - LWW + parent-override defaults plus injection point.
- [packages/autolife-core/lib/src/sync/connectivity_watcher.dart](packages/autolife-core/lib/src/sync/connectivity_watcher.dart).
- [packages/autolife-core/test/sync/](packages/autolife-core/test/sync/) - unit + integration tests.
- [docs/offline-sync-contract.md](docs/offline-sync-contract.md) - written contract for queue schema, conflict rules, encryption, and engine states.

## Dependencies
- [.cursor/plans/phase1.2_autolife_core_contracts.plan.md](.cursor/plans/phase1.2_autolife_core_contracts.plan.md) - `OfflineWriteQueue` interface and model classes.
- [.cursor/plans/phase1.4_supabase_baseline.plan.md](.cursor/plans/phase1.4_supabase_baseline.plan.md) - server tables to mirror and target for queue drains.
- [.cursor/plans/phase1.5_event_bus_process_event_worker.plan.md](.cursor/plans/phase1.5_event_bus_process_event_worker.plan.md) - reuses producer/consumer contract when queued writes are events.

## Acceptance criteria (gate)
- [ ] `pending_write` schema includes `id`, `tenant_id`, `actor_id`, `target_table`, `operation` (insert/update/delete), `payload` (encrypted), `idempotency_key`, `attempt`, `status` (pending/succeeded/failed/conflict), `last_error`, `created_at`, `next_attempt_at`.
- [ ] Inserting the same logical write twice with the same `(tenant_id, idempotency_key)` is a no-op on the queue (unit test).
- [ ] When two cached rows diverge, the default resolver picks the higher `updated_at` and the parent-override resolver picks the row whose `actor_role` is `parent` (both unit-tested).
- [ ] A custom resolver can be injected via constructor and is invoked for every conflict (unit test).
- [ ] Encryption-at-rest test verifies payload bytes are unreadable on disk without the device-keychain key.
- [ ] Sync engine transitions through `offline -> syncing -> idle` when connectivity returns and drains queued writes in FIFO within the same `target_table`.
- [ ] `docs/offline-sync-contract.md` documents the schema, conflict rules, encryption, and engine states; every later plan that touches sync references this doc.
- [ ] `apps/autolife-shell` can read the sync status from a Riverpod provider exposed by this package without re-implementing it.

## Risks + mitigations
- **Risk**: Encryption key loss locks users out of queued data. / **Mitigation**: Store a wrapped copy of the data-encryption key in Supabase (server-side, protected by RLS) so a fresh device can re-derive after auth; document recovery in the contract doc.
- **Risk**: Schema drift between Drift cache tables and Supabase tables. / **Mitigation**: Generate Drift table definitions from a shared schema descriptor used by `packages/autolife-core` models; add a CI test that asserts column-set parity with the Supabase migrations.
- **Risk**: LWW silently overwrites legitimate concurrent edits. / **Mitigation**: Always emit a `conflict_detected` SystemEvent (consumed by Phase 3.13 settings) when the resolver had to pick a winner, so users can audit and override.

## Implementation outline
1. Author `docs/offline-sync-contract.md` covering schema, conflict rules, encryption, and engine states before writing code.
2. Add Drift + `connectivity_plus` + `flutter_secure_storage` dependencies to `packages/autolife-core` pubspec.
3. Implement the cache tables one-to-one with the Supabase baseline migrations and the queue table.
4. Implement `DriftOfflineWriteQueue` as the concrete `OfflineWriteQueue` from phase 1.2.
5. Implement `ConflictResolver` with `LastWriterWinsResolver` and `ParentOverrideResolver` and an injection seam.
6. Implement `ConnectivityWatcher` and the `SyncEngine` state machine.
7. Wire payload encryption using a key derived from `flutter_secure_storage`, with a wrapped backup uploaded to Supabase.
8. Emit `conflict_detected` events through the producer from phase 1.5 whenever the resolver fires.
9. Write unit tests for queue lifecycle, LWW, parent override, custom resolver injection, encryption-at-rest, and engine state transitions.
10. Add an integration test that runs the full engine against a local Supabase stack and asserts a queued write lands server-side.

## Artifacts/links
- PR: (tbd)
- Migration: (tbd)
- Test report: (tbd)
