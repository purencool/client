/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */


import '../apps/browser/translation/browser.dart';
import '../apps/calendar/translation/calendar.dart';
import '../apps/documents/translation/documents.dart';
import '../apps/email/translation/email.dart';
import '../apps/news/translation/news.dart';
import '../apps/notes/translation/notes.dart';
import '../apps/podcasts/translation/podcasts.dart';
import '../apps/qr/translation/qr.dart';
import '../apps/support/translation/support.dart';

// Core
import '../core/apps/ai/translation/ai.dart';
import '../core/apps/home/translation/home.dart';
import '../core/apps/menu/translation/menu.dart';
import '../core/apps/sync/translation/sync.dart';
import '../core/apps/terms/translation/terms.dart';
import '../core/apps/user/translation/user.dart';

Map<String, Map<String, dynamic>> get buildLanguages {
  final allLanguages = [
    languagesMenuRegistry,
    languagesAIRegistry,
    languagesBrowserRegistry,
    languagesCalendarRegistry,
    languagesDocumentsRegistry,
    languagesEmailRegistry,
    languagesNewsRegistry,
    languagesNotesRegistry,
    languagesPodcastsRegistry,
    languagesQrRegistry,
    languagesSupportRegistry,
    languagesHomeRegistry,
    languagesSyncRegistry,
    languagesTermsRegistry,
    languagesUserRegistry,
  ];

  final buildLanguagesKeys = allLanguages.expand((r) => r.keys).toSet();
  final result = {
    for (var key in buildLanguagesKeys)
      key: {
        for (var registry in allLanguages)
          ...registry[key] ?? {},
      },
  };
  return result;
}
