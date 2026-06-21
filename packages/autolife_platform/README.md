# autolife_platform

Shared **offline-first sync platform** for AutoLife apps. Local Hive storage stays
the UI source of truth in every app; when the user opts in (account sign-in or
device pairing), registered per-module gateways mirror the same records to
Supabase Postgres + Storage.

Full design: [`docs/sync-architecture.md`](../../docs/sync-architecture.md).

## Public surface

| Type | Role |
|------|------|
| `AutolifePlatform` | Entry point: `initialize()`, `registerGateway()`. Runs local-only when no Supabase config is supplied. |
| `AuthService` | Email/password sign-in (primary) + optional device pairing. |
| `SyncCoordinator` | Push outbox → pull remote across all gateways; owns cursors + `SyncStatus`. |
| `OutboxStore` | Encrypted, coalescing queue of local edits. |
| `ModuleSyncGateway` | The expandable seam each module implements. |
| `RemoteModuleTable` / `SupabaseModuleTable` | Per-table remote access (testable via a fake). |
| `BlobSyncService` | Upload/download file paths embedded in payloads. |
| `SyncMutation` / `SyncCursor` / `SyncStatus` | Core value types. |

Riverpod: `autolifePlatformProvider` (override in `main`), `authStateProvider`,
`syncStatusProvider`.

## Usage

```dart
final platform = await AutolifePlatform.initialize(
  supabaseUrl: '...',      // empty => local-only, no network
  supabaseAnonKey: '...',
);
platform.registerGateway(MyModuleGateway(...));
```

Hive must already be initialized (`Hive.initFlutter()`) before `initialize()`.

## Design notes

- **Server-time cursor.** Pull pages on a DB-assigned `server_updated_at`, never
  the client clock — skew-proof.
- **Last-write-wins** on the model `updated_at`.
- **Idempotent upserts.** The record id is the idempotency key, so retries are safe.
- **Encrypted outbox.** AES key in `flutter_secure_storage`.
- **No service-role key on the client.** Device pairing goes through the
  `pair-device` Edge Function.

## Tests

```sh
flutter test
```

Unit tests cover mutation/cursor JSON round-trips and outbox coalescing/removal.
Supabase-touching code is behind interfaces so it isn't exercised in unit tests.
