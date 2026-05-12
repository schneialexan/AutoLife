import 'package:auto_tasks/src/services/template_engine.dart';
import 'package:autolife_core/autolife_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('template applies 6 tasks atomically', () async {
    final repo = MemoryTaskRepository();
    final now = DateTime.now().toUtc();
    await repo.upsertList(
      TaskList(
        id: 'l1',
        familyId: 'f',
        name: 'L',
        createdAt: now,
        updatedAt: now,
      ),
    );
    const engine = TemplateEngine();
    final template = TaskTemplate(
      id: 'tpl',
      familyId: 'f',
      name: 'six',
      items: List.generate(
        6,
        (i) => TaskTemplateItem(title: 'T$i', dueOffsetMinutes: i * 10),
      ),
      createdAt: now,
      updatedAt: now,
    );
    final created = await engine.apply(
      template: template,
      listId: 'l1',
      familyId: 'f',
      createdBy: 'u',
      anchorUtc: now,
      repo: repo,
    );
    expect(created.length, 6);
    expect(repo.snapshotTasks('f').length, 6);
  });
}
