/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Custom Code
import '../../services/configuration/configuration_filter.dart';
import '../../services/permissions/permissions.dart';


class GlobalConfig with ChangeNotifier {
  // Global Config
  String configResource = '';
  final Map<String, dynamic> _configs = {};
  Map<String, dynamic> _userAuthenicatedPayLoad = {};

  // Authentication
  String? _apiKey, _authToken, _id;

  // AI
  String? _aiApiKey;
  String? _aiModel;
  String? _aiApiUrl;

  // UI
  List<Map<String, dynamic>>? _cachedAppConfig, _cachedLanguage, _cachedTheme;
  late final Permissions permissions;

  // Access to user
  void reconfigureUser({
    String? id,
    required Map<String, dynamic> configs,
    required String configResource,
    String? apiKey, 
    String? authToken,
    Map<String, dynamic> ? userAuthenicatedPayLoad,
  }) {
    _id = id;
    _configs.clear();
    _configs.addAll(configs);
    this.configResource = configResource;
    _apiKey = apiKey;
    _authToken = authToken;
    _userAuthenicatedPayLoad = userAuthenicatedPayLoad ?? {};
    notifyUpdate();
  }

  /// Update AI configuration.
  void updateAiConfig({
    String? apiKey,
    String? model,
    String? apiUrl,
  }) {
    if (apiKey != null) _aiApiKey = apiKey;
    if (model != null) _aiModel = model;
    if (apiUrl != null) _aiApiUrl = apiUrl;
    notifyListeners();
  }

  /// True only when both api key and auth token are non-null and non-empty.
  bool get isAuthenticated =>
      _apiKey != null &&
      _apiKey!.trim().isNotEmpty &&
      _authToken != null &&
      _authToken!.trim().isNotEmpty;

  ///
  /// Grouped Getters (Records)
  ///
  ({String? id, String? key, String? token, bool loggedIn}) get session => (
    id: _id,
    key: _apiKey,
    token: _authToken,
    loggedIn: isAuthenticated,
  );

  ///
  /// Grouped Getters for AI
  /// 
  ({String? apiKey, String? model, String? apiUrl}) get ai => (
        apiKey: _aiApiKey ?? getEnv('REST_API_APP_SERVICE_AI_KEY'),
        model: _aiModel ?? getEnv('REST_API_APP_SERVICE_AI_MODEL'),
        apiUrl: _aiApiUrl ?? getEnv('REST_API_APP_SERVICE_AI'),
      );

  ///
  /// Access network: config.network.api
  /// 
  ({String api}) get network => (api: getEnv('REST_API_APP_SERVICE'));

  /// Access SMTP: config.smtp.user
  ({String host, String port, String user, String pass, String from})
  get smtp => (
    host: getEnv('SMTP_HOST'),
    port: getEnv('SMTP_PORT'),
    user: getEnv('SMTP_USERNAME'),
    pass: getEnv('SMTP_PASSWORD'),
    from: getEnv('SMTP_FROM'),
  );

  /// Get app configuration.
  List<Map<String, dynamic>> get appConfigList => _cachedAppConfig ??=
      ConfigurationFilter().findByMetadata(_configs, 'app', 'app');

  /// Get language configuration.
  List<Map<String, dynamic>> get currentLanguage {
    if (_cachedLanguage == null) {
      final lang = appConfigList.isNotEmpty
          ? (appConfigList.first['configuration']?['translation'] ?? 'english')
          : 'english';
      _cachedLanguage = ConfigurationFilter().findByMetadata(
        _configs,
        'translation',
        lang,
      );
    }
    return _cachedLanguage!;
  }

  /// Get permissions configuration
  Map<String, dynamic> get permissionsData {
    final perms = _configs['permissions'];
    if (perms is Map && perms.containsKey('data')) {
      final data = Map<String, dynamic>.from(perms['data'])
        ..remove('resources');
      return data;
    }
    return {};
  }

  /// Get theme configuration.
  List<Map<String, dynamic>> get currentTheme {
    if (_cachedTheme == null) {
      final theme = appConfigList.isNotEmpty
          ? (appConfigList.first['data']?['configuration']?['theme'] ??
                'default')
          : 'default';
      _cachedTheme = ConfigurationFilter().findByMetadata(
        _configs,
        'theme',
        theme,
      );
    }
    return _cachedTheme!;
  }

  /// Provide access to the raw configuration map.
  Map<String, dynamic> get all => Map.unmodifiable(_configs);


  /// This just needs 
  Map<String, dynamic> get authenticateUserData => Map.unmodifiable( _userAuthenicatedPayLoad);


  void notifyUpdate() {
    _cachedAppConfig = null;
    _cachedLanguage = null;
    _cachedTheme = null;
    notifyListeners();
  }

  
  // Helpers
  String getEnv(String key, {String fallback = ''}) =>
      dotenv.env[key] ?? fallback;

  // Serialization
  String toJsonString() {
    try {
      return const JsonEncoder.withIndent('  ').convert({
        'configs': _configs,
        'env': dotenv.env,
        'id': _id,
        'apiKey': _apiKey,
        'authToken': _authToken,
        'configResource': configResource,
        'userAutheicatedPayLoad': _userAuthenicatedPayLoad,
        'isAuthenticated': isAuthenticated,
        'permissions': permissionsData,
        'ai': {
          'apiKey': _aiApiKey,
          'model': _aiModel,
          'apiUrl': _aiApiUrl,
        },
        'network': {'api': network.api},
        'smtp': {
          'host': smtp.host,
          'port': smtp.port,
          'user': smtp.user,
          'pass': smtp.pass,
          'from': smtp.from,
        },
        'appConfigList': appConfigList,
        'currentLanguage': currentLanguage,
        'currentTheme': currentTheme,
      });
    } catch (e) {
      return jsonEncode({"error": e.toString()});
    }
  }

  @override
  String toString() => toJsonString();
}
