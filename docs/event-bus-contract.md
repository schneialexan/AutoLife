# AutoLife event bus contract (Phase 1.5)

This document is the human-readable source of truth for producer/consumer contracts, retry and dead-letter behavior, idempotency, ordering, and operational hooks. Feature plans should link here instead of re-stating these rules.

## Tables

- `system_event` — canonical append-only event log (unique on `(tenant_id, idempotency_key)`).
- `event_delivery` — one row per `(event_id, consumer)` with attempt counters and scheduling metadata.
- `ordering_tag_lease` — short TTL lease rows used to serialize concurrent `process-event` workers per `ordering_tag`.

## Producer (`EventProducer` / `SupabaseEventProducer`)

- **Insert path**: `SupabaseEventProducer.publish` performs `INSERT ... SELECT` into `system_event` using the JSON shape of `SystemEvent` (snake_case keys).
- **Idempotency**: Duplicate `(tenant_id, idempotency_key)` posts surface as `PostgrestException` with Postgres code `23505` (or a duplicate-key message). The producer treats that as success and **re-selects** the existing row. Callers always receive `Result.success` with the **same** persisted event `id` as the first insert.
- **Trigger path**: An `AFTER INSERT` trigger on `system_event` calls `pg_net` to `POST /functions/v1/process-event` with body `{"event_id":"<uuid>"}`. Producers do not need to invoke the worker directly.
- **Ordering field**: Every event must include a stable `ordering_tag` (for example `tenant_id:aggregate_id`). The worker drains work **in `occurred_at` order** for a given tag and will not start a later event while an earlier one still has in-flight or scheduled deliveries.

## Consumer registry (`process-event`)

- Consumers are registered in `supabase/functions/process-event/registry.ts` as `Map<consumerId, handler>`.
- Phase 3 modules add one entry each. The worker **upserts** `event_delivery` rows for every registered consumer when an event is first processed.
- **Handler contract**: `async (ctx) => void` where `ctx.client` is a service-role Supabase client and `ctx.event` mirrors `SystemEventRow` (`types.ts`).

## Worker behavior (`process-event`)

1. **Lease**: `try_acquire_ordering_tag_lease(ordering_tag, lock_uuid)` must return true before draining a tag. If another worker holds the lease, the HTTP handler returns **202** `{ deferred: true }`.
2. **Drain loop**: While work exists for the tag, pick the earliest `system_event` that is not fully terminal and run all **due** deliveries for that event.
3. **Due delivery**: `status` is `pending`, and `next_attempt_at` is null or `<= now`.
4. **Parallelism**: Deliveries for the **same** event may run concurrently; ordering is enforced **across events** sharing a tag, not across consumers of one event.
5. **Success**: `status = succeeded`, `attempt` becomes `previous_attempt + 1`, `last_error` cleared, `next_attempt_at` null.
6. **Failure with retry**: After the *k*th failed completed try (`attempt` after increment is *k*), schedule:
   \[
   \Delta_k = \min(\tau_{\max}, \tau_0 \cdot 2^{k-1}) \cdot (1 + U)
   \]
   where \(\tau_0 = 200\text{ ms}\), \(\tau_{\max} = 5\text{ min}\), and \(U \sim \mathrm{Uniform}[-0.25, +0.25]\).
   `next_attempt_at = now + \Delta_k`, `status` remains `pending`, `last_error` records the message.
7. **Dead letter**: After **five** failed completed tries (final `attempt = 5`, `status = dead_letter`), no further retries are scheduled. A best-effort Realtime **broadcast** is emitted on channel `dead_letter_event` with event `dead_letter_delivery` and a small JSON payload (delivery id, event id, consumer, tenant id).
8. **Stalled work safety net**: `pg_cron` invokes `enqueue_event_bus_sweep_via_net` every minute, which posts `{"scan_stalled":true}` to the same function. The worker scans `event_delivery` rows in `pending` state whose `next_attempt_at` is null or in the past and drains their tags.

## DLQ surface

- View: `dead_letter_event` (joins `event_delivery` + `system_event` for `dead_letter` rows).
- Realtime: subscribe to **broadcast** channel `dead_letter_event` (or watch `event_delivery` via Postgres changes if your client prefers row-level feeds). `event_delivery` is added to `supabase_realtime` publication with `REPLICA IDENTITY FULL` to support filtered consumers.

## HTTP API (`process-event`)

- `POST { "event_id": "<uuid>" }` — process/drain for the hinted event’s `ordering_tag`.
- `POST { "scan_stalled": true }` — safety-net sweep for all due pending deliveries.
- Responses: `200` processed, `202` deferred (lease busy), `400` bad body, `404` missing event, `500` internal.

## Testing expectations

- Deno tests in `supabase/functions/process-event/` cover happy path, retry→success, retry→DLQ, idempotent SQL constraint, ordering under concurrency, and stalled scan.
- Dart integration test `test/services/supabase_event_producer_integration_test.dart` validates producer idempotency against a live local stack (skipped when env vars are absent).

## Configuration overrides

- `ALTER DATABASE postgres SET app.edge_process_event_base_url = 'https://…';` — when Postgres cannot reach the default `http://kong:8000` (self-hosted networking).
- `ALTER DATABASE postgres SET app.supabase_functions_secret = '…';` — optional explicit bearer secret for `pg_net` calls (otherwise the migration falls back to the documented local demo service role JWT for development only).
