/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */

import 'package:flutter/material.dart';

// Custom code
import '../services/endpoint_requests.dart';
import '../services/configuration/configuration.dart';
import '../registry/activeconfiguration.dart';

class Authentication {


  /// Performs the network request and returns the credentials.
  Future<Map<String, dynamic>> executeLogin(String username, String password) async {
    final api = EndpointRequests(
      baseUrl: activeConfig.network.api,
      timeout: const Duration(seconds: 30),
    );

    try {
      final response = await api.postJson(
        "/authentication",
        body: {
          'action': 'login',
          'username': username,
          'password': password,
        },
      );
      return response;
    } finally {
      api.close();
    }
  }


  ///
  /// Authentication
  ///
  Future<void> signIn(String username, String password) async {
    final data = await executeLogin(username, password);
    debugPrint('API Payload: $data'); 
    if (data.isEmpty) {
      await logout();
      return;
    }

    // Pass this on configuration and it will load and update the global object.
    await Configuration(
      requestedProfileId: data['unique_name'],
      apiKey: data['api_key'],
      authToken: data['token'],
      userAuthenicatedPayLoad: data,
    ).globalManager();
  }
  
  ///
  /// The logout is using the global configuration mananger to load
  /// the default user configuration using resources and add it to 
  /// the global configuration where the application is notified and
  /// is updated. 
  /// 
  Future<void> logout() async {
   await Configuration().globalManager();
 }

}