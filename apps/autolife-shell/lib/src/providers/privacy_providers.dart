import 'package:autolife_core/autolife_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'shell_providers.dart';

final biometricLockServiceProvider = Provider<BiometricLockService>(
  (_) => BiometricLockService(),
);

final babysitterLinkServiceProvider = Provider<BabysitterLinkService>(
  (ref) => BabysitterLinkService(ref.watch(supabaseClientProvider)),
);
