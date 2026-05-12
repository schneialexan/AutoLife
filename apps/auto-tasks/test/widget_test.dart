import 'package:auto_tasks/src/providers/task_providers.dart';
import 'package:auto_tasks/src/tasks_module.dart';
import 'package:autolife_core/autolife_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('TasksModule builds', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          taskRepositoryProvider.overrideWithValue(MemoryTaskRepository()),
        ],
        child: const MaterialApp(
          home: TasksModule(familyId: 'demo-family'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Tasks'), findsOneWidget);
  });
}
