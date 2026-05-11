/// Persists [`connector_event`](../../../../supabase/migrations/0020_connector_credentials.sql) rows.
abstract class ConnectorAuditLogger {
  Future<void> log({
    required String tenantId,
    required String connectorId,
    required String kind,
    required String outcome,
    String? errorDetail,
    Map<String, dynamic> detail,
    String? clientIp,
    String? userAgent,
  });
}

class SilentConnectorAuditLogger implements ConnectorAuditLogger {
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
  }) async {}
}

class ConnectorAuditRecord {
  ConnectorAuditRecord({
    required this.tenantId,
    required this.connectorId,
    required this.kind,
    required this.outcome,
    this.errorDetail,
    this.detail = const {},
    this.clientIp,
    this.userAgent,
  });

  final String tenantId;
  final String connectorId;
  final String kind;
  final String outcome;
  final String? errorDetail;
  final Map<String, dynamic> detail;
  final String? clientIp;
  final String? userAgent;
}

/// Test double capturing audit rows in memory.
class InMemoryConnectorAuditLogger implements ConnectorAuditLogger {
  final List<ConnectorAuditRecord> records = [];

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
    records.add(
      ConnectorAuditRecord(
        tenantId: tenantId,
        connectorId: connectorId,
        kind: kind,
        outcome: outcome,
        errorDetail: errorDetail,
        detail: Map<String, dynamic>.from(detail),
        clientIp: clientIp,
        userAgent: userAgent,
      ),
    );
  }
}
