/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */

import 'package:flutter/material.dart';

class AppWorkflowInput extends StatelessWidget {
  final TextEditingController controller;

  const AppWorkflowInput({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: "Workflow",
        border: OutlineInputBorder(),
      ),
    );
  }
}