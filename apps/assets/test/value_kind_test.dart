import 'package:auto_assets/src/models/category_type.dart';
import 'package:auto_assets/src/models/value_kind.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('labels and round-trip by name', () {
    expect(ValueKind.select.label, 'Select');
    expect(ValueKind.money.label, 'Money');
    for (final kind in ValueKind.values) {
      expect(ValueKind.fromName(kind.name), kind);
    }
    expect(ValueKind.fromName('bogus'), ValueKind.text);
  });

  test('only text supports autocomplete; only select requires options', () {
    expect(ValueKind.text.supportsAutocomplete, isTrue);
    expect(ValueKind.select.supportsAutocomplete, isFalse);
    expect(ValueKind.select.requiresOptions, isTrue);
    expect(ValueKind.number.requiresOptions, isFalse);
  });

  test('Select requires at least 2 options to be considered valid', () {
    bool hasEnoughOptions(List<String> options) {
      final unique = options
          .map((o) => o.trim())
          .where((o) => o.isNotEmpty)
          .toSet();
      return unique.length >= CategoryType.minOptions;
    }

    expect(CategoryType.minOptions, 2);
    expect(hasEnoughOptions(['New']), isFalse);
    expect(hasEnoughOptions(['New', '  ']), isFalse);
    expect(hasEnoughOptions(['New', 'Used']), isTrue);
  });

  test('switching away from Select drops options via copyWith', () {
    final type = CategoryType(
      id: 'condition',
      name: 'Condition',
      valueKind: ValueKind.select,
      options: const ['New', 'Used'],
      accentColor: '#16A34A',
      displayIcon: 'icon:verified',
      sortOrder: 0,
      createdAt: DateTime(2026),
    );
    final asText = type.copyWith(valueKind: ValueKind.text, clearOptions: true);
    expect(asText.options, isNull);
  });
}
