---
name: calendar-ux-rich-fields
overview: "Implement the three requested calendar UX improvements in `apps/auto-calendar`: richer Month cells with titled timed-event rows, complete Event Detail surface, and a full-feature Event Form with persisted rich fields (images/URLs/related events) end-to-end."
todos:
  - id: schema-model
    content: Add rich event fields to core model + Supabase migration + schema parity coverage
    status: completed
  - id: month-view-rows
    content: Implement month cell titled rows with sort, color persistence, and overflow scroll behavior
    status: completed
  - id: detail-screen-complete
    content: Expand event detail screen to render all event metadata including recurrence/reminders/rich fields
    status: completed
  - id: form-rich-editor
    content: Upgrade full event form with rich controls and save pipeline for new fields
    status: completed
  - id: validation
    content: Update/add tests and run analyze/test checks for auto-calendar and autolife-core
    status: completed
isProject: false
---

# Calendar UX + Rich Event Data Plan

## Scope
- Improve Month view to show titled timed-event rows per day (sorted by start time), while preserving member color coding.
- Expand event details to display all available metadata (including recurrence and reminders) plus new rich fields.
- Expand full event form to support additional fields similar to mainstream calendar tools, and persist them end-to-end.
- Implement persistence now (model + repository + migration + UI wiring), per your choice.

## Implementation Steps

1. **Extend event domain + storage for rich fields**
- Update event model in [c:\Users\alexa\Documents\Private\AutoLife\packages\autolife-core\lib\src\calendar\calendar_event.dart](c:\Users\alexa\Documents\Private\AutoLife\packages\autolife-core\lib\src\calendar\calendar_event.dart) with:
  - `attachments` (image/file refs)
  - `links` (URL entries)
  - `relatedEventIds` (linked events)
  - `attendees` / extra tags as needed for form parity
- Add serialization/deserialization + `copyWith` coverage for all new fields.
- Update DB schema via new migration under [c:\Users\alexa\Documents\Private\AutoLife\supabase\migrations](c:\Users\alexa\Documents\Private\AutoLife\supabase\migrations) to add corresponding columns (`jsonb`/array-friendly types), indexes if needed, and sensitivity registry rows.
- Keep RLS policy shape unchanged unless new table(s) are introduced.

2. **Wire repository persistence for new fields**
- Ensure `upsert`/`watch` in [c:\Users\alexa\Documents\Private\AutoLife\packages\autolife-core\lib\src\calendar\calendar_repository.dart](c:\Users\alexa\Documents\Private\AutoLife\packages\autolife-core\lib\src\calendar\calendar_repository.dart) round-trip new fields for:
  - `MemoryCalendarRepository`
  - `SupabaseCalendarRepository`
- Validate that existing offline queue path still handles richer `payload` without special-casing.

3. **Month view: titled rows + intra-cell scrolling**
- Rework day cell rendering in [c:\Users\alexa\Documents\Private\AutoLife\apps\auto-calendar\lib\src\screens\calendar\views\month_view.dart](c:\Users\alexa\Documents\Private\AutoLife\apps\auto-calendar\lib\src\screens\calendar\views\month_view.dart):
  - Header row stays as day number + weather indicator.
  - Body shows timed events sorted by `startAt`.
  - Show at least first 3 rows immediately.
  - Allow scroll for overflow rows inside cell.
  - Preserve member-color indicator in each row (left stripe/dot/chip).
- Use desktop/web pointer behavior to keep scrollbar unobtrusive by default and visible on hover/interaction where platform allows.

4. **Event detail: complete information surface**
- Expand [c:\Users\alexa\Documents\Private\AutoLife\apps\auto-calendar\lib\src\screens\calendar\event_detail_screen.dart](c:\Users\alexa\Documents\Private\AutoLife\apps\auto-calendar\lib\src\screens\calendar\event_detail_screen.dart) sections:
  - Core: title, date/time, all-day, location
  - People: creator, tagged members, attendees
  - Scheduling: recurrence rule details, reminders, series/exception metadata
  - Content: notes, links, attachments, related events
  - Sync metadata: provider/external IDs where present
- Ensure graceful empty-state rendering for optional fields.

5. **Full event form: richer editor controls**
- Upgrade [c:\Users\alexa\Documents\Private\AutoLife\apps\auto-calendar\lib\src\screens\calendar\event_form_screen.dart](c:\Users\alexa\Documents\Private\AutoLife\apps\auto-calendar\lib\src\screens\calendar\event_form_screen.dart):
  - Time controls + all-day toggle
  - Member tagging + attendees chips
  - Notes editor
  - URL list editor
  - Attachment list editor (initially metadata + local picker hook point)
  - Related-event picker (from current family events)
  - Recurrence/reminder controls (reuse [recurrence_editor_sheet.dart](c:\Users\alexa\Documents\Private\AutoLife\apps\auto-calendar\lib\src\screens\calendar\recurrence_editor_sheet.dart) where possible)
- Save path must build full `CalendarEvent` and persist all fields.

6. **Cross-screen wiring adjustments**
- Update any navigation payload assumptions in:
  - [c:\Users\alexa\Documents\Private\AutoLife\apps\auto-calendar\lib\src\screens\calendar\widgets\event_card.dart](c:\Users\alexa\Documents\Private\AutoLife\apps\auto-calendar\lib\src\screens\calendar\widgets\event_card.dart)
  - [c:\Users\alexa\Documents\Private\AutoLife\apps\auto-calendar\lib\src\screens\calendar\calendar_screen.dart](c:\Users\alexa\Documents\Private\AutoLife\apps\auto-calendar\lib\src\screens\calendar\calendar_screen.dart)
- Keep current quick-create behavior, but ensure events created there still display correctly in new month/detail UIs.

7. **Tests + verification**
- Extend/add tests in:
  - [c:\Users\alexa\Documents\Private\AutoLife\apps\auto-calendar\test\views\calendar_view_test.dart](c:\Users\alexa\Documents\Private\AutoLife\apps\auto-calendar\test\views\calendar_view_test.dart)
  - [c:\Users\alexa\Documents\Private\AutoLife\apps\auto-calendar\test\widget_test.dart](c:\Users\alexa\Documents\Private\AutoLife\apps\auto-calendar\test\widget_test.dart)
  - core model tests under [c:\Users\alexa\Documents\Private\AutoLife\packages\autolife-core\test](c:\Users\alexa\Documents\Private\AutoLife\packages\autolife-core\test)
- Add/adjust schema parity assertions for new migration.
- Run `flutter test` + `flutter analyze` for `apps/auto-calendar` and targeted `autolife-core` tests.

## Risks and Mitigations
- **Month cell overcrowding**: Keep fixed cell height and virtualized inner list; preserve predictable layout to avoid jitter.
- **Model/schema drift**: Implement model + migration in same milestone and cover with serialization and schema parity tests.
- **Form complexity**: Group fields into collapsible sections to keep primary flow fast while enabling advanced options.

## Acceptance Criteria (for this request)
- Month cells show titled, time-sorted timed-event rows with member color coding; overflow is scrollable within cell.
- Clicking event opens detail showing complete event metadata including recurrence/reminders and rich fields.
- Full form supports adding members/tags/notes/URLs/attachments/related-events and persists them end-to-end.
- Updated tests pass and analyzer remains clean except existing accepted deprecation infos.