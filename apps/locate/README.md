# AutoLocate

**Status:** planned · **Build order:** Expansion #12 (lowest priority)

Family safety / location. Built standalone last; strongest consent + audit requirements.

## Scope (standalone)
- Map with colored family-member pins; bottom-sheet member list with last-updated time.
- Saved places (home/school/work) with geofences.
- Geofence alert history.
- Emergency SOS button (high-priority, overriding alert to parents with GPS).
- "Where is my?" device-finding pings.

## Module contract
See [`docs/module-contract.md`](../../docs/module-contract.md).

- **Owns:** member locations, places, geofences, alerts.
- **Emits:** _(added step by step as built)_
- **Consumes:** _(added step by step as built)_
- **Renders:** dashboard "where is everyone" card — *consent-gated*; omnibar place results.

## Safety (non-negotiable)
Explicit consent model; audit log for every location access.
