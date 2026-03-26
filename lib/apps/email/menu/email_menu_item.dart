/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */

import 'package:flutter/material.dart';

// Custom
import '../../../layout/widgets/app_menu_item.dart';

class EmailMenuItem extends StatelessWidget {
  final Map<String, dynamic> labels;
  const EmailMenuItem({super.key, required this.labels});

  @override
  Widget build(BuildContext context) {
    return AppMenuItem(
      permissionKey: 'email',
      icon: Icons.email,
      title: labels['email']['menu_item'] ?? "",
      routeName: '/email',
    );
  }
}
