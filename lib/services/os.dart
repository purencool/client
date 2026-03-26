/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */

import 'dart:io';

/// Platform / OS detection and OS language list.
///
/// Example:
/// ```dart
/// if (Os.isDesktop) { ... }
/// final langs = await Os.getLanguageList();
/// ```
class Os {
  static String get operatingSystem {
    if (Platform.isMacOS) return 'macos';
    if (Platform.isWindows) return 'windows';
    if (Platform.isLinux) return 'linux';
    if (Platform.isIOS) return 'ios';
    if (Platform.isAndroid) return 'android';
    if (Platform.isFuchsia) return 'fuchsia';
    return 'unknown';
  }

  static bool get isDesktop =>
      Platform.isMacOS || Platform.isWindows || Platform.isLinux;

  static bool get isMobile => Platform.isIOS || Platform.isAndroid;

  /// Returns the list of language/locale tags available on the current OS
  /// (all installed locales on Linux/macOS; preferred list on Windows).
  /// Empty list on unsupported platform or on error.
  static Future<List<String>> getLanguageList() async {
    final os = operatingSystem;
    try {
      if (os == 'macos' || os == 'linux') {
        // Use locale -a to get all installed locales (not just preferred)
        return _parseLocaleList(
          await Process.run('locale', ['-a']),
        );
      }
      if (os == 'windows') {
        return _parseWindowsLanguages(
          await Process.run(
            'powershell',
            [
              '-NoProfile',
              '-Command',
              'Get-WinUserLanguageList | Select-Object -ExpandProperty LanguageTag',
            ],
          ),
        );
      }
      if (os == 'android') {
        return _parseAndroidLocale(
          await Process.run('getprop', ['ro.product.locale']),
        );
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  static List<String> _parseWindowsLanguages(ProcessResult result) {
    if (result.exitCode != 0 || result.stdout == null) return [];
    final out = result.stdout as String;
    return out
        .split(RegExp(r'[\r\n]+'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty && s.length >= 2)
        .toList();
  }

  static List<String> _parseLocaleList(ProcessResult result) {
    if (result.exitCode != 0 || result.stdout == null) return [];
    final out = result.stdout as String;
    return out
        .split(RegExp(r'[\r\n]+'))
        .map((s) => s.trim().split('.').first)
        .where((s) => s.isNotEmpty)
        .toList();
  }

  static List<String> _parseAndroidLocale(ProcessResult result) {
    if (result.exitCode != 0 || result.stdout == null) return [];
    final out = (result.stdout as String).trim();
    return out.isEmpty ? [] : [out];
  }
}
