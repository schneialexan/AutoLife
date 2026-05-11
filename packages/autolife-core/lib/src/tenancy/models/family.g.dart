// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'family.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Family _$FamilyFromJson(Map<String, dynamic> json) => _Family(
  id: json['id'] as String,
  name: json['name'] as String,
  createdBy: json['created_by'] as String?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  archivedAt: json['archived_at'] == null
      ? null
      : DateTime.parse(json['archived_at'] as String),
  settings:
      json['settings'] as Map<String, dynamic>? ?? const <String, dynamic>{},
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$FamilyToJson(_Family instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'created_by': instance.createdBy,
  'created_at': instance.createdAt?.toIso8601String(),
  'archived_at': instance.archivedAt?.toIso8601String(),
  'settings': instance.settings,
  'updated_at': instance.updatedAt?.toIso8601String(),
};
