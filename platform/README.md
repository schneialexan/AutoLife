# platform/

Cross-cutting surfaces that aren't standalone apps. Designed **after** several apps exist,
because they only make sense once there are modules to govern.

Planned contents (see [`docs/app-catalog.md`](../docs/app-catalog.md) and
[`Idea-Refined`](../docs/idea-refined.md) Part 5):

- **Control Center** — role/permission matrix, approval engine, privacy tiers, AI "leash"
  levels, nag-mode tuning, notification batching, integration manager,
  "Download My Life" export.
- **Backend / data layer** — whatever D2 in [`docs/open-decisions.md`](../docs/open-decisions.md)
  resolves to (auth, tenancy, storage, sync, RLS).
- **Integration gateway** — external connectors (calendars, maps, stores, OCR/AI) behind
  swappable interfaces.

Nothing is built here yet — this is a placeholder marking where platform concerns will live.
