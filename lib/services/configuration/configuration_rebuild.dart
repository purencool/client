/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */

import 'dart:convert';

import '../../registry/app.dart';

import '../../models/app.dart';
import '../../models/permissions.dart';
import '../../models/settings.dart';
import '../../models/themes.dart';
import '../../models/translations.dart';

class ConfigurationRebuild {
  final String profileId;
  final GlobalResources _globalResources;

  ConfigurationRebuild({required this.profileId})
      : _globalResources = GlobalResources(profileId: profileId);

  final appLocal = buildApp[0];
  final appGlobal = buildApp[1];
  final appInit = buildApp[2];
  final appSync = buildApp[3];

  Future<void> rebuildAppLocal() async {
    final Map<String, dynamic> mergedData = Map.from(appLocal);
    mergedData['local'] = buildSettingsLocal;
    final file = await _globalResources.profileAppJson;
    await file.writeAsString(_encodeJson(mergedData));
  }

  Future<void> rebuildAppGlobal() async {
    final Map<String, dynamic> mergedData = Map.from(appGlobal);
    mergedData['global'] = buildSettingsGlobal;
    final file = await _globalResources.profileGlobalJson;
    await file.writeAsString(_encodeJson(mergedData));
  }

  Future<void> rebuildAppInit() async {
    Map<String, dynamic> appInitMap = Map<String, dynamic>.from(appInit);
    appInitMap['profile'] = profileId;
    final globalResources = GlobalResources(profileId: profileId);
    final file = await globalResources.appInitJson;
    await file.writeAsString(_encodeJson(appInitMap));
  }

  Future<void> rebuildPermissions() async {
    final Map<String, dynamic> permissionsData = buildPermissions;
    final file = await _globalResources.permissionsJson;
    await file.writeAsString(_encodeJson(permissionsData));
  }

  Future<void> rebuildSettings() async {
  final Map<String, dynamic> mergedData = Map.from(appSync);
    mergedData['sync'] = buildSettingsSync;
    final file = await _globalResources.settingsJson();
    await file.writeAsString(_encodeJson(mergedData));
  }

  Future<void> rebuildThemes() async {
    for (final entry in buildThemes.entries) {
      await (await _globalResources.themesJson(
        entry.key,
      )).writeAsString(_encodeJson(entry.value));
    }
  }

  Future<void> rebuildTranslation() async {
    final writeFutures = buildLanguages.entries.map((entry) async {
      final file = await _globalResources.languageJson(entry.key);
      await file.writeAsString(_encodeJson(entry.value));
    });
    await Future.wait(writeFutures);
  }

  String _encodeJson(dynamic value) {
    return json.encode(value);
  }

  /// Rebuilds all configuration files concurrently for maximum efficiency.
  Future<void> rebuildAll() async {
    await Future.wait([
      rebuildAppLocal(), rebuildAppGlobal(), rebuildAppInit(),
      rebuildSettings(),  rebuildPermissions(), rebuildThemes(),
      rebuildTranslation(),
    ]);
  }
}
