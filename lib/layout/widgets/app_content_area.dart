/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:md_editor/md_editor.dart';
import 'app_category_input.dart';
import 'app_workflow_input.dart';
import '../../core/utility/format_and_print.dart';

enum _ViewMode { edit, split, preview }

class AppContentArea extends StatefulWidget {
  final String? fileKey;
  final ValueChanged<String>? onFileSelected;
  final TextEditingController titleController;
  final TextEditingController contentController;
  final TextEditingController categoryController;
  final TextEditingController workflowController;

  const AppContentArea({
    super.key,
    this.fileKey,
    this.onFileSelected,
    required this.titleController,
    required this.contentController,
    required this.categoryController,
    required this.workflowController,
  });

  @override
  State<AppContentArea> createState() => _AppContentAreaState();
}

class _AppContentAreaState extends State<AppContentArea> {
  double _editorRatio = 0.5;
  _ViewMode _viewMode = _ViewMode.split;
  final List<_EditorSession> _sessions = [];
  bool _isFullScreen = false;
  int _activeSessionIndex = 0;
  Timer? _debounceTimer;

  _EditorSession get _activeSession => _sessions[_activeSessionIndex];

  @override
  void initState() {
    super.initState();
    if (widget.fileKey != null) {
      // Create the very first session when the widget is first built.
      final newSession = _EditorSession.fromWidget(
        fileKey: widget.fileKey!,
        widget: widget,
      );
      newSession.titleController.addListener(_onContentChanged);
      newSession.contentController.addListener(_onContentChanged);
      _sessions.add(newSession);
      _activeSessionIndex = 0;
    }
  }

  @override
  void didUpdateWidget(AppContentArea oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.fileKey != null) {
      // This ensures that if the parent widget tells us to open a file,
      // we make sure it's open and active, even if it's the same fileKey as before.
      // This handles the case where a tab was closed internally and needs to be re-opened.
      _addOrActivateSession(widget);
    } else if (oldWidget.fileKey != null) {
      // The parent has cleared the selection.
      for (var session in _sessions) {
        session.dispose();
      }
      setState(() {
        _sessions.clear();
        _activeSessionIndex = 0;
      });
    }
  }

  void _addOrActivateSession(AppContentArea widget) {
    final existingIndex =
        _sessions.indexWhere((s) => s.fileKey == widget.fileKey);

    if (existingIndex >= 0) {
      // The file is already open in a tab, just switch to it.
      // CRITICAL FIX: Sync content from parent to session if it changed (e.g. async load).
      final session = _sessions[existingIndex];
      if (session.contentController.text != widget.contentController.text) {
        session.contentController.text = widget.contentController.text;
      }
      if (session.titleController.text != widget.titleController.text) {
        session.titleController.text = widget.titleController.text;
      }

      setState(() {
        _activeSessionIndex = existingIndex;
      });
      return;
    }

    // This is a new file, so create a new session (tab).
    final newSession = _EditorSession.fromWidget(
      fileKey: widget.fileKey!,
      widget: widget,
    );
    newSession.titleController.addListener(_onContentChanged);
    newSession.contentController.addListener(_onContentChanged);
    setState(() {
      _sessions.add(newSession);
      _activeSessionIndex = _sessions.length - 1;
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    for (var session in _sessions) {
      session.dispose();
    }
    super.dispose();
  }

  void _onContentChanged() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) setState(() {});
    });
  }

  Future<void> _handlePrint() async {
    await FormatAndPrint(
      _activeSession.titleController.text.isEmpty
          ? "Untitled"
          : _activeSession.titleController.text,
      _activeSession.contentController.text,
    ).print();
  }
  

  @override
  Widget build(BuildContext context) {
    if (_sessions.isEmpty) {
      return const Center(child: Text("No open files"));
    }

    return Padding(
      padding: _isFullScreen
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!_isFullScreen) _buildTabBar(),
          if (!_isFullScreen) const SizedBox(height: 8),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    if (_sessions.isEmpty) return const SizedBox.shrink();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _sessions.asMap().entries.map((entry) {
          final index = entry.key;
          final session = entry.value;
          final isActive = index == _activeSessionIndex;
          return GestureDetector(
            onTap: () {
              setState(() => _activeSessionIndex = index);
              
              // Sync the session content to the parent controllers before notifying.
              // This ensures that when the parent rebuilds with the new fileKey,
              // it passes the correct content back down, preventing the session 
              // from being overwritten by old data in _addOrActivateSession.
              widget.titleController.text = session.titleController.text;
              widget.contentController.text = session.contentController.text;
              widget.categoryController.text = session.categoryController.text;
              widget.workflowController.text = session.workflowController.text;

              if (widget.onFileSelected != null) {
                widget.onFileSelected!(session.fileKey);
              }
            },
            child: Tooltip(
              message: "tab: ${session.titleController.text.isEmpty ? "Untitled" : session.titleController.text}",
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                margin: const EdgeInsets.only(right: 4),
                child: Row(
                  children: [
                    Text(
                      session.titleController.text.isEmpty
                          ? "Untitled"
                          : session.titleController.text,
                      style: TextStyle(fontWeight: isActive ? FontWeight.bold : FontWeight.normal),
                    ),
                    if (_sessions.length > 1) ...[
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _closeSession(index),
                        child: Icon(Icons.close, size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _closeSession(int index) {
    final session = _sessions[index];
    session.dispose();
    setState(() {
      _sessions.removeAt(index);
      if (_sessions.isNotEmpty) {
        if (index < _activeSessionIndex) {
          _activeSessionIndex--;
        } else if (_activeSessionIndex >= _sessions.length) {
          // If we closed the active tab (or one after), and the index is now out of bounds
          _activeSessionIndex = _sessions.length - 1;
        }
      }
      // if _sessions is empty, build() will show "No open files"
    });
  }

  Widget _buildEditor() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Theme(
        data: Theme.of(context).copyWith(
          inputDecorationTheme: const InputDecorationTheme(
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
          ),
        ),
        child: MdEditor(
          key: ObjectKey(_activeSession),
          content: _activeSession.contentController.text,
          editable: true,
          onTextChanged: (text) {
            if (text != null && _activeSession.contentController.text != text) {
              _activeSession.contentController.text = text;
              if (widget.fileKey == _activeSession.fileKey) {
                widget.contentController.text = text;
              }
            }
          },
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!_isFullScreen)
          TextField(
            controller: _activeSession.titleController,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: "Title",
            ),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              onPressed: () => setState(() => _viewMode = _ViewMode.edit),
              icon: const Icon(Icons.edit),
              color: _viewMode == _ViewMode.edit
                  ? Theme.of(context).colorScheme.primary
                  : null,
              tooltip: 'Editor Only',
            ),
            IconButton(
              onPressed: () => setState(() => _viewMode = _ViewMode.split),
              icon: const Icon(Icons.vertical_split),
              color: _viewMode == _ViewMode.split
                  ? Theme.of(context).colorScheme.primary
                  : null,
              tooltip: 'Split View',
            ),
            IconButton(
              onPressed: () => setState(() => _viewMode = _ViewMode.preview),
              icon: const Icon(Icons.visibility),
              color: _viewMode == _ViewMode.preview
                  ? Theme.of(context).colorScheme.primary
                  : null,
              tooltip: 'Preview Only',
            ),
            IconButton(
              onPressed: _handlePrint,
              icon: const Icon(Icons.print),
              tooltip: 'Print',
            ),
            IconButton(
              onPressed: () => setState(() => _isFullScreen = !_isFullScreen),
              icon: Icon(_isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen),
              color: _isFullScreen ? Theme.of(context).colorScheme.primary : null,
              tooltip: _isFullScreen ? 'Exit Full Screen' : 'Full Screen',
            ),
          ],
        ),
        Expanded(
          child: _buildSessionView(),
        ),
        if (!_isFullScreen) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: AppCategoryInput(
                    controller: _activeSession.categoryController),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppWorkflowInput(
                    controller: _activeSession.workflowController),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildSessionView() {
    switch (_viewMode) {
      case _ViewMode.edit:
        return _buildEditor();
      case _ViewMode.preview:
        return _buildPreview();
      case _ViewMode.split:
        return LayoutBuilder(
          builder: (context, constraints) {
            const double gap = 20.0;
            final double resizableWidth = constraints.maxWidth - gap;
            final double editorWidth = resizableWidth * _editorRatio;

            return Stack(
              fit: StackFit.expand,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      width: editorWidth,
                      child: _buildEditor(),
                    ),
                    const SizedBox(width: gap),
                    Expanded(
                      child: _buildPreview(),
                    ),
                  ],
                ),
                Positioned(
                  left: editorWidth + (gap / 2) - 12, // Center handle in gap
                  bottom: -2,
                  child: GestureDetector(
                    onHorizontalDragUpdate: (details) {
                      setState(() {
                        _editorRatio = (_editorRatio +
                                (details.delta.dx / resizableWidth))
                            .clamp(0.1, 0.9);
                      });
                    },
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.drag_handle,
                        size: 16,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
    }
  }

  Widget _buildPreview() {
    return Container(
      color: Colors.grey[100],
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: GptMarkdown(
          _activeSession.contentController.text,
          key: ValueKey(_activeSession.contentController.text),
        ),
      ),
    );
  }
}

class _EditorSession {
  final String fileKey;
  final TextEditingController titleController;
  final TextEditingController contentController;
  final TextEditingController categoryController;
  final TextEditingController workflowController;

  // Private constructor that takes ownership of controllers.
  _EditorSession._({
    required this.fileKey,
    required this.titleController,
    required this.contentController,
    required this.categoryController,
    required this.workflowController,
  });

  // Factory to create a session with its own independent controllers,
  // initialized with the text from the parent widget's controllers.
  factory _EditorSession.fromWidget({
    required String fileKey,
    required AppContentArea widget,
  }) {
    final session = _EditorSession._(
      fileKey: fileKey,
      titleController: TextEditingController(text: widget.titleController.text),
      contentController: TextEditingController(text: widget.contentController.text),
      categoryController: TextEditingController(text: widget.categoryController.text),
      workflowController: TextEditingController(text: widget.workflowController.text),
    );

    return session;
  }

  void dispose() {
    titleController.dispose();
    contentController.dispose();
    categoryController.dispose();
    workflowController.dispose();
  }
}
