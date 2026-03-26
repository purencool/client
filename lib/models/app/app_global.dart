/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */

class AppGlobal {
  static const Map<String, dynamic> app = {
    "type": "app",
    "machine_name": "global",
    "endpoints": {
      "login": {
        "api_url": "default", 
        "api_key": "", 
        "auth_token": ""
      },
    },
    "permissions": {"groups": {}, "users": {}},
  };
}