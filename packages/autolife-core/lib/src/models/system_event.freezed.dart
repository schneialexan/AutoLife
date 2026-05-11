// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'system_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SystemEvent {

 String? get id;@JsonKey(name: 'tenant_id') String get tenantId;@JsonKey(name: 'actor_id') String get actorId; String get module; String get type;@JsonKey(fromJson: _payloadFromJson, toJson: _payloadToJson) Map<String, dynamic> get payload;@JsonKey(name: 'idempotency_key') String get idempotencyKey;@JsonKey(name: 'occurred_at') DateTime get occurredAt;@JsonKey(name: 'ordering_tag') String get orderingTag;@JsonKey(name: 'schema_version') int get schemaVersion;@JsonKey(name: 'updated_at') DateTime? get updatedAt;
/// Create a copy of SystemEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SystemEventCopyWith<SystemEvent> get copyWith => _$SystemEventCopyWithImpl<SystemEvent>(this as SystemEvent, _$identity);

  /// Serializes this SystemEvent to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SystemEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.tenantId, tenantId) || other.tenantId == tenantId)&&(identical(other.actorId, actorId) || other.actorId == actorId)&&(identical(other.module, module) || other.module == module)&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other.payload, payload)&&(identical(other.idempotencyKey, idempotencyKey) || other.idempotencyKey == idempotencyKey)&&(identical(other.occurredAt, occurredAt) || other.occurredAt == occurredAt)&&(identical(other.orderingTag, orderingTag) || other.orderingTag == orderingTag)&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,tenantId,actorId,module,type,const DeepCollectionEquality().hash(payload),idempotencyKey,occurredAt,orderingTag,schemaVersion,updatedAt);

@override
String toString() {
  return 'SystemEvent(id: $id, tenantId: $tenantId, actorId: $actorId, module: $module, type: $type, payload: $payload, idempotencyKey: $idempotencyKey, occurredAt: $occurredAt, orderingTag: $orderingTag, schemaVersion: $schemaVersion, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $SystemEventCopyWith<$Res>  {
  factory $SystemEventCopyWith(SystemEvent value, $Res Function(SystemEvent) _then) = _$SystemEventCopyWithImpl;
@useResult
$Res call({
 String? id,@JsonKey(name: 'tenant_id') String tenantId,@JsonKey(name: 'actor_id') String actorId, String module, String type,@JsonKey(fromJson: _payloadFromJson, toJson: _payloadToJson) Map<String, dynamic> payload,@JsonKey(name: 'idempotency_key') String idempotencyKey,@JsonKey(name: 'occurred_at') DateTime occurredAt,@JsonKey(name: 'ordering_tag') String orderingTag,@JsonKey(name: 'schema_version') int schemaVersion,@JsonKey(name: 'updated_at') DateTime? updatedAt
});




}
/// @nodoc
class _$SystemEventCopyWithImpl<$Res>
    implements $SystemEventCopyWith<$Res> {
  _$SystemEventCopyWithImpl(this._self, this._then);

  final SystemEvent _self;
  final $Res Function(SystemEvent) _then;

/// Create a copy of SystemEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? tenantId = null,Object? actorId = null,Object? module = null,Object? type = null,Object? payload = null,Object? idempotencyKey = null,Object? occurredAt = null,Object? orderingTag = null,Object? schemaVersion = null,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,tenantId: null == tenantId ? _self.tenantId : tenantId // ignore: cast_nullable_to_non_nullable
as String,actorId: null == actorId ? _self.actorId : actorId // ignore: cast_nullable_to_non_nullable
as String,module: null == module ? _self.module : module // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,payload: null == payload ? _self.payload : payload // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,idempotencyKey: null == idempotencyKey ? _self.idempotencyKey : idempotencyKey // ignore: cast_nullable_to_non_nullable
as String,occurredAt: null == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as DateTime,orderingTag: null == orderingTag ? _self.orderingTag : orderingTag // ignore: cast_nullable_to_non_nullable
as String,schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [SystemEvent].
extension SystemEventPatterns on SystemEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SystemEvent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SystemEvent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SystemEvent value)  $default,){
final _that = this;
switch (_that) {
case _SystemEvent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SystemEvent value)?  $default,){
final _that = this;
switch (_that) {
case _SystemEvent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id, @JsonKey(name: 'tenant_id')  String tenantId, @JsonKey(name: 'actor_id')  String actorId,  String module,  String type, @JsonKey(fromJson: _payloadFromJson, toJson: _payloadToJson)  Map<String, dynamic> payload, @JsonKey(name: 'idempotency_key')  String idempotencyKey, @JsonKey(name: 'occurred_at')  DateTime occurredAt, @JsonKey(name: 'ordering_tag')  String orderingTag, @JsonKey(name: 'schema_version')  int schemaVersion, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SystemEvent() when $default != null:
return $default(_that.id,_that.tenantId,_that.actorId,_that.module,_that.type,_that.payload,_that.idempotencyKey,_that.occurredAt,_that.orderingTag,_that.schemaVersion,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id, @JsonKey(name: 'tenant_id')  String tenantId, @JsonKey(name: 'actor_id')  String actorId,  String module,  String type, @JsonKey(fromJson: _payloadFromJson, toJson: _payloadToJson)  Map<String, dynamic> payload, @JsonKey(name: 'idempotency_key')  String idempotencyKey, @JsonKey(name: 'occurred_at')  DateTime occurredAt, @JsonKey(name: 'ordering_tag')  String orderingTag, @JsonKey(name: 'schema_version')  int schemaVersion, @JsonKey(name: 'updated_at')  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _SystemEvent():
return $default(_that.id,_that.tenantId,_that.actorId,_that.module,_that.type,_that.payload,_that.idempotencyKey,_that.occurredAt,_that.orderingTag,_that.schemaVersion,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id, @JsonKey(name: 'tenant_id')  String tenantId, @JsonKey(name: 'actor_id')  String actorId,  String module,  String type, @JsonKey(fromJson: _payloadFromJson, toJson: _payloadToJson)  Map<String, dynamic> payload, @JsonKey(name: 'idempotency_key')  String idempotencyKey, @JsonKey(name: 'occurred_at')  DateTime occurredAt, @JsonKey(name: 'ordering_tag')  String orderingTag, @JsonKey(name: 'schema_version')  int schemaVersion, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _SystemEvent() when $default != null:
return $default(_that.id,_that.tenantId,_that.actorId,_that.module,_that.type,_that.payload,_that.idempotencyKey,_that.occurredAt,_that.orderingTag,_that.schemaVersion,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SystemEvent implements SystemEvent {
  const _SystemEvent({this.id, @JsonKey(name: 'tenant_id') required this.tenantId, @JsonKey(name: 'actor_id') required this.actorId, required this.module, required this.type, @JsonKey(fromJson: _payloadFromJson, toJson: _payloadToJson) required final  Map<String, dynamic> payload, @JsonKey(name: 'idempotency_key') required this.idempotencyKey, @JsonKey(name: 'occurred_at') required this.occurredAt, @JsonKey(name: 'ordering_tag') required this.orderingTag, @JsonKey(name: 'schema_version') required this.schemaVersion, @JsonKey(name: 'updated_at') this.updatedAt}): _payload = payload;
  factory _SystemEvent.fromJson(Map<String, dynamic> json) => _$SystemEventFromJson(json);

@override final  String? id;
@override@JsonKey(name: 'tenant_id') final  String tenantId;
@override@JsonKey(name: 'actor_id') final  String actorId;
@override final  String module;
@override final  String type;
 final  Map<String, dynamic> _payload;
@override@JsonKey(fromJson: _payloadFromJson, toJson: _payloadToJson) Map<String, dynamic> get payload {
  if (_payload is EqualUnmodifiableMapView) return _payload;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_payload);
}

@override@JsonKey(name: 'idempotency_key') final  String idempotencyKey;
@override@JsonKey(name: 'occurred_at') final  DateTime occurredAt;
@override@JsonKey(name: 'ordering_tag') final  String orderingTag;
@override@JsonKey(name: 'schema_version') final  int schemaVersion;
@override@JsonKey(name: 'updated_at') final  DateTime? updatedAt;

/// Create a copy of SystemEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SystemEventCopyWith<_SystemEvent> get copyWith => __$SystemEventCopyWithImpl<_SystemEvent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SystemEventToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SystemEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.tenantId, tenantId) || other.tenantId == tenantId)&&(identical(other.actorId, actorId) || other.actorId == actorId)&&(identical(other.module, module) || other.module == module)&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other._payload, _payload)&&(identical(other.idempotencyKey, idempotencyKey) || other.idempotencyKey == idempotencyKey)&&(identical(other.occurredAt, occurredAt) || other.occurredAt == occurredAt)&&(identical(other.orderingTag, orderingTag) || other.orderingTag == orderingTag)&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,tenantId,actorId,module,type,const DeepCollectionEquality().hash(_payload),idempotencyKey,occurredAt,orderingTag,schemaVersion,updatedAt);

@override
String toString() {
  return 'SystemEvent(id: $id, tenantId: $tenantId, actorId: $actorId, module: $module, type: $type, payload: $payload, idempotencyKey: $idempotencyKey, occurredAt: $occurredAt, orderingTag: $orderingTag, schemaVersion: $schemaVersion, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$SystemEventCopyWith<$Res> implements $SystemEventCopyWith<$Res> {
  factory _$SystemEventCopyWith(_SystemEvent value, $Res Function(_SystemEvent) _then) = __$SystemEventCopyWithImpl;
@override @useResult
$Res call({
 String? id,@JsonKey(name: 'tenant_id') String tenantId,@JsonKey(name: 'actor_id') String actorId, String module, String type,@JsonKey(fromJson: _payloadFromJson, toJson: _payloadToJson) Map<String, dynamic> payload,@JsonKey(name: 'idempotency_key') String idempotencyKey,@JsonKey(name: 'occurred_at') DateTime occurredAt,@JsonKey(name: 'ordering_tag') String orderingTag,@JsonKey(name: 'schema_version') int schemaVersion,@JsonKey(name: 'updated_at') DateTime? updatedAt
});




}
/// @nodoc
class __$SystemEventCopyWithImpl<$Res>
    implements _$SystemEventCopyWith<$Res> {
  __$SystemEventCopyWithImpl(this._self, this._then);

  final _SystemEvent _self;
  final $Res Function(_SystemEvent) _then;

/// Create a copy of SystemEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? tenantId = null,Object? actorId = null,Object? module = null,Object? type = null,Object? payload = null,Object? idempotencyKey = null,Object? occurredAt = null,Object? orderingTag = null,Object? schemaVersion = null,Object? updatedAt = freezed,}) {
  return _then(_SystemEvent(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,tenantId: null == tenantId ? _self.tenantId : tenantId // ignore: cast_nullable_to_non_nullable
as String,actorId: null == actorId ? _self.actorId : actorId // ignore: cast_nullable_to_non_nullable
as String,module: null == module ? _self.module : module // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,payload: null == payload ? _self._payload : payload // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,idempotencyKey: null == idempotencyKey ? _self.idempotencyKey : idempotencyKey // ignore: cast_nullable_to_non_nullable
as String,occurredAt: null == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as DateTime,orderingTag: null == orderingTag ? _self.orderingTag : orderingTag // ignore: cast_nullable_to_non_nullable
as String,schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
