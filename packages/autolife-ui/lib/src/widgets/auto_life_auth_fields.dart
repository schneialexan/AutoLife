import 'package:flutter/material.dart';

import '../tokens/radii.dart';
import '../tokens/spacing.dart';

/// Outlined single-line password-aware field wired to Phase 1.3 rounding + spacing tokens.
///
/// Embed in a caller-owned [Form]/[FocusNode]/[validator] pairing.
final class AutoLifeTextField extends StatelessWidget {
  const AutoLifeTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onChanged,
    this.enabled = true,
    this.obscureText = false,
    this.autofillHints,
    this.textCapitalization,
    this.focusNode,
  });

  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final void Function(String raw)? onChanged;
  final bool enabled;
  final bool obscureText;
  final Iterable<String>? autofillHints;
  final TextCapitalization? textCapitalization;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      obscureText: obscureText,
      onChanged: onChanged,
      enabled: enabled,
      autofillHints: autofillHints,
      textCapitalization: textCapitalization ?? TextCapitalization.none,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AutoLifeRadii.md),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AutoLifeRadii.md),
          borderSide: BorderSide(color: scheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AutoLifeRadii.md),
          borderSide: BorderSide(color: scheme.primary, width: 1.25),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AutoLifeRadii.md),
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AutoLifeRadii.md),
          borderSide: BorderSide(color: scheme.error, width: 1.25),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AutoLifeSpacing.sm,
          vertical: AutoLifeSpacing.sm,
        ),
      ),
      style: TextStyle(color: scheme.onSurface, fontSize: 16),
      cursorColor: scheme.primary,
    );
  }
}

/// Lightweight inline error surfaced by auth + form flows.
///
/// Always feed user-facing sentences from typed mappers (`AuthMappedError`).
final class AutoLifeErrorBanner extends StatelessWidget {
  const AutoLifeErrorBanner({super.key, required this.message, this.onDismiss});

  final String message;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final border = Border.all(color: scheme.error.withValues(alpha: 0.4));
    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AutoLifeSpacing.sm),
        decoration: BoxDecoration(
          color: scheme.errorContainer,
          borderRadius: BorderRadius.circular(AutoLifeRadii.md),
          border: border,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.warning_amber_rounded, color: scheme.error),
            const SizedBox(width: AutoLifeSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onErrorContainer,
                ),
              ),
            ),
            if (onDismiss != null)
              IconButton(
                icon: Icon(Icons.close, color: scheme.onSurface),
                onPressed: onDismiss,
                visualDensity: VisualDensity.compact,
              ),
          ],
        ),
      ),
    );
  }
}
