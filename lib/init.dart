/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:window_manager/window_manager.dart';
//import 'package:webview_cef/webview_cef.dart' as webview;
import 'package:path/path.dart' as p;


// Custom code
import 'registry/configuration.dart';

/// Entry point called in main.dart
class Init {
  /// Entry point that populates the Registry
  static Future<void> init() async {
    await _setupEnvironment();
    await _setupWindowManager();
    // if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    //  await _initializeWebView();
    // }
  }


  //TODO waiting for the follow to branch to be merged https://github.com/hlwhl/webview_cef/pull/199
  //also the the path in this are not correct need to be fixed.  
  static Future<void> _initializeWebView() async {
    const String appName = 'Conferjents';
    String? cachePath;

    if (Platform.isWindows) {
      final appData = Platform.environment['APPDATA'];
      if (appData != null) {
        cachePath = p.join(appData, appName, 'CefCache');
      }
    } else if (Platform.isMacOS) {
      final home = Platform.environment['HOME'];
      if (home != null) {
        cachePath = p.join(home, 'Library', 'Caches', appName, 'CefCache');
      }
    } else if (Platform.isLinux) {
      final home = Platform.environment['HOME'];
      if (home != null) {
        cachePath = p.join(home, '.cache', appName, 'CefCache');
      }
    }

    // Fallback if the platform-specific path could not be determined
    cachePath ??= p.join(Directory.systemTemp.path, appName, 'CefCache');

    await Directory(cachePath).create(recursive: true);
    //await webview.WebviewManager().initialize(cachePath: cachePath);
  }

  static Future<void> _setupEnvironment() async {
    try {
      await dotenv.load(fileName: ".env");
    } catch (e) {
      debugPrint('Critical Error: .env file is missing: $e');
      exit(1);
    }

    await configManager.defaultConfig();
  }

  /// Setup window variables
  static Future<void> _setupWindowManager() async {
    await windowManager.ensureInitialized();
    const WindowOptions windowOptions = WindowOptions(center: true, title: ' ');

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }
}
