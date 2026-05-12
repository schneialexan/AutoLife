import 'package:flutter/material.dart';

/// Header row: weather glyph + red stress dot when forecast crosses [stressThreshold].
class WeatherOverlayHeader extends StatelessWidget {
  const WeatherOverlayHeader({
    super.key,
    required this.day,
    required this.precipitationProbability,
    required this.stressThreshold,
    this.previousPrecipitationProbability,
  });

  final DateTime day;
  final double precipitationProbability;
  final double stressThreshold;

  /// When the delta exceeds [stressThreshold], show alert dot on day.
  final double? previousPrecipitationProbability;

  bool get _stress {
    final prev = previousPrecipitationProbability;
    if (prev == null) return precipitationProbability >= stressThreshold;
    return (precipitationProbability - prev).abs() >= stressThreshold;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.wb_cloudy_outlined, size: 20),
        const SizedBox(width: 6),
        Text(
          '${(precipitationProbability * 100).round()}% precip',
          style: Theme.of(context).textTheme.labelMedium,
        ),
        if (_stress) ...[
          const SizedBox(width: 8),
          const Icon(Icons.circle, size: 10, color: Color(0xFFD32F2F)),
        ],
      ],
    );
  }
}

/// Compact icon for month cells.
class WeatherOverlayCompact extends StatelessWidget {
  const WeatherOverlayCompact({
    super.key,
    required this.precipitationProbability,
    required this.stressThreshold,
  });

  final double precipitationProbability;
  final double stressThreshold;

  @override
  Widget build(BuildContext context) {
    final stress = precipitationProbability >= stressThreshold;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.grain,
          size: 14,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        if (stress)
          const Padding(
            padding: EdgeInsets.only(left: 2),
            child: Icon(Icons.circle, size: 7, color: Color(0xFFD32F2F)),
          ),
      ],
    );
  }
}
