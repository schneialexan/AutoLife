import 'dart:async';

import 'package:autolife_core/autolife_core.dart';
import 'package:autolife_shell/src/auth/oauth_redirect.dart';
import 'package:autolife_shell/src/screens/auth/password_recovery_screen.dart';
import 'package:autolife_shell/src/screens/auth/sign_in_screen.dart';
import 'package:autolife_shell/src/screens/tenancy/tenancy_bootstrap_shell.dart';
import 'package:autolife_shell/src/shell/shell_environment.dart';
import 'package:autolife_shell/src/shell/shell_workspace_data.dart';
import 'package:autolife_shell/src/widgets/shell_auth_deep_links.dart';
import 'package:autolife_ui/autolife_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'providers/auth_provider.dart';
import 'providers/shell_providers.dart';
import 'router/app_router.dart';

/// Root shell — Phase 3.1 wires GoRouter under tenancy when auth chrome is on.
class AutolifeShellApp extends ConsumerStatefulWidget {
  const AutolifeShellApp({super.key});

  @override
  ConsumerState<AutolifeShellApp> createState() => _AutolifeShellAppState();
}

class _AutolifeShellAppState extends ConsumerState<AutolifeShellApp> {
  late final GoRouter _router = buildShellGoRouter(
    smokeSurfaceEnabled: shellSmokeSurfaceEnabled(
      supabaseConfigured: shellSupabaseConfigured,
    ),
  );

  var _connectorsPrimed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_connectorsPrimed && shellSupabaseConfigured) {
      _connectorsPrimed = true;
      unawaited(_primeConnectors());
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

  Widget _shellRouterSubtree() {
    return MaterialApp.router(
      title: 'AutoLife',
      theme: AutoLifeTheme.light(),
      darkTheme: AutoLifeTheme.dark(),
      themeMode: ThemeMode.system,
      routerConfig: _router,
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
                      return ProviderScope(
                        overrides: [
                          shellWorkspaceProvider.overrideWithValue(
                            ShellWorkspaceData(
                              enrollments: enrollments,
                              activeFamilyId: activeFamilyId,
                              reloadTenancy: reloadTenancy,
                            ),
                          ),
                        ],
                        child: _shellRouterSubtree(),
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
    if (!shellAuthChromeEnabled) {
      return ProviderScope(
        overrides: [
          shellWorkspaceProvider.overrideWithValue(ShellWorkspaceData.demo()),
        ],
        child: _shellRouterSubtree(),
      );
    }

    return MaterialApp(
      title: 'AutoLife',
      theme: AutoLifeTheme.light(),
      darkTheme: AutoLifeTheme.dark(),
      themeMode: ThemeMode.system,
      // Web can report defaultRouteName `/home` while only `home` (/) exists here;
      // inner [MaterialApp.router] owns `/home`. Force `/` for this navigator.
      initialRoute: '/',
      home: Consumer(
        builder: (context, ref, _) {
          final svc = ref.watch(authServiceProvider);
          return _authenticatedHome(svc);
        },
      ),
    );
  }
}
