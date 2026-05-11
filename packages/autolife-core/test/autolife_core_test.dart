import 'package:autolife_core/autolife_core.dart';
import 'package:test/test.dart';

void main() {
  test('barrel exposes core contracts', () {
    expect(Role.values, isNotEmpty);
    expect(EventDeliveryStatus.values, hasLength(4));
    expect(const Tenant(tenantId: 'x').tenantId, 'x');
  });
}
