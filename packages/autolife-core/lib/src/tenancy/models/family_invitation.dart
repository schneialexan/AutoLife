import 'package:freezed_annotation/freezed_annotation.dart';

import '../../policy/role.dart';

part 'family_invitation.freezed.dart';
part 'family_invitation.g.dart';

/// `public.family_invitations` row (excluding `token_hash` from optimistic responses).
@freezed
abstract class FamilyInvitation with _$FamilyInvitation {
  const factory FamilyInvitation({
    required String id,
    @JsonKey(name: 'family_id') required String familyId,
    required String email,
    @JsonKey(name: 'invited_role')
    @Default(FamilyRole.partner)
    FamilyRole invitedRole,
    @JsonKey(name: 'invited_by') required String invitedBy,
    @JsonKey(name: 'expires_at') required DateTime expiresAt,
    @JsonKey(name: 'accepted_at') DateTime? acceptedAt,
    @JsonKey(name: 'revoked_at') DateTime? revokedAt,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _FamilyInvitation;

  factory FamilyInvitation.fromJson(Map<String, dynamic> json) =>
      _$FamilyInvitationFromJson(json);
}
