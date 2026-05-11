import 'package:freezed_annotation/freezed_annotation.dart';

part 'family.freezed.dart';
part 'family.g.dart';

/// `public.families` row.
@freezed
abstract class Family with _$Family {
  const factory Family({
    required String id,
    required String name,
    @JsonKey(name: 'created_by') String? createdBy,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'archived_at') DateTime? archivedAt,
    @JsonKey(name: 'settings')
    @Default(<String, dynamic>{})
    Map<String, dynamic> settings,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _Family;

  factory Family.fromJson(Map<String, dynamic> json) => _$FamilyFromJson(json);
}
