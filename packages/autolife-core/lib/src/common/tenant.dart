import 'package:freezed_annotation/freezed_annotation.dart';

part 'tenant.freezed.dart';
part 'tenant.g.dart';

/// Resolved tenant context for a signed-in session or integration call.
///
/// Full tenancy lifecycle (families, invites, RLS) is owned by phase 2.2+.
@freezed
abstract class Tenant with _$Tenant {
  const factory Tenant({
    @JsonKey(name: 'tenant_id') required String tenantId,
    @JsonKey(name: 'display_label') String? displayLabel,
  }) = _Tenant;

  factory Tenant.fromJson(Map<String, dynamic> json) => _$TenantFromJson(json);
}
