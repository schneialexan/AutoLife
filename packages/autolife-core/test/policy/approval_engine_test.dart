import 'package:autolife_core/autolife_core.dart';
import 'package:test/test.dart';

class _CaptureProducer implements EventProducer {
  final events = <SystemEvent>[];

  @override
  Future<Result<SystemEvent>> publish(SystemEvent event) async {
    events.add(event);
    return Result.success(event);
  }
}

void main() {
  test('auto-approve emits requested + resolved with rule id', () async {
    final producer = _CaptureProducer();
    final engine = ApprovalEngine(
      eventProducer: producer,
      defaultTenant: const Tenant(tenantId: 't1'),
      actorProfileId: 'u1',
    );

    final row = <String, dynamic>{};
    Future<void> persist(Map<String, dynamic> merged) async {
      row
        ..clear()
        ..addAll(merged);
    }

    engine.cacheRulesForNextSubmit([
      const ApprovalAutoRule(
        id: 'rule-1',
        familyId: 'f1',
        role: FamilyRole.teenager,
        capability: Capability.calendarCreateEvent,
        label: 'school',
        enabled: true,
        match: {'location_normalized': 'school'},
      ),
    ]);

    final res = await engine.submitApprovalRequest(
      persist: persist,
      familyId: 'f1',
      capability: Capability.calendarCreateEvent,
      requesterRole: FamilyRole.teenager,
      payload: const {'location': 'School'},
    );

    expect(res.when(success: (_) => true, failure: (_) => false), isTrue);
    expect(row['status'], 'auto_approved');
    expect(row['applied_auto_rule_id'], 'rule-1');

    expect(producer.events.length, 2);
    expect(producer.events[0].type, 'approval.requested');
    expect(producer.events[1].type, 'approval.resolved');
    expect(producer.events[1].payload['status'], 'auto_approved');
  });

  test('illegal transition returns typed failure', () async {
    final engine = ApprovalEngine(
      eventProducer: const IgnoringEventProducer(),
      defaultTenant: const Tenant(tenantId: 't1'),
      actorProfileId: 'u1',
    );

    var snap = <String, dynamic>{
      'id': 'a1',
      'family_id': 'f1',
      'status': 'approved',
    };

    final res = await engine.transitionPending(
      rowSnapshot: snap,
      persist: (m) async {
        snap = Map<String, dynamic>.from(m);
      },
      desiredStatus: 'expired',
      resolverProfileId: 'parent',
    );

    expect(res.when(success: (_) => false, failure: (_) => true), isTrue);
    expect(
      res.when(success: (_) => null, failure: (f) => f.code),
      'approval_illegal_transition',
    );
  });

  test('pending may transition to approved', () async {
    final producer = _CaptureProducer();
    final engine = ApprovalEngine(
      eventProducer: producer,
      defaultTenant: const Tenant(tenantId: 't1'),
      actorProfileId: 'parent',
    );

    var snap = <String, dynamic>{
      'id': 'a2',
      'family_id': 'f1',
      'status': 'pending',
    };

    final res = await engine.transitionPending(
      rowSnapshot: snap,
      persist: (m) async {
        snap = Map<String, dynamic>.from(m);
      },
      desiredStatus: 'approved',
      resolverProfileId: 'parent',
    );

    expect(res.when(success: (_) => true, failure: (_) => false), isTrue);
    expect(snap['status'], 'approved');
    expect(producer.events.single.type, 'approval.resolved');
  });

  test('expireStaleIfNeeded moves pending past expires_at', () async {
    final engine = ApprovalEngine(
      eventProducer: const IgnoringEventProducer(),
      defaultTenant: const Tenant(tenantId: 't1'),
      actorProfileId: 'sys',
    );

    var snap = <String, dynamic>{
      'id': 'a3',
      'family_id': 'f1',
      'status': 'pending',
      'expires_at': DateTime.now()
          .toUtc()
          .subtract(const Duration(minutes: 1))
          .toIso8601String(),
    };

    await engine.expireStaleIfNeeded(
      rowSnapshot: snap,
      persist: (m) async {
        snap = Map<String, dynamic>.from(m);
      },
    );

    expect(snap['status'], 'expired');
  });
}
