---
name: phase1.5_event_bus_process_event_worker
overview: Implement the canonical producer/consumer contracts, retry policy, dead-letter semantics, idempotency keys, and ordering guarantees of the AutoLife system event bus inside the process-event Edge Function.
phase: 1.5
gate_owner: Phase 1 Gate
isProject: false
---

# Phase 1.5 - Event Bus + process-event Worker

## Objective
Turn the Supabase baseline tables and Edge Function scaffold into a working event bus owned by `supabase/functions/process-event/`. This plan is the canonical source for producer/consumer contracts, retry/backoff policy, dead-letter handling, idempotency-key semantics, and ordering guarantees. Later plans (Phase 3 apps, integration gateway, automations) must reference this file rather than re-specifying those semantics.

## In scope
- Concrete `EventProducer` implementation in `packages/autolife-core` backed by a Supabase insert into `system_event`.
- `process-event` Edge Function logic: pull next ready event, fan out to registered consumers, record per-consumer `event_delivery` rows.
- Retry policy: exponential backoff with jitter, max 5 attempts per consumer; after the cap the delivery row moves to `dead_letter` status.
- Idempotency: insertion of `system_event` uses the producer-supplied `idempotency_key`; duplicate keys per `(tenant_id, idempotency_key)` are accepted with a 200 and ignored.
- Ordering: deliveries for a single `ordering_tag` (e.g., `tenant_id:aggregate_id`) are processed in `occurred_at` order; the worker takes an advisory lock per tag to enforce this.
- DLQ surface: `dead_letter_event` view plus a Supabase Realtime channel that ops dashboards can subscribe to.
- Consumer registry: a static map in the function listing module-name -> consumer handler; every Phase 3 app registers one handler here.
- Trigger: a Postgres `AFTER INSERT` trigger on `system_event` invoking the function via `pg_net` so producers do not need to call the function directly.
- Integration tests covering happy-path, retry-then-success, retry-then-DLQ, idempotent re-insertion, and ordering across two tags.

## Out of scope
- App-specific consumer logic (each Phase 3 plan adds its own consumer to the registry).
- Offline write queue runtime (owned by [phase 1.6](.cursor/plans/phase1.6_offline_sync_foundation.plan.md)).
- External integrations such as Google Calendar or OCR (owned by phase 1.7).
- Audit/replay tooling beyond the dead-letter view (deferred to phase 2.6).

## Key deliverables
- [supabase/functions/process-event/index.ts](supabase/functions/process-event/index.ts) - worker entrypoint.
- [supabase/functions/process-event/registry.ts](supabase/functions/process-event/registry.ts) - consumer registry.
- [supabase/functions/process-event/retry.ts](supabase/functions/process-event/retry.ts) - backoff + jitter logic.
- [supabase/functions/process-event/locks.ts](supabase/functions/process-event/locks.ts) - per-`ordering_tag` advisory locking helpers.
- [supabase/functions/process-event/types.ts](supabase/functions/process-event/types.ts) - TypeScript mirrors of the Dart event models from `packages/autolife-core`.
- [supabase/functions/process-event/__tests__/](supabase/functions/process-event/__tests__/) - Deno integration tests.
- [supabase/migrations/0010_event_bus_triggers.sql](supabase/migrations/0010_event_bus_triggers.sql) - trigger on `system_event`, `dead_letter_event` view, indexes for `(status, next_attempt_at)`.
- [packages/autolife-core/lib/src/services/supabase_event_producer.dart](packages/autolife-core/lib/src/services/supabase_event_producer.dart) - concrete producer.
- [packages/autolife-core/test/services/supabase_event_producer_test.dart](packages/autolife-core/test/services/supabase_event_producer_test.dart).
- [docs/event-bus-contract.md](docs/event-bus-contract.md) - human-readable spec of producer/consumer contract, retry policy, DLQ, idempotency, ordering (linked from this plan).

## Dependencies
- [.cursor/plans/phase1.2_autolife_core_contracts.plan.md](.cursor/plans/phase1.2_autolife_core_contracts.plan.md) - Dart models and producer/consumer interfaces.
- [.cursor/plans/phase1.4_supabase_baseline.plan.md](.cursor/plans/phase1.4_supabase_baseline.plan.md) - `system_event`, `event_delivery`, and `process-event` scaffold must already exist.

## Acceptance criteria (gate)
- [ ] Producing the same `SystemEvent` twice with the same `(tenant_id, idempotency_key)` results in exactly one persisted row and one set of deliveries.
- [ ] A consumer that fails 4 times then succeeds yields a single `event_delivery` row in `status='succeeded'` with `attempt=5` and exponentially increasing `next_attempt_at` gaps (verified by integration test).
- [ ] A consumer that fails 5 times moves its delivery to `status='dead_letter'` and emits a Realtime notification on the `dead_letter_event` channel.
- [ ] Two events with the same `ordering_tag` are processed in `occurred_at` order even when invoked concurrently (advisory-lock test passes).
- [ ] The `AFTER INSERT` trigger on `system_event` enqueues processing without the producer calling the function directly.
- [ ] `docs/event-bus-contract.md` documents the producer interface, consumer interface, retry policy with the exact backoff formula, DLQ behavior, idempotency rules, and ordering guarantees.
- [ ] Deno tests cover happy-path, retry-success, retry-DLQ, idempotent-duplicate, and ordering scenarios; all green in CI.
- [ ] No Phase 3 plan re-defines retry, DLQ, idempotency, or ordering semantics; all such plans link to this file in their Dependencies section.

## Risks + mitigations
- **Risk**: `pg_net`-triggered invocations dropping under load and stalling delivery. / **Mitigation**: Run a Supabase Scheduled Function every minute that scans for `event_delivery` rows with `status='pending'` and `next_attempt_at <= now()` as a safety net; document in the contract.
- **Risk**: Advisory-lock contention under bursty traffic hurting latency. / **Mitigation**: Scope locks to `ordering_tag` (not global), use `pg_try_advisory_xact_lock`, and emit a metric for lock-wait time so we can iterate.
- **Risk**: Consumer registry becomes a merge-conflict hotspot as more apps land. / **Mitigation**: Use one file per consumer registered via a generator script, then concatenate into `registry.ts`; document the convention in `docs/event-bus-contract.md`.

## Implementation outline
1. Author `docs/event-bus-contract.md` first so producer/consumer contracts are written down before code lands.
2. Add migration `0010_event_bus_triggers.sql` for the `AFTER INSERT` trigger, `dead_letter_event` view, and required indexes.
3. Implement `SupabaseEventProducer` in `packages/autolife-core` with idempotency-key handling.
4. Implement `retry.ts` (backoff + jitter) and `locks.ts` (advisory locking) as pure modules with unit tests.
5. Implement `registry.ts` shape (empty registry day one; Phase 3 apps add entries).
6. Wire `index.ts`: dequeue, lock per `ordering_tag`, fan out to consumers, record `event_delivery`, schedule next attempt or move to DLQ.
7. Add the safety-net scheduled function for stalled `pending` rows.
8. Write Deno integration tests covering all five scenarios in Acceptance Criteria.
9. Add Realtime publication for `dead_letter_event` and document subscription in the contract doc.
10. Run end-to-end test from a Flutter test using the real `SupabaseEventProducer` against a local Supabase stack.

## Artifacts/links
- PR: (tbd)
- Migration: (tbd)
- Test report: (tbd)
