# Secret management (Phase 2.6)

This document is the **single convention** for secrets across AutoLife: local development, CI, hosted Supabase, and Vault-backed storage.

## Principles

1. **Never commit secret material.** Use placeholders in examples and synthetic values in tests.
2. **Publishable keys in clients only.** `AUTOLIFE_SUPABASE_ANON_KEY` (or legacy anon) is allowed in app builds; **service role** is server-only.
3. **Vault for long-lived tokens at rest.** Integration connector bundles use Supabase Vault — see `0020_connector_credentials.sql`.
4. **Supabase CLI `secrets` for runtime env** injected into Edge Functions and hosted workers (never checked into git).

## Local development

| Mechanism | Use |
| --- | --- |
| **`.env`** (gitignored manually; not committed) | Paste local `SUPABASE_URL`, keys, OAuth test secrets |
| **[`.env.example`](../../.env.example)** | Committed manifest of required keys + placeholder values |
| **dotenv / `--dart-define`** | Flutter integration tests use `--dart-define` in CI — mirror names from `.env.example` |

Copy `.env.example` → `.env` and fill from `supabase status` after `supabase start`.

## Hosted Supabase

| Surface | Command / UI |
| --- | --- |
| Edge Function env | `supabase secrets set KEY=value` (per project) |
| Auth external providers | `supabase/config.toml` uses `env(VAR)`; set vars in hosted dashboard or CI deploy pipeline |
| Database direct URL | CI only; never in mobile apps |

## Vault

- Extension: `supabase_vault` (enabled in baseline migrations; reinforced in `20260512000500_secrets_baseline.sql`).
- Application code stores **references** (`vault_secret_id`), not raw secret JSON in public columns.
- Secret **slots** intended for production are listed in `public.phase2_vault_secret_slot` (metadata only).

## Onboarding checklist

1. Install Supabase CLI and run `supabase start`.
2. Copy `.env.example` → `.env`; sync values from `supabase status -o env`.
3. Confirm `dart run scripts/secret_scan.dart` is clean from repo root.
4. For connector development, use `integration_store_connector_secret` only from **service role** contexts (Edge Function or admin script).

## CI

- [`.github/workflows/security.yml`](../../.github/workflows/security.yml) runs `secret_scan.dart` on every PR and nightly.
- Historical scans use `fetch-depth: 0` where needed; see script `--history` flag.

## Recommended git hook

```bash
git config core.hooksPath .githooks
```

The [.githooks/pre-push](../../.githooks/pre-push) helper runs `secret_scan.dart` before every push.

## Rotation

| Secret type | Rotation trigger |
| --- | --- |
| OAuth client secret | Provider console rotation + update Vault / `supabase secrets` |
| Service role | Incident response only; never ship to clients |
| Babysitter signing material | Per product policy (hashed tokens server-side) |

Related: [auth.md](../auth.md), [release-readiness.md](release-readiness.md).
