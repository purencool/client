/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as p;

/// Custom & BLoC
import '../bloc/notes_bloc.dart';
import '../../../registry/app.dart'; 
import '../../../layout/widgets/app_file_tree_sidebar.dart';
import '../../../layout/widgets/app_content_area.dart';

class Notes extends StatefulWidget {
  const Notes({super.key});

  @override
  State<Notes> createState() => _NotesState();
}

class _NotesState extends State<Notes> {
  // UI-ONLY STATE
  bool _isSidebarOpen = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Controllers remain here for performance (to avoid lag during typing)
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _workflowController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _categoryController.dispose();
    _workflowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NotesBloc()..add(LoadTreeRequested()),
      child: BlocListener<NotesBloc, NotesState>(
        // Update controllers only when the content in the state changes
        listenWhen: (prev, curr) => prev.selectedFileKey != curr.selectedFileKey,
        listener: (context, state) {
          _contentController.text = state.content;
          // Title logic...
        },
        child: BlocBuilder<NotesBloc, NotesState>(
          builder: (context, state) {
            return Scaffold(
              key: _scaffoldKey,
              body: Row(
                children: [
                  // SLIDING SIDEBAR
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: _isSidebarOpen ? 280 : 0,
                    child: AppFileTreeSidebar(
                      fileTree: state.fileTree,
                      selectedFileKey: state.selectedFileKey,
                      onNodeTap: (node) {
                        if (node.isLeaf) {
                          context.read<NotesBloc>().add(FileSelected(node));
                        }
                      },
                      onClose: () => setState(() => _isSidebarOpen = false),
                      onOpenDirectory: () => context.read<NotesBloc>().add(DirectoryPickerRequested()),
                    ),
                  ),

                  // CONTENT AREA
                  Expanded(
                    child: state.selectedFileKey == null
                        ? const Center(child: Text("Select a file from the explorer"))
                        : AppContentArea(
                            fileKey: state.selectedFileKey,
                            titleController: _titleController,
                            contentController: _contentController,
                            // Other controllers...
                          ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}