# Design Language

The promise: **every app looks and feels like one product**, even though each is built
separately. This file defines the shared language. It is intentionally
implementation-agnostic — it describes the *system*, not a specific UI framework.

When the [frontend decision](open-decisions.md) is made, this becomes the spec for a shared
design-system package (extracted into `packages/` once a second app needs it).

## Principles

- **One product, many modules.** A user should never feel they've left AutoLife when moving
  between apps. Same spacing, same motion, same component behavior.
- **Member color is a first-class concept.** Each family member has a color; it threads
  through calendars, tasks, avatars, and badges. (A setting may switch coloring to be by
  category instead of by member.)
- **Density adapts to the person/device.** A high-density "Command Center" for parents; a
  large-button, high-contrast "Kids Mode" for tablets.
- **Calm by default.** Notifications and automations are quiet unless the user opts into
  more aggressive behavior ("Nag Mode").

## Tokens (to be defined, not yet pinned)

These are the categories every app must consume from a shared source rather than
hard-coding:

- **Color** — brand palette, semantic roles (success/warning/danger/info), member colors,
  surface/background elevations, light + dark.
- **Typography** — type scale, weights, the display/body/label roles.
- **Spacing** — a single spacing scale used everywhere.
- **Radius & elevation** — corner radii and shadow/elevation levels.
- **Motion** — standard durations and easing for transitions.
- **Iconography** — one icon set + sizing rules.

## Core components (the shared kit)

Components every app reuses so they behave identically:

- App scaffold / nav (bottom nav + tabs), app bar
- Cards (the dashboard widget surface), list rows, section headers
- Buttons (primary / secondary / destructive), inputs, chips/badges
- Member avatar + member badge (carries member color)
- Empty states, loading states, error states
- Omnibar (shared search surface)
- Date/time pickers, the calendar grid primitives

## Interaction patterns

- **Floating "+"** is context-aware (creates the relevant entity for the current app).
- **Long-press** exposes power actions (e.g. convert event ↔ task).
- **Settings are discoverable where the behavior lives**, not only in a global panel.
- **Privacy affordances are visible** (lock icons on sensitive modules/sections).

## Until a stack is chosen

Apps may build their own local UI, but should keep visual decisions aligned with this doc
so the eventual extraction into a shared design system is mechanical, not a redesign.
