import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/asset_storage.dart';
import '../data/category_type_repository.dart';
import '../data/hive_category_type_repository.dart';
import '../models/category_type.dart';
import 'asset_providers.dart';

/// Overridden in `main` with the opened [AppStorage] instance.
final appStorageProvider = Provider<AppStorage>((ref) {
  throw UnimplementedError('appStorageProvider must be overridden');
});

final categoryTypeRepositoryProvider = Provider<CategoryTypeRepository>((ref) {
  return HiveCategoryTypeRepository(ref.watch(appStorageProvider));
});

final categoryTypesProvider =
    StateNotifierProvider<CategoryTypeNotifier, List<CategoryType>>((ref) {
      return CategoryTypeNotifier(ref.watch(categoryTypeRepositoryProvider));
    });

/// Active (non-archived) types, ordered for display.
final activeCategoryTypesProvider = Provider<List<CategoryType>>((ref) {
  return ref.watch(categoryTypesProvider).where((t) => !t.isArchived).toList();
});

/// typeId -> number of assets that hold a non-empty value for that type.
final typeUsageProvider = Provider<Map<String, int>>((ref) {
  final assets = ref.watch(assetsProvider);
  final counts = <String, int>{};
  for (final asset in assets) {
    asset.propertyValues.forEach((typeId, value) {
      if (!value.isEmpty) {
        counts.update(typeId, (c) => c + 1, ifAbsent: () => 1);
      }
    });
  }
  return counts;
});

class CategoryTypeNotifier extends StateNotifier<List<CategoryType>> {
  CategoryTypeNotifier(this._repository) : super(const <CategoryType>[]) {
    _load();
  }

  final CategoryTypeRepository _repository;

  void _load() {
    state = _repository.getAll();
  }

  /// Re-reads from the repository. Called after a sync pull writes to Hive.
  void reload() => _load();

  bool get isAtLimit => state.length >= CategoryType.maxTypes;

  Future<void> save(CategoryType type) async {
    await _repository.save(type);
    _load();
  }

  Future<void> delete(String id) async {
    await _repository.delete(id);
    _load();
  }

  Future<void> archive(CategoryType type, {required bool archived}) async {
    await _repository.save(type.copyWith(isArchived: archived));
    _load();
  }

  int nextSortOrder() {
    if (state.isEmpty) {
      return 0;
    }
    return state.map((t) => t.sortOrder).reduce((a, b) => a > b ? a : b) + 1;
  }
}
