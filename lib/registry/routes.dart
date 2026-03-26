/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */

import 'package:flutter/material.dart';

import '../../apps/browser/app/browser.dart';
import '../../apps/calendar/app/calendar.dart';
import '../../apps/documents/app/documents.dart';
import '../../apps/email/app/email.dart';
import '../../apps/news/app/news.dart';
import '../../apps/notes/app/notes.dart';
import '../../apps/podcasts/app/podcasts.dart';
import '../../apps/qr/app/qr.dart';
import '../../apps/support/app/support.dart';

import '../core/apps/ai/app/ai.dart';
import '../core/apps/home/app/home.dart';
import '../core/apps/sync/app/sync.dart';
import '../core/apps/user/app/user.dart';
import '../core/apps/terms/app/terms.dart';

// Registry for MaterialApp routes
final Map<String, WidgetBuilder> appRoutes = {
  '/': (context) => const Home(),
  '/ai': (context) => const Ai(),
  '/browser': (context) => const Browser(),
  '/calendar': (context) => const Calender(),
  '/documents': (context) => const Documents(),
  '/email': (context) => const Email(),
  '/news': (context) => const News(),
  '/notes': (context) => const Notes(),
  '/podcasts': (context) => const Podcasts(),
  '/qr': (context) => const Qr(),
  '/support': (context) => const Support(),
  '/sync': (context) => const Sync(),
  '/terms': (context) => const Terms(),
  '/user': (context) => const User(),
};