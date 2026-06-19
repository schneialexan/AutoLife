# AutoHealth

**Status:** planned · **Build order:** Expansion #6

Medical, wellness & cycle tracker. The most privacy-sensitive app — built standalone first
with strong local privacy, then shares only what the user explicitly opts into.

## Scope (standalone)
- Predictive cycle tracker (phases from medical data + personal history).
- Deep symptom logger (flow intensity, cramps, mood, energy, custom pains).
- Product tracker (pads/tampons/cups) with grocery integration.
- Workout & calorie tracker (calories from exact exercises + current body weight).
- Medication tracker + refill loop.
- Medical passport (blood type, allergies, vaccination PDFs).
- Profile-aware: hides sections that don't apply (e.g. cycle hidden for non-women profiles).

## Module contract
See [`docs/module-contract.md`](../../docs/module-contract.md).

- **Owns:** cycle data, symptom logs, product usage, workouts, meds, medical passport.
- **Emits:** _(added step by step as built)_
- **Consumes:** _(added step by step as built)_
- **Renders:** dashboard cards (meds checklist, weight trend) — *gated by privacy + profile*.

## Privacy (non-negotiable)
Biometric gate; granular sharing (e.g. share phase only, hide all symptoms/flow). Sensitive
data is marked so the platform privacy layer can enforce it.
