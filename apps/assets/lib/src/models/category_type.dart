import 'value_kind.dart';

/// A user-defined dimension (field type) such as `Brand`, `Model`, or
/// `Category`. Shared app-wide and filled in per asset.
class CategoryType {
  CategoryType({
    required this.id,
    required this.name,
    required this.valueKind,
    required this.accentColor,
    required this.displayIcon,
    required this.sortOrder,
    required this.createdAt,
    this.options,
    this.isArchived = false,
  });

  /// Maximum number of category types a user may create.
  static const int maxTypes = 50;

  /// Maximum characters in a type name.
  static const int maxNameLength = 32;

  /// Maximum allowed options on a Select type.
  static const int maxOptions = 20;

  /// Minimum options required to save a Select type.
  static const int minOptions = 2;

  /// Maximum characters in a single Select option label.
  static const int maxOptionLength = 32;

  final String id;
  final String name;
  final ValueKind valueKind;

  /// Ordered dropdown choices; required when [valueKind] is Select.
  final List<String>? options;
  final String accentColor;
  final String displayIcon;
  final int sortOrder;
  final bool isArchived;
  final DateTime createdAt;

  /// Whether [value] is an allowed choice for a Select type. Always false for
  /// non-Select kinds.
  bool acceptsSelectValue(String value) {
    if (valueKind != ValueKind.select) {
      return false;
    }
    return options?.contains(value) ?? false;
  }

  CategoryType copyWith({
    String? name,
    ValueKind? valueKind,
    List<String>? options,
    bool clearOptions = false,
    String? accentColor,
    String? displayIcon,
    int? sortOrder,
    bool? isArchived,
  }) {
    return CategoryType(
      id: id,
      name: name ?? this.name,
      valueKind: valueKind ?? this.valueKind,
      options: clearOptions ? null : (options ?? this.options),
      accentColor: accentColor ?? this.accentColor,
      displayIcon: displayIcon ?? this.displayIcon,
      sortOrder: sortOrder ?? this.sortOrder,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'name': name,
    'valueKind': valueKind.name,
    'options': options,
    'accentColor': accentColor,
    'displayIcon': displayIcon,
    'sortOrder': sortOrder,
    'isArchived': isArchived,
    'createdAt': createdAt.toIso8601String(),
  };

  factory CategoryType.fromJson(Map<String, dynamic> json) {
    final rawOptions = json['options'];
    return CategoryType(
      id: json['id'] as String,
      name: json['name'] as String,
      valueKind: ValueKind.fromName(json['valueKind'] as String),
      options: rawOptions == null
          ? null
          : (rawOptions as List).map((e) => e as String).toList(),
      accentColor: json['accentColor'] as String,
      displayIcon: json['displayIcon'] as String,
      sortOrder: json['sortOrder'] as int? ?? 0,
      isArchived: json['isArchived'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
