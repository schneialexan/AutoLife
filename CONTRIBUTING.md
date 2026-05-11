# Contributing

## Setup

1. Install [Flutter](https://docs.flutter.dev/get-started/install) (stable).
2. Clone the repository and open a terminal at the **repository root** (the directory that contains `melos.yaml`).
3. Install root tooling and link packages:

   ```sh
   dart pub get
   dart run melos bootstrap
   ```

If you add or remove packages under `apps/` or `packages/`, run `dart run melos bootstrap` again.

## Checks before pushing

From the repository root:

```sh
dart format --set-exit-if-changed .
dart run melos run analyze
dart run melos run test
```

CI runs the same steps (see `.github/workflows/ci.yml`).

## Melos scripts

Defined in `melos.yaml`:

- `analyze` — `dart analyze` in each package
- `format` — `dart format --set-exit-if-changed .` from the repo root
- `test` — runs `dart test` / `flutter test` where `test/` exists (`test:core`, `test:ui`, and `test:shell` are available individually)

Run any script with:

```sh
dart run melos run <script>
```

## Supabase

Local development uses the `supabase/` directory. With Docker available:

```sh
supabase start
```

Migrations and Edge Functions live under `supabase/migrations` and `supabase/functions` respectively.
