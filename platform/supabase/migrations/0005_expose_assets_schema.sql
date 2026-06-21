-- Expose the custom `assets` schema to PostgREST on hosted projects.
--
-- Local dev gets this from config.toml (`[api].schemas`), but a hosted project
-- only exposes a schema when it is present in the `authenticator` role's
-- `pgrst.db_schemas` setting. When `assets` is missing there, every write to
-- `assets.*` fails with HTTP 406 / PGRST106 ("The schema must be one of the
-- following: ...") even though sign-in and Storage uploads work — which is
-- exactly the "sorry something went wrong" backup/sync failure.
--
-- Pinning the list here makes the exposure reproducible via `supabase db push`
-- instead of relying on the dashboard's "Exposed schemas" toggle (which can
-- silently drift out of sync with this role setting). Keep `public`,
-- `graphql_public`, and `storage` so existing APIs keep working.
alter role authenticator
  set pgrst.db_schemas = 'public, graphql_public, storage, assets';

-- Ask PostgREST to pick up the new config + reload its schema cache immediately,
-- so the change takes effect without waiting for a restart.
notify pgrst, 'reload config';
notify pgrst, 'reload schema';
