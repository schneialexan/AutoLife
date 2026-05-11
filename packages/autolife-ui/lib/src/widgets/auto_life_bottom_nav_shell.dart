import 'package:flutter/material.dart';

import 'package:autolife_ui/src/tokens/spacing.dart';

/// Scaffold hosting [NavigationBar] and branch body — shell chrome baseline.
class AutoLifeBottomNavShell extends StatelessWidget {
  /// Shell with Material 3 [NavigationBar] synced to [selectedIndex].
  const AutoLifeBottomNavShell({
    super.key,
    required this.body,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.appBar,
    this.floatingActionButton,
    this.drawer,
  });

  final Widget body;
  final List<NavigationDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final Widget? drawer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      drawer: drawer,
      body: Padding(
        padding: const EdgeInsets.only(bottom: AutoLifeSpacing.xxs),
        child: body,
      ),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        destinations: destinations,
        onDestinationSelected: onDestinationSelected,
      ),
    );
  }
}
