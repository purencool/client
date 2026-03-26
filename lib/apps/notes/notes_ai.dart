/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */

import 'dart:io';
import '../../core/interfaces/ai_app_interface.dart';

class NotesAi implements AiAppInterface {
  List<String> _files = [];
  List<String> _directories = [];
  String? _currentFile;

  @override
  void setData(String type, dynamic data) {
    if (type == 'files' && data is List<String>) {
      _files = data;
    } else if (type == 'directories' && data is List<String>) {
      _directories = data;
    } else if (type == 'current_file' && data is String?) {
      _currentFile = data;
    }
  }

  @override
  Map<String, Map<String, dynamic>> get commands => {
        '/notes-files': {
          'description': 'Get a list of files',
          'prompt': 'The user wants to see the file list. Here is the data:\n',
          'data': () => _files,
        },
        '/notes-dir': {
          'description': 'Get a list of directories',
          'prompt':
              'The user wants to see the directory list. Here is the data:\n',
          'data': () => _directories,
        },
        '/note-current-file': {
          'description': 'Get content of the currently open file',
          'prompt':
              'The user wants to see the content of the current file. Here is the data:\n',
          'data': () {
            if (_currentFile != null && File(_currentFile!).existsSync()) {
              try {
                return File(_currentFile!).readAsStringSync();
              } catch (e) {
                return 'Error reading file: $e';
              }
            }
            return 'No file is currently open or the file path is invalid.';
          },
        },
      };

  @override
  String? run(String command) {
    final config = commands[command];
    if (config != null) {
      final dataFn = config['data'] as Function?;
      if (dataFn != null) {
        final data = dataFn();
        return "${config['prompt'] as String}$data";
      }
    }

    return null;
  }
}
