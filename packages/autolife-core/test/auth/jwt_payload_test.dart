import 'dart:convert';

import 'package:autolife_core/autolife_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('JwtPayload', () {
    test('decodes simple payload', () {
      final header = base64Url
          .encode(utf8.encode('{"alg":"none"}'))
          .replaceAll('=', '');
      final payloadMap = {'session_id': 'sess-1', 'exp': 2000000000};
      final payloadSegment = base64Url
          .encode(utf8.encode(jsonEncode(payloadMap)))
          .replaceAll('=', '');
      final jwt = '$header.$payloadSegment.';
      final payload = JwtPayload.decode(jwt);
      expect(payload, isNotNull);
      expect(payload!['session_id'], 'sess-1');
      expect(payload['exp'], 2000000000);
    });
  });
}
