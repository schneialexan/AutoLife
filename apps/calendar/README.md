# AutoCalendar

**Status:** planned · **Build order:** MVP #2

Smart family calendar. Built standalone first (local events only), then gains external sync
and cross-module reactions.

## Scope (standalone)
- Day / week / month (+ agenda) views with per-member coloring.
- 2-way external sync (Google / Apple / Outlook) — *setting-gated, direction configurable*.
- Auto-commute blocks from event location + traffic data — *toggleable*.
- Weather overlays with change flags (e.g. "Beach Day" → rain) — *toggleable*.
- Babysitter mode: temporary read-only link with configurable contents + expiry.

## Module contract
See [`docs/module-contract.md`](../../docs/module-contract.md).

- **Owns:** calendar events, external-sync config, babysitter links.
- **Emits:** _(added step by step as built)_
- **Consumes:** _(added step by step as built)_
- **Renders:** dashboard "today/upcoming" card; omnibar event results.

## Settings (every automation must be off-able)
Commute blocks, weather flags, external sync direction, babysitter link scope/duration.
