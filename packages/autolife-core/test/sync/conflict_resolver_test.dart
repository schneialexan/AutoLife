import 'package:autolife_core/autolife_core.dart';
import 'package:test/test.dart';

void main() {
  group('LastWriterWinsResolver', () {
    test('favors newer updated_at', () {
      final r = LastWriterWinsResolver();
      final local = {
        'id': '1',
        'updated_at': '2026-01-01T00:00:00.000Z',
      };
      final remote = {
        'id': '1',
        'updated_at': '2026-02-01T00:00:00.000Z',
      };
      expect(
        r.resolve(
          localRow: local,
          remoteRow: remote,
          actorRole: null,
          localUpdated: DateTime.utc(2026, 1, 1),
          remoteUpdated: DateTime.utc(2026, 2, 1),
        ),
        ConflictWinner.remote,
      );
      expect(
        r.resolve(
          localRow: local,
          remoteRow: remote,
          actorRole: null,
          localUpdated: DateTime.utc(2026, 3, 1),
          remoteUpdated: DateTime.utc(2026, 2, 1),
        ),
        ConflictWinner.local,
      );
    });
  });

  group('ParentOverrideResolver', () {
    test('prefers parent role over child regardless of timestamp', () {
      final r = ParentOverrideResolver(parentRole: 'parent');
      final local = {
        'id': '1',
        'updated_at': '2026-01-01T00:00:00.000Z',
        'actor_role': 'parent',
      };
      final remote = {
        'id': '1',
        'updated_at': '2026-05-01T00:00:00.000Z',
        'actor_role': 'child',
      };
      expect(
        r.resolve(
          localRow: local,
          remoteRow: remote,
          actorRole: null,
          localUpdated: DateTime.utc(2026, 1, 1),
          remoteUpdated: DateTime.utc(2026, 5, 1),
        ),
        ConflictWinner.local,
      );
    });
  });

  group('CallbackConflictResolver', () {
    test('invokes custom lambda', () {
      var calls = 0;
      final r = CallbackConflictResolver(({
        required Map<String, dynamic> localRow,
        required Map<String, dynamic> remoteRow,
        required String? actorRole,
        DateTime? localUpdated,
        DateTime? remoteUpdated,
      }) {
        calls++;
        return ConflictWinner.remote;
      });
      r.resolve(
        localRow: const {},
        remoteRow: const {},
        actorRole: null,
        localUpdated: null,
        remoteUpdated: null,
      );
      expect(calls, 1);
    });
  });
}
