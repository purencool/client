/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */

import '../apps/notes/notes_ai.dart';

import '../core/interfaces/ai_app_interface.dart';

import '../core/apps/user/user_ai.dart';

/// A service class to register, discover, and execute AI commands.
///
/// This class acts as a central hub for all AI commands defined in different
/// parts of the application (e.g., Notes, User). It allows for a unified
/// way to "push" command definitions from modules and "pull" or execute them
/// from a central point like the AI chat dialog.
class AiCommands{
  /// A map of registered AI application modules.
  final Map<String, AiAppInterface> _apps = {
    'notes': NotesAi(),
    'user': UsersAi(),
  };

  /// A map that aggregates all command definitions from all registered modules.
  /// The key is the command string (e.g., '/notes-files'), and the value is the
  /// command's configuration map (description, prompt, etc.).
  late final Map<String, Map<String, dynamic>> _commands;

  /// A map that links an app identifier (e.g., 'notes') to the function
  /// responsible for executing its commands.
  late final Map<String, String? Function(String)> _runners;

  /// Initializes the service by aggregating commands and runners from all modules.
  AiCommands() {
    _commands = {};
    _runners = {};
    for (final entry in _apps.entries) {
      final appName = entry.key;
      final appInstance = entry.value;
      _commands.addAll(appInstance.commands);
      _runners[appName] = appInstance.run;
    }
  }

  /// Returns a map of all available commands.
  /// Useful for displaying a help list of commands to the user.
  Map<String, Map<String, dynamic>> get allCommands => _commands;

  /// Executes a given command string.
  ///
  /// It identifies the responsible app module from the command prefix
  /// (e.g., '/notes-...' is handled by the 'notes' runner) and delegates
  /// execution to that module's `run` method.
  ///
  /// Returns a formatted string prompt for the AI, or null if the command is not found.
  String? run(String command) {
    if (!command.startsWith('/')) {
      return null;
    }

    // Extract app identifier from command, e.g., '/notes-files' -> 'notes'
    final appIdentifier = command.substring(1).split('-').first;

    final runner = _runners[appIdentifier];
    if (runner != null) {
      return runner(command);
    }

    return null;
  }

  /// Provides data to a specific AI application module.
  ///
  /// This is the "push" mechanism for other parts of the app to provide
  /// context (like file lists) to the AI modules.
  void setData(String appName, String type, dynamic data) {
    final app = _apps[appName];
    if (app != null) {
      app.setData(type, data);
    }
  }
}