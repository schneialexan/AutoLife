import 'package:autolife_core/autolife_core.dart';
import 'package:flutter/material.dart';

/// Fixed-size preview chrome for edit mode (phase 3.1.5).
class DevicePreviewFrame extends StatelessWidget {
  const DevicePreviewFrame({
    super.key,
    required this.formFactor,
    required this.child,
    this.fit = true,
  });

  final DashboardFormFactor formFactor;
  final Widget child;
  final bool fit;

  Size get _size {
    switch (formFactor) {
      case DashboardFormFactor.mobile:
        return const Size(360, 780);
      case DashboardFormFactor.tablet:
        return const Size(768, 1024);
      case DashboardFormFactor.desktop:
        return const Size(1280, 800);
      case DashboardFormFactor.web:
        return const Size(1440, 900);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sz = _size;
    final body = MediaQuery(
      data: MediaQuery.of(context).copyWith(size: sz),
      child: SizedBox(
        width: sz.width,
        height: sz.height,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: child,
        ),
      ),
    );

    if (!fit) return body;

    return Center(
      child: FittedBox(
        fit: BoxFit.contain,
        child: body,
      ),
    );
  }
}
