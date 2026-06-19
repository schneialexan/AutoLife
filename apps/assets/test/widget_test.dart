import 'package:auto_assets/src/data/category_type_repository.dart';
import 'package:auto_assets/src/models/category_type.dart';
import 'package:auto_assets/src/models/money.dart';
import 'package:auto_assets/src/models/value_kind.dart';
import 'package:auto_assets/src/providers/category_type_providers.dart';
import 'package:auto_assets/src/screens/asset_form/add_category_overlay.dart';
import 'package:auto_assets/src/widgets/color_swatch_picker.dart';
import 'package:auto_assets/src/widgets/icon_grid_picker.dart';
import 'package:auto_assets/src/widgets/typed_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// In-memory repository so widget tests avoid Hive's real disk I/O, which never
/// completes inside the `testWidgets` fake-async zone.
class _FakeCategoryTypeRepository implements CategoryTypeRepository {
  _FakeCategoryTypeRepository(this._types);

  final List<CategoryType> _types;

  @override
  List<CategoryType> getAll() => List.of(_types);

  @override
  List<CategoryType> getActive() => _types.where((t) => !t.isArchived).toList();

  @override
  CategoryType? getById(String id) {
    for (final t in _types) {
      if (t.id == id) {
        return t;
      }
    }
    return null;
  }

  @override
  Future<void> save(CategoryType type) async {
    _types.removeWhere((t) => t.id == type.id);
    _types.add(type);
  }

  @override
  Future<void> delete(String id) async {
    _types.removeWhere((t) => t.id == id);
  }

  @override
  Future<void> seedDefaults() async {}
}

ProviderScope _scope({required Widget child}) {
  final repo = _FakeCategoryTypeRepository([])
    .._types.addAll([
      CategoryType(
        id: 'category',
        name: 'Category',
        valueKind: ValueKind.text,
        accentColor: '#2563EB',
        displayIcon: 'icon:category',
        sortOrder: 0,
        createdAt: DateTime(2026),
      ),
      CategoryType(
        id: 'brand',
        name: 'Brand',
        valueKind: ValueKind.text,
        accentColor: '#D97706',
        displayIcon: 'icon:tag',
        sortOrder: 1,
        createdAt: DateTime(2026),
      ),
      CategoryType(
        id: 'model',
        name: 'Model',
        valueKind: ValueKind.text,
        accentColor: '#0D9488',
        displayIcon: 'icon:cube',
        sortOrder: 2,
        createdAt: DateTime(2026),
      ),
    ]);
  return ProviderScope(
    overrides: [categoryTypeRepositoryProvider.overrideWithValue(repo)],
    child: child,
  );
}

void main() {
  testWidgets('add-category sheet lists types but excludes added ones', (
    tester,
  ) async {
    CategoryType? picked;
    await tester.pumpWidget(
      _scope(
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  picked = await showAddCategorySheet(
                    context,
                    excludeIds: {'brand'},
                  );
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Category'), findsOneWidget);
    expect(find.text('Model'), findsOneWidget);
    expect(find.text('Brand'), findsNothing);
    expect(find.text('Create new type'), findsOneWidget);

    await tester.tap(find.text('Category'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(picked?.id, 'category');
  });

  testWidgets('color swatch picker reports selection', (tester) async {
    String? chosen;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ColorSwatchPicker(
            selected: '#2563EB',
            onSelected: (c) => chosen = c,
          ),
        ),
      ),
    );
    await tester.tap(find.bySemanticsLabel('Color #4F46E5'));
    expect(chosen, '#4F46E5');
  });

  testWidgets('icon grid picker reports selection', (tester) async {
    String? chosen;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: IconGridPicker(
              selected: 'icon:tag',
              accentColor: '#2563EB',
              onSelected: (i) => chosen = i,
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.bySemanticsLabel('Store'));
    expect(chosen, 'icon:store');
  });

  testWidgets('money field emits amount with default currency', (tester) async {
    Money? money;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MoneyField(value: null, onChanged: (m) => money = m),
        ),
      ),
    );
    await tester.enterText(find.byType(TextField).first, '129.95');
    await tester.pump();
    expect(money, isNotNull);
    expect(money!.amount, 129.95);
    expect(money!.currency, Money.supportedCurrencies.first);
  });
}
