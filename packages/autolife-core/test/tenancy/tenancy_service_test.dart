import 'package:autolife_core/autolife_core.dart';
import 'package:test/test.dart';

void main() {
  group('Tenancy helpers', () {
    test('mapInvitePostgresCode maps P0001', () {
      expect(mapInvitePostgresCode('P0001'), 'invitation_logic_error');
      expect(mapInvitePostgresCode('xyz'), 'rpc_failed');
    });

    test('Family.fromJson maps families row', () {
      final j = {
        'id': 'f1',
        'name': 'Smith',
        'created_by': 'u1',
        'created_at': '2026-01-01T00:00:00.000Z',
        'archived_at': null,
        'settings': <String, dynamic>{'k': 1},
        'updated_at': '2026-01-02T00:00:00.000Z',
      };
      final f = Family.fromJson(j);
      expect(f.id, 'f1');
      expect(f.name, 'Smith');
      expect(f.settings['k'], 1);
    });

    test('Membership.fromJson maps memberships row', () {
      final j = {
        'family_id': 'f1',
        'user_id': 'u1',
        'role': 'partner',
        'joined_at': '2026-01-01T00:00:00.000Z',
        'removed_at': null,
        'updated_at': '2026-01-02T00:00:00.000Z',
      };
      final m = Membership.fromJson(j);
      expect(m.familyId, 'f1');
      expect(m.userId, 'u1');
      expect(m.role, FamilyRole.partner);
    });

    test('FamilyInvitation.fromJson', () {
      final j = {
        'id': 'i1',
        'family_id': 'f1',
        'email': 'a@b.com',
        'invited_role': 'partner',
        'invited_by': 'u2',
        'expires_at': '2026-02-01T00:00:00.000Z',
        'accepted_at': null,
        'revoked_at': null,
        'created_at': '2026-01-01T00:00:00.000Z',
        'updated_at': '2026-01-01T00:00:00.000Z',
      };
      final inv = FamilyInvitation.fromJson(j);
      expect(inv.email, 'a@b.com');
      expect(inv.invitedRole, FamilyRole.partner);
    });
  });
}
