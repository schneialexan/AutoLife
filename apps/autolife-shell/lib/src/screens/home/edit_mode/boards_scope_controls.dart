import 'package:autolife_core/autolife_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'edit_layout_ops.dart';
import 'edit_mode_providers.dart';

/// Owner controls when [DashboardOverflowMode.boards] is active.
class BoardsScopeControls extends ConsumerWidget {
  const BoardsScopeControls({
    super.key,
    required this.previewScope,
    required this.runtimeFormFactor,
  });

  final DashboardScope previewScope;
  final DashboardFormFactor runtimeFormFactor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final working = ref.watch(dashboardEditWorkingProvider);
    final allScopes = ref.watch(dashboardEditAllScopesProvider);
    if (working == null) return const SizedBox.shrink();
    final pres = working.resolvePresentation(previewScope);
    if (pres.mode != DashboardOverflowMode.boards) {
      return const SizedBox.shrink();
    }
    final rows = working.resolveRows(previewScope);
    final rc = rows.length;
    final slices = pres.normalized(rc).boardRowSlices(rc);
    final maxBoards = runtimeFormFactor == DashboardFormFactor.mobile ? 5 : 8;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Boards: ${slices.length} (max $maxBoards on this form factor)',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                OutlinedButton.icon(
                  onPressed: rc <= 1
                      ? null
                      : () async {
                          final after = await _pickRowIndex(
                            context,
                            title: 'Add board after row',
                            maxExclusive: rc - 1,
                          );
                          if (after == null || !context.mounted) return;
                          if (slices.length >= maxBoards) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Max $maxBoards boards for '
                                  '${runtimeFormFactor.name}.',
                                ),
                              ),
                            );
                            return;
                          }
                          final next = addBoardAfter(
                            working,
                            previewScope,
                            allScopes,
                            after,
                          );
                          ref.read(dashboardEditWorkingProvider.notifier).state =
                              next;
                        },
                  icon: const Icon(Icons.view_column_outlined),
                  label: const Text('Split after row…'),
                ),
                OutlinedButton.icon(
                  onPressed: pres.boardBreaks.isEmpty
                      ? null
                      : () {
                          final next = setBoardBreaks(
                            working,
                            previewScope,
                            allScopes,
                            pres.boardBreaks.sublist(
                              0,
                              pres.boardBreaks.length - 1,
                            ),
                          );
                          ref.read(dashboardEditWorkingProvider.notifier).state =
                              next;
                        },
                  icon: const Icon(Icons.undo),
                  label: const Text('Remove last split'),
                ),
                OutlinedButton.icon(
                  onPressed: pres.boardBreaks.isEmpty
                      ? null
                      : () async {
                          final row = await _pickRowIndex(
                            context,
                            title: 'Merge board containing row',
                            maxExclusive: rc,
                          );
                          if (row == null || !context.mounted) return;
                          final next = removeBoardContaining(
                            working,
                            previewScope,
                            allScopes,
                            row,
                          );
                          ref.read(dashboardEditWorkingProvider.notifier).state =
                              next;
                        },
                  icon: const Icon(Icons.merge_type),
                  label: const Text('Merge board…'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Future<int?> _pickRowIndex(
  BuildContext context, {
  required String title,
  required int maxExclusive,
}) {
  return showDialog<int>(
    context: context,
    builder: (ctx) {
      return SimpleDialog(
        title: Text(title),
        children: [
          for (var i = 0; i < maxExclusive; i++)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, i),
              child: Text('Row $i'),
            ),
        ],
      );
    },
  );
}
