import 'dart:typed_data';

import 'package:autolife_core/autolife_core.dart';
import 'package:cryptography/cryptography.dart';
import 'package:test/test.dart';

void main() {
  test('duplicate idempotency key is a no-op', () async {
    final db = AutolifeDatabase.memory();
    final cipher = PayloadCipher(SecretKey(Uint8List(32)));
    final q = DriftOfflineWriteQueue(db, cipher);
    final env = OfflineWritePayloadBuilder.build(
      tenantId: 't1',
      actorId: 'a1',
      targetTable: 'profile',
      operation: 'insert',
      idempotencyKey: 'idem-1',
      payload: {'display_name': 'x'},
    );
    expect(
      (await q.enqueue(
        env,
      )).maybeWhen(success: (_) => true, orElse: () => false),
      isTrue,
    );
    expect(
      (await q.enqueue(
        env,
      )).maybeWhen(success: (_) => true, orElse: () => false),
      isTrue,
    );
    final d = await q.depth();
    expect(d.maybeWhen(success: (x) => x, orElse: () => -1), 1);
  });

  test(
    'fifo within target_table — lexicographic table order, then created_at',
    () async {
      final db = AutolifeDatabase.memory();
      final cipher = PayloadCipher(SecretKey(Uint8List(32)));
      final q = DriftOfflineWriteQueue(db, cipher);
      Future<void> e(String table, String suffix) async {
        final r = await q.enqueue(
          OfflineWritePayloadBuilder.build(
            tenantId: 't1',
            actorId: 'a',
            targetTable: table,
            operation: 'insert',
            idempotencyKey: 'i$table$suffix',
            payload: {'id': '$table$suffix'},
          ),
        );
        expect(r.maybeWhen(success: (_) => true, orElse: () => false), isTrue);
      }

      await e('profile', '1');
      await e('families', '1');
      await e('profile', '2');
      final first = await q.dequeue();
      final m = first.maybeWhen(success: (x) => x, orElse: () => null);
      expect(m?['_meta']?['target_table'], 'families');
    },
  );
}
