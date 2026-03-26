/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */

import 'package:flutter/material.dart';
import '../../../../../registry/app.dart';

class UserSessionView extends StatelessWidget {
  final VoidCallback onLogout;

  const UserSessionView({
    super.key, 
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    // We use watch here because if the session ID changes, 
    // this specific part of the UI should rebuild.
    final sessionId = context.configWatch.session.id;

    return ListTile(
      leading: const CircleAvatar(
        child: Icon(Icons.person),
      ),
      title: Text("$sessionId"),
      subtitle: const Text("Log Out"),
      trailing: IconButton(
        icon: const Icon(Icons.logout, color: Colors.red),
        onPressed: onLogout,
      ),
    );
  }
}