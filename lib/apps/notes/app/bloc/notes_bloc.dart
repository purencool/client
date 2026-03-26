/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */

import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as p;
import 'package:animated_tree_view/animated_tree_view.dart';

// --- Events ---
abstract class NotesEvent {}
class LoadTreeRequested extends NotesEvent {}
class DirectoryPickerRequested extends NotesEvent {}
class FileSelected extends NotesEvent {
  final TreeNode<String> node;
  FileSelected(this.node);
}

// --- States ---
class NotesState {
  final TreeNode<String> fileTree;
  final String? selectedFileKey;
  final String content;
  final bool isLoading;

  NotesState({
    required this.fileTree,
    this.selectedFileKey,
    this.content = "",
    this.isLoading = false,
  });

  NotesState copyWith({
    TreeNode<String>? fileTree,
    String? selectedFileKey,
    String? content,
    bool? isLoading,
  }) {
    return NotesState(
      fileTree: fileTree ?? this.fileTree,
      selectedFileKey: selectedFileKey ?? this.selectedFileKey,
      content: content ?? this.content,
      isLoading: isLoading ?? false,
    );
  }
}

// --- The BLoC ---
class NotesBloc extends Bloc<NotesEvent, NotesState> {
  NotesBloc() : super(NotesState(fileTree: TreeNode.root())) {
    on<LoadTreeRequested>(_onLoadTree);
    on<FileSelected>(_onFileSelected);
    // Note: DirectoryPicker logic would be triggered here via service
  }

  Future<void> _onLoadTree(LoadTreeRequested event, emit) async {
    emit(state.copyWith(isLoading: true));
    // In 2026, we fetch the tree from the Sovereign Vault/Service
    // final tree = await AppRegistry.instance.notesService.getTree();
    // emit(state.copyWith(fileTree: tree));
  }

  Future<void> _onFileSelected(FileSelected event, emit) async {
    final String path = event.node.data ?? '';
    if (path.isNotEmpty && await File(path).exists()) {
      final content = await File(path).readAsString();
      emit(state.copyWith(
        selectedFileKey: event.node.key,
        content: content,
      ));
    }
  }
}