# AutoLife

Melos-managed monorepo for the AutoLife Flutter shell, shared Dart/Flutter packages, and Supabase backend scaffolding.

## Prerequisites

- **Flutter** (stable), including the bundled **Dart** SDK — see `environment` constraints in the root and package `pubspec.yaml` files (currently Dart **3.11** / Flutter **3.41**).
- **Melos** is a dev dependency at the repo root; use `dart run melos` after `dart pub get`.

Optional:

- **Supabase CLI** for local backend work (`supabase`).

## Bootstrap

From the repository root:

```sh
dart pub get
dart run melos bootstrap
```

`melos bootstrap` links path dependencies across `apps/*` and `packages/*` via generated `pubspec_overrides.yaml` files.

## Daily commands

Run these from the repository root:

| Task    | Command                      |
|---------|------------------------------|
| Analyze | `dart run melos run analyze` |
| Format  | `dart format .`              |
| Format (CI) | `dart format --set-exit-if-changed .` |
| Tests   | `dart run melos run test`    |

## Run the shell app

```sh
cd apps/autolife-shell
flutter run -d chrome
```

## Layout

- `apps/autolife-shell` — Flutter application entrypoint.
- `packages/autolife-core` — shared domain/contracts (expanded in Phase 1.2).
- `packages/autolife-ui` — shared UI/design system (expanded in Phase 1.3).
- `supabase/` — Supabase config, `migrations/`, and `functions/`.

See [CONTRIBUTING.md](CONTRIBUTING.md) for workflow details.
