# AutoPets

**Status:** planned · **Build order:** Expansion #10

Pet management. Built standalone first, then links to tasks/calendar for care reminders.

## Scope (standalone)
- Pet profiles (photo, breed, age, status badges: Fed today / Walk needed / Vet appt).
- Quick actions per pet (Feed / Walk / Meds) with rotational chore (today's responsible member).
- Care schedule (feeding/medication check-off).
- Vet history + upcoming; vaccination records.
- Document vault (certificates, insurance, rabies docs).

## Module contract
See [`docs/module-contract.md`](../../docs/module-contract.md).

- **Owns:** pets, care schedules, vet records, pet documents.
- **Emits:** _(added step by step as built)_
- **Consumes:** _(added step by step as built)_
- **Renders:** dashboard "pet care today" card; omnibar pet results.
