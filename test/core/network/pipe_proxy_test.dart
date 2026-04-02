/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:client/core/network/pipe_proxy.dart';

void main() {
  group('SovereignPipeProxy - Clinical Scrubbing Tests', () {
    test('Should redact standard 9-digit Australian TFN with spaces', () {
      const raw = "The client's TFN is 123 456 789.";
      final result = PipeProxy.scrub(raw);
      expect(result, contains('[REDACTED_AU_TFN]'));
      expect(result, isNot(contains('123 456 789')));
    });

    test('Should redact 11-digit Australian ABN with standard spacing', () {
      const raw = "Company ABN: 51 824 753 556";
      final result = PipeProxy.scrub(raw);
      expect(result, contains('[REDACTED_AU_ABN]'));
      expect(result, isNot(contains('51 824 753 556')));
    });

    test('Should redact 10-digit Medicare number with regional spacing', () {
      const raw = "Patient Medicare: 2003 45678 1";
      final result = PipeProxy.scrub(raw);
      expect(result, contains('[REDACTED_AU_MEDICARE]'));
      expect(result, isNot(contains('2003 45678 1')));
    });

    test('Should redact Australian Mobile numbers (+61 and 04 formats)', () {
      const mobile1 = "Call me at +61 412 345 678";
      const mobile2 = "Contact: 0412 345 678";

      expect(PipeProxy.scrub(mobile1), contains('[REDACTED_AU_PHONE]'));
      expect(PipeProxy.scrub(mobile2), contains('[REDACTED_AU_PHONE]'));
    });

    test('Stress Test: Multiple PII in a single clinical note', () {
      const complexNote = """
        Subject: John Doe
        TFN: 987 654 321
        Medicare: 5555 44444 2
        Notes: Patient called from 0400 111 222 regarding ABN 12 345 678 901.
      """;

      final result = PipeProxy.scrub(complexNote);

      expect(result, contains('[REDACTED_AU_TFN]'));
      expect(result, contains('[REDACTED_AU_MEDICARE]'));
      expect(result, contains('[REDACTED_AU_PHONE]'));
      expect(result, contains('[REDACTED_AU_ABN]'));

      // Ensure no raw numbers remain
      expect(result, isNot(contains('987 654 321')));
      expect(result, isNot(contains('0400 111 222')));
    });

    test(
      'Edge Case: Should not redact non-PII numbers (e.g., Dates or Amounts)',
      () {
        const safeText = "The total invoice is \$1,200.50 dated 2026-04-02.";
        final result = PipeProxy.scrub(safeText);
        expect(result, equals(safeText)); // No redaction should occur
      },
    );
  });
}
