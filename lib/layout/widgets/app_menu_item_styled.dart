/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */

import 'package:flutter/material.dart';

class AppMenuItemStyled extends StatelessWidget {
  final String title;
  final String routeName;
  final TextStyle? style;
  final TextAlign textAlign;

  const AppMenuItemStyled({
    super.key,
    required this.title,
    required this.routeName,
    this.style,
    this.textAlign = TextAlign.start,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title, style: style, textAlign: textAlign),
      onTap: () {
        Navigator.pop(context);
        Navigator.pushReplacementNamed(context, routeName);
      },
    );
  }
}
