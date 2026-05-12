import 'package:auto_tasks/src/providers/task_providers.dart';
import 'package:auto_tasks/src/screens/tasks/task_detail_screen.dart';
import 'package:autolife_core/autolife_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('TaskDetailScreen edits title and importance', (tester) async {
    final repo = MemoryTaskRepository();
    final now = DateTime.now().toUtc();
    await repo.upsertList(
      TaskList(
        id: 'l1',
        familyId: 'f',
        name: 'List',
        createdAt: now,
        updatedAt: now,
      ),
    );
    await repo.upsertTask(
      Task(
        id: 'tid',
        familyId: 'f',
        listId: 'l1',
        title: 'Original',
        status: TaskStatus.active,
        priority: TaskPriority.medium,
        importance: false,
        createdBy: 'u1',
        createdAt: now,
        updatedAt: now,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          taskRepositoryProvider.overrideWithValue(repo),
          taskFamilyIdProvider.overrideWithValue('f'),
        ],
        child: const MaterialApp(
          home: TaskDetailScreen(familyId: 'f', taskId: 'tid'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Original'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'Renamed');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    final t = await repo.getTask(familyId: 'f', taskId: 'tid');
    expect(t!.title, 'Renamed');

    await tester.tap(find.byIcon(Icons.star_border));
    await tester.pumpAndSettle();

    final t2 = await repo.getTask(familyId: 'f', taskId: 'tid');
    expect(t2!.importance, isTrue);
  });

  testWidgets('TaskDetailScreen adds tag', (tester) async {
    final repo = MemoryTaskRepository();
    final now = DateTime.now().toUtc();
    await repo.upsertList(
      TaskList(
        id: 'l1',
        familyId: 'f',
        name: 'List',
        createdAt: now,
        updatedAt: now,
      ),
    );
    await repo.upsertTask(
      Task(
        id: 'tid',
        familyId: 'f',
        listId: 'l1',
        title: 'T',
        status: TaskStatus.active,
        priority: TaskPriority.medium,
        importance: false,
        createdBy: 'u1',
        createdAt: now,
        updatedAt: now,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          taskRepositoryProvider.overrideWithValue(repo),
          taskFamilyIdProvider.overrideWithValue('f'),
        ],
        child: const MaterialApp(
          home: TaskDetailScreen(familyId: 'f', taskId: 'tid'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('task_detail_tag_add')),
      'work',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    final t = await repo.getTask(familyId: 'f', taskId: 'tid');
    expect(t!.tags, contains('work'));
  });
}
