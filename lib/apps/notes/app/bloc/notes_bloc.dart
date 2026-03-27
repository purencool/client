/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */

import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:path/path.dart' as p;

// Events
abstract class NotesEvent {}

class LoadTreeRequested extends NotesEvent {}

class FileSelected extends NotesEvent {
  final TreeNode<String> node;
  FileSelected(this.node);
}

class DirectoryPickerRequested extends NotesEvent {}

// State
class NotesState {
  final TreeNode<String> fileTree;
  final String? selectedFileKey;
  final String title;
  final String content;
  final String category;
  final String workflow;
  final bool isLoading;

  NotesState({
    required this.fileTree,
    this.selectedFileKey,
    this.title = '',
    this.content = '',
    this.category = '',
    this.workflow = '',
    this.isLoading = false,
  });

  NotesState copyWith({
    TreeNode<String>? fileTree,
    String? selectedFileKey,
    String? title,
    String? content,
    String? category,
    String? workflow,
    bool? isLoading,
  }) {
    return NotesState(
      fileTree: fileTree ?? this.fileTree,
      selectedFileKey: selectedFileKey ?? this.selectedFileKey,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      workflow: workflow ?? this.workflow,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// Bloc
class NotesBloc extends Bloc<NotesEvent, NotesState> {
  NotesBloc() : super(NotesState(fileTree: TreeNode.root())) {
    on<LoadTreeRequested>(_onLoadTree);
    on<FileSelected>(_onFileSelected);
    on<DirectoryPickerRequested>(_onDirectoryPickerRequested);
  }

  Future<void> _onLoadTree(LoadTreeRequested event, Emitter<NotesState> emit) async {
    emit(state.copyWith(isLoading: true));
    // TODO: Implement logic to load the file tree from a service
  }

  Future<void> _onFileSelected(FileSelected event, Emitter<NotesState> emit) async {
    final String path = event.node.data ?? '';
    if (path.isNotEmpty && await File(path).exists()) {
      final content = await File(path).readAsString();
      emit(state.copyWith(
        selectedFileKey: event.node.key,
        title: p.basenameWithoutExtension(path),
        content: content,
      ));
    }
  }

  Future<void> _onDirectoryPickerRequested(DirectoryPickerRequested event, Emitter<NotesState> emit) async {
    // TODO: Implement directory picker logic
  }
}