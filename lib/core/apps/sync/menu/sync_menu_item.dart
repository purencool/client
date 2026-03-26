/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */

import 'package:flutter/material.dart';

// Custom
import '../../../../layout/widgets/app_menu_item.dart';

class SyncMenuItem extends StatelessWidget {
  final Map<String, dynamic> labels;
  const SyncMenuItem({super.key, required this.labels});

  @override
  Widget build(BuildContext context) {
    return AppMenuItem(
      permissionKey: 'sync',
      icon: Icons.sync,
      title: labels['sync']['menu_item'] ?? "",
      routeName: '/sync',
    );
  }
}
