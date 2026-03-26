/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */

import 'package:flutter/material.dart';

// Custom code
import '../../../registry/app.dart'; 

class Podcasts extends StatelessWidget {
  const Podcasts({super.key});

  @override
  Widget build(BuildContext context) {
    final labels = context.labels['podcasts'] ?? {};

    // Permission check
    if (!context.isAllowed('podasts')) {
      return const AccessDenied();
    }

    return Scaffold(
      key: keybindings.scaffoldKey,
      appBar: AppBar(title: Text(labels['title'] ?? "")),
      drawer: const AppMenu(),
      body: ListView(
        children: [ListTile(title: Text(labels['title'] ?? ""), onTap: () {})],
      ),
    );
  }
}
