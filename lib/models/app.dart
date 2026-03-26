/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */

import 'app/app_local.dart';
import 'app/app_global.dart';
import 'app/app_init.dart';
import 'app/app_sync.dart';

final List<Map<String, dynamic>> buildApp = [
  AppLocal.app,
  AppGlobal.app,
  AppInit.init,
  AppSync.app,
];