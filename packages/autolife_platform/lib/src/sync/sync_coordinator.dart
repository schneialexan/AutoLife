import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../auth/auth_service.dart';
import '../core/module_sync_gateway.dart';
import '../core/sync_cursor.dart';
import '../core/sync_mutation.dart';
import '../core/sync_status.dart';
import '../storage/outbox_store.dart';
import '../storage/platform_storage.dart';

/// Orchestrates push (outbox → remote) then pull (remote → Hive) across all
/// registered [ModuleSyncGateway]s using a single auth session and per-module
/// server-time cursors. Pull pagination/LWW live inside each gateway; the
/// coordinator owns sequencing, cursor persistence, and status.
class SyncCoordinator {
  SyncCoordinator({
    required AuthService auth,
    required OutboxStore outbox,
    required PlatformStorage storage,
    Future<bool> Function()? isOnline,
  }) : _auth = auth,
       _outbox = outbox,
       _storage = storage,
       _isOnline = isOnline ?? (() async => true) {
    _authSub = _auth.stateChanges.listen((_) {
      _refreshIdleStatus();
      if (_auth.state == PlatformAuthState.authenticated) {
        // Fire-and-forget on sign-in: failures are reflected in [status]; we
        // swallow here so an unawaited rejection can't crash the zone.
        unawaited(syncNow().catchError((Object _) {}));
      }
    });
    _refreshIdleStatus();
  }

  final AuthService _auth;
  final OutboxStore _outbox;
  final PlatformStorage _storage;
  final Future<bool> Function() _isOnline;

  final List<ModuleSyncGateway> _gateways = <ModuleSyncGateway>[];
  final ValueNotifier<SyncStatus> status = ValueNotifier<SyncStatus>(
    SyncStatus.localOnly,
  );

  StreamSubscription<PlatformAuthState>? _authSub;
  bool _running = false;

  static const String _cursorKeyPrefix = 'cursor:';

  void registerGateway(ModuleSyncGateway gateway) {
    if (_gateways.any((g) => g.moduleId == gateway.moduleId)) {
      return;
    }
    _gateways.add(gateway);
  }

  void _refreshIdleStatus() {
    if (_running) {
      return;
    }
    status.value = _auth.state == PlatformAuthState.authenticated
        ? SyncStatus.synced
        : SyncStatus.localOnly;
  }

  /// Push queued local edits, then pull remote changes. No-ops (and reflects
  /// `localOnly` / `offline`) when not authenticated or offline.
  ///
  /// On failure this updates [status] to [SyncStatus.error] **and rethrows**, so
  /// callers that trigger a manual sync (e.g. a "Sync now" button) can show the
  /// real error instead of a false success. Fire-and-forget callers should
  /// swallow the rejection (see the auth listener).
  Future<void> syncNow() async {
    if (_auth.state != PlatformAuthState.authenticated) {
      status.value = SyncStatus.localOnly;
      return;
    }
    if (_running) {
      return;
    }
    if (!await _isOnline()) {
      status.value = SyncStatus.offline;
      return;
    }
    _running = true;
    status.value = SyncStatus.syncing;
    try {
      await _pushOutbox();
      await _pullAll();
      status.value = SyncStatus.synced;
    } catch (_) {
      status.value = SyncStatus.error;
      rethrow;
    } finally {
      _running = false;
    }
  }

  /// Bulk idempotent upsert of all local records on first sign-in. The server
  /// forces `user_id = auth.uid()`, so a device can never claim rows onto
  /// another user.
  Future<void> claimLocalVault() async {
    if (_auth.state != PlatformAuthState.authenticated) {
      throw const AuthException(
        'Sign in before claiming the local vault.',
        code: 'not_authenticated',
      );
    }
    for (final gateway in _gateways) {
      final mutations = await gateway.collectLocalState();
      if (mutations.isNotEmpty) {
        await gateway.pushMutations(mutations);
      }
    }
    await syncNow();
  }

  Future<void> _pushOutbox() async {
    for (final gateway in _gateways) {
      final pending = _outbox.pendingForModule(gateway.moduleId);
      if (pending.isEmpty) {
        continue;
      }
      await gateway.pushMutations(pending);
      await _outbox.removeProcessed(pending);
    }
  }

  Future<void> _pullAll() async {
    for (final gateway in _gateways) {
      final cursor = _readCursor(gateway.moduleId);
      final changes = <SyncMutation>[];
      final maxSeen = await gateway.pullSince(
        cursor.lastServerUpdatedAt,
        onRemoteChange: changes.add,
      );
      if (changes.isNotEmpty) {
        await gateway.applyRemoteChanges(changes);
      }
      if (maxSeen != null) {
        await _writeCursor(cursor.advancedTo(maxSeen));
      }
    }
  }

  SyncCursor _readCursor(String moduleId) {
    final raw = _storage.metaBox.get('$_cursorKeyPrefix$moduleId');
    if (raw == null) {
      return SyncCursor(moduleId: moduleId);
    }
    return SyncCursor.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> _writeCursor(SyncCursor cursor) async {
    await _storage.metaBox.put(
      '$_cursorKeyPrefix${cursor.moduleId}',
      jsonEncode(cursor.toJson()),
    );
  }

  Future<void> dispose() async {
    await _authSub?.cancel();
    status.dispose();
  }
}
