import 'package:autolife_core/autolife_core.dart';
import 'package:test/test.dart';

void main() {
  test('defaults source grants owner manage_policy', () async {
    final svc = RolePolicyService(const YamlDefaultsCapabilityGrantSource());
    final g = await svc.resolvedGrant(
      familyId: 'any',
      role: FamilyRole.owner,
      capability: Capability.familyManagePolicy,
    );
    expect(
      g.when(success: (v) => v.granted, failure: (_) => fail('boom')),
      isTrue,
    );
  });

  test('defaults source denies partner manage_policy', () async {
    final svc = RolePolicyService(const YamlDefaultsCapabilityGrantSource());
    final g = await svc.resolvedGrant(
      familyId: 'any',
      role: FamilyRole.partner,
      capability: Capability.familyManagePolicy,
    );
    expect(
      g.when(success: (v) => v.granted, failure: (_) => fail('boom')),
      isFalse,
    );
  });

  test('userMayUseCapability summary', () async {
    final svc = RolePolicyService(const YamlDefaultsCapabilityGrantSource());
    final ok = await svc.userMayUseCapability(
      familyId: 'x',
      role: FamilyRole.child,
      capability: Capability.calendarCreateEvent,
    );
    expect(ok.when(success: (v) => v, failure: (_) => fail('boom')), isTrue);
  });
}
