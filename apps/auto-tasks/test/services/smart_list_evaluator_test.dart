import 'package:auto_tasks/src/services/smart_list_evaluator.dart';
import 'package:autolife_core/autolife_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('smart list matches tags and due window', () {
    const eval = SmartListEvaluator();
    final rule = const TaskSmartRule(
      dueWithinDays: 7,
      tagsAny: ['chore'],
    );
    final t = Task(
      id: '1',
      familyId: 'f',
      listId: 'l',
      title: 'x',
      status: TaskStatus.active,
      priority: TaskPriority.medium,
      importance: false,
      dueAt: DateTime.now().toUtc().add(const Duration(days: 3)),
      tags: const ['chore'],
      createdBy: 'u',
      createdAt: DateTime.now().toUtc(),
      updatedAt: DateTime.now().toUtc(),
    );
    expect(
      eval.matches(
        task: t,
        rule: rule,
        nowUtc: DateTime.now().toUtc(),
        currentUserId: null,
      ),
      true,
    );
  });
}
