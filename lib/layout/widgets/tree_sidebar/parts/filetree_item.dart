/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:path/path.dart' as p;

class FileTreeItem extends StatelessWidget {
  final TreeNode<String> node;
  final bool isSelected;
  final TreeViewController<String, TreeNode<String>>? controller;
  final ValueChanged<TreeNode<String>> onNodeTap;

  const FileTreeItem({
    super.key,
    required this.node,
    required this.isSelected,
    required this.controller,
    required this.onNodeTap,
  });

  @override
  Widget build(BuildContext context) {
    final String path = node.data ?? "Open/create category";
    final String displayLabel = node.isLeaf 
        ? p.basenameWithoutExtension(path) 
        : p.basename(path);

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.arrowRight): () {
          if (!node.isLeaf && !node.isExpanded) controller?.expandNode(node);
        },
        const SingleActivator(LogicalKeyboardKey.arrowLeft): () {
          if (!node.isLeaf && node.isExpanded) controller?.collapseNode(node);
        },
      },
      child: Semantics(
        label: "$displayLabel, ${node.isLeaf ? 'file' : 'folder'}",
        selected: isSelected,
        child: Tooltip(
          message: path,
          waitDuration: const Duration(seconds: 1),
          child: ListTile(
            dense: true,
            visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
            contentPadding: EdgeInsets.only(
              left: 2.0 + (node.level - 1) * 0.25,
              right: 8,
            ),
            horizontalTitleGap: 2.0,
            minLeadingWidth: 20,
            leading: node.isLeaf
                ? const Icon(Icons.description_outlined, size: 18)
                : ChevronIndicator.rightDown(tree: node, color: Colors.grey),
            title: Text(
              displayLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13),
            ),
            selected: isSelected,
            selectedTileColor: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            onTap: () {
              if (!node.isLeaf) controller?.toggleExpansion(node);
              onNodeTap(node);
            },
          ),
        ),
      ),
    );
  }
}
