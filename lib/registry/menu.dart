/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */

import 'package:flutter/material.dart';

// Apps
import '../apps/browser/menu/browser_menu_item.dart';
import '../apps/calendar/menu/calendar_menu_item.dart';
import '../apps/documents/menu/documents_menu_item.dart';
import '../apps/email/menu/email_menu_item.dart';
import '../apps/news/menu/news_menu_item.dart';
import '../apps/notes/menu/notes_menu_item.dart';
import '../apps/podcasts/menu/podcasts_menu_item.dart';
import '../apps/qr/menu/qr_menu_item.dart';
import '../apps/support/menu/support_menu_item.dart';



// Core
import '../core/apps/ai/menu/ai_menu_item.dart';
import '../core/apps/home/menu/home_menu_item.dart';
import '../core/apps/sync/menu/sync_menu_item.dart';
import '../core/apps/user/menu/login_menu_item.dart';
import '../core/apps/user/menu/user_menu_item.dart';
import '../core/apps/terms/menu/terms_menu_item.dart';

typedef MenuBuilder = Widget Function(Map<String, dynamic> labels);

final Map<String, MenuBuilder> menuRegistry = {
  'home': (labels) => HomeMenuItem(labels: labels),
  'ai': (labels) => AiMenuItem(labels: labels),
  'browser': (labels) => BrowserMenuItem(labels: labels),
  'calendar': (labels) => CalendarMenuItem(labels: labels),
  'documents': (labels) => DocumentsMenuItem(labels: labels),
  'email': (labels) => EmailMenuItem(labels: labels),
  'news': (labels) => NewsMenuItem(labels: labels),
  'notes': (labels) => NotesMenuItem(labels: labels),
  'podcast': (labels) => PodcastsMenuItem(labels: labels),
  'qr': (labels) => QrMenuItem(labels: labels),
  'support': (labels) => SupportMenuItem(labels: labels),
  'sync': (labels) => SyncMenuItem(labels: labels),
  'user': (labels) => UserMenuItem(labels: labels),
  'login': (labels) => LoginMenuItem(labels: labels),
  'terms': (labels) => TermsMenuItem(labels: labels),
};