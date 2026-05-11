import 'package:autolife_core/autolife_core.dart';
import 'package:autolife_ui/autolife_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/privacy_providers.dart';

/// Wraps [child] and runs [BiometricLockService.lock] when the module is enabled.
class BiometricGate extends ConsumerStatefulWidget {
  const BiometricGate({
    super.key,
    required this.moduleId,
    required this.child,
    this.localizedReason =
        'Authenticate with Face ID, Touch ID, or your device passcode.',
  });

  final String moduleId;
  final Widget child;
  final String localizedReason;

  @override
  ConsumerState<BiometricGate> createState() => _BiometricGateState();
}

class _BiometricGateState extends ConsumerState<BiometricGate> {
  var _phase = _GatePhase.loading;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _run());
  }

  Future<void> _run() async {
    final svc = ref.read(biometricLockServiceProvider);
    final res = await svc.lock(
      widget.moduleId,
      localizedReason: widget.localizedReason,
    );
    if (!mounted) return;
    res.when(
      success: (_) => setState(() => _phase = _GatePhase.unlocked),
      failure: (f) => setState(() {
        _phase = _GatePhase.blocked;
        _error = f.message ?? f.code;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return switch (_phase) {
      _GatePhase.loading => const Center(child: CircularProgressIndicator()),
      _GatePhase.unlocked => widget.child,
      _GatePhase.blocked => Center(
        child: Padding(
          padding: const EdgeInsets.all(AutoLifeSpacing.lg),
          child: AutoLifeSurfaceCard(
            child: Padding(
              padding: const EdgeInsets.all(AutoLifeSpacing.md),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Unlock required',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AutoLifeSpacing.sm),
                  Text(
                    _error ?? 'Authentication required.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AutoLifeSpacing.md),
                  FilledButton(
                    onPressed: () {
                      setState(() => _phase = _GatePhase.loading);
                      _run();
                    },
                    child: const Text('Try again'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    };
  }
}

enum _GatePhase { loading, unlocked, blocked }
