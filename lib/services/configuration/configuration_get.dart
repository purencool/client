/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;



class ConfigurationGet {
  final String profileId;

  ConfigurationGet({required this.profileId});

  Future<Directory> _getConfig() async {
    final baseDir = await getApplicationSupportDirectory();
    final Directory configDir = Directory(p.join(baseDir.path, profileId));
    return configDir;
  }

  Future<Map<String, dynamic>> getConfig() async {
    final Directory dir = await _getConfig();
    final Map<String, dynamic> configs = {};

    await for (var entity in dir.list(recursive: true)) {
      if (entity is File && entity.path.endsWith('.json')) {
        try {
          final String content = await entity.readAsString();
          final String fileName = p.basenameWithoutExtension(entity.path);
          final Map<String, dynamic> jsonData = Map<String, dynamic>.from(
            json.decode(content),
          );
          jsonData['resources'] = entity.path;

          configs[fileName] = {'data': jsonData};
        } catch (e) {
          debugPrint('Failed to process ${entity.path}: $e');
        }
      }
    }
    return configs;
  }
}
