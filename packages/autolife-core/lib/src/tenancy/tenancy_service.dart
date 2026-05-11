import '../common/result.dart';
import 'models/family.dart';
import 'models/family_invitation.dart';
import 'models/membership.dart';

/// Active membership bundled with its [Family] row (joined list projection).
final class TenancyEnrollment {
  const TenancyEnrollment({required this.membership, required this.family});

  final Membership membership;
  final Family family;
}

/// Canonical tenancy API (families, invitations, memberships, active family).
abstract class TenancyService {
  String? get currentUserId;

  Future<Result<TenancyEnrollment>> createFamily({required String name});

  Future<Result<void>> switchActiveFamily({required String familyId});

  Future<Result<List<TenancyEnrollment>>> listMyActiveEnrollments();

  Future<Result<void>> leaveFamily({required String familyId});

  Future<Result<void>> removeMember({
    required String familyId,
    required String userId,
  });

  Future<Result<FamilyInvitation>> sendInvitation({
    required String familyId,
    required String email,
    String invitedRole = 'partner',
  });

  Future<Result<List<FamilyInvitation>>> listPendingInvitationsForFamily({
    required String familyId,
  });

  Future<Result<List<FamilyInvitation>>> listOpenInvitationsForCurrentUser();

  Future<Result<Map<String, dynamic>>> acceptInvitation({
    required String token,
  });

  Future<Result<void>> revokeInvitation({required String invitationId});
}
