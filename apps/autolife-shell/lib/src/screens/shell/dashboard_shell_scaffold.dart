import 'package:autolife_ui/autolife_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/shell_providers.dart';
import '../../shell/shell_workspace_data.dart';
import '../../router/shell_navigation.dart';
import '../home/context_aware_fab.dart';

/// Bottom navigation + app bar wrapping [StatefulNavigationShell] (phase 3.1).
class DashboardShellScaffold extends ConsumerWidget {
  const DashboardShellScaffold({
    super.key,
    required this.navigationShell,
    required this.smokeSurfaceEnabled,
  });

  final StatefulNavigationShell navigationShell;
  final bool smokeSurfaceEnabled;

  static String _workspaceTitle(ShellWorkspaceData ws) {
    final id = ws.activeFamilyId;
    for (final e in ws.enrollments) {
      if (e.family.id == id) {
        return e.family.name;
      }
    }
    return 'AutoLife';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ws = ref.watch(shellWorkspaceProvider);
    final title = _workspaceTitle(ws);
    final branchIdx = navigationShell.currentIndex;

    final destinations = <NavigationDestination>[
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
      const NavigationDestination(
        icon: Icon(Icons.task_alt_outlined),
        selectedIcon: Icon(Icons.task_alt),
        label: 'Tasks',
      ),
      const NavigationDestination(
        icon: Icon(Icons.inventory_2_outlined),
        selectedIcon: Icon(Icons.inventory_2),
        label: 'Assets',
      ),
      if (smokeSurfaceEnabled)
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

    final showFamilyChrome =
        ws.tenancyResolved && ws.enrollments.isNotEmpty && ws.activeFamilyId.isNotEmpty;

    return AutoLifeBottomNavShell(
      appBar: AutoLifeAppBar(
        title: Text(title),
        actions: showFamilyChrome
            ? [
                IconButton(
                  tooltip: 'Switch family',
                  icon: const Icon(Icons.groups_outlined),
                  onPressed: () => context.openFamilySwitcher(ws),
                ),
                IconButton(
                  tooltip: 'Invitations',
                  icon: const Icon(Icons.mail_outline),
                  onPressed: () => context.openInvitations(ws, title),
                ),
              ]
            : null,
      ),
      destinations: destinations,
      selectedIndex: branchIdx,
      onDestinationSelected: navigationShell.goBranch,
      floatingActionButton:
          branchIdx < 4 ? ContextAwareFab(branchIndex: branchIdx) : null,
      body: navigationShell,
    );
  }
}
