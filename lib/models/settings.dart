/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */

import '../apps/notes/notes_settings.dart';
import '../apps/qr/qr_settings.dart';
import '../apps/support/support_settings.dart';

import '../core/apps/ai/ai_settings.dart';
import '../core/apps/user/user_settings.dart';

final Map<String, Map<String, dynamic>> _buildSettings = {
  'notes': NotesSettings.notes,
  'support': SupportSettings.support,
  'qr': QrSettings.qr,
  // Core 
  'ai': AISettings.ai,
  'user': UserSettings.user
};

final Map<String, Map<String, dynamic>> buildSettingsGlobal = {
  for (final item in _buildSettings.values)
    item['machine_name'] as String: {
      'settings': item['global'],
    },
};

final Map<String, Map<String, dynamic>> buildSettingsLocal = {
  for (final item in _buildSettings.values)
    item['machine_name'] as String: {
      'settings': item['local'],
    },
};

final Map<String, Map<String, dynamic>> buildSettingsSync = {
  for (final item in _buildSettings.values)
    item['machine_name'] as String: {
      'settings': item['sync'],
    },
};
