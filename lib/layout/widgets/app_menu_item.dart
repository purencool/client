/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */

import 'package:flutter/material.dart';

// Custom
import '../../registry/app.dart'; 

class AppMenuItem extends StatelessWidget {
  final String? permissionKey;
  final IconData icon;
  final String title;
  final String routeName;

  const AppMenuItem({
    super.key,
    required this.permissionKey,
    required this.icon,
    required this.title,
    required this.routeName,
  });

  @override
  Widget build(BuildContext context) {
    final result = context.isAllowed(permissionKey ?? '');
    if (!result) {
      return const SizedBox.shrink();
    }

    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        Navigator.pushReplacementNamed(context, routeName);
      },
    );
  }
}
