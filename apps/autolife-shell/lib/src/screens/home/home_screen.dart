import 'package:autolife_core/autolife_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/dashboard_layout_provider.dart';
import '../../providers/dashboard_registry_provider.dart';
import '../../providers/shell_providers.dart';
import '../../providers/time_of_day_provider.dart';
import 'adaptive_layout_resolver.dart';
import 'dashboard_host.dart';
import 'edit_mode/boards_scope_controls.dart';
import 'edit_mode/device_scope_selector.dart';
import 'edit_mode/device_preview_frame.dart';
import 'edit_mode/dashboard_resize_popover.dart';
import 'edit_mode/edit_layout_ops.dart';
import 'edit_mode/edit_mode_providers.dart';
import 'edit_mode/manage_overrides_sheet.dart';
import 'edit_mode/presentation_picker.dart';
import 'edit_mode/preset_picker.dart';
import 'edit_mode/scope_selector.dart';
import 'edit_mode/widget_picker_sheet.dart';
import 'widgets/omnibar.dart';

/// Home tab: omnibar + viewport-flex dashboard (phase 3.1 / 3.1.5).
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _canCustomize(WidgetRef ref) {
    final ws = ref.watch(shellWorkspaceProvider);
    if (ws.activeFamilyId.isEmpty) return true;
    FamilyRole? role;
    for (final e in ws.enrollments) {
      if (e.family.id == ws.activeFamilyId) {
        role = e.membership.role;
        break;
      }
    }
    if (role == null) return true;
    return defaultsFor(role, Capability.dashboardCustomizeOwn).granted;
  }

  MinWidthUnitsOf _minWidthOf(WidgetRef ref) {
    final reg = ref.read(dashboardWidgetRegistryProvider);
    return (id) => (reg.lookup(id)?.minWidthUnits ?? 1).clamp(1, 6);
  }

  MinHeightUnitsOf _minHeightOf(WidgetRef ref) {
    final reg = ref.read(dashboardWidgetRegistryProvider);
    return (id) => (reg.lookup(id)?.minHeightUnits ?? 1).clamp(1, 6);
  }

  Future<void> _exitEditAndSave(DashboardFormFactor ff) async {
    final working = ref.read(dashboardEditWorkingProvider);
    if (working == null) return;
    final repo = ref.read(dashboardLayoutRepositoryProvider);
    final familyId = ref.read(shellWorkspaceProvider).activeFamilyId.isEmpty
        ? shellDemoFamilyScopeUuid
        : ref.read(shellWorkspaceProvider).activeFamilyId;
    final memberScope = ref.read(dashboardEditFamilyDefaultProvider)
        ? DashboardLayoutRepository.familyDefaultMemberScope
        : shellDemoProfileUuid;

    if (repo != null) {
      await repo.upsertLayout(
        familyId: familyId,
        memberScope: memberScope,
        layout: working,
      );
    }

    ref.invalidate(homeDashboardLayoutProvider(ff));
    ref.read(dashboardEditActiveProvider.notifier).state = false;
    ref.read(dashboardEditWorkingProvider.notifier).state = null;
    ref.read(dashboardEditPreviewScopeProvider.notifier).state = null;
    ref.read(dashboardEditFamilyDefaultProvider.notifier).state = false;
    ref.read(dashboardAutoFitScrollFallbackProvider.notifier).state = false;
  }

  void _enterEdit(DashboardLayout remoteDoc, DashboardScope runtimeScope) {
    ref.read(dashboardEditWorkingProvider.notifier).state =
        DashboardLayout.fromJson(remoteDoc.toJson());
    ref.read(dashboardEditPreviewScopeProvider.notifier).state = runtimeScope;
    ref.read(dashboardEditAllScopesProvider.notifier).state = true;
    ref.read(dashboardEditActiveProvider.notifier).state = true;
    ref.read(dashboardAutoFitScrollFallbackProvider.notifier).state = false;
  }

  void _updateWorking(DashboardLayout next) {
    ref.read(dashboardEditWorkingProvider.notifier).state = next;
  }

  void _onTileDelete(
    DashboardFormFactor ff,
    DashboardScope runtimeScope,
    int rowIndex,
    int tileIndex,
  ) {
    final full = ref.read(dashboardEditWorkingProvider);
    if (full == null) return;
    final preview = ref.read(dashboardEditPreviewScopeProvider) ?? runtimeScope;
    final allScopes = ref.read(dashboardEditAllScopesProvider);
    _updateWorking(
      removeDashboardTileAt(
        full,
        preview,
        allScopes,
        rowIndex,
        tileIndex,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ff = DashboardFormFactor.fromRuntime(MediaQuery.of(context));
    final phase = ref.watch(dashboardDayPhaseProvider);
    final runtimeScope = DashboardScope(
      formFactor: ff,
      adaptive: dashboardAdaptiveForPhase(phase),
    );
    final layoutAsync = ref.watch(homeDashboardLayoutProvider(ff));
    final editing = ref.watch(dashboardEditActiveProvider);
    final working = ref.watch(dashboardEditWorkingProvider);
    final ws = ref.watch(shellWorkspaceProvider);
    final owner = isActiveFamilyOwner(ws);
    final scrollWarn = ref.watch(dashboardAutoFitScrollFallbackProvider);

    return layoutAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Dashboard error: $e')),
      data: (remote) {
        final adaptedRemote = adaptDashboardLayout(remote, phase);
        final doc = (editing && working != null) ? working : adaptedRemote;
        final previewScope =
            ref.watch(dashboardEditPreviewScopeProvider) ?? runtimeScope;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  const Expanded(child: DashboardOmnibar()),
                  if (editing) ...[
                    IconButton(
                      tooltip: 'Manage overrides',
                      icon: const Icon(Icons.layers_outlined),
                      onPressed: () =>
                          showManageOverridesSheet(context, ref),
                    ),
                    PopupMenuButton<String>(
                      itemBuilder: (ctx) => const [
                        PopupMenuItem(
                          value: 'preset',
                          child: Text('Apply preset…'),
                        ),
                        PopupMenuItem(
                          value: 'display',
                          child: Text('Display mode…'),
                        ),
                      ],
                      onSelected: (v) async {
                        if (v == 'preset') {
                          final p = await showPresetPicker(context);
                          if (!context.mounted || p == null) return;
                          final next = layoutForBuiltinPreset(
                            preset: p,
                            formFactor: previewScope.formFactor,
                          );
                          ref
                              .read(dashboardEditWorkingProvider.notifier)
                              .state = next;
                        } else if (v == 'display') {
                          final cur = working;
                          if (cur == null || !context.mounted) return;
                          final mode = await showPresentationPicker(
                            context,
                            cur.resolvePresentation(previewScope).mode,
                          );
                          if (!context.mounted || mode == null) return;
                          _updateWorking(
                            setOverflowMode(
                              cur,
                              previewScope,
                              ref.read(dashboardEditAllScopesProvider),
                              mode,
                            ),
                          );
                        }
                      },
                    ),
                    TextButton(
                      onPressed: () => _exitEditAndSave(ff),
                      child: const Text('Done'),
                    ),
                  ],
                ],
              ),
            ),
            if (editing) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DashboardScopeSelector(isOwner: owner),
                    if (ref.watch(dashboardEditFamilyDefaultProvider))
                      Card(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        child: const Padding(
                          padding: EdgeInsets.all(8),
                          child: Text(
                            'Editing the family default. Existing members keep '
                            'their own layouts. New members will start with this.',
                          ),
                        ),
                      ),
                    DeviceScopeSelector(runtimeScope: runtimeScope),
                    BoardsScopeControls(
                      previewScope: previewScope,
                      runtimeFormFactor: ff,
                    ),
                    if (scrollWarn)
                      Card(
                        color: Theme.of(context).colorScheme.errorContainer,
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            'This layout scrolls vertically. Resize or rearrange '
                            'widgets so everything fits your screen, or pick a '
                            'different display mode.',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onErrorContainer,
                            ),
                          ),
                        ),
                      ),
                    Text(
                      ref.watch(dashboardEditAllScopesProvider)
                          ? 'Editing: All scopes'
                          : 'Editing: ${previewScope.cacheKey} override',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
              ),
            ],
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: editing
                    ? DevicePreviewFrame(
                        formFactor: previewScope.formFactor,
                        child: DashboardHost(
                          document: doc,
                          scope: previewScope,
                          onAutoFitUsesScrollFallback: (v) {
                            ref
                                .read(
                                  dashboardAutoFitScrollFallbackProvider
                                      .notifier,
                                )
                                .state = v;
                          },
                          editModeOptions: DashboardEditChrome(
                            isEditing: true,
                            onTileDelete: (ri, ti) =>
                                _onTileDelete(ff, runtimeScope, ri, ti),
                            onTileResizeWidthDelta: (ri, ti, d) {
                              final w = ref.read(dashboardEditWorkingProvider);
                              if (w == null) return;
                              final p =
                                  ref.read(dashboardEditPreviewScopeProvider) ??
                                  runtimeScope;
                              final all = ref.read(dashboardEditAllScopesProvider);
                              _updateWorking(
                                bumpTileWidthDelta(
                                  w,
                                  p,
                                  all,
                                  ri,
                                  ti,
                                  d,
                                  minWidthUnitsOf: _minWidthOf(ref),
                                ),
                              );
                            },
                            onRowResizeHeightDelta: (ri, d) {
                              final w = ref.read(dashboardEditWorkingProvider);
                              if (w == null) return;
                              final p =
                                  ref.read(dashboardEditPreviewScopeProvider) ??
                                  runtimeScope;
                              final all = ref.read(dashboardEditAllScopesProvider);
                              _updateWorking(
                                bumpRowHeightDelta(
                                  w,
                                  p,
                                  all,
                                  ri,
                                  d,
                                  minHeightUnitsOf: _minHeightOf(ref),
                                ),
                              );
                            },
                            onRowReorder: (o, n) {
                              final w = ref.read(dashboardEditWorkingProvider);
                              if (w == null) return;
                              final p =
                                  ref.read(dashboardEditPreviewScopeProvider) ??
                                  runtimeScope;
                              final all = ref.read(dashboardEditAllScopesProvider);
                              _updateWorking(
                                reorderRow(w, p, all, o, n),
                              );
                            },
                            onTileReorderInRow: (r, o, n) {
                              final w = ref.read(dashboardEditWorkingProvider);
                              if (w == null) return;
                              final p =
                                  ref.read(dashboardEditPreviewScopeProvider) ??
                                  runtimeScope;
                              final all = ref.read(dashboardEditAllScopesProvider);
                              _updateWorking(
                                reorderTileInRow(w, p, all, r, o, n),
                              );
                            },
                            onTileMoveCrossRow: (fr, ft, tr, ti) {
                              final w = ref.read(dashboardEditWorkingProvider);
                              if (w == null) return;
                              final p =
                                  ref.read(dashboardEditPreviewScopeProvider) ??
                                  runtimeScope;
                              final all = ref.read(dashboardEditAllScopesProvider);
                              final next = moveTileCrossRow(
                                w,
                                p,
                                all,
                                fromRow: fr,
                                fromTile: ft,
                                toRow: tr,
                                insertTileIndex: ti,
                                minWidthUnitsOf: _minWidthOf(ref),
                              );
                              if (next != null) _updateWorking(next);
                            },
                            onDetachTileIntoNewRowAt: (ins, fr, ft) {
                              final w = ref.read(dashboardEditWorkingProvider);
                              if (w == null) return;
                              final p =
                                  ref.read(dashboardEditPreviewScopeProvider) ??
                                  runtimeScope;
                              final all = ref.read(dashboardEditAllScopesProvider);
                              _updateWorking(
                                detachTileIntoNewRow(
                                  w,
                                  p,
                                  all,
                                  fr,
                                  ft,
                                  ins,
                                  minWidthUnitsOf: _minWidthOf(ref),
                                ),
                              );
                            },
                            onOpenTileResizePopover: (ri, ti) async {
                              final w = ref.read(dashboardEditWorkingProvider);
                              if (w == null || !mounted) return;
                              final p =
                                  ref.read(dashboardEditPreviewScopeProvider) ??
                                  runtimeScope;
                              final all = ref.read(dashboardEditAllScopesProvider);
                              final rows = w.resolveRows(p);
                              final cur =
                                  rows[ri].tiles[ti].widthUnits;
                              await showTileWidthPopover(
                                context,
                                cur,
                                (nw) {
                                  final curW =
                                      ref.read(dashboardEditWorkingProvider);
                                  if (curW == null) return;
                                  _updateWorking(
                                    resizeTileWidth(
                                      curW,
                                      p,
                                      all,
                                      ri,
                                      ti,
                                      nw,
                                      minWidthUnitsOf: _minWidthOf(ref),
                                    ),
                                  );
                                },
                              );
                            },
                            onOpenRowResizePopover: (ri) async {
                              final w = ref.read(dashboardEditWorkingProvider);
                              if (w == null || !mounted) return;
                              final p =
                                  ref.read(dashboardEditPreviewScopeProvider) ??
                                  runtimeScope;
                              final all = ref.read(dashboardEditAllScopesProvider);
                              final ru = w.resolveRows(p)[ri].heightUnits;
                              await showRowHeightPopover(
                                context,
                                ru,
                                (nh) {
                                  final curW =
                                      ref.read(dashboardEditWorkingProvider);
                                  if (curW == null) return;
                                  _updateWorking(
                                    resizeRowHeight(
                                      curW,
                                      p,
                                      all,
                                      ri,
                                      nh,
                                      minHeightUnitsOf: _minHeightOf(ref),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      )
                    : GestureDetector(
                        onLongPress: _canCustomize(ref)
                            ? () => _enterEdit(adaptedRemote, runtimeScope)
                            : null,
                        child: DashboardHost(
                          document: doc,
                          scope: runtimeScope,
                        ),
                      ),
              ),
            ),
            if (editing)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: FilledButton.icon(
                  onPressed: () async {
                    final id = await showWidgetPickerSheet(context, ref);
                    if (!context.mounted || id == null) return;
                    final cur = ref.read(dashboardEditWorkingProvider)!;
                    final p =
                        ref.read(dashboardEditPreviewScopeProvider) ??
                        runtimeScope;
                    final all = ref.read(dashboardEditAllScopesProvider);
                    _updateWorking(
                      appendDashboardWidget(cur, p, all, id),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add widget'),
                ),
              ),
          ],
        );
      },
    );
  }
}
