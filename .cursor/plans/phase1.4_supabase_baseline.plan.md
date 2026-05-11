---
name: phase1.4_supabase_baseline
overview: Lay down the Supabase project baseline (DB schema, auth config, storage buckets, Edge Functions scaffold) that every later phase will extend, mirroring the core models defined in phase 1.2 without redefining their contracts.
phase: 1.4
gate_owner: Phase 1 Gate
isProject: false
---

# Phase 1.4 - Supabase Baseline

## Objective
Provision the foundational Supabase project: SQL migrations for the canonical tables (`system_event`, `event_delivery`, plus stubbed `profile`, `family`, `membership`), auth provider and email-template configuration, storage buckets needed by Phase 3 apps, and the empty `process-event` and `bootstrap` Edge Functions so the worker plan (1.5) and gateway plan (1.7) can drop logic in without scaffolding work. Ownership of full tenancy and RLS shifts to phase 2.2/2.4; this plan only stubs the tables and grants service-role access.

## In scope
- SQL migration that creates `system_event` and `event_delivery` with the exact columns declared by [.cursor/plans/phase1.2_autolife_core_contracts.plan.md](.cursor/plans/phase1.2_autolife_core_contracts.plan.md).
- SQL migration that creates skeleton `profile`, `family`, `membership` tables (id, foreign keys, display name, role enum) marked with TODO comments pointing to phase 2.2 for full schema and phase 2.4 for RLS.
- Auth configuration: email/password enabled, magic link enabled, OAuth providers declared but credentials left blank, email templates committed.
- Storage buckets: `avatars` (public read), `receipts` (private), `documents` (private), `family-assets` (private).
- Edge Functions scaffolding: empty `process-event/` and `bootstrap/` folders with `index.ts`, `deno.json`, and a smoke test invoking the function locally returning 200.
- `supabase/config.toml` updates pinning project ref, db version, and function entrypoints.
- Local-dev workflow documented (`supabase start`, `supabase db reset`, `supabase functions serve`).
- CI step running `supabase db lint` and `supabase functions deno test` against the scaffold.

## Out of scope
- RLS policies (owned by phase 2.4).
- Full tenancy lifecycle (owned by phase 2.2).
- Worker business logic for `process-event` (owned by phase 1.5).
- Integration connector credential storage details (owned by phase 1.7).
- Production secret rotation procedures (owned by phase 2.6).

## Key deliverables
- [supabase/migrations/0001_init_system_events.sql](supabase/migrations/0001_init_system_events.sql) - creates `system_event` and `event_delivery`.
- [supabase/migrations/0002_init_tenancy_stubs.sql](supabase/migrations/0002_init_tenancy_stubs.sql) - creates stubbed `profile`, `family`, `membership`.
- [supabase/migrations/0003_storage_buckets.sql](supabase/migrations/0003_storage_buckets.sql) - declares the four buckets and their public/private flags.
- [supabase/config.toml](supabase/config.toml) - project config with auth providers, function entrypoints, and DB version pinned.
- [supabase/seed.sql](supabase/seed.sql) - dev-only seed inserting one family + two profiles for local testing.
- [supabase/functions/process-event/index.ts](supabase/functions/process-event/index.ts) - scaffold returning 501 Not Implemented (filled in by 1.5).
- [supabase/functions/process-event/deno.json](supabase/functions/process-event/deno.json).
- [supabase/functions/bootstrap/index.ts](supabase/functions/bootstrap/index.ts) - scaffold returning current user + tenant context.
- [supabase/functions/bootstrap/deno.json](supabase/functions/bootstrap/deno.json).
- [supabase/templates/](supabase/templates/) - email templates (signup, recovery, magic link).
- [docs/supabase-local-dev.md](docs/supabase-local-dev.md) - bootstrap/run/reset documentation.

## Dependencies
- [.cursor/plans/phase1.1_monorepo_workspace_setup.plan.md](.cursor/plans/phase1.1_monorepo_workspace_setup.plan.md) - workspace and CI must exist.
- [.cursor/plans/phase1.2_autolife_core_contracts.plan.md](.cursor/plans/phase1.2_autolife_core_contracts.plan.md) - column names in `system_event` and `event_delivery` migrations must match the Dart models defined there.

## Acceptance criteria (gate)
- [ ] `supabase db reset` runs cleanly against a fresh local Postgres and applies all three migrations.
- [ ] Column names and types in `system_event` and `event_delivery` match the fields declared in `packages/autolife-core` exactly; a CI parity test enforces this.
- [ ] All four storage buckets exist after `supabase db reset` and have the correct public/private flags.
- [ ] `supabase functions serve process-event` responds with 501 to a POST; `supabase functions serve bootstrap` responds with 200 and echoes the auth context.
- [ ] `supabase db lint` produces no errors on the committed migrations.
- [ ] Local dev doc walks a new contributor from clone to working Supabase stack in under 10 minutes.
- [ ] `supabase/seed.sql` inserts one family and two profiles and `supabase db reset` applies it without error.
- [ ] `.env.example` documents every environment variable referenced by the functions or the Flutter shell.

## Risks + mitigations
- **Risk**: Schema drift between this baseline and the full tenancy schema landed in phase 2.2. / **Mitigation**: Mark every stub column with a SQL `COMMENT` referencing `.cursor/plans/phase2.2_family_tenancy_model.plan.md` and require phase 2.2 to ship an `ALTER TABLE` migration rather than dropping the stub.
- **Risk**: Migrations diverging between local dev and the hosted project. / **Mitigation**: Adopt `supabase migration squash` only at phase gates, otherwise keep migrations forward-only; CI runs `supabase db reset` plus `supabase db diff --linked` against a check-only project to flag drift.
- **Risk**: Edge Function scaffolds rotting before 1.5 lands. / **Mitigation**: Add a minimal Deno test per function that asserts the scaffold's HTTP contract, run it in CI so changes that break the contract fail fast.

## Implementation outline
1. Author migration `0001_init_system_events.sql` with column names mirroring `packages/autolife-core` exactly, including indices on `(tenant_id, occurred_at)` and `(idempotency_key)`.
2. Author migration `0002_init_tenancy_stubs.sql` with TODO comments pointing to phase 2.2.
3. Author migration `0003_storage_buckets.sql` declaring the four buckets with explicit policies set to `service_role only` for now (phase 2.4 tightens with RLS).
4. Update `supabase/config.toml` for auth providers, redirect URLs, and the two function entrypoints.
5. Commit the four email templates (signup, magic-link, recovery, invite) under `supabase/templates/`.
6. Scaffold `process-event/index.ts` and `bootstrap/index.ts` with the minimal Deno entrypoints and a smoke test per function.
7. Write `supabase/seed.sql` for local-dev test data.
8. Document the local-dev workflow in `docs/supabase-local-dev.md` and `.env.example`.
9. Add a Melos script `melos run supabase:reset` wrapping `supabase db reset` for CI parity.
10. Add the column-parity test (Dart side reads JSON schema, asserts column names appear in the migration files) to CI.

## Artifacts/links
- PR: (tbd)
- Migration: (tbd)
- Test report: (tbd)
