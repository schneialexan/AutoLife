import 'package:autolife_core/autolife_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Bound when Supabase is configured ([smokeSupabaseOverrides]).
final tenancyServiceProvider = Provider<TenancyService>(
  (ref) => throw StateError('tenancyServiceProvider unbound'),
);
