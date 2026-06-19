import 'package:intl/intl.dart';

import 'money.dart';
import 'value_kind.dart';

/// A typed value stored against a category type on an asset.
///
/// Persisted as JSON with a `kind` discriminator so no Hive TypeAdapter (and no
/// `build_runner`) is required.
sealed class PropertyValue {
  const PropertyValue();

  ValueKind get kind;

  /// Whether the value carries no meaningful data and should be dropped on save.
  bool get isEmpty;

  /// Human-readable representation used in lists, cards, and search.
  String displayString();

  Map<String, dynamic> toJson();

  factory PropertyValue.fromJson(Map<String, dynamic> json) {
    final kind = ValueKind.fromName(json['kind'] as String);
    switch (kind) {
      case ValueKind.text:
        return TextValue(json['value'] as String? ?? '');
      case ValueKind.number:
        return NumberValue((json['value'] as num?)?.toDouble() ?? 0);
      case ValueKind.date:
        return DateValue(DateTime.parse(json['value'] as String));
      case ValueKind.money:
        return MoneyValue(
          Money.fromJson((json['value'] as Map).cast<String, dynamic>()),
        );
      case ValueKind.photo:
        return PhotoValue(json['value'] as String? ?? '');
      case ValueKind.select:
        return SelectValue(json['value'] as String? ?? '');
    }
  }
}

class TextValue extends PropertyValue {
  const TextValue(this.value);

  final String value;

  @override
  ValueKind get kind => ValueKind.text;

  @override
  bool get isEmpty => value.trim().isEmpty;

  @override
  String displayString() => value;

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
    'kind': kind.name,
    'value': value,
  };
}

class NumberValue extends PropertyValue {
  const NumberValue(this.value);

  final double value;

  @override
  ValueKind get kind => ValueKind.number;

  @override
  bool get isEmpty => false;

  @override
  String displayString() {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toString();
  }

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
    'kind': kind.name,
    'value': value,
  };
}

class DateValue extends PropertyValue {
  const DateValue(this.value);

  final DateTime value;

  @override
  ValueKind get kind => ValueKind.date;

  @override
  bool get isEmpty => false;

  @override
  String displayString() => DateFormat('d MMM y').format(value);

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
    'kind': kind.name,
    'value': value.toIso8601String(),
  };
}

class MoneyValue extends PropertyValue {
  const MoneyValue(this.value);

  final Money value;

  @override
  ValueKind get kind => ValueKind.money;

  @override
  bool get isEmpty => false;

  @override
  String displayString() => value.format();

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
    'kind': kind.name,
    'value': value.toJson(),
  };
}

class PhotoValue extends PropertyValue {
  const PhotoValue(this.path);

  final String path;

  @override
  ValueKind get kind => ValueKind.photo;

  @override
  bool get isEmpty => path.trim().isEmpty;

  @override
  String displayString() => 'Photo';

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
    'kind': kind.name,
    'value': path,
  };
}

class SelectValue extends PropertyValue {
  const SelectValue(this.value);

  final String value;

  @override
  ValueKind get kind => ValueKind.select;

  @override
  bool get isEmpty => value.trim().isEmpty;

  @override
  String displayString() => value;

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
    'kind': kind.name,
    'value': value,
  };
}
