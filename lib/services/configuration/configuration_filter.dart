/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */

import 'package:flutter/material.dart';

class ConfigurationFilter extends ChangeNotifier {
  
  List<Map<String, dynamic>> findByMetadata(
    Map<String, dynamic> allConfigs, 
    String targetType, 
    String targetMachineName
  ) {
    List<Map<String, dynamic>> results = [];
    allConfigs.forEach((fileName, fileWrapper) {
      final data = fileWrapper['data'];
      if (data is Map) {
        final bool isCorrectType = data['type'] == targetType;
        final bool isCorrectName = data['machine_name'] == targetMachineName;
        if (isCorrectType && isCorrectName) {
          results.add(Map<String, dynamic>.from(data));
        }
      }
    });

    return results;
  }
}
