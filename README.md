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

## Milestone 2: `autolife-shell` (Supabase auth + bootstrap)

### Start Supabase locally (migrations + seed)

```bash
supabase start
supabase db reset --local
```

Get your local API keys:

```bash
supabase status
```

### Run the Flutter shell (web)

```bash
cd apps/autolife-shell
flutter run -d chrome ^
  --dart-define=SUPABASE_URL=http://127.0.0.1:54321 ^
  --dart-define=SUPABASE_ANON_KEY=YOUR_LOCAL_ANON_KEY
```

Behavior:
- **Signed out**: email/password sign-in + sign-up
- **Signed in**: setup spinner calls the `bootstrap` Edge Function until it returns `ready: true`
- Then routes to a **Ready** screen

### Verify trigger + bootstrap flow

- **Trigger**: on new `auth.users` insert, creates `public.families` row + `public.profiles` row.
- **Edge Function**: `supabase/functions/bootstrap` is idempotent; safe to call repeatedly.

### CI parity checks (run locally)

```bash
cd apps/autolife-shell
flutter build web --release
```

```bash
cd ../..
supabase start
supabase db reset --local
supabase stop
```

