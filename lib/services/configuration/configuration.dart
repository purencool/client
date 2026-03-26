/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */

import 'package:flutter_dotenv/flutter_dotenv.dart';

// Custom code.
import '../../registry/app.dart';
import 'configuration_rebuild.dart';
import 'configuration_get.dart';
import 'configuration_object.dart';
import 'configuration_update.dart';


class Configuration {
  final String requestedProfileId;
  final String apiKeyNew;
  final String authTokenNew;
 final Map<String, dynamic>? userAuthenicatedPayLoad;

  Configuration({String? requestedProfileId, String? apiKey, String? authToken, Map<String, dynamic>? userAuthenicatedPayLoad})
    : requestedProfileId = requestedProfileId ?? dotenv.env['DEFAULT_USER'] ?? 'default.user',
      apiKeyNew = apiKey ?? '',
      authTokenNew = authToken ?? '',
      userAuthenicatedPayLoad = userAuthenicatedPayLoad ?? {};

  // this needs to update resource configuration an then reflect that in the UI.
  // @todo this also should use the configuration object to update the correct configuration.
  // @todo notify should be run from the Global configuration object.
  Future<void> updateItem({
    required String type,
    required String machineName,
    required String keyPath,
    required String newValue,
  }) async {
    final global = activeConfig;

    await ConfigurationUpdate().updateValue(
      globalConfig: global,
      type: type,
      machineName: machineName,
      keyPath: keyPath,
      newValue: newValue,
    );

    // Notify the UI that data has changed
    global.notifyUpdate();
  }

  /// Resources form
  Future<Map<String, dynamic>> getConfigFromResource() async {
    return await ConfigurationGet(profileId: requestedProfileId).getConfig();
  }

  /// This rebuilds the configuration resources and adds them to an array
  /// but this doesn't add it to the Global Configuraation Object.
  Future<dynamic> rebuiltFromResources() async {
    return await ConfigurationRebuild(profileId: requestedProfileId).rebuildAll();
  }

  /// Installs user configuration from the resource.
  Future<dynamic> globalManager() async {
    return await ConfigurationObject(
      requestedProfileId: requestedProfileId,
      apiKey: apiKeyNew,
      authToken: authTokenNew,
      userAuthenicatedPayLoad: userAuthenicatedPayLoad,
    ).changeUser();
  }
}
