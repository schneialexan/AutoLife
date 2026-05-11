---
name: phase1.3_autolife_ui_design_system
overview: Establish packages/autolife-ui as the canonical owner of design tokens, theme, and shared widgets so every AutoLife app renders with one consistent look and feel.
phase: 1.3
gate_owner: Phase 1 Gate
isProject: false
---

# Phase 1.3 - autolife-ui Design System

## Objective
Build `packages/autolife-ui` as the single source of truth for design tokens (colors, spacing, typography, radii, shadows), light/dark `ThemeData`, and the small library of shared widgets (buttons, cards, app bars, omnibar shell, member-color avatars) that every Phase 3 app must consume so the cross-app "unified UI feel" mandated by Idea-Refined Part 1 is enforced from day one.

## In scope
- Design token primitives exposed as Dart constants and a `ThemeExtension` so consumers can read tokens without re-declaring them.
- Light and dark `ThemeData` factories that compose from the tokens.
- Family-member color palette helpers (deterministic color assignment given a member id).
- Core shared widgets: primary/secondary/destructive buttons, surface card, app bar, bottom-nav scaffold shell, omnibar text field, member avatar, member-colored badge, empty state, loading skeleton.
- Widgetbook (or Storybook-style harness) page for each shared widget so designers and developers can visually verify changes.
- Widget tests with golden snapshots for the shared widgets in light and dark themes.
- Public barrel and dartdoc on every exported widget and token.

## Out of scope
- App-specific screens or business widgets (those live in each Phase 3 app plan).
- Animations beyond simple Material defaults (deferred to QoL phase 3.14).
- Icon library curation beyond declaring which package (`material_symbols_icons` or similar) the system uses.
- Localization assets and translations (deferred; tokens stay locale-agnostic).

## Key deliverables
- [packages/autolife-ui/lib/autolife_ui.dart](packages/autolife-ui/lib/autolife_ui.dart) - public barrel.
- [packages/autolife-ui/lib/src/tokens/colors.dart](packages/autolife-ui/lib/src/tokens/colors.dart).
- [packages/autolife-ui/lib/src/tokens/spacing.dart](packages/autolife-ui/lib/src/tokens/spacing.dart).
- [packages/autolife-ui/lib/src/tokens/typography.dart](packages/autolife-ui/lib/src/tokens/typography.dart).
- [packages/autolife-ui/lib/src/tokens/radii.dart](packages/autolife-ui/lib/src/tokens/radii.dart).
- [packages/autolife-ui/lib/src/tokens/shadows.dart](packages/autolife-ui/lib/src/tokens/shadows.dart).
- [packages/autolife-ui/lib/src/theme/autolife_theme.dart](packages/autolife-ui/lib/src/theme/autolife_theme.dart) - `ThemeData` factories + `ThemeExtension`.
- [packages/autolife-ui/lib/src/theme/member_palette.dart](packages/autolife-ui/lib/src/theme/member_palette.dart) - deterministic family-member colors.
- [packages/autolife-ui/lib/src/widgets/](packages/autolife-ui/lib/src/widgets/) - shared widget library (buttons, cards, app bar, bottom-nav scaffold, omnibar field, member avatar, badge, empty state, skeleton).
- [packages/autolife-ui/example/](packages/autolife-ui/example/) - Widgetbook/gallery harness.
- [packages/autolife-ui/test/](packages/autolife-ui/test/) - widget tests plus golden files in `test/goldens/`.
- [packages/autolife-ui/CHANGELOG.md](packages/autolife-ui/CHANGELOG.md) starting at `0.1.0`.

## Dependencies
- [.cursor/plans/phase1.1_monorepo_workspace_setup.plan.md](.cursor/plans/phase1.1_monorepo_workspace_setup.plan.md) - workspace, analysis options, and CI must exist before this package can be tested.

## Acceptance criteria (gate)
- [ ] `dart analyze` and `dart format --set-exit-if-changed .` pass on the package.
- [ ] Every token is defined exactly once and exported via the public barrel; no widget hard-codes a hex value or a magic spacing number (lint or grep-based check documented).
- [ ] `AutoLifeTheme.light()` and `AutoLifeTheme.dark()` both return a complete `ThemeData` with the `AutoLifeTokens` `ThemeExtension` attached.
- [ ] `MemberPalette.colorFor(memberId)` is deterministic across runs and platforms (unit-tested).
- [ ] Each shared widget has at least one widget test and one light/dark golden file checked in under `test/goldens/`.
- [ ] The Widgetbook example app builds and renders every widget on Web.
- [ ] `apps/autolife-shell` consumes `AutoLifeTheme.light()` and at least one shared widget (e.g., the bottom-nav scaffold) without re-declaring any token.
- [ ] Public barrel re-exports every token, theme, palette, and widget; each export has a dartdoc comment.

## Risks + mitigations
- **Risk**: Token churn after Phase 3 apps adopt the package, forcing cascading visual changes. / **Mitigation**: Treat the `AutoLifeTokens` extension as a versioned contract, bump the package minor version on additive changes, document deprecations in `CHANGELOG.md`.
- **Risk**: Golden tests becoming flaky across host platforms. / **Mitigation**: Pin a single platform (`flutter test --update-goldens` only runs in Linux CI), document the workflow, and exclude goldens from non-Linux CI runs.
- **Risk**: Widgetbook adding a heavy transitive dependency to the shell app. / **Mitigation**: Keep the gallery harness inside `packages/autolife-ui/example/` as its own pubspec so the shared package itself stays free of Widgetbook deps.

## Implementation outline
1. Decide on token naming conventions and document them at the top of `lib/src/tokens/colors.dart`.
2. Implement the five token files (colors, spacing, typography, radii, shadows) with semantic names mapped to raw values.
3. Author `AutoLifeTheme.light()` and `AutoLifeTheme.dark()` and attach an `AutoLifeTokens` `ThemeExtension`.
4. Implement `MemberPalette` with a stable hash-to-color algorithm and unit tests.
5. Build the shared widgets one by one, each backed by a widget test and a golden file in light + dark.
6. Wire the Widgetbook example app in `packages/autolife-ui/example/` and add a Melos script `melos run gallery` to launch it.
7. Update `apps/autolife-shell/lib/main.dart` to consume `AutoLifeTheme.light()` and one shared widget to prove the wiring.
8. Add a CI check that runs `flutter test --tags golden` on Linux.
9. Set `CHANGELOG.md` to `0.1.0` and tag the merge commit `ui-0.1.0`.

## Artifacts/links
- PR: (tbd)
- Migration: (tbd)
- Test report: (tbd)
