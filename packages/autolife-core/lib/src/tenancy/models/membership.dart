import 'package:freezed_annotation/freezed_annotation.dart';

import '../../policy/role.dart';

part 'membership.freezed.dart';
part 'membership.g.dart';

/// `public.memberships` composite row (key = family_id + user_id).
@freezed
abstract class Membership with _$Membership {
  const factory Membership({
    @JsonKey(name: 'family_id') required String familyId,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'role') required FamilyRole role,
    @JsonKey(name: 'joined_at') DateTime? joinedAt,
    @JsonKey(name: 'removed_at') DateTime? removedAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _Membership;

  factory Membership.fromJson(Map<String, dynamic> json) =>
      _$MembershipFromJson(json);
}
