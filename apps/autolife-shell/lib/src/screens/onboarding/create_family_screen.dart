import 'package:autolife_core/autolife_core.dart';
import 'package:autolife_shell/src/providers/tenancy_provider.dart';
import 'package:autolife_ui/autolife_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CreateFamilyScreen extends ConsumerStatefulWidget {
  const CreateFamilyScreen({super.key, required this.onFamilyCreated});

  /// Called after [TenancyService.createFamily] succeeds.
  final Future<void> Function() onFamilyCreated;

  @override
  ConsumerState<CreateFamilyScreen> createState() => _CreateFamilyScreenState();
}

class _CreateFamilyScreenState extends ConsumerState<CreateFamilyScreen> {
  final _name = TextEditingController();
  var _busy = false;
  Object? _error;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final svc = ref.read(tenancyServiceProvider);
    setState(() {
      _busy = true;
      _error = null;
    });
    final res = await svc.createFamily(name: _name.text);
    if (!mounted) return;
    res.when(
      failure: (f) {
        setState(() {
          _busy = false;
          _error = f.message ?? f.code;
        });
      },
      success: (_) async {
        setState(() => _busy = false);
        await widget.onFamilyCreated();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create your family')),
      body: Padding(
        padding: const EdgeInsets.all(AutoLifeSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Families are AutoLife workspaces. Choose a display name; you '
              'can invite others later.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AutoLifeSpacing.md),
            TextField(
              controller: _name,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'Family name',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) {
                if (!_busy) {
                  _submit();
                }
              },
            ),
            if (_error != null) ...[
              const SizedBox(height: AutoLifeSpacing.sm),
              Text(
                '$_error',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
            const SizedBox(height: AutoLifeSpacing.lg),
            FilledButton(
              onPressed: _busy || _name.text.trim().isEmpty ? null : _submit,
              child: Text(_busy ? 'Creating…' : 'Create family'),
            ),
          ],
        ),
      ),
    );
  }
}
