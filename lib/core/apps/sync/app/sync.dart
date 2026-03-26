/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */

import 'package:flutter/material.dart';

// Custom code
import '../../../../registry/app.dart';

import 'parts/sync_data.dart';
import 'parts/backup_create.dart';
import 'parts/backup_restore.dart';

class Sync extends StatefulWidget {
  const Sync({super.key});

  @override
  State<Sync> createState() => _SyncState();
}

class _SyncState extends State<Sync> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    keybindings.pushKey(_scaffoldKey);
  }

  @override
  void dispose() {
    keybindings.popKey();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final labels = context.labels['sync'] ?? {};

    if (!context.isAllowed('sync')) {
      return const AccessDenied();
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(title: Text(labels['title'] ?? "")),
      drawer: const AppMenu(),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: const [
          SyncData(),
          Divider(),
          BackupCreate(),
          Divider(),
          BackupRestore(),
        ],
      ),
    );
  }
}
