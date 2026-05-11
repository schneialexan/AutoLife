import 'package:autolife_core/autolife_core.dart';
import 'package:test/test.dart';

void main() {
  test('Profile JSON round-trip and copyWith', () {
    const original = Profile(id: 'p1', displayName: 'Alex', familyId: 'f1');
    expect(Profile.fromJson(original.toJson()), original);
    final next = original.copyWith(displayName: 'Alexa');
    expect(next.displayName, 'Alexa');
    expect(next.id, original.id);
  });

  test('Family JSON round-trip and copyWith', () {
    const original = Family(id: 'f1', displayName: 'The Smiths');
    expect(Family.fromJson(original.toJson()), original);
    final next = original.copyWith(displayName: 'Smith');
    expect(next.displayName, 'Smith');
  });

  test('Membership JSON encodes Role as snake_case', () {
    final original = Membership(
      id: 'm1',
      familyId: 'f1',
      profileId: 'p1',
      role: Role.admin,
    );
    final json = original.toJson();
    expect(json['role'], 'admin');
    expect(Membership.fromJson(json), original);
    final next = original.copyWith(role: Role.owner);
    expect(next.role, Role.owner);
    expect(next.familyId, original.familyId);
  });
}
