/// Single omnibar hit across modules (phase 3.1).
class OmnibarSearchResult {
  const OmnibarSearchResult({
    required this.moduleId,
    required this.title,
    required this.subtitle,
    required this.entityId,
    this.rank = 0,
  });

  final String moduleId;
  final String title;
  final String subtitle;

  /// Opaque id for navigation / dedupe.
  final String entityId;

  /// Lower is better when merging lists (optional heuristic score).
  final double rank;
}
