import 'dart:async';

import 'package:autolife_core/autolife_core.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const _supabaseUrl = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
const _supabaseAnonKey = String.fromEnvironment(
  'SUPABASE_ANON_KEY',
  defaultValue: '',
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (_supabaseUrl.isNotEmpty && _supabaseAnonKey.isNotEmpty) {
    await SupabaseClientProvider.initialize(
      url: _supabaseUrl,
      anonKey: _supabaseAnonKey,
    );
  }

  runApp(const AutoLifeShellApp());
}

class AutoLifeShellApp extends StatelessWidget {
  const AutoLifeShellApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AutoLife Shell',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const _RootGate(),
    );
  }
}

class _RootGate extends StatefulWidget {
  const _RootGate();

  @override
  State<_RootGate> createState() => _RootGateState();
}

class _RootGateState extends State<_RootGate> {
  StreamSubscription<AuthState>? _sub;

  bool get _isSupabaseConfigured =>
      _supabaseUrl.isNotEmpty && _supabaseAnonKey.isNotEmpty;

  @override
  void initState() {
    super.initState();

    if (_isSupabaseConfigured) {
      _sub = Supabase.instance.client.auth.onAuthStateChange.listen((_) {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isSupabaseConfigured) {
      return const _MissingSupabaseConfigScreen();
    }

    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) {
      return const _EmailAuthScreen();
    }

    return const _BootstrapGate();
  }
}

class _MissingSupabaseConfigScreen extends StatelessWidget {
  const _MissingSupabaseConfigScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Missing Supabase config',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Run the shell with:\n\n'
                  'flutter run -d chrome '
                  '--dart-define=SUPABASE_URL=... '
                  '--dart-define=SUPABASE_ANON_KEY=...\n',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmailAuthScreen extends StatefulWidget {
  const _EmailAuthScreen();

  @override
  State<_EmailAuthScreen> createState() => _EmailAuthScreenState();
}

class _EmailAuthScreenState extends State<_EmailAuthScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _isSignUp = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      final client = Supabase.instance.client;
      final email = _email.text.trim();
      final password = _password.text;

      if (email.isEmpty || password.isEmpty) {
        throw const FormatException('Email and password are required.');
      }

      if (_isSignUp) {
        await client.auth.signUp(email: email, password: password);
      } else {
        await client.auth.signInWithPassword(email: email, password: password);
      }
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } on FormatException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _isSignUp ? 'Create account' : 'Sign in',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _password,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password'),
                ),
                const SizedBox(height: 16),
                if (_error != null) ...[
                  Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                FilledButton(
                  onPressed: _busy ? null : _submit,
                  child: _busy
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(_isSignUp ? 'Sign up' : 'Sign in'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _busy
                      ? null
                      : () => setState(() => _isSignUp = !_isSignUp),
                  child: Text(
                    _isSignUp
                        ? 'Already have an account? Sign in'
                        : 'No account yet? Sign up',
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

class _BootstrapGate extends StatefulWidget {
  const _BootstrapGate();

  @override
  State<_BootstrapGate> createState() => _BootstrapGateState();
}

class _BootstrapGateState extends State<_BootstrapGate> {
  bool _ready = false;
  String? _status;
  int _attempt = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _poll();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _poll() async {
    _timer?.cancel();

    setState(() {
      _attempt += 1;
      _status = 'Attempt $_attempt';
    });

    try {
      final res = await Supabase.instance.client.functions.invoke('bootstrap');
      if (res.status != 200) {
        final err = (res.data is Map && (res.data as Map)['error'] != null)
            ? (res.data as Map)['error'].toString()
            : 'Bootstrap failed (status ${res.status})';
        throw Exception(err);
      }

      final data = res.data;
      final isReady = data is Map && data['ready'] == true;
      if (isReady) {
        setState(() => _ready = true);
        return;
      }

      setState(() => _status = 'Not ready yet. Retrying…');
    } catch (e) {
      setState(() => _status = e.toString());
    }

    final delay = Duration(seconds: (_attempt < 5) ? 1 : 2);
    _timer = Timer(delay, _poll);
  }

  @override
  Widget build(BuildContext context) {
    if (_ready) return const _ReadyScreen();

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  'Setting up your workspace…',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(_status ?? '', textAlign: TextAlign.center),
                const SizedBox(height: 16),
                TextButton(onPressed: _poll, child: const Text('Retry now')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ReadyScreen extends StatelessWidget {
  const _ReadyScreen();

  Future<void> _signOut() async {
    await Supabase.instance.client.auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AutoLife'),
        actions: [
          TextButton(onPressed: _signOut, child: const Text('Sign out')),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Ready', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 12),
                Text('Signed in as: ${user?.email ?? user?.id ?? 'unknown'}'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
