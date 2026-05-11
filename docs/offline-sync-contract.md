# Offline sync contract (AutoLife)

This document is the canonical reference for the Phase 1.6 offline sync foundation. Later plans that mention queues, conflicts, encryption, or engine state should link here instead of redefining behavior.

## Scope

- Local Drift/SQLite cache mirroring core Supabase tables: `system_event`, `event_delivery`, `profile`, `family`, `membership`.
- Durable `pending_write` queue drained when connectivity returns (foreground engine only in Phase 1.6).
- Last-writer-wins (LWW) conflict resolution with an optional override hook (default: parent wins over child when roles differ).

Out of scope for Phase 1.6: RLS policies (Phase 2.4), background sync scheduling (Phase 3.14), per-feature repositories (Phase 3).

## `pending_write` schema (Drift / local SQLite)

| Column             | Type        | Notes |
|--------------------|------------|-------|
| `id`               | integer PK | Auto-increment row id (queue order within a device). |
| `tenant_id`        | text       | Tenant scope for the mutation. |
| `actor_id`         | text       | Profile / actor performing the write. |
| `target_table`     | text       | Destination PostgREST table (e.g. `profile`). |
| `operation`        | text       | One of `insert`, `update`, `delete`. |
| `payload`          | blob       | **Encrypted** JSON payload for the operation (application plaintext is never stored raw on disk). |
| `idempotency_key`  | text       | Dedupes logical writes with the same `(tenant_id, idempotency_key)`. |
| `attempt`          | integer    | Retry count for PostgREST / network failures. |
| `status`           | text       | `pending`, `succeeded`, `failed`, or `conflict`. |
| `last_error`       | text?      | Last failure message when applicable. |
| `created_at`       | datetime   | Enqueue time (UTC). |
| `next_attempt_at`  | datetime?  | Scheduled retry time; null means “as soon as possible”. |

**Unique constraint:** `(tenant_id, idempotency_key)` — inserting the same logical write again is a no-op when a row already exists (any status).

## Conflict resolution

1. **Default (LWW):** When comparing a local cached row and a remote row for the same primary key, the row with the greater `updated_at` wins. Ties are broken deterministically (remote wins on equal timestamps).
2. **Parent override:** Alternative default policy favors the row whose `actor_role` is `parent` when roles differ. This is used for parent-vs-child collision semantics; product roles in Postgres may still use `membership_role` — the resolver receives a string `actor_role` derived from domain context (tests use `parent` / `child` literals).
3. **Custom resolver:** Applications may inject a `ConflictResolver` that receives both rows and the acting role; it is invoked when the engine detects divergent `updated_at` for the same entity key. When a resolver **chooses** a winner (true conflict), the sync layer emits a `conflict_detected` `SystemEvent` (module `sync`) so clients can audit or prompt (Phase 3.13 settings).

## Encryption at rest (queue payloads)

- A data-encryption key (DEK) is derived from random material stored in the device keychain via `flutter_secure_storage`.
- Queue `payload` blobs are AES-256-GCM ciphertext (nonce + MAC + ciphertext concatenated in a single blob layout defined by `PayloadCipher`).
- **Recovery / multi-device:** If the DEK is lost, queued ciphertext cannot be decrypted locally. Mitigation for production: store a server-side wrapped copy of the DEK (envelope-encrypted to the authenticated user, protected by RLS) so a new device can unwrap after sign-in. The concrete table and RPC for that live outside Phase 1.6; consumers should treat key backup as a product requirement for multi-device recovery.

## Sync engine states

| State      | Meaning |
|------------|---------|
| `idle`     | Connected (or unspecified); no sync work running. |
| `syncing`  | Pull and/or queue drain in progress. |
| `offline`  | No suitable network connectivity. |
| `error`    | Unrecoverable engine failure until reset or retry. |

**Typical transition when connectivity returns:** `offline` → `syncing` → `idle` (or `error` if flush fails consistently).

## Server pagination & `updated_at`

Incremental pulls page by `updated_at` (and tie-break on primary key). Baseline migrations add `updated_at` to mirrored tables where missing so PostgREST filters align with the Drift cache.

## FIFO drain ordering

Pending writes are applied in FIFO order **per `target_table`** — rows with the same table name are ordered by `created_at` ascending; the engine may process multiple tables in one sync pass but never reorders writes for a single table.

## Riverpod surface

Apps obtain read-only `SyncStatus` (state + queue depth + optional last error) from providers exported by `autolife_core` — apps must not duplicate this wiring.
