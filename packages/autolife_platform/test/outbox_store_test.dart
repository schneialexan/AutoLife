import 'dart:io';

import 'package:autolife_platform/autolife_platform.dart';
import 'package:hive/hive.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory dir;
  late Box<String> box;
  late OutboxStore outbox;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('outbox_test');
    Hive.init(dir.path);
    box = await Hive.openBox<String>('sync_outbox');
    outbox = OutboxStore(box);
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    await Hive.close();
  });

  SyncMutation upsert(String id, DateTime updatedAt) => SyncMutation(
    moduleId: 'assets',
    entityType: 'item',
    entityId: id,
    operation: SyncOperation.upsert,
    payload: <String, dynamic>{'id': id},
    schemaVersion: 1,
    updatedAt: updatedAt,
    deviceId: 'd',
  );

  test('enqueue coalesces repeated edits to one entity', () async {
    await outbox.enqueue(upsert('a', DateTime.utc(2026, 1, 1)));
    await outbox.enqueue(upsert('a', DateTime.utc(2026, 1, 2)));
    expect(outbox.length, 1);
    expect(outbox.pending().single.updatedAt, DateTime.utc(2026, 1, 2));
  });

  test('pending is ordered by updatedAt', () async {
    await outbox.enqueue(upsert('b', DateTime.utc(2026, 1, 3)));
    await outbox.enqueue(upsert('a', DateTime.utc(2026, 1, 1)));
    final ids = outbox.pending().map((m) => m.entityId).toList();
    expect(ids, <String>['a', 'b']);
  });

  test('pendingForModule filters by module', () async {
    await outbox.enqueue(upsert('a', DateTime.utc(2026, 1, 1)));
    await outbox.enqueue(
      SyncMutation(
        moduleId: 'calendar',
        entityType: 'event',
        entityId: 'e1',
        operation: SyncOperation.upsert,
        schemaVersion: 1,
        updatedAt: DateTime.utc(2026, 1, 1),
        deviceId: 'd',
      ),
    );
    expect(outbox.pendingForModule('assets').length, 1);
    expect(outbox.pendingForModule('calendar').length, 1);
  });

  test('removeProcessed keeps a newer concurrent edit', () async {
    final processed = upsert('a', DateTime.utc(2026, 1, 1));
    await outbox.enqueue(processed);
    // A newer edit arrives for the same entity during the push.
    await outbox.enqueue(upsert('a', DateTime.utc(2026, 1, 5)));
    await outbox.removeProcessed(<SyncMutation>[processed]);
    expect(outbox.length, 1, reason: 'newer edit must survive');
    expect(outbox.pending().single.updatedAt, DateTime.utc(2026, 1, 5));
  });

  test('removeProcessed clears a pushed mutation', () async {
    final processed = upsert('a', DateTime.utc(2026, 1, 1));
    await outbox.enqueue(processed);
    await outbox.removeProcessed(<SyncMutation>[processed]);
    expect(outbox.isEmpty, isTrue);
  });
}
