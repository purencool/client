/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */

import 'package:flutter/material.dart';

// Custom
import '../../../layout/widgets/app_menu_item.dart';

class DocumentsMenuItem extends StatelessWidget {
  final Map<String, dynamic> labels;
  const DocumentsMenuItem({super.key, required this.labels});

  @override
  Widget build(BuildContext context) {
    return AppMenuItem(
      permissionKey: 'documents',
      icon: Icons.description,
      title: labels['documents']['menu_item'] ?? "",
      routeName: '/documents',
    );
  }
}
