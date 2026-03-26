/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

// Custom code
import '../../../../registry/app.dart';
import '../../../../registry/configuration.dart';

class Directories extends StatefulWidget {
  const Directories({super.key});

  @override
  State<Directories> createState() => _DirectoriesState();
}

class _DirectoriesState extends State<Directories> {
  Future<void> _pick(BuildContext context, String key) async {
    String? path = await FilePicker.platform.getDirectoryPath();
    if (path != null) {
      await configManager.updateItem(
        type: "app",
        machineName: "app",
        keyPath: "local.user.settings.directories.$key",
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
        appData['local']['user']['settings']['directories'] as Map<String, dynamic>? ?? {};

    return Column(
      children: [
        _tile(
          context,
          labels['directories']?['documents'] ?? "",
          Icons.description,
          dirs['documents'],
          "documents"
        ),
        _tile(
          context,
          labels['directories']?['music'] ?? "",
          Icons.audiotrack,
          dirs['music'],
          "music"
        ),
        _tile(
          context,
          labels['directories']?['pictures'] ?? "",
          Icons.image,
          dirs['pictures'],
          "pictures"
        ),
        _tile(
          context,
          labels['directories']?['videos'] ?? "",
          Icons.video_library,
          dirs['videos'],
          "videos"
        ),
      ],
    );
  }

  Widget _tile(
    BuildContext context,
    String title,
    IconData icon,
    String directories,
    String key
  ) {
    final labels = context.labels['user'] ?? {};
    final bool isSet = directories.isNotEmpty && directories != "Not set";

    return ListTile(
      leading: Icon(icon, color: isSet ? Colors.blue : Colors.grey),
      title: Text(title),
      subtitle: Text(
        isSet
            ? directories
            : labels['directories']?['directory_help_text'] ?? "",
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () => _pick(context, key),
    );
  }
}
