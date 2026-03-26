/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as p;
import 'package:intl/intl.dart';

// Custom Code
import '../../../registry/app.dart';

class CreateBackup {
  final String profileId;

  CreateBackup({required this.profileId});

  ///
  /// Creates a backup of the 'sync' directory.
  /// Usage: 
  ///   final creator = Create(profileId: 'user123');
  ///   final path = await creator.createBackup();
  Future<String> create() async {
    final config = GlobalResources(profileId: profileId);
    final Directory syncDir = await config.syncDir;
    final Directory backupsDir = await config.backupDir;
    debugPrint("$backupsDir");
    debugPrint("$syncDir");

    final String dateTimeStr = DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());
    final String sanitizedInput = profileId.trim().replaceAll(
      RegExp(r'[^A-Za-z0-9_\-]'),
      '_',
    );

    final String zipFileName = '$dateTimeStr-$sanitizedInput.zip';
    final String zipPath = p.join(backupsDir.path, zipFileName);

    final encoder = ZipFileEncoder();
    encoder.create(zipPath);
    await encoder.addDirectory(syncDir, includeDirName: false);
    encoder.close();
    return zipPath;
  }
}