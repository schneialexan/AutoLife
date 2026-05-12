import 'dashboard_tile.dart';

/// One horizontal band in the dashboard; height flexes with [heightUnits].
class DashboardRow {
  const DashboardRow({
    required this.heightUnits,
    required this.tiles,
    this.minHeightPx,
  }) : assert(heightUnits >= 1 && heightUnits <= 6);

  final int heightUnits;
  final List<DashboardTile> tiles;

  /// Optional row-level minimum height in logical pixels.
  final int? minHeightPx;

  int get rowMinHeightPx =>
      minHeightPx ??
      tiles
          .map((t) => t.minHeightPx ?? 0)
          .fold<int>(0, (a, b) => a > b ? a : b);

  Map<String, dynamic> toJson() => {
        'height_units': heightUnits,
        'tiles': tiles.map((t) => t.toJson()).toList(),
        if (minHeightPx != null) 'min_height_px': minHeightPx,
      };

  factory DashboardRow.fromJson(Map<String, dynamic> json) {
    final h = json['height_units'] as int? ?? json['heightUnits'] as int? ?? 1;
    final tilesRaw = json['tiles'] as List<dynamic>? ?? const [];
    final tiles = tilesRaw
        .map((e) => DashboardTile.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    final minH = json['min_height_px'] as int? ?? json['minHeightPx'] as int?;
    return DashboardRow(
      heightUnits: h.clamp(1, 6),
      tiles: tiles,
      minHeightPx: minH,
    );
  }

  DashboardRow copyWith({
    int? heightUnits,
    List<DashboardTile>? tiles,
    int? minHeightPx,
  }) {
    return DashboardRow(
      heightUnits: heightUnits ?? this.heightUnits,
      tiles: tiles ?? this.tiles,
      minHeightPx: minHeightPx ?? this.minHeightPx,
    );
  }
}
