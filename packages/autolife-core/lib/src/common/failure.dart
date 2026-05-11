import 'package:freezed_annotation/freezed_annotation.dart';

part 'failure.freezed.dart';
part 'failure.g.dart';

/// Structured error surface for repository and integration boundaries.
@freezed
abstract class Failure with _$Failure {
  const factory Failure({
    required String code,
    String? message,
    Map<String, dynamic>? details,
  }) = _Failure;

  factory Failure.fromJson(Map<String, dynamic> json) =>
      _$FailureFromJson(json);
}
