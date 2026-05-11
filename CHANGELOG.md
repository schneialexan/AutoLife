# Changelog

All notable project-level milestones are summarized here using [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) style.

## [Unreleased]

### Security (Phase 2.6 closure)

- Added penetration-test checklist (`docs/security/pentest-checklist.md`), MASVS evidence map (`docs/security/masvs-coverage.md`), secret-management onboarding (`docs/security/secret-management.md`), and Phase 2 release gate doc (`docs/security/release-readiness.md`).
- Wired `.github/workflows/security.yml` plus `scripts/secret_scan.dart`, `scripts/dependency_audit.sh` / `scripts/dependency_audit_runner.dart`, and `scripts/pentest_docs_validate.dart`.
- Documented canonical env placeholders in `.env.example`, added Vault slot inventory baseline migration `20260512000500_secrets_baseline.sql`, and optional `.githooks/pre-push` that runs secret scanning locally.
