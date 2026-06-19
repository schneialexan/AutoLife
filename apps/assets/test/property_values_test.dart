import 'package:auto_assets/src/models/category_type.dart';
import 'package:auto_assets/src/models/money.dart';
import 'package:auto_assets/src/models/property_value.dart';
import 'package:auto_assets/src/models/value_kind.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  PropertyValue roundTrip(PropertyValue value) {
    return PropertyValue.fromJson(value.toJson());
  }

  test('text/number/date/money/photo/select serialize round-trip', () {
    final text = roundTrip(const TextValue('Schneider'));
    expect((text as TextValue).value, 'Schneider');

    final number = roundTrip(const NumberValue(12.5));
    expect((number as NumberValue).value, 12.5);

    final date = roundTrip(DateValue(DateTime(2026, 3, 15)));
    expect((date as DateValue).value, DateTime(2026, 3, 15));

    final money = roundTrip(
      const MoneyValue(Money(amount: 129.95, currency: 'CHF')),
    );
    expect((money as MoneyValue).value.amount, 129.95);
    expect(money.value.currency, 'CHF');

    final photo = roundTrip(const PhotoValue('/data/x.jpg'));
    expect((photo as PhotoValue).path, '/data/x.jpg');

    final select = roundTrip(const SelectValue('Used'));
    expect((select as SelectValue).value, 'Used');
  });

  test('emptiness rules', () {
    expect(const TextValue('   ').isEmpty, isTrue);
    expect(const TextValue('a').isEmpty, isFalse);
    expect(const SelectValue('').isEmpty, isTrue);
    expect(const PhotoValue('').isEmpty, isTrue);
    expect(const NumberValue(0).isEmpty, isFalse);
  });

  test('Select type rejects a value not in its options', () {
    final condition = CategoryType(
      id: 'condition',
      name: 'Condition',
      valueKind: ValueKind.select,
      options: const ['New', 'Used', 'Broken'],
      accentColor: '#16A34A',
      displayIcon: 'icon:verified',
      sortOrder: 0,
      createdAt: DateTime(2026),
    );
    expect(condition.acceptsSelectValue('Used'), isTrue);
    expect(condition.acceptsSelectValue('Refurbished'), isFalse);
  });
}
