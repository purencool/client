/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class Keybindings {
  // Singleton pattern for global access
  static final Keybindings _instance = Keybindings._internal();
  factory Keybindings() => _instance;
  Keybindings._internal();

  // Notifier to signal a menu toggle event from a global key press.
  final ValueNotifier<int> menuToggleNotifier = ValueNotifier(0);

  void initialize() {
    HardwareKeyboard.instance.addHandler(_handleKeyEvent);
  }

  bool _handleKeyEvent(KeyEvent event) {
    // Handle key down events for combinations.
    if (event is KeyDownEvent) {
      final bool isControlPressed = HardwareKeyboard.instance.isControlPressed;
      final bool isMetaPressed = HardwareKeyboard.instance.isMetaPressed;

      // CTRL/CMD + M to toggle the global menu.
      if ((isControlPressed || isMetaPressed) &&
          event.logicalKey == LogicalKeyboardKey.keyM) {  
        menuToggleNotifier.value++;
        return true;
      }

      // CTRL/CMD + Q to quit the application.
      if ((isControlPressed || isMetaPressed) &&
          event.logicalKey == LogicalKeyboardKey.keyQ) {
        SystemNavigator.pop();
        return true;
      }
    }

    return false;
  }
  
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
  }
}
