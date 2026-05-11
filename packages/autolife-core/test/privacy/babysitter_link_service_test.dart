import 'package:autolife_core/autolife_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('SHA-256 matches pgTAP fixture vector for scope-token-a', () {
    final h = babysitterTokenSha256Hex('scope-token-a');
    expect(
      h,
      '8b0922d6580625931a5fc7c0b41eb2d0546e857c1d5ba200c1063b4efc2aa925',
    );
  });

  test('BabysitterScopeResolution parses ok payload', () {
    final r = BabysitterScopeResolution.fromJson({
      'status': 'ok',
      'family_id': 'f1',
      'link_id': 'l1',
      'resources': ['wifi_credentials', 'allergies'],
    });
    expect(r.status, BabysitterScopeStatus.ok);
    expect(r.familyId, 'f1');
    expect(r.resources, ['wifi_credentials', 'allergies']);
  });
}
