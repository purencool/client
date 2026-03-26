/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */

import 'package:flutter/material.dart';

// Custom
import '../../../registry/app.dart'; 

class Email extends StatefulWidget {
  const Email({super.key});
  @override
  State<Email> createState() => _EmailState();
}

class _EmailState extends State<Email> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    keybindings.pushKey(_scaffoldKey);
  }

  @override
  void dispose() {
    keybindings.popKey();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final labels = context.labels['email'] ?? {};

    // Permission check
    if (!context.isAllowed('email')) {
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
