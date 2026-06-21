# Supabase integration tests (manual)

These checks exercise behavior that needs a **live** Postgres/Auth stack, so they
run against a local Supabase rather than in the Flutter CI matrix (which is
network-isolated). Run them after `supabase start` + `supabase db reset`.

## RLS isolation

Verifies that one user cannot read or write another user's rows.

```sh
cd platform/supabase
supabase start
supabase db reset
# Run the assertions (uses the local DB connection string from `supabase status`):
psql "$(supabase status -o env | grep DB_URL | cut -d= -f2- | tr -d '"')" \
  -v ON_ERROR_STOP=1 -f tests/rls_isolation.sql
```

Expected: the script prints `RLS ISOLATION: PASS` and exits 0. A leak makes an
assertion fail and the script exits non-zero.

## Pairing Edge Function

Verifies expired / used / wrong codes are rejected. Run with the function served
locally:

```sh
supabase functions serve pair-device &
# 1. As an authenticated user, start pairing -> returns { code, expires_at }
# 2. complete with a WRONG code           -> 400 pairing_invalid
# 3. complete with the right code         -> { email, token }
# 4. complete again with the same code    -> 400 pairing_invalid (single-use)
```

A scripted version can be added with the Supabase CLI's `functions` test harness;
the assertions above are the contract.

## Migration round-trip

The standalone↔AutoLife sign-in migration is covered at the unit level in
`apps/assets/test/vault_migration_test.dart` (export/import bundle) and by the
gateway pull/apply tests (`assets_sync_gateway_test.dart`). End-to-end, signing in
on a second app pulls `assets.*` into local Hive via the same gateway.
