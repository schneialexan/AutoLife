import 'dart:convert';
import 'dart:typed_data';

import 'package:autolife_core/autolife_core.dart';
import 'package:cryptography/cryptography.dart';
import 'package:test/test.dart';

void main() {
  test('cipher round-trips JSON', () async {
    final key = SecretKey(Uint8List(32));
    final c = PayloadCipher(key);
    final blob = await c.encryptJson({'a': 1, 'b': 'x'});
    final out = await c.decryptJson(blob);
    expect(out, {'a': 1, 'b': 'x'});
  });

  test('bytes on disk are not plaintext JSON without key', () async {
    final key = SecretKey(Uint8List(32));
    final c = PayloadCipher(key);
    final secret = {'secret': 'do-not-leak'};
    final blob = await c.encryptJson(secret);
    final asText = utf8.decode(blob, allowMalformed: true);
    expect(asText.contains('do-not-leak'), isFalse);
    expect(asText.contains('secret'), isFalse);

    final wrong = PayloadCipher(SecretKey(Uint8List(32)..[0] = 1));
    expect(() async => wrong.decryptJson(blob), throwsA(anything));
  });
}
