import 'package:autolife_ui/autolife_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpGolden(
    WidgetTester tester, {
    required ThemeData theme,
    required String label,
    required Widget child,
    Size surfaceSize = const Size(420, 220),
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme,
        home: ColoredBox(
          color: theme.colorScheme.surface,
          child: Align(
            alignment: Alignment.topCenter,
            child: RepaintBoundary(
              key: Key(label),
              child: SizedBox(
                width: surfaceSize.width,
                height: surfaceSize.height,
                child: Padding(
                  padding: const EdgeInsets.all(AutoLifeSpacing.md),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> expectGolden(WidgetTester tester, String keyName) async {
    await expectLater(
      find.byKey(Key(keyName)),
      matchesGoldenFile('goldens/$keyName.png'),
    );
  }

  group('design system goldens', () {
    const destinations = [
      NavigationDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home),
        label: 'Home',
      ),
      NavigationDestination(
        icon: Icon(Icons.calendar_month_outlined),
        selectedIcon: Icon(Icons.calendar_month),
        label: 'Cal',
      ),
    ];

    testWidgets('button_primary light', (tester) async {
      await pumpGolden(
        tester,
        theme: AutoLifeTheme.light(),
        label: 'btn_primary_light',
        child: Center(
          child: AutoLifeButton(label: 'Continue', onPressed: () {}),
        ),
        surfaceSize: const Size(420, 120),
      );
      await expectGolden(tester, 'btn_primary_light');
    }, tags: ['golden']);

    testWidgets('button_primary dark', (tester) async {
      await pumpGolden(
        tester,
        theme: AutoLifeTheme.dark(),
        label: 'btn_primary_dark',
        child: Center(
          child: AutoLifeButton(label: 'Continue', onPressed: () {}),
        ),
        surfaceSize: const Size(420, 120),
      );
      await expectGolden(tester, 'btn_primary_dark');
    }, tags: ['golden']);

    testWidgets('surface_card light', (tester) async {
      await pumpGolden(
        tester,
        theme: AutoLifeTheme.light(),
        label: 'card_light',
        child: AutoLifeSurfaceCard(
          child: Text(
            'Card title',
            style: AutoLifeTheme.light().textTheme.titleMedium,
          ),
        ),
      );
      await expectGolden(tester, 'card_light');
    }, tags: ['golden']);

    testWidgets('surface_card dark', (tester) async {
      await pumpGolden(
        tester,
        theme: AutoLifeTheme.dark(),
        label: 'card_dark',
        child: AutoLifeSurfaceCard(
          child: Text(
            'Card title',
            style: AutoLifeTheme.dark().textTheme.titleMedium,
          ),
        ),
      );
      await expectGolden(tester, 'card_dark');
    }, tags: ['golden']);

    testWidgets('app_bar light', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AutoLifeTheme.light(),
          home: RepaintBoundary(
            key: const Key('app_bar_light'),
            child: Scaffold(
              appBar: AutoLifeAppBar(title: const Text('AutoLife')),
              body: const SizedBox.expand(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await expectGolden(tester, 'app_bar_light');
    }, tags: ['golden']);

    testWidgets('app_bar dark', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AutoLifeTheme.dark(),
          home: RepaintBoundary(
            key: const Key('app_bar_dark'),
            child: Scaffold(
              appBar: AutoLifeAppBar(title: const Text('AutoLife')),
              body: const SizedBox.expand(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await expectGolden(tester, 'app_bar_dark');
    }, tags: ['golden']);

    testWidgets('bottom_nav_shell light', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AutoLifeTheme.light(),
          home: RepaintBoundary(
            key: const Key('shell_light'),
            child: SizedBox(
              width: 420,
              height: 360,
              child: AutoLifeBottomNavShell(
                destinations: destinations,
                selectedIndex: 0,
                onDestinationSelected: (_) {},
                body: const Center(child: Text('Home')),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await expectGolden(tester, 'shell_light');
    }, tags: ['golden']);

    testWidgets('bottom_nav_shell dark', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AutoLifeTheme.dark(),
          home: RepaintBoundary(
            key: const Key('shell_dark'),
            child: SizedBox(
              width: 420,
              height: 360,
              child: AutoLifeBottomNavShell(
                destinations: destinations,
                selectedIndex: 1,
                onDestinationSelected: (_) {},
                body: const Center(child: Text('Calendar')),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await expectGolden(tester, 'shell_dark');
    }, tags: ['golden']);

    testWidgets('omnibar light', (tester) async {
      await pumpGolden(
        tester,
        theme: AutoLifeTheme.light(),
        label: 'omnibar_light',
        child: Align(
          alignment: Alignment.topCenter,
          child: AutoLifeOmnibar(onSubmitted: _noop),
        ),
        surfaceSize: const Size(420, 100),
      );
      await expectGolden(tester, 'omnibar_light');
    }, tags: ['golden']);

    testWidgets('omnibar dark', (tester) async {
      await pumpGolden(
        tester,
        theme: AutoLifeTheme.dark(),
        label: 'omnibar_dark',
        child: Align(
          alignment: Alignment.topCenter,
          child: AutoLifeOmnibar(onSubmitted: _noop),
        ),
        surfaceSize: const Size(420, 100),
      );
      await expectGolden(tester, 'omnibar_dark');
    }, tags: ['golden']);

    testWidgets('member_avatar light', (tester) async {
      await pumpGolden(
        tester,
        theme: AutoLifeTheme.light(),
        label: 'avatar_light',
        child: const Center(
          child: AutoLifeMemberAvatar(
            memberId: 'id-zoe',
            displayName: 'Zoe Member',
          ),
        ),
        surfaceSize: const Size(200, 120),
      );
      await expectGolden(tester, 'avatar_light');
    }, tags: ['golden']);

    testWidgets('member_avatar dark', (tester) async {
      await pumpGolden(
        tester,
        theme: AutoLifeTheme.dark(),
        label: 'avatar_dark',
        child: const Center(
          child: AutoLifeMemberAvatar(
            memberId: 'id-zoe',
            displayName: 'Zoe Member',
          ),
        ),
        surfaceSize: const Size(200, 120),
      );
      await expectGolden(tester, 'avatar_dark');
    }, tags: ['golden']);

    testWidgets('member_badge light', (tester) async {
      await pumpGolden(
        tester,
        theme: AutoLifeTheme.light(),
        label: 'badge_light',
        child: const Center(
          child: AutoLifeMemberBadge(memberId: 'id-max', label: 'Max'),
        ),
        surfaceSize: const Size(240, 100),
      );
      await expectGolden(tester, 'badge_light');
    }, tags: ['golden']);

    testWidgets('member_badge dark', (tester) async {
      await pumpGolden(
        tester,
        theme: AutoLifeTheme.dark(),
        label: 'badge_dark',
        child: const Center(
          child: AutoLifeMemberBadge(memberId: 'id-max', label: 'Max'),
        ),
        surfaceSize: const Size(240, 100),
      );
      await expectGolden(tester, 'badge_dark');
    }, tags: ['golden']);

    testWidgets('empty_state light', (tester) async {
      await pumpGolden(
        tester,
        theme: AutoLifeTheme.light(),
        label: 'empty_light',
        child: AutoLifeEmptyState(
          title: 'Nothing here yet',
          message: 'Add an item to get started.',
          actionLabel: 'Create',
          onAction: () {},
        ),
        surfaceSize: const Size(420, 280),
      );
      await expectGolden(tester, 'empty_light');
    }, tags: ['golden']);

    testWidgets('empty_state dark', (tester) async {
      await pumpGolden(
        tester,
        theme: AutoLifeTheme.dark(),
        label: 'empty_dark',
        child: AutoLifeEmptyState(
          title: 'Nothing here yet',
          message: 'Add an item to get started.',
          actionLabel: 'Create',
          onAction: () {},
        ),
        surfaceSize: const Size(420, 280),
      );
      await expectGolden(tester, 'empty_dark');
    }, tags: ['golden']);

    testWidgets('skeleton light', (tester) async {
      await pumpGolden(
        tester,
        theme: AutoLifeTheme.light(),
        label: 'skeleton_light',
        child: const AutoLifeSkeletonBlock(lines: 4),
        surfaceSize: const Size(420, 160),
      );
      await expectGolden(tester, 'skeleton_light');
    }, tags: ['golden']);

    testWidgets('skeleton dark', (tester) async {
      await pumpGolden(
        tester,
        theme: AutoLifeTheme.dark(),
        label: 'skeleton_dark',
        child: const AutoLifeSkeletonBlock(lines: 4),
        surfaceSize: const Size(420, 160),
      );
      await expectGolden(tester, 'skeleton_dark');
    }, tags: ['golden']);

    testWidgets('button_secondary light', (tester) async {
      await pumpGolden(
        tester,
        theme: AutoLifeTheme.light(),
        label: 'btn_secondary_light',
        child: Center(
          child: AutoLifeButton(
            label: 'Maybe later',
            onPressed: () {},
            variant: AutoLifeButtonVariant.secondary,
          ),
        ),
        surfaceSize: const Size(420, 120),
      );
      await expectGolden(tester, 'btn_secondary_light');
    }, tags: ['golden']);

    testWidgets('button_secondary dark', (tester) async {
      await pumpGolden(
        tester,
        theme: AutoLifeTheme.dark(),
        label: 'btn_secondary_dark',
        child: Center(
          child: AutoLifeButton(
            label: 'Maybe later',
            onPressed: () {},
            variant: AutoLifeButtonVariant.secondary,
          ),
        ),
        surfaceSize: const Size(420, 120),
      );
      await expectGolden(tester, 'btn_secondary_dark');
    }, tags: ['golden']);

    testWidgets('button_destructive light', (tester) async {
      await pumpGolden(
        tester,
        theme: AutoLifeTheme.light(),
        label: 'btn_destructive_light',
        child: Center(
          child: AutoLifeButton(
            label: 'Remove',
            onPressed: () {},
            variant: AutoLifeButtonVariant.destructive,
          ),
        ),
        surfaceSize: const Size(420, 120),
      );
      await expectGolden(tester, 'btn_destructive_light');
    }, tags: ['golden']);

    testWidgets('button_destructive dark', (tester) async {
      await pumpGolden(
        tester,
        theme: AutoLifeTheme.dark(),
        label: 'btn_destructive_dark',
        child: Center(
          child: AutoLifeButton(
            label: 'Remove',
            onPressed: () {},
            variant: AutoLifeButtonVariant.destructive,
          ),
        ),
        surfaceSize: const Size(420, 120),
      );
      await expectGolden(tester, 'btn_destructive_dark');
    }, tags: ['golden']);
  });
}

void _noop(String _) {}
