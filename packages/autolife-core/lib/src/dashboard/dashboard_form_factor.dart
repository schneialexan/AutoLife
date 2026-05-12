import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/widgets.dart';

/// Runtime dashboard form factors (phase 3.1.5 preview + layout defaults).
enum DashboardFormFactor {
  mobile,
  tablet,
  desktop,
  web;

  static const double nativeTabletWidthBreakpoint = 600;

  /// Web always maps to [web]. Desktop OS maps to [desktop]. Otherwise width
  /// threshold splits mobile vs tablet.
  static DashboardFormFactor fromRuntime(MediaQueryData mq) {
    if (kIsWeb) return DashboardFormFactor.web;
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      return DashboardFormFactor.desktop;
    }
    final w = mq.size.width;
    return w >= nativeTabletWidthBreakpoint
        ? DashboardFormFactor.tablet
        : DashboardFormFactor.mobile;
  }
}
