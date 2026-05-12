import 'dart:io';

import 'package:autolife_core/autolife_core.dart';
import 'package:autolife_shell/src/providers/dashboard_registry_provider.dart';
import 'package:autolife_shell/src/registration/dashboard_registration.dart';
import 'package:autolife_shell/src/screens/home/dashboard_host.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Goldens for dashboard presentation + edit chrome (phase 3.1.5.1).
///
/// `flutter test test/visual_dashboard_goldens_test.dart --dart-define=RUN_SHELL_GOLDENS=true --update-goldens`
void main() {
  final enabled = Platform.environment['RUN_SHELL_GOLDENS'] == 'true';

  const scope = DashboardScope(
    formFactor: DashboardFormFactor.mobile,
    adaptive: DashboardAdaptiveMode.anyTime,
  );

  Future<void> pumpLayout(
    WidgetTester tester,
    DashboardLayout doc, {
    DashboardEditChrome? chrome,
  }) async {
    final reg = DashboardWidgetRegistry();
    registerShellDashboardWidgets(reg);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dashboardWidgetRegistryProvider.overrideWithValue(reg),
        ],
        child: MaterialApp(
          home: RepaintBoundary(
            child: SizedBox(
              width: 360,
              height: 520,
              child: DashboardHost(
                document: doc,
                scope: scope,
                editModeOptions: chrome,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('golden autoFit', (tester) async {
    await pumpLayout(
      tester,
      DashboardLayout(
        schemaVersion: 2,
        base: kDefaultDashboardLayouts[DashboardFormFactor.mobile]!.base,
      ),
    );
    await expectLater(
      find.byType(RepaintBoundary),
      matchesGoldenFile('goldens/dashboard_mode_autofit.png'),
    );
  }, skip: !enabled);

  testWidgets('golden scrollVertical', (tester) async {
    await pumpLayout(
      tester,
      DashboardLayout(
        schemaVersion: 2,
        base: kDefaultDashboardLayouts[DashboardFormFactor.mobile]!.base,
        basePresentation: const DashboardPresentation(
          mode: DashboardOverflowMode.scrollVertical,
        ),
      ),
    );
    await expectLater(
      find.byType(RepaintBoundary),
      matchesGoldenFile('goldens/dashboard_mode_scroll_vertical.png'),
    );
  }, skip: !enabled);

  testWidgets('golden scrollSnap', (tester) async {
    await pumpLayout(
      tester,
      DashboardLayout(
        schemaVersion: 2,
        base: kDefaultDashboardLayouts[DashboardFormFactor.mobile]!.base,
        basePresentation: const DashboardPresentation(
          mode: DashboardOverflowMode.scrollSnap,
        ),
      ),
    );
    await expectLater(
      find.byType(RepaintBoundary),
      matchesGoldenFile('goldens/dashboard_mode_scroll_snap.png'),
    );
  }, skip: !enabled);

  testWidgets('golden boards', (tester) async {
    await pumpLayout(
      tester,
      DashboardLayout(
        schemaVersion: 2,
        base: kDefaultDashboardLayouts[DashboardFormFactor.mobile]!.base,
        basePresentation: const DashboardPresentation(
          mode: DashboardOverflowMode.boards,
          boardBreaks: [1],
        ),
      ),
    );
    await expectLater(
      find.byType(RepaintBoundary),
      matchesGoldenFile('goldens/dashboard_mode_boards.png'),
    );
  }, skip: !enabled);

  testWidgets('golden edit chrome', (tester) async {
    await pumpLayout(
      tester,
      DashboardLayout(
        schemaVersion: 2,
        base: kDefaultDashboardLayouts[DashboardFormFactor.mobile]!.base,
      ),
      chrome: DashboardEditChrome(
        isEditing: true,
        onRowReorder: _noopReorder,
        onOpenTileResizePopover: _noop2,
        onOpenRowResizePopover: _noop1,
      ),
    );
    await expectLater(
      find.byType(RepaintBoundary),
      matchesGoldenFile('goldens/dashboard_edit_chrome.png'),
    );
  }, skip: !enabled);
}

void _noopReorder(int a, int b) {}

void _noop1(int a) {}

void _noop2(int a, int b) {}
