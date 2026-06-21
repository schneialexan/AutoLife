/// Supabase connection config, supplied at build time via `--dart-define`:
///
/// ```sh
/// flutter run \
///   --dart-define=SUPABASE_URL=https://xyz.supabase.co \
///   --dart-define=SUPABASE_ANON_KEY=eyJ...
/// ```
///
/// When unset, the app runs fully local-only (no network) — the standalone
/// offline guarantee is preserved. The service-role key is **never** compiled
/// into the client; it lives only in Edge Function secrets.
class SyncConfig {
  SyncConfig._();

  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
  );

  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
