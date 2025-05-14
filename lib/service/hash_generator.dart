import 'dart:convert';
import 'package:crypto/crypto.dart';

String generateHashFromContent(String content) {
  final bytes = utf8.encode(content);
  final digest = sha256.convert(bytes);
  return digest.toString();
}
