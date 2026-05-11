import 'dart:async';

import 'package:autolife_core/autolife_core.dart';

/// Integration test hook for toggling [ConnectivityWatcher] from tests.
class SmokeTestHarness {
  SmokeTestHarness._();

  static StreamController<bool>? _onlineController;
  static ConnectivityWatcher? connectivity;

  static void initIntegrationTest() {
    _onlineController?.close();
    _onlineController = StreamController<bool>.broadcast();
    connectivity = ConnectivityWatcher.fake(
      stream: _onlineController!.stream,
      initialOnline: true,
    );
  }

  static void setOnline(bool online) {
    _onlineController?.add(online);
  }

  static void disposeIntegrationTest() {
    _onlineController?.close();
    _onlineController = null;
    connectivity = null;
  }
}
