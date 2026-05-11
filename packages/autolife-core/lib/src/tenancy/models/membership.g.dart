// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'membership.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Membership _$MembershipFromJson(Map<String, dynamic> json) => _Membership(
  familyId: json['family_id'] as String,
  userId: json['user_id'] as String,
  role: $enumDecode(_$FamilyRoleEnumMap, json['role']),
  joinedAt: json['joined_at'] == null
      ? null
      : DateTime.parse(json['joined_at'] as String),
  removedAt: json['removed_at'] == null
      ? null
      : DateTime.parse(json['removed_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$MembershipToJson(_Membership instance) =>
    <String, dynamic>{
      'family_id': instance.familyId,
      'user_id': instance.userId,
      'role': _$FamilyRoleEnumMap[instance.role]!,
      'joined_at': instance.joinedAt?.toIso8601String(),
      'removed_at': instance.removedAt?.toIso8601String(),
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
