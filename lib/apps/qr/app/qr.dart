/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */

import 'package:flutter/material.dart';

// Custom
import '../../../registry/app.dart'; 

class Qr extends StatelessWidget {
  const Qr({super.key});

  @override
  Widget build(BuildContext context) {
    final labels = context.labels['qr'] ?? {};

    // Permission check
    if (!context.isAllowed('qr')) {
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
