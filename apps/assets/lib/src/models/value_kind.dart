/// The kind of value a field accepts. Controls input widget, validation, and
/// how the value is stored and rendered.
enum ValueKind {
  text,
  number,
  date,
  money,
  photo,
  select;

  /// User-facing label shown in pills and pickers.
  String get label {
    switch (this) {
      case ValueKind.text:
        return 'Text';
      case ValueKind.number:
        return 'Number';
      case ValueKind.date:
        return 'Date';
      case ValueKind.money:
        return 'Money';
      case ValueKind.photo:
        return 'Photo';
      case ValueKind.select:
        return 'Select';
    }
  }

  /// Whether free-text autocomplete suggestions apply to this kind.
  bool get supportsAutocomplete => this == ValueKind.text;

  /// Whether this kind requires a user-defined option list.
  bool get requiresOptions => this == ValueKind.select;

  static ValueKind fromName(String name) {
    return ValueKind.values.firstWhere(
      (k) => k.name == name,
      orElse: () => ValueKind.text,
    );
  }
}
