import 'integration_connector.dart';

/// Registers connector implementations by stable [IntegrationConnector.connectorId].
class ConnectorRegistry {
  final Map<String, IntegrationConnector> _connectors = {};

  /// Sorted connector ids for deterministic UI lists.
  List<String> get connectorIds => _connectors.keys.toList()..sort();

  void register(IntegrationConnector connector) {
    final id = connector.connectorId;
    if (_connectors.containsKey(id)) {
      throw StateError('Duplicate connector id: $id');
    }
    _connectors[id] = connector;
  }

  IntegrationConnector? operator [](String connectorId) =>
      _connectors[connectorId];

  IntegrationConnector require(String connectorId) {
    final c = _connectors[connectorId];
    if (c == null) {
      throw StateError('Unknown connector id: $connectorId');
    }
    return c;
  }
}
