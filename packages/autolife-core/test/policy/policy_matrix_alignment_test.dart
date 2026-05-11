import 'dart:io';

import 'package:autolife_core/autolife_core.dart';
import 'package:autolife_core/src/policy/capability_matrix_generated.dart';
import 'package:test/test.dart';

void main() {
  test('YAML canonical JSON matches codegen output', () {
    final yaml = File('policy/matrix.yaml').readAsStringSync();

    expect(policyMatrixCanonicalJson(yaml), equals(kPolicyMatrixCanonicalJson));

    expect(
      Capability.values.length,
      greaterThan(8),
      reason: 'Capability enum should cover every matrix capability id',
    );
  });
}
