/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */

import 'package:flutter/material.dart';

/// Custom
import '../../../../registry/app.dart';

// Added Home class here
class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
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
    final config = context.configWatch;

    if (!context.isAllowed('home')) {
      return const AccessDenied();
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(title: Text("App ID: ${config.session.id}")),
      drawer: const AppMenu(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.home, size: 64, color: Colors.deepPurple),
            const SizedBox(height: 20),
            Text("Welcome to ${config.session.id}"),
            const SizedBox(height: 10),
            Text("Install ID: ${config.session.id}"),
          ],
        ),
      ),
    );
  }
}
