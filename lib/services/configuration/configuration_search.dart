/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */

import 'package:flutter/material.dart';


class ConfigurationSearch extends ChangeNotifier {
  List<dynamic> searchByPath(Map<String, dynamic> allConfigs, String path) {
    List<String> parts = path.split('.');
    String targetType = parts[0];
    List<String> subKeys = parts.sublist(1);
    List<dynamic> results = [];
    allConfigs.forEach((fileName, fileWrapper) {
      final data = fileWrapper['data'];
      if (data is Map && data['type'] == targetType) {
        if (subKeys.isEmpty) {
          results.add(data);
        } else {
          dynamic currentPart = data;
          bool found = true;

          for (String key in subKeys) {
            if (currentPart is Map && currentPart.containsKey(key)) {
              currentPart = currentPart[key];
            } else {
              found = false;
              break;
            }
          }

          if (found) {
            results.add(currentPart);
          }
        }
      }
    });

    return results;
  }
}