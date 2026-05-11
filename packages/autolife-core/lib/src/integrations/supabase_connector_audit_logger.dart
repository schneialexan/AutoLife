import 'package:supabase/supabase.dart';

import 'connector_audit_logger.dart';

/// Writes [`connector_event`](../../../../supabase/migrations/0020_connector_credentials.sql)
/// rows using the Supabase client (typically **service role** on the server).
class SupabaseConnectorAuditLogger implements ConnectorAuditLogger {
  SupabaseConnectorAuditLogger(this._client);

  final SupabaseClient _client;

  @override
  Future<void> log({
    required String tenantId,
    required String connectorId,
    required String kind,
    required String outcome,
    String? errorDetail,
    Map<String, dynamic> detail = const {},
    String? clientIp,
    String? userAgent,
  }) async {
    await _client.from('connector_event').insert({
      'tenant_id': tenantId,
      'connector_id': connectorId,
      'kind': kind,
      'outcome': outcome,
      'error_detail': errorDetail,
      'detail': detail,
      'client_ip': clientIp,
      'user_agent': userAgent,
    });
  }
}
