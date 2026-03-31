import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';

// Custom Code
import '../../../services/logging/logging.dart';
import '../io/resources_system.dart';
import 'encryption_base.dart';

class Encryption implements EncryptionBase {
  final ILogging _logger;
  final ResourcesSystem  _resourcesSystem;
  final AesGcm _algorithm = AesGcm.with256bits();
  final SecretKey _vaultKey;

  Encryption({
    required ILogging logger,
    required ResourcesSystem  resourcesSystem,
    required SecretKey vaultKey,
  })  : _logger = logger,
        _resourcesSystem = resourcesSystem,
        _vaultKey = vaultKey;

  @override
  Future<void> write(String resource, Uint8List sensitiveData) async {
    try {
      _logger.log("Initiating encrypted write for asset: $resource", level: LogLevel.debug);
      
      // Encrypt the data. 
      // This generates a unique Nonce (IV) automatically.
      final secretBox = await _algorithm.encrypt(
        sensitiveData,
        secretKey: _vaultKey,
      );

      // Concatenate Nonce + Ciphertext + MAC into a single payload
      final Uint8List encryptedPayload = secretBox.concatenation();

      // Write binary data to the resource path
      // Assuming FileSystem has a method for binary storage
      await _resourcesSystem.saveResource(resource, encryptedPayload);
      
      // Memory Integrity: Overwrite the raw sensitive data buffer with zeros
      // This is vital to prevent sensitive data from lingering in RAM.
      sensitiveData.fillRange(0, sensitiveData.length, 0);

      _logger.log("Asset $resource successfully committed to at-rest vault.", level: LogLevel.info);
    } catch (e, stack) {
      _logger.log("CRITICAL: Encryption failure for $resource", level: LogLevel.critical, error: e, stackTrace: stack);
      throw SecurityException("Vault write failed: Integrity preserved.");
    }
  }

  @override
  Future<Uint8List?> read(String resource) async {
    try {
      _logger.log("Initiating secure read for asset: $resource", level: LogLevel.debug);

      // Retrieve the binary payload from disk
      final dynamic payload = await _resourcesSystem.openResource(resource);
      if (payload == null || payload is! Uint8List) return null;

      // Reconstruct the SecretBox and decrypt
      // nonceLength is 12 bytes and macLength is 16 bytes for AES-GCM
      final secretBox = SecretBox.fromConcatenation(
        payload,
        nonceLength: _algorithm.nonceLength,
        macLength: _algorithm.macAlgorithm.macLength,
      );

      final decryptedData = await _algorithm.decrypt(
        secretBox,
        secretKey: _vaultKey,
      );

      _logger.log("Asset $resource successfully decrypted and accessed.", level: LogLevel.info);
      
      return Uint8List.fromList(decryptedData);
    } catch (e, stack) {
      _logger.log("CRITICAL: Integrity check failed for $resource", level: LogLevel.error, error: e, stackTrace: stack);
      throw SecurityException("Integrity check failed: Data may be compromised.");
    }
  }
}

class SecurityException implements Exception {
  final String message;
  SecurityException(this.message);
}
