/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';

// Custom code
import '../../../../../registry/app.dart'; 
import '../../../../../services/data/backup/manage_backup.dart';
class BackupRestore extends StatefulWidget {
  final Future<void> Function(String backupName)? onRestore;
  const BackupRestore({super.key, this.onRestore});

  @override
  State<BackupRestore> createState() => _BackupRestoreState();
}

class _BackupRestoreState extends State<BackupRestore> {
  bool _loadingBackups = false;
  bool _restoring = false;
  List<String> _backups = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    // Load local files on start
    _fetchLocalBackups();
  }

  Future<void> _fetchLocalBackups() async {
    if (!mounted) return;
    setState(() {
      _loadingBackups = true;
      _error = null;
    });

    try {
      final config = context.read<GlobalConfig>();
      final storage = ManageBackup(profileId: config.session.id ?? '');
      final keys = await storage.listBackupKeys();

      if (!mounted) return;
      setState(() {
        _backups = keys;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Error accessing local backups: $e';
      });
    } finally {
      if (mounted) {
        setState(() => _loadingBackups = false);
      }
    }
  }

  Future<void> _handleRestore(String backupName) async {
    setState(() => _restoring = true);
    try {
      if (widget.onRestore != null) {
        await widget.onRestore!(backupName);
      } else {
        await Future.delayed(const Duration(seconds: 1));
      }
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Backup "$backupName" restored!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Restore failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _restoring = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Available Local Backups',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadingBackups ? null : _fetchLocalBackups,
              tooltip: 'Refresh list',
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_loadingBackups)
          const Center(child: CircularProgressIndicator())
        else if (_error != null)
          Text(_error!, style: const TextStyle(color: Colors.red))
        else if (_backups.isEmpty)
          const Text('No local .zip backups found in this profile.')
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _backups.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final backup = _backups[index];
              return ListTile(
                leading: const Icon(Icons.folder_zip_outlined),
                title: Text(backup),
                subtitle: const Text('Local Storage'),
                trailing: _restoring
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : IconButton(
                        icon: const Icon(Icons.settings_backup_restore),
                        onPressed: () => _handleRestore(backup),
                      ),
              );
            },
          ),
      ],
    );
  }
}