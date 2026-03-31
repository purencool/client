import 'package:flutter/material.dart';
import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:path/path.dart' as p;

class FileTreeUtils {
  /// Recursively collapses all nodes in the tree.
  static void collapseAll(
    TreeViewController<String, TreeNode<String>>? controller, 
    TreeNode<String> node
  ) {
    if (controller == null) return;
    
    for (final child in node.children.values) {
      collapseAll(controller, child as TreeNode<String>);
    }
    
    if (node.isExpanded) {
      controller.collapseNode(node);
    }
  }

  /// Returns a new tree containing only nodes that match the query
  /// or have children that match the query.
  static TreeNode<String> filterTree(TreeNode<String> node, String query) {
    // Create a copy of the current node
    final newNode = TreeNode<String>(key: node.key, data: node.data);
    
    if (query.isEmpty) return node;

    final lowercaseQuery = query.toLowerCase();
    
    for (final child in node.children.values) {
      final filteredChild = filterTree(child as TreeNode<String>, query);
      
      // If the child matches OR the child's subtree has matches, add it
      final nodePath = child.data?.toLowerCase() ?? "";
      if (nodePath.contains(lowercaseQuery) || filteredChild.children.isNotEmpty) {
        newNode.add(filteredChild);
      }
    }
    return newNode;
  }

  /// Calculates the maximum width required for horizontal scrolling based on node depth and text.
  static double calculateMaxScrollWidth(TreeNode<String> node, int level) {
    double maxWidth = 0.0;
    final String path = node.data ?? "Open/create category";
    final String displayLabel = node.isLeaf
        ? p.basenameWithoutExtension(path)
        : p.basename(path);

    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: displayLabel, 
        style: const TextStyle(fontSize: 13),
      ),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();

    final double indent = 2.0 + ((level - 1) * 0.25);
    final double iconWidth = 32.0;
    final double currentWidth = indent + iconWidth + textPainter.width + 24.0;
    
    if (currentWidth > maxWidth) maxWidth = currentWidth;

    for (final child in node.children.values) {
      final double childWidth = calculateMaxScrollWidth(
        child as TreeNode<String>, 
        level + 1,
      );
      if (childWidth > maxWidth) maxWidth = childWidth;
    }
    
    return maxWidth;
  }
}
