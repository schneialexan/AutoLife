import 'dart:convert';

import '../constants/category_colors.dart';
import '../models/category_type.dart';
import '../models/value_kind.dart';
import 'asset_storage.dart';
import 'category_type_repository.dart';

class HiveCategoryTypeRepository implements CategoryTypeRepository {
  HiveCategoryTypeRepository(this._storage);

  final AppStorage _storage;

  @override
  List<CategoryType> getAll() {
    final types = _storage.categoryTypeBox.values
        .map(
          (raw) =>
              CategoryType.fromJson(jsonDecode(raw) as Map<String, dynamic>),
        )
        .toList();
    types.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return types;
  }

  @override
  List<CategoryType> getActive() {
    return getAll().where((t) => !t.isArchived).toList();
  }

  @override
  CategoryType? getById(String id) {
    final raw = _storage.categoryTypeBox.get(id);
    if (raw == null) {
      return null;
    }
    return CategoryType.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  Future<void> save(CategoryType type) async {
    final isNew = !_storage.categoryTypeBox.containsKey(type.id);
    if (isNew && _storage.categoryTypeBox.length >= CategoryType.maxTypes) {
      throw const CategoryTypeLimitException();
    }
    await _storage.categoryTypeBox.put(type.id, jsonEncode(type.toJson()));
  }

  @override
  Future<void> delete(String id) async {
    await _storage.categoryTypeBox.delete(id);
  }

  @override
  Future<void> seedDefaults() async {
    final alreadySeeded =
        _storage.metaBox.get(AppStorage.seededKey) as bool? ?? false;
    if (alreadySeeded) {
      return;
    }
    final now = DateTime.now();
    final starters = <CategoryType>[
      CategoryType(
        id: 'category',
        name: 'Category',
        valueKind: ValueKind.text,
        accentColor: CategoryColors.blue,
        displayIcon: 'icon:category',
        sortOrder: 0,
        createdAt: now,
      ),
      CategoryType(
        id: 'brand',
        name: 'Brand',
        valueKind: ValueKind.text,
        accentColor: CategoryColors.amber,
        displayIcon: 'icon:tag',
        sortOrder: 1,
        createdAt: now,
      ),
      CategoryType(
        id: 'model',
        name: 'Model',
        valueKind: ValueKind.text,
        accentColor: CategoryColors.teal,
        displayIcon: 'icon:cube',
        sortOrder: 2,
        createdAt: now,
      ),
    ];
    for (final type in starters) {
      await _storage.categoryTypeBox.put(type.id, jsonEncode(type.toJson()));
    }
    await _storage.metaBox.put(AppStorage.seededKey, true);
  }
}
