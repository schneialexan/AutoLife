# AutoLife privacy tiers and guest scope (Phase 2.5)

This document is the canonical contract for sensitive household data, module-level biometric locks, and babysitter link scoping. Phase 3 feature modules **must** declare which tier their columns map to in `public.sensitivity_assignments` (via migrations).

## Sensitivity tiers

All tiers are defined by Postgres enum `public.sensitivity_tier`. The set is **closed**: adding a fifth value requires an ADR and CI updates.

### `public_family`

Data any active family member may see under normal RLS (e.g., shared calendar labels, family display name).

**Example:** `public.families.name` — the household label shown in the switcher.

### `private_member`

Data owned by or primarily about a single member where family-wide visibility would be surprising without explicit sharing.

**Example:** A per-profile notification handle that is not meant for children’s accounts on the same family.

### `health_locked`

Clinical or safety-adjacent data (allergies, medications, immunizations) that should respect `health_locked` RLS policies and **optional** app-level biometric gates.

**Example:** An allergy list row marked for parent/health-module visibility only.

### `finance_locked`

Banking identifiers, card metadata, or allowance ledger details subject to finance RLS and optional biometric gates.

**Example:** A stored external account mask used for allowance payouts.

## Column registry

Table `public.sensitivity_assignments` maps `(table_schema, table_name, column_name)` → tier. Phase 2.2–2.3 columns were seeded at `public_family` as a conservative baseline; tighten per column in future migrations when a module lands.

## Biometric app-lock contract

- Dart API: `BiometricLockService` in `autolife_core` wraps `local_auth` with **device credential fallback** (`biometricOnly: false`) so users recover with PIN/password when biometrics fail.
- Persistence: per-module booleans in secure storage (`autolife.privacy.biometric_locks.v1`). Enabling a lock in **Biometric locks** survives app restarts.
- UI: modules wrap sensitive routes with shell widget `BiometricGate` (`moduleId` matches entries toggled in the control center).
- Telemetry hook: failed prompts emit `PrivacyLockFailed` / analytics name `privacy.lock_failed` for hosts to wire to their analytics layer.

## Babysitter links

- Table `public.babysitter_links` stores **only** `token_hash` (SHA-256 hex of the raw token) plus per-link boolean toggles: WiFi credentials, emergency contacts, allergies, locations.
- Default TTL when minted from the shell is **24 hours** (`BabysitterLinkService.defaultTtl`); owners revoke with `revoked_at`.
- RPC `public.babysitter_scope(p_token text [, p_client_meta jsonb])` returns JSON:

  - `status`: `ok` | `invalid` | `expired` | `revoked`
  - On `ok`: `family_id`, `link_id`, `resources` (json array of enabled string keys)
  - Successful lookups append a row to `public.babysitter_link_access_logs` with `client_meta` (caller-supplied audit payload, e.g. IP / user-agent from an Edge Function).

- RLS: only family **owners** insert/update/list their family’s links; guests never read the table directly — they call `babysitter_scope` with anon or authenticated clients.

### Example scope response

```json
{
  "status": "ok",
  "family_id": "f0000001-0001-4001-8001-000000000001",
  "link_id": "c0000001-0001-4001-8001-000000000001",
  "resources": ["wifi_credentials", "allergies"]
}
```

## See also

- `docs/tenancy.md` — `family_id` inheritance for links
- `docs/role-policy.md` — babysitter role capabilities
- `supabase/policies/babysitter_scoped_read.sql.tpl` — row-level template that composes with scope predicates in Phase 3 tables

Phase 3.6 (Auto Health) intentionally references this file when classifying medical-adjacent columns and choosing `BiometricGate` module IDs.
