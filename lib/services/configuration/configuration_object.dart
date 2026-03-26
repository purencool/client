/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */

import 'package:flutter/material.dart';
//import 'dart:io';

// Custom code
import './configuration.dart';
import '../../registry/activeconfiguration.dart';
import '../../registry/resources.dart';


class ConfigurationObject {
  final String? requestedProfileId;
  final String? apiKey;
  final String? authToken;
  final Map<String, dynamic>? userAuthenicatedPayLoad;


  ConfigurationObject({this.requestedProfileId, this.apiKey, this.authToken, this.userAuthenicatedPayLoad});

  Future<void> changeUser() async {
    final globalConfig = activeConfig;

    final globalResources = GlobalResources(profileId: requestedProfileId);
    final baseResources = await globalResources.baseDir;

    // Check if the profile is installed locally
    if (!await globalResources.checkProfileIsInstalled()) {   
      // If not install rebuild resources stuctures.
      await globalResources.createProfileStructure();
      // Add default configuration to resources.
      await Configuration(requestedProfileId: requestedProfileId).rebuiltFromResources();
    }


    final configResource = baseResources.path;
    try {
      final configData = await Configuration(requestedProfileId: requestedProfileId).getConfigFromResource();      
      globalConfig.reconfigureUser(
        id: requestedProfileId,
        configs: configData,
        configResource: configResource,
        apiKey: apiKey,
        authToken: authToken,
        userAuthenicatedPayLoad: userAuthenicatedPayLoad,
      );
    } catch (e) {
      debugPrint("!!! ERROR during reconfigure: $e");
    }
  }
}
