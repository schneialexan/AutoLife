// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'membership.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Membership _$MembershipFromJson(Map<String, dynamic> json) => _Membership(
  id: json['id'] as String,
  familyId: json['family_id'] as String,
  profileId: json['profile_id'] as String,
  role: $enumDecode(_$RoleEnumMap, json['role']),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$MembershipToJson(_Membership instance) =>
    <String, dynamic>{
      'id': instance.id,
      'family_id': instance.familyId,
      'profile_id': instance.profileId,
      'role': _$RoleEnumMap[instance.role]!,
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

const _$RoleEnumMap = {
  Role.member: 'member',
  Role.admin: 'admin',
  Role.owner: 'owner',
};
