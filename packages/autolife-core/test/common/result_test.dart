import 'package:autolife_core/autolife_core.dart';
import 'package:test/test.dart';

void main() {
  test('success/failure equality', () {
    expect(const Result<int>.success(3), const Result<int>.success(3));
    expect(
      Result<int>.failure(const Failure(code: 'x')),
      Result<int>.failure(const Failure(code: 'x')),
    );
  });

  test('map success via when', () {
    const r = Result<String>.success('ok');
    final out = r.when(success: (v) => v.length, failure: (_) => -1);
    expect(out, 2);
  });

  test('Success copyWith', () {
    const original = Success<int>(1);
    expect(original.copyWith(value: 2), const Success<int>(2));
  });
}
