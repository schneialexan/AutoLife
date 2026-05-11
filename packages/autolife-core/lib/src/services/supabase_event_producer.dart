import 'package:supabase/supabase.dart';

import '../common/failure.dart';
import '../common/result.dart';
import '../models/system_event.dart';
import 'event_producer.dart';

/// Inserts into `system_event`, relying on Postgres `UNIQUE (tenant_id, idempotency_key)`.
///
/// Duplicate `(tenant_id, idempotency_key)` inserts return the persisted row exactly as if the
/// first insert succeeded ([Result.success]) — PostgREST errors are mapped to idempotent selects.
class SupabaseEventProducer implements EventProducer {
  SupabaseEventProducer(this._client);

  final SupabaseClient _client;

  Map<String, dynamic> _insertPayload(SystemEvent event) {
    final json = event.toJson()..remove('id');
    return Map<String, dynamic>.from(json);
  }

  @override
  Future<Result<SystemEvent>> publish(SystemEvent event) async {
    try {
      final row = await _client
          .from('system_event')
          .insert(_insertPayload(event))
          .select()
          .maybeSingle();

      if (row != null) {
        return Result.success(
          SystemEvent.fromJson(Map<String, dynamic>.from(row)),
        );
      }

      // PostgREST can return zero rows depending on RLS posture; normalize via select.
      return await _loadExisting(event.tenantId, event.idempotencyKey);
    } on PostgrestException catch (e) {
      if (_isIdempotencyDuplicate(e))
        return _loadExisting(event.tenantId, event.idempotencyKey);
      return Result.failure(
        Failure(
          code: 'event_publish_failed',
          message: e.message,
          details: {'code': e.code, 'hint': e.hint, 'details': e.details},
        ),
      );
    } catch (e, st) {
      return Result.failure(
        Failure(
          code: 'event_publish_unexpected',
          message: e.toString(),
          details: {'stack': st.toString()},
        ),
      );
    }
  }

  Future<Result<SystemEvent>> _loadExisting(
    String tenantId,
    String idempotencyKey,
  ) async {
    try {
      final row = await _client
          .from('system_event')
          .select()
          .eq('tenant_id', tenantId)
          .eq('idempotency_key', idempotencyKey)
          .maybeSingle();

      if (row != null) {
        return Result.success(
          SystemEvent.fromJson(Map<String, dynamic>.from(row)),
        );
      }
      return Result.failure(
        Failure(code: 'event_idempotent_miss', message: 'expected row'),
      );
    } on PostgrestException catch (e) {
      return Result.failure(
        Failure(
          code: 'event_idempotent_select_failed',
          message: e.message,
          details: {'code': e.code},
        ),
      );
    }
  }

  bool _isIdempotencyDuplicate(PostgrestException e) {
    final code = e.code;
    if (code == '23505') return true;
    final hint = '${e.details ?? ''} ${e.message}';
    return hint.contains('system_event_tenant_idempotency') ||
        hint.toLowerCase().contains('duplicate key');
  }
}
