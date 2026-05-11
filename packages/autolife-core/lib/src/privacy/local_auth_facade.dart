import 'package:local_auth/local_auth.dart';

/// Test seam around `local_auth`.
abstract class LocalAuthFacade {
  Future<bool> authenticate({
    required String localizedReason,
    bool biometricOnly = false,
  });

  Future<bool> isDeviceSupported();

  Future<bool> canCheckBiometrics();
}

/// Default wrapper using [LocalAuthentication].
final class DefaultLocalAuthFacade implements LocalAuthFacade {
  DefaultLocalAuthFacade([LocalAuthentication? inner])
    : _inner = inner ?? LocalAuthentication();

  final LocalAuthentication _inner;

  @override
  Future<bool> canCheckBiometrics() => _inner.canCheckBiometrics;

  @override
  Future<bool> isDeviceSupported() => _inner.isDeviceSupported();

  @override
  Future<bool> authenticate({
    required String localizedReason,
    bool biometricOnly = false,
  }) async {
    return _inner.authenticate(
      localizedReason: localizedReason,
      options: AuthenticationOptions(
        biometricOnly: biometricOnly,
        stickyAuth: true,
        useErrorDialogs: true,
        sensitiveTransaction: true,
      ),
    );
  }
}
