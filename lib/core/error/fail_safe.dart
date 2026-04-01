/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */

import 'dart:developer' as dev;

enum ClientFailure { scrubError, vaultError, residencyError, auditError }

class ClientFailSafe {
  /// The global "Panic" state. If true, all external traffic is blocked.
  static bool _isSystemLocked = false;
  static bool get isSystemLocked => _isSystemLocked;

  /// Clinical Trigger: Immediately halts the "Pipe" and "Vault".
  static void triggerKillSwitch(ClientFailure reason, String context) {
    _isSystemLocked = true;

    dev.log(
      '[CRITICAL_FAILURE] System Locked: ${reason.name.toUpperCase()}',
      name: 'Sovereign.Core.Security',
      error: context,
    );

    //TODO: Add logic to notify the BLoC to show a "Secure Lockdown" UI.
  }

  /// Reset Protocol: Requires manual/admin re-authentication (planned for Week 04).
  static void clearLockdown() {
    _isSystemLocked = false;
  }
}
