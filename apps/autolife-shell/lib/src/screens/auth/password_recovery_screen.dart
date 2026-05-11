import 'package:autolife_core/autolife_core.dart';
import 'package:autolife_ui/autolife_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_provider.dart';

class PasswordRecoveryScreen extends ConsumerStatefulWidget {
  const PasswordRecoveryScreen({super.key});

  @override
  ConsumerState<PasswordRecoveryScreen> createState() =>
      _PasswordRecoveryScreenState();
}

class _PasswordRecoveryScreenState
    extends ConsumerState<PasswordRecoveryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _p1 = TextEditingController();
  final _p2 = TextEditingController();
  bool _busy = false;
  String? _banner;

  @override
  void dispose() {
    _p1.dispose();
    _p2.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _busy = true;
      _banner = null;
    });

    final res = await ref.read(authServiceProvider).updatePassword(_p1.text);
    setState(() => _busy = false);

    res.when<void>(
      success: (_) {
        ScaffoldMessenger.maybeOf(
          context,
        )?.showSnackBar(const SnackBar(content: Text('Password updated.')));
      },
      failure: (fail) =>
          setState(() => _banner = fail.message ?? 'Could not reset password.'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose a new password')),
      body: Padding(
        padding: const EdgeInsets.all(AutoLifeSpacing.lg),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Your reset link authenticated this device temporarily. Pick a '
                  'new password below.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AutoLifeSpacing.md),
                if (_banner != null) ...[
                  AutoLifeErrorBanner(message: _banner!),
                  const SizedBox(height: AutoLifeSpacing.sm),
                ],
                AutoLifeTextField(
                  controller: _p1,
                  labelText: 'New password',
                  obscureText: true,
                  validator: (v) {
                    if ((v ?? '').length < 6) {
                      return 'Use at least 6 characters.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AutoLifeSpacing.sm),
                AutoLifeTextField(
                  controller: _p2,
                  labelText: 'Confirm password',
                  obscureText: true,
                  validator: (v) {
                    if (v != _p1.text) return 'Passwords do not match.';
                    return null;
                  },
                ),
                const SizedBox(height: AutoLifeSpacing.lg),
                SizedBox(
                  width: double.infinity,
                  child: AutoLifeButton(
                    label: 'Save password',
                    onPressed: _busy ? null : _submit,
                    icon: Icons.check,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
