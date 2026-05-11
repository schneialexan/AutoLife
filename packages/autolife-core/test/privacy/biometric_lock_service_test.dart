import 'package:autolife_core/autolife_core.dart';
import 'package:flutter_test/flutter_test.dart';

class _MemStore implements SecurePrefsStore {
  final _m = <String, String>{};

  @override
  Future<String?> read(String key) async => _m[key];

  @override
  Future<void> write(String key, String value) async {
    _m[key] = value;
  }
}

class _FakeAuth implements LocalAuthFacade {
  _FakeAuth({required this.supported, required this.outcomes});

  final bool supported;
  final List<bool> outcomes;
  var _i = 0;

  @override
  Future<bool> authenticate({
    required String localizedReason,
    bool biometricOnly = false,
  }) async {
    if (_i >= outcomes.length) return false;
    final o = outcomes[_i];
    _i++;
    return o;
  }

  @override
  Future<bool> canCheckBiometrics() async => true;

  @override
  Future<bool> isDeviceSupported() async => supported;
}

void main() {
  test('lock is no-op when module not enabled', () async {
    final svc = BiometricLockService(
      prefs: _MemStore(),
      localAuth: _FakeAuth(supported: true, outcomes: const []),
    );
    final r = await svc.lock('m1');
    expect(r.map(success: (_) => true, failure: (_) => false), isTrue);
  });

  test('lock prompts and succeeds', () async {
    final svc = BiometricLockService(
      prefs: _MemStore(),
      localAuth: _FakeAuth(supported: true, outcomes: const [true]),
    );
    await svc.setLockEnabled('m1', true);
    final r = await svc.lock('m1');
    expect(r.map(success: (_) => true, failure: (_) => false), isTrue);
  });

  test('lock failure emits telemetry', () async {
    PrivacyTelemetryEvent? seen;
    final svc = BiometricLockService(
      prefs: _MemStore(),
      localAuth: _FakeAuth(supported: true, outcomes: const [false]),
      onTelemetry: (e) => seen = e,
    );
    await svc.setLockEnabled('m1', true);
    final r = await svc.lock('m1');
    expect(r.map(success: (_) => false, failure: (_) => true), isTrue);
    expect(seen, isA<PrivacyLockFailed>());
    expect((seen! as PrivacyLockFailed).moduleId, 'm1');
  });

  test('unsupported device fails closed', () async {
    final svc = BiometricLockService(
      prefs: _MemStore(),
      localAuth: _FakeAuth(supported: false, outcomes: const []),
    );
    await svc.setLockEnabled('m1', true);
    final r = await svc.lock('m1');
    expect(r.map(success: (_) => false, failure: (_) => true), isTrue);
  });
}
