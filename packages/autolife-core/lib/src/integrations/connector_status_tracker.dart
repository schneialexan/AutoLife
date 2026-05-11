import 'package:flutter/foundation.dart';

import 'connector_status.dart';

/// Mutable connector status map for shell widgets.
class ConnectorStatusTracker extends ChangeNotifier {
  final Map<String, ConnectorStatus> _byId = {};

  Map<String, ConnectorStatus> get snapshot => Map.unmodifiable(_byId);

  void setStatus(String connectorId, ConnectorStatus status) {
    _byId[connectorId] = status;
    notifyListeners();
  }

  void remove(String connectorId) {
    _byId.remove(connectorId);
    notifyListeners();
  }
}
