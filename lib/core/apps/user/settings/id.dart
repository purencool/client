/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */

import 'package:flutter/material.dart';

// Custom code
import '../../../../registry/app.dart'; 

class Id extends StatelessWidget {
  const Id({super.key});

  @override
  Widget build(BuildContext context) {
    final config = context.configWatch;
    final labels = context.labels['user'] ?? {};

    return ListTile(
      leading: const Icon(Icons.fingerprint),
      title: Text(labels['id']?['title'] ?? ""),
      isThreeLine: true,
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Updated to use the local config variable
          Text("${labels['id']?['id'] ?? ""} ${config.session.id}"),
          Text("${labels['id']?['profile'] ?? ""} ${config.session.id}"),
        ],
      ),
    );
  }
}
