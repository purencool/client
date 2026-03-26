/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */

//import 'dart:io';
//import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

// Custom code
import '../../data/backup/manage_backup.dart';

///
/// Sync configuration backups to the cloud
///
/// Example
/// final sync = Sync(
///  apiKey: 'yourApiKey',
///  token: 'yourToken',
///  cloudApiBaseUrl: 'https://your.api.base.url',
///  profile: 'profileId',
/// );
/// await sync.uploadBackups();
///
///
class Sync {
  final String apiKey;
  final String token;
  final String cloudApiBaseUrl;
  final String profile;

  Sync({
    required this.apiKey,
    required this.token,
    required this.cloudApiBaseUrl,
    required this.profile,
  });

  Future<void> uploadBackups() async {
    final managerBackUp = ManageBackup(profileId: profile);

    final backups = await managerBackUp.listBackupKeys();

    for (final file in backups) {
      debugPrint(file);

      // Check if file exists in the cloud
      ///final checkRes = await http.get(
      //  Uri.parse('$cloudApiBaseUrl/api/backups/exists?filename=$fileName'),
      //  headers: {'Authorization': 'Bearer $token', 'x-api-key': apiKey},
      //);

      //if (checkRes.statusCode == 200) {
      ///  final exists = checkRes.body == 'true' || checkRes.body == '"true"';
      // if (exists) {
      //   // Already exists, skip
      ///   continue;
      //  }
      ///} else {
      // Handle error (could log or throw)
      // debugPrint(
      //    'Failed to check existence for $fileName: ${checkRes.statusCode}',
      //  );
      //  continue;
      // }
      // exit;
      // Upload the file
      // final uploadReq =
      //    http.MultipartRequest(
      //        'POST',
      //        Uri.parse('$cloudApiBaseUrl/api/backups/upload'),
      //      )
      //      ..headers['Authorization'] = 'Bearer $token'
      //      ..headers['x-api-key'] = apiKey
      //      ..files.add(await http.MultipartFile.fromPath('file', file.path));

      ///final uploadRes = await uploadReq.send();

      /// if (uploadRes.statusCode == 200 || uploadRes.statusCode == 201) {
      // Success!
      ///   debugPrint('Uploaded ${file.path}');
      //} else {
      // Handle upload error
      // debugPrint('Failed to upload ${file.path}: ${uploadRes.statusCode}');
      // }
    }
  }
}
