# AutoTasks

**Status:** planned · **Build order:** MVP #3

To-do + task engine. Built standalone first, then links to calendar and feeds allowance.

## Scope (standalone)
- Multiple named task lists (Family Wall, Groceries, Work, House Projects, Kid Chores…),
  each with the same full feature set, own icon/color/sharing.
- Per-list tabs: Inbox / Today / Projects / Done; a cross-list "Today" aggregate.
- Event ⇄ Task switching (convert an event into a clickable task and back).
- Sub-task dependencies (locked tasks until prerequisites are done) — *per-task + setting*.
- Quick-add bar; context-aware floating "+".

## Module contract
See [`docs/module-contract.md`](../../docs/module-contract.md).

- **Owns:** task lists, tasks, sub-tasks, dependencies, chores.
- **Emits:** _(added step by step as built)_
- **Consumes:** _(added step by step as built)_
- **Renders:** dashboard "today's tasks" card; omnibar task results.
