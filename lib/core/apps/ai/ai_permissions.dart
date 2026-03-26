/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */

class AIPermissions {
  /// Permissions configuration for this application.
  static const Map<String, dynamic> permissions = {
    "type": "permissions",
    "machine_name": "permissions",
    "permissions": {
      "ai": {
        "application": {
          "android": true,
          "ios": true,
          "linux": true,
          "macos": true,
          "windows": true,
        },
        "groups": {},
        "user": {},
      },
    },
  };
}