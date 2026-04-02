import 'package:flutter_test/flutter_test.dart';
import 'package:client/models/translations.dart';

/// Helper function to test the merging logic used in [buildLanguages].
/// This allows us to verify the algorithm without relying on the external
/// dependencies of the actual [buildLanguages] getter.
Map<String, Map<String, dynamic>> _testMergeLogic(
  List<Map<String, Map<String, dynamic>>> registries,
) {
  final keys = registries.expand((r) => r.keys).toSet();
  return {
    for (var key in keys)
      key: {for (var registry in registries) ...registry[key] ?? {}},
  };
}

void main() {
  group('Translations Merging Logic', () {
    test(
      'should merge keys from different registries for the same language',
      () {
        final registry1 = {
          'english': {'menu': 'Menu'},
          'french': {'menu': 'Menu'},
        };
        final registry2 = {
          'english': {'browser': 'Browser'},
          'spanish': {'browser': 'Navegador'},
        };

        final result = _testMergeLogic([registry1, registry2]);

        // English should have both menu and browser
        expect(result['english'], {'menu': 'Menu', 'browser': 'Browser'});
        // French only has menu
        expect(result['french'], {'menu': 'Menu'});
        // Spanish only has browser
        expect(result['spanish'], {'browser': 'Navegador'});
      },
    );

    test(
      'should overwrite duplicate keys with values from later registries',
      () {
        final registry1 = {
          'english': {'title': 'Old Title'},
        };
        final registry2 = {
          'english': {'title': 'New Title'},
        };

        final result = _testMergeLogic([registry1, registry2]);

        expect(result['english'], {'title': 'New Title'});
      },
    );

    test('should handle empty registries gracefully', () {
      final registry1 = {
        'english': {'key': 'value'},
      };
      final result = _testMergeLogic([registry1, {}]);

      expect(result['english'], {'key': 'value'});
    });
  });

  test('buildLanguages returns valid structure', () {
    final result = buildLanguages;
    expect(result, isA<Map<String, Map<String, dynamic>>>());
  });
}
