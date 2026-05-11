import 'package:flutter/material.dart';

/// Naming conventions for AutoLife color tokens:
///
/// - **Brand** — primary teal family used for key chrome and interactive accents.
/// - **Surface** — backgrounds layered from lowest (`surface`) to elevated (`surfaceContainer*`).
/// - **Content** — text and icons: `on*` sits on the matching surface/brand role.
/// - **Semantic** — success, warning, error, info for banners and validation (not raw Material reds).
///
/// Raw hex values live only in this file; widgets read semantic roles via [ColorScheme]
/// or [AutoLifeTokens].
abstract final class AutoLifeColors {
  AutoLifeColors._();

  // Brand
  static const Color brandPrimary = Color(0xFF0D9488);
  static const Color brandOnPrimary = Color(0xFFFFFFFF);
  static const Color brandPrimaryContainer = Color(0xFFCCFBF1);
  static const Color brandOnPrimaryContainer = Color(0xFF042F2E);

  // Neutrals (light)
  static const Color lightSurface = Color(0xFFF8FAFC);
  static const Color lightSurfaceContainer = Color(0xFFE2E8F0);
  static const Color lightSurfaceContainerHigh = Color(0xFFCBD5E1);
  static const Color lightOnSurface = Color(0xFF0F172A);
  static const Color lightOnSurfaceVariant = Color(0xFF475569);
  static const Color lightOutline = Color(0xFF94A3B8);
  static const Color lightOutlineVariant = Color(0xFFCBD5E1);

  // Neutrals (dark)
  static const Color darkSurface = Color(0xFF0F172A);
  static const Color darkSurfaceContainer = Color(0xFF1E293B);
  static const Color darkSurfaceContainerHigh = Color(0xFF334155);
  static const Color darkOnSurface = Color(0xFFF1F5F9);
  static const Color darkOnSurfaceVariant = Color(0xFFCBD5E1);
  static const Color darkOutline = Color(0xFF64748B);
  static const Color darkOutlineVariant = Color(0xFF475569);

  // Semantic accents (shared)
  static const Color success = Color(0xFF16A34A);
  static const Color onSuccess = Color(0xFFFFFFFF);
  static const Color warning = Color(0xFFD97706);
  static const Color onWarning = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFDC2626);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color info = Color(0xFF2563EB);
  static const Color onInfo = Color(0xFFFFFFFF);
}
