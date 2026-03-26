/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */

import 'package:flutter/material.dart';

// Custom
import '../../../registry/app.dart'; 

class Browser extends StatefulWidget {
  const Browser({super.key});

  @override
  State<Browser> createState() => _BrowserState();
}

class _BrowserState extends State<Browser> {
  // Local unique key for this page's Scaffold
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // Register this key so Ctrl+M targets this page
    keybindings.pushKey(_scaffoldKey);
  }

  @override
  void dispose() {
    // Unregister the key
    keybindings.popKey();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final labels = context.labels['browser'] ?? {};

    // Permission check
    if (!context.isAllowed('browser')) {
      return const AccessDenied();
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(title: Text(labels['title'] ?? "")),
      drawer: const AppMenu(),
      body: ListView(
        children: [ListTile(title: Text(labels['title'] ?? ""), onTap: () {})],
      ),
    );
  }
}
