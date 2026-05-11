---
name: phase1.1_monorepo_workspace_setup
overview: Stand up the Melos-managed Dart/Flutter monorepo with shared packages, app shells, and CI so every later Phase 1 plan can build, test, and lint a consistent workspace.
todos: []
isProject: false
---

# Phase 1.1 - Monorepo + Workspace Setup

## Objective
Create a reproducible Melos-driven workspace that hosts the Flutter shell app, the shared `autolife-core` and `autolife-ui` packages, and the Supabase functions tree, with CI enforcing formatting, analysis, and tests on every push so all downstream phase work starts from a green baseline.

## In scope
- Root Melos configuration, workspace pubspec, and shared analysis options.
- Skeleton package directories with valid `pubspec.yaml` and minimal library entry points so they resolve under `melos bootstrap`.
- Skeleton Flutter shell app at `apps/autolife-shell/` (already partly scaffolded) wired into the Melos workspace.
- Supabase project scaffolding at `supabase/` (config files, empty `migrations/` and `functions/` directories) so later phases can drop files in without restructuring.
- GitHub Actions CI pipeline running `melos bootstrap`, `dart format --set-exit-if-changed`, `dart analyze`, and `flutter test` (where applicable) across all workspace packages.
- Repository hygiene: top-level `.gitignore`, `README.md` overview, and `CONTRIBUTING.md` describing the Melos bootstrap workflow.

## Out of scope
- Any domain models, design tokens, or migrations (owned by 1.2, 1.3, 1.4 respectively).
- Release/signing configuration for Android or iOS.
- Code-generation pipelines (introduced incrementally by later phases that need them).
- Hosted CI runners other than GitHub Actions.

## Key deliverables
- [melos.yaml](melos.yaml) - workspace declaration listing `apps/*` and `packages/*`.
- [pubspec.yaml](pubspec.yaml) - root workspace pubspec used by Melos.
- [analysis_options.yaml](analysis_options.yaml) - shared lint set inherited by all packages.
- [packages/autolife-core/pubspec.yaml](packages/autolife-core/pubspec.yaml) and [packages/autolife-core/lib/autolife_core.dart](packages/autolife-core/lib/autolife_core.dart) - empty barrel file.
- [packages/autolife-ui/pubspec.yaml](packages/autolife-ui/pubspec.yaml) and [packages/autolife-ui/lib/autolife_ui.dart](packages/autolife-ui/lib/autolife_ui.dart) - empty barrel file.
- [apps/autolife-shell/pubspec.yaml](apps/autolife-shell/pubspec.yaml) wired to depend on the two shared packages via `path:` references.
- [supabase/config.toml](supabase/config.toml), [supabase/migrations/.gitkeep](supabase/migrations/.gitkeep), [supabase/functions/.gitkeep](supabase/functions/.gitkeep).
- [.github/workflows/ci.yml](.github/workflows/ci.yml) - CI pipeline.
- [README.md](README.md) and [CONTRIBUTING.md](CONTRIBUTING.md) describing bootstrap, run, and test commands.

## Dependencies
None. This is the foundational plan that all subsequent Phase 1 plans build on top of.

## Acceptance criteria (gate)
- [ ] `melos bootstrap` completes cleanly on a fresh clone with no warnings.
- [ ] `melos run analyze` (or equivalent `dart analyze` across packages) returns zero issues.
- [ ] `melos run format` (or `dart format --set-exit-if-changed .`) returns zero diffs on a clean tree.
- [ ] `melos run test` succeeds with at least one trivial passing test per package (`packages/autolife-core`, `packages/autolife-ui`, `apps/autolife-shell`).
- [ ] CI workflow in `.github/workflows/ci.yml` runs the same commands on push and PR and is green on `main`.
- [ ] `apps/autolife-shell` launches in `flutter run -d chrome` (or any platform) with a placeholder screen and resolves both shared packages from `path:` dependencies.
- [ ] `supabase/` contains a valid `config.toml` and empty `migrations/` and `functions/` trees recognized by `supabase start --no-backend` (or equivalent dry-run check).
- [ ] `README.md` documents the bootstrap, analyze, test, and run commands a new contributor needs.

## Risks + mitigations
- **Risk**: Inconsistent Dart/Flutter SDK versions between contributors causing `pub get` drift. / **Mitigation**: Pin `environment.sdk` and `flutter` ranges in every pubspec, document required versions in `README.md`, and add an SDK-version check step to CI.
- **Risk**: Melos workspace path layout conflicting with the partially scaffolded `apps/autolife-shell` tree. / **Mitigation**: Audit the existing shell app first, normalize directory naming, and add a Melos `ide.intellij: false` setting only after confirming the existing pubspec resolves under the workspace.
- **Risk**: CI runtime balloons as more packages join. / **Mitigation**: Use Melos `--scope` filters and GitHub Actions cache for `~/.pub-cache` from day one so the pattern is established before more packages are added.

## Implementation outline
1. Audit the existing `apps/autolife-shell/` tree and capture any structural fixes needed before introducing Melos.
2. Author the root `pubspec.yaml`, `melos.yaml`, and shared `analysis_options.yaml`, declaring workspace globs for `apps/*` and `packages/*`.
3. Create `packages/autolife-core` and `packages/autolife-ui` skeletons with passing trivial tests.
4. Update `apps/autolife-shell/pubspec.yaml` to consume both packages via relative `path:` dependencies.
5. Scaffold `supabase/` with `config.toml`, empty `migrations/`, and empty `functions/` directories plus `.gitkeep` placeholders.
6. Add Melos scripts for `bootstrap`, `analyze`, `format`, and `test` so contributors and CI invoke the same commands.
7. Author `.github/workflows/ci.yml` that installs Flutter, caches `~/.pub-cache`, runs `melos bootstrap`, then runs analyze/format/test.
8. Write `README.md` and `CONTRIBUTING.md` covering setup, daily workflows, and the Melos command surface.
9. Run the full pipeline locally on Windows and confirm green before opening the PR.
10. Tag the merge commit `phase-1.1-workspace-ready` so later plans can pin to it if needed.

## Artifacts/links
- PR: (tbd)
- Migration: (tbd)
- Test report: (tbd)
