# auto_tasks

AutoLife task engine (phase 3.3): lists, smart tabs, calendar bridge, templates.

## Test

```bash
flutter test
```

`test/task_calendar_round_trip_test.dart` exercises convert idempotency (200×), `task.scheduled` + `event.linked_task_update`, and `task.promote_to_event` without an integration driver.
