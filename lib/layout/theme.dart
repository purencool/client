/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */

import 'package:flutter/material.dart';
class BaseTheme {
  final Map<String, dynamic> config;

  BaseTheme(Map<String, dynamic> defaults, [Map<String, dynamic>? overrides])
      : config = _mergeConfig(defaults, overrides);

  ThemeData get themeData {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: _c(config['seedColor'])),
      useMaterial3: true,
      appBarTheme: AppBarTheme(
        backgroundColor: _c(config['appBar']['backgroundColor']),
        foregroundColor: _c(config['appBar']['foregroundColor']),
        elevation: 4,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: _c(config['bottomNav']['backgroundColor']),
        selectedItemColor: _c(config['bottomNav']['selectedItemColor']),
        unselectedItemColor: _c(config['bottomNav']['unselectedItemColor']),
        elevation: 8,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _c(config['input']['fillColor']),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(
              color: _c(config['input']['borderColor']),
              width: (config['input']['width'] as num).toDouble()),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(
              color: _c(config['input']['focusedBorderColor']),
              width: (config['input']['width'] as num).toDouble() + 1.0),
        ),
        labelStyle:
            TextStyle(color: _c(config['text']['color']), fontSize: (config['input']['fontSize'] as num).toDouble()),
      ),
      textTheme: TextTheme(
        bodyMedium: TextStyle(
          fontSize: (config['text']['fontSize'] as num).toDouble(),
          color: _c(config['text']['color']),
        ),
      ),
    );
  }

  // Helper to merge configuration maps.
  static Map<String, dynamic> _mergeConfig(
      Map<String, dynamic> defaults, Map<String, dynamic>? overrides) {
    if (overrides == null) return defaults;
    final result = Map<String, dynamic>.from(defaults);
    for (final key in overrides.keys) {
      if (overrides[key] is Map && result[key] is Map) {
        result[key] = _mergeConfig(result[key] as Map<String, dynamic>,
            overrides[key] as Map<String, dynamic>);
      } else {
        result[key] = overrides[key];
      }
    }
    return result;
  }

  // Helper to parse colors.
  static Color _c(dynamic value) => Color(value is int ? value : 0xFF000000);
}