/// AutoLife shared offline-first sync platform.
///
/// Local Hive storage stays the UI source of truth in every app. When the user
/// opts in (account sign-in or device pairing), registered [ModuleSyncGateway]s
/// mirror the same domain records to Supabase Postgres + Storage.
library;

export 'src/auth/auth_service.dart';
export 'src/auth/supabase_auth_service.dart';
export 'src/blob/blob_sync_service.dart';
export 'src/bootstrap/autolife_platform_base.dart';
export 'src/core/module_sync_gateway.dart';
export 'src/core/sync_cursor.dart';
export 'src/core/sync_mutation.dart';
export 'src/core/sync_status.dart';
export 'src/providers/platform_providers.dart';
export 'src/storage/outbox_store.dart';
export 'src/storage/platform_storage.dart';
export 'src/sync/remote_module_table.dart';
export 'src/sync/sync_coordinator.dart';
