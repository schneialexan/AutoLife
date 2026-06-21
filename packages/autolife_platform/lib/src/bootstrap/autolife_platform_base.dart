import 'dart:math';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../auth/auth_service.dart';
import '../auth/local_only_auth_service.dart';
import '../auth/supabase_auth_service.dart';
import '../blob/blob_sync_service.dart';
import '../core/module_sync_gateway.dart';
import '../storage/outbox_store.dart';
import '../storage/platform_storage.dart';
import '../sync/sync_coordinator.dart';

/// Entry point that wires the platform together. Apps call
/// [AutolifePlatform.initialize] once at startup, then register their module
/// gateways. When [supabaseUrl] is empty the platform runs in **local-only**
/// mode (no network), keeping the standalone-offline guarantee.
class AutolifePlatform {
  AutolifePlatform._({
    required this.auth,
    required this.outbox,
    required this.coordinator,
    required this.storage,
    required this.deviceId,
    required this.isSyncConfigured,
    this.client,
    this.blobSync,
  });

  final AuthService auth;
  final OutboxStore outbox;
  final SyncCoordinator coordinator;
  final PlatformStorage storage;

  /// Stable per-install id used as the LWW tie-breaker.
  final String deviceId;

  /// True when Supabase config was supplied and sign-in is possible.
  final bool isSyncConfigured;

  final sb.SupabaseClient? client;
  final BlobSyncService? blobSync;

  static const String _deviceIdKey = 'device_id';

  /// Initializes Supabase (when configured), opens encrypted platform storage,
  /// and constructs the auth service + sync coordinator. Hive must already be
  /// initialized by the host app (`Hive.initFlutter()`).
  static Future<AutolifePlatform> initialize({
    String supabaseUrl = '',
    String supabaseAnonKey = '',
  }) async {
    final storage = await PlatformStorage.open();
    final deviceId = await _ensureDeviceId(storage);
    final outbox = OutboxStore(storage.outboxBox);

    final configured = supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
    if (!configured) {
      final auth = LocalOnlyAuthService();
      return AutolifePlatform._(
        auth: auth,
        outbox: outbox,
        coordinator: SyncCoordinator(
          auth: auth,
          outbox: outbox,
          storage: storage,
        ),
        storage: storage,
        deviceId: deviceId,
        isSyncConfigured: false,
      );
    }

    await sb.Supabase.initialize(
      url: supabaseUrl,
      publishableKey: supabaseAnonKey,
    );
    final client = sb.Supabase.instance.client;
    final auth = SupabaseAuthService(client);
    final coordinator = SyncCoordinator(
      auth: auth,
      outbox: outbox,
      storage: storage,
      isOnline: _connectivityProbe,
    );
    final blobSync = SupabaseBlobSyncService(
      client,
      currentUserId: () => auth.userId ?? '',
    );
    return AutolifePlatform._(
      auth: auth,
      outbox: outbox,
      coordinator: coordinator,
      storage: storage,
      deviceId: deviceId,
      isSyncConfigured: true,
      client: client,
      blobSync: blobSync,
    );
  }

  void registerGateway(ModuleSyncGateway gateway) {
    coordinator.registerGateway(gateway);
  }

  static Future<bool> _connectivityProbe() async {
    final results = await Connectivity().checkConnectivity();
    return !results.contains(ConnectivityResult.none);
  }

  static Future<String> _ensureDeviceId(PlatformStorage storage) async {
    final existing = storage.metaBox.get(_deviceIdKey);
    if (existing != null) {
      return existing;
    }
    final random = Random.secure();
    final id = List<int>.generate(
      16,
      (_) => random.nextInt(256),
    ).map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    await storage.metaBox.put(_deviceIdKey, id);
    return id;
  }
}
