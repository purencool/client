/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */

import 'package:flutter/material.dart';

// Custom
import '../../../../registry/app.dart'; 
import '../../../../registry/settings.dart';


class User extends StatelessWidget {
  const User({super.key});

  @override
  Widget build(BuildContext context) {
    final labels = context.labels['user'] ?? {};

    if (!context.isAllowed('user')) {
      return const AccessDenied();
    }

    return Scaffold(
      key: keybindings.scaffoldKey,
      appBar: AppBar(title: Text(labels['title'] ?? "")),
      drawer: const AppMenu(),
      body: ListView.separated(
        itemCount: settings.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final builder = settings.values.elementAt(index);
          return builder(context);
        },
      ),
    );
  }
}
