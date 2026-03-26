/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */

import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Example usage:
/// final resources = GlobalResources(profileId: 'foo');
/// final Directory base = await resources.baseDir;
/// final Directory sync = await resources.syncDir;
/// final Directory backups = await resources.backupDir;
/// final File profileLocalJson  = await resources.LocalJson;
/// final File arabicJson = await resources.languageJson('arabic');
class GlobalResources {
  final String profileId;

  GlobalResources({String? profileId}) : profileId = profileId ?? "";

  /// Returns default App directory and creates it if it doesn't exist.
  Future<Directory> get appDefaultDir async => Directory(
    p.join((await getApplicationSupportDirectory()).path),
  );

  /// Returns the base for this profile and creates it if it doesn't exist.
  Future<Directory> get baseDir async => Directory(
    p.join((await getApplicationSupportDirectory()).path, profileId),
  );

  

  /// Ensures the profileId base framework exists
  Future<bool> checkProfileIsInstalled() async {
    final dir = await baseDir;
    if (!await dir.exists()) {
      return false;
    }
    return true;
  }

  /// Creates the full profile structure. So that
  /// configuration can be added and stored on 
  /// local storage.
  Future<Directory> createProfileStructure() async {
    final dir = await baseDir;
    // Profile config directory
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    // Backups, sync, global services
    final backups = await backupDir;
    if (!await backups.exists()) {
      await backups.create(recursive: true);
    }
    final sync = await syncDir;
    if (!await sync.exists()) {
      await sync.create(recursive: true);
    }
    final global = await globalDir;
    if (!await global.exists()) {
      await global.create(recursive: true);
    }

    //  Sync service structure app, language, theme
    for (final sub in ['app', 'language', 'theme']) {
      final subDir = Directory(p.join(sync.path, sub));
      if (!await subDir.exists()) {
        await subDir.create(recursive: true);
      }
    }

    return dir;
  }

  Future<Directory> _getUserHomeDirectory() async {
    Map<String, String> envVars = Platform.environment;
    String? homePath;

    if (Platform.isMacOS || Platform.isLinux) {
      homePath = envVars['HOME'];
    } else if (Platform.isWindows) {
      homePath = envVars['USERPROFILE'];
      // Safely fallback to HOMEDRIVE/HOMEPATH if USERPROFILE is not set
      if (homePath == null || homePath.isEmpty) {
        final drive = envVars['HOMEDRIVE'];
        final path = envVars['HOMEPATH'];
        if (drive != null && path != null) {
          homePath = p.join(drive, path);
        }
      }
    }

    if (homePath != null && homePath.isNotEmpty) {
      return Directory(homePath);
    }

    // Fallback for mobile or if environment variables are not set on desktop.
    return getApplicationDocumentsDirectory();
  }

  Future<Directory> get userHomeDir => _getUserHomeDirectory();
  /// Returns the sync.
  Future<Directory> get syncDir async =>
      Directory(p.join((await baseDir).path, 'sync'));

  /// Returns the global.
  Future<Directory> get globalDir async =>
      Directory(p.join((await baseDir).path, 'global'));

  /// Returns the backups.
  Future<Directory> get backupDir async =>
      Directory(p.join((await baseDir).path, 'backups'));

  /// Returns the app subs under sync.
  Future<Directory> get syncAppDir async =>
      Directory(p.join((await syncDir).path, 'app'));

  /// Returns the language sub under sync.
  Future<Directory> get syncLanguageDir async =>
      Directory(p.join((await syncDir).path, 'language'));

  /// Returns the theme sub under sync.
  Future<Directory> get syncThemeDir async =>
      Directory(p.join((await syncDir).path, 'theme'));

  ///
  /// Specific configuration files
  ///
  ///
  /// Returns the local object.
  Future<File> get profileAppJson async =>
      File(p.join((await baseDir).path, 'local.json'));

  /// Returns the profile global object.
  Future<File> get profileGlobalJson async =>
      File(p.join((await globalDir).path, 'global.json'));

  /// Returns the local object.
  Future<File> get appInitJson async =>
      File(p.join((await appDefaultDir).path, 'init.json'));

  /// Returns the permissions object.
  Future<File> get permissionsJson async =>
      File(p.join((await globalDir).path, 'permissions.json'));

 /// Returns the [settings] object.
  Future<File> settingsJson() async =>
      File(p.join((await syncDir).path, 'settings.json'));

  /// Returns the [themes] object.
  Future<File> themesJson(String themes) async =>
      File(p.join((await syncThemeDir).path, '$themes.json'));

  /// Returns the [language] object.
  Future<File> languageJson(String language) async =>
      File(p.join((await syncLanguageDir).path, '$language.json'));

  /// Logging 
  Future<File> get profileApplogging async =>
      File(p.join((await baseDir).path, 'app_errors.log'));    

  Future<void> logError(dynamic error, StackTrace? stackTrace) async {
    try {
      final file = await profileApplogging;
      final timestamp = DateTime.now().toIso8601String();
      await file.writeAsString('[$timestamp] $error\n$stackTrace\n\n', mode: FileMode.append);
    } catch (e) {
      print('Failed to write error log: $e');
    }
  }
}
