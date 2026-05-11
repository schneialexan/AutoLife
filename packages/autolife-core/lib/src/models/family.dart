import 'package:freezed_annotation/freezed_annotation.dart';

part 'family.freezed.dart';
part 'family.g.dart';

/// Family (tenant) stub row (`family` table — phase 1.4).
@freezed
abstract class Family with _$Family {
  const factory Family({
    required String id,
    @JsonKey(name: 'display_name') required String displayName,
  }) = _Family;

  factory Family.fromJson(Map<String, dynamic> json) => _$FamilyFromJson(json);
}
