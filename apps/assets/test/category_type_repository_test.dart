import 'package:auto_assets/src/data/asset_storage.dart';
import 'package:auto_assets/src/data/category_type_repository.dart';
import 'package:auto_assets/src/data/hive_category_type_repository.dart';
import 'package:auto_assets/src/models/category_type.dart';
import 'package:auto_assets/src/models/value_kind.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_storage.dart';

void main() {
  late AppStorage storage;
  late HiveCategoryTypeRepository repo;

  setUp(() async {
    storage = await openTestStorage();
    repo = HiveCategoryTypeRepository(storage);
  });

  tearDown(closeTestStorage);

  CategoryType makeType(String id, {int sortOrder = 0}) {
    return CategoryType(
      id: id,
      name: id,
      valueKind: ValueKind.text,
      accentColor: '#2563EB',
      displayIcon: 'icon:tag',
      sortOrder: sortOrder,
      createdAt: DateTime(2026),
    );
  }

  test('seeds starter types with color and icon exactly once', () async {
    await repo.seedDefaults();
    final seeded = repo.getAll();
    expect(
      seeded.map((t) => t.id),
      containsAll(['category', 'brand', 'model']),
    );
    for (final type in seeded) {
      expect(type.accentColor, isNotEmpty);
      expect(type.displayIcon, isNotEmpty);
    }

    // Deleting a starter then re-seeding must NOT bring it back.
    await repo.delete('brand');
    await repo.seedDefaults();
    expect(repo.getById('brand'), isNull);
  });

  test('add, rename and delete a type', () async {
    await repo.save(makeType('room'));
    expect(repo.getById('room'), isNotNull);

    await repo.save(repo.getById('room')!.copyWith(name: 'Location'));
    expect(repo.getById('room')!.name, 'Location');

    await repo.delete('room');
    expect(repo.getById('room'), isNull);
  });

  test('cannot exceed the 50-type cap', () async {
    for (var i = 0; i < CategoryType.maxTypes; i++) {
      await repo.save(makeType('type_$i', sortOrder: i));
    }
    expect(repo.getAll().length, CategoryType.maxTypes);
    expect(
      () => repo.save(makeType('overflow')),
      throwsA(isA<CategoryTypeLimitException>()),
    );
  });

  test('getActive excludes archived types', () async {
    await repo.save(makeType('a', sortOrder: 0));
    await repo.save(makeType('b', sortOrder: 1).copyWith(isArchived: true));
    expect(repo.getActive().map((t) => t.id), ['a']);
  });
}
