/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */

import 'package:flutter/material.dart';

import '../apps/notes/settings/notes.dart';

import '../core/apps/user/settings/language.dart';
import '../core/apps/user/settings/directories.dart';
import '../core/apps/user/settings/developer.dart';
import '../core/apps/user/settings/id.dart';

final Map<String, WidgetBuilder> settings = {
  'language': (context) => const Language(),
  'directories': (context) => const Directories(),
  'notes' : (context) => const Notes(),
  'developer': (context) => const Developer(),
  'id': (context) => const Id(),
};
