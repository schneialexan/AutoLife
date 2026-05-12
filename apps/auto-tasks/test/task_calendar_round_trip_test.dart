import 'package:auto_tasks/src/services/task_calendar_bridge.dart';
import 'package:autolife_core/autolife_core.dart';
import 'package:flutter_test/flutter_test.dart';

/// Calendar ↔ tasks three-leg coverage (convert, schedule + linked update, promote).
/// Runs under `flutter test` without a device (integration_test driver not required).
void main() {
  test('convert envelope is idempotent (200 duplicate consumes)', () async {
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
    const producer = IgnoringEventProducer();
    final bridge = TaskCalendarBridge(
      taskRepo: tasks,
      calendarRepo: cal,
      tasksEmitter: TasksEventsEmitter(
        producer: producer,
        tenantId: 't',
        actorId: 'a',
      ),
      calendarEmitter: CalendarEventsEmitter(
        producer: producer,
        tenantId: 't',
        actorId: 'a',
      ),
      actorId: 'a',
    );
    final ev = CalendarEvent(
      id: 'e_conv',
      familyId: 'f',
      title: 'Meeting',
      startAt: now,
      endAt: now.add(const Duration(hours: 1)),
      allDay: false,
      createdBy: 'a',
      syncSource: 'internal',
      createdAt: now,
      updatedAt: now,
    );
    final payload = {'event': ev.toJson()};
    for (var i = 0; i < 200; i++) {
      await bridge.onConvertToTaskEnvelope(payload, 'l1');
    }
    final withSource =
        tasks.snapshotTasks('f').where((t) => t.sourceEventId == 'e_conv').length;
    expect(withSource, 1);
  });

  test('schedule + linked_task_update + promote round-trip', () async {
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
    const producer = IgnoringEventProducer();
    final calEmitter = CalendarEventsEmitter(
      producer: producer,
      tenantId: 't',
      actorId: 'a',
    );
    final tasksEmitter = TasksEventsEmitter(
      producer: producer,
      tenantId: 't',
      actorId: 'a',
    );
    final bridge = TaskCalendarBridge(
      taskRepo: tasks,
      calendarRepo: cal,
      tasksEmitter: tasksEmitter,
      calendarEmitter: calEmitter,
      actorId: 'a',
    );

    await tasks.upsertTask(
      Task(
        id: 't_sched',
        familyId: 'f',
        listId: 'l1',
        title: 'Deep work',
        status: TaskStatus.active,
        priority: TaskPriority.medium,
        importance: false,
        createdBy: 'a',
        createdAt: now,
        updatedAt: now,
      ),
    );
    final t0 = (await tasks.getTask(familyId: 'f', taskId: 't_sched'))!;
    final startBlock = now.add(const Duration(days: 1));
    final endBlock = startBlock.add(const Duration(hours: 2));
    await bridge.scheduleTaskBlock(
      task: t0,
      startUtc: startBlock,
      endUtc: endBlock,
    );
    final tAfter = await tasks.getTask(familyId: 'f', taskId: 't_sched');
    expect(tAfter!.scheduledEventId, isNotNull);
    final calEvents = await cal.watchFamily('f').first;
    final block = calEvents.firstWhere((e) => e.id == tAfter.scheduledEventId);
    expect(block.isTaskBlock, isTrue);
    expect(block.linkedTaskId, 't_sched');

    await bridge.onLinkedTaskUpdateEnvelope({
      'family_id': 'f',
      'linked_task_id': 't_sched',
      'start_at': startBlock.add(const Duration(hours: 1)).toIso8601String(),
      'end_at': endBlock.add(const Duration(hours: 1)).toIso8601String(),
    });
    final tMoved = await tasks.getTask(familyId: 'f', taskId: 't_sched');
    expect(tMoved!.scheduledFor, startBlock.add(const Duration(hours: 1)));

    await tasks.upsertTask(
      Task(
        id: 't_prom',
        familyId: 'f',
        listId: 'l1',
        title: 'Ship it',
        status: TaskStatus.active,
        priority: TaskPriority.high,
        importance: true,
        scheduledFor: now.add(const Duration(days: 2)),
        createdBy: 'a',
        createdAt: now,
        updatedAt: now,
      ),
    );
    final toPromote = (await tasks.getTask(familyId: 'f', taskId: 't_prom'))!;
    final promoteEnv = EventEnvelope(
      idempotencyKey: 'promote:t_prom',
      orderingTag: 'promote:t_prom',
      occurredAt: DateTime.now().toUtc(),
      sourceModule: 'test',
    );
    await bridge.promoteTaskToEvent(toPromote, promoteEnv);
    final promoted = await tasks.getTask(familyId: 'f', taskId: 't_prom');
    expect(promoted!.status, TaskStatus.completed);
    expect(promoted.sourceTaskId, isNotNull);
    final calAfterPromote = await cal.watchFamily('f').first;
    expect(
      calAfterPromote.any(
        (e) => e.linkedTaskId == 't_prom' && e.id == promoted.sourceTaskId,
      ),
      isTrue,
    );
  });
}
