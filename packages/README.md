# packages/

Shared code — **extracted later**, not designed up front.

This folder stays empty until real overlap appears between apps. The rule (from the root
[README](../README.md)): build apps standalone, and only when **two or more** apps need the
same thing do we pull it out into a package here.

Likely first extractions, when the time comes:
- **design-system** — the tokens + core components from [`docs/design-language.md`](../docs/design-language.md).
- **events** — the shared event names/types from [`docs/event-vocabulary.md`](../docs/event-vocabulary.md).
- **core/contracts** — shared domain types once two apps exchange the same data.

Do **not** pre-create these. Let the apps tell us what's actually shared.
