import 'package:autolife_core/autolife_core.dart';
import 'package:test/test.dart';

void main() {
  test('Profile JSON round-trip with active_family_id', () {
    const original = Profile(
      id: 'p1',
      displayName: 'Alex',
      activeFamilyId: 'f1',
    );
    expect(Profile.fromJson(original.toJson()), original);
    final next = original.copyWith(displayName: 'Alexa');
    expect(next.displayName, 'Alexa');
    expect(next.id, original.id);
  });

  test('Family JSON round-trip and copyWith', () {
    final original = Family(
      id: 'f1',
      name: 'The Smiths',
      createdAt: DateTime.utc(2026, 1, 2),
      updatedAt: DateTime.utc(2026, 1, 2),
    );
    expect(Family.fromJson(original.toJson()), original);
    final next = original.copyWith(name: 'Smith');
    expect(next.name, 'Smith');
  });

  test('Membership JSON round-trip', () {
    final original = Membership(
      familyId: 'f1',
      userId: 'u1',
      role: FamilyRole.partner,
      joinedAt: DateTime.utc(2026, 1, 3),
      updatedAt: DateTime.utc(2026, 1, 3),
    );
    expect(Membership.fromJson(original.toJson()), original);
    expect(original.role, FamilyRole.partner);
  });
}
