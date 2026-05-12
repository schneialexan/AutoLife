/// Dashboard tile span sizes on the shell grid (phase 3.1).
///
/// Phone uses 2 columns; tablet uses 4. Mapping uses cell counts on that grid.
enum DashboardSize {
  /// One grid cell (square-ish tile height unit).
  s,

  /// Two columns wide, one row tall (when grid has ≥2 columns).
  m,

  /// Two columns × two row units (when grid has ≥2 columns).
  l,

  /// Full row width (all columns).
  xl,
}
