/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */

import 'package:flutter/material.dart';

// Custom
import '../../registry/app.dart'; 
import '../../registry/menu.dart'; 

class AppMenu extends StatelessWidget {
  const AppMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final labels = context.labels;
    return Drawer(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            child: Text(labels['menu']['main_menu']['title'] ?? ""),
          ),
          ...menuRegistry.values.map((builder) => builder(labels)),
        ],
      ),
    );
  }
}
