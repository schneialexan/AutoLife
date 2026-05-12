import 'package:autolife_core/autolife_core.dart';
import 'package:autolife_shell/src/app.dart';
import 'package:autolife_shell/src/providers/shell_providers.dart';
import 'package:autolife_shell/src/shell/shell_environment.dart';
import 'package:autolife_shell/src/smoke/smoke_test_harness.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (shellSmokeIntegrationFlag) {
    SmokeTestHarness.initIntegrationTest();
  }

  ConnectivityWatcher watcher;
  if (shellSmokeIntegrationFlag) {
    watcher = SmokeTestHarness.connectivity!;
  } else {
    watcher = ConnectivityWatcher();
  }

  final overrides = <Override>[];

  if (shellSupabaseConfigured) {
    final wired = AutoLifeSupabaseBootstrap.createServices(
      supabaseUrl: shellSupabaseUrl,
      supabaseKey: shellEffectiveSupabaseApiKey,
    );

    await wired.auth.initialize();

    overrides.addAll(
      smokeSupabaseOverrides(
        client: wired.client,
        authService: wired.auth,
        database: shellSmokeIntegrationFlag
            ? AutolifeDatabase.memory()
            : AutolifeDatabase.openFlutterFile('autolife_shell.db'),
        connectivity: shellSmokeIntegrationFlag
            ? SmokeTestHarness.connectivity!
            : watcher,
        shellSmokeIntegration: shellSmokeIntegrationFlag,
      ),
    );
  } else {
    overrides.addAll(localOfflineBootstrapOverrides());
    overrides.add(
      connectorRegistryProvider.overrideWith((ref) {
        final registry = ConnectorRegistry();
        final sync = ref.read(syncEngineProvider);
        registry.register(
          OfflineAwareIntegrationConnector(
            inner: MockConnector(),
            offlineQueue: sync.offlineWriteQueue,
            probeOnline: () => sync.connectivityWatcher.isOnline(),
            defaultTenantId: 'local-dev',
            defaultActorId: 'shell-actor',
          ),
        );
        return registry;
      }),
    );
  }

  runApp(ProviderScope(overrides: overrides, child: const AutolifeShellApp()));
}
