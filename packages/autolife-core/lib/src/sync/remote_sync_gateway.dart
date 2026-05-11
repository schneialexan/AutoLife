import 'package:supabase/supabase.dart';

/// Remote source for incremental sync (Supabase or fakes in tests).
abstract class RemoteSyncGateway {
  Future<List<Map<String, dynamic>>> pullTable({
    required String tenantId,

    /// When set: UUID of the active `families` row — scopes `families`/`memberships` pulls.
    String? tenancyFamilyScopeId,

    /// When set: scopes `profile` pulls to `profile.id`.
    String? tenancyProfileScopeId,

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
    String? tenancyProfileScopeId,
    required String table,
    DateTime? updatedAfter,
    int limit = 200,
  }) async {
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

    if (table == 'families' || table == 'memberships') {
      if (tenancyFamilyScopeId == null) {
        return [];
      }
    } else if (table == 'profile') {
      if (tenancyProfileScopeId == null) {
        return [];
      }
    }

    final familyScoped = tenancyFamilyScopeId ?? tenantId;
    var qb = _client.from(table).select();
    if (table == 'system_event') {
      qb = qb.eq('tenant_id', tenantId);
    } else if (table == 'profile') {
      qb = qb.eq('id', tenancyProfileScopeId!);
    } else if (table == 'memberships') {
      qb = qb.eq('family_id', familyScoped).isFilter('removed_at', null);
    } else if (table == 'families') {
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
        if (table == 'memberships') {
          final familyId = payload['family_id'] as String?;
          final userId = payload['user_id'] as String?;
          if (familyId == null || userId == null) {
            throw StateError('membership_update_requires_family_and_user_ids');
          }
          final patch = Map<String, dynamic>.from(payload)
            ..remove('family_id')
            ..remove('user_id')
            ..remove('id');
          await _client
              .from(table)
              .update(patch)
              .eq('family_id', familyId)
              .eq('user_id', userId);
          return;
        }
        final id = payload['id'] as String?;
        if (id == null) {
          throw StateError('update_payload_missing_id');
        }
        final patch = Map<String, dynamic>.from(payload)..remove('id');
        await _client.from(table).update(patch).eq('id', id);
        return;
      case 'delete':
        if (table == 'memberships') {
          final familyId = payload['family_id'] as String?;
          final userId = payload['user_id'] as String?;
          if (familyId == null || userId == null) {
            throw StateError('membership_delete_requires_family_and_user_ids');
          }
          await _client
              .from(table)
              .delete()
              .eq('family_id', familyId)
              .eq('user_id', userId);
          return;
        }
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
    String? tenancyProfileScopeId,
    required String table,
    DateTime? updatedAfter,
    int limit = 200,
  }) async => [];

  @override
  Future<void> applyWrite({
    required String table,
    required String operation,
    required Map<String, dynamic> payload,
  }) async {}
}
