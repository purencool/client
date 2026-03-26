/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */

import 'package:flutter/material.dart';
import '../services/permissions/permissions.dart'; 

extension PermissionsExtension on BuildContext {
  Permissions get perm => Permissions(); 
  bool isAllowed(String permissionKey) { 
    final result = perm.isApplicationEnabled(permissionKey);
    return result;
  
  }
}