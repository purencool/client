/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */

import '../../../services/os.dart';
import '../../registry/activeconfiguration.dart';


class Permissions {
  
  bool _canAccess(String feature, String category) {
    // Use singleton so we read the loaded config (not a fresh empty instance)
    final permissionsData = activeConfig.permissionsData;

    // See if the feature is allowed
    final featureData = permissionsData[feature];
    if (featureData == null || featureData is! Map) return false;

    // See if the category
    final categoryData = featureData[category];
    if (categoryData == null || categoryData is! Map) return false;

    // Is current platform allowed for example categoryData['linux'] == true
    final String currentPlatform = Os.operatingSystem.toLowerCase();
    final isAllowed = categoryData[currentPlatform] == true;

    return isAllowed;
  }

  bool isApplicationEnabled(String featureName) {
    return _canAccess(featureName, 'application');
  }

  bool isApplicationFeatureEnabled(String featureName, String application ) {
    return _canAccess(featureName, application);
  }

}