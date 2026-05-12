import 'package:autolife_core/autolife_core.dart';

List<TaskList> demoTaskLists(String familyId) {
  final now = DateTime.now().toUtc();
  return [
    TaskList(
      id: 'list-wall',
      familyId: familyId,
      name: 'Family Wall',
      colorHex: '#1565C0',
      position: 0,
      createdAt: now,
      updatedAt: now,
    ),
    TaskList(
      id: 'list-grocery',
      familyId: familyId,
      name: 'Groceries',
      colorHex: '#43A047',
      position: 1,
      createdAt: now,
      updatedAt: now,
      defaultReminderMinutesBeforeDue: 15,
    ),
  ];
}

List<Task> demoTasks(String familyId) {
  final now = DateTime.now().toUtc();
  final today = DateTime.utc(now.year, now.month, now.day);
  return [
    Task(
      id: 't-inbox',
      familyId: familyId,
      listId: 'list-wall',
      title: 'Sort recycling',
      status: TaskStatus.inbox,
      priority: TaskPriority.medium,
      importance: false,
      createdBy: '11111111-1111-1111-1111-111111111111',
      createdAt: now,
      updatedAt: now,
    ),
    Task(
      id: 't-myday',
      familyId: familyId,
      listId: 'list-grocery',
      title: 'Pick up bread',
      status: TaskStatus.active,
      priority: TaskPriority.high,
      importance: true,
      myDayDate: today,
      dueAt: today.add(const Duration(hours: 18)),
      assigneeIds: const ['11111111-1111-1111-1111-111111111111'],
      createdBy: '11111111-1111-1111-1111-111111111111',
      createdAt: now,
      updatedAt: now,
    ),
  ];
}
