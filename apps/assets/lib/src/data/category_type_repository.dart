import '../models/category_type.dart';

/// Thrown when an operation would exceed [CategoryType.maxTypes].
class CategoryTypeLimitException implements Exception {
  const CategoryTypeLimitException();

  @override
  String toString() => 'Cannot exceed ${CategoryType.maxTypes} category types.';
}

/// Read/write access to the shared catalog of [CategoryType]s.
abstract class CategoryTypeRepository {
  /// All types, including archived ones.
  List<CategoryType> getAll();

  /// Non-archived types, ordered by [CategoryType.sortOrder].
  List<CategoryType> getActive();

  CategoryType? getById(String id);

  /// Persists a new or existing type. Throws [CategoryTypeLimitException] when
  /// creating beyond the cap.
  Future<void> save(CategoryType type);

  Future<void> delete(String id);

  /// Seeds the starter types exactly once (guarded by a meta flag).
  Future<void> seedDefaults();
}
