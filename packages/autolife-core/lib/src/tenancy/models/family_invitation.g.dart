// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'family_invitation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FamilyInvitation _$FamilyInvitationFromJson(Map<String, dynamic> json) =>
    _FamilyInvitation(
      id: json['id'] as String,
      familyId: json['family_id'] as String,
      email: json['email'] as String,
      invitedRole:
          $enumDecodeNullable(_$FamilyRoleEnumMap, json['invited_role']) ??
          FamilyRole.partner,
      invitedBy: json['invited_by'] as String,
      expiresAt: DateTime.parse(json['expires_at'] as String),
      acceptedAt: json['accepted_at'] == null
          ? null
          : DateTime.parse(json['accepted_at'] as String),
      revokedAt: json['revoked_at'] == null
          ? null
          : DateTime.parse(json['revoked_at'] as String),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$FamilyInvitationToJson(_FamilyInvitation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'family_id': instance.familyId,
      'email': instance.email,
      'invited_role': _$FamilyRoleEnumMap[instance.invitedRole]!,
      'invited_by': instance.invitedBy,
      'expires_at': instance.expiresAt.toIso8601String(),
      'accepted_at': instance.acceptedAt?.toIso8601String(),
      'revoked_at': instance.revokedAt?.toIso8601String(),
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

const _$FamilyRoleEnumMap = {
  FamilyRole.owner: 'owner',
  FamilyRole.partner: 'partner',
  FamilyRole.child: 'child',
  FamilyRole.teenager: 'teenager',
  FamilyRole.grandparent: 'grandparent',
  FamilyRole.guest: 'guest',
  FamilyRole.babysitter: 'babysitter',
};
