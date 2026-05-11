// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tenant.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Tenant _$TenantFromJson(Map<String, dynamic> json) => _Tenant(
  tenantId: json['tenant_id'] as String,
  displayLabel: json['display_label'] as String?,
);

Map<String, dynamic> _$TenantToJson(_Tenant instance) => <String, dynamic>{
  'tenant_id': instance.tenantId,
  'display_label': instance.displayLabel,
};
