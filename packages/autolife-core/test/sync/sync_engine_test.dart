import 'dart:async';
import 'dart:typed_data';

import 'package:autolife_core/autolife_core.dart';
import 'package:cryptography/cryptography.dart';
import 'package:test/test.dart';

void main() {
  test('offline -> syncing -> idle when connectivity becomes online', () async {
    final c = StreamController<bool>.broadcast();
    final db = AutolifeDatabase.memory();
    final gw = const NoopRemoteSyncGateway();
    final cipher = PayloadCipher(SecretKey(Uint8List(32)));
    final engine = SyncEngine(
      db: db,
      gateway: gw,
      connectivity: ConnectivityWatcher.fake(
        stream: c.stream,
        initialOnline: false,
      ),
      cipher: cipher,
      conflictResolver: LastWriterWinsResolver(),
      tenantId: 'tenant-a',
    );
    expect(engine.status.phase, SyncEnginePhase.offline);
    await Future<void>.delayed(Duration.zero);
    c.add(true);
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(engine.status.phase, SyncEnginePhase.idle);
    engine.dispose();
    await c.close();
  });
}
