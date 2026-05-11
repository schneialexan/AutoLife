import 'package:autolife_ui/autolife_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('MemberPalette.colorFor is deterministic', () {
    expect(
      MemberPalette.colorFor('member-alice-uuid'),
      MemberPalette.colorFor('member-alice-uuid'),
    );
    expect(
      MemberPalette.colorFor('member-alice-uuid'),
      isNot(equals(MemberPalette.colorFor('member-bob-uuid'))),
    );
  });

  test('MemberPalette colors are opaque', () {
    final c = MemberPalette.colorFor('any-stable-id');
    expect(c.a, closeTo(1.0, 1e-9));
  });
}
