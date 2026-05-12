import 'package:auto_tasks/src/services/quick_add_parser.dart';
import 'package:autolife_core/autolife_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses acceptance grammar', () {
    final p = const QuickAddParser();
    final fixed = DateTime.utc(2026, 5, 12, 12);
    final r = p.parse('Buy milk tomorrow 5pm #grocery !! @sam *', now: fixed);
    expect(r.title.toLowerCase(), contains('buy milk'));
    expect(r.listSlug, 'grocery');
    expect(r.priority, TaskPriority.medium);
    expect(r.importance, true);
    expect(r.assigneeHint, 'sam');
    expect(r.dueAt, isNotNull);
  });
}
