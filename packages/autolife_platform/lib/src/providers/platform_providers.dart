import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_service.dart';
import '../bootstrap/autolife_platform_base.dart';
import '../core/sync_status.dart';

/// Overridden in the host app's `main` with the initialized platform.
final autolifePlatformProvider = Provider<AutolifePlatform>((ref) {
  throw UnimplementedError('autolifePlatformProvider must be overridden');
});

final authServiceProvider = Provider<AuthService>((ref) {
  return ref.watch(autolifePlatformProvider).auth;
});

/// Live [SyncStatus] for the status chip, bridged from the coordinator's
/// [ValueNotifier].
final syncStatusProvider = StreamProvider<SyncStatus>((ref) {
  final notifier = ref.watch(autolifePlatformProvider).coordinator.status;
  final controller = StreamController<SyncStatus>();
  controller.add(notifier.value);
  void listener() => controller.add(notifier.value);
  notifier.addListener(listener);
  ref.onDispose(() {
    notifier.removeListener(listener);
    controller.close();
  });
  return controller.stream;
});

/// Live [PlatformAuthState], so the UI can switch between sign-in and
/// signed-in views.
final authStateProvider = StreamProvider<PlatformAuthState>((ref) {
  final auth = ref.watch(authServiceProvider);
  final controller = StreamController<PlatformAuthState>();
  controller.add(auth.state);
  final sub = auth.stateChanges.listen(controller.add);
  ref.onDispose(() {
    sub.cancel();
    controller.close();
  });
  return controller.stream;
});
