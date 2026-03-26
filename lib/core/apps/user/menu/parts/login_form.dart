/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */

import 'package:flutter/material.dart';
import '../../../../../registry/app.dart'; 

class LoginForm extends StatelessWidget {
  final TextEditingController userController;
  final TextEditingController passController;
  final bool isLoading;
  final VoidCallback onLogin;

  const LoginForm({
    super.key,
    required this.userController,
    required this.passController,
    required this.isLoading,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    final labels = context.labels['user'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        children: [
          const Divider(),
          TextField(
            controller: userController,
            decoration: InputDecoration(
              labelText: labels?['username'] ?? 'Username',
              prefixIcon: const Icon(Icons.person, size: 20),
            ),
          ),
          TextField(
            controller: passController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: labels?['password'] ?? 'Password',
              prefixIcon: const Icon(Icons.lock, size: 20),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoading ? null : onLogin,
              child: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(labels?['login_button'] ?? 'Login'),
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }
}