import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/chat_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/chat_input.dart';
import '../widgets/empty_chat.dart';
import '../widgets/message_bubble.dart';
import '../widgets/typing_indicator.dart';
import '../widgets/chat_history_drawer.dart';
import '../services/pdf_service.dart';

/// The main chat screen — displays messages, typing state, and input bar.
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _scrollController = ScrollController();
  final _textController = TextEditingController(); // Manage controller here
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Use a FocusNode to focus input when suggestion is clicked
  final FocusNode _inputFocusNode = FocusNode();

  @override
  void dispose() {
    _scrollController.dispose();
    _textController.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  /// Exports the current chat session to a PDF.
  Future<void> _exportChat(BuildContext context) async {
    final chatProvider = context.read<ChatProvider>();
    final currentSession = chatProvider.currentSession;

    if (currentSession.messages.isNotEmpty) {
      try {
        await PdfService.exportChatToPdf(currentSession);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Chat exported successfully!'),
              backgroundColor: AppTheme.primaryBrand,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to export chat: $e'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No messages to export'),
          backgroundColor: Colors.orangeAccent,
        ),
      );
    }
  }

  bool _shouldScroll = true;

  /// Scrolls to the bottom of the message list with a smooth animation.
  void _scrollToBottom() {
    if (!_shouldScroll) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTheme.black,
      drawer: const ChatHistoryDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            // ── Minimal Header ─────────────────────────────
            Container(
              height: 60,
              decoration: const BoxDecoration(
                color: AppTheme.black,
                border: Border(
                  bottom: BorderSide(color: AppTheme.dividerColor),
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 1. Absolute Center Model Selector
                  const _ModelSelector(),

                  // 2. Left side Menu¯
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: IconButton(
                        icon: const Icon(Icons.menu_rounded),
                        color: AppTheme.textPrimary,
                        onPressed: () =>
                            _scaffoldKey.currentState?.openDrawer(),
                      ),
                    ),
                  ),

                  // 3. Right side Icons
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.add_rounded),
                            tooltip: 'New Chat',
                            color: AppTheme.textPrimary,
                            onPressed: () {
                              context.read<ChatProvider>().startNewChat();
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.download_rounded),
                            tooltip: 'Export Chat',
                            color: AppTheme.textPrimary,
                            onPressed: () => _exportChat(context),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            //  const Divider(height: 1, color: AppTheme.dividerColor),

            // ── Message list ─────────────────────────────────
            Expanded(
              child: Consumer<ChatProvider>(
                builder: (context, chat, _) {
                  if (chat.messages.isEmpty) {
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                            child: EmptyChat(
                              onSuggestionClick: (suggestion) {
                                debugPrint("Suggestion Clicked: $suggestion");
                                setState(() {
                                  _textController.value = TextEditingValue(
                                    text: suggestion,
                                    selection: TextSelection.collapsed(
                                      offset: suggestion.length,
                                    ),
                                  );
                                });
                                // Request focus after a short delay to ensure UI updates
                                Future.delayed(
                                  const Duration(milliseconds: 50),
                                  () {
                                    if (mounted) {
                                      FocusScope.of(
                                        context,
                                      ).requestFocus(_inputFocusNode);
                                    }
                                  },
                                );
                              },
                            ),
                          ),
                        );
                      },
                    );
                  }

                  // Only scroll if AI is typing or if it's a new message
                  _shouldScroll =
                      chat.isAiTyping ||
                      (_scrollController.hasClients &&
                          _scrollController.position.atEdge &&
                          _scrollController.position.pixels > 0);

                  // Auto-scroll logic
                  _scrollToBottom();

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    itemCount: chat.messages.length + (chat.isAiTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == chat.messages.length) {
                        return const Padding(
                          padding: EdgeInsets.only(
                            left: 20,
                            top: 12,
                            bottom: 20,
                          ),
                          child: TypingIndicator(),
                        );
                      }
                      return MessageBubble(message: chat.messages[index]);
                    },
                  );
                },
              ),
            ),

            // ── Error banner ────────────────────────────────
            Consumer<ChatProvider>(
              builder: (context, chat, _) {
                if (chat.errorMessage == null) {
                  return const SizedBox.shrink();
                }
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Text(
                    chat.errorMessage!,
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 13,
                    ),
                  ),
                );
              },
            ),

            // ── Input bar ───────────────────────────────────
            Consumer<ChatProvider>(
              builder: (context, chat, _) {
                return ChatInput(
                  controller: _textController,
                  focusNode: _inputFocusNode, // Pass focus node
                  enabled:
                      !chat.isAiTyping, // Ensure input is enabled when empty
                  onSend: (text, imagePath) {
                    chat.sendMessage(text, imageUrl: imagePath);
                    _scrollToBottom();
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ModelSelector extends StatelessWidget {
  const _ModelSelector();

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chat, _) {
        return PopupMenuButton<String>(
          onSelected: (model) => chat.setModel(model),
          itemBuilder: (context) => chat.availableModels.map((model) {
            return PopupMenuItem(
              value: model,
              child: Row(
                children: [
                  Icon(
                    model == chat.currentModel
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    size: 16,
                    color: model == chat.currentModel
                        ? AppTheme.primaryBrand
                        : AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    model,
                    style: AppTheme.bodyMedium.copyWith(
                      color: model == chat.currentModel
                          ? AppTheme.textPrimary
                          : AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          color: AppTheme.surfaceLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          offset: const Offset(0, 40),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.dividerColor),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  chat.currentModel,
                  style: AppTheme.bodyMedium.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 16,
                  color: AppTheme.textSecondary,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
