/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */

import 'package:flutter/material.dart';
import 'package:animated_tree_view/animated_tree_view.dart';

/// Custom
import '../../../../registry/app.dart';

class Ai extends StatefulWidget {
  const Ai({super.key});

  @override
  State<Ai> createState() => _AiState();
}

class _AiState extends State<Ai> {
  bool _isSidebarOpen = true;
  String? _selectedChatKey;
  int _chatCounter = 0;

  final Map<String, List<_ChatMessage>> _chatSessions = {};
  final TreeNode<String> _chatListTree = TreeNode.root();

  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Local unique key for this page's Scaffold
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // Register this key so Ctrl+M targets this page
    keybindings.pushKey(_scaffoldKey);
    _addNewChat(); // Start with one chat session
  }

  @override
  void dispose() {
    // Unregister the key
    keybindings.popKey();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addNewChat() {
    setState(() {
      _chatCounter++;
      final key = DateTime.now().millisecondsSinceEpoch.toString();
      final chatName = "Chat $_chatCounter";
      _chatListTree.add(TreeNode(key: key, data: chatName));
      _chatSessions[key] = [
        _ChatMessage(text: "Hello! How can I assist you today?", isUser: false),
      ];
      _selectedChatKey = key;
    });
  }

  void _addMessage(
    String text, {
    required bool isUser,
    required String chatKey,
  }) {
    setState(() {
      _chatSessions[chatKey]?.insert(
        0,
        _ChatMessage(text: text, isUser: isUser),
      );
    });
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _handleSubmitted(String text) async {
    if (text.trim().isEmpty || _selectedChatKey == null) return;

    // Capture the current chat key locally. This ensures that if the user switches
    // to a different chat while waiting for the AI response, the incoming message
    // is still added to the correct (original) conversation history.
    final currentChatKey = _selectedChatKey!;
    _textController.clear();
    _addMessage(text, isUser: true, chatKey: currentChatKey);

    try {
      final aiResponse = await aiRequests.getResponse(text);
      _addMessage(aiResponse, isUser: false, chatKey: currentChatKey);
    } catch (e) {
      // The provider layer is responsible for logging the full error.
      // We just need to show a user-friendly message.
      _addMessage(
        "An error occurred: $e",
        isUser: false,
        chatKey: currentChatKey,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final labels = context.labels['ai'] ?? {};

    // Permission check
    if (!context.isAllowed('ai')) {
      return const AccessDenied();
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(title: Text(labels['title'] ?? "")),
      drawer: const AppMenu(),
      body: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: _isSidebarOpen ? 280 : 0,
            curve: Curves.easeInOut,
            child: ClipRect(
              child: OverflowBox(
                minWidth: 280,
                maxWidth: 280,
                alignment: Alignment.topLeft,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    border: const Border(
                      right: BorderSide(color: Colors.black12),
                    ),
                  ),
                  child: _buildChatListSidebar(),
                ),
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: _selectedChatKey == null
                      ? const Center(child: Text("Select or create a chat"))
                      : _buildChatContentArea(),
                ),
                if (!_isSidebarOpen)
                  Positioned(
                    left: 10,
                    top: 10,
                    child: IconButton.filledTonal(
                      icon: const Icon(Icons.menu),
                      onPressed: () => setState(() => _isSidebarOpen = true),
                      tooltip: "Open Sidebar",
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatListSidebar() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
          child: Row(
            children: [
              const Text("CHATS"),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.add_comment_outlined, size: 20),
                onPressed: _addNewChat,
                tooltip: "New Chat",
              ),
              IconButton(
                icon: const Icon(Icons.menu_open, size: 20),
                onPressed: () => setState(() => _isSidebarOpen = false),
                tooltip: "Close Sidebar",
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: TreeView.simple(
            tree: _chatListTree,
            showRootNode: false,
            expansionIndicatorBuilder: (context, node) =>
                ChevronIndicator.rightDown(
                  tree: node,
                  color: Colors.grey,
                  padding: const EdgeInsets.all(8),
                ),
            builder: (context, node) {
              return ListTile(
                dense: true,
                leading: const Icon(Icons.chat_bubble_outline, size: 20),
                title: Text(node.data ?? "Untitled Chat"),
                selected: _selectedChatKey == node.key,
                onTap: () {
                  setState(() => _selectedChatKey = node.key);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildChatContentArea() {
    final messages = _chatSessions[_selectedChatKey] ?? [];
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            reverse: true,
            itemCount: messages.length,
            itemBuilder: (context, index) {
              return _ChatMessageWidget(message: messages[index]);
            },
          ),
        ),
        const Divider(height: 1.0),
        _buildInputArea(),
      ],
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              onSubmitted: _handleSubmitted,
              decoration: const InputDecoration.collapsed(
                hintText: 'Type a message...',
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () => _handleSubmitted(_textController.text),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;

  _ChatMessage({required this.text, required this.isUser});
}

class _ChatMessageWidget extends StatelessWidget {
  final _ChatMessage message;

  const _ChatMessageWidget({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: message.isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            CircleAvatar(
              backgroundColor: theme.primaryColor,
              foregroundColor: theme.colorScheme.onPrimary,
              child: const Icon(Icons.smart_toy_outlined),
            ),
            const SizedBox(width: 8.0),
          ],
          Flexible(
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
