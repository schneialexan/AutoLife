import 'package:autolife_core/autolife_core.dart';
import 'package:autolife_shell/src/providers/dashboard_registry_provider.dart';
import 'package:autolife_shell/src/screens/home/dashboard_host.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const scope = DashboardScope(
    formFactor: DashboardFormFactor.mobile,
    adaptive: DashboardAdaptiveMode.anyTime,
  );

  DashboardLayout sampleLayout(DashboardOverflowMode mode) {
    return DashboardLayout(
      schemaVersion: 2,
      base: [
        DashboardRow(
          heightUnits: 1,
          tiles: [DashboardTile(widgetId: 'today_summary', widthUnits: 6)],
        ),
      ],
      basePresentation: DashboardPresentation(mode: mode),
    );
  }

  Future<void> pumpHost(
    WidgetTester tester,
    DashboardLayout doc, {
    Size size = const Size(360, 640),
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dashboardWidgetRegistryProvider.overrideWithValue(
            DashboardWidgetRegistry(),
          ),
        ],
        child: MaterialApp(
          home: Center(
            child: SizedBox(
              width: size.width,
              height: size.height,
              child: DashboardHost(document: doc, scope: scope),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('autoFit uses Column flex when room', (tester) async {
    await pumpHost(tester, sampleLayout(DashboardOverflowMode.autoFit));
    expect(find.byType(Column), findsWidgets);
  });

  testWidgets('scrollVertical uses SingleChildScrollView', (tester) async {
    await pumpHost(tester, sampleLayout(DashboardOverflowMode.scrollVertical));
    expect(find.byType(SingleChildScrollView), findsWidgets);
  });

  testWidgets('boards uses PageView', (tester) async {
    final doc = DashboardLayout(
      schemaVersion: 2,
      base: [
        DashboardRow(
          heightUnits: 1,
          tiles: [DashboardTile(widgetId: 'today_summary', widthUnits: 6)],
        ),
        DashboardRow(
          heightUnits: 1,
          tiles: [DashboardTile(widgetId: 'quick_actions', widthUnits: 6)],
        ),
      ],
      basePresentation: const DashboardPresentation(
        mode: DashboardOverflowMode.boards,
        boardBreaks: [1],
      ),
    );
    await pumpHost(tester, doc);
    expect(find.byType(PageView), findsOneWidget);
  });
}
