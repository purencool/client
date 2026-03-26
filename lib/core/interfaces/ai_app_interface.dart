/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */

/// Defines the contract for an AI-enabled application module.
///
/// Each app that wants to expose commands to the AI must implement this interface.
/// This allows the central `AiCommandService` to discover and run commands
/// in a standardized way.
abstract class AiAppInterface {
  /// A map of command definitions for this module.
  Map<String, Map<String, dynamic>> get commands;

  /// A method to provide data to the module's internal state.
  /// For example, providing a list of files or directories.
  void setData(String type, dynamic data);

   /// Executes a command and returns a formatted prompt string for the AI.
  String? run(String command);
}
