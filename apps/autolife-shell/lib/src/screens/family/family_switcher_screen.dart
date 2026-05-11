import 'package:autolife_core/autolife_core.dart';
import 'package:autolife_shell/src/providers/tenancy_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Pick the active workspace and refresh sync pull scope + Drift hydration.
class FamilySwitcherScreen extends ConsumerWidget {
  const FamilySwitcherScreen({
    super.key,
    required this.enrollments,
    required this.activeFamilyId,
    required this.reloadTenancy,
  });

  final List<TenancyEnrollment> enrollments;
  final String activeFamilyId;
  final VoidCallback reloadTenancy;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your families')),
      body: ListView.separated(
        itemCount: enrollments.length,
        separatorBuilder: (context, i) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final e = enrollments[index];
          final sel = e.family.id == activeFamilyId;
          return ListTile(
            title: Text(e.family.name),
            subtitle: Text('Your role · ${e.membership.role}'),
            trailing: sel ? const Icon(Icons.check_circle) : null,
            selected: sel,
            onTap: sel
                ? null
                : () async {
                    final tenancy = ref.read(tenancyServiceProvider);
                    final res = await tenancy.switchActiveFamily(
                      familyId: e.family.id,
                    );
                    if (!context.mounted) return;
                    res.when<void>(
                      success: (_) {
                        ref
                            .read(syncEngineProvider)
                            .setFamilyPullScope(e.family.id);
                        reloadTenancy();
                        Navigator.of(context).pop<bool>(true);
                      },
                      failure: (Failure f) =>
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                f.message ?? 'Could not switch family',
                              ),
                            ),
                          ),
                    );
                  },
          );
        },
      ),
    );
  }
}
