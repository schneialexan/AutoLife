# RLS policy templates (Phase 2.4)

AutoLife standardizes Row-Level Security on **four parameterized templates** (`supabase/policies/*.sql.tpl`) backed by shared SQL helpers in `supabase/migrations/20260512000300_rls_helpers.sql`.

Migrations must reference a template by name in `COMMENT ON POLICY` (see `20260512000310_apply_rls_phase2.sql`). New tables with RLS must register policies in `supabase/policies/rls_policy_registry.yaml` so `scripts/policy_drift_check.dart` can fail CI when policies drift.

## Helpers

| Function | Purpose |
| --- | --- |
| `public.is_member_of(uuid)` | Active membership in a family (`memberships.removed_at is null`). Implemented as `SECURITY DEFINER` so policies on `memberships` do not recurse through RLS. |
| `public.has_role(uuid, family_role)` | Membership + exact role. |
| `public.is_owner_of(uuid)` | `has_role(..., owner)`. |
| `public.babysitter_can_read(uuid)` | `has_role(..., babysitter)` — pair with row flags for scoped reads. |

## Templates

### `per_family_scope.sql.tpl`

- **When**: Members of the same family should share access to rows keyed by `family_id`.
- **Shape**: `USING (public.is_member_of(__FAMILY_COL__))` (and `WITH CHECK` for inserts/updates as needed).
- **Examples**: `capability_grants` SELECT; `approval_requests` SELECT; `families` SELECT (combined with creator bootstrap where needed).

### `per_role_gate.sql.tpl`

- **When**: Only certain roles may act (for example only `owner` inserts policy rows).
- **Shape**: `USING / WITH CHECK (public.has_role(__FAMILY_COL__, 'owner'::public.family_role))` or multiple roles with `OR`.
- **Examples**: `capability_grants` INSERT/UPDATE; resolver rules on `approval_requests` UPDATE (owner/partner OR requester).

### `owner_only.sql.tpl`

- **When**: Mutations are limited to the family owner.
- **Shape**: `USING (public.is_owner_of(__FAMILY_COL__))` with matching `WITH CHECK`.
- **Examples**: `capability_grants` owner writes; `approval_auto_rules` DML.

### `babysitter_scoped_read.sql.tpl`

- **When**: Babysitters should see only a subset of family rows; other members retain full family visibility.
- **Shape**: `USING ( public.is_member_of(__FAMILY_COL__) AND (NOT public.babysitter_can_read(__FAMILY_COL__) OR __BABYSITTER_FLAG_COL__) )`.
- **Example table**: `public.rls_babysitter_scope_demo` (non-production demo used by pgTAP).

## Tests

- **pgTAP**: `supabase test db supabase/tests/rls` — role simulations via `test_rls.set_auth` in `supabase/tests/rls/fixtures/users_and_families.inc` (include file, not executed as its own test).
- **Coverage gate**: `dart run scripts/rls_coverage_gate.dart` — ensures helper predicates appear in SQL tests or in the apply migration.
- **Drift**: `dart run scripts/policy_drift_check.dart` (requires `DB_URL` / `SUPABASE_DB_URL`; local URLs append `sslmode=disable` automatically in the script).

## Adopting a template in a later plan

1. Add or extend `CREATE POLICY` using the helpers (copy the `.tpl` comment block into the migration for traceability).
2. Register policy names under `supabase/policies/rls_policy_registry.yaml`.
3. Extend pgTAP (or document why the table is allow-listed) so the drift detector stays green.
