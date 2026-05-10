import 'package:autolife_ui/autolife_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AutoLifeTheme.light builds', () {
    final theme = AutoLifeTheme.light();
    expect(theme.useMaterial3, isTrue);
  });
}
