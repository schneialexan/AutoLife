# Role + Policy Model (Phase 2.3)

Idea-Refined Part 5.1 anchor:

> "Custom Roles: Templates for Co-Parent, Teenager, Young Child, Grandparent, Guest/Babysitter, Child."
>
> "RSVP & Approval Engine: Strictness toggles ('Child accounts require Parent approval to add calendar events.'), Auto-Approve rules ('Auto-approve teen's events if the location is set to "School".'), Turn off if not necessary."
>
> "Chore Enforcement: Toggle if a kid's chore requires a 'Photo Proof' upload or Parent 'Verification' before granting allowance."

## Source of truth

- **YAML matrix**: `packages/autolife-core/policy/matrix.yaml` — canonical capabilities × roles × default grants and enforcement flags.
- **Generated outputs** (`dart run tool/generate_policy_matrix.dart`):
  - `packages/autolife-core/lib/src/policy/capability_matrix_generated.dart`
  - `INSERT` block embedded in `supabase/migrations/20260512000210_capability_matrix.sql` between codegen markers.

## Postgres

RLS policy shapes for these tables follow [rls-templates.md](rls-templates.md).

| Object | Migration | Purpose |
| --- | --- | --- |
| `family_role` enum | `20260512000200_role_enum.sql` | Owner-facing roles mirrored in Dart `FamilyRole`. |
| `capability_matrix_default` / `capability_grants` | `20260512000210_capability_matrix.sql` | Global defaults + per-family editable grants. |
| `approval_requests` / `approval_auto_rules` | `20260512000220_approval_engine.sql` | Manual + auto approvals, example match on normalized location. |

## Dart surface

| Type | Responsibility |
| --- | --- |
| `Capability` | Strongly typed capability identifiers (wire strings match Postgres). |
| `RolePolicyService` + `SupabaseCapabilityGrantSource` | Resolves grants for `(family_id, FamilyRole, Capability)`. |
| `ApprovalEngine` | `pending → approved \| rejected \| expired \| auto_approved` transitions + emits `approval.requested` / `approval.resolved` on the Phase 1.5 producer. |
| `ChoreTaskCompletionGuard` | Sample enforcement hook reading `require_photo_proof` / `require_parent_verification`. |

## Capabilities seeded (YAML)

Aligned with Idea-Refined Part 5.1:

| Capability | Notes |
| --- | --- |
| `calendar.view` | Shared agenda visibility tiers. |
| `calendar.create_event` | RSVP / approvals for minors (parent approval flag + auto-rules). |
| `calendar.edit_own_event` | Self-service edits. |
| `chores.*` | Assignments vs completion gates with photo proof + parent verification toggles (`chores.complete_task`). |
| `family.*` | Invitations and owner-only matrix management (`family.manage_policy`). |
| `allowance.*` | View vs manage payouts. |

Stale generated matrix files fail CI alongside `dart run tool/generate_policy_matrix.dart` drift checks.
