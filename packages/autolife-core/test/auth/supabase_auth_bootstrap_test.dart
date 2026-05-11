import 'package:autolife_core/autolife_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AutoLifeSupabaseBootstrap wires PKCE storage + auth service', () {
    final memPkce = MemoryGotrueStorage();
    final memBlob = MemoryPersistentAuthSessionRepository();

    final wired = AutoLifeSupabaseBootstrap.createServices(
      supabaseUrl: 'http://127.0.0.1:54321',
      supabaseKey: 'anon-test-key',
      testPkce: memPkce,
      sessionRepo: memBlob,
    );

    expect(wired.client, isNotNull);
    expect(wired.auth, isA<SupabaseAuthService>());
  });
}
