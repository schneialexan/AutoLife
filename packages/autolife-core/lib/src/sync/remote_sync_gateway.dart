import 'package:supabase/supabase.dart';

/// Remote source for incremental sync (Supabase or fakes in tests).
abstract class RemoteSyncGateway {
  Future<List<Map<String, dynamic>>> pullTable({
    required String tenantId,

    /// When set (typical smoke shell): UUID of the `family` row + `family_id` on derived rows.
    /// [tenantId] still scopes `system_event.tenant_id` (text slug).
    String? tenancyFamilyScopeId,
    required String table,
    DateTime? updatedAfter,
    int limit = 200,
  });

  /// Applies a drained [operation] from the local queue (`insert` / `update` / `delete`).
  Future<void> applyWrite({
    required String table,
    required String operation,
    required Map<String, dynamic> payload,
  });
}

class SupabaseRemoteSyncGateway implements RemoteSyncGateway {
  SupabaseRemoteSyncGateway(this._client);

  final SupabaseClient _client;

  @override
  Future<List<Map<String, dynamic>>> pullTable({
    required String tenantId,
    String? tenancyFamilyScopeId,
    required String table,
    DateTime? updatedAfter,
    int limit = 200,
  }) async {
    final familyScoped = tenancyFamilyScopeId ?? tenantId;
    if (table == 'event_delivery') {
      var q = _client
          .from('event_delivery')
          .select('*, system_event!inner(tenant_id)')
          .eq('system_event.tenant_id', tenantId);
      if (updatedAfter != null) {
        q = q.gt('updated_at', updatedAfter.toUtc().toIso8601String());
      }
      final rows = await q.order('updated_at').limit(limit);
      return _rowsAsMaps(rows);
    }

    var qb = _client.from(table).select();
    if (table == 'system_event') {
      qb = qb.eq('tenant_id', tenantId);
    } else if (table == 'profile') {
      qb = qb.eq('family_id', familyScoped);
    } else if (table == 'membership') {
      qb = qb.eq('family_id', familyScoped);
    } else if (table == 'family') {
      qb = qb.eq('id', familyScoped);
    }

    if (updatedAfter != null) {
      qb = qb.gt('updated_at', updatedAfter.toUtc().toIso8601String());
    }
    final rows = await qb.order('updated_at').limit(limit);
    return _rowsAsMaps(rows);
  }

  @override
  Future<void> applyWrite({
    required String table,
    required String operation,
    required Map<String, dynamic> payload,
  }) async {
    switch (operation) {
      case 'insert':
        await _client.from(table).insert(payload);
        return;
      case 'update':
        final id = payload['id'] as String?;
        if (id == null) {
          throw StateError('update_payload_missing_id');
        }
        final patch = Map<String, dynamic>.from(payload)..remove('id');
        await _client.from(table).update(patch).eq('id', id);
        return;
      case 'delete':
        final id = payload['id'] as String?;
        if (id == null) {
          throw StateError('delete_payload_missing_id');
        }
        await _client.from(table).delete().eq('id', id);
        return;
      default:
        throw StateError('unknown_operation: $operation');
    }
  }

  List<Map<String, dynamic>> _rowsAsMaps(dynamic rows) {
    final list = rows as List<dynamic>;
    return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }
}

class NoopRemoteSyncGateway implements RemoteSyncGateway {
  const NoopRemoteSyncGateway();

  @override
  Future<List<Map<String, dynamic>>> pullTable({
    required String tenantId,
    String? tenancyFamilyScopeId,
    required String table,
    DateTime? updatedAfter,
    int limit = 200,
  }) async =>
      [];

  @override
  Future<void> applyWrite({
    required String table,
    required String operation,
    required Map<String, dynamic> payload,
  }) async {}
}
