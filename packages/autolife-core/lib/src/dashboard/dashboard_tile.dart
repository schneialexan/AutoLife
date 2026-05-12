/// One tile within a [DashboardRow] (phase 3.1.5 viewport-flex model).
class DashboardTile {
  const DashboardTile({
    required this.widgetId,
    required this.widthUnits,
    this.spanRows = 1,
    this.minHeightPx,
  });

  final String widgetId;

  /// Horizontal flex share; sum of tiles in a row should be 6.
  final int widthUnits;

  /// Reserved for multi-row spanning (default 1). Host may treat as 1 until fully wired.
  final int spanRows;

  /// Soft minimum height in logical pixels for scroll-fallback heuristics.
  final int? minHeightPx;

  Map<String, dynamic> toJson() => {
        'widget_id': widgetId,
        'width_units': widthUnits,
        if (spanRows != 1) 'span_rows': spanRows,
        if (minHeightPx != null) 'min_height_px': minHeightPx,
      };

  factory DashboardTile.fromJson(Map<String, dynamic> json) {
    final id = json['widget_id'] as String? ?? json['widgetId'] as String?;
    if (id == null) {
      throw FormatException('DashboardTile missing widget_id: $json');
    }
    final w = json['width_units'] as int? ?? json['widthUnits'] as int? ?? 6;
    final span = json['span_rows'] as int? ?? json['spanRows'] as int? ?? 1;
    final minH = json['min_height_px'] as int? ?? json['minHeightPx'] as int?;
    return DashboardTile(
      widgetId: id,
      widthUnits: w.clamp(1, 6),
      spanRows: span.clamp(1, 6),
      minHeightPx: minH,
    );
  }

  DashboardTile copyWith({
    String? widgetId,
    int? widthUnits,
    int? spanRows,
    int? minHeightPx,
  }) {
    return DashboardTile(
      widgetId: widgetId ?? this.widgetId,
      widthUnits: widthUnits ?? this.widthUnits,
      spanRows: spanRows ?? this.spanRows,
      minHeightPx: minHeightPx ?? this.minHeightPx,
    );
  }
}
