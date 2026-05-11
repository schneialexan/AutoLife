import 'package:autolife_core/autolife_core.dart';
import 'package:test/test.dart';

void main() {
  final next = DateTime.utc(2026, 5, 11, 9, 15);

  test('JSON round-trip including dead_letter status', () {
    for (final status in EventDeliveryStatus.values) {
      final original = EventDelivery(
        id: 'd1',
        eventId: 'e1',
        consumer: 'dashboard',
        attempt: 2,
        status: status,
        lastError: status == EventDeliveryStatus.pending ? null : 'x',
        nextAttemptAt: status == EventDeliveryStatus.succeeded ? null : next,
      );
      expect(EventDelivery.fromJson(original.toJson()), original);
    }
  });

  test('copyWith', () {
    const base = EventDelivery(
      id: 'd1',
      eventId: 'e1',
      consumer: 'c',
      attempt: 0,
      status: EventDeliveryStatus.pending,
    );
    final bumped = base.copyWith(
      attempt: 1,
      status: EventDeliveryStatus.failed,
    );
    expect(bumped.attempt, 1);
    expect(bumped.status, EventDeliveryStatus.failed);
    expect(bumped.consumer, base.consumer);
  });
}
