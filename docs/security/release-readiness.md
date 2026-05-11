# Phase 2 release readiness gate

This file is **gating documentation**: the Phase 2 closure tag MUST NOT be applied until the table below is signed and the checklist in [pentest-checklist.md](pentest-checklist.md) is executed with evidence.

## Preconditions (automated)

| Gate | Mechanism |
| --- | --- |
| Policy drift | `dart run scripts/policy_drift_check.dart` (see CI) |
| Secret scan | `dart run scripts/secret_scan.dart` |
| Dependency audit | `scripts/dependency_audit.sh` |
| Security docs consistency | `dart run scripts/pentest_docs_validate.dart` |

## Preconditions (manual)

| Gate | Artifact |
| --- | --- |
| MASVS map current | [masvs-coverage.md](masvs-coverage.md) |
| Secret conventions agreed | [secret-management.md](secret-management.md) |
| `.env.example` complete | Repo root [.env.example](../../.env.example) |

---

## Sign-off record

_Update `Last updated (UTC)` and the table when approving a release._

**Last updated (UTC):** (not signed)

| Role | Name | Timestamp (UTC) | Commit / tag SHA |
| --- | --- | --- | --- |
| Security owner | | | |
| Engineering lead | | | |
| Release manager | | | |

---

## Break-glass (emergency hotfix)

Use only when delaying the gate would materially harm users:

1. Open an incident ticket with **reason**, **risk acceptance**, and **two-owner** names (engineering + security or lead delegate).
2. Apply the minimal hotfix; tag with `hotfix-` prefix and link the incident ID in the tag annotation.
3. Within **24 hours**, re-run the automated security workflow on `main` and complete any missing rows in [pentest-checklist.md](pentest-checklist.md) for the touched surface.
4. Record the break-glass event in the sign-off table footnotes.

**Footnotes (incidents / waivers):**

- (none)

---

## Related

- [pentest-checklist.md](pentest-checklist.md)
- [masvs-coverage.md](masvs-coverage.md)
- [CHANGELOG](../../CHANGELOG.md)
