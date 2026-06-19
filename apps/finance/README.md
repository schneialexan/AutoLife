# AutoFinance

**Status:** planned · **Build order:** Expansion #7

Budgets & subscriptions. Built standalone first, then links to chores (allowance) and mail.

## Scope (standalone)
- Spending overview (category donut, month-over-month).
- Subscriptions with renewal dates; free-trial killer (aggressive alarm before charge +
  cancel URL).
- Bills with due dates; statement/document vault.
- Chore-linked allowance (kid's digital piggy bank).
- Shared expense splitter (Splitwise-style, incl. currency conversion).

## Module contract
See [`docs/module-contract.md`](../../docs/module-contract.md).

- **Owns:** budgets, subscriptions, bills, expenses, allowances, financial documents.
- **Emits:** _(added step by step as built)_
- **Consumes:** _(added step by step as built)_
- **Renders:** dashboard "spend / trial alert" card; omnibar finance results — *privacy-gated*.

## Privacy
Biometric gate; explicit family sharing rules.
