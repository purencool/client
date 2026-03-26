/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */

import '../../interfaces/ai_app_interface.dart';

class UsersAi implements AiAppInterface {
  List<String> _files = [];
  List<String> _directories = [];

  @override
  void setData(String type, dynamic data) {
    if (data is List<String>) {
      if (type == 'files') _files = data;
      if (type == 'directories') _directories = data;
    }
  }

  @override
  Map<String, Map<String, dynamic>> get commands => {
        '/user-files': {
          'description': 'Get a list of files',
          'prompt': 'The user wants to see the file list. Here is the data:\n',
          'data': () => _files,
        },
        '/user-dir': {
          'description': 'Get a list of directories',
          'prompt':
              'The user wants to see the directory list. Here is the data:\n',
          'data': () => _directories,
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
