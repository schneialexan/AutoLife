import '../common/result.dart';

/// Generic persistence contract for feature modules. Concrete DAOs live in
/// apps or sync layers (e.g. phase 1.6 Drift).
abstract class Repository<T, TId> {
  Future<Result<T>> getById(TId id);

  Future<Result<List<T>>> list({int? limit, int? offset});

  Future<Result<void>> upsert(T entity);

  Future<Result<void>> delete(TId id);
}
