/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */

import 'package:flutter/material.dart';

// Custom
import '../../../../layout/widgets/app_menu_item_styled.dart';

class TermsMenuItem extends StatelessWidget {
  final Map<String, dynamic> labels;
  const TermsMenuItem({super.key, required this.labels});

  @override
  Widget build(BuildContext context) {
    return AppMenuItemStyled(
      title: labels['terms']['menu_item'] ?? "",
      routeName: '/terms',
      textAlign: TextAlign.center,
    );
  }
}
