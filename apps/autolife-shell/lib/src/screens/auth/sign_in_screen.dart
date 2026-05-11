import 'package:autolife_core/autolife_core.dart';
import 'package:autolife_ui/autolife_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase/supabase.dart' hide AuthUser;
import 'package:url_launcher/url_launcher.dart';

import '../../providers/auth_provider.dart';
import 'forgot_password_screen.dart';
import 'sign_up_screen.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key, required this.redirectUri});

  final String redirectUri;

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _busy = false;
  String? _banner;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _oauth(OAuthProvider provider) async {
    setState(() => _banner = null);
    final svc = ref.read(authServiceProvider);
    final urlRes = await svc.oauthAuthorizeUrl(
      provider: provider,
      redirectTo: widget.redirectUri,
      skipBrowserRedirect: true,
    );
    urlRes.when<void>(
      success: (url) async {
        final parsed = Uri.parse(url);
        if (!await launchUrl(parsed, mode: LaunchMode.externalApplication)) {
          setState(
            () => _banner =
                'Could not open browser for ${provider.name} sign-in.',
          );
        }
      },
      failure: (fail) =>
          setState(() => _banner = fail.message ?? 'OAuth unavailable.'),
    );
  }

  Future<void> _signIn() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _busy = true;
      _banner = null;
    });
    final svc = ref.read(authServiceProvider);
    final result = await svc.signInWithPassword(
      email: _email.text,
      password: _password.text,
    );
    setState(() => _busy = false);
    result.when<void>(
      success: (_) {},
      failure: (f) => setState(() => _banner = f.message ?? 'Sign-in failed.'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AutoLifeSpacing.lg),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                Text(
                  'AutoLife',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: AutoLifeSpacing.sm),
                Text(
                  'Sign in to continue',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AutoLifeSpacing.md),
                if (_banner != null) ...[
                  AutoLifeErrorBanner(message: _banner!),
                  const SizedBox(height: AutoLifeSpacing.sm),
                ],
                AutoLifeTextField(
                  controller: _email,
                  labelText: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  key: const Key('auth_email_field'),
                  validator: (v) =>
                      v == null || v.trim().length < 3 ? 'Enter email.' : null,
                ),
                const SizedBox(height: AutoLifeSpacing.sm),
                AutoLifeTextField(
                  controller: _password,
                  labelText: 'Password',
                  obscureText: true,
                  autofillHints: const [AutofillHints.password],
                  textInputAction: TextInputAction.done,
                  key: const Key('auth_password_field'),
                  validator: (v) =>
                      v == null || v.length < 6 ? 'Enter your password.' : null,
                ),
                const SizedBox(height: AutoLifeSpacing.sm),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => ForgotPasswordScreen(
                            redirectUri: widget.redirectUri,
                          ),
                        ),
                      );
                    },
                    child: const Text('Forgot password'),
                  ),
                ),
                SizedBox(
                  key: const Key('auth_sign_in_button'),
                  width: double.infinity,
                  child: AutoLifeButton(
                    label: 'Sign in',
                    onPressed: _busy ? null : _signIn,
                    icon: Icons.login,
                  ),
                ),
                TextButton(
                  key: const Key('auth_nav_sign_up'),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            SignUpScreen(redirectUri: widget.redirectUri),
                      ),
                    );
                  },
                  child: const Text('Create an account'),
                ),
                const SizedBox(height: AutoLifeSpacing.lg),
                const Divider(),
                Row(
                  children: [
                    Expanded(
                      child: AutoLifeButton(
                        label: 'Google',
                        icon: Icons.g_mobiledata,
                        variant: AutoLifeButtonVariant.secondary,
                        onPressed: _busy
                            ? null
                            : () => _oauth(OAuthProvider.google),
                      ),
                    ),
                    const SizedBox(width: AutoLifeSpacing.sm),
                    Expanded(
                      child: AutoLifeButton(
                        label: 'Apple',
                        icon: Icons.apple,
                        variant: AutoLifeButtonVariant.secondary,
                        onPressed: _busy
                            ? null
                            : () => _oauth(OAuthProvider.apple),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
