/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */

import 'package:flutter/material.dart';

// Custom
import '../../../../registry/app.dart';
import '../../../../registry/configuration.dart';

class Language extends StatelessWidget {
  const Language({super.key});
  
  @override
  Widget build(BuildContext context) {
    final config = context.configWatch; 
    final labels = context.labels['user'] ?? {};
    debugPrint(config.toString());
    final appData = config.appConfigList.first['configuration'] ?? {};
    final String currentLang = appData['translation'] ?? 'english';

    return ListTile(
      leading: const Icon(Icons.language),
      title: Text(labels['language']['title'] ?? ""),
      trailing: DropdownButton<String>(
        value: currentLang,
        items: const [
          DropdownMenuItem(value: 'arabic', child: Text("عربي")),
          DropdownMenuItem(value: 'bengali', child: Text("बंगाली")),
          DropdownMenuItem(value: 'english', child: Text("English")),
          DropdownMenuItem(value: 'french', child: Text("Français")),
          DropdownMenuItem(value: 'hindi', child: Text("हिंदी")),
          DropdownMenuItem(value: 'mandarin', child: Text("普通话")),
          DropdownMenuItem(value: 'portuguese', child: Text("Português")),
          DropdownMenuItem(value: 'russian', child: Text("Русский")),
          DropdownMenuItem(value: 'spanish', child: Text("Español")),
          DropdownMenuItem(value: 'urdu', child: Text("اردو")),
        ],
        onChanged: (String? val) async {
          if (val == null || val == currentLang) return;
           await configManager.updateItem(
            type: "app",
            machineName: "app",
            keyPath: "configuration.translation",
            newValue: val,
          );
        },
      ),
    );
  }
}
