import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../models/event_delivery_status.dart';
import '../models/role.dart';
import '../models/system_event.dart';
import '../services/event_producer.dart';
import '../services/offline_write_queue.dart';
import 'autolife_database.dart';
import 'conflict_resolver.dart';
import 'connectivity_watcher.dart';
import 'drift_offline_write_queue.dart';
import 'payload_cipher.dart';
import 'remote_sync_gateway.dart';

/// High-level lifecycle for foreground sync (`docs/offline-sync-contract.md`).
enum SyncEnginePhase { idle, syncing, offline, error }

@immutable
class SyncStatus {
  const SyncStatus({
    required this.phase,
    required this.pendingQueueDepth,
    this.lastError,
  });

  final SyncEnginePhase phase;
  final int pendingQueueDepth;
  final String? lastError;

  SyncStatus copyWith({
    SyncEnginePhase? phase,
    int? pendingQueueDepth,
    String? lastError,
  }) => SyncStatus(
        phase: phase ?? this.phase,
        pendingQueueDepth: pendingQueueDepth ?? this.pendingQueueDepth,
        lastError: lastError ?? this.lastError,
      );
}

EventDeliveryStatus _parseDeliveryStatus(String? raw) {
  switch (raw) {
    case 'pending':
      return EventDeliveryStatus.pending;
    case 'succeeded':
      return EventDeliveryStatus.succeeded;
    case 'failed':
      return EventDeliveryStatus.failed;
    case 'dead_letter':
      return EventDeliveryStatus.deadLetter;
    default:
      return EventDeliveryStatus.pending;
  }
}

/// Coordinates connectivity, remote pulls, cache merges, and queue drains.
class SyncEngine extends ChangeNotifier {
  SyncEngine({
    required AutolifeDatabase db,
    required RemoteSyncGateway gateway,
    required ConnectivityWatcher connectivity,
    required PayloadCipher cipher,
    required ConflictResolver conflictResolver,
    required String tenantId,

    /// UUID of the seeded `family` row for Postgres tenancy tables (`family`, `profile`, `membership`).
    /// [tenantId] alone still filters `system_event.tenant_id` (text slug, e.g. `local-dev`).
    String? tenancyFamilyScopeId,
    EventProducer? conflictEvents,
  })  : _db = db,
        _gateway = gateway,
        _connectivity = connectivity,
        _cipher = cipher,
        _resolver = conflictResolver,
        _tenantId = tenantId,
        _tenancyFamilyScopeId = tenancyFamilyScopeId,
        _conflictEvents = conflictEvents {
    // Defer listeners so we never call [notifyListeners] during the first
    // [ProviderScope]/[ChangeNotifierProvider] mount (avoids Flutter's !_dirty
    // assert on web and other platforms).
    Future.microtask(_startConnectivityObservation);
  }

  final AutolifeDatabase _db;
  final RemoteSyncGateway _gateway;
  final ConnectivityWatcher _connectivity;
  final PayloadCipher _cipher;
  final ConflictResolver _resolver;
  final String _tenantId;
  final String? _tenancyFamilyScopeId;
  final EventProducer? _conflictEvents;

  StreamSubscription<bool>? _subscription;

  bool _disposed = false;

  void _startConnectivityObservation() {
    if (_disposed) return;
    _subscription = _connectivity.watchOnline().listen(_onConnectivityChanged);
    unawaited(
      _connectivity.isOnline().then((online) {
        _onConnectivityChanged(online);
      }),
    );
  }

  void _onConnectivityChanged(bool online) {
    if (online) {
      unawaited(runCycle());
    } else {
      _emit(_status.copyWith(phase: SyncEnginePhase.offline));
    }
  }

  SyncStatus _status = const SyncStatus(
    phase: SyncEnginePhase.offline,
    pendingQueueDepth: 0,
  );

  SyncStatus get status => _status;

  /// Local Drift database (read models, watch queries).
  AutolifeDatabase get database => _db;

  /// Offline queue used by OfflineAwareIntegrationConnector (phase 1.7).
  OfflineWriteQueue get offlineWriteQueue =>
      DriftOfflineWriteQueue(_db, _cipher);

  ConnectivityWatcher get connectivityWatcher => _connectivity;

  static const tables = [
    'family',
    'profile',
    'membership',
    'system_event',
    'event_delivery',
  ];

  Future<void> runCycle() async {
    _emit(_status.copyWith(phase: SyncEnginePhase.syncing, lastError: null));
    try {
      for (final table in tables) {
        final watermark = await _maxUpdated(table);
        final rows = await _gateway.pullTable(
          tenantId: _tenantId,
          tenancyFamilyScopeId: _tenancyFamilyScopeId,
          table: table,
          updatedAfter: watermark,
          limit: 500,
        );
        for (final remote in rows) {
          await _mergeRemote(table, remote);
        }
      }
      await _drainQueue();
      await _refreshDepth();
      _emit(_status.copyWith(phase: SyncEnginePhase.idle, lastError: null));
    } catch (e, st) {
      debugPrint('sync cycle failed: $e\n$st');
      await _refreshDepth();
      _emit(
        _status.copyWith(
          phase: SyncEnginePhase.error,
          lastError: e.toString(),
        ),
      );
    }
  }

  Future<void> _refreshDepth() async {
    final rows = await (_db.select(_db.pendingWrites)
          ..where((t) => t.status.equals('pending')))
        .get();
    _emit(_status.copyWith(pendingQueueDepth: rows.length));
  }

  Future<DateTime?> _maxUpdated(String table) async {
    switch (table) {
      case 'system_event':
        final rows = await _db.select(_db.systemEventCache).get();
        return _maxDate(rows.map((e) => e.updatedAt));
      case 'event_delivery':
        final rows = await _db.select(_db.eventDeliveryCache).get();
        return _maxDate(rows.map((e) => e.updatedAt));
      case 'profile':
        final rows = await _db.select(_db.profileCache).get();
        return _maxDate(rows.map((e) => e.updatedAt));
      case 'family':
        final rows = await _db.select(_db.familyCache).get();
        return _maxDate(rows.map((e) => e.updatedAt));
      case 'membership':
        final rows = await _db.select(_db.membershipCache).get();
        return _maxDate(rows.map((e) => e.updatedAt));
      default:
        return null;
    }
  }

  DateTime? _maxDate(Iterable<DateTime> dates) {
    final list = dates.toList();
    if (list.isEmpty) return null;
    return list.reduce((a, b) => a.isAfter(b) ? a : b);
  }

  Future<void> _mergeRemote(String table, Map<String, dynamic> remote) async {
    switch (table) {
      case 'system_event':
        return _mergeSystemEvent(remote);
      case 'event_delivery':
        return _mergeEventDelivery(remote);
      case 'profile':
        return _mergeProfile(remote);
      case 'family':
        return _mergeFamily(remote);
      case 'membership':
        return _mergeMembership(remote);
      default:
        return;
    }
  }

  DateTime _eventRemoteTs(Map<String, dynamic> r) {
    final raw = r['updated_at'] ?? r['occurred_at'];
    return DateTime.parse(raw as String).toUtc();
  }

  Map<String, dynamic> _localSystemMap(SystemEventCacheData l) => {
        'id': l.id,
        'updated_at': l.updatedAt.toIso8601String(),
        'actor_role': 'local',
      };

  SystemEventCacheCompanion _systemCompanion(
    Map<String, dynamic> r,
    DateTime updated,
  ) {
    return SystemEventCacheCompanion.insert(
      id: r['id'] as String,
      tenantId: r['tenant_id'] as String,
      actorId: r['actor_id'] as String,
      module: r['module'] as String,
      type: r['type'] as String,
      payloadJson: jsonEncode(r['payload']),
      idempotencyKey: r['idempotency_key'] as String,
      occurredAt: DateTime.parse(r['occurred_at'] as String).toUtc(),
      orderingTag: r['ordering_tag'] as String,
      schemaVersion: (r['schema_version'] as num).toInt(),
      updatedAt: updated,
    );
  }

  Future<void> _mergeSystemEvent(Map<String, dynamic> r) async {
    final id = r['id'] as String;
    final remoteTs = _eventRemoteTs(r);
    final local = await (_db.select(_db.systemEventCache)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (local == null) {
      await _db.into(_db.systemEventCache).insert(_systemCompanion(r, remoteTs));
      return;
    }
    final winner = _resolver.resolve(
      localRow: _localSystemMap(local),
      remoteRow: r,
      actorRole: null,
      localUpdated: local.updatedAt,
      remoteUpdated: remoteTs,
    );
    if (_shouldEmitConflict(local.updatedAt, remoteTs)) {
      await _emitConflict(table: 'system_event', id: id, winner: winner);
    }
    if (winner == ConflictWinner.remote) {
      await (_db.update(_db.systemEventCache)..where((t) => t.id.equals(id)))
          .write(
        SystemEventCacheCompanion(
          tenantId: Value(r['tenant_id'] as String),
          actorId: Value(r['actor_id'] as String),
          module: Value(r['module'] as String),
          type: Value(r['type'] as String),
          payloadJson: Value(jsonEncode(r['payload'])),
          idempotencyKey: Value(r['idempotency_key'] as String),
          occurredAt:
              Value(DateTime.parse(r['occurred_at'] as String).toUtc()),
          orderingTag: Value(r['ordering_tag'] as String),
          schemaVersion: Value((r['schema_version'] as num).toInt()),
          updatedAt: Value(remoteTs),
        ),
      );
    }
  }

  Future<void> _mergeEventDelivery(Map<String, dynamic> r) async {
    final id = r['id'] as String;
    final remoteTs = DateTime.parse(r['updated_at'] as String).toUtc();
    final local = await (_db.select(_db.eventDeliveryCache)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    final parsed = _parseDeliveryStatus(r['status'] as String?);
    if (local == null) {
      await _db.into(_db.eventDeliveryCache).insert(
            EventDeliveryCacheCompanion.insert(
              id: id,
              eventId: r['event_id'] as String,
              consumer: r['consumer'] as String,
              attempt: (r['attempt'] as num).toInt(),
              status: parsed,
              lastError: Value(r['last_error'] as String?),
              nextAttemptAt: Value(
                r['next_attempt_at'] != null
                    ? DateTime.parse(r['next_attempt_at'] as String).toUtc()
                    : null,
              ),
              updatedAt: remoteTs,
            ),
          );
      return;
    }
    final winner = _resolver.resolve(
      localRow: {
        'id': local.id,
        'updated_at': local.updatedAt.toIso8601String(),
      },
      remoteRow: r,
      actorRole: null,
      localUpdated: local.updatedAt,
      remoteUpdated: remoteTs,
    );
    if (_shouldEmitConflict(local.updatedAt, remoteTs)) {
      await _emitConflict(table: 'event_delivery', id: id, winner: winner);
    }
    if (winner == ConflictWinner.remote) {
      await (_db.update(_db.eventDeliveryCache)..where((t) => t.id.equals(id)))
          .write(
        EventDeliveryCacheCompanion(
          eventId: Value(r['event_id'] as String),
          consumer: Value(r['consumer'] as String),
          attempt: Value((r['attempt'] as num).toInt()),
          status: Value(parsed),
          lastError: Value(r['last_error'] as String?),
          nextAttemptAt: Value(
            r['next_attempt_at'] != null
                ? DateTime.parse(r['next_attempt_at'] as String).toUtc()
                : null,
          ),
          updatedAt: Value(remoteTs),
        ),
      );
    }
  }

  Future<void> _mergeProfile(Map<String, dynamic> r) async {
    final id = r['id'] as String;
    final remoteTs = DateTime.parse(r['updated_at'] as String).toUtc();
    final local = await (_db.select(_db.profileCache)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (local == null) {
      await _db.into(_db.profileCache).insert(
            ProfileCacheCompanion.insert(
              id: id,
              displayName: r['display_name'] as String,
              familyId: Value(r['family_id'] as String?),
              updatedAt: remoteTs,
            ),
          );
      return;
    }
    final winner = _resolver.resolve(
      localRow: {
        'id': local.id,
        'updated_at': local.updatedAt.toIso8601String(),
        'actor_role': r['actor_role'],
      },
      remoteRow: r,
      actorRole: r['actor_role'] as String?,
      localUpdated: local.updatedAt,
      remoteUpdated: remoteTs,
    );
    if (_shouldEmitConflict(local.updatedAt, remoteTs)) {
      await _emitConflict(table: 'profile', id: id, winner: winner);
    }
    if (winner == ConflictWinner.remote) {
      await (_db.update(_db.profileCache)..where((t) => t.id.equals(id))).write(
            ProfileCacheCompanion(
              displayName: Value(r['display_name'] as String),
              familyId: Value(r['family_id'] as String?),
              updatedAt: Value(remoteTs),
            ),
          );
    }
  }

  Future<void> _mergeFamily(Map<String, dynamic> r) async {
    final id = r['id'] as String;
    final remoteTs = DateTime.parse(r['updated_at'] as String).toUtc();
    final local = await (_db.select(_db.familyCache)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (local == null) {
      await _db.into(_db.familyCache).insert(
            FamilyCacheCompanion.insert(
              id: id,
              displayName: r['display_name'] as String,
              updatedAt: remoteTs,
            ),
          );
      return;
    }
    final winner = _resolver.resolve(
      localRow: {'id': local.id, 'updated_at': local.updatedAt.toIso8601String()},
      remoteRow: r,
      actorRole: r['actor_role'] as String?,
      localUpdated: local.updatedAt,
      remoteUpdated: remoteTs,
    );
    if (_shouldEmitConflict(local.updatedAt, remoteTs)) {
      await _emitConflict(table: 'family', id: id, winner: winner);
    }
    if (winner == ConflictWinner.remote) {
      await (_db.update(_db.familyCache)..where((t) => t.id.equals(id))).write(
            FamilyCacheCompanion(
              displayName: Value(r['display_name'] as String),
              updatedAt: Value(remoteTs),
            ),
          );
    }
  }

  Future<void> _mergeMembership(Map<String, dynamic> r) async {
    final id = r['id'] as String;
    final remoteTs = DateTime.parse(r['updated_at'] as String).toUtc();
    final local = await (_db.select(_db.membershipCache)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    final role = Role.values.firstWhere(
      (e) => e.name == (r['role'] as String),
      orElse: () => Role.member,
    );
    if (local == null) {
      await _db.into(_db.membershipCache).insert(
            MembershipCacheCompanion.insert(
              id: id,
              familyId: r['family_id'] as String,
              profileId: r['profile_id'] as String,
              role: role,
              updatedAt: remoteTs,
            ),
          );
      return;
    }
    final winner = _resolver.resolve(
      localRow: {
        'id': local.id,
        'updated_at': local.updatedAt.toIso8601String(),
        'actor_role': local.role.name,
      },
      remoteRow: {
        ...r,
        'actor_role': role.name,
      },
      actorRole: role.name,
      localUpdated: local.updatedAt,
      remoteUpdated: remoteTs,
    );
    if (_shouldEmitConflict(local.updatedAt, remoteTs)) {
      await _emitConflict(table: 'membership', id: id, winner: winner);
    }
    if (winner == ConflictWinner.remote) {
      await (_db.update(_db.membershipCache)
            ..where((t) => t.id.equals(id)))
          .write(
        MembershipCacheCompanion(
          familyId: Value(r['family_id'] as String),
          profileId: Value(r['profile_id'] as String),
          role: Value(role),
          updatedAt: Value(remoteTs),
        ),
      );
    }
  }

  bool _shouldEmitConflict(DateTime localTs, DateTime remoteTs) =>
      localTs.toUtc().compareTo(remoteTs.toUtc()) != 0;

  Future<void> _emitConflict({
    required String table,
    required String id,
    required ConflictWinner winner,
  }) async {
    final producer = _conflictEvents;
    if (producer == null) return;
    final event = SystemEvent(
      tenantId: _tenantId,
      actorId: 'sync-engine',
      module: 'sync',
      type: 'conflict_detected',
      payload: {
        'table': table,
        'id': id,
        'winner': winner.name,
      },
      idempotencyKey:
          'conflict_${table}_$id-${DateTime.now().toUtc().microsecondsSinceEpoch}',
      occurredAt: DateTime.now().toUtc(),
      orderingTag: 'sync',
      schemaVersion: 1,
    );
    final _ = await producer.publish(event);
  }

  Future<void> _drainQueue() async {
    final pending = await (_db.select(_db.pendingWrites)
          ..where((t) => t.status.equals('pending'))
          ..orderBy([
            (t) => OrderingTerm(expression: t.targetTable),
            (t) => OrderingTerm(expression: t.createdAt),
          ]))
        .get();
    for (final row in pending) {
      try {
        final body = await _cipher.decryptJson(
          Uint8List.fromList(row.payload),
        );
        await _gateway.applyWrite(
          table: row.targetTable,
          operation: row.operation,
          payload: body,
        );
        await (_db.update(_db.pendingWrites)..where((t) => t.id.equals(row.id)))
            .write(
          const PendingWritesCompanion(
            status: Value('succeeded'),
            lastError: Value.absent(),
          ),
        );
      } catch (e) {
        await (_db.update(_db.pendingWrites)..where((t) => t.id.equals(row.id)))
            .write(
          PendingWritesCompanion(
            status: const Value('failed'),
            lastError: Value(e.toString()),
            attempt: Value(row.attempt + 1),
            nextAttemptAt: Value(
              DateTime.now().toUtc().add(const Duration(minutes: 5)),
            ),
          ),
        );
      }
    }
  }

  void _emit(SyncStatus next) {
    _status = next;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _subscription?.cancel();
    super.dispose();
  }
}
