import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

/// AES-256-GCM payload protection for [pending_write.payload] blobs.
class PayloadCipher {
  PayloadCipher(this._key);

  final SecretKey _key;
  static const int _wireVersion = 1;

  final AesGcm _algo = AesGcm.with256bits();

  Future<Uint8List> encryptUtf8(String utf8Text) async {
    final secretBox = await _algo.encrypt(
      utf8.encode(utf8Text),
      secretKey: _key,
    );
    return _pack(secretBox);
  }

  Future<String> decryptUtf8(Uint8List blob) async {
    final box = _unpack(blob);
    final clear = await _algo.decrypt(
      box,
      secretKey: _key,
    );
    return utf8.decode(clear);
  }

  Future<Uint8List> encryptJson(Map<String, dynamic> map) =>
      encryptUtf8(jsonEncode(map));

  Future<Map<String, dynamic>> decryptJson(Uint8List blob) async {
    final s = await decryptUtf8(blob);
    final decoded = jsonDecode(s);
    return Map<String, dynamic>.from(decoded as Map);
  }

  Uint8List _pack(SecretBox box) {
    final nonce = box.nonce;
    final mac = box.mac.bytes;
    final ct = box.cipherText;
    final out = BytesBuilder(copy: false);
    out.addByte(_wireVersion);
    out.addByte(nonce.length);
    out.add(nonce);
    out.addByte(mac.length);
    out.add(mac);
    out.add(ct);
    return out.toBytes();
  }

  SecretBox _unpack(Uint8List blob) {
    if (blob.isEmpty || blob[0] != _wireVersion) {
      throw StateError('unsupported_payload_cipher_version');
    }
    var i = 1;
    final nlen = blob[i++];
    final nonce = blob.sublist(i, i + nlen);
    i += nlen;
    final mlen = blob[i++];
    final mac = Mac(blob.sublist(i, i + mlen));
    i += mlen;
    final cipherText = blob.sublist(i);
    return SecretBox(cipherText, nonce: nonce, mac: mac);
  }
}
