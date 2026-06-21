import 'package:autolife_platform/autolife_platform.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SyncCursor', () {
    test('advances only to a later server timestamp', () {
      const cursor = SyncCursor(moduleId: 'assets');
      final t1 = DateTime.utc(2026, 1, 1, 12);
      final t2 = DateTime.utc(2026, 1, 1, 13);

      final advanced = cursor.advancedTo(t1);
      expect(advanced.lastServerUpdatedAt, t1);

      final further = advanced.advancedTo(t2);
      expect(further.lastServerUpdatedAt, t2);

      final unchanged = further.advancedTo(t1);
      expect(unchanged.lastServerUpdatedAt, t2);
    });

    test('round-trips through JSON', () {
      final cursor = SyncCursor(
        moduleId: 'assets',
        lastServerUpdatedAt: DateTime.utc(2026, 5, 1),
      );
      final restored = SyncCursor.fromJson(cursor.toJson());
      expect(restored.moduleId, 'assets');
      expect(restored.lastServerUpdatedAt, cursor.lastServerUpdatedAt);
    });

    test('null cursor round-trips', () {
      const cursor = SyncCursor(moduleId: 'assets');
      final restored = SyncCursor.fromJson(cursor.toJson());
      expect(restored.lastServerUpdatedAt, isNull);
    });
  });
}
