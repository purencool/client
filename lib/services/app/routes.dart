/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */


import '../../models/routes.dart';

class Routes {
  Routes._internal();
  static final Routes _instance = Routes._internal();
  factory Routes() => _instance;

  final Map<String, dynamic> _allRoutes = {};

  Map<String, dynamic> get routes => _allRoutes;

  void loadRoutes() {
    _allRoutes.clear();

    for (Map<String, dynamic> routeMap in buildRoutes) {
      _allRoutes.addAll(routeMap);
    }
  }
}