import 'package:autolife_core/autolife_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Family JSON roundtrip', () {
    final value = Family(
      id: 'f1',
      name: 'Test',
      createdAt: DateTime.utc(2026, 1, 1),
    );

    final json = value.toJson();
    final parsed = Family.fromJson(json);

    expect(parsed.id, value.id);
    expect(parsed.name, value.name);
    expect(
        parsed.createdAt.toIso8601String(), value.createdAt.toIso8601String());
  });

  test('Profile JSON roundtrip', () {
    final value = Profile(
      id: 'u1',
      familyId: 'f1',
      displayName: 'Alex',
      role: 'co-parent',
      createdAt: DateTime.utc(2026, 1, 1),
    );

    final json = value.toJson();
    final parsed = Profile.fromJson(json);

    expect(parsed.familyId, value.familyId);
    expect(parsed.role, value.role);
  });

  test('SystemEvent JSON roundtrip', () {
    final value = SystemEvent(
      id: 'e1',
      familyId: 'f1',
      idempotencyKey: 'k1',
      type: 'demo.test',
      sourceModule: 'autolife-shell',
      payload: {'hello': 'world'},
      createdAt: DateTime.utc(2026, 1, 1),
    );

    final json = value.toJson();
    final parsed = SystemEvent.fromJson(json);

    expect(parsed.payload['hello'], 'world');
    expect(parsed.idempotencyKey, value.idempotencyKey);
  });

  test('EventDelivery JSON roundtrip', () {
    final value = EventDelivery(
      id: 'd1',
      eventId: 'e1',
      consumerModule: 'auto-calendar',
      status: 'pending',
      retryCount: 0,
      createdAt: DateTime.utc(2026, 1, 1),
    );

    final json = value.toJson();
    final parsed = EventDelivery.fromJson(json);

    expect(parsed.status, 'pending');
    expect(parsed.consumerModule, value.consumerModule);
  });
}
