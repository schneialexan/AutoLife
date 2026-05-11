import 'package:drift/drift.dart';

import '../models/event_delivery_status.dart';
import '../models/role.dart';
import 'database_connection.dart';
import 'tables/event_delivery_cache.dart';
import 'tables/event_delivery_status_map.dart';
import 'tables/family_cache.dart';
import 'tables/membership_cache.dart';
import 'tables/membership_role_map.dart';
import 'tables/pending_write.dart';
import 'tables/profile_cache.dart';
import 'tables/system_event_cache.dart';

part 'autolife_database.g.dart';

/// Drift/SQLite backing store for offline cache + `pending_write` queue.
@DriftDatabase(
  tables: [
    SystemEventCache,
    EventDeliveryCache,
    ProfileCache,
    FamilyCache,
    MembershipCache,
    PendingWrites,
  ],
)
class AutolifeDatabase extends _$AutolifeDatabase {
  AutolifeDatabase(super.e);

  /// In-memory SQLite (native VM / tests) or volatile WASM (web).
  factory AutolifeDatabase.memory() =>
      AutolifeDatabase(openInMemoryConnection());

  /// Persistent storage under app documents (native) or IndexedDB (web).
  static AutolifeDatabase openFlutterFile(String filename) =>
      AutolifeDatabase(openFileConnection(filename));

  @override
  int get schemaVersion => 1;
}
