/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/configuration/active_configuration.dart';
export '../services/configuration/active_configuration.dart';


/// Get active
GlobalConfig get activeConfig {
  //ActiveConfig.dumpEverything();
  return ActiveConfiguration.config;
}

///
///
///
extension ActiveConfigExtension on BuildContext {
  /// Read [GlobalConfig] without subscribing to updates.
  GlobalConfig get configRead {
    //ActiveConfig.dumpEverything();
    return read<GlobalConfig>();
  }

  /// Watch [GlobalConfig]; widget rebuilds on any change.
  GlobalConfig get configWatch {
    //ActiveConfig.dumpEverything();
    return watch<GlobalConfig>();
  }

  /// True when api key and auth token are set (non-null, non-empty). 
  ///Rebuilds only when this bool changes.
  bool get isAuthenticated => select<GlobalConfig, bool>((c) => c.isAuthenticated);

  /// Current language labels map. Rebuilds only when this map's content changes, 
  ///not on other config updates.
  Map<String, dynamic> get labels =>
    select<GlobalConfig, Map<String, dynamic>>((c) {
      final val = c.currentLanguage.isNotEmpty ? c.currentLanguage.first : <String, dynamic>{};
      //debugPrint('DEBUG LABELS: $val');
      return val;
  });
}