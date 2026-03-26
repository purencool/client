import 'package:flutter_test/flutter_test.dart';

// Import the test files you want to run
import './configuration/configuration_test.dart' as configuration_test;


void main() {
  group('Configuration Service Test Suite', () {
    // Run the main function of each test file
    configuration_test.main();
  });
}
