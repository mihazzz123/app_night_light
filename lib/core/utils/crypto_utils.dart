import 'dart:convert';
import 'package:crypto/crypto.dart';

class CryptoUtils {
  static const String _secret = 'your-client-secret';

  static String generateSignature(String payload) {
    final key = utf8.encode(_secret);
    final bytes = utf8.encode(payload);
    final hmac = Hmac(sha256, key);
    final digest = hmac.convert(bytes);
    return digest.toString();
  }
}
