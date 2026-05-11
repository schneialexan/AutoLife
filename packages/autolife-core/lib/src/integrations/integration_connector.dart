import 'package:uuid/uuid.dart';

import '../common/result.dart';
import '../common/tenant.dart';
import '../services/offline_write_queue.dart';
import '../sync/drift_offline_write_queue.dart';

/// Sync direction for an integration instance (`connector_credential.direction`).
enum IntegrationConnectorDirection {
  oneWayIn,
  oneWayOut,
  twoWay,
}

extension IntegrationConnectorDirectionWire on IntegrationConnectorDirection {
  /// Wire / Postgres enum literal.
  String get wireLiteral => switch (this) {
    IntegrationConnectorDirection.oneWayIn => 'one_way_in',
    IntegrationConnectorDirection.oneWayOut => 'one_way_out',
    IntegrationConnectorDirection.twoWay => 'two_way',
  };
}

/// Canonical outbound/inbound integration seam (phase 1.7).
///
/// Credential persistence and OAuth completion run through Supabase Vault and
/// the `oauth-callback` Edge Function (`docs/integration-connector-contract.md`).
/// Implementations are registered in `connector_registry.dart`.
abstract class IntegrationConnector {
  /// Stable id registered in [ConnectorRegistry] (`mock`, `google_calendar`, …).
  String get connectorId;

  IntegrationConnectorDirection get directions;

  Future<Result<void>> connect({Tenant? tenant});

  Future<Result<void>> refresh({Tenant? tenant});

  Future<Result<void>> disconnect();

  Future<Result<void>> healthcheck({Tenant? tenant});

  Future<Result<Map<String, dynamic>>> pullChanges({Tenant? tenant});

  Future<Result<void>> pushChanges({
    Tenant? tenant,
    required Map<String, dynamic> payload,
  });
}

/// Wraps a connector so [pushChanges] uses [OfflineWriteQueue] while offline.
///
/// Uses [OfflineWritePayloadKeys.targetTable] value [`connectorPushTargetTable`].
class OfflineAwareIntegrationConnector implements IntegrationConnector {
  OfflineAwareIntegrationConnector({
    required IntegrationConnector inner,
    required OfflineWriteQueue offlineQueue,
    required Future<bool> Function() probeOnline,
    required String defaultTenantId,
    required String defaultActorId,
  }) : _inner = inner,
       _offlineQueue = offlineQueue,
       _probeOnline = probeOnline,
       _defaultTenantId = defaultTenantId,
       _defaultActorId = defaultActorId;

  final IntegrationConnector _inner;
  final OfflineWriteQueue _offlineQueue;
  final Future<bool> Function() _probeOnline;
  final String _defaultTenantId;
  final String _defaultActorId;

  static const connectorPushTargetTable = 'connector_push';

  @override
  String get connectorId => _inner.connectorId;

  @override
  IntegrationConnectorDirection get directions => _inner.directions;

  String _tenant(Tenant? tenant) => tenant?.tenantId ?? _defaultTenantId;

  @override
  Future<Result<void>> connect({Tenant? tenant}) =>
      _inner.connect(tenant: tenant);

  @override
  Future<Result<void>> disconnect() => _inner.disconnect();

  @override
  Future<Result<void>> healthcheck({Tenant? tenant}) =>
      _inner.healthcheck(tenant: tenant);

  @override
  Future<Result<Map<String, dynamic>>> pullChanges({Tenant? tenant}) =>
      _inner.pullChanges(tenant: tenant);

  @override
  Future<Result<void>> refresh({Tenant? tenant}) =>
      _inner.refresh(tenant: tenant);

  @override
  Future<Result<void>> pushChanges({
    Tenant? tenant,
    required Map<String, dynamic> payload,
  }) async {
    final online = await _probeOnline();
    if (!online) {
      final idem =
          '$connectorId:${_tenant(tenant)}:${const Uuid().v4()}';
      return _offlineQueue.enqueue(
        OfflineWritePayloadBuilder.build(
          tenantId: _tenant(tenant),
          actorId: _defaultActorId,
          targetTable: connectorPushTargetTable,
          operation: 'insert',
          idempotencyKey: idem,
          payload: {
            'connector_id': connectorId,
            'payload': payload,
          },
        ),
      );
    }
    return _inner.pushChanges(tenant: tenant, payload: payload);
  }
}
