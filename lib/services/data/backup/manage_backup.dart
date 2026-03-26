/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */

import 'dart:typed_data';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// The Manage class provides methods to manually write, read, list,
/// and delete backup files (e.g., ZIP archives),
///
/// Example.
///
/// final storage = Manage(profileId: 'user123');
///
/// Write data file
/// await storage.writeData('settings.json', bytes: utf8.encode('{"some": "value"}'));
///
/// Read data file
/// final dataBytes = await storage.readData('settings.json');
/// if (dataBytes != null) {
///  debugPrint(utf8.decode(dataBytes));
/// }
///
/// List backups
/// final backupKeys = await storage.listBackupKeys();
/// debugPrint(backupKeys);
///
/// Write a backup
/// await storage.writeBackup('2024-05-27_backup.zip', bytes: myZipBytes);
///
/// Read a backup
/// final backupBytes = await storage.readBackup('2024-05-27_backup.zip');
///
/// Delete a backup
/// await storage.deleteBackup('2024-05-27_backup.zip');
///
class ManageBackup {
  final String profileId;

  ManageBackup({required this.profileId});

  /// Internal gets the base directory for this profile.
  Future<String> _getProfileBasePath() async {
    final baseDir = await getApplicationSupportDirectory();
    return p.join(baseDir.path, profileId);
  }

  /// Internal gets the backups directory path.
  Future<String> _getBackupDirPath() async {
    final basePath = await _getProfileBasePath();
    final backupDir = Directory(p.join(basePath, 'backups'));
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }
    return backupDir.path;
  }

  /// Write data (as String or bytes) to a data file.
  Future<void> writeData(String key, {required List<int> bytes}) async {
    final basePath = await _getProfileBasePath();
    final file = File(p.join(basePath, key));
    await file.writeAsBytes(bytes, flush: true);
  }

  /// Read data from a data file.
  Future<Uint8List?> readData(String key) async {
    final basePath = await _getProfileBasePath();
    final file = File(p.join(basePath, key));
    if (await file.exists()) {
      return await file.readAsBytes();
    }
    return null;
  }

  /// List all backup keys for this profile (sorted oldest to newest).
  Future<List<String>> listBackupKeys() async {
    final backupDirPath = await _getBackupDirPath();
    final dir = Directory(backupDirPath);
    final files = dir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.zip'))
        .toList();
    files.sort((a, b) => a.path.compareTo(b.path));
    return files.map((f) => p.basename(f.path)).toList();
  }

  /// Write a backup file (as bytes) with the given key (filename).
  Future<void> writeBackup(String backupKey, {required List<int> bytes}) async {
    final backupDirPath = await _getBackupDirPath();
    final file = File(p.join(backupDirPath, backupKey));
    await file.writeAsBytes(bytes, flush: true);
  }

  /// Read a backup file as bytes.
  Future<Uint8List?> readBackup(String backupKey) async {
    final backupDirPath = await _getBackupDirPath();
    final file = File(p.join(backupDirPath, backupKey));
    if (await file.exists()) {
      return await file.readAsBytes();
    }
    return null;
  }

  /// Delete a backup by key.
  Future<void> deleteBackup(String backupKey) async {
    final backupDirPath = await _getBackupDirPath();
    final file = File(p.join(backupDirPath, backupKey));
    if (await file.exists()) {
      await file.delete();
    }
  }
}
