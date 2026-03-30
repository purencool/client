import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';

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
  // Use a private constructor for a singleton pattern if desired, 
  // though dependency injection is preferred.
  Logging();

  @override
  void log(
    String message, {
    LogLevel level = LogLevel.info,
    Object? error,
    StackTrace? stackTrace,
  }) {
    // We only log debug info in debug mode to keep production logs clean.
    if (level == LogLevel.debug && !kDebugMode) return;

    final String time = DateTime.now().toIso8601String();
    final String label = level.name.toUpperCase();
    
    // Using dart:developer log allows for better categorization in DevTools
    dev.log(
      '[$time] $message',
      name: 'Client.$label',
      level: _getPriority(level),
      error: error,
      stackTrace: stackTrace,
    );

    // If it's a critical error, you might want to trigger additional 
    // internal logic here (e.g., local crash reporting).
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
