import 'package:auto_tasks/src/screens/tasks/list_picker_drawer.dart';
import 'package:auto_tasks/src/screens/tasks/tabs/assigned_to_me_tab.dart';
import 'package:auto_tasks/src/screens/tasks/tabs/done_tab.dart';
import 'package:auto_tasks/src/screens/tasks/tabs/important_tab.dart';
import 'package:auto_tasks/src/screens/tasks/tabs/inbox_tab.dart';
import 'package:auto_tasks/src/screens/tasks/tabs/my_day_tab.dart';
import 'package:auto_tasks/src/screens/tasks/tabs/planned_tab.dart';
import 'package:auto_tasks/src/screens/tasks/tabs/projects_tab.dart';
import 'package:auto_tasks/src/screens/tasks/today_aggregate_screen.dart';
import 'package:auto_tasks/src/screens/tasks/widgets/quick_add_bar.dart';
import 'package:auto_tasks/src/screens/tasks/widgets/bulk_action_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TaskListsScreen extends ConsumerWidget {
  const TaskListsScreen({
    super.key,
    required this.familyId,
    this.showAppBar = true,
  });

  final String familyId;
  final bool showAppBar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 7,
      child: Scaffold(
        appBar: showAppBar
            ? AppBar(
                title: const Text('Tasks'),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.today_outlined),
                    tooltip: 'Today across lists',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              TodayAggregateScreen(familyId: familyId),
                        ),
                      );
                    },
                  ),
                ],
                bottom: const TabBar(
                  isScrollable: true,
                  tabs: [
                    Tab(text: 'Inbox'),
                    Tab(text: 'My Day'),
                    Tab(text: 'Important'),
                    Tab(text: 'Planned'),
                    Tab(text: 'Assigned'),
                    Tab(text: 'Projects'),
                    Tab(text: 'Done'),
                  ],
                ),
              )
            : null,
        drawer: ListPickerDrawer(familyId: familyId),
        body: Column(
          children: [
            BulkActionBar(familyId: familyId),
            Expanded(
              child: TabBarView(
                children: [
                  InboxTab(familyId: familyId),
                  MyDayTab(familyId: familyId),
                  ImportantTab(familyId: familyId),
                  PlannedTab(familyId: familyId),
                  AssignedToMeTab(familyId: familyId),
                  ProjectsTab(familyId: familyId),
                  DoneTab(familyId: familyId),
                ],
              ),
            ),
            QuickAddBar(familyId: familyId),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Add task from quick bar or templates (phase 3.3).')),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
