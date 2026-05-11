/// Layout spacing scale (logical pixels). Use these multiples for padding,
/// gaps, and inset — never duplicate raw numbers in widgets.
abstract final class AutoLifeSpacing {
  AutoLifeSpacing._();

  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  /// Standard horizontal padding for screen edges and dialogs.
  static const double screenHorizontal = md;

  /// Standard vertical gap between major sections.
  static const double sectionGap = lg;
}
