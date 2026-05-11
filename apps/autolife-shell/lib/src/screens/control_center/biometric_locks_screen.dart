import 'package:autolife_core/autolife_core.dart';
import 'package:autolife_shell/src/screens/health/health_stub_screen.dart';
import 'package:autolife_ui/autolife_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/privacy_providers.dart';

/// Control-center screen to persist per-module biometric locks.
class BiometricLocksScreen extends ConsumerStatefulWidget {
  const BiometricLocksScreen({super.key});

  @override
  ConsumerState<BiometricLocksScreen> createState() =>
      _BiometricLocksScreenState();
}

class _BiometricLocksScreenState extends ConsumerState<BiometricLocksScreen> {
  static const _modules = <({String id, String title, String subtitle})>[
    (
      id: healthStubModuleId,
      title: 'Health (demo)',
      subtitle: 'Reference module used to validate the biometric gate.',
    ),
  ];

  final _enabled = <String, bool>{};
  var _ready = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final svc = ref.read(biometricLockServiceProvider);
    for (final m in _modules) {
      final r = await svc.isLockEnabled(m.id);
      _enabled[m.id] = r.when(success: (v) => v, failure: (_) => false);
    }
    if (mounted) setState(() => _ready = true);
  }

  @override
  Widget build(BuildContext context) {
    final svc = ref.watch(biometricLockServiceProvider);
    return Scaffold(
      appBar: AutoLifeAppBar(title: const Text('Biometric locks')),
      body: !_ready
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(AutoLifeSpacing.md),
              itemCount: _modules.length,
              separatorBuilder: (_, index) =>
                  const SizedBox(height: AutoLifeSpacing.sm),
              itemBuilder: (context, i) {
                final m = _modules[i];
                final on = _enabled[m.id] ?? false;
                return SwitchListTile(
                  title: Text(m.title),
                  subtitle: Text(m.subtitle),
                  value: on,
                  onChanged: (v) async {
                    await svc.setLockEnabled(m.id, v);
                    if (mounted) {
                      setState(() => _enabled[m.id] = v);
                    }
                  },
                );
              },
            ),
    );
  }
}
