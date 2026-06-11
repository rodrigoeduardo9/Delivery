import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/chatbot_provider.dart';
import '../models/chat_message.dart';
import '../widgets/chatbot_bubble.dart';
import '../widgets/loading_shimmer.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatbotProvider>().loadConversations();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    context.read<ChatbotProvider>().sendMessage(text);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.smart_toy, color: AppTheme.primary, size: 24),
            SizedBox(width: 8),
            Text('Assistant'),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatbotProvider>(
              builder: (context, chatbot, _) {
                if (chatbot.isLoading && chatbot.messages.isEmpty) {
                  return const LoadingShimmerList();
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: chatbot.messages.length + (chatbot.isTyping ? 1 : 0),
                  itemBuilder: (_, index) {
                    if (index == chatbot.messages.length && chatbot.isTyping) {
                      return _buildTypingIndicator();
                    }

                    final message = chatbot.messages[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: ChatbotBubble(
                        message: message,
                        onQuickReply: (reply) {
                          _messageController.text = reply;
                          _sendMessage();
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(right: 60, top: 4, bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _dot(),
            const SizedBox(width: 4),
            _dot(delay: true),
            const SizedBox(width: 4),
            _dot(delay: true, delay2: true),
          ],
        ),
      ),
    );
  }

  Widget _dot({bool delay = false, bool delay2 = false}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: AppTheme.textSecondary.withOpacity(0.5),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        8,
        8,
        8,
        8 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                filled: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(Icons.send, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
