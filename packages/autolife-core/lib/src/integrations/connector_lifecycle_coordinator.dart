import 'package:uuid/uuid.dart';

import '../common/failure.dart';
import '../common/result.dart';
import '../common/tenant.dart';
import '../models/system_event.dart';
import '../services/event_producer.dart';
import 'connector_audit_logger.dart';
import 'connector_registry.dart';
import 'connector_status.dart';
import 'connector_status_tracker.dart';

/// Wraps lifecycle calls with `connector_event` audit rows and bus emits.
class ConnectorLifecycleCoordinator {
  ConnectorLifecycleCoordinator({
    required ConnectorRegistry registry,
    required ConnectorStatusTracker statusTracker,
    required ConnectorAuditLogger audit,
    required EventProducer eventProducer,
    required String actorId,
    required String defaultTenantId,
    Uuid? uuid,
  }) : _registry = registry,
       _statusTracker = statusTracker,
       _audit = audit,
       _eventProducer = eventProducer,
       _actorId = actorId,
       _defaultTenantId = defaultTenantId,
       _uuid = uuid ?? const Uuid();

  final ConnectorRegistry _registry;
  final ConnectorStatusTracker _statusTracker;
  final ConnectorAuditLogger _audit;
  final EventProducer _eventProducer;
  final String _actorId;
  final String _defaultTenantId;
  final Uuid _uuid;

  String _tenant(Tenant? tenant) => tenant?.tenantId ?? _defaultTenantId;

  Future<void> _auditRow({
    required Tenant? tenant,
    required String connectorId,
    required String kind,
    required Result<dynamic> result,
    Map<String, dynamic> detail = const {},
    String? clientIp,
    String? userAgent,
  }) async {
    final outcome = result.maybeWhen(
      success: (_) => 'success',
      failure: (_) => 'failure',
      orElse: () => 'failure',
    );
    final err = result.maybeWhen(failure: (f) => f.message, orElse: () => null);
    await _audit.log(
      tenantId: _tenant(tenant),
      connectorId: connectorId,
      kind: kind,
      outcome: outcome,
      errorDetail: err,
      detail: detail,
      clientIp: clientIp,
      userAgent: userAgent,
    );
  }

  Future<void> _publishOk({
    required String tenantId,
    required String connectorId,
    required String type,
    Map<String, dynamic> extra = const {},
  }) async {
    final event = SystemEvent(
      tenantId: tenantId,
      actorId: _actorId,
      module: 'integrations',
      type: type,
      payload: {'connector_id': connectorId, ...extra},
      idempotencyKey: _uuid.v4(),
      occurredAt: DateTime.now().toUtc(),
      orderingTag: '$connectorId:$type:${_uuid.v4()}',
      schemaVersion: 1,
    );
    await _eventProducer.publish(event);
  }

  Future<void> _publishError({
    required String tenantId,
    required String connectorId,
    required Failure failure,
    Map<String, dynamic> extra = const {},
  }) async {
    final event = SystemEvent(
      tenantId: tenantId,
      actorId: _actorId,
      module: 'integrations',
      type: 'connector_error',
      payload: {
        'connector_id': connectorId,
        'failure_code': failure.code,
        'failure_message': failure.message,
        ...extra,
      },
      idempotencyKey: _uuid.v4(),
      occurredAt: DateTime.now().toUtc(),
      orderingTag: '$connectorId:connector_error:${_uuid.v4()}',
      schemaVersion: 1,
    );
    await _eventProducer.publish(event);
  }

  Future<Result<void>> connect(
    String connectorId, {
    Tenant? tenant,
    String? clientIp,
    String? userAgent,
  }) async {
    final connector = _registry[connectorId];
    if (connector == null) {
      final miss = Result<void>.failure(
        Failure(code: 'connector_unknown', message: connectorId),
      );
      await _auditRow(
        tenant: tenant,
        connectorId: connectorId,
        kind: 'connect',
        result: miss,
        clientIp: clientIp,
        userAgent: userAgent,
      );
      return miss;
    }
    _statusTracker.setStatus(
      connectorId,
      const ConnectorStatus(phase: ConnectorConnectionPhase.connecting),
    );
    final result = await connector.connect(tenant: tenant);
    await _auditRow(
      tenant: tenant,
      connectorId: connectorId,
      kind: 'connect',
      result: result,
      clientIp: clientIp,
      userAgent: userAgent,
    );
    final tid = _tenant(tenant);
    switch (result) {
      case Success():
        await _publishOk(
          tenantId: tid,
          connectorId: connectorId,
          type: 'connector_connected',
        );
        _statusTracker.setStatus(
          connectorId,
          const ConnectorStatus(phase: ConnectorConnectionPhase.connected),
        );
      case FailureResult(:final failure):
        await _publishError(
          tenantId: tid,
          connectorId: connectorId,
          failure: failure,
          extra: {'lifecycle': 'connect'},
        );
        _statusTracker.setStatus(
          connectorId,
          ConnectorStatus(
            phase: ConnectorConnectionPhase.error,
            lastError: failure.message,
          ),
        );
    }
    return result;
  }

  Future<Result<void>> refresh(
    String connectorId, {
    Tenant? tenant,
    String? clientIp,
    String? userAgent,
  }) async {
    final connector = _registry[connectorId];
    if (connector == null) {
      final miss = Result<void>.failure(
        Failure(code: 'connector_unknown', message: connectorId),
      );
      await _auditRow(
        tenant: tenant,
        connectorId: connectorId,
        kind: 'refresh',
        result: miss,
        clientIp: clientIp,
        userAgent: userAgent,
      );
      return miss;
    }
    _statusTracker.setStatus(
      connectorId,
      const ConnectorStatus(phase: ConnectorConnectionPhase.refreshing),
    );
    final result = await connector.refresh(tenant: tenant);
    await _auditRow(
      tenant: tenant,
      connectorId: connectorId,
      kind: 'refresh',
      result: result,
      clientIp: clientIp,
      userAgent: userAgent,
    );
    final tid = _tenant(tenant);
    switch (result) {
      case Success():
        _statusTracker.setStatus(
          connectorId,
          const ConnectorStatus(phase: ConnectorConnectionPhase.connected),
        );
      case FailureResult(:final failure):
        await _publishError(
          tenantId: tid,
          connectorId: connectorId,
          failure: failure,
          extra: {'lifecycle': 'refresh'},
        );
        _statusTracker.setStatus(
          connectorId,
          ConnectorStatus(
            phase: ConnectorConnectionPhase.error,
            lastError: failure.message,
          ),
        );
    }
    return result;
  }

  Future<Result<void>> disconnect(
    String connectorId, {
    Tenant? tenant,
    String? clientIp,
    String? userAgent,
  }) async {
    final connector = _registry[connectorId];
    if (connector == null) {
      final miss = Result<void>.failure(
        Failure(code: 'connector_unknown', message: connectorId),
      );
      await _auditRow(
        tenant: tenant,
        connectorId: connectorId,
        kind: 'disconnect',
        result: miss,
        clientIp: clientIp,
        userAgent: userAgent,
      );
      return miss;
    }
    final result = await connector.disconnect();
    await _auditRow(
      tenant: tenant,
      connectorId: connectorId,
      kind: 'disconnect',
      result: result,
      clientIp: clientIp,
      userAgent: userAgent,
    );
    final tid = _tenant(tenant);
    switch (result) {
      case Success():
        await _publishOk(
          tenantId: tid,
          connectorId: connectorId,
          type: 'connector_disconnected',
        );
        _statusTracker.setStatus(
          connectorId,
          const ConnectorStatus(phase: ConnectorConnectionPhase.disconnected),
        );
      case FailureResult(:final failure):
        await _publishError(
          tenantId: tid,
          connectorId: connectorId,
          failure: failure,
          extra: {'lifecycle': 'disconnect'},
        );
        _statusTracker.setStatus(
          connectorId,
          ConnectorStatus(
            phase: ConnectorConnectionPhase.error,
            lastError: failure.message,
          ),
        );
    }
    return result;
  }

  Future<Result<void>> healthcheck(
    String connectorId, {
    Tenant? tenant,
    String? clientIp,
    String? userAgent,
  }) async {
    final connector = _registry[connectorId];
    if (connector == null) {
      final miss = Result<void>.failure(
        Failure(code: 'connector_unknown', message: connectorId),
      );
      await _auditRow(
        tenant: tenant,
        connectorId: connectorId,
        kind: 'healthcheck',
        result: miss,
        clientIp: clientIp,
        userAgent: userAgent,
      );
      return miss;
    }
    final result = await connector.healthcheck(tenant: tenant);
    await _auditRow(
      tenant: tenant,
      connectorId: connectorId,
      kind: 'healthcheck',
      result: result,
      clientIp: clientIp,
      userAgent: userAgent,
    );
    final tid = _tenant(tenant);
    switch (result) {
      case FailureResult(:final failure):
        await _publishError(
          tenantId: tid,
          connectorId: connectorId,
          failure: failure,
          extra: {'lifecycle': 'healthcheck'},
        );
        _statusTracker.setStatus(
          connectorId,
          ConnectorStatus(
            phase: ConnectorConnectionPhase.error,
            lastError: failure.message,
          ),
        );
      case Success():
        break;
    }
    return result;
  }

  Future<Result<Map<String, dynamic>>> pullChanges(
    String connectorId, {
    Tenant? tenant,
    String? clientIp,
    String? userAgent,
  }) async {
    final connector = _registry[connectorId];
    if (connector == null) {
      final miss = Result<Map<String, dynamic>>.failure(
        Failure(code: 'connector_unknown', message: connectorId),
      );
      await _auditRow(
        tenant: tenant,
        connectorId: connectorId,
        kind: 'pull_changes',
        result: miss,
        clientIp: clientIp,
        userAgent: userAgent,
      );
      return miss;
    }
    final result = await connector.pullChanges(tenant: tenant);
    await _auditRow(
      tenant: tenant,
      connectorId: connectorId,
      kind: 'pull_changes',
      result: result,
      clientIp: clientIp,
      userAgent: userAgent,
    );
    final tid = _tenant(tenant);
    switch (result) {
      case FailureResult(:final failure):
        await _publishError(
          tenantId: tid,
          connectorId: connectorId,
          failure: failure,
          extra: {'lifecycle': 'pull_changes'},
        );
      case Success():
        break;
    }
    return result;
  }

  Future<Result<void>> pushChanges(
    String connectorId, {
    Tenant? tenant,
    required Map<String, dynamic> payload,
    String? clientIp,
    String? userAgent,
  }) async {
    final connector = _registry[connectorId];
    if (connector == null) {
      final miss = Result<void>.failure(
        Failure(code: 'connector_unknown', message: connectorId),
      );
      await _auditRow(
        tenant: tenant,
        connectorId: connectorId,
        kind: 'push_changes',
        result: miss,
        detail: {'queued': false},
        clientIp: clientIp,
        userAgent: userAgent,
      );
      return miss;
    }
    final result = await connector.pushChanges(
      tenant: tenant,
      payload: payload,
    );
    await _auditRow(
      tenant: tenant,
      connectorId: connectorId,
      kind: 'push_changes',
      result: result,
      detail: const {},
      clientIp: clientIp,
      userAgent: userAgent,
    );
    final tid = _tenant(tenant);
    switch (result) {
      case FailureResult(:final failure):
        await _publishError(
          tenantId: tid,
          connectorId: connectorId,
          failure: failure,
          extra: {'lifecycle': 'push_changes'},
        );
      case Success():
        break;
    }
    return result;
  }
}
