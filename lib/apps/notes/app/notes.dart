/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */


import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Custom & BLoC
import './bloc/notes_bloc.dart';
import '../../../registry/app.dart'; 
import '../../../layout/widgets/tree_sidebar/app_file_tree_sidebar.dart';
import '../../../layout/widgets/app_content_area.dart';

class Notes extends StatefulWidget {
  const Notes({super.key});

  @override
  State<Notes> createState() => _NotesState();
}

class _NotesState extends State<Notes> {
  bool _isSidebarOpen = true;
  String? _selectedFileKey;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
 // TreeNode<String> _fileTree = TreeNode.root();
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
    final labels = context.labels['notes'] ?? {};

    // Permission check
    if (!context.isAllowed('notes')) {
      return const AccessDenied();
    }

    return BlocProvider(
      create: (context) => NotesBloc()..add(LoadTreeRequested()),
      child: BlocListener<NotesBloc, NotesState>(
        listenWhen: (prev, curr) => prev.selectedFileKey != curr.selectedFileKey,
        listener: (context, state) {
          _contentController.text = state.content;
        },
        child: BlocBuilder<NotesBloc, NotesState>(
          builder: (context, state) {
            return Scaffold(
              key: _scaffoldKey,
              appBar: AppBar(
                title: Text(labels['title'] ?? ""),
                // Optional: You could also put a toggle here if preferred
              ),
              drawer: const AppMenu(),
              body: Row(
                children: [
                  // SLIDING SIDEBAR
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    width: _isSidebarOpen ? 280 : 0,
                    child: ClipRect( // Prevents overflow during animation
                      child: AppFileTreeSidebar(
                        fileTree: state.fileTree,
                        selectedFileKey: state.selectedFileKey,
                        onNodeTap: (node) {
                          if (node.isLeaf) {
                            context.read<NotesBloc>().add(FileSelected(node));
                          }
                        },
                        onClose: () => setState(() => _isSidebarOpen = false),
                        onOpenDirectory: () =>
                            context.read<NotesBloc>().add(DirectoryPickerRequested()),
                      ),
                    ),
                  ),

                  // CONTENT AREA
                  Expanded(
                    child: Stack(
                      children: [
                        // Main Content
                        Positioned.fill(
                          child: state.selectedFileKey == null
                              ? const Center(child: Text("Select a file from the explorer"))
                              : AppContentArea(
                                  fileKey: state.selectedFileKey, // Use state key
                                  titleController: _titleController,
                                  contentController: _contentController,
                                  categoryController: _categoryController,
                                  workflowController: _workflowController,
                                  onFileSelected: (key) {
                                    setState(() {
                                      _selectedFileKey = key;
                                    });
                                  },
                                ),
                        ),

                        // Sidebar Re-open Button (Visible only when sidebar is closed)
                        if (!_isSidebarOpen)
                          Positioned(
                            left: 0,
                            bottom: 15,
                            child: Material(
                              elevation: 4,
                              color: Theme.of(context).colorScheme.secondaryContainer,
                              borderRadius: const BorderRadius.horizontal(
                                right: Radius.circular(8),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.chevron_right),
                                onPressed: () => setState(() => _isSidebarOpen = true),
                                tooltip: "Open File Explorer",
                              ),
                            ),
                          ),
                      ],
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