import 'package:json_annotation/json_annotation.dart';

/// Stub role taxonomy; full matrix and policy engine — phase 2.3.
@JsonEnum(fieldRename: FieldRename.snake)
enum Role { member, admin, owner }
