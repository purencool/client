/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */

import 'dart:typed_data';

/// The blueprint for high-integrity at-rest storage.
/// Forces every implementation to handle data as 
/// raw bytes for memory control.
abstract class EncryptionBase {

  /// Encrypts and persists data to the resource.
  Future<dynamic> write(String resource, Uint8List sensitiveData);

  /// Retrieves and decrypts data from the resource.
  Future<Uint8List?> read(String resource);

}