import 'package:autolife_core/autolife_core.dart';
import 'package:test/test.dart';

void main() {
  test('Task.copyWith can clear nullable fields with explicit null', () {
    final now = DateTime.now().toUtc();
    final t = Task(
      id: 'a',
      familyId: 'f',
      listId: 'l',
      title: 'x',
      description: 'd',
      status: TaskStatus.active,
      priority: TaskPriority.medium,
      importance: false,
      dueAt: now,
      createdBy: 'u',
      createdAt: now,
      updatedAt: now,
    );
    final cleared = t.copyWith(
      description: null,
      dueAt: null,
    );
    expect(cleared.description, isNull);
    expect(cleared.dueAt, isNull);
    expect(cleared.title, 'x');
  });
}
