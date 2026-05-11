/// Corner radii for surfaces, buttons, and fields (logical pixels).
abstract final class AutoLifeRadii {
  AutoLifeRadii._();

  static const double xs = 6;
  static const double sm = 10;
  static const double md = 14;
  static const double lg = 18;
  static const double xl = 24;

  /// Cards and sheets.
  static const double card = md;

  /// Omnibar and filled inputs.
  static const double field = lg;

  /// Pill-shaped chips and badges.
  static const double pill = 999;
}
