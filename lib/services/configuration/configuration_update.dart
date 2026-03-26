/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';


class ConfigurationUpdate {
  Future<void> updateValue({
    required globalConfig,
    required String type,
    required String machineName,
    required String keyPath,
    required dynamic newValue,
  }) async {
    Map<String, dynamic>? targetData;

    for (var fileWrapper in globalConfig.all.values) {
      final data = fileWrapper['data'];
      if (data is Map &&
          data['type'] == type &&
          data['machine_name'] == machineName) {
        targetData = data as Map<String, dynamic>;
        break;
      }
    }

    if (targetData == null) {
      debugPrint(
        "Error: Could not find config for type: $type, name: $machineName",
      );
      return;
    }
    List<String> keys = keyPath.split('.');
    dynamic current = targetData;

    for (int i = 0; i < keys.length - 1; i++) {
      String key = keys[i];
      if (current[key] == null || current[key] is! Map) {
        current[key] = <String, dynamic>{};
      }

      current = current[key] as Map<String, dynamic>;
    }

    current[keys.last] = newValue;
    final String? filePath = targetData['resources'];
    if (filePath != null) {
      final File file = File(filePath);
      final Map<String, dynamic> toSave = Map.from(targetData)
        ..remove('resources');

      try {
        await file.writeAsString(json.encode(toSave));
        debugPrint("Configuration saved: $filePath");
      } catch (e) {
        debugPrint("Disk Write Error: $e");
      }
    }
  }
}
