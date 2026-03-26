/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter/services.dart';


// Custom code
import '../../../../registry/app.dart';

/// The main dialog widget for the AI Chat.
class AiChatDialog extends StatefulWidget {
  final bool isPinned;
  final VoidCallback? onClose;
  final List<ChatMessage> messages;
  final Function(String) onSubmitted;
  final bool isLoading;

  const AiChatDialog({
    super.key,
    this.isPinned = false,
    this.onClose,
    required this.messages,
    required this.onSubmitted,
    this.isLoading = false,
  });

  @override
  State<AiChatDialog> createState() => _AiChatDialogState();
}

class _AiChatDialogState extends State<AiChatDialog>
    with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _inputFocusNode = FocusNode();
  late AnimationController _animationController;
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _lastWords = '';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _inputFocusNode.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void didUpdateWidget(AiChatDialog oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Scroll to the top (which is the newest message due to `reverse: true`) if new messages arrived.
    if (widget.messages.length > oldWidget.messages.length) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    }

    if (widget.isLoading != oldWidget.isLoading) {
      if (widget.isLoading) {
        _animationController.repeat(reverse: true);
      } else {
        _animationController.stop();
        _animationController.value = 0.0;
      }
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _inputFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) return;
    _textController.clear();
    widget.onSubmitted(text);
  }

  Future<void> _copyEntireChat() async {
    final chatContent = widget.messages
        .reversed // To get chronological order
        .map((msg) => "${msg.isUser ? 'You' : 'AI'}: ${msg.text}")
        .join('\n\n');

    if (chatContent.isEmpty) return;

    await Clipboard.setData(ClipboardData(text: chatContent));

    // Show a confirmation snackbar using the navigator's context
    final navigatorContext = aiKey.currentContext;
    if (navigatorContext != null && navigatorContext.mounted) {
      ScaffoldMessenger.of(navigatorContext).showSnackBar(
        const SnackBar(
          content: Text('Chat copied to clipboard!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _lastWords = val.recognizedWords;
            _textController.text = _lastWords;
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
      // If there's transcribed text, submit it
      if (_lastWords.isNotEmpty) {
        _handleSubmitted(_lastWords);
        _lastWords = '';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    //final labels = context.labels['ai'] ?? {};

    // Permission check
    if (!context.isAllowed('ai')) {
      return const AccessDenied();
    }

    // This widget now only returns its content. The parent is responsible
    // for how it's displayed (e.g., in a Dialog, a Positioned widget, etc.).
    return _buildChatContent(context);
  }

  Widget _buildChatContent(BuildContext context) {
    // The parent widget is now responsible for the container, elevation, and shape.
    // This widget just builds the core chat UI.
    return Column(
      children: [
        _buildAppBar(),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            reverse: true, // To show messages from bottom to top
            itemCount: widget.messages.length,
            itemBuilder: (context, index) {
              return ChatMessageWidget(message: widget.messages[index]);
            },
          ),
        ),
        const Divider(height: 1.0),
        _buildInputArea(),
      ],
    );
  }

  Widget _buildAppBar() {
    return Container(
      height: kToolbarHeight,
      padding: const EdgeInsets.only(right: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).appBarTheme.backgroundColor,
        // The parent Material widget with clipBehavior handles the border radius.
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Text(
            'AI Assistant',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: Theme.of(context).appBarTheme.foregroundColor),
          ),
          const Spacer(),
          IconButton(
            icon: Icon(Icons.copy_all_outlined,
                color: Theme.of(context).appBarTheme.foregroundColor),
            onPressed: _copyEntireChat,
            tooltip: widget.isPinned ? null : 'Copy entire chat',
          ),
          // Show close button for dialogs, or for pinned views that provide an onClose callback.
          // A pinned view without onClose is considered permanent.
          if (widget.onClose != null || !widget.isPinned) ...[
            IconButton(
              icon: Icon(Icons.remove,
                  color: Theme.of(context).appBarTheme.foregroundColor),
              onPressed: () {
                if (widget.onClose != null) {
                  widget.onClose!();
                } else {
                  Navigator.of(context).pop();
                }
              },
              tooltip: 'Minimize',
            ),
            IconButton(
              icon: Icon(Icons.close,
                  color: Theme.of(context).appBarTheme.foregroundColor),
              onPressed: () {
                if (widget.onClose != null) {
                  widget.onClose!();
                } else {
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: CallbackShortcuts(
              bindings: {
                const SingleActivator(LogicalKeyboardKey.enter): () =>
                    _handleSubmitted(_textController.text),
              },
              child: TextField(
                focusNode: _inputFocusNode,
                controller: _textController,
                onSubmitted: _handleSubmitted,
                textCapitalization: TextCapitalization.sentences,
                keyboardType: TextInputType.multiline,
                minLines: _inputFocusNode.hasFocus ? 3 : 1,
                maxLines: 6, // Allow the field to grow up to 6 lines, then scroll.
                decoration: const InputDecoration(
                  hintText: 'Type a message or use voice...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(_isListening ? Icons.mic_off : Icons.mic),
            onPressed: _listen,
            tooltip: widget.isPinned ? null : 'Voice Input',
          ),
          ScaleTransition(
            scale: _animationController.drive(Tween<double>(begin: 1.0, end: 0.8)),
            child: IconButton(
              icon: const Icon(Icons.send),
              onPressed: widget.isLoading
                  ? null
                  : () => _handleSubmitted(_textController.text),
            ),
          ),
        ],
      ),
    );
  }
}

/// Data model for a single chat message.
class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}

/// Widget to display a single chat message.
class ChatMessageWidget extends StatelessWidget {
  final ChatMessage message;

  const ChatMessageWidget({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            CircleAvatar(
              backgroundColor: theme.primaryColor,
              foregroundColor: theme.colorScheme.onPrimary,
              child: const Icon(Icons.smart_toy_outlined),
            ),
            const SizedBox(width: 8.0),
          ],
          Flexible( // Allows message bubble to take available space
            child: Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: message.isUser
                    ? theme.colorScheme.primaryContainer
                    : theme.colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: SelectableText(
                message.text,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: message.isUser
                      ? theme.colorScheme.onPrimaryContainer
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}