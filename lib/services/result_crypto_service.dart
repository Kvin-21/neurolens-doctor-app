import 'dart:convert';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart' as enc;

import 'api_service.dart';

class ResultCryptoService {
  Map<String, dynamic> decryptResult({
    required EncryptedResultPayload payload,
    required String resultKeyB64,
  }) {
    try {
      final dataKey = _unwrapDataKey(
        envelopeB64: payload.patientKeyEnvelopeB64,
        resultKeyB64: resultKeyB64,
      );
      final plaintext = _decryptResult(
        ciphertextB64: payload.encryptedResultB64,
        nonceB64: payload.resultNonceB64,
        dataKey: dataKey,
      );
      return jsonDecode(utf8.decode(plaintext)) as Map<String, dynamic>;
    } catch (e) {
      throw ResultDecryptionException('Failed to decrypt result: $e');
    }
  }


  Uint8List _unwrapDataKey({
    required String envelopeB64,
    required String resultKeyB64,
  }) {
    final envelope = base64Decode(envelopeB64);
    final nonce = envelope.sublist(0, 12);
    final ciphertext = envelope.sublist(12);

    final resultKey = enc.Key(Uint8List.fromList(base64Decode(resultKeyB64)));
    final iv = enc.IV(Uint8List.fromList(nonce));
    final encrypter = enc.Encrypter(enc.AES(resultKey, mode: enc.AESMode.gcm));

    return Uint8List.fromList(
      encrypter.decryptBytes(enc.Encrypted(Uint8List.fromList(ciphertext)), iv: iv),
    );
  }

  Uint8List _decryptResult({
    required String ciphertextB64,
    required String nonceB64,
    required Uint8List dataKey,
  }) {
    final key = enc.Key(dataKey);
    final iv = enc.IV(Uint8List.fromList(base64Decode(nonceB64)));
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.gcm));
    final ciphertext = enc.Encrypted(Uint8List.fromList(base64Decode(ciphertextB64)));
    return Uint8List.fromList(encrypter.decryptBytes(ciphertext, iv: iv));
  }
}

class ResultDecryptionException implements Exception {
  final String message;
  const ResultDecryptionException(this.message);

  @override
  String toString() => 'ResultDecryptionException: $message';
}
