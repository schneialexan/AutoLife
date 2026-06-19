# Shell / Dashboard

**Status:** scaffolded (Flutter, Android) · **Build order:** MVP #1

The home of AutoLife and the host that composes other modules' cards. Built standalone
first (works with zero modules installed), then becomes the surface that aggregates them.

## Scope (standalone)
- Adaptive home screen (morning vs. evening layout).
- Family / role management: invite members, assign member colors, set permissions.
- Universal omnibar search surface.
- Morning/evening briefings.

## Module contract
See [`docs/module-contract.md`](../../docs/module-contract.md).

- **Owns:** household/members, member colors, dashboard layout, global settings entry points.
- **Emits:** _(added step by step as built)_
- **Consumes:** dashboard-render + omnibar contributions from every other module
  _(specific events added step by step as built)_.
- **Renders:** the dashboard grid and omnibar (the shared surfaces other modules render into).

## Notes
The shell defines the slots; other modules fill them. It must render gracefully when a
module is absent.
