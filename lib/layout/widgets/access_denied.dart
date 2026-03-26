/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */

import 'package:flutter/material.dart';

// Custom code
import '../../registry/app.dart'; 

class AccessDenied extends StatelessWidget {
  const AccessDenied({super.key});

  @override
  Widget build(BuildContext context) {
    final labels = context.labels['access_denied'] ?? {};

    return Scaffold(
      appBar: AppBar(title: Text(labels['title'] ?? "")),
      drawer: AppMenu(),
      body: Center(child: Text(labels['description'] ?? "")),
    );
  }
}
