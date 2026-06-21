# platform/

Cross-cutting surfaces that aren't standalone apps. Designed **after** several apps exist,
because they only make sense once there are modules to govern.

## supabase/ — backend & data layer (D2 = Supabase, decided)

The backend half of D2 is now built. [`supabase/`](supabase) holds everything the
Supabase project needs:

- [`migrations/`](supabase/migrations) — `profiles`, `device_pairing_codes`, the
  `assets.*` module tables (`payload jsonb` + `schema_version` + DB-assigned
  `server_updated_at` trigger), RLS on every table, indexes, the private
  `user-files` Storage bucket, and the tombstone-cleanup job.
- [`functions/pair-device/`](supabase/functions/pair-device) — the service-role
  Edge Function for optional device linking (validates a hashed single-use code,
  mints a one-time OTP). The service-role key never reaches the client.
- [`config.toml`](supabase/config.toml) — local Supabase CLI dev (exposes the
  `assets` schema to PostgREST).

The Dart side of the platform lives in
[`packages/autolife_platform`](../packages/autolife_platform).

### The gateway pattern (how modules sync)

Each app keeps **local-first Hive storage** and stays fully usable offline. When
the user opts in (sign-in or pairing), the app's `ModuleSyncGateway` mirrors its
records to the module's Supabase tables. The shared `SyncCoordinator` drives
push (encrypted outbox → remote) then pull (remote → Hive, last-write-wins on a
server-assigned cursor). Adding a new module = new tables + one gateway; no core
changes.

### Migration model (shared project)

Standalone AutoAssets and the AutoLife shell are clients of **one** Supabase
project / identity / `assets.*` tables, so moving between apps is just signing
in. Offline-only users can instead move data via the cloud-independent
export/import bundle. Full design: [`docs/sync-architecture.md`](../docs/sync-architecture.md).

## Still planned (not built yet)

See [`docs/app-catalog.md`](../docs/app-catalog.md) and
[`Idea-Refined`](../docs/idea-refined.md) Part 5:

- **Control Center** — role/permission matrix, approval engine, privacy tiers, AI "leash"
  levels, nag-mode tuning, notification batching, integration manager,
  "Download My Life" export.
- **Integration gateway** — external connectors (calendars, maps, stores, OCR/AI) behind
  swappable interfaces.
