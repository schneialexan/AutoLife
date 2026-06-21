# platform/supabase

Supabase project definition for the AutoLife sync platform: SQL migrations, the
`pair-device` Edge Function, and local-dev config. See
[`docs/sync-architecture.md`](../../docs/sync-architecture.md) for the full design.

## Layout

```
supabase/
├── config.toml                 # local CLI config (exposes the `assets` schema)
├── migrations/
│   ├── 0001_profiles_and_pairing.sql
│   ├── 0002_assets_schema.sql      # assets.items / category_types + trigger + RLS
│   ├── 0003_storage_bucket.sql     # private user-files bucket + storage RLS
│   ├── 0004_tombstone_cleanup.sql  # retention job (pg_cron when available)
│   └── 0005_expose_assets_schema.sql # exposes `assets` to PostgREST (fixes 406)
└── functions/
    └── pair-device/                # service-role device-linking function
```

## Local development

Requires the [Supabase CLI](https://supabase.com/docs/guides/cli).

```sh
cd platform/supabase
supabase start          # boots local Postgres + Auth + Storage + Studio
supabase db reset       # applies ./migrations to the local DB
supabase functions serve pair-device   # run the Edge Function locally
```

`supabase start` prints a local `API URL` and `anon key`. Point the app at them:

```sh
cd ../../apps/assets
flutter run \
  --dart-define=SUPABASE_URL=http://127.0.0.1:54321 \
  --dart-define=SUPABASE_ANON_KEY=<local anon key>
```

## Edge Function secrets

`pair-device` needs the service-role key, injected by the platform as
`SUPABASE_SERVICE_ROLE_KEY` (provided automatically for local `functions serve`).
For a hosted project:

```sh
supabase secrets set SUPABASE_SERVICE_ROLE_KEY=<service-role key>
supabase functions deploy pair-device
```

**Never** ship the service-role key in the Flutter client — it lives only here.

## Deploying to a hosted project

```sh
supabase link --project-ref <ref>
supabase db push                 # apply migrations
supabase functions deploy pair-device
```

Migration `0005_expose_assets_schema.sql` pins the `assets` schema into the
`authenticator` role's `pgrst.db_schemas`, so `supabase db push` exposes it to
PostgREST automatically — no manual dashboard toggle required. If you ever see
HTTP 406 / `PGRST106` ("The schema must be one of the following…") on
`assets.*`, the schema isn't exposed; re-run the migration or apply it directly
in the SQL editor:

```sql
alter role authenticator
  set pgrst.db_schemas = 'public, graphql_public, storage, assets';
notify pgrst, 'reload config';
notify pgrst, 'reload schema';
```
