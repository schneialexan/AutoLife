---
name: phase2.6_security_verification_hardening
overview: Pen-test checklist, OWASP MASVS coverage map, Supabase Vault + dotenv secret-management conventions, a policy-drift CI gate, an automated dependency-audit workflow, and the release-readiness gate that closes Phase 2.
phase: 2.6
gate_owner: Phase 2 Gate
isProject: false
---

# Phase 2.6 - Security Verification + Hardening

## Objective
Close Phase 2 with verifiable, repeatable security evidence: a documented pen-test checklist mapped to OWASP MASVS controls, a secret-management convention covering Supabase Vault and `dotenv`, a CI-enforced policy-drift detector, an automated dependency-audit workflow, and a release-readiness gate that block-lists deploys until all controls are green.

## In scope
- A pen-test checklist with concrete cases against the auth flows from 2.1, the tenancy model from 2.2, the role and approval engine from 2.3, the RLS templates from 2.4, and the privacy controls from 2.5.
- OWASP MASVS L1 + L2 coverage mapping (storage, crypto, auth, network, platform interaction) with per-control acceptance evidence.
- Secret-management conventions: `supabase secrets` for runtime values, Supabase Vault for at-rest tokens, `.env.example` and `dotenv` for local development, and a CI rule that no real secrets land in the repo.
- A policy-drift CI gate that consumes the detector from Phase 2.4 and fails builds when drift is detected.
- A dependency-audit workflow running `dart pub outdated`, `flutter pub outdated`, and an `npm audit` pass for edge-function dependencies, with a CVE allowlist.
- A signed release-readiness gate document checked in alongside the codebase and required for every tagged release.

## Out of scope
- Adding new product features.
- Replacing the RLS template library or the role matrix (consumed here, not redefined).
- External-firm penetration testing engagement (this plan produces the input package for that engagement).

## Key deliverables
- `docs/security/pentest-checklist.md` - case-by-case verification matrix covering Phases 2.1 - 2.5.
- `docs/security/masvs-coverage.md` - OWASP MASVS control table with evidence links.
- `docs/security/secret-management.md` - Supabase Vault + dotenv conventions and onboarding steps.
- `docs/security/release-readiness.md` - the gate document referenced by the release process.
- `.github/workflows/security.yml` - workflow running policy-drift, dependency-audit, and secret-scan jobs on every PR and nightly on `main`.
- `scripts/secret_scan.dart` - block-lists committed secrets via regex + entropy heuristics.
- `scripts/dependency_audit.sh` - one-shot runner used both locally and in CI.
- `supabase/migrations/20260512000500_secrets_baseline.sql` - confirms Vault is enabled and seeds the documented secret slots.
- `.env.example` - documented placeholders for every required runtime secret.
- `CHANGELOG.md` entry recording Phase 2 closure.

## Dependencies
- [phase2.1_auth_flows.plan.md](phase2.1_auth_flows.plan.md) - auth flows under test.
- [phase2.2_family_tenancy_model.plan.md](phase2.2_family_tenancy_model.plan.md) - tenancy boundaries under test.
- [phase2.3_role_policy_model.plan.md](phase2.3_role_policy_model.plan.md) - role and approval surface under test.
- [phase2.4_rls_policies.plan.md](phase2.4_rls_policies.plan.md) - policy-drift detector consumed here.
- [phase2.5_privacy_controls.plan.md](phase2.5_privacy_controls.plan.md) - biometric and babysitter surface under test.

## Acceptance criteria (gate)
- [ ] The pen-test checklist contains at least one passing case for every Idea-Refined Part 5.1 and 5.2 control and is fully executed before release.
- [ ] MASVS L1 controls are 100% covered with evidence links; L2 controls are at least 80% covered with documented gaps and owners.
- [ ] `secret_scan.dart` returns clean against `git log --all` and is wired into a pre-push hook plus CI.
- [ ] `.github/workflows/security.yml` runs policy-drift, secret-scan, and dependency-audit jobs on every PR and exits non-zero on findings.
- [ ] `dependency_audit.sh` produces a machine-readable report and fails when a `CRITICAL` CVE is unaddressed for more than 7 days.
- [ ] `docs/security/release-readiness.md` is signed off (file mtime updated, owner recorded) before any Phase 2 release tag.
- [ ] No production secret is present in any committed file; `.env.example` lists every required key with a placeholder value and a one-line description.
- [ ] All Phase 2.1 through 2.5 gates remain green when re-run after this plan's hardening changes.

## Risks + mitigations
- **Risk**: Security checks become noisy and developers learn to ignore them. **Mitigation**: Tune each check to actionable thresholds, route findings into a dedicated `security` GitHub label with SLAs, and review the noise-vs-signal ratio at every Phase 2 retro.
- **Risk**: Secret scanning misses high-entropy production tokens or false-positives on test fixtures. **Mitigation**: Use both regex and entropy heuristics, maintain an allowlist file with required justifications, and run nightly historic scans against `git log --all`.
- **Risk**: The release-readiness gate slows down legitimate hot-fixes. **Mitigation**: Provide a documented break-glass procedure that records an audit entry, requires two-owner sign-off, and re-runs the gate within 24 hours of the hot-fix.

## Implementation outline
1. Draft `docs/security/pentest-checklist.md` by walking every Phase 2 plan and listing concrete attack and abuse cases.
2. Map each case to OWASP MASVS controls in `docs/security/masvs-coverage.md` with evidence link placeholders.
3. Author `docs/security/secret-management.md` covering Supabase Vault enablement, `supabase secrets`, `.env.example`, and developer onboarding.
4. Implement `scripts/secret_scan.dart` with regex and entropy checks and an allowlist file.
5. Implement `scripts/dependency_audit.sh` wrapping `dart pub outdated`, `flutter pub outdated`, and edge-function `npm audit` with a unified report.
6. Wire `.github/workflows/security.yml` to run policy-drift (from Phase 2.4), secret scan, dependency audit, and pentest-checklist link validation on every PR.
7. Add migration `20260512000500_secrets_baseline.sql` confirming Vault is enabled and seeding documented secret slots.
8. Run the full pentest checklist locally against the staging stack, capture evidence, and link it into the docs.
9. Author `docs/security/release-readiness.md` with the sign-off table and break-glass procedure.
10. Tag the merge commit `phase-2-gate-green` and update the overarching tracker checkboxes.

## Artifacts/links
- PR: (tbd)
- Security workflow: `.github/workflows/security.yml` (tbd)
- Pen-test evidence bundle: `docs/security/pentest-checklist.md` (tbd)
- MASVS map: `docs/security/masvs-coverage.md` (tbd)
- Release-readiness sign-off: `docs/security/release-readiness.md` (tbd)
