/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */

class PipeProxy {
  /// Clinical Patterns for Australian PII Detection
  static final Map<String, RegExp> _piiPatterns = {
    // 8 or 9 digits (Standard TFN)
    'AU_TFN': RegExp(r'\b\d{3}\s?\d{3}\s?\d{2,3}\b'),

    // 11 digits (Standard ABN)
    'AU_ABN': RegExp(r'\b\d{2}\s?\d{3}\s?\d{3}\s?\d{3}\b'),

    // 10 digits (Standard Medicare)
    'AU_MEDICARE': RegExp(r'\b\d{4}\s?\d{5}\s?\d{1}\b'),

    // Common AU Mobile/Landline formats
    'AU_PHONE': RegExp(r'\b(?:\+61|0)[2-478](?:[ -]?\d){8}\b'),
  };

  /// The Scrubbing Engine
  /// Takes any string and returns a "Safe" version.
  static String scrub(String input) {
    if (input.isEmpty) return input;

    String sanitized = input;

    _piiPatterns.forEach((label, pattern) {
      if (pattern.hasMatch(sanitized)) {
        // We replace the sensitive data with a clinical tag
        sanitized = sanitized.replaceAll(pattern, '[REDACTED_$label]');
      }
    });

    return sanitized;
  }
}
