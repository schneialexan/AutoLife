import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/sync_providers.dart';
import 'screens/vault/vault_screen.dart';

/// Root widget for the AutoAssets standalone app.
class AutoAssetsApp extends ConsumerWidget {
  const AutoAssetsApp({super.key});

  static const Color _seed = Color(0xFF4F46E5);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Registers the assets gateway with the sync coordinator on startup; a
    // no-op in local-only builds.
    ref.watch(assetsSyncBootstrapProvider);
    return MaterialApp(
      title: 'AutoAssets',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: _seed),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seed,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const VaultScreen(),
    );
  }
}
