// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'event_envelope.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EventEnvelope {

@JsonKey(name: 'idempotency_key') String get idempotencyKey;@JsonKey(name: 'ordering_tag') String get orderingTag;@JsonKey(name: 'occurred_at') DateTime get occurredAt;@JsonKey(name: 'source_module') String get sourceModule;
/// Create a copy of EventEnvelope
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EventEnvelopeCopyWith<EventEnvelope> get copyWith => _$EventEnvelopeCopyWithImpl<EventEnvelope>(this as EventEnvelope, _$identity);

  /// Serializes this EventEnvelope to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EventEnvelope&&(identical(other.idempotencyKey, idempotencyKey) || other.idempotencyKey == idempotencyKey)&&(identical(other.orderingTag, orderingTag) || other.orderingTag == orderingTag)&&(identical(other.occurredAt, occurredAt) || other.occurredAt == occurredAt)&&(identical(other.sourceModule, sourceModule) || other.sourceModule == sourceModule));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,idempotencyKey,orderingTag,occurredAt,sourceModule);

@override
String toString() {
  return 'EventEnvelope(idempotencyKey: $idempotencyKey, orderingTag: $orderingTag, occurredAt: $occurredAt, sourceModule: $sourceModule)';
}


}

/// @nodoc
abstract mixin class $EventEnvelopeCopyWith<$Res>  {
  factory $EventEnvelopeCopyWith(EventEnvelope value, $Res Function(EventEnvelope) _then) = _$EventEnvelopeCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'idempotency_key') String idempotencyKey,@JsonKey(name: 'ordering_tag') String orderingTag,@JsonKey(name: 'occurred_at') DateTime occurredAt,@JsonKey(name: 'source_module') String sourceModule
});




}
/// @nodoc
class _$EventEnvelopeCopyWithImpl<$Res>
    implements $EventEnvelopeCopyWith<$Res> {
  _$EventEnvelopeCopyWithImpl(this._self, this._then);

  final EventEnvelope _self;
  final $Res Function(EventEnvelope) _then;

/// Create a copy of EventEnvelope
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? idempotencyKey = null,Object? orderingTag = null,Object? occurredAt = null,Object? sourceModule = null,}) {
  return _then(_self.copyWith(
idempotencyKey: null == idempotencyKey ? _self.idempotencyKey : idempotencyKey // ignore: cast_nullable_to_non_nullable
as String,orderingTag: null == orderingTag ? _self.orderingTag : orderingTag // ignore: cast_nullable_to_non_nullable
as String,occurredAt: null == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as DateTime,sourceModule: null == sourceModule ? _self.sourceModule : sourceModule // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [EventEnvelope].
extension EventEnvelopePatterns on EventEnvelope {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EventEnvelope value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EventEnvelope() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EventEnvelope value)  $default,){
final _that = this;
switch (_that) {
case _EventEnvelope():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EventEnvelope value)?  $default,){
final _that = this;
switch (_that) {
case _EventEnvelope() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'idempotency_key')  String idempotencyKey, @JsonKey(name: 'ordering_tag')  String orderingTag, @JsonKey(name: 'occurred_at')  DateTime occurredAt, @JsonKey(name: 'source_module')  String sourceModule)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EventEnvelope() when $default != null:
return $default(_that.idempotencyKey,_that.orderingTag,_that.occurredAt,_that.sourceModule);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'idempotency_key')  String idempotencyKey, @JsonKey(name: 'ordering_tag')  String orderingTag, @JsonKey(name: 'occurred_at')  DateTime occurredAt, @JsonKey(name: 'source_module')  String sourceModule)  $default,) {final _that = this;
switch (_that) {
case _EventEnvelope():
return $default(_that.idempotencyKey,_that.orderingTag,_that.occurredAt,_that.sourceModule);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'idempotency_key')  String idempotencyKey, @JsonKey(name: 'ordering_tag')  String orderingTag, @JsonKey(name: 'occurred_at')  DateTime occurredAt, @JsonKey(name: 'source_module')  String sourceModule)?  $default,) {final _that = this;
switch (_that) {
case _EventEnvelope() when $default != null:
return $default(_that.idempotencyKey,_that.orderingTag,_that.occurredAt,_that.sourceModule);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EventEnvelope implements EventEnvelope {
  const _EventEnvelope({@JsonKey(name: 'idempotency_key') required this.idempotencyKey, @JsonKey(name: 'ordering_tag') required this.orderingTag, @JsonKey(name: 'occurred_at') required this.occurredAt, @JsonKey(name: 'source_module') required this.sourceModule});
  factory _EventEnvelope.fromJson(Map<String, dynamic> json) => _$EventEnvelopeFromJson(json);

@override@JsonKey(name: 'idempotency_key') final  String idempotencyKey;
@override@JsonKey(name: 'ordering_tag') final  String orderingTag;
@override@JsonKey(name: 'occurred_at') final  DateTime occurredAt;
@override@JsonKey(name: 'source_module') final  String sourceModule;

/// Create a copy of EventEnvelope
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EventEnvelopeCopyWith<_EventEnvelope> get copyWith => __$EventEnvelopeCopyWithImpl<_EventEnvelope>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EventEnvelopeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EventEnvelope&&(identical(other.idempotencyKey, idempotencyKey) || other.idempotencyKey == idempotencyKey)&&(identical(other.orderingTag, orderingTag) || other.orderingTag == orderingTag)&&(identical(other.occurredAt, occurredAt) || other.occurredAt == occurredAt)&&(identical(other.sourceModule, sourceModule) || other.sourceModule == sourceModule));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,idempotencyKey,orderingTag,occurredAt,sourceModule);

@override
String toString() {
  return 'EventEnvelope(idempotencyKey: $idempotencyKey, orderingTag: $orderingTag, occurredAt: $occurredAt, sourceModule: $sourceModule)';
}


}

/// @nodoc
abstract mixin class _$EventEnvelopeCopyWith<$Res> implements $EventEnvelopeCopyWith<$Res> {
  factory _$EventEnvelopeCopyWith(_EventEnvelope value, $Res Function(_EventEnvelope) _then) = __$EventEnvelopeCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'idempotency_key') String idempotencyKey,@JsonKey(name: 'ordering_tag') String orderingTag,@JsonKey(name: 'occurred_at') DateTime occurredAt,@JsonKey(name: 'source_module') String sourceModule
});




}
/// @nodoc
class __$EventEnvelopeCopyWithImpl<$Res>
    implements _$EventEnvelopeCopyWith<$Res> {
  __$EventEnvelopeCopyWithImpl(this._self, this._then);

  final _EventEnvelope _self;
  final $Res Function(_EventEnvelope) _then;

/// Create a copy of EventEnvelope
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? idempotencyKey = null,Object? orderingTag = null,Object? occurredAt = null,Object? sourceModule = null,}) {
  return _then(_EventEnvelope(
idempotencyKey: null == idempotencyKey ? _self.idempotencyKey : idempotencyKey // ignore: cast_nullable_to_non_nullable
as String,orderingTag: null == orderingTag ? _self.orderingTag : orderingTag // ignore: cast_nullable_to_non_nullable
as String,occurredAt: null == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as DateTime,sourceModule: null == sourceModule ? _self.sourceModule : sourceModule // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
