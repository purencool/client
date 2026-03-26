/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */

import 'package:flutter/material.dart';

// Custom code
import '../../../../../registry/app.dart'; 
import '../../../../../services/data/backup/create_backup.dart';

class BackupCreate extends StatelessWidget {
  final VoidCallback? onSuccess;

  const BackupCreate({
    super.key, 
    this.onSuccess,
  });

Future<void> _handleBackup(BuildContext context) async {
  final config = context.configRead;
  final String? profileId = config.session.id;

  if (profileId == null || profileId.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error: No Profile ID found.')),
    );
    return;
  }

  final creator = CreateBackup(profileId: profileId);

  try {
    final path = await creator.create(); 
    
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Backup created at: $path')),
    );
    
    if (onSuccess != null) onSuccess!();
  } catch (e) {
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to create backup: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.backup),
      label: const Text('Create Backup'),
      onPressed: () => _handleBackup(context),
    );
  }
}