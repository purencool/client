/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */

import 'package:flutter/material.dart';

// Custom Code
import '../../layout/theme.dart';
import '../core/apps/user/theme/developer.dart';

//TODO this will need to be converted to the theme resources. I will create three WAG, default and dark.
const Map<String, dynamic> _defaultConfig = {
  "global": {
    'seedColor': 0xFF673AB7,
    'appBar': {'backgroundColor': 0xFF673AB7, 'foregroundColor': 0xFFFFFFFF},
    'bottomNav': {
      'backgroundColor': 0xFF673AB7,
      'selectedItemColor': 0xFFFFFFFF,
      'unselectedItemColor': 0xB3FFFFFF,
    },
    'input': {
      'fillColor': 0xFFFFFFFF,
      'borderColor': 0xDD000000,
      'focusedBorderColor': 0xFF673AB7,
      'fontSize': 18.0,
      'width': 2.0,
    },
    'text': {'fontSize': 16.0, 'color': 0xDD000000},
  },
  'user': {
    'developer': {
      'codeColor': 0xFF69F0AE,
      'containerColor': 0xFF212121,
      'codeFontSize': 11.0,
      'codeFontFamily': 'monospace',
      'headerIconColor': 0xFFFF9800, // Colors.orange
      'subHeaderColor': 0xFF607D8B, // Colors.blueGrey
      'subHeaderFontSize': 12.0,
      'emptyTextColor': 0xFF9E9E9E, // Colors.grey
      'rawConfigColor': 0xFF607D8B, // Colors.blueGrey
      'rawConfigFontSize': 8.0,
    },
  },
};

/// The BaseTheme class is used for two purposes: 
/// 1. Merging custom and default configurations.
/// 2. Rebuilding building ThemeData data. 
ThemeData buildTheme([Map<String, dynamic>? overrides]) {

  // Use a temporary BaseTheme instance to get the system 
  // configuration, combining the default config with any overrides.
  final mergedConfig = BaseTheme(_defaultConfig, overrides).config;

  // Build the main ThemeData using only the 'global' part of the
  // merged configuration.
  final globalSettings = mergedConfig['global'] as Map<String, dynamic>;
  final theme = BaseTheme(globalSettings).themeData;

  // Extract the merged 'user' settings to build the theme extensions.
  final userSettings = mergedConfig['user'] as Map<String, dynamic>;
  return theme.copyWith(
    extensions: [
      DeveloperThemeExtension.fromConfig(
        userSettings['developer'] as Map<String, dynamic>,
      ),
    ],
  );
}

/// Rebuilds the active theme. This is called when theme configuration changes.
final ValueNotifier<ThemeData> themeNotifier = ValueNotifier(buildTheme());

/// Updates the active theme. Call this when configuration changes.
void refreshTheme([Map<String, dynamic>? overrides]) {
  themeNotifier.value = buildTheme(overrides);
}
