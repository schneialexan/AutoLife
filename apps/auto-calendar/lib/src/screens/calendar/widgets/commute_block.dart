import 'package:flutter/material.dart';

/// Gray travel row shown before/around located events (integration gateway ETA in production).
class CommuteBlockPreview extends StatelessWidget {
  const CommuteBlockPreview({super.key, required this.travelMinutes});

  final int travelMinutes;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade100,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(
            Icons.directions_car_filled_outlined,
            size: 20,
            color: Colors.blueGrey.shade700,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Travel block · ~ $travelMinutes min (Maps ETA)',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Colors.blueGrey.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
