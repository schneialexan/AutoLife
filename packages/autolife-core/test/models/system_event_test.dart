import 'package:autolife_core/autolife_core.dart';
import 'package:test/test.dart';

void main() {
  final occurred = DateTime.utc(2026, 5, 11, 8, 0);

  test('JSON round-trip with snake_case keys', () {
    final original = SystemEvent(
      id: '11111111-1111-1111-1111-111111111111',
      tenantId: '22222222-2222-2222-2222-222222222222',
      actorId: '33333333-3333-3333-3333-333333333333',
      module: 'shell',
      type: 'app.opened',
      payload: {'route': '/', 'n': 1},
      idempotencyKey: 'idem-1',
      occurredAt: occurred,
      orderingTag: 'ot:9',
      schemaVersion: 1,
    );
    expect(SystemEvent.fromJson(original.toJson()), original);
  });

  test('copyWith preserves unspecified fields', () {
    final base = SystemEvent(
      tenantId: 't',
      actorId: 'a',
      module: 'm',
      type: 'ty',
      payload: const {},
      idempotencyKey: 'i',
      occurredAt: occurred,
      orderingTag: 'o',
      schemaVersion: 1,
    );
    final next = base.copyWith(type: 'ty2');
    expect(next.type, 'ty2');
    expect(next.module, 'm');
  });
}
