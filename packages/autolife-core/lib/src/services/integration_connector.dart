import '../common/result.dart';
import '../common/tenant.dart';

/// Shape for outbound integrations (Coop, email, …). Credential lifecycle and
/// OAuth live in phase 1.7 gateway.
abstract class IntegrationConnector {
  String get integrationId;

  Future<Result<void>> ensureConnected({Tenant? tenant});

  Future<Result<void>> disconnect();
}
