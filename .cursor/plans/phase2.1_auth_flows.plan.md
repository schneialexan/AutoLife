---
name: phase2.1_auth_flows
overview: Deliver end-to-end authentication flows on top of the Supabase Auth baseline - sign up, login, password reset, OAuth (Google + Apple), session lifecycle, and logout-all-devices - exposed through a single autolife-core auth service and autolife-shell screens.
phase: 2.1
gate_owner: Phase 2 Gate
isProject: false
---

# Phase 2.1 - Auth Flows

## Objective
Implement a production-grade, multi-platform authentication experience built on the Supabase Auth project scaffolded in Phase 1.4. Users can sign up, log in, recover passwords, link Google/Apple identities, persist sessions across restarts, refresh tokens transparently, and force-revoke every device session from a single tap. All auth state is exposed through one `AuthService` contract in `packages/autolife-core` so every later module consumes it without re-implementing logic.

## In scope
- Email/password sign-up, login, and password reset (request + redeem flows).
- Google and Apple OAuth providers wired into Supabase Auth with platform-specific deep links.
- Session persistence using `flutter_secure_storage` and silent refresh.
- Logout (current device) and logout-all-devices via the Supabase admin revoke endpoint.
- A single `AuthService` interface in `packages/autolife-core` plus a Supabase-backed implementation.
- Auth UI screens in `apps/autolife-shell` (sign in, sign up, forgot password, account/sessions management).
- Auth error mapping so user-visible copy is decoupled from raw Supabase error strings.

## Out of scope
- MFA/TOTP enrollment (deferred to 2.6 or a later phase).
- Family creation/invitation flows (owned by [phase2.2_family_tenancy_model.plan.md](phase2.2_family_tenancy_model.plan.md)).
- Role assignment and capability gates (owned by [phase2.3_role_policy_model.plan.md](phase2.3_role_policy_model.plan.md)).
- Biometric module-level locks (owned by [phase2.5_privacy_controls.plan.md](phase2.5_privacy_controls.plan.md)).

## Key deliverables
- `packages/autolife-core/lib/src/auth/auth_service.dart` - abstract `AuthService` contract.
- `packages/autolife-core/lib/src/auth/supabase_auth_service.dart` - Supabase implementation.
- `packages/autolife-core/lib/src/auth/models/auth_session.dart`, `auth_user.dart`, `auth_error.dart`.
- `packages/autolife-core/test/auth/supabase_auth_service_test.dart` - mocked Supabase client tests.
- `apps/autolife-shell/lib/src/screens/auth/sign_in_screen.dart`.
- `apps/autolife-shell/lib/src/screens/auth/sign_up_screen.dart`.
- `apps/autolife-shell/lib/src/screens/auth/forgot_password_screen.dart`.
- `apps/autolife-shell/lib/src/screens/auth/sessions_screen.dart` (with logout-all action).
- `apps/autolife-shell/lib/src/providers/auth_provider.dart`.
- `apps/autolife-shell/android/app/src/main/AndroidManifest.xml` - deep-link entries for OAuth callbacks.
- `apps/autolife-shell/ios/Runner/Info.plist` - URL schemes for OAuth callbacks.
- `supabase/migrations/20260512000050_auth_metadata.sql` - any `auth.users` metadata triggers (display name copy, etc.).
- `docs/auth.md` - flow diagrams and provider setup runbook.

## Dependencies
- [phase1.2_autolife_core_contracts.plan.md](phase1.2_autolife_core_contracts.plan.md) - service-interface conventions and error-type primitives.
- [phase1.3_autolife_ui_design_system.plan.md](phase1.3_autolife_ui_design_system.plan.md) - form fields, buttons, and theme tokens used by auth screens.
- [phase1.4_supabase_baseline.plan.md](phase1.4_supabase_baseline.plan.md) - Supabase project, auth config, and provider scaffolding.
- [phase1.6_offline_sync_foundation.plan.md](phase1.6_offline_sync_foundation.plan.md) - secure-storage conventions reused for session persistence.

## Acceptance criteria (gate)
- [ ] A new user can sign up with email/password, receive the confirmation email, and complete sign-in on Android, iOS, and web builds.
- [ ] Google OAuth and Apple OAuth flows complete successfully on at least one mobile platform each and produce a valid Supabase session.
- [ ] Password-reset request emails are delivered and the redeem deep-link updates the password without leaving the app.
- [ ] Sessions persist across app restarts and refresh silently before access-token expiry (verified by an integration test that fast-forwards expiry).
- [ ] "Logout this device" revokes only the current session; "Logout all devices" calls the admin endpoint and invalidates every active refresh token for the user.
- [ ] `AuthService` unit tests cover sign-in, sign-up, reset, OAuth callback, refresh, and logout-all paths with at least 80% line coverage of `packages/autolife-core/lib/src/auth/`.
- [ ] All auth error states map to user-facing messages via the shared design-system error component; no raw Supabase error strings reach the UI.
- [ ] CI runs a Flutter integration test for the email/password happy path against a Supabase local stack.

## Risks + mitigations
- **Risk**: OAuth deep-link configuration drift between Android, iOS, and web breaks production sign-in. **Mitigation**: Codify URL schemes and intent filters in a single source-of-truth doc, add a CI smoke test per platform target that asserts the redirect URI resolves, and version provider config in `supabase/config.toml`.
- **Risk**: Apple Sign-In review rejection because of missing display-name handling or token-revocation endpoint. **Mitigation**: Implement Apple-specific name/email caching on first sign-in, register a server-side revocation endpoint, and document the Apple review checklist in `docs/auth.md`.
- **Risk**: Silent refresh races leave the app in a partially-authenticated state. **Mitigation**: Centralize refresh in `SupabaseAuthService` behind a single-flight lock, add tests that trigger concurrent refresh calls, and surface a `AuthState.refreshing` value the UI renders explicitly.

## Implementation outline
1. Define `AuthService` interface and value types in `packages/autolife-core` and wire dependency-injection points.
2. Implement `SupabaseAuthService` against the Supabase Dart SDK with secure-storage-backed session persistence.
3. Configure Supabase Auth providers (email, Google, Apple) in `supabase/config.toml` and document required secrets.
4. Build the sign-in, sign-up, and forgot-password screens in `apps/autolife-shell` using design-system primitives.
5. Wire OAuth deep-link handling on Android, iOS, and web with redirect URIs that round-trip through the auth callback handler.
6. Implement the sessions screen with active-device list, "log out this device", and "log out all devices" actions.
7. Wire `AuthProvider` so the rest of the shell observes auth state changes reactively.
8. Author unit tests for `SupabaseAuthService` and an integration test for the email/password happy path.
9. Wire CI to spin up the local Supabase stack and run the integration test on every PR.
10. Update `docs/auth.md` with sequence diagrams, provider setup, and the Apple review runbook.

## Artifacts/links
- PR: (tbd)
- Migration: `supabase/migrations/20260512000050_auth_metadata.sql` (tbd)
- Auth runbook: `docs/auth.md` (tbd)
- Provider config: `supabase/config.toml` updates (tbd)
