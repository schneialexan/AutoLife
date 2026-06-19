# AutoLife

A modular life-management hub for a household — one product that replaces ~10 separate
apps (calendar, to-dos, purchase/warranty tracking, meals, health, finance, and more).

The point isn't the feature count. It's **cross-module intelligence**: an action in one
app meaningfully triggers behavior in another.

> Scan a receipt → a warranty reminder lands on the calendar.
> Log a heavy period flow → pads get added to the grocery list.
> Check off 5 chores → a kid's allowance updates.

## This repo is design-open on purpose

We are **not** committing to a tech stack, a backend, or an integration mechanism yet.

The chosen way of working:

1. **Build each app as a self-contained, runnable product.**
2. **Keep the seams between apps stable and explicit.**
3. **Combine the apps cleanly — only once they're individually good.**

For step 3 to be "wiring" instead of "a rewrite", three things are fixed from day one,
while everything else stays open:

| Fixed seam | What it guarantees | Lives in |
|------------|-------------------|----------|
| **Module contract** | Every app declares what it owns, emits, consumes, and renders | [`docs/module-contract.md`](docs/module-contract.md) |
| **Event vocabulary** | Cross-module magic is just well-named events | [`docs/event-vocabulary.md`](docs/event-vocabulary.md) |
| **Design language** | Every app looks & feels like one product | [`docs/design-language.md`](docs/design-language.md) |

So we can actually run apps on a real phone, two decisions are now locked: **Flutter** as
the app framework and **GitHub Actions → GitHub Releases (sideload APK)** as the pipeline.
Everything else (database, sync engine, AI/OCR provider, monorepo vs. multi-repo, real
event bus vs. in-process) stays a **deferred decision**, tracked with its constraints in
[`docs/open-decisions.md`](docs/open-decisions.md).

## Two product principles run through everything

1. **Unified feel.** Every app looks and behaves like one product, even when built separately.
2. **Everything is a setting.** Almost every automation must be toggleable/tunable
   (commute blocks, weather flags, auto-downloads, AI autonomy, nag intensity, sync
   direction, conflict rules).

## Repository layout

```
AutoLife/
├── README.md              ← you are here
├── docs/                  ← the design (vision + the seams that let apps combine)
│   ├── vision.md          ← product vision & principles (distilled)
│   ├── idea-refined.md    ← the original raw idea (source of truth)
│   ├── app-catalog.md     ← index of every app, one row each
│   ├── module-contract.md ← the boundary every app honors (owns / emits / consumes / renders)
│   ├── event-vocabulary.md← the cross-module event names (the integration seam)
│   ├── design-language.md ← shared look/feel: tokens, components, interaction patterns
│   ├── open-decisions.md  ← tech-stack & integration decisions, each with its constraints
│   └── distribution.md    ← build/publish pipeline + how to install on the phone
├── apps/                  ← one folder per app; each is built & runs standalone first
│   ├── shell/             ← Dashboard / home (the host that composes the others)
│   ├── calendar/          ← AutoCalendar
│   ├── tasks/             ← AutoTasks
│   ├── assets/            ← AutoAssets (purchase / warranty vault)
│   ├── dine/              ← AutoDine (meals, groceries, nutrition)
│   ├── health/            ← AutoHealth (medical, wellness, cycle)
│   ├── finance/           ← AutoFinance (budgets, subscriptions)
│   ├── gallery/           ← AutoGallery (photos, files, memories)
│   ├── mail/              ← AutoMail (email ingestion + AI parsing)
│   ├── pets/              ← AutoPets
│   ├── maintain/          ← AutoMaintain (home + vehicles — may fold into assets)
│   └── locate/            ← AutoLocate (family safety / location)
├── packages/              ← shared code, EXTRACTED LATER from real app overlap (empty for now)
└── platform/              ← cross-cutting surfaces (Control Center, backend choice) — open
```

## App build order

**MVP set** (build first, in order): `shell` → `calendar` → `tasks` → `assets`.

**Expansion set** (priority order): `dine` → `health` → `finance` → `gallery` →
`mail` → `pets` → `maintain` → `locate`.

See [`docs/app-catalog.md`](docs/app-catalog.md) for the full list and one-line scope of each.

## Building & running

Apps are **Flutter** (Android-first; target device: Poco F5). The first app, `shell`, is
scaffolded; the rest are README stubs until built.

```sh
# run the shell app on a connected device / emulator
cd apps/shell
flutter run

# build a release APK
flutter build apk --release
```

**Publishing to your phone:** push a tag and let CI build + attach the APKs to a GitHub
Release, then sideload them:

```sh
git tag v0.1.0 && git push origin v0.1.0
```

Full pipeline + Poco F5 install steps: [`docs/distribution.md`](docs/distribution.md).

## How to build a new app (the rule)

1. Read [`docs/module-contract.md`](docs/module-contract.md) and [`docs/design-language.md`](docs/design-language.md).
2. Build the app so it **runs entirely on its own** (mock/local data is fine).
3. Declare its contract in its own `apps/<app>/README.md`: what it **owns**, **emits**, **consumes**, **renders**.
4. Register any new cross-module events in [`docs/event-vocabulary.md`](docs/event-vocabulary.md).
5. Only wire it into other apps once at least two apps need the seam — then extract shared
   bits into `packages/`.
