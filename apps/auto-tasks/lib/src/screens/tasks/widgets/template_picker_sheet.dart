import 'package:flutter/material.dart';

Future<void> showTemplatePickerSheet(BuildContext context) async {
  await showModalBottomSheet<void>(
    context: context,
    builder: (ctx) => const SafeArea(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Text('Templates — apply via TemplateEngine (phase 3.3).'),
      ),
    ),
  );
}
