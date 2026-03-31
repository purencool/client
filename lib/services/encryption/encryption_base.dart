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