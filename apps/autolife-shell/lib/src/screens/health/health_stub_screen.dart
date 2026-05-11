import 'package:autolife_ui/autolife_ui.dart';
import 'package:flutter/material.dart';

import '../../widgets/biometric_gate.dart';

const healthStubModuleId = 'health.stub';

/// Phase 2.5 reference module: sensitive placeholder behind [BiometricGate].
class HealthStubScreen extends StatelessWidget {
  const HealthStubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AutoLifeAppBar(title: const Text('Health (demo)')),
      body: BiometricGate(
        moduleId: healthStubModuleId,
        localizedReason: 'Confirm your identity to open Health (demo).',
        child: Padding(
          padding: const EdgeInsets.all(AutoLifeSpacing.md),
          child: AutoLifeSurfaceCard(
            child: Padding(
              padding: const EdgeInsets.all(AutoLifeSpacing.md),
              child: Text(
                'Auto Health lands in Phase 3.6; this screen exists to prove the '
                'Phase 2.5 biometric gate contract end-to-end.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
