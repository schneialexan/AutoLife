# AutoDine

**Status:** planned · **Build order:** Expansion #5

Meals, groceries & nutrition. Built standalone first (manual recipes + lists), then syncs
with stores and reacts to receipts/health.

## Scope (standalone)
- Recipe & nutrition vault (enter macros once, saved forever).
- Two logging paths: store API sync (Coop/Migros, extensible by URL) and camera OCR of
  nutrition labels.
- Store-specific grocery sorting (per the store you're visiting).
- Live store inventory checks (flag out-of-stock at your default branch).
- Pantry/freezer inventory with expiry; recipe suggestions from expiring items.
- Deal ("Aktion") flags.

## Module contract
See [`docs/module-contract.md`](../../docs/module-contract.md).

- **Owns:** recipes, nutrition data, grocery lists, pantry inventory, store connections.
- **Emits:** _(added step by step as built)_
- **Consumes:** _(added step by step as built)_
- **Renders:** dashboard "expiring / meal plan" card; omnibar food + recipe results.
