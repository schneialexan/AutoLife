import 'package:autolife_core/autolife_core.dart';
import 'package:test/test.dart';

void main() {
  test('JSON round-trip', () {
    const original = Failure(
      code: 'timeout',
      message: 'upstream',
      details: {'ms': 5000},
    );
    expect(Failure.fromJson(original.toJson()), original);
  });

  test('copyWith', () {
    const base = Failure(code: 'a');
    final next = base.copyWith(message: 'm');
    expect(next.message, 'm');
    expect(next.code, 'a');
  });
}
