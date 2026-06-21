import 'package:auto_assets/src/data/asset_repository.dart';
import 'package:auto_assets/src/data/category_type_repository.dart';
import 'package:auto_assets/src/models/asset.dart';
import 'package:auto_assets/src/models/category_type.dart';
import 'package:auto_assets/src/models/value_kind.dart';
import 'package:auto_assets/src/sync/assets_sync_gateway.dart';
import 'package:auto_assets/src/sync/assets_sync_schema.dart';
import 'package:autolife_platform/autolife_platform.dart';
import 'package:flutter_test/flutter_test.dart';

class _InMemoryAssetRepository implements AssetRepository {
  final Map<String, Asset> _store = <String, Asset>{};

  @override
  List<Asset> getAll() => _store.values.toList();

  @override
  Asset? getById(String id) => _store[id];

  @override
  Future<void> save(Asset asset) async => _store[asset.id] = asset;

  @override
  Future<void> delete(String id) async => _store.remove(id);
}

class _InMemoryCategoryTypeRepository implements CategoryTypeRepository {
  final Map<String, CategoryType> _store = <String, CategoryType>{};

  @override
  List<CategoryType> getAll() => _store.values.toList();

  @override
  List<CategoryType> getActive() =>
      _store.values.where((t) => !t.isArchived).toList();

  @override
  CategoryType? getById(String id) => _store[id];

  @override
  Future<void> save(CategoryType type) async => _store[type.id] = type;

  @override
  Future<void> delete(String id) async => _store.remove(id);

  @override
  Future<void> seedDefaults() async {}
}

class _FakeRemoteTable implements RemoteModuleTable {
  final List<Map<String, dynamic>> upserted = <Map<String, dynamic>>[];
  List<Map<String, dynamic>> rows = <Map<String, dynamic>>[];

  @override
  Future<void> upsertRows(List<Map<String, dynamic>> rows) async {
    upserted.addAll(rows);
  }

  @override
  Future<List<Map<String, dynamic>>> fetchSince(
    DateTime? cursor, {
    required int limit,
  }) async {
    return rows.where((r) {
      if (cursor == null) {
        return true;
      }
      final server = DateTime.parse(r['server_updated_at'] as String);
      return server.isAfter(cursor);
    }).toList();
  }
}

Asset _asset(String id, {String? name, DateTime? updatedAt}) {
  final ts = updatedAt ?? DateTime.utc(2026, 1, 1);
  return Asset(id: id, name: name, createdAt: ts, updatedAt: ts);
}

Map<String, dynamic> _remoteRow(
  Asset asset, {
  required DateTime serverUpdatedAt,
  int schemaVersion = 1,
  bool deleted = false,
}) {
  return <String, dynamic>{
    'id': asset.id,
    'payload': asset.toJson(),
    'schema_version': schemaVersion,
    'updated_at': asset.updatedAt.toUtc().toIso8601String(),
    'server_updated_at': serverUpdatedAt.toUtc().toIso8601String(),
    'deleted_at': deleted ? asset.updatedAt.toUtc().toIso8601String() : null,
    'device_id': 'remote-device',
  };
}

void main() {
  late _InMemoryAssetRepository assets;
  late _InMemoryCategoryTypeRepository categoryTypes;
  late _FakeRemoteTable itemsTable;
  late _FakeRemoteTable categoryTable;
  late AssetsSyncGateway gateway;

  setUp(() {
    assets = _InMemoryAssetRepository();
    categoryTypes = _InMemoryCategoryTypeRepository();
    itemsTable = _FakeRemoteTable();
    categoryTable = _FakeRemoteTable();
    gateway = AssetsSyncGateway(
      assetRepository: assets,
      categoryTypeRepository: categoryTypes,
      itemsTable: itemsTable,
      categoryTypesTable: categoryTable,
      deviceId: 'local-device',
    );
  });

  SyncMutation upsertItem(Asset asset) => SyncMutation(
    moduleId: AssetsSyncSchema.moduleId,
    entityType: AssetsSyncSchema.itemEntity,
    entityId: asset.id,
    operation: SyncOperation.upsert,
    payload: asset.toJson(),
    schemaVersion: AssetsSyncSchema.version,
    updatedAt: asset.updatedAt,
    deviceId: 'local-device',
  );

  test('pushMutations routes items to the items table as rows', () async {
    await gateway.pushMutations(<SyncMutation>[upsertItem(_asset('a'))]);
    expect(itemsTable.upserted, hasLength(1));
    expect(itemsTable.upserted.single['id'], 'a');
    expect(categoryTable.upserted, isEmpty);
  });

  test('pull then apply writes the remote asset into the local repo', () async {
    final remote = _asset(
      'r1',
      name: 'Drill',
      updatedAt: DateTime.utc(2026, 5),
    );
    itemsTable.rows = <Map<String, dynamic>>[
      _remoteRow(remote, serverUpdatedAt: DateTime.utc(2026, 5, 1, 0, 0, 1)),
    ];

    final changes = <SyncMutation>[];
    final max = await gateway.pullSince(null, onRemoteChange: changes.add);
    expect(changes, hasLength(1));
    expect(max, DateTime.utc(2026, 5, 1, 0, 0, 1));

    await gateway.applyRemoteChanges(changes);
    expect(assets.getById('r1')?.name, 'Drill');
  });

  test(
    'apply respects last-write-wins (older remote does not overwrite)',
    () async {
      await assets.save(
        _asset('x', name: 'Local new', updatedAt: DateTime.utc(2026, 6)),
      );
      final stale = _asset(
        'x',
        name: 'Remote old',
        updatedAt: DateTime.utc(2026, 1),
      );
      await gateway.applyRemoteChanges(<SyncMutation>[
        AssetsSyncSchema.mutationFromRow(
          _remoteRow(stale, serverUpdatedAt: DateTime.utc(2026, 6, 2)),
          entityType: AssetsSyncSchema.itemEntity,
        ),
      ]);
      expect(assets.getById('x')?.name, 'Local new');
    },
  );

  test('apply refuses a payload with a newer schema_version', () async {
    final remote = _asset('future', name: 'Too new');
    await gateway.applyRemoteChanges(<SyncMutation>[
      AssetsSyncSchema.mutationFromRow(
        _remoteRow(
          remote,
          serverUpdatedAt: DateTime.utc(2026, 7),
          schemaVersion: AssetsSyncSchema.version + 1,
        ),
        entityType: AssetsSyncSchema.itemEntity,
      ),
    ]);
    expect(assets.getById('future'), isNull);
  });

  test('apply soft-delete removes the local asset', () async {
    await assets.save(
      _asset('del', name: 'Bye', updatedAt: DateTime.utc(2026, 1)),
    );
    final remote = _asset('del', updatedAt: DateTime.utc(2026, 8));
    await gateway.applyRemoteChanges(<SyncMutation>[
      AssetsSyncSchema.mutationFromRow(
        _remoteRow(
          remote,
          serverUpdatedAt: DateTime.utc(2026, 8, 1),
          deleted: true,
        ),
        entityType: AssetsSyncSchema.itemEntity,
      ),
    ]);
    expect(assets.getById('del'), isNull);
  });

  test('collectLocalState yields a mutation per local record', () async {
    await assets.save(_asset('a'));
    await assets.save(_asset('b'));
    await categoryTypes.save(
      CategoryType(
        id: 'brand',
        name: 'Brand',
        valueKind: ValueKind.text,
        accentColor: '#000000',
        displayIcon: 'icon:tag',
        sortOrder: 0,
        createdAt: DateTime.utc(2026),
      ),
    );

    final mutations = await gateway.collectLocalState();
    expect(
      mutations.where((m) => m.entityType == AssetsSyncSchema.itemEntity),
      hasLength(2),
    );
    expect(
      mutations.where(
        (m) => m.entityType == AssetsSyncSchema.categoryTypeEntity,
      ),
      hasLength(1),
    );
  });
}
