import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';
import '../../models/global_resources.dart';

/// Defines the severity of the system telemetry.
enum LogLevel {
  debug,
  info,
  warning,
  error,
  critical,
}

/// The blueprint for all logging operations.
abstract class ILogging {
  void log(String message, {LogLevel level = LogLevel.info, Object? error, StackTrace? stackTrace});
}

class Logging implements ILogging {
  Logging();

  @override
  void log(
    String message, {
    LogLevel level = LogLevel.info,
    Object? error,
    StackTrace? stackTrace,
  }) {
    // Guard clause: Skip debug logs in production
    if (level == LogLevel.debug && !kDebugMode) return;

    final String time = DateTime.now().toIso8601String();
    final String label = level.name.toUpperCase();
    final String fullLogEntry = '[$time] [$label] $message';

    // Output to Developer Console (Standard behavior)
    dev.log(
      fullLogEntry,
      name: 'Client.$label',
      level: _getPriority(level),
      error: error,
      stackTrace: stackTrace,
    );

    // Persist to Global Resources (Audit behavior)
    // We pass the string entry, not the 'dev' library.
    _writeToGlobalResources(fullLogEntry, error);
  }

  /// Internal helper to sync logs with the application state.
  void _writeToGlobalResources(String logEntry, Object? error) {
    try {
      // Assuming logWrite accepts a String. 
      // If there's an error object, we append it to the record.
      final record = error != null ? '$logEntry | Error: $error' : logEntry;
      
      GlobalResources().logWrite(record);
    } catch (e) {
      // Fail-safe to prevent logging failures from crashing the app
      debugPrint('Critial Failure: Logging to GlobalResources failed: $e');
    }
  }

  int _getPriority(LogLevel level) {
    return switch (level) {
      LogLevel.debug => 500,
      LogLevel.info => 800,
      LogLevel.warning => 900,
      LogLevel.error => 1000,
      LogLevel.critical => 2000,
    };
  }
}
