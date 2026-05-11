import 'package:freezed_annotation/freezed_annotation.dart';

import 'role.dart';

part 'membership.freezed.dart';
part 'membership.g.dart';

/// Join between [Profile] and [Family] (`membership` table — phase 1.4).
@freezed
abstract class Membership with _$Membership {
  const factory Membership({
    required String id,
    @JsonKey(name: 'family_id') required String familyId,
    @JsonKey(name: 'profile_id') required String profileId,
    required Role role,
  }) = _Membership;

  factory Membership.fromJson(Map<String, dynamic> json) =>
      _$MembershipFromJson(json);
}
