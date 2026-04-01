import 'package:equatable/equatable.dart';

class FileNode extends Equatable {
  final String name;
  final String path;
  final bool isDirectory;
  final List<FileNode> children;

  const FileNode({
    required this.name,
    required this.path,
    required this.isDirectory,
    this.children = const [],
  });

  /// Recursively counts all nodes in this branch
  int get totalNodeCount {
    int count = 1; // Count this node
    for (var child in children) {
      count += child.totalNodeCount;
    }
    return count;
  }

  @override
  List<Object?> get props => [name, path, isDirectory, children];
}
