---
name: Milestone 1 Plan
overview: Scaffold the AutoLife Melos monorepo, bootstrap shared packages (autolife-ui, autolife-core), create the Supabase schema baseline (multi-tenant family model with RLS), and wire up CI for lint/test/build.
todos:
  - id: root-scaffold
    content: Git init, create root files (.gitignore, README.md, analysis_options.yaml, pubspec.yaml, melos.yaml) and directory skeleton (apps/, packages/, supabase/)
    status: completed
  - id: autolife-ui
    content: "Bootstrap packages/autolife-ui: pubspec.yaml, barrel export, theme/colors, smoke test"
    status: completed
  - id: autolife-core
    content: "Bootstrap packages/autolife-core: pubspec.yaml, barrel export, models (family, profile, system_event, event_delivery), Supabase client wrapper, serialization tests"
    status: completed
  - id: supabase-init
    content: Run supabase init, authenticate MCP, create baseline_schema migration (families, profiles, system_events, event_deliveries with indexes)
    status: completed
  - id: supabase-rls
    content: Create baseline_rls migration with family-scoped RLS policies on all four tables
    status: completed
  - id: seed-data
    content: Write supabase/seed.sql with test family + two profiles for local dev
    status: completed
  - id: ci-pipeline
    content: Create .github/workflows/ci.yml with format, lint, and test jobs via Melos
    status: completed
isProject: false
---

# Milestone 1: Monorepo Foundation and Backend Baseline

## Objective

Stand up a fully buildable Melos monorepo with two shared Flutter packages and a Supabase schema baseline (multi-tenant `family_id`, `profiles`, `system_events`, `event_deliveries`, initial RLS). Wire CI so every PR is gated on lint, test, and build. No app features -- just the foundation everything else plugs into.

## Scope

**In scope:**
- `melos.yaml`, root `pubspec.yaml`, directory scaffold (`apps/`, `packages/`, `supabase/`)
- `packages/autolife-ui` -- design tokens, theme data, placeholder widget exports
- `packages/autolife-core` -- Supabase client wrapper, shared models, event bus types
- Supabase migration: `profiles`, `system_events`, `event_deliveries` tables with `family_id` tenant column and RLS
- GitHub Actions CI: lint, test, build matrix
- Root `.gitignore`, `analysis_options.yaml`, `README.md`

**Out of scope:**
- Any `apps/*` implementation (shell, calendar, tasks, assets, etc.)
- Docker / self-hosting setup
- Edge Functions
- Post-MVP modules
- Production deployment, secrets rotation, monitoring

---

## Prerequisites and Dependencies

| Dependency | Why | Action |
|---|---|---|
| Flutter SDK (stable) | All Dart/Flutter packages need it | Ensure installed locally; pin version in CI |
| Melos CLI | Workspace orchestration | `dart pub global activate melos` |
| Supabase CLI | Migrations, local dev | Install via `npm i -g supabase` or scoop |
| Supabase project | Remote database target | Create via dashboard or MCP (authenticate MCP first via `mcp_auth`) |
| GitHub repo | CI target | Initialize `git init` in workspace root |

---

## Implementation Steps

### Step 1: Git init and root scaffold

Create the root-level files and directory skeleton.

**Files to create:**
- `.gitignore` -- Dart/Flutter + Supabase + IDE ignores
- `README.md` -- project overview, setup instructions
- `analysis_options.yaml` -- shared lint rules (use `flutter_lints` or `very_good_analysis`)
- `pubspec.yaml` -- root workspace pubspec with `workspace:` field listing `packages/*` and `apps/*`
- `melos.yaml` -- workspace config with scripts for `bootstrap`, `lint:all`, `test:all`, `build:all`

**Directories to create (empty with `.gitkeep`):**
- `apps/` (empty for now -- Milestone 2+)
- `packages/`
- `supabase/`

Key `melos.yaml` content:

```yaml
name: autolife
packages:
  - packages/**
  - apps/**
scripts:
  bootstrap:
    run: melos exec -- flutter pub get
  lint:
    run: melos exec -- dart analyze --fatal-infos
  test:
    run: melos exec -- flutter test
  format:check:
    run: melos exec -- dart format --set-exit-if-changed .
```

Root `pubspec.yaml`:

```yaml
name: autolife_workspace
publish_to: none
environment:
  sdk: ">=3.4.0 <4.0.0"
workspace:
  - packages/autolife-ui
  - packages/autolife-core
```

### Step 2: Bootstrap `packages/autolife-ui`

Minimal Flutter package exporting design tokens and a placeholder theme.

**Files:**
- `packages/autolife-ui/pubspec.yaml` -- Flutter package, depends on `flutter`
- `packages/autolife-ui/lib/autolife_ui.dart` -- barrel export
- `packages/autolife-ui/lib/src/theme/` -- `autolife_theme.dart` (color scheme, typography, spacing constants), `autolife_colors.dart`
- `packages/autolife-ui/test/autolife_ui_test.dart` -- smoke test that theme builds without error

### Step 3: Bootstrap `packages/autolife-core`

Minimal Dart package for Supabase client, shared models, and event bus types.

**Files:**
- `packages/autolife-core/pubspec.yaml` -- depends on `supabase_flutter`, exports models
- `packages/autolife-core/lib/autolife_core.dart` -- barrel export
- `packages/autolife-core/lib/src/models/` -- `family.dart`, `profile.dart`, `system_event.dart`, `event_delivery.dart` (data classes matching the DB schema)
- `packages/autolife-core/lib/src/client/` -- `supabase_client_provider.dart` (thin init wrapper)
- `packages/autolife-core/test/models_test.dart` -- serialization round-trip tests for each model

### Step 4: Supabase project init and schema migration

Initialize the Supabase directory and create the baseline migration.

**4a. Initialize Supabase locally:**
```bash
supabase init    # creates supabase/config.toml, supabase/seed.sql
```

**4b. Authenticate Supabase MCP** (call `mcp_auth` tool) to enable `execute_sql`, `apply_migration`, and other MCP tools.

**4c. Create baseline migration** via `supabase migration new baseline_schema`. Write the following SQL:

```sql
-- Enable required extensions
create extension if not exists "uuid-ossp";

-- families table (tenant root)
create table public.families (
  id         uuid primary key default uuid_generate_v4(),
  name       text not null,
  created_at timestamptz not null default now()
);
alter table public.families enable row level security;

-- profiles table (one per auth user, linked to a family)
create table public.profiles (
  id         uuid primary key references auth.users(id) on delete cascade,
  family_id  uuid not null references public.families(id) on delete cascade,
  display_name text not null,
  role       text not null default 'co-parent'
               check (role in ('co-parent','teenager','child','grandparent','guest')),
  created_at timestamptz not null default now()
);
alter table public.profiles enable row level security;

create index idx_profiles_family_id on public.profiles(family_id);

-- system_events table (durable event bus)
create table public.system_events (
  id              uuid primary key default uuid_generate_v4(),
  idempotency_key text not null,
  type            text not null,
  source_module   text not null,
  payload         jsonb not null default '{}',
  family_id       uuid not null references public.families(id) on delete cascade,
  created_at      timestamptz not null default now()
);
alter table public.system_events enable row level security;

create unique index idx_system_events_idempotency
  on public.system_events(family_id, idempotency_key);
create index idx_system_events_family_id on public.system_events(family_id);

-- event_deliveries table (per-consumer delivery tracking)
create table public.event_deliveries (
  id              uuid primary key default uuid_generate_v4(),
  event_id        uuid not null references public.system_events(id) on delete cascade,
  consumer_module text not null,
  status          text not null default 'pending'
                    check (status in ('pending','processed','failed')),
  processed_at    timestamptz,
  retry_count     int not null default 0,
  last_error      text,
  created_at      timestamptz not null default now()
);
alter table public.event_deliveries enable row level security;

create unique index idx_event_deliveries_dedup
  on public.event_deliveries(event_id, consumer_module);
create index idx_event_deliveries_pending
  on public.event_deliveries(status) where status = 'pending';
```

**4d. RLS policies** (separate migration: `supabase migration new baseline_rls`):

```sql
-- families: members can read their own family
create policy "family_members_select" on public.families
  for select using (
    id in (select family_id from public.profiles where id = auth.uid())
  );

-- profiles: read own family, update own row
create policy "profiles_select_family" on public.profiles
  for select using (
    family_id in (select family_id from public.profiles where id = auth.uid())
  );
create policy "profiles_update_own" on public.profiles
  for update using (id = auth.uid());

-- system_events: insert + read own family only
create policy "events_insert_family" on public.system_events
  for insert with check (
    family_id in (select family_id from public.profiles where id = auth.uid())
  );
create policy "events_select_family" on public.system_events
  for select using (
    family_id in (select family_id from public.profiles where id = auth.uid())
  );

-- event_deliveries: read own family events only
create policy "deliveries_select_family" on public.event_deliveries
  for select using (
    event_id in (
      select id from public.system_events
      where family_id in (select family_id from public.profiles where id = auth.uid())
    )
  );
```

**Design notes (per Supabase best practices):**
- `family_id` on every tenant table with index for RLS filter performance (avoids sequential scan in policy subquery)
- `idempotency_key` unique per family prevents duplicate event processing
- Partial index on `event_deliveries.status = 'pending'` for efficient retry queries
- RLS enabled on ALL tables; policies use `auth.uid()` joined through `profiles` -- never `user_metadata`
- `profiles.id` references `auth.users(id)` directly -- single join, no extra lookup

### Step 5: Seed data (optional, for local dev)

Update `supabase/seed.sql` with a test family + two profiles for local development.

### Step 6: GitHub Actions CI

Create `.github/workflows/ci.yml`:

```yaml
name: CI
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  lint-test-build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          channel: stable
      - name: Install Melos
        run: dart pub global activate melos
      - name: Bootstrap
        run: melos bootstrap
      - name: Format check
        run: melos run format:check
      - name: Lint
        run: melos run lint
      - name: Test
        run: melos run test
```

This single job covers format, lint, and test for all packages. Build step is omitted since `autolife-ui` and `autolife-core` are library packages (no buildable app target yet).

---

## Risks and Mitigations

| # | Risk | Impact | Mitigation |
|---|------|--------|------------|
| 1 | **Melos/Flutter SDK version drift** -- CI installs latest stable which may break | Build failures on CI | Pin Flutter channel to `stable` in CI; add `.fvmrc` or `.flutter-version` for local parity |
| 2 | **Supabase MCP auth not yet connected** -- cannot run SQL or create migrations via MCP | Blocks schema step | Authenticate MCP as first action in Step 4; fallback to Supabase CLI locally |
| 3 | **RLS policy subquery perf on large datasets** -- nested `select family_id from profiles` in every policy | Slow queries at scale | Index on `profiles.family_id` created; can later extract to a `security definer` helper function in a private schema if perf degrades |
| 4 | **No Supabase project exists yet** -- remote target needed for `supabase link` | Blocks remote testing | Create project via Supabase dashboard before starting; local dev works without it via `supabase start` |
| 5 | **Scope creep into app features** -- temptation to add shell/dashboard code | Delays milestone | Strictly enforce: `apps/` stays empty with only `.gitkeep`; no app `pubspec.yaml` files in M1 |

---

## Definition of Done Checklist

- [x] `melos bootstrap` succeeds with zero errors from repo root
- [x] `melos run lint` passes with no fatal infos on both packages
- [x] `melos run test` passes -- at least 1 test per package (theme smoke test, model serialization test)
- [x] `melos run format:check` passes (all code formatted)
- [x] `supabase db reset` applies all migrations cleanly on a fresh local instance
- [x] RLS verification: query as unauthenticated user returns zero rows; query as authenticated user returns only own-family rows
- [x] `families`, `profiles`, `system_events`, `event_deliveries` tables exist with correct columns, types, and constraints
- [x] All indexes confirmed via `\di` or MCP inspection
- [ ] GitHub Actions CI workflow runs green on a push to `main`
- [ ] Repo structure matches the planned scaffold (no extra files, no missing directories)

---

## Recommended Execution

- **Mode:** Agent
- **Approach:** Execute steps 1-6 sequentially. Steps 1-3 (monorepo + packages) are pure file creation with no external dependencies. Step 4 (Supabase) requires MCP auth or CLI. Step 6 (CI) is independent of Step 4 and can be done in parallel.
- **Estimated effort:** ~1 focused agent session
