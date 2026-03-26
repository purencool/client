/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */

import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:path/path.dart' as p;

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

  // State for resizable sidebar width
  double _sidebarWidth = 280.0;
  static const double _minSidebarWidth = 150.0;
  static const double _maxSidebarWidth = 600.0;

  @override
  void dispose() {
    _searchController.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
  }

  /// Recursively collapses all nodes in the tree.
  void _collapseAll(TreeNode<String> node) {
    if (_controller == null) return;
    // We perform a post-order traversal to collapse nodes from the leaves up.
    // This ensures that parent nodes are collapsed after their children.
    for (final child in node.children.values) {
      _collapseAll(child as TreeNode<String>);
    }
    if (node.isExpanded) {
      _controller!.collapseNode(node);
    }
  }

  double _calculateMaxScrollWidth(TreeNode<String> node, int level) {
    double maxWidth = 0.0;
    final String path = node.data ?? "Open/create category";
    final String displayLabel = node.isLeaf
        ? p.basenameWithoutExtension(path)
        : p.basename(path);

    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: displayLabel, style: const TextStyle(fontSize: 13)),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();
    
    final double indent = 2.0 + ((level - 1) * 0.25);
    final double iconWidth = 32.0;
    final double currentWidth = indent + iconWidth + textPainter.width + 24.0;
    if (currentWidth > maxWidth) maxWidth = currentWidth;

    // 2. Recursively check children
    for (final child in node.children.values) {
      final double childWidth = _calculateMaxScrollWidth(child as TreeNode<String>, level + 1);
      if (childWidth > maxWidth) maxWidth = childWidth;
    }
    return maxWidth;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _sidebarWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Sidebar Header with Close Button
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
            color: Theme.of(context).colorScheme.surface,
            child: Row(
              children: [
                Text(
                  "EXPLORER",
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                ),
                const Spacer(),
                _SidebarAction(
                  icon: Icons.folder_open,
                  tooltip: "Open Directory",
                  onPressed: widget.onOpenDirectory,
                ),
                _SidebarAction(
                  icon: Icons.create_new_folder,
                  tooltip: "New Folder",
                  onPressed: widget.onNewFolder,
                ),
                _SidebarAction(
                  icon: Icons.note_add,
                  tooltip: "New File",
                  onPressed: widget.onNewFile,
                ),
                _SidebarAction(
                  icon: Icons.menu_open,
                  tooltip: "Close Sidebar",
                  onPressed: widget.onClose,
                ),
              ],
            ),
          ),
          // Search and Toolbar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 32,
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        prefixIcon: const Icon(Icons.search, size: 16),
                        contentPadding: EdgeInsets.zero,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.05),
                      ),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                _SidebarAction(
                  icon: Icons.unfold_more,
                  tooltip: "Expand All",
                  onPressed: () => _controller
                      ?.expandAllChildren(widget.fileTree, recursive: true),
                ),
                _SidebarAction(
                  icon: Icons.unfold_less,
                  tooltip: "Collapse All",
                  onPressed: () => _collapseAll(widget.fileTree),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: LayoutBuilder(builder: (context, constraints) {
              // Calculate required width based on actual text width
              final requiredWidth = math.max(
                  constraints.maxWidth,
                  _calculateMaxScrollWidth(
                      widget.fileTree, widget.fileTree.level));

              return Scrollbar(
                controller: _horizontalScrollController,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  controller: _horizontalScrollController,
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: requiredWidth,
                    child: TreeView.simple(
                      key: ObjectKey(widget.fileTree),
                      tree: widget.fileTree,
                      onTreeReady: (controller) {
                        _controller = controller;
                      },
                      expansionIndicatorBuilder: (context, node) =>
                          ChevronIndicator.rightDown(
                        tree: node,
                        padding: EdgeInsets.zero,
                        color: Colors.transparent,
                      ),
                      builder: (context, node) {
                        final String path =
                            node.data ?? "Open/create category";
                        final String displayLabel = node.isLeaf
                            ? p.basenameWithoutExtension(path)
                            : p.basename(path);

                        return CallbackShortcuts(
                          bindings: {
                            const SingleActivator(
                                LogicalKeyboardKey.arrowRight): () {
                              if (!node.isLeaf && !node.isExpanded) {
                                _controller?.expandNode(node);
                              }
                            },
                            const SingleActivator(
                                LogicalKeyboardKey.arrowLeft): () {
                              if (!node.isLeaf && node.isExpanded) {
                                _controller?.collapseNode(node);
                              }
                            },
                          },
                          child: Semantics(
                            label:
                                "$displayLabel, ${node.isLeaf ? 'file' : 'folder'}",
                            selected: widget.selectedFileKey == node.key,
                            child: Tooltip(
                              message: path, // Full path on hover
                              waitDuration: const Duration(seconds: 1),
                              child: ListTile(
                                dense: true,
                                visualDensity: const VisualDensity(
                                    horizontal: 0, vertical: -4),
                                contentPadding: EdgeInsets.only(
                                  left: 2.0 + (node.level - 1) * 0.25,
                                  right: 8,
                                ),
                                horizontalTitleGap: 2.0,
                                minLeadingWidth: 20,
                                leading: node.isLeaf
                                    ? const Icon(Icons.description_outlined,
                                        size: 18)
                                    : ChevronIndicator.rightDown(
                                        tree: node,
                                        color: Colors.grey,
                                        padding: EdgeInsets.zero,
                                      ),
                                title: Text(
                                  displayLabel,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 13),
                                ),
                                selected: widget.selectedFileKey == node.key,
                                selectedTileColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer
                                    .withOpacity(0.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                onTap: () {
                                  if (!node.isLeaf) {
                                    _controller?.toggleExpansion(node);
                                  }
                                  widget.onNodeTap(node);
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            }),
          ),
          MouseRegion(
            cursor: SystemMouseCursors.resizeLeftRight,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragUpdate: (details) {
                setState(() {
                  _sidebarWidth = (_sidebarWidth + details.delta.dx)
                      .clamp(_minSidebarWidth, _maxSidebarWidth);
                });
              },
              child: Container(
                height: 24.0,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  border: Border(
                    top: BorderSide(color: Theme.of(context).dividerColor),
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.drag_indicator,
                    size: 16,
                    color: Theme.of(context).iconTheme.color?.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarAction extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  const _SidebarAction({
    required this.icon,
    required this.tooltip,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 18),
      tooltip: tooltip,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      padding: EdgeInsets.zero,
      onPressed: onPressed ?? () {},
    );
  }
}