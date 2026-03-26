/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */

import 'translation_arabic.dart';
import 'translation_bengali.dart';
import 'translation_english.dart';
import 'translation_french.dart';
import 'translation_hindi.dart';
import 'translation_mandarin.dart';
import 'translation_portuguese.dart';
import 'translation_russian.dart';
import 'translation_spanish.dart';
import 'translation_urdu.dart';


final Map<String, Map<String, dynamic>> languagesQrRegistry = {
    'arabic': TranslationArabic.arabic,
    'bengali': TranslationBengali.bengali,
    'english': TranslationEnglish.english,
    'french': TranslationFrench.french,
    'hindi': TranslationHindi.hindi,
    'mandarin': TranslationMandarin.mandarin,
    'portuguese': TranslationPortuguese.portuguese,
    'russian': TranslationRussian.russian,
    'spanish': TranslationSpanish.spanish,
    'urdu': TranslationUrdu.urdu,
};