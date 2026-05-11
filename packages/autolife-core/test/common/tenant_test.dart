import 'package:autolife_core/autolife_core.dart';
import 'package:test/test.dart';

void main() {
  test('JSON round-trip', () {
    const original = Tenant(
      tenantId: '00000000-0000-0000-0000-000000000001',
      displayLabel: 'Home',
    );
    expect(Tenant.fromJson(original.toJson()), original);
  });

  test('copyWith', () {
    const base = Tenant(tenantId: 't1');
    final next = base.copyWith(displayLabel: 'x');
    expect(next.displayLabel, 'x');
    expect(next.tenantId, base.tenantId);
  });
}
