import 'package:auto_tasks/src/services/dependency_resolver.dart';
import 'package:autolife_core/autolife_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const resolver = DependencyResolver();
  const fam = 'f1';

  test('rejects cycle', () {
    final edges = [
      TaskDependency(id: 'd1', familyId: fam, taskId: 'a', prerequisiteTaskId: 'b', createdAt: DateTime.now().toUtc()),
      TaskDependency(id: 'd2', familyId: fam, taskId: 'b', prerequisiteTaskId: 'a', createdAt: DateTime.now().toUtc()),
    ];
    expect(
      () => resolver.validateAcyclic(edges),
      throwsA(isA<TaskDependencyCycleException>()),
    );
  });

  test('isLocked when prerequisite incomplete', () {
    final a = Task(
      id: 'a',
      familyId: fam,
      listId: 'l',
      title: 'A',
      status: TaskStatus.active,
      priority: TaskPriority.medium,
      importance: false,
      createdBy: 'u',
      createdAt: DateTime.now().toUtc(),
      updatedAt: DateTime.now().toUtc(),
    );
    final b = Task(
      id: 'b',
      familyId: fam,
      listId: 'l',
      title: 'B',
      status: TaskStatus.inbox,
      priority: TaskPriority.medium,
      importance: false,
      createdBy: 'u',
      createdAt: DateTime.now().toUtc(),
      updatedAt: DateTime.now().toUtc(),
    );
    final edges = [
      TaskDependency(id: 'd1', familyId: fam, taskId: 'a', prerequisiteTaskId: 'b', createdAt: DateTime.now().toUtc()),
    ];
    expect(resolver.isLocked(task: a, allTasks: [a, b], edges: edges), true);
    final bDone = b.copyWith(status: TaskStatus.completed);
    expect(resolver.isLocked(task: a, allTasks: [a, bDone], edges: edges), false);
  });
}
