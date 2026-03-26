/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */

import '../core/themes/theme_dark.dart';
import '../core/themes/theme_default.dart';


final Map<String, Map<String, dynamic>> buildThemes = {
  'dark': ThemeDark.theme,
  'default': ThemeDefault.theme,
};
