// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'event_delivery.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EventDelivery {

 String get id;@JsonKey(name: 'event_id') String get eventId; String get consumer; int get attempt; EventDeliveryStatus get status;@JsonKey(name: 'last_error') String? get lastError;@JsonKey(name: 'next_attempt_at') DateTime? get nextAttemptAt;@JsonKey(name: 'updated_at') DateTime? get updatedAt;
/// Create a copy of EventDelivery
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EventDeliveryCopyWith<EventDelivery> get copyWith => _$EventDeliveryCopyWithImpl<EventDelivery>(this as EventDelivery, _$identity);

  /// Serializes this EventDelivery to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EventDelivery&&(identical(other.id, id) || other.id == id)&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.consumer, consumer) || other.consumer == consumer)&&(identical(other.attempt, attempt) || other.attempt == attempt)&&(identical(other.status, status) || other.status == status)&&(identical(other.lastError, lastError) || other.lastError == lastError)&&(identical(other.nextAttemptAt, nextAttemptAt) || other.nextAttemptAt == nextAttemptAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,eventId,consumer,attempt,status,lastError,nextAttemptAt,updatedAt);

@override
String toString() {
  return 'EventDelivery(id: $id, eventId: $eventId, consumer: $consumer, attempt: $attempt, status: $status, lastError: $lastError, nextAttemptAt: $nextAttemptAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $EventDeliveryCopyWith<$Res>  {
  factory $EventDeliveryCopyWith(EventDelivery value, $Res Function(EventDelivery) _then) = _$EventDeliveryCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'event_id') String eventId, String consumer, int attempt, EventDeliveryStatus status,@JsonKey(name: 'last_error') String? lastError,@JsonKey(name: 'next_attempt_at') DateTime? nextAttemptAt,@JsonKey(name: 'updated_at') DateTime? updatedAt
});




}
/// @nodoc
class _$EventDeliveryCopyWithImpl<$Res>
    implements $EventDeliveryCopyWith<$Res> {
  _$EventDeliveryCopyWithImpl(this._self, this._then);

  final EventDelivery _self;
  final $Res Function(EventDelivery) _then;

/// Create a copy of EventDelivery
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? eventId = null,Object? consumer = null,Object? attempt = null,Object? status = null,Object? lastError = freezed,Object? nextAttemptAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,consumer: null == consumer ? _self.consumer : consumer // ignore: cast_nullable_to_non_nullable
as String,attempt: null == attempt ? _self.attempt : attempt // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EventDeliveryStatus,lastError: freezed == lastError ? _self.lastError : lastError // ignore: cast_nullable_to_non_nullable
as String?,nextAttemptAt: freezed == nextAttemptAt ? _self.nextAttemptAt : nextAttemptAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [EventDelivery].
extension EventDeliveryPatterns on EventDelivery {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EventDelivery value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EventDelivery() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EventDelivery value)  $default,){
final _that = this;
switch (_that) {
case _EventDelivery():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EventDelivery value)?  $default,){
final _that = this;
switch (_that) {
case _EventDelivery() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'event_id')  String eventId,  String consumer,  int attempt,  EventDeliveryStatus status, @JsonKey(name: 'last_error')  String? lastError, @JsonKey(name: 'next_attempt_at')  DateTime? nextAttemptAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EventDelivery() when $default != null:
return $default(_that.id,_that.eventId,_that.consumer,_that.attempt,_that.status,_that.lastError,_that.nextAttemptAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'event_id')  String eventId,  String consumer,  int attempt,  EventDeliveryStatus status, @JsonKey(name: 'last_error')  String? lastError, @JsonKey(name: 'next_attempt_at')  DateTime? nextAttemptAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _EventDelivery():
return $default(_that.id,_that.eventId,_that.consumer,_that.attempt,_that.status,_that.lastError,_that.nextAttemptAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'event_id')  String eventId,  String consumer,  int attempt,  EventDeliveryStatus status, @JsonKey(name: 'last_error')  String? lastError, @JsonKey(name: 'next_attempt_at')  DateTime? nextAttemptAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _EventDelivery() when $default != null:
return $default(_that.id,_that.eventId,_that.consumer,_that.attempt,_that.status,_that.lastError,_that.nextAttemptAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EventDelivery implements EventDelivery {
  const _EventDelivery({required this.id, @JsonKey(name: 'event_id') required this.eventId, required this.consumer, required this.attempt, required this.status, @JsonKey(name: 'last_error') this.lastError, @JsonKey(name: 'next_attempt_at') this.nextAttemptAt, @JsonKey(name: 'updated_at') this.updatedAt});
  factory _EventDelivery.fromJson(Map<String, dynamic> json) => _$EventDeliveryFromJson(json);

@override final  String id;
@override@JsonKey(name: 'event_id') final  String eventId;
@override final  String consumer;
@override final  int attempt;
@override final  EventDeliveryStatus status;
@override@JsonKey(name: 'last_error') final  String? lastError;
@override@JsonKey(name: 'next_attempt_at') final  DateTime? nextAttemptAt;
@override@JsonKey(name: 'updated_at') final  DateTime? updatedAt;

/// Create a copy of EventDelivery
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EventDeliveryCopyWith<_EventDelivery> get copyWith => __$EventDeliveryCopyWithImpl<_EventDelivery>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EventDeliveryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EventDelivery&&(identical(other.id, id) || other.id == id)&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.consumer, consumer) || other.consumer == consumer)&&(identical(other.attempt, attempt) || other.attempt == attempt)&&(identical(other.status, status) || other.status == status)&&(identical(other.lastError, lastError) || other.lastError == lastError)&&(identical(other.nextAttemptAt, nextAttemptAt) || other.nextAttemptAt == nextAttemptAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,eventId,consumer,attempt,status,lastError,nextAttemptAt,updatedAt);

@override
String toString() {
  return 'EventDelivery(id: $id, eventId: $eventId, consumer: $consumer, attempt: $attempt, status: $status, lastError: $lastError, nextAttemptAt: $nextAttemptAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$EventDeliveryCopyWith<$Res> implements $EventDeliveryCopyWith<$Res> {
  factory _$EventDeliveryCopyWith(_EventDelivery value, $Res Function(_EventDelivery) _then) = __$EventDeliveryCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'event_id') String eventId, String consumer, int attempt, EventDeliveryStatus status,@JsonKey(name: 'last_error') String? lastError,@JsonKey(name: 'next_attempt_at') DateTime? nextAttemptAt,@JsonKey(name: 'updated_at') DateTime? updatedAt
});




}
/// @nodoc
class __$EventDeliveryCopyWithImpl<$Res>
    implements _$EventDeliveryCopyWith<$Res> {
  __$EventDeliveryCopyWithImpl(this._self, this._then);

  final _EventDelivery _self;
  final $Res Function(_EventDelivery) _then;

/// Create a copy of EventDelivery
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? eventId = null,Object? consumer = null,Object? attempt = null,Object? status = null,Object? lastError = freezed,Object? nextAttemptAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_EventDelivery(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,consumer: null == consumer ? _self.consumer : consumer // ignore: cast_nullable_to_non_nullable
as String,attempt: null == attempt ? _self.attempt : attempt // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EventDeliveryStatus,lastError: freezed == lastError ? _self.lastError : lastError // ignore: cast_nullable_to_non_nullable
as String?,nextAttemptAt: freezed == nextAttemptAt ? _self.nextAttemptAt : nextAttemptAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
