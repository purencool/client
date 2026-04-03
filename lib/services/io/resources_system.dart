/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */

import 'dart:io';
import 'package:path/path.dart' as p;

// Custom Code
import 'file_node.dart';
import '../../../services/logging/logging.dart';

/// The blueprint for OS-level and application-level operations.
abstract class IOperational {
  Future<void> scanResources(String path);
  Future<dynamic> recentResources(String appName);
  Future<bool> saveResources(dynamic payload);
  Future<String> openResource(String type);
  Future<bool> saveResource(String type, dynamic payload);
  Future<bool> deleteResource(String resource);
  Future<bool> createResource(String resource);
}

class ResourcesSystem implements IOperational {
  final ILogging _logger;

  /// The constructor uses an initializer list (the part after the colon)
  /// to ensure all final variables are set before the object is fully created.
  ResourcesSystem({ILogging? logger}) : _logger = logger ?? Logging() {
    // Now that _logger is initialized, you can use it in the constructor body
    _logger.log(
      "ResourcesSystem successfully initialized.",
      level: LogLevel.info,
    );
  }

  // Internal singleton instance
  static ResourcesSystem? _instance;

  // Private constructor with logger injection
  ResourcesSystem._internal({ILogging? logger}) : _logger = logger ?? Logging();

  /// Access the singleton instance.
  static ResourcesSystem get instance {
    _instance ??= ResourcesSystem._internal();
    return _instance!;
  }

  /// Allows for manual initialization with a specific logger (ideal for tests).
  static void initialize(ILogging logger) {
    _instance = ResourcesSystem._internal(logger: logger);
  }

  @override
  Future<FileNode> scanResources(String path) async {
    final directory = Directory(path);
    _logger.log("Scanning directory tree: $path", level: LogLevel.info);

    if (!await directory.exists()) {
      _logger.log("Directory not found: $path", level: LogLevel.error);
      throw FileSystemException("Directory does not exist", path);
    }

    try {
      return await _buildTree(directory);
    } catch (e, stack) {
      _logger.log(
        "Failed to scan directory tree",
        level: LogLevel.error,
        error: e,
        stackTrace: stack,
      );
      rethrow;
    }
  }

  Future<FileNode> _buildTree(Directory root) async {
    final List<FileNode> children = [];

    try {
      // We list the directory contents.
      // We don't use recursive: true here because we want to build
      // the hierarchy manually into our FileNode objects.
      final List<FileSystemEntity> entities = await root.list().toList();

      // Sort entities: Directories first, then files alphabetically
      entities.sort((a, b) {
        if (a is Directory && b is! Directory) return -1;
        if (a is! Directory && b is Directory) return 1;
        return a.path.toLowerCase().compareTo(b.path.toLowerCase());
      });

      for (var entity in entities) {
        final name = p.basename(entity.path);

        if (entity is Directory) {
          // Recursive call to dive into sub-directories
          children.add(await _buildTree(entity));
        } else if (entity is File) {
          children.add(
            FileNode(name: name, path: entity.path, isDirectory: false),
          );
        }
      }
    } catch (e) {
      // Handle restricted folders/access denied errors gracefully
      _logger.log(
        "Access denied or error at ${root.path}",
        level: LogLevel.warning,
      );
    }

    return FileNode(
      name: p.basename(root.path),
      path: root.path,
      isDirectory: true,
      children: children,
    );
  }

  @override
  Future<dynamic> recentResources(String appName) async {
    _logger.log(
      "Retrieving tree structure for: $appName",
      level: LogLevel.debug,
    );

    return null;
  }

  @override
  Future<bool> saveResources(dynamic payload) async {
    _logger.log(
      "Committing tree structure update to vault.",
      level: LogLevel.info,
    );
    _logger.log("Tree Payload: $payload", level: LogLevel.debug);
    return true;
  }

  @override
  Future<String> openResource(String type) async {
    _logger.log("Fetching content for type: $type", level: LogLevel.debug);
    return type;
  }

  @override
  Future<bool> saveResource(String type, dynamic payload) async {
    _logger.log(
      "SWAT Operation: Committing $type content to persistence.",
      level: LogLevel.info,
    );
    return true;
  }

  @override
  Future<bool> deleteResource(String resource) async {
    _logger.log(
      "Delete secure deletion for asset: $resource",
      level: LogLevel.warning,
    );
    return true;
  }

  @override
  Future<bool> createResource(String resource) async {
    _logger.log(
      "Initiating secure creation for asset: $resource",
      level: LogLevel.warning,
    );
    return true;
  }
}
