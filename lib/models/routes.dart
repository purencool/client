/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */

import '../apps/notes/notes_route.dart';
import '../core/apps/user/user_route.dart';


final List<Map<String, dynamic>> buildRoutes = [
  NotesRoute.route, 
  UserRoute.route,
];