import 'package:drift/drift.dart';

import '../models/event_delivery_status.dart';
import 'database_connection.dart';
import 'tables/event_delivery_cache.dart';
import 'tables/event_delivery_status_map.dart';
import 'tables/family_cache.dart';
import 'tables/membership_cache.dart';
import 'tables/dashboard_layout_cache.dart';
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
    DashboardLayoutCache,
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
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.deleteTable('family_cache');
        await migrator.deleteTable('membership_cache');
        await migrator.deleteTable('profile_cache');
        await migrator.createTable(familyCache);
        await migrator.createTable(membershipCache);
        await migrator.createTable(profileCache);
      }
      if (from < 3) {
        await migrator.createTable(dashboardLayoutCache);
      }
    },
  );
}
