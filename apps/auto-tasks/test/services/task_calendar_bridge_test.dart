import 'package:auto_tasks/src/services/task_calendar_bridge.dart';
import 'package:autolife_core/autolife_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('convert idempotent on sourceEventId', () async {
    final tasks = MemoryTaskRepository();
    final cal = MemoryCalendarRepository();
    final now = DateTime.now().toUtc();
    await tasks.upsertList(
      TaskList(
        id: 'l1',
        familyId: 'f',
        name: 'L',
        createdAt: now,
        updatedAt: now,
      ),
    );
    final emitterBase = CalendarEventsEmitter(
      producer: const IgnoringEventProducer(),
      tenantId: 't',
      actorId: 'a',
    );
    final tasksEmitter = TasksEventsEmitter(
      producer: const IgnoringEventProducer(),
      tenantId: 't',
      actorId: 'a',
    );
    final bridge = TaskCalendarBridge(
      taskRepo: tasks,
      calendarRepo: cal,
      tasksEmitter: tasksEmitter,
      calendarEmitter: emitterBase,
      actorId: 'a',
    );
    final ev = CalendarEvent(
      id: 'e1',
      familyId: 'f',
      title: 'Meet',
      startAt: now,
      endAt: now.add(const Duration(hours: 1)),
      allDay: false,
      createdBy: 'a',
      syncSource: 'internal',
      createdAt: now,
      updatedAt: now,
    );
    final p1 = {'event': ev.toJson()};
    final t1 = await bridge.onConvertToTaskEnvelope(p1, 'l1');
    final t2 = await bridge.onConvertToTaskEnvelope(p1, 'l1');
    expect(t1.id, t2.id);
  });

  test('linked task update adjusts scheduledFor', () async {
    final tasks = MemoryTaskRepository();
    final now = DateTime.now().toUtc();
    await tasks.upsertList(
      TaskList(
        id: 'l1',
        familyId: 'f',
        name: 'L',
        createdAt: now,
        updatedAt: now,
      ),
    );
    await tasks.upsertTask(
      Task(
        id: 'tid',
        familyId: 'f',
        listId: 'l1',
        title: 'Work',
        status: TaskStatus.active,
        priority: TaskPriority.medium,
        importance: false,
        createdBy: 'a',
        createdAt: now,
        updatedAt: now,
      ),
    );
    final bridge = TaskCalendarBridge(
      taskRepo: tasks,
      calendarRepo: MemoryCalendarRepository(),
      tasksEmitter: TasksEventsEmitter(
        producer: const IgnoringEventProducer(),
        tenantId: 't',
        actorId: 'a',
      ),
      calendarEmitter: CalendarEventsEmitter(
        producer: const IgnoringEventProducer(),
        tenantId: 't',
        actorId: 'a',
      ),
      actorId: 'a',
    );
    await bridge.onLinkedTaskUpdateEnvelope({
      'family_id': 'f',
      'linked_task_id': 'tid',
      'start_at': now.add(const Duration(hours: 2)).toIso8601String(),
      'end_at': now.add(const Duration(hours: 3)).toIso8601String(),
    });
    final t = await tasks.getTask(familyId: 'f', taskId: 'tid');
    expect(t!.scheduledFor, isNotNull);
  });
}
