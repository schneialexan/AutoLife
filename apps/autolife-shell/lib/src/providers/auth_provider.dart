import 'package:autolife_core/autolife_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/noop_auth_shell.dart';

final _shellAuthFallback = ShellNoopAuthService();

/// Always bound (defaults to [ShellNoopAuthService] until Supabase smoke overrides swap it).
final authServiceProvider = Provider<AuthService>((_) => _shellAuthFallback);
