/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

// Custom code
import '../../../registry/app.dart';
import '../../../registry/configuration.dart';
import '../../../layout/widgets/app_directory_tile.dart';

class Notes extends StatefulWidget {
  const Notes({super.key});

  @override
  State<Notes> createState() => _DirectoriesState();
}

class _DirectoriesState extends State<Notes> {
  Future<void> _pick(BuildContext context, String key) async {
    String? path = await FilePicker.platform.getDirectoryPath();
    if (path != null) {
      await configManager.updateItem(
        type: "app",
        machineName: "app",
        keyPath: "global.notes.settings.directories.$key",
        newValue: path,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = context.configWatch;
    final labels = context.labels['user'] ?? {};

    if (config.all.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final appDataList = config.appConfigList;
    if (appDataList.isEmpty) {
      return const ListTile(title: Text("Loading directory settings..."));
    }

    final appData = appDataList.first;
    final Map<String, dynamic> dirs =
        appData['global']['notes']['settings']['directories'] as Map<String, dynamic>? ?? {};

    return Column(
      children: [
        AppDirectoryTile(
          title: labels['directories']?['notes'] ?? "",
          icon: Icons.note_alt,
          types: "notes",
          directoryPath: dirs['notes'] as String?,
          onTap: () => _pick(context, "notes"),
        ),
      ],
    );
  }
}
