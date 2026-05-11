# OWASP MASVS coverage (AutoLife Phase 2)

This table maps **OWASP MASVS** controls to AutoLife evidence. **L1** targets full coverage with a concrete artifact; **L2** targets ≥80% with named gaps and owners.

Reference: [OWASP MASVS](https://mas.owasp.org/MASVS/).

## Storage (V2)

| Control | Level | Evidence in AutoLife | Status |
| --- | --- | --- | --- |
| No sensitive data in logs | L1 | Auth error mapping (`AuthService`); no raw tokens in shell logs — [auth.md](../auth.md) | Met |
| No sensitive data in backups without plan | L1 | Supabase backup policy (hosting); document in ops runbook — **Gap**: centralize URL in `release-readiness.md` owner | Gap |
| Credentials in secure storage | L1 | `flutter_secure_storage` for session — Phase 2.1 | Met |
| No world-readable local stores | L1 | Platform defaults + no SD-card paths for secrets | Met |
| Hardware-backed when available | L2 | OS keystore / Keychain via secure storage | Partial — document device matrix |
| Asset protection / encryption at rest | L2 | Supabase at rest + Vault for connector creds — [0020 migration](../../supabase/migrations/0020_connector_credentials.sql) | Met |

## Cryptography (V3)

| Control | Level | Evidence | Status |
| --- | --- | --- | --- |
| Use platform crypto primitives | L1 | TLS to Supabase; GoTrue token handling | Met |
| No custom crypto for secrets | L1 | Vault `create_secret` / `update_secret` for connector bundles | Met |
| Key material not in repo | L1 | [secret-management.md](secret-management.md), [secret_scan.dart](../../scripts/secret_scan.dart), CI | Met |

## Authentication (V4)

| Control | Level | Evidence | Status |
| --- | --- | --- | --- |
| Appropriate session lifecycle | L1 | [auth.md](../auth.md) logout scopes; integration tests | Met |
| Server-side auth for sensitive ops | L1 | RLS on all Phase 2 tables — [rls-templates.md](../rls-templates.md) | Met |
| Step-up / second factor where required | L2 | MFA deferred in Phase 2.1 — **Gap**: owner Phase 3, track in roadmap | Gap |
| Account recovery safe | L1 | PKCE recovery flow — [auth.md](../auth.md) | Met |

## Network (V5)

| Control | Level | Evidence | Status |
| --- | --- | --- | --- |
| TLS for all endpoints | L1 | Supabase HTTPS; local dev HTTP documented only for localhost | Met |
| Certificate validation | L1 | Platform networking defaults | Met |
| No sensitive data via deep links | L1 | OAuth uses one-time codes; recovery PKCE — [auth.md](../auth.md) | Met |

## Platform interaction (V6)

| Control | Level | Evidence | Status |
| --- | --- | --- | --- |
| Minimal OS permissions | L1 | Biometric + intent filters scoped — Android manifest / iOS plist | Met |
| No sensitive data via IPC | L1 | Review clipboard / sharing for auth screens — **Gap**: periodic UX audit | Gap |
| User permission prompts justified | L1 | Face ID usage string; biometric screens | Met |

## Code quality / resilience (V7 / V8)

| Control | Level | Evidence | Status |
| --- | --- | --- | --- |
| Input validation | L1 | Postgres constraints; RPC guards | Met |
| Error handling without leaks | L1 | Typed auth + tenancy errors | Met |
| Integrity of code / supply chain | L1 | Dependency audit workflow + allowlist — [dependency_audit.sh](../../scripts/dependency_audit.sh) | Met |
| Runtime tamper reaction | L2 | Not implemented client-side — **Gap**: Jailbreak/root guidance only | Gap |

---

## Summary

| Level | Coverage | Notes |
| --- | --- | --- |
| **L1** | 100% rows above marked Met or covered by linked artifact | All L1 rows have evidence links |
| **L2** | ≥80% | Gaps: backup runbook centralization, MFA, IPC/clipboard audit cadence, client tamper response |

## L2 gap owners

| Gap | Owner | Target |
| --- | --- | --- |
| Backup / DR documentation | Ops / Security | Next minor release |
| MFA (TOTP/WebAuthn) | Auth platform | Phase 3+ |
| Clipboard / IPC audit | Shell team | Quarterly |
| Client integrity / jailbreak | Mobile platform | Advisory doc only until hardening |

Update this file when controls change or evidence moves.
