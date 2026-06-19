# Module Contract

Every AutoLife app is a **module**. A module can run completely on its own *and* slot into
the wider hub without changes to its internals. The only thing that makes both possible is
that every module honors the same small, explicit contract.

This contract is **stack-agnostic on purpose**. It describes *what* a module exposes, not
*how* (no language, framework, or transport is assumed). The "how" is an
[open decision](open-decisions.md).

## A module declares four things

Each app states these in its own `apps/<app>/README.md`.

### 1. Owns (data)
The data this module is the source of truth for. No other module writes it directly.
Other modules only learn about it through **events** or a **read surface**.

> Example (assets): assets, receipts, warranties, claims, maintenance records.

### 2. Emits (events out)
Named events this module publishes when something happens. Other modules may react.
The module must work fine even if **nobody** is listening.

> Example (assets): `asset.created`, `asset.warranty.expiring`, `asset.return_window.ending`.

### 3. Consumes (events in)
Named events from other modules this one reacts to. The module must work fine even if
those events **never arrive** (e.g. when running standalone).

> Example (calendar): consumes `asset.warranty.expiring` → offers to create a reminder event.

### 4. Renders (surfaces)
Optional UI the module can contribute to shared spaces — primarily the **shell dashboard**
(a card/widget) and the **omnibar** (searchable results). Declared, not assumed.

> Example (tasks): a "Today" dashboard card; omnibar results for task titles.

## The rules that keep modules combinable

1. **Standalone is the default.** If a dependency (another module, the backend, the
   network) is absent, the module degrades gracefully — it does not crash or block.
2. **Talk through events, not internals.** Modules never import another module's internal
   data layer. Cross-module behavior happens via the [event vocabulary](event-vocabulary.md).
3. **Own your data.** Exactly one module is the source of truth for any given record.
4. **Events are additive & named, never breaking.** Add new events; don't repurpose
   existing ones. Versioning rules live in [`event-vocabulary.md`](event-vocabulary.md).
5. **Settings gate every automation.** Any event a module emits *as automation* (e.g.
   auto-creating a calendar reminder) must be behind a user-visible toggle.
6. **Privacy is declared per data type.** Modules mark which owned data is sensitive so the
   platform privacy layer can gate it.

## What is intentionally NOT in this contract yet

- The transport for events (real message bus? in-process? function calls?) — open.
- The shape/serialization of event payloads beyond "named + versioned" — to be pinned
  once two real modules share an event.
- Auth, tenancy, and storage mechanics — these are platform concerns, decided later.

## Standalone → combined checklist (per app)

- [ ] Runs end-to-end on its own with local/mock data.
- [ ] `apps/<app>/README.md` lists Owns / Emits / Consumes / Renders.
- [ ] Every emitted automation event has a setting to disable it.
- [ ] New events are registered in [`event-vocabulary.md`](event-vocabulary.md).
- [ ] No imports of another module's internals.
