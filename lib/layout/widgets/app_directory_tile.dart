/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */

import 'package:flutter/material.dart';

// Custom code
import '../../registry/app.dart';

class AppDirectoryTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final String types;
  final String? directoryPath;
  final VoidCallback onTap;

  const AppDirectoryTile({
    super.key,
    required this.title,
    required this.icon,
    required this.types,
    this.directoryPath,
   
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final labels = context.labels[types] ?? {};
    final bool isSet = directoryPath != null && directoryPath!.isNotEmpty && directoryPath != "Not set";

    return ListTile(
      leading: Icon(icon, color: isSet ? Colors.blue : Colors.grey),
      title: Text(title),
      subtitle: Text(
        isSet ? directoryPath! : (labels['directory_help_text'] ?? ""),
        overflow: TextOverflow.ellipsis,
      ),
      onTap: onTap,
    );
  }
}