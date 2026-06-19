# Vision

AutoLife is a single, modular life-management hub for a household. It replaces ~10
separate apps and ties them together so that an action in one module intelligently
triggers behavior in others.

This file is the distilled vision. The original, fuller idea lives in
[`idea-refined.md`](idea-refined.md).

## What makes it AutoLife (not just a bundle of apps)

- **Cross-module intelligence.** Modules don't just coexist; they react to each other.
  This is the whole product. If two apps never talk, we've failed the premise.
- **Unified feel.** Everything looks and behaves like one product, even though each app
  is built separately. See [`design-language.md`](design-language.md).
- **Everything is a setting.** Every automation is toggleable and tunable. A user who
  hates a behavior must be able to turn it off, not just live with it.
- **Family-centric & private.** Multiple people, roles, and ages share the hub. Sensitive
  data (health, finance, location) needs granular, per-person privacy controls.
- **Offline-first.** Core flows (check off groceries, view the calendar) work with no
  connectivity and resolve conflicts on reconnect.

## Who it's for

A household: parents/co-parents, teens, young children, grandparents, plus scoped guests
(babysitters). Roles change with age and need different permissions and UI density.

## The three pillars that must always hold

1. **Modules are intelligent together** — the cross-module events in
   [`event-vocabulary.md`](event-vocabulary.md) are the product, not an afterthought.
2. **Modules are independent first** — each app in `apps/` builds and runs standalone.
3. **One coherent experience** — shared design language and interaction patterns.

## Global quality-of-life features (cross-cutting, not their own app)

- **Universal omnibar search** — one search box that queries everything (a receipt, a
  grocery item, a calendar event, and a task all surface for "Apple").
- **Offline mode engine** — local cache + conflict resolution.
- **Morning/evening briefings** — a daily digest push ("3 meetings, 2 tasks, rain later").
- **Printability** — export lists, calendars, and meal plans to clean PDFs.

## Non-goals (for now)

- Picking the final tech stack (tracked in [`open-decisions.md`](open-decisions.md)).
- Pixel-perfect screens before the contracts are stable.
- Premature shared infrastructure — shared code is *extracted* once real overlap exists,
  not designed up front.
