import 'package:autolife_ui/autolife_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/home/home_screen.dart';
import '../screens/settings/settings_hub_screen.dart';
import '../screens/shell/dashboard_shell_scaffold.dart';
import '../screens/shell/module_placeholder_screen.dart';
import '../screens/smoke/add_event_screen.dart';
import '../screens/smoke/today_widget.dart';

/// Builds the GoRouter that backs the five-tab shell (+ optional Smoke tab).
GoRouter buildShellGoRouter({
  required bool smokeSurfaceEnabled,
}) {
  return GoRouter(
    initialLocation: '/home',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return DashboardShellScaffold(
            navigationShell: navigationShell,
            smokeSurfaceEnabled: smokeSurfaceEnabled,
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                pageBuilder: (context, state) => NoTransitionPage<void>(
                  key: state.pageKey,
                  child: const HomeScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/calendar',
                pageBuilder: (context, state) => NoTransitionPage<void>(
                  key: state.pageKey,
                  child: const ModulePlaceholderScreen(title: 'Calendar'),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/tasks',
                pageBuilder: (context, state) => NoTransitionPage<void>(
                  key: state.pageKey,
                  child: const ModulePlaceholderScreen(title: 'Tasks'),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/assets',
                pageBuilder: (context, state) => NoTransitionPage<void>(
                  key: state.pageKey,
                  child: const ModulePlaceholderScreen(title: 'Assets'),
                ),
              ),
            ],
          ),
          if (smokeSurfaceEnabled)
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/smoke',
                  pageBuilder: (context, state) => NoTransitionPage<void>(
                    key: state.pageKey,
                    child: Builder(
                      builder: (context) => Center(
                        child: SingleChildScrollView(
                          child: AutoLifeSurfaceCard(
                            child: Padding(
                              padding: EdgeInsets.all(
                                context.autoLifeTokens.spaceMd,
                              ),
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
                      ),
                    ),
                  ),
                ),
              ],
            ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                pageBuilder: (context, state) => NoTransitionPage<void>(
                  key: state.pageKey,
                  child: const SettingsHubScreen(),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
