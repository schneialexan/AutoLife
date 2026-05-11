// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'failure.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Failure _$FailureFromJson(Map<String, dynamic> json) => _Failure(
  code: json['code'] as String,
  message: json['message'] as String?,
  details: json['details'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$FailureToJson(_Failure instance) => <String, dynamic>{
  'code': instance.code,
  'message': instance.message,
  'details': instance.details,
};
