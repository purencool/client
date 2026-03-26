/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */

import 'package:flutter/material.dart';

// Custom
import '../../../layout/widgets/app_menu_item.dart';

class NewsMenuItem extends StatelessWidget {
  final Map<String, dynamic> labels;
  const NewsMenuItem({super.key, required this.labels});

  @override
  Widget build(BuildContext context) {
    return AppMenuItem(
      permissionKey: 'news',
      icon: Icons.newspaper,
      title: labels['news']['menu_item'] ?? "",
      routeName: '/news',
    );
  }
}
