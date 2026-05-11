import 'package:autolife_core/autolife_core.dart';
import 'package:test/test.dart';

void main() {
  final occurred = DateTime.utc(2026, 5, 11, 12, 30);

  test('JSON round-trip', () {
    final original = EventEnvelope(
      idempotencyKey: 'ik-1',
      orderingTag: 'seq:42',
      occurredAt: occurred,
      sourceModule: 'calendar',
    );
    expect(EventEnvelope.fromJson(original.toJson()), original);
  });

  test('copyWith overrides fields', () {
    final base = EventEnvelope(
      idempotencyKey: 'ik-1',
      orderingTag: 'seq:42',
      occurredAt: occurred,
      sourceModule: 'calendar',
    );
    final next = base.copyWith(sourceModule: 'tasks');
    expect(next.sourceModule, 'tasks');
    expect(next.idempotencyKey, base.idempotencyKey);
  });
}
