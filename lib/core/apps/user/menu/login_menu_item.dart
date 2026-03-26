/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */

import 'package:flutter/material.dart';

// Custom code imports
import '../../../../registry/app.dart';
import '../../../../services/authentication.dart';
import './parts/login_form.dart';
import './parts/user_session_view.dart';

class LoginMenuItem extends StatefulWidget {
  final Map<String, dynamic> labels;
  const LoginMenuItem({super.key, required this.labels});

  @override
  State<LoginMenuItem> createState() => _LoginMenuItemState();
}

class _LoginMenuItemState extends State<LoginMenuItem> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  bool _loading = false;

  void _showError(String message) {

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _handleLogin() async {
    setState(() => _loading = true);

    try {
      await Authentication().signIn(_userController.text, _passController.text);
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _handleLogout() async {
    Authentication().logout();
    _userController.clear();
    _passController.clear();

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Logged Out')));
    }
  }

  @override
  void dispose() {
    _userController.dispose();
    _passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!context.isAuthenticated) {
      return LoginForm(
        userController: _userController,
        passController: _passController,
        isLoading: _loading,
        onLogin: _handleLogin,
      );
    }

    return UserSessionView(onLogout: _handleLogout);
  }
}
