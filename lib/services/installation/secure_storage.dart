/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */

import 'dart:math';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as p;

class SecureStorage {
  static const _storage = FlutterSecureStorage();

  // Base directory from .env
  final String appName = dotenv.env['CONFIG_DIRECTORY'] ?? 'app';

  String _getProfileKey(String profileId, String key) {
    return p.join(appName, profileId, key);
  }

  /// Retrieves or generates a string for a SPECIFIC profile.
  Future<String> getOrGenerateForProfile(String profileId) async {
    final prefs = await SharedPreferences.getInstance();

    // Create profile-specific keys
    final String profileKey = _getProfileKey(
      profileId,
      'unique_install_string',
    );
    final String firstRunKey = _getProfileKey(profileId, 'is_first_run');

    final bool isFirstRun = prefs.getBool(firstRunKey) ?? true;

    if (isFirstRun) {
      // Delete existing ID for THIS profile only
      await _storage.delete(key: profileKey);

      String newString = _generateSecureString();
      await _storage.write(key: profileKey, value: newString);

      // Mark first run as complete for THIS profile
      await prefs.setBool(firstRunKey, false);
      return newString;
    }

    // Read the string for this specific profile
    return await _storage.read(key: profileKey) ?? _generateSecureString();
  }

  String _generateSecureString() {
    final random = Random.secure();
    final values = List<int>.generate(32, (i) => random.nextInt(256));
    return base64Url.encode(values);
  }
}
