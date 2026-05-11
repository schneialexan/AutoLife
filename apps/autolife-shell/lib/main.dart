import 'package:autolife_core/autolife_core.dart';
import 'package:autolife_ui/autolife_ui.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const AutolifeShellApp());
}

class AutolifeShellApp extends StatelessWidget {
  const AutolifeShellApp({super.key});

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

class _DemoShellHome extends StatefulWidget {
  const _DemoShellHome();

  @override
  State<_DemoShellHome> createState() => _DemoShellHomeState();
}

class _DemoShellHomeState extends State<_DemoShellHome> {
  int _index = 0;

  static const _devTenant = Tenant(tenantId: 'local-dev');

  static const _destinations = [
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: 'Home',
    ),
    NavigationDestination(
      icon: Icon(Icons.calendar_month_outlined),
      selectedIcon: Icon(Icons.calendar_month),
      label: 'Calendar',
    ),
    NavigationDestination(
      icon: Icon(Icons.settings_outlined),
      selectedIcon: Icon(Icons.settings),
      label: 'Settings',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final bodyLabel = switch (_index) {
      0 => 'Home',
      1 => 'Calendar',
      _ => 'Settings',
    };

    return AutoLifeBottomNavShell(
      appBar: AutoLifeAppBar(title: const Text('AutoLife')),
      destinations: _destinations,
      selectedIndex: _index,
      onDestinationSelected: (i) => setState(() => _index = i),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AutoLifeSpacing.md),
          child: AutoLifeSurfaceCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(bodyLabel, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AutoLifeSpacing.sm),
                Text(
                  'Tenant: ${_devTenant.tenantId}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
