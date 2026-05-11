import 'dart:io';

import 'package:supabase/supabase.dart';
import 'package:test/test.dart';

import 'package:autolife_core/autolife_core.dart';

void main() {
  final url = Platform.environment['SUPABASE_URL'];
  final key = Platform.environment['SUPABASE_SERVICE_ROLE_KEY'];

  final run = url != null && url.isNotEmpty && key != null && key.isNotEmpty;

  test(
    'SupabaseEventProducer is idempotent for (tenant_id, idempotency_key)',
    () async {
      final client = SupabaseClient(url!, key!);
      final producer = SupabaseEventProducer(client);

      final tenant = 'it_producer_${DateTime.now().microsecondsSinceEpoch}';
      final idem = 'idem_${DateTime.now().microsecondsSinceEpoch}';
      final occurred = DateTime.now().toUtc();

      final event = SystemEvent(
        tenantId: tenant,
        actorId: 'actor_it',
        module: 'it',
        type: 'it.test',
        payload: const {'k': 1},
        idempotencyKey: idem,
        occurredAt: occurred,
        orderingTag: 'tag:$tenant',
        schemaVersion: 1,
      );

      final first = await producer.publish(event);
      final second = await producer.publish(event);

      final firstEvt = first.when(
        success: (v) => v,
        failure: (f) => throw Exception('publish1: ${f.code} ${f.message}'),
      );
      final secondEvt = second.when(
        success: (v) => v,
        failure: (f) => throw Exception('publish2: ${f.code} ${f.message}'),
      );

      expect(firstEvt.id, isNotNull);
      expect(secondEvt.id, equals(firstEvt.id));

      final rows = await client
          .from('system_event')
          .select('id')
          .eq('tenant_id', tenant)
          .eq('idempotency_key', idem);

      final list = rows as List<dynamic>;
      expect(list.length, 1);

      await client.from('system_event').delete().eq('tenant_id', tenant);
    },
    skip: run
        ? false
        : 'Set SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY (CI provides these).',
  );
}
