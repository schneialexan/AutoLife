# App Catalog

Every AutoLife app, its scope in one line, and its status. Each app is built **standalone
first**, then combined via the [module contract](module-contract.md) and
[event vocabulary](event-vocabulary.md).

Status legend: `planned` · `in progress` · `standalone` (runs on its own) · `integrated`.

## MVP set (build first, in order)

| # | App | Folder | One-line scope | Status |
|---|-----|--------|----------------|--------|
| 1 | **Shell / Dashboard** | [`apps/shell`](../apps/shell) | Adaptive home, family/role management, omnibar, briefings; hosts other modules' cards | scaffolded |
| 2 | **AutoCalendar** | [`apps/calendar`](../apps/calendar) | Day/week/month, external 2-way sync, commute blocks, weather overlays, babysitter links | planned |
| 3 | **AutoTasks** | [`apps/tasks`](../apps/tasks) | Multiple named lists, event⇄task switching, sub-task dependencies, quick add | planned |
| 4 | **AutoAssets** | [`apps/assets`](../apps/assets) | Receipt scan → vault, warranty/return reminders, claim & maintenance timeline | planned |

## Expansion set (priority order, highest first)

| # | App | Folder | One-line scope | Status |
|---|-----|--------|----------------|--------|
| 5 | **AutoDine** | [`apps/dine`](../apps/dine) | Recipes & nutrition, store API/OCR sync, store-specific grocery sorting, pantry/expiry | planned |
| 6 | **AutoHealth** | [`apps/health`](../apps/health) | Cycle tracker, symptom/product logger, workout/calorie, meds refill, medical passport | planned |
| 7 | **AutoFinance** | [`apps/finance`](../apps/finance) | Free-trial killer, chore-linked allowance, expense splitting, subscriptions/bills | planned |
| 8 | **AutoGallery** | [`apps/gallery`](../apps/gallery) | Family photos/files/memories, auto-albums, cross-module photo linking | planned |
| 9 | **AutoMail** | [`apps/mail`](../apps/mail) | Shared family inbox, AI parsing of emails into events/tasks/renewals, rules | planned |
| 10 | **AutoPets** | [`apps/pets`](../apps/pets) | Rotational care chores, vet/meds tracking, document vault | planned |
| 11 | **AutoMaintain** | [`apps/maintain`](../apps/maintain) | Home + vehicle maintenance, mileage/seasonal triggers, video-notes *(may fold into assets)* | planned |
| 12 | **AutoLocate** | [`apps/locate`](../apps/locate) | Family location, geofences, SOS protocol *(lowest priority; strong consent needs)* | planned |

## Cross-cutting surfaces (not standalone apps)

These live at the platform level and are designed once several apps exist.

- **Control Center** — role/permission matrix, approval engine, privacy tiers, AI "leash",
  nag-mode tuning, integration manager, "Download My Life" export. → `platform/`
- **Global QoL** — omnibar, offline engine, morning/evening briefings, PDF export.
  Implemented partly in `shell` and partly as shared concerns.
