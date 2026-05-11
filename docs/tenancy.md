# Family tenancy

AutoLife is **multi-tenant by family**: most domain data is scoped to a single household (`public.families`). This document is the contract every feature plan and migration must follow.

## Tables (Phase 2.2)

- **`families`** — tenant root (`id`, `name`, `created_by`, `created_at`, `archived_at`, `settings` JSONB).
- **`memberships`** — user ↔ family link with composite primary key `(family_id, user_id)`, role placeholder text, `joined_at`, soft removal via `removed_at`.
- **`family_invitations`** — email invitation lifecycle; only **`token_hash`** is stored server-side; acceptance uses the `accept_invitation` RPC.

## Standard column for new tables

Any new table that stores family-scoped data **must** include:

```sql
family_id uuid not null references public.families (id) on delete cascade
```

Application code must treat **`family_id`** as mandatory for writes and must align reads with the user’s **active family** (see `profile.active_family_id`).

## Active family

`public.profile.active_family_id` is the canonical pointer to which family context the signed-in user is operating in. The shell updates it through `TenancyService.switchActiveFamily`.

## RLS

Baseline policies ship in `20260512000100_family_tenancy.sql`. Tightening and capability checks are owned by Phase 2.4 (`phase2.4_rls_policies.plan.md`).

## Client services

- Dart models: `packages/autolife-core/lib/src/tenancy/models/`.
- API: `TenancyService` / `SupabaseTenancyService` in `packages/autolife-core/lib/src/tenancy/`.
- Invitations email: `supabase/functions/send-invitation` (deep link default `autolife://invite?token=…`).

## Sync engine

Incremental sync scopes `families`, `memberships`, and `profile` using `SyncEngine.setFamilyPullScope` / `setProfilePullScope` together with `SupabaseRemoteSyncGateway`.
