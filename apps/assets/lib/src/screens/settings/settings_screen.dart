import 'package:flutter/material.dart';

import '../category_types/category_type_manager_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.category_outlined),
            title: const Text('Categories'),
            subtitle: const Text('Manage field types, colors, and icons'),
            trailing: const Icon(Icons.chevron_right),
            minVerticalPadding: 12,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const CategoryTypeManagerScreen(),
                ),
              );
            },
          ),
          Opacity(
            opacity: 0.5,
            child: ListTile(
              leading: const Icon(Icons.payments_outlined),
              title: const Text('Default currency'),
              subtitle: const Text('CHF'),
              minVerticalPadding: 12,
              trailing: Chip(
                label: const Text('Soon'),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
