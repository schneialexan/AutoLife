import 'dart:async';

import 'package:autolife_ui/autolife_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/omnibar_search_service.dart';

/// Universal omnibar backed by [OmnibarSearchService] (phase 3.1 local scan).
class DashboardOmnibar extends ConsumerStatefulWidget {
  const DashboardOmnibar({super.key});

  @override
  ConsumerState<DashboardOmnibar> createState() => _DashboardOmnibarState();
}

class _DashboardOmnibarState extends ConsumerState<DashboardOmnibar> {
  final _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _runSearch(String raw) async {
    final svc = ref.read(omnibarSearchServiceProvider);
    final results = await svc.search(raw);
    if (!mounted) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (results.isEmpty) {
      messenger?.clearSnackBars();
      return;
    }
    messenger?.showSnackBar(
      SnackBar(
        content: Text(
          '${results.length} hits · top: ${results.first.title}',
          key: const Key('omnibar_snackbar'),
        ),
      ),
    );
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    final trimmed = value.trim();
    if (trimmed.length < 2) return;
    _debounce = Timer(const Duration(milliseconds: 150), () {
      unawaited(_runSearch(trimmed));
    });
  }

  @override
  Widget build(BuildContext context) {
    return AutoLifeOmnibar(
      key: const Key('dashboard_omnibar'),
      controller: _controller,
      onSubmitted: _runSearch,
      onChanged: _onChanged,
    );
  }
}
