/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */

import 'package:flutter/material.dart';

// Custom code
import '../../models/keybindings.dart';



class KeybindingsListeners {
  /// A global key to control the main app scaffold (e.g., for opening the drawer).
  /// This instance should remain constant so the Home widget doesn't crash on rebuild.
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  
  final List<GlobalKey<ScaffoldState>> _keyStack = [];

  KeybindingsListeners() {
    print("KeybindingsListeners initialized");
    Keybindings().menuToggleNotifier.addListener(() {
      // Use the active page's key if available, otherwise fallback to the Home key.
      final targetKey = _keyStack.isNotEmpty ? _keyStack.last : scaffoldKey;

      if (targetKey.currentState != null) {
        if (targetKey.currentState!.isDrawerOpen) {
          targetKey.currentState!.closeDrawer();
        } else {
          targetKey.currentState!.openDrawer();
        }
      }
    });
  }

  /// Temporarily replaces the global scaffold key with a local one.
  void pushKey(GlobalKey<ScaffoldState> key) {
    _keyStack.add(key);
  }

  /// Restores the previous scaffold key.
  void popKey() {
    if (_keyStack.isNotEmpty) {
      _keyStack.removeLast();
    }
  }

  /// Initializes the default configuration.
  Future<void> defaultConfig() async {
    Keybindings().initialize();
  }

  /// Initializes the default configuration.
  Future<void> dispose() async {
    Keybindings().dispose();
  }
}

final keybindings = KeybindingsListeners();
