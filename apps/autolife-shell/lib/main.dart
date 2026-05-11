import 'package:autolife_core/autolife_core.dart';
import 'package:autolife_shell/src/auth/oauth_redirect.dart';
import 'package:autolife_shell/src/screens/auth/password_recovery_screen.dart';
import 'package:autolife_shell/src/screens/auth/sessions_screen.dart';
import 'package:autolife_shell/src/screens/auth/sign_in_screen.dart';
import 'package:autolife_shell/src/widgets/shell_auth_deep_links.dart';
import 'package:autolife_ui/autolife_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/providers/auth_provider.dart';
import 'src/providers/shell_providers.dart';
import 'src/screens/control_center/approval_engine_screen.dart';
import 'src/screens/control_center/babysitter_link_screen.dart';
import 'src/screens/control_center/biometric_locks_screen.dart';
import 'src/screens/control_center/role_matrix_screen.dart';
import 'src/screens/health/health_stub_screen.dart';
import 'src/screens/family/family_switcher_screen.dart';
import 'src/screens/family/invitations_screen.dart';
import 'src/screens/tenancy/tenancy_bootstrap_shell.dart';
import 'src/screens/smoke/add_event_screen.dart';
import 'src/screens/smoke/today_widget.dart';
import 'src/smoke/smoke_test_harness.dart';

const _supabaseUrl = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
const _supabaseAnonKey = String.fromEnvironment(
  'AUTOLIFE_SUPABASE_ANON_KEY',
  defaultValue: '',
);
const _supabaseServiceRoleKey = String.fromEnvironment(
  'SUPABASE_SERVICE_ROLE_KEY',
  defaultValue: '',
);

/// Phase 1.8 integration harness skips the UX auth chrome (service-role client stays smoke-capable).
const _shellSmokeIntegration = bool.fromEnvironment(
  'AUTOLIFE_SMOKE_INTEGRATION_TEST',
  defaultValue: false,
);

String get _effectiveSupabaseApiKey =>
    _supabaseAnonKey.isNotEmpty ? _supabaseAnonKey : _supabaseServiceRoleKey;

bool get _supabaseConfigured =>
    _supabaseUrl.isNotEmpty && _effectiveSupabaseApiKey.isNotEmpty;

bool get _smokeSurfaceEnabled =>
    (_shellSmokeIntegration || kDebugMode) && _supabaseConfigured;

bool get _authChromeEnabled => _supabaseConfigured && !_shellSmokeIntegration;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (_shellSmokeIntegration) {
    SmokeTestHarness.initIntegrationTest();
  }

  ConnectivityWatcher watcher;
  if (_shellSmokeIntegration) {
    watcher = SmokeTestHarness.connectivity!;
  } else {
    watcher = ConnectivityWatcher();
  }

  final overrides = <Override>[];

  if (_supabaseConfigured) {
    final wired = AutoLifeSupabaseBootstrap.createServices(
      supabaseUrl: _supabaseUrl,
      supabaseKey: _effectiveSupabaseApiKey,
    );

    await wired.auth.initialize();

    overrides.addAll(
      smokeSupabaseOverrides(
        client: wired.client,
        authService: wired.auth,
        database: _shellSmokeIntegration
            ? AutolifeDatabase.memory()
            : AutolifeDatabase.openFlutterFile('autolife_shell.db'),
        connectivity: _shellSmokeIntegration
            ? SmokeTestHarness.connectivity!
            : watcher,
        shellSmokeIntegration: _shellSmokeIntegration,
      ),
    );
  } else {
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

  Widget _authenticatedHome(AuthService svc) {
    return ShellAuthDeepLinks(
      child: StreamBuilder<AutoLifeAuthState>(
        stream: svc.authStates,
        initialData: svc.currentState,
        builder: (context, snapshot) {
          final state = snapshot.data ?? svc.currentState;
          switch (state.phase) {
            case AutoLifeAuthPhase.bootstrapping:
            case AutoLifeAuthPhase.hydrating:
            case AutoLifeAuthPhase.refreshing:
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            case AutoLifeAuthPhase.awaitingPasswordRecovery:
              return const PasswordRecoveryScreen();
            case AutoLifeAuthPhase.unauthenticated:
              return SignInScreen(redirectUri: autolifeOAuthRedirect);
            case AutoLifeAuthPhase.authenticated:
              return TenancyBootstrapShell(
                dashboard:
                    ({
                      required List<TenancyEnrollment> enrollments,
                      required String activeFamilyId,
                      required VoidCallback reloadTenancy,
                    }) {
                      return _DemoShellHome(
                        enrollments: enrollments,
                        activeFamilyId: activeFamilyId,
                        reloadTenancy: reloadTenancy,
                      );
                    },
              );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AutoLife',
      theme: AutoLifeTheme.light(),
      darkTheme: AutoLifeTheme.dark(),
      themeMode: ThemeMode.system,
      home: _authChromeEnabled
          ? Consumer(
              builder: (context, ref, _) {
                final svc = ref.watch(authServiceProvider);
                return _authenticatedHome(svc);
              },
            )
          : const _DemoShellHome(),
    );
  }
}

class _DemoShellHome extends ConsumerStatefulWidget {
  const _DemoShellHome({
    this.enrollments = const [],
    this.activeFamilyId = '',
    this.reloadTenancy,
  });

  /// Populated once [TenancyBootstrapShell] has loaded memberships.
  final List<TenancyEnrollment> enrollments;
  final String activeFamilyId;
  final VoidCallback? reloadTenancy;

  @override
  ConsumerState<_DemoShellHome> createState() => _DemoShellHomeState();
}

class _DemoShellHomeState extends ConsumerState<_DemoShellHome> {
  var _index = 0;

  static const _devTenant = Tenant(tenantId: 'local-dev');

  String get _workspaceTitle {
    final id = widget.activeFamilyId;
    for (final e in widget.enrollments) {
      if (e.family.id == id) {
        return e.family.name;
      }
    }
    return 'AutoLife';
  }

  Tenant get _effectiveTenant => widget.reloadTenancy == null
      ? _devTenant
      : Tenant(tenantId: widget.activeFamilyId);

  FamilyRole? get _activeFamilyRole {
    final id = widget.activeFamilyId;
    for (final e in widget.enrollments) {
      if (e.family.id == id) {
        return e.membership.role;
      }
    }
    return null;
  }

  bool get _isFamilyOwner => _activeFamilyRole == FamilyRole.owner;

  bool get _canResolveApprovals {
    final r = _activeFamilyRole;
    return r == FamilyRole.owner || r == FamilyRole.partner;
  }

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

  int _settingsIndex() => _destinations.length - 1;

  @override
  Widget build(BuildContext context) {
    final sync = ref.watch(syncStatusProvider);
    final connectors = ref.watch(connectorListProvider);
    final connectorStatuses = ref.watch(connectorStatusProvider);
    final smokeIdx = _smokeIndex();
    final settingsIdx = _settingsIndex();
    final bodyLabel = switch (_index) {
      0 => 'Home',
      1 => 'Calendar',
      _ when smokeIdx >= 0 && _index == smokeIdx => 'Smoke',
      _ => 'Settings',
    };

    return AutoLifeBottomNavShell(
      appBar: AutoLifeAppBar(
        title: Text(_workspaceTitle),
        actions: widget.reloadTenancy == null
            ? null
            : [
                IconButton(
                  tooltip: 'Switch family',
                  icon: const Icon(Icons.groups_outlined),
                  onPressed: () {
                    Navigator.of(context).push<void>(
                      MaterialPageRoute<void>(
                        builder: (_) => FamilySwitcherScreen(
                          enrollments: widget.enrollments,
                          activeFamilyId: widget.activeFamilyId,
                          reloadTenancy: widget.reloadTenancy!,
                        ),
                      ),
                    );
                  },
                ),
                IconButton(
                  tooltip: 'Invitations',
                  icon: const Icon(Icons.mail_outline),
                  onPressed: () {
                    if (widget.activeFamilyId.isEmpty) return;
                    Navigator.of(context).push<void>(
                      MaterialPageRoute<void>(
                        builder: (_) => InvitationsScreen(
                          familyId: widget.activeFamilyId,
                          familyName: _workspaceTitle,
                          reloadTenancy: widget.reloadTenancy!,
                        ),
                      ),
                    );
                  },
                ),
              ],
      ),
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
          : _index == settingsIdx && _supabaseConfigured
          ? Padding(
              padding: const EdgeInsets.all(AutoLifeSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      bodyLabel,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  const Divider(),
                  if (widget.reloadTenancy != null &&
                      widget.activeFamilyId.isNotEmpty) ...[
                    ListTile(
                      leading: const Icon(Icons.grid_view_outlined),
                      title: const Text('Role matrix'),
                      subtitle: const Text(
                        'Capability toggles per family role (owners edit).',
                      ),
                      onTap: () {
                        Navigator.of(context).push<void>(
                          MaterialPageRoute<void>(
                            builder: (_) => RoleMatrixScreen(
                              familyId: widget.activeFamilyId,
                              familyName: _workspaceTitle,
                              isOwner: _isFamilyOwner,
                            ),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.rule_folder_outlined),
                      title: const Text('Approval queue'),
                      subtitle: const Text('Pending parent/partner decisions.'),
                      onTap: () {
                        Navigator.of(context).push<void>(
                          MaterialPageRoute<void>(
                            builder: (_) => ApprovalEngineScreen(
                              familyId: widget.activeFamilyId,
                              familyName: _workspaceTitle,
                              canResolve: _canResolveApprovals,
                            ),
                          ),
                        );
                      },
                    ),
                    if (_isFamilyOwner) ...[
                      ListTile(
                        leading: const Icon(Icons.fingerprint_outlined),
                        title: const Text('Biometric locks'),
                        subtitle: const Text('Require device auth for sensitive modules.'),
                        onTap: () {
                          Navigator.of(context).push<void>(
                            MaterialPageRoute<void>(
                              builder: (_) => const BiometricLocksScreen(),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.link_outlined),
                        title: const Text('Babysitter link'),
                        subtitle: const Text('Share a scoped, expiring read-only token.'),
                        onTap: () {
                          Navigator.of(context).push<void>(
                            MaterialPageRoute<void>(
                              builder: (_) => BabysitterLinkScreen(
                                familyId: widget.activeFamilyId,
                                familyName: _workspaceTitle,
                              ),
                            ),
                          );
                        },
                      ),
                      const Divider(),
                    ],
                    ListTile(
                      leading: const Icon(Icons.favorite_outline),
                      title: const Text('Health (demo)'),
                      subtitle: const Text('Biometric-gated placeholder for Phase 3.6.'),
                      onTap: () {
                        Navigator.of(context).push<void>(
                          MaterialPageRoute<void>(
                            builder: (_) => const HealthStubScreen(),
                          ),
                        );
                      },
                    ),
                    const Divider(),
                  ],
                  ListTile(
                    leading: const Icon(Icons.devices_other_outlined),
                    title: const Text('Sessions & devices'),
                    subtitle: Text(
                      'Manage refresh tokens scoped to this client vs every signed-in shell.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    onTap: () {
                      Navigator.of(context).push<void>(
                        MaterialPageRoute<void>(
                          builder: (_) => const SessionsScreen(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.refresh_outlined),
                    title: const Text('Silent refresh probe'),
                    onTap: () async {
                      final nav = ScaffoldMessenger.maybeOf(context);
                      final res = await ref
                          .read(authServiceProvider)
                          .refreshSessionExplicit();
                      res.when<void>(
                        success: (_) => nav?.showSnackBar(
                          const SnackBar(
                            content: Text('Refresh completed gracefully.'),
                          ),
                        ),
                        failure: (Failure fail) => nav?.showSnackBar(
                          SnackBar(
                            content: Text(fail.message ?? 'Refresh failed'),
                          ),
                        ),
                      );
                    },
                  ),
                  const Divider(),
                  Expanded(
                    child: AutoLifeSurfaceCard(
                      child: Padding(
                        padding: const EdgeInsets.all(AutoLifeSpacing.md),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tenant: ${_effectiveTenant.tenantId}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              Text(
                                'Sync: ${sync.phase.name} · pending '
                                '${sync.pendingQueueDepth}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Text(
                                'Connectors: ${connectors.join(', ')}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              if (connectorStatuses.isNotEmpty) ...[
                                const SizedBox(height: AutoLifeSpacing.xs),
                                Text(
                                  connectorStatuses.entries
                                      .map(
                                        (e) =>
                                            '${e.key} → '
                                            '${e.value.phase.name}',
                                      )
                                      .join(' · '),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                              if (sync.lastError != null) ...[
                                const SizedBox(height: AutoLifeSpacing.xs),
                                Text(
                                  sync.lastError!,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.error,
                                      ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
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
                        'Tenant: ${_effectiveTenant.tenantId}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: AutoLifeSpacing.sm),
                      Text(
                        'Sync: ${sync.phase.name} · pending '
                        '${sync.pendingQueueDepth}',
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
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
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
