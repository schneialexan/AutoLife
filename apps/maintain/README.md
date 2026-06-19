# AutoMaintain

**Status:** planned · **Build order:** Expansion #11

Home + vehicle maintenance. Built standalone first.

> **Open question:** may be absorbed into [AutoAssets](../assets) as a "Maintenance" tab
> rather than shipping standalone. Decide during its planning phase. See
> [`docs/open-decisions.md`](../../docs/open-decisions.md).

## Scope (standalone)
- Maintenance schedule (icon, asset, due trigger, urgency).
- Mileage triggers (enter mileage → auto-create "Change Oil" task).
- Seasonal automation (e.g. "Winterize Sprinklers" from weather).
- Video-notes (record the electrician explaining the breaker box, pinned to the home).
- Home tricks/notes with images/video for future reference.
- Providers list with notes/ratings.

## Module contract
See [`docs/module-contract.md`](../../docs/module-contract.md).

- **Owns:** maintenance records, providers, home/vehicle profiles, video-notes.
- **Emits:** _(added step by step as built)_
- **Consumes:** _(added step by step as built)_
- **Renders:** dashboard "upcoming maintenance" card; omnibar results.
