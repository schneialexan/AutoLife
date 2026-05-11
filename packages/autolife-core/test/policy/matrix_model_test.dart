import 'package:autolife_core/autolife_core.dart';
import 'package:test/test.dart';

void main() {
  test('parsePolicyMatrixYaml rejects bad root', () {
    expect(() => parsePolicyMatrixYaml('{}'), throwsArgumentError);
  });

  test('compareFamilyRoleWire orders known roles', () {
    expect(compareFamilyRoleWire('owner', 'partner'), lessThan(0));
    expect(compareFamilyRoleWire('teenager', 'child'), greaterThan(0));
  });

  test('ApprovalAutoRule.fromRow parses enum columns', () {
    final r = ApprovalAutoRule.fromRow({
      'id': 'rid',
      'family_id': 'f1',
      'role': 'teenager',
      'capability': 'calendar.create_event',
      'label': 'x',
      'enabled': true,
      'match': {'location_normalized': 'school'},
    });
    expect(r.role, FamilyRole.teenager);
    expect(r.matchesPayload(const {'location': 'School'}), isTrue);
    expect(r.matchesPayload(const {'location': 'Beach'}), isFalse);
  });
}
