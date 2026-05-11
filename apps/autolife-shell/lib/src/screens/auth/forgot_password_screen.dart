import 'package:autolife_core/autolife_core.dart';
import 'package:autolife_ui/autolife_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_provider.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key, required this.redirectUri});

  final String redirectUri;

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  bool _busy = false;
  String? _banner;
  bool _sent = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _busy = true;
      _banner = null;
    });

    final res = await ref
        .read(authServiceProvider)
        .requestPasswordResetEmail(
          email: _email.text.trim(),
          redirectTo: widget.redirectUri,
        );
    setState(() => _busy = false);

    res.when<void>(
      success: (_) => setState(() => _sent = true),
      failure: (fail) =>
          setState(() => _banner = fail.message ?? 'Reset request failed.'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot password')),
      body: Padding(
        padding: const EdgeInsets.all(AutoLifeSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_sent)
                Expanded(
                  child: Center(
                    child: AutoLifeSurfaceCard(
                      child: Padding(
                        padding: const EdgeInsets.all(AutoLifeSpacing.md),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.mark_email_read_outlined,
                              size: 48,
                            ),
                            const SizedBox(height: AutoLifeSpacing.sm),
                            Text(
                              'Check your inbox for reset instructions (Inbucket '
                              'when developing locally against supabase start).',
                              style: Theme.of(context).textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                            TextButton(
                              onPressed: () =>
                                  Navigator.maybeOf(context)?.pop(),
                              child: const Text('Back to sign in'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              else ...[
                Text(
                  'We will email an AutoLife-signed link pointing back to this '
                  'app using your OAuth redirect Uri.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AutoLifeSpacing.md),
                if (_banner != null) AutoLifeErrorBanner(message: _banner!),
                const SizedBox(height: AutoLifeSpacing.sm),
                AutoLifeTextField(
                  controller: _email,
                  labelText: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if ((v ?? '').trim().length < 3) return 'Enter email.';
                    return null;
                  },
                ),
                const Spacer(),
                AutoLifeButton(
                  label: 'Send reset email',
                  onPressed: _busy ? null : _submit,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
