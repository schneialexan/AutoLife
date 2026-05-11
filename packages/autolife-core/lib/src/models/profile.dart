import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile.freezed.dart';
part 'profile.g.dart';

/// User profile row stub (`profile` table — phase 1.4). Detailed tenancy fields
/// (`display_name`, prefs, links) expand in phase 2.2.
@freezed
abstract class Profile with _$Profile {
  const factory Profile({
    required String id,
    @JsonKey(name: 'display_name') required String displayName,
    @JsonKey(name: 'active_family_id') String? activeFamilyId,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _Profile;

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);
}
