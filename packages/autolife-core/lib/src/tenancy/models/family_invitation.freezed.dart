// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'family_invitation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FamilyInvitation {

 String get id;@JsonKey(name: 'family_id') String get familyId; String get email;@JsonKey(name: 'invited_role') FamilyRole get invitedRole;@JsonKey(name: 'invited_by') String get invitedBy;@JsonKey(name: 'expires_at') DateTime get expiresAt;@JsonKey(name: 'accepted_at') DateTime? get acceptedAt;@JsonKey(name: 'revoked_at') DateTime? get revokedAt;@JsonKey(name: 'created_at') DateTime? get createdAt;@JsonKey(name: 'updated_at') DateTime? get updatedAt;
/// Create a copy of FamilyInvitation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FamilyInvitationCopyWith<FamilyInvitation> get copyWith => _$FamilyInvitationCopyWithImpl<FamilyInvitation>(this as FamilyInvitation, _$identity);

  /// Serializes this FamilyInvitation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FamilyInvitation&&(identical(other.id, id) || other.id == id)&&(identical(other.familyId, familyId) || other.familyId == familyId)&&(identical(other.email, email) || other.email == email)&&(identical(other.invitedRole, invitedRole) || other.invitedRole == invitedRole)&&(identical(other.invitedBy, invitedBy) || other.invitedBy == invitedBy)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.acceptedAt, acceptedAt) || other.acceptedAt == acceptedAt)&&(identical(other.revokedAt, revokedAt) || other.revokedAt == revokedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,familyId,email,invitedRole,invitedBy,expiresAt,acceptedAt,revokedAt,createdAt,updatedAt);

@override
String toString() {
  return 'FamilyInvitation(id: $id, familyId: $familyId, email: $email, invitedRole: $invitedRole, invitedBy: $invitedBy, expiresAt: $expiresAt, acceptedAt: $acceptedAt, revokedAt: $revokedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $FamilyInvitationCopyWith<$Res>  {
  factory $FamilyInvitationCopyWith(FamilyInvitation value, $Res Function(FamilyInvitation) _then) = _$FamilyInvitationCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'family_id') String familyId, String email,@JsonKey(name: 'invited_role') FamilyRole invitedRole,@JsonKey(name: 'invited_by') String invitedBy,@JsonKey(name: 'expires_at') DateTime expiresAt,@JsonKey(name: 'accepted_at') DateTime? acceptedAt,@JsonKey(name: 'revoked_at') DateTime? revokedAt,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt
});




}
/// @nodoc
class _$FamilyInvitationCopyWithImpl<$Res>
    implements $FamilyInvitationCopyWith<$Res> {
  _$FamilyInvitationCopyWithImpl(this._self, this._then);

  final FamilyInvitation _self;
  final $Res Function(FamilyInvitation) _then;

/// Create a copy of FamilyInvitation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? familyId = null,Object? email = null,Object? invitedRole = null,Object? invitedBy = null,Object? expiresAt = null,Object? acceptedAt = freezed,Object? revokedAt = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,familyId: null == familyId ? _self.familyId : familyId // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,invitedRole: null == invitedRole ? _self.invitedRole : invitedRole // ignore: cast_nullable_to_non_nullable
as FamilyRole,invitedBy: null == invitedBy ? _self.invitedBy : invitedBy // ignore: cast_nullable_to_non_nullable
as String,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,acceptedAt: freezed == acceptedAt ? _self.acceptedAt : acceptedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,revokedAt: freezed == revokedAt ? _self.revokedAt : revokedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [FamilyInvitation].
extension FamilyInvitationPatterns on FamilyInvitation {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FamilyInvitation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FamilyInvitation() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FamilyInvitation value)  $default,){
final _that = this;
switch (_that) {
case _FamilyInvitation():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FamilyInvitation value)?  $default,){
final _that = this;
switch (_that) {
case _FamilyInvitation() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'family_id')  String familyId,  String email, @JsonKey(name: 'invited_role')  FamilyRole invitedRole, @JsonKey(name: 'invited_by')  String invitedBy, @JsonKey(name: 'expires_at')  DateTime expiresAt, @JsonKey(name: 'accepted_at')  DateTime? acceptedAt, @JsonKey(name: 'revoked_at')  DateTime? revokedAt, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FamilyInvitation() when $default != null:
return $default(_that.id,_that.familyId,_that.email,_that.invitedRole,_that.invitedBy,_that.expiresAt,_that.acceptedAt,_that.revokedAt,_that.createdAt,_that.updatedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'family_id')  String familyId,  String email, @JsonKey(name: 'invited_role')  FamilyRole invitedRole, @JsonKey(name: 'invited_by')  String invitedBy, @JsonKey(name: 'expires_at')  DateTime expiresAt, @JsonKey(name: 'accepted_at')  DateTime? acceptedAt, @JsonKey(name: 'revoked_at')  DateTime? revokedAt, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _FamilyInvitation():
return $default(_that.id,_that.familyId,_that.email,_that.invitedRole,_that.invitedBy,_that.expiresAt,_that.acceptedAt,_that.revokedAt,_that.createdAt,_that.updatedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'family_id')  String familyId,  String email, @JsonKey(name: 'invited_role')  FamilyRole invitedRole, @JsonKey(name: 'invited_by')  String invitedBy, @JsonKey(name: 'expires_at')  DateTime expiresAt, @JsonKey(name: 'accepted_at')  DateTime? acceptedAt, @JsonKey(name: 'revoked_at')  DateTime? revokedAt, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _FamilyInvitation() when $default != null:
return $default(_that.id,_that.familyId,_that.email,_that.invitedRole,_that.invitedBy,_that.expiresAt,_that.acceptedAt,_that.revokedAt,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FamilyInvitation implements FamilyInvitation {
  const _FamilyInvitation({required this.id, @JsonKey(name: 'family_id') required this.familyId, required this.email, @JsonKey(name: 'invited_role') this.invitedRole = FamilyRole.partner, @JsonKey(name: 'invited_by') required this.invitedBy, @JsonKey(name: 'expires_at') required this.expiresAt, @JsonKey(name: 'accepted_at') this.acceptedAt, @JsonKey(name: 'revoked_at') this.revokedAt, @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'updated_at') this.updatedAt});
  factory _FamilyInvitation.fromJson(Map<String, dynamic> json) => _$FamilyInvitationFromJson(json);

@override final  String id;
@override@JsonKey(name: 'family_id') final  String familyId;
@override final  String email;
@override@JsonKey(name: 'invited_role') final  FamilyRole invitedRole;
@override@JsonKey(name: 'invited_by') final  String invitedBy;
@override@JsonKey(name: 'expires_at') final  DateTime expiresAt;
@override@JsonKey(name: 'accepted_at') final  DateTime? acceptedAt;
@override@JsonKey(name: 'revoked_at') final  DateTime? revokedAt;
@override@JsonKey(name: 'created_at') final  DateTime? createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime? updatedAt;

/// Create a copy of FamilyInvitation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FamilyInvitationCopyWith<_FamilyInvitation> get copyWith => __$FamilyInvitationCopyWithImpl<_FamilyInvitation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FamilyInvitationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FamilyInvitation&&(identical(other.id, id) || other.id == id)&&(identical(other.familyId, familyId) || other.familyId == familyId)&&(identical(other.email, email) || other.email == email)&&(identical(other.invitedRole, invitedRole) || other.invitedRole == invitedRole)&&(identical(other.invitedBy, invitedBy) || other.invitedBy == invitedBy)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.acceptedAt, acceptedAt) || other.acceptedAt == acceptedAt)&&(identical(other.revokedAt, revokedAt) || other.revokedAt == revokedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,familyId,email,invitedRole,invitedBy,expiresAt,acceptedAt,revokedAt,createdAt,updatedAt);

@override
String toString() {
  return 'FamilyInvitation(id: $id, familyId: $familyId, email: $email, invitedRole: $invitedRole, invitedBy: $invitedBy, expiresAt: $expiresAt, acceptedAt: $acceptedAt, revokedAt: $revokedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$FamilyInvitationCopyWith<$Res> implements $FamilyInvitationCopyWith<$Res> {
  factory _$FamilyInvitationCopyWith(_FamilyInvitation value, $Res Function(_FamilyInvitation) _then) = __$FamilyInvitationCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'family_id') String familyId, String email,@JsonKey(name: 'invited_role') FamilyRole invitedRole,@JsonKey(name: 'invited_by') String invitedBy,@JsonKey(name: 'expires_at') DateTime expiresAt,@JsonKey(name: 'accepted_at') DateTime? acceptedAt,@JsonKey(name: 'revoked_at') DateTime? revokedAt,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt
});




}
/// @nodoc
class __$FamilyInvitationCopyWithImpl<$Res>
    implements _$FamilyInvitationCopyWith<$Res> {
  __$FamilyInvitationCopyWithImpl(this._self, this._then);

  final _FamilyInvitation _self;
  final $Res Function(_FamilyInvitation) _then;

/// Create a copy of FamilyInvitation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? familyId = null,Object? email = null,Object? invitedRole = null,Object? invitedBy = null,Object? expiresAt = null,Object? acceptedAt = freezed,Object? revokedAt = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_FamilyInvitation(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,familyId: null == familyId ? _self.familyId : familyId // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,invitedRole: null == invitedRole ? _self.invitedRole : invitedRole // ignore: cast_nullable_to_non_nullable
as FamilyRole,invitedBy: null == invitedBy ? _self.invitedBy : invitedBy // ignore: cast_nullable_to_non_nullable
as String,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,acceptedAt: freezed == acceptedAt ? _self.acceptedAt : acceptedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,revokedAt: freezed == revokedAt ? _self.revokedAt : revokedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
