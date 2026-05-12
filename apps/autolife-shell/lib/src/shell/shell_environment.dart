import 'package:flutter/foundation.dart';

/// Shared compile-time env for the Flutter shell (`main.dart`, router, tests).
const shellSupabaseUrl = String.fromEnvironment('SUPABASE_URL', defaultValue: '');

const shellSupabaseAnonKey = String.fromEnvironment(
  'AUTOLIFE_SUPABASE_ANON_KEY',
  defaultValue: '',
);

const shellSupabaseServiceRoleKey = String.fromEnvironment(
  'SUPABASE_SERVICE_ROLE_KEY',
  defaultValue: '',
);

/// Phase 1.8 integration harness skips the UX auth chrome.
const shellSmokeIntegrationFlag = bool.fromEnvironment(
  'AUTOLIFE_SMOKE_INTEGRATION_TEST',
  defaultValue: false,
);

String get shellEffectiveSupabaseApiKey =>
    shellSupabaseAnonKey.isNotEmpty ? shellSupabaseAnonKey : shellSupabaseServiceRoleKey;

bool get shellSupabaseConfigured =>
    shellSupabaseUrl.isNotEmpty && shellEffectiveSupabaseApiKey.isNotEmpty;

bool get shellAuthChromeEnabled =>
    shellSupabaseConfigured && !shellSmokeIntegrationFlag;

/// Mirrors main.dart smoke surface gate for router destinations (phase 3.1).
bool shellSmokeSurfaceEnabled({required bool supabaseConfigured}) {
  return supabaseConfigured &&
      (shellSmokeIntegrationFlag || kDebugMode);
}
