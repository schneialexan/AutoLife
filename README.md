# AutoLife

AutoLife is a modular, multi-tenant family life management ecosystem built with **Flutter** and **Supabase**.

## Repo structure

```text
apps/        # (Milestone 1: empty) future Auto* apps
packages/    # shared packages
supabase/    # migrations + local supabase config
```

## Getting started (local)

Prereqs:
- Flutter (stable)
- Dart (comes with Flutter)
- Melos (`dart pub global activate melos`)
- Supabase CLI (optional for DB work)

Bootstrap:
- `melos bootstrap`

Quality checks:
- `melos run format:check`
- `melos run lint`
- `melos run test`

