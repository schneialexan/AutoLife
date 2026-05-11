import 'package:autolife_core/autolife_core.dart';
import 'package:autolife_ui/autolife_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase/supabase.dart';

import 'src/providers/shell_providers.dart';
import 'src/screens/smoke/add_event_screen.dart';
import 'src/screens/smoke/today_widget.dart';
import 'src/smoke/smoke_test_harness.dart';

const _supabaseUrl = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
const _supabaseKey = String.fromEnvironment(
  'SUPABASE_SERVICE_ROLE_KEY',
  defaultValue: '',
);

bool get _supabaseConfigured =>
    _supabaseUrl.isNotEmpty && _supabaseKey.isNotEmpty;

bool get _smokeSurfaceEnabled => kDebugMode && _supabaseConfigured;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const integration = bool.fromEnvironment(
    'AUTOLIFE_SMOKE_INTEGRATION_TEST',
    defaultValue: false,
  );
  if (integration) {
    SmokeTestHarness.initIntegrationTest();
  }

  final connectivity = integration
      ? SmokeTestHarness.connectivity!
      : (_supabaseConfigured ? ConnectivityWatcher() : null);

  final overrides = <Override>[
    if (_supabaseConfigured)
      ...smokeSupabaseOverrides(
        client: SupabaseClient(_supabaseUrl, _supabaseKey),
        database: integration
            ? AutolifeDatabase.memory()
            : AutolifeDatabase.openFlutterFile('autolife_shell.db'),
        connectivity: connectivity!,
      )
    else
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
  ];

  runApp(ProviderScope(overrides: overrides, child: const AutolifeShellApp()));
}

class AutolifeShellApp extends ConsumerStatefulWidget {
  const AutolifeShellApp({super.key});

  @override
  ConsumerState<AutolifeShellApp> createState() => _AutolifeShellAppState();
}

class _AutolifeShellAppState extends ConsumerState<AutolifeShellApp> {
  var _connectorsPrimed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_connectorsPrimed && _supabaseConfigured) {
      _connectorsPrimed = true;
      _primeConnectors();
    }
  }

  Future<void> _primeConnectors() async {
    final coordinator = ref.read(connectorLifecycleCoordinatorProvider);
    await coordinator.connect('mock');
    final ok = await coordinator.healthcheck('mock');
    ok.when(
      success: (_) {},
      failure: (f) => debugPrint('mock connector healthcheck: ${f.message}'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AutoLife',
      theme: AutoLifeTheme.light(),
      darkTheme: AutoLifeTheme.dark(),
      themeMode: ThemeMode.system,
      home: const _DemoShellHome(),
    );
  }
}

class _DemoShellHome extends ConsumerStatefulWidget {
  const _DemoShellHome();

  @override
  ConsumerState<_DemoShellHome> createState() => _DemoShellHomeState();
}

class _DemoShellHomeState extends ConsumerState<_DemoShellHome> {
  var _index = 0;

  static const _devTenant = Tenant(tenantId: 'local-dev');

  List<NavigationDestination> get _destinations => [
        const NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Home',
        ),
        const NavigationDestination(
          icon: Icon(Icons.calendar_month_outlined),
          selectedIcon: Icon(Icons.calendar_month),
          label: 'Calendar',
        ),
        if (_smokeSurfaceEnabled)
          const NavigationDestination(
            icon: Icon(Icons.science_outlined),
            selectedIcon: Icon(Icons.science),
            label: 'Smoke',
          ),
        const NavigationDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ];

  int _smokeIndex() {
    if (!_smokeSurfaceEnabled) return -1;
    return _destinations.length - 2;
  }

  @override
  Widget build(BuildContext context) {
    final sync = ref.watch(syncStatusProvider);
    final connectors = ref.watch(connectorListProvider);
    final connectorStatuses = ref.watch(connectorStatusProvider);
    final smokeIdx = _smokeIndex();
    final bodyLabel = switch (_index) {
      0 => 'Home',
      1 => 'Calendar',
      _ when smokeIdx >= 0 && _index == smokeIdx => 'Smoke',
      _ => 'Settings',
    };

    return AutoLifeBottomNavShell(
      appBar: AutoLifeAppBar(title: const Text('AutoLife')),
      destinations: _destinations,
      selectedIndex: _index,
      onDestinationSelected: (i) => setState(() => _index = i),
      body: _index == smokeIdx && smokeIdx >= 0
          ? Center(
              child: SingleChildScrollView(
                child: AutoLifeSurfaceCard(
                  child: Padding(
                    padding: EdgeInsets.all(context.autoLifeTokens.spaceMd),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AddEventScreen(),
                        SizedBox(height: AutoLifeSpacing.lg),
                        TodayWidget(),
                      ],
                    ),
                  ),
                ),
              ),
            )
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(AutoLifeSpacing.md),
                child: AutoLifeSurfaceCard(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bodyLabel,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AutoLifeSpacing.sm),
                      Text(
                        'Tenant: ${_devTenant.tenantId}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: AutoLifeSpacing.sm),
                      Text(
                        'Sync: ${sync.phase.name} · pending ${sync.pendingQueueDepth}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: AutoLifeSpacing.sm),
                      Text(
                        'Connectors: ${connectors.join(', ')}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      if (connectorStatuses.isNotEmpty) ...[
                        const SizedBox(height: AutoLifeSpacing.xs),
                        Text(
                          connectorStatuses.entries
                              .map((e) => '${e.key} → ${e.value.phase.name}')
                              .join(' · '),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                      if (sync.lastError != null) ...[
                        const SizedBox(height: AutoLifeSpacing.xs),
                        Text(
                          sync.lastError!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.error,
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
