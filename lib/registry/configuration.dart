/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */

import '../services/configuration/configuration.dart';
import '../services/configuration/configuration_search.dart';
import '../services/configuration/configuration_filter.dart';

class ConfigurationRegistry {
  /// Initializes the default configuration.
  Future<void> defaultConfig() async {
    await Configuration().globalManager();
  }

  /// Updates the active profile.
  Future<void> updateProfile(String newProfileId) async {
    await Configuration(requestedProfileId: newProfileId).globalManager();
  }

  /// Updates a specific configuration item.
  Future<void> updateItem({
    required String type,
    required String machineName,
    required String keyPath,
    required String newValue,
  }) async {
    await Configuration().updateItem(
      type: type,
      machineName: machineName,
      keyPath: keyPath,
      newValue: newValue,
    );
  }

  /// Searches the configuration by a given path text.
  List<dynamic> search(dynamic config, String text) {
    return ConfigurationSearch().searchByPath(
      config,
      text,
    );
  }

  /// Filters the configuration by metadata type and name.
  List<dynamic> filter(dynamic config, String type, String name) {
    return ConfigurationFilter().findByMetadata(
      config,
      type,
      name,
    );
  }
}

final configManager = ConfigurationRegistry();