/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */

import 'package:flutter/material.dart';

class SyncData extends StatefulWidget {
  final VoidCallback? onSync;

  const SyncData({super.key, this.onSync});

  @override
  State<SyncData> createState() => _SyncState();
}

class _SyncState extends State<SyncData> {
  bool _syncing = false;

  Future<void> _handleSync() async {
    setState(() => _syncing = true);

    try {
      // Call the callback if provided
      if (widget.onSync != null) {
        widget.onSync!();
      }
      // Simulate sync delay
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Sync completed!')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sync failed: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _syncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: _syncing
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.sync),
        label: const Text('Sync to the cloud'),
        onPressed: _syncing ? null : _handleSync,
      ),
    );
  }
}
