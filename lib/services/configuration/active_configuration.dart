/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


// Custom code
import '../../models/global_config.dart';
export '../../models/global_config.dart';

///
///
///
class ActiveConfiguration {
  static final GlobalConfig _instance = GlobalConfig();
  static GlobalConfig get config => _instance;
  static ChangeNotifierProvider<GlobalConfig> provide({required Widget child}) {
    return ChangeNotifierProvider<GlobalConfig>.value(
      value: _instance,
      child: child,
    );
  }
}
