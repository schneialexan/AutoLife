import 'package:flutter/material.dart';

import 'screens/vault/vault_screen.dart';

/// Root widget for the AutoAssets standalone app.
class AutoAssetsApp extends StatelessWidget {
  const AutoAssetsApp({super.key});

  static const Color _seed = Color(0xFF4F46E5);

  @override
  Widget build(BuildContext context) {
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
