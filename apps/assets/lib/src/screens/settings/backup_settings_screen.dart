import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/asset_providers.dart';
import '../../providers/category_type_providers.dart';

/// Cloud-independent backup: export the whole vault (data + blobs) to a single
/// portable file, or import one. Works fully offline and needs no account.
class BackupSettingsScreen extends ConsumerStatefulWidget {
  const BackupSettingsScreen({super.key});

  @override
  ConsumerState<BackupSettingsScreen> createState() =>
      _BackupSettingsScreenState();
}

class _BackupSettingsScreenState extends ConsumerState<BackupSettingsScreen> {
  bool _busy = false;

  Future<void> _export() async {
    setState(() => _busy = true);
    try {
      final path = await FilePicker.platform.saveFile(
        dialogTitle: 'Export vault backup',
        fileName: 'autoassets-backup.json',
        type: FileType.custom,
        allowedExtensions: const ['json'],
      );
      if (path == null) {
        return;
      }
      final service = ref.read(vaultMigrationServiceProvider);
      await service.exportToFile(path);
      _snack('Backup exported');
    } catch (_) {
      _snack('Export failed', isError: true);
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _import() async {
    setState(() => _busy = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        dialogTitle: 'Import vault backup',
        type: FileType.custom,
        allowedExtensions: const ['json'],
      );
      final path = result?.files.single.path;
      if (path == null) {
        return;
      }
      final service = ref.read(vaultMigrationServiceProvider);
      final imported = await service.importFromFile(path);
      ref.read(assetsProvider.notifier).reload();
      ref.read(categoryTypesProvider.notifier).reload();
      _snack(
        'Imported ${imported.assets} assets and '
        '${imported.categoryTypes} types',
      );
    } on FormatException catch (e) {
      _snack(e.message, isError: true);
    } catch (_) {
      _snack('Import failed', isError: true);
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  void _snack(String message, {bool isError = false}) {
    if (!mounted) {
      return;
    }
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? theme.colorScheme.errorContainer : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Backup & restore')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Export creates a single portable file containing your assets, '
            'category types, and attached files. Import merges a backup into '
            'this device (last-write-wins on matching items).',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _busy ? null : _export,
            icon: const Icon(Icons.download_outlined),
            label: const Text('Export backup'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _busy ? null : _import,
            icon: const Icon(Icons.upload_outlined),
            label: const Text('Import backup'),
          ),
        ],
      ),
    );
  }
}
