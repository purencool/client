/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:path/path.dart' as p;

/// Custom
import '../../../registry/app.dart'; 

import '../../../layout/widgets/app_file_tree_sidebar.dart';
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
  TreeNode<String> _fileTree = TreeNode.root();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _workflowController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Temporarily take over the global keybinding key
    keybindings.pushKey(_scaffoldKey);
    _loadFileTree();
  }

  @override
  void dispose() {
    keybindings.popKey();
    _titleController.dispose();
    _contentController.dispose();
    _categoryController.dispose();
    _workflowController.dispose();
    super.dispose();
  }

  Future<void> _loadFileTree() async {
    final tree = await appData.getTree('notes');
    if (mounted) {
      setState(() {
        _fileTree = tree;
      });
    }
  }

  Future<void> _pickDirectory() async {
    final String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      final dir = Directory(selectedDirectory);
      if (await dir.exists()) {
        final newTree = await _buildFileTree(dir);
        if (mounted) {
          setState(() {
            _fileTree = newTree;
            _selectedFileKey = null;
            _titleController.clear();
            _contentController.clear();
          });
        }
      }
    }
  }

  Future<TreeNode<String>> _buildFileTree(Directory dir) async {
    final root = TreeNode<String>.root(data: p.basename(dir.path));
    await _populateNode(root, dir);
    return root;
  }

  Future<void> _populateNode(TreeNode<String> parent, Directory dir) async {
    try {
      final List<FileSystemEntity> entities = await dir.list().toList();
      // Sort directories first, then files
      entities.sort((a, b) {
        if (a is Directory && b is File) return -1;
        if (a is File && b is Directory) return 1;
        return p.basename(a.path).toLowerCase().compareTo(p.basename(b.path).toLowerCase());
      });

      for (final entity in entities) {
        final name = p.basename(entity.path);
        if (name.startsWith('.')) continue; // Skip hidden files

        if (entity is Directory) {
          final dirNode = TreeNode<String>(key: entity.path.replaceAll('.', '_'), data: entity.path);
          await _populateNode(dirNode, entity);
          if (dirNode.children.isNotEmpty) parent.add(dirNode);
        } else if (entity is File && name.toLowerCase().endsWith('.md')) {
          parent.add(TreeNode<String>(key: entity.path.replaceAll('.', '_'), data: entity.path));
        }
      }
    } catch (e) {
      debugPrint("Error populating file tree node: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final labels = context.labels['notes'] ?? {};

    // Permission check
    if (!context.isAllowed('notes')) {
      return const AccessDenied();
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(title: Text(labels['title'] ?? "")),
      drawer: const AppMenu(),
      body: Row(
        children: [
          // Sliding Sidebar
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: _isSidebarOpen ? 280 : 0,
            curve: Curves.easeInOut,
            child: ClipRect(
              child: OverflowBox(
                minWidth: 280,
                maxWidth: 280,
                alignment: Alignment.topLeft,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    border: const Border(
                      right: BorderSide(color: Colors.black12),
                    ),
                  ),
                  child: AppFileTreeSidebar(
                    fileTree: _fileTree,
                    selectedFileKey: _selectedFileKey,
                    onClose: () => setState(() => _isSidebarOpen = false),
                    onOpenRecent: () {},
                    onOpenDirectory: _pickDirectory,
                    onNewFolder: () {},
                    onNodeTap: (node) async {
                      if (!node.isLeaf) {
                        // If a directory is tapped, we only want the tree view to
                        // handle the expansion/collapse. We do not want to change
                        // the currently displayed content.
                        return; // Do nothing.
                      }

                      String content = "";
                      final String path = node.data ?? '';
                      if (path.isNotEmpty && await File(path).exists()) {
                        content = await File(path).readAsString();
                      }

                      if (mounted) {
                        setState(() {
                          _selectedFileKey = node.key;
                          _titleController.text =
                              p.basenameWithoutExtension(path.isEmpty ? "Untitled" : path);
                          _contentController.text = content;
                        });
                      }
                    },
                  ),
                ),
              ),
            ),
          ),

          // Content Area with Overlay Toggle
          Expanded(
            child: Stack(
              children: [
                // Main Content
                Positioned.fill(
                  child: _selectedFileKey == null
                      ? const Center(
                          child: Text("Select a file from the explorer"),
                        )
                      : AppContentArea(
                          fileKey: _selectedFileKey,
                          titleController: _titleController,
                          contentController: _contentController,
                          categoryController: _categoryController,
                          workflowController: _workflowController,
                          onFileSelected: (key) {
                            setState(() {
                              _selectedFileKey = key;
                              // Controllers are already updated by AppContentArea before calling this
                            });
                          },
                        ),
                ),

                // Toggle button that appears ONLY when sidebar is closed
                if (!_isSidebarOpen)
                  Positioned(
                    left: 10,
                    top: 10,
                    child: IconButton.filledTonal(
                      icon: const Icon(Icons.menu),
                      onPressed: () => setState(() => _isSidebarOpen = true),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
