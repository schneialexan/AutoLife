import 'package:autolife_core/autolife_core.dart';
import 'package:autolife_ui/autolife_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_provider.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key, required this.redirectUri});

  final String redirectUri;

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pw = TextEditingController();
  bool _busy = false;
  String? _banner;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _pw.dispose();
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
        .signUpWithPassword(
          email: _email.text.trim(),
          password: _pw.text,
          displayName: _name.text.trim(),
          emailRedirectTo: widget.redirectUri,
        );
    setState(() => _busy = false);
    res.when<void>(
      success: (_) {
        final phase = ref.read(authServiceProvider).currentState.phase;
        if (phase == AutoLifeAuthPhase.authenticated ||
            phase == AutoLifeAuthPhase.hydrating) {
          ScaffoldMessenger.maybeOf(context)?.showSnackBar(
            const SnackBar(content: Text('Account ready — welcome!')),
          );
          Navigator.maybeOf(context)?.pop();
        } else {
          ScaffoldMessenger.maybeOf(context)?.showSnackBar(
            const SnackBar(
              content: Text(
                'Signup complete — confirm the email Supabase sends before '
                'your first login when confirmations are enabled.',
              ),
            ),
          );
          Navigator.maybeOf(context)?.pop();
        }
      },
      failure: (fail) =>
          setState(() => _banner = fail.message ?? 'Could not register.'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AutoLifeSpacing.lg),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                Text(
                  'Create your AutoLife account',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AutoLifeSpacing.md),
                if (_banner != null) AutoLifeErrorBanner(message: _banner!),
                if (_banner != null) const SizedBox(height: AutoLifeSpacing.sm),
                AutoLifeTextField(
                  controller: _name,
                  labelText: 'Display name (optional)',
                  key: const Key('auth_display_name_field'),
                ),
                const SizedBox(height: AutoLifeSpacing.sm),
                AutoLifeTextField(
                  controller: _email,
                  labelText: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  key: const Key('auth_sign_up_email_field'),
                  validator: (v) =>
                      v == null || v.trim().length < 3 ? 'Enter email.' : null,
                ),
                const SizedBox(height: AutoLifeSpacing.sm),
                AutoLifeTextField(
                  controller: _pw,
                  labelText: 'Password',
                  obscureText: true,
                  key: const Key('auth_sign_up_password_field'),
                  validator: (v) => v == null || v.length < 8
                      ? 'Use at least 8 characters.'
                      : null,
                ),
                const SizedBox(height: AutoLifeSpacing.lg),
                SizedBox(
                  key: const Key('auth_sign_up_button'),
                  width: double.infinity,
                  child: AutoLifeButton(
                    label: 'Sign up',
                    onPressed: _busy ? null : _submit,
                    icon: Icons.person_add_alt_1_outlined,
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
