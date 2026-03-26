/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */

// Apps
import '../apps/browser/browser_permissions.dart';
import '../apps/calendar/calendar_permissions.dart';
import '../apps/documents/documents_permissions.dart';
import '../apps/email/email_permissions.dart';
import '../apps/news/news_permissions.dart';
import '../apps/notes/notes_permissions.dart';
import '../apps/podcasts/podcasts_permissions.dart';
import '../apps/qr/qr_permissions.dart';
import '../apps/support/support_permissions.dart';

// Core
import '../core/apps/ai/ai_permissions.dart';
import '../core/apps/home/home_permissions.dart';
import '../core/apps/sync/sync_permissions.dart';
import '../core/apps/terms/terms_permissions.dart';
import '../core/apps/user/user_permissions.dart';

final Map<String, Map<String, dynamic>> permissionsRegistry = {
  "ai": AIPermissions.permissions,
  "browser": BrowserPermissions.permissions,
  "calendar": CalendarPermissions.permissions,
  "documents": DocumentsPermissions.permissions,
  "email": EmailPermissions.permissions,
  "news": NewsPermissions.permissions,
  "notes": NotesPermissions.permissions,
  "podcast": PodcastsPermissions.permissions,
  "qr": QrPermissions.permissions,
  "support": SupportPermissions.permissions,
  "home": HomePermissions.permissions,
  "sync": SyncPermissions.permissions,
  "terms": TermsPermissions.permissions,
  "user": UserPermissions.permissions,
};

Map<String, dynamic> get buildPermissions {
  final Map<String, dynamic> merged = {};

  permissionsRegistry.forEach((key, map) {
    final Map<String, dynamic> innerPermissions = map['permissions'] ?? {};
    merged.addAll(innerPermissions);
  });

  return merged;
}
