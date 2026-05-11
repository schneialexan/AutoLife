# Phase 1.8 manual smoke (end-to-end)

This procedure mirrors `apps/autolife-shell/integration_test/phase1_smoke_test.dart`. Use a **local Supabase** stack (`supabase start`, `supabase db reset`) and a **service role key** (RLS stays closed in phase 1.x, so the anon key will not insert into `system_event`).

## One-time setup

1. Start the stack and apply migrations. Run:

   `supabase db reset`
2. Note `API URL` and **service_role** from `supabase status` (or `supabase status -o env`).

## Run the automated integration test

From the repo root, with a running local stack (`supabase start` / `supabase db reset`):

```bash
cd apps/autolife-shell
flutter test integration_test/phase1_smoke_test.dart -d linux \
  --dart-define=SUPABASE_URL="<API URL from supabase status>" \
  --dart-define=SUPABASE_SERVICE_ROLE_KEY="<service_role JWT from supabase status>" \
  --dart-define=AUTOLIFE_SMOKE_INTEGRATION_TEST=true
```

`AUTOLIFE_SMOKE_INTEGRATION_TEST=true` enables `SmokeTestHarness` so the test can flip offline/online without relying on the host network.

## Run the shell interactively

```bash
cd apps/autolife-shell
flutter run -d linux \
  --dart-define=SUPABASE_URL="http://127.0.0.1:54321" \
  --dart-define=SUPABASE_SERVICE_ROLE_KEY="<service_role_jwt_from_supabase_status>"
```

Adjust host/port if your CLI prints different values.

## In the app

1. Wait for startup; the **mock** connector should move to **connected** after a successful `healthcheck` (connect runs first on boot when Supabase defines are set).
2. Open the **Smoke** tab (debug builds only, when `SUPABASE_URL` / key defines are present).
3. **Online:** enter a title (e.g. `manual-online`) and tap **Add Event**.

   - Expect snackbar “Event queued or published”.
   - Within a couple of seconds, the **Today** list should show the title (Drift cache fed by sync).
   - In SQL: one `system_event` row, one `event_delivery` row for consumer `dashboard` with `status = succeeded`.
4. **Offline (optional):** run with a harness that toggles connectivity, or simulate by turning off the machine network and using the same screen; expect `pending_write` to drain after going back online (see integration test for the exact toggle API).

## Log cues (Edge Function / Postgres)

- Successful worker dispatch returns JSON like `{"ok":true,"drained":true}` from `POST /functions/v1/process-event` with body `{"event_id":"<uuid>"}`.
- If `pg_net` fails to reach Kong locally, check `raise warning` in Postgres logs for `enqueue_process_event_via_net`.

## PR grep check (theme)

Smoke UI should use the design system, not raw insets or hard-coded colors. Example checks from the repo root:

```bash
rg "EdgeInsets\\." apps/autolife-shell/lib/src/screens/smoke
rg "Color\\(0x" apps/autolife-shell/lib/src/screens/smoke
```

There should be no raw `Color(0x…)` literals; prefer `AutoLifeSpacing` / `context.autoLifeTokens` and theme colors.

## Screenshots

Capture the **Smoke** tab with **Today** showing at least one note after a successful add (optional for PR description).
