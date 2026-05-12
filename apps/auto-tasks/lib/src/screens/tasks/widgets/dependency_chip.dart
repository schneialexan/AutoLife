import 'package:flutter/material.dart';

class DependencyChip extends StatelessWidget {
  const DependencyChip({super.key});

  @override
  Widget build(BuildContext context) {
    return const Chip(
      avatar: Icon(Icons.link, size: 16),
      label: Text('Blocked'),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
