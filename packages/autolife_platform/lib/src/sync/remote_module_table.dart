import 'package:supabase_flutter/supabase_flutter.dart' as sb;

/// Thin abstraction over a single module table (e.g. `assets.items`). Gateways
/// depend on this rather than the Supabase client directly, so their mapping /
/// LWW / cursor logic is unit-testable against a fake.
abstract class RemoteModuleTable {
  /// Idempotent upsert keyed on the row `id` (the idempotency key). Rows
  /// already carry `payload`, `schema_version`, `updated_at`, `deleted_at`,
  /// `device_id`; `user_id` and `server_updated_at` are server-assigned.
  Future<void> upsertRows(List<Map<String, dynamic>> rows);

  /// Returns rows with `server_updated_at` strictly greater than [cursor]
  /// (or all rows when null), ordered ascending by `server_updated_at`, capped
  /// at [limit]. RLS scopes results to the current user.
  Future<List<Map<String, dynamic>>> fetchSince(
    DateTime? cursor, {
    required int limit,
  });
}

/// [RemoteModuleTable] backed by Supabase PostgREST.
class SupabaseModuleTable implements RemoteModuleTable {
  SupabaseModuleTable(
    this._client, {
    required this.schema,
    required this.table,
  });

  final sb.SupabaseClient _client;
  final String schema;
  final String table;

  sb.SupabaseQueryBuilder get _builder => _client.schema(schema).from(table);

  @override
  Future<void> upsertRows(List<Map<String, dynamic>> rows) async {
    if (rows.isEmpty) {
      return;
    }
    // Stamp the owning user explicitly. Relying on the column default
    // (`user_id default auth.uid()`) alone makes PostgREST resolve the row
    // owner only while returning the written rows, which can fail the upsert
    // with HTTP 406 under RLS. Setting `user_id` up front satisfies the
    // `with check (user_id = auth.uid())` policy on both the insert and the
    // on-conflict update path. Falls back to the column default when no
    // session is cached locally.
    final userId = _client.auth.currentUser?.id;
    final payload = userId == null
        ? rows
        : [
            for (final row in rows)
              <String, dynamic>{...row, 'user_id': userId},
          ];
    // `return=minimal` skips selecting the written rows back: this is a
    // push-only operation, so it saves a round-trip and sidesteps RLS edge
    // cases on the returned representation.
    await _builder.upsert(payload, onConflict: 'id').setHeader(
          'Prefer',
          'return=minimal,resolution=merge-duplicates',
        );
  }

  @override
  Future<List<Map<String, dynamic>>> fetchSince(
    DateTime? cursor, {
    required int limit,
  }) async {
    final query = _builder.select();
    final filtered = cursor == null
        ? query
        : query.gt('server_updated_at', cursor.toUtc().toIso8601String());
    final rows = await filtered
        .order('server_updated_at', ascending: true)
        .limit(limit);
    return (rows as List)
        .map((row) => (row as Map).cast<String, dynamic>())
        .toList();
  }
}
