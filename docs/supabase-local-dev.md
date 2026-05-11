# Supabase local development

This project keeps the database, storage buckets, and Edge Function scaffolds under `supabase/`. A typical contributor flow stays under **10 minutes** once Docker and the Supabase CLI are installed.

## Prerequisites

- [Docker Desktop](https://docs.docker.com/desktop/) (or another engine compatible with the Supabase CLI).
- [Supabase CLI](https://supabase.com/docs/guides/cli) v1.200+ (CI uses `supabase/setup-cli`).
- Optional: [Deno](https://deno.com/) v2 for running Edge Function unit tests (`deno test` in each function folder).

## 1. Install the CLI

Follow the [official install steps](https://supabase.com/docs/guides/cli/getting-started) for your OS. Verify:

```bash
supabase --version
```

## 2. Start the stack

From the **repository root** (the directory that contains `supabase/config.toml`):

```bash
supabase start
```

The first run pulls images and can take a few minutes. When it finishes, the CLI prints local URLs and keys (API URL, `anon` key, `service_role` key). Use those values in `.env` for apps and Edge Functions (see `.env.example`).

## 3. Apply migrations and seed data

Reset the database to a clean state, apply all SQL in `supabase/migrations/`, then load `supabase/seed.sql`:

```bash
supabase db reset
```

From the monorepo you can also run:

```bash
dart run melos run supabase:reset
```

After a reset you should see:

- Tables `system_event`, `event_delivery`, `profile`, `family`, `membership`.
- Storage buckets `avatars`, `receipts`, `documents`, `family-assets`.
- Seed rows: one demo family and two profiles with memberships.

## 4. Lint migrations

```bash
supabase db lint
```

This should report **no errors** for committed migrations.

## 5. Edge Functions

Serve functions locally (hot reload uses `[edge_runtime]` in `config.toml`):

```bash
supabase functions serve process-event
```

In another terminal, POST to the local functions URL shown by the CLI (port may vary):

```bash
curl -s -o /dev/null -w "%{http_code}" -X POST "http://127.0.0.1:54321/functions/v1/process-event"
```

Expect **501** for the `process-event` scaffold.

For `bootstrap`:

```bash
supabase functions serve bootstrap
curl -s "http://127.0.0.1:54321/functions/v1/bootstrap"
```

Expect **200** and a JSON body with `user` / `tenant` (may be `null` without a JWT).

Integration tests for `process-event` need a running stack plus env (see `docs/event-bus-contract.md`):

```bash
eval "$(supabase status -o env)"
export SUPABASE_URL="$API_URL"
export SUPABASE_SERVICE_ROLE_KEY="$SERVICE_ROLE_KEY"
export SUPABASE_DB_DIRECT_URL="$DB_URL"
(cd supabase/functions/process-event && deno test --allow-env --allow-net)
```

Bootstrap smoke tests (no network):

```bash
(cd supabase/functions/bootstrap && deno test)
```

## 6. Stop

```bash
supabase stop
```

## Troubleshooting

- **`supabase start` fails**: ensure Docker is running and ports `54321`–`54329` (see `config.toml`) are free.
- **Stale volumes**: `supabase stop --no-backup` then `supabase start` if the DB is corrupted during experiments.
- **Linked remote project**: use `supabase link` and keep `[db].major_version` aligned with the hosted instance.
