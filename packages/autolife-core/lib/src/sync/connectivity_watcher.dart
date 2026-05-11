import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

/// Observes device connectivity and exposes an online boolean stream.
class ConnectivityWatcher {
  ConnectivityWatcher({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity(),
      _customStream = null,
      _initialOnline = null;

  /// Test / shell hooks that bypass the platform plugin.
  ///
  /// [isOnline] tracks the latest value from [stream] (and [initialOnline]
  /// until the first emission).
  ConnectivityWatcher.fake({
    required Stream<bool> stream,
    required bool initialOnline,
  }) : _connectivity = null,
       _customStream = stream,
       _initialOnline = null {
    _fakeLatestOnline = initialOnline;
  }

  final Connectivity? _connectivity;
  final Stream<bool>? _customStream;
  final bool? _initialOnline;
  bool? _fakeLatestOnline;
  Stream<bool>? _fakeWatchBroadcast;

  /// Emits `true` when any non-none transport is available.
  Stream<bool> watchOnline() {
    final custom = _customStream;
    if (custom != null) {
      _fakeWatchBroadcast ??= custom.map((online) {
        _fakeLatestOnline = online;
        return online;
      }).asBroadcastStream();
      return _fakeWatchBroadcast!;
    }
    return _connectivity!.onConnectivityChanged.map(_hasConnection);
  }

  Future<bool> isOnline() async {
    if (_customStream != null) return _fakeLatestOnline ?? false;
    final initial = _initialOnline;
    if (initial != null) return initial;
    final r = await _connectivity!.checkConnectivity();
    return _hasConnection(r);
  }

  bool _hasConnection(List<ConnectivityResult> results) {
    return results.any((r) => r != ConnectivityResult.none);
  }
}
