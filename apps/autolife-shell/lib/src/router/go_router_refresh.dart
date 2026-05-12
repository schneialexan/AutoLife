import 'dart:async';

import 'package:flutter/foundation.dart';

/// Notifies [GoRouter] when [stream] emits (phase 3.1 shell router).
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  StreamSubscription<dynamic>? _subscription;

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    super.dispose();
  }
}
