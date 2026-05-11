import '../common/failure.dart';
import '../common/result.dart';
import '../common/tenant.dart';
import 'integration_connector.dart';

/// Reference connector used by phase 1.8 smoke tests and Dart harnesses.
class MockConnector implements IntegrationConnector {
  var connected = false;

  @override
  String get connectorId => 'mock';

  @override
  IntegrationConnectorDirection get directions =>
      IntegrationConnectorDirection.twoWay;

  @override
  Future<Result<void>> connect({Tenant? tenant}) async {
    connected = true;
    return const Result.success(null);
  }

  @override
  Future<Result<void>> disconnect() async {
    connected = false;
    return const Result.success(null);
  }

  @override
  Future<Result<void>> healthcheck({Tenant? tenant}) async {
    if (!connected) {
      return Result.failure(
        Failure(code: 'mock_not_connected', message: 'connect first'),
      );
    }
    return const Result.success(null);
  }

  @override
  Future<Result<Map<String, dynamic>>> pullChanges({Tenant? tenant}) async {
    if (!connected) {
      return Result.failure(
        Failure(code: 'mock_not_connected', message: 'connect first'),
      );
    }
    return Result.success({
      'items': [
        {'id': 'mock-1', 'title': 'Mock inbound item'},
      ],
      'cursor': 'mock-cursor',
    });
  }

  @override
  Future<Result<void>> pushChanges({
    Tenant? tenant,
    required Map<String, dynamic> payload,
  }) async {
    if (!connected) {
      return Result.failure(
        Failure(code: 'mock_not_connected', message: 'connect first'),
      );
    }
    return const Result.success(null);
  }

  @override
  Future<Result<void>> refresh({Tenant? tenant}) async {
    if (!connected) {
      return Result.failure(
        Failure(code: 'mock_not_connected', message: 'connect first'),
      );
    }
    return const Result.success(null);
  }
}
