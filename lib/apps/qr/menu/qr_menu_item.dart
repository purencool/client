/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */

import 'package:flutter/material.dart';

// Custom
import '../../../layout/widgets/app_menu_item.dart';

class QrMenuItem extends StatelessWidget {
  final Map<String, dynamic> labels;
  const QrMenuItem({super.key, required this.labels});

  @override
  Widget build(BuildContext context) {
    return AppMenuItem(
      permissionKey: 'qr',
      icon: Icons.qr_code_scanner_outlined,
      title: labels['qr']['menu_item'] ?? "",
      routeName: '/qr',
    );
  }
}
