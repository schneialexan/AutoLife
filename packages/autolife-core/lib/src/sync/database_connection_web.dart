import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';
import 'package:sqlite3/wasm.dart';

QueryExecutor openInMemoryConnection() => LazyDatabase(() async {
      final sqlite3 = await WasmSqlite3.loadFromUrl(Uri.parse('sqlite3.wasm'));
      sqlite3.registerVirtualFileSystem(InMemoryFileSystem(), makeDefault: true);
      return WasmDatabase.inMemory(sqlite3);
    });

QueryExecutor openFileConnection(String filename) => LazyDatabase(() async {
      final sqlite3 = await WasmSqlite3.loadFromUrl(Uri.parse('sqlite3.wasm'));
      final fs = await IndexedDbFileSystem.open(dbName: filename);
      sqlite3.registerVirtualFileSystem(fs);
      return WasmDatabase(sqlite3: sqlite3, path: '/$filename', fileSystem: fs);
    });
