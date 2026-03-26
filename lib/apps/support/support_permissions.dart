/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */

class SupportPermissions {
  /// Permissions configuration for this application.
  static const Map<String, dynamic> permissions = {
    "type": "permissions",
    "machine_name": "permissions",
    "permissions": {
      "support": {
        "application": {
          "android": false,
          "ios": false,
          "linux": true,
          "macos": false,
          "windows": false,
        },
        "groups": {},
        "user": {},
      },
    },
  };
}