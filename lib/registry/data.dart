/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */

import 'package:animated_tree_view/animated_tree_view.dart';

final Map<String, dynamic>? _data = null;


class AppDataProvider {

  Future<TreeNode<String>> getTree(String appName) async {
    // We use Future.value to simulate an async operation with mock data.
    switch (appName) {
      case 'notes':
        final notesData = _data?['notes'];
        if (notesData != null && notesData.containsKey('notes_tree')) {
          final treeFactory = notesData['notes_tree'] as Function;
          return Future.value(treeFactory() as TreeNode<String>);
        }
    }
    return Future.value(TreeNode.root());
  }


  Future<bool> saveTree(dynamic payload) async {
    // In a real app, you would serialize and save the payload.
    // For now, we just pretend it was successful.
    print("Simulating save for payload: $payload");
    return Future.value(true);
  }

  Future<String> getContent(String type) async {
    // We use Future.value to simulate an async operation with mock data.
    switch (type) {
      case 'notes':
        return Future.value("Content for $type");
    }
    return Future.value("");
  }

  /// Mock save operation for the Notes app.
  Future<bool> saveContent(String type, dynamic payload) async {
    // In a real app, you would serialize and save the payload.
    // For now, we just pretend it was successful.
    print("Simulating save for payload: $payload");

    switch (type) {
      case 'notes':
        return Future.value(true);
    }

    return Future.value(true);
  }

  // Context for AI
  Map<String, dynamic> _activeContext = {};
  Map<String, dynamic> get activeContext => _activeContext;

  void updateContext(Map<String, dynamic> context) {
    _activeContext = context;
  }
}
final appData = AppDataProvider();