/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */

import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart'; 

/// This Class encrypts and decrypts strings needing 
/// protection on application locally.
class Encryption {
  final Key key;
  final IV iv;

  /// Encryption function.
  Encryption(String keyString, String ivString)
      : key = Key.fromUtf8(keyString), 
        iv = IV.fromUtf8(ivString); 

  /// String to be encrypted.
  Uint8List encrypt({required String plainText}) {
    final encrypter = Encrypter(AES(key));
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    return Uint8List.fromList(encrypted.bytes); 
  }

  /// String to be decrypted.
  String decrypt(Uint8List ciphertext) {
    final encrypter = Encrypter(AES(key)); 
    final decrypted = encrypter.decryptBytes(Encrypted(ciphertext), iv: iv);
    return utf8.decode(decrypted); 
  }
}