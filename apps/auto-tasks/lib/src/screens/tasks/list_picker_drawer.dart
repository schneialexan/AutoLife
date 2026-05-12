import 'package:auto_tasks/src/providers/task_providers.dart';
import 'package:auto_tasks/src/screens/tasks/list_settings_screen.dart';
import 'package:autolife_core/autolife_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ListPickerDrawer extends ConsumerWidget {
  const ListPickerDrawer({super.key, required this.familyId});

  final String familyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(taskRepositoryProvider);
    return Drawer(
      child: SafeArea(
        child: StreamBuilder<List<TaskList>>(
          stream: repo.watchLists(familyId),
          builder: (context, snap) {
            final lists = snap.data ?? const [];
            final selected = ref.watch(taskSelectedListIdProvider);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const DrawerHeader(
                  child: Text('Task lists', style: TextStyle(fontSize: 20)),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: lists.length,
                    itemBuilder: (ctx, i) {
                      final l = lists[i];
                      final n = repo
                          .snapshotTasks(familyId)
                          .where(
                            (t) =>
                                t.listId == l.id &&
                                t.status != TaskStatus.completed,
                          )
                          .length;
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _listColor(l.colorHex),
                          child: Text(l.name.isNotEmpty ? l.name[0] : '?'),
                        ),
                        title: Text(l.name),
                        trailing: n > 0 ? Chip(label: Text('$n')) : null,
                        selected: selected == l.id,
                        onTap: () {
                          ref.read(taskSelectedListIdProvider.notifier).state = l.id;
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.settings_outlined),
                  title: const Text('List settings'),
                  onTap: () {
                    Navigator.pop(context);
                    final id = ref.read(taskSelectedListIdProvider);
                    if (id == null) return;
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => ListSettingsScreen(
                          familyId: familyId,
                          listId: id,
                        ),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

Color? _listColor(String? hex) {
  if (hex == null || hex.length < 7) return null;
  try {
    return Color(int.parse(hex.replaceFirst('#', '0xFF')));
  } catch (_) {
    return null;
  }
}
