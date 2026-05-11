import 'dart:async';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

import 'autolife_database.dart';
import 'conflict_resolver.dart';
import 'connectivity_watcher.dart';
import 'payload_cipher.dart';
import 'remote_sync_gateway.dart';
import 'sync_engine.dart';

/// Minimal [SyncEngine] for apps that have not wired Supabase yet (foreground-only, offline).
SyncEngine createShellPlaceholderSyncEngine({required String tenantId}) {
  return SyncEngine(
    db: AutolifeDatabase.memory(),
    gateway: const NoopRemoteSyncGateway(),
    connectivity: ConnectivityWatcher.fake(
      stream: Stream.value(false),
      initialOnline: false,
    ),
    cipher: PayloadCipher(SecretKey(Uint8List(32))),
    conflictResolver: LastWriterWinsResolver(),
    tenantId: tenantId,
  );
}
