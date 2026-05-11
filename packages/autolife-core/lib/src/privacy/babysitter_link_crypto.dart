import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

String babysitterTokenSha256Hex(String rawToken) {
  return sha256.convert(utf8.encode(rawToken)).toString();
}

/// 256-bit random token encoded as 64 hex chars (matches Postgres `digest` hex).
String generateBabysitterRawToken() {
  final r = Random.secure();
  final bytes = List<int>.generate(32, (_) => r.nextInt(256));
  return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
}
