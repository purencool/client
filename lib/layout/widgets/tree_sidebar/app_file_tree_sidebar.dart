/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */

import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:animated_tree_view/animated_tree_view.dart';

// Custom Parts
import 'parts/sidebar_header.dart';
import 'parts/filetree_item.dart';
import 'parts/sidebar_resizer.dart';
import 'parts/sidebar_search.dart';
import 'parts/file_tree_utils.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/swat/swat/swat_bloc.dart';
import '../../../core/swat/swat/swat_state.dart';



class AppFileTreeSidebar extends StatefulWidget {
  final TreeNode<String> fileTree;
  final String? selectedFileKey;
  final VoidCallback onClose;
  final VoidCallback? onNewFolder;
  final VoidCallback? onNewFile;
  final VoidCallback? onOpenRecent;
  final VoidCallback? onOpenDirectory;
  final ValueChanged<TreeNode<String>> onNodeTap;

  const AppFileTreeSidebar({
    super.key,
    required this.fileTree,
    required this.selectedFileKey,
    required this.onClose,
    this.onNewFolder,
    this.onNewFile,
    this.onOpenRecent,
    this.onOpenDirectory,
    required this.onNodeTap,
  });

  @override
  State<AppFileTreeSidebar> createState() => _AppFileTreeSidebarState();
}

class _AppFileTreeSidebarState extends State<AppFileTreeSidebar> {
  TreeViewController<String, TreeNode<String>>? _controller;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _horizontalScrollController = ScrollController();
  
  late TreeNode<String> _displayTree;

  // State for resizable sidebar width
  double _sidebarWidth = 280.0;
  static const double _minSidebarWidth = 150.0;
  static const double _maxSidebarWidth = 600.0;

  @override
  void initState() {
    super.initState();
    _displayTree = widget.fileTree;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void didUpdateWidget(AppFileTreeSidebar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fileTree != widget.fileTree) {
      _onSearchChanged();
    }
  }

  void _onSearchChanged() {
    setState(() {
      _displayTree = FileTreeUtils.filterTree(widget.fileTree, _searchController.text);
      if (_searchController.text.isNotEmpty) {
        _controller?.expandAllChildren(_displayTree);
      }
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _sidebarWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Reusable Header
          SidebarHeader(
            title: "EXPLORER",
            onClose: widget.onClose,
            onNewFolder: widget.onNewFolder,
            onNewFile: widget.onNewFile,
            onOpenDirectory: widget.onOpenDirectory,
          ),

          // 2. Reusable Search & Toolbar
          SidebarSearch(
            controller: _searchController,
            onExpandAll: () =>
                _controller?.expandAllChildren(_displayTree, recursive: true),
            onCollapseAll: () =>
                FileTreeUtils.collapseAll(_controller, _displayTree),
          ),

          const Divider(height: 1),

          // 3. Main Tree Content
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final requiredWidth = math.max(
                  constraints.maxWidth,
                  FileTreeUtils.calculateMaxScrollWidth(
                    _displayTree,
                    _displayTree.level,
                  ),
                );

                return Scrollbar(
                  controller: _horizontalScrollController,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    controller: _horizontalScrollController,
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: requiredWidth,
                      child: TreeView.simple(
                        key: ValueKey(_searchController.text + _displayTree.children.length.toString()),
                        tree: _displayTree,
                        onTreeReady: (c) => _controller = c,
                        builder: (context, node) => FileTreeItem(
                          node: node,
                          isSelected: widget.selectedFileKey == node.key,
                          controller: _controller,
                          onNodeTap: widget.onNodeTap,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // 4. Reusable Resize Handle
          SidebarResizer(
            onDrag: (details) {
              setState(() {
                _sidebarWidth = (_sidebarWidth + details.delta.dx).clamp(
                  _minSidebarWidth,
                  _maxSidebarWidth,
                );
              });
            },
          ),
        ],
      ),
    );
  }
}
