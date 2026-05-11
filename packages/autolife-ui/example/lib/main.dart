import 'package:autolife_ui/autolife_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

void main() {
  runApp(
    Widgetbook.material(
      lightTheme: AutoLifeTheme.light(),
      darkTheme: AutoLifeTheme.dark(),
      themeMode: ThemeMode.light,
      directories: [
        WidgetbookCategory(
          name: 'Actions',
          children: [
            WidgetbookComponent(
              name: 'AutoLifeButton',
              useCases: [
                WidgetbookUseCase(
                  name: 'Primary',
                  builder: (context) => Center(
                    child: AutoLifeButton(
                      label: 'Continue',
                      icon: Icons.arrow_forward,
                      onPressed: () {},
                    ),
                  ),
                ),
                WidgetbookUseCase(
                  name: 'Secondary',
                  builder: (context) => Center(
                    child: AutoLifeButton(
                      label: 'Maybe later',
                      variant: AutoLifeButtonVariant.secondary,
                      onPressed: () {},
                    ),
                  ),
                ),
                WidgetbookUseCase(
                  name: 'Destructive',
                  builder: (context) => Center(
                    child: AutoLifeButton(
                      label: 'Remove',
                      variant: AutoLifeButtonVariant.destructive,
                      onPressed: () {},
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        WidgetbookCategory(
          name: 'Surfaces',
          children: [
            WidgetbookComponent(
              name: 'AutoLifeSurfaceCard',
              useCases: [
                WidgetbookUseCase(
                  name: 'Default',
                  builder: (context) => Center(
                    child: AutoLifeSurfaceCard(
                      child: Text(
                        'Preview card',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        WidgetbookCategory(
          name: 'Chrome',
          children: [
            WidgetbookComponent(
              name: 'AutoLifeAppBar',
              useCases: [
                WidgetbookUseCase(
                  name: 'Title',
                  builder: (context) => Scaffold(
                    appBar: AutoLifeAppBar(title: const Text('AutoLife')),
                    body: const Center(child: Text('Body')),
                  ),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'AutoLifeBottomNavShell',
              useCases: [
                WidgetbookUseCase(
                  name: 'Two tabs',
                  builder: (context) => AutoLifeBottomNavShell(
                    destinations: const [
                      NavigationDestination(
                        icon: Icon(Icons.home_outlined),
                        selectedIcon: Icon(Icons.home),
                        label: 'Home',
                      ),
                      NavigationDestination(
                        icon: Icon(Icons.settings_outlined),
                        selectedIcon: Icon(Icons.settings),
                        label: 'Settings',
                      ),
                    ],
                    selectedIndex: 0,
                    onDestinationSelected: (_) {},
                    body: const Center(child: Text('Home')),
                  ),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'AutoLifeOmnibar',
              useCases: [
                WidgetbookUseCase(
                  name: 'Search',
                  builder: (context) => const Padding(
                    padding: EdgeInsets.all(AutoLifeSpacing.md),
                    child: AutoLifeOmnibar(onSubmitted: _noop),
                  ),
                ),
              ],
            ),
          ],
        ),
        WidgetbookCategory(
          name: 'Family',
          children: [
            WidgetbookComponent(
              name: 'AutoLifeMemberAvatar',
              useCases: [
                WidgetbookUseCase(
                  name: 'Initials',
                  builder: (context) => const Center(
                    child: AutoLifeMemberAvatar(
                      memberId: 'gallery-member',
                      displayName: 'Jamie Lee',
                    ),
                  ),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'AutoLifeMemberBadge',
              useCases: [
                WidgetbookUseCase(
                  name: 'Label',
                  builder: (context) => const Center(
                    child: AutoLifeMemberBadge(
                      memberId: 'gallery-member',
                      label: 'Jamie',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        WidgetbookCategory(
          name: 'Feedback',
          children: [
            WidgetbookComponent(
              name: 'AutoLifeEmptyState',
              useCases: [
                WidgetbookUseCase(
                  name: 'With action',
                  builder: (context) => AutoLifeEmptyState(
                    title: 'Nothing here yet',
                    message: 'Create something to see it listed.',
                    actionLabel: 'Create',
                    onAction: () {},
                  ),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'AutoLifeSkeleton',
              useCases: [
                WidgetbookUseCase(
                  name: 'Block',
                  builder: (context) => const Padding(
                    padding: EdgeInsets.all(AutoLifeSpacing.md),
                    child: AutoLifeSkeletonBlock(lines: 4),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  );
}

void _noop(String _) {}
