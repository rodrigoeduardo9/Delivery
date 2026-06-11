import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../services/chatbot_service.dart';

class ChatbotProvider extends ChangeNotifier {
  final ChatbotService _chatbotService = ChatbotService();

  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isTyping = false;

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isTyping => _isTyping;

  Future<void> loadConversations() async {
    _isLoading = true;
    notifyListeners();

    final result = await _chatbotService.getConversations();
    if (result.success && result.data != null) {
      _messages = result.data!;
    }

    _isLoading = false;
    notifyListeners();

    if (_messages.isEmpty) {
      _addWelcomeMessage();
    }
  }

  void _addWelcomeMessage() {
    _messages.add(ChatMessage(
      id: 'welcome',
      content: 'Hello! I\'m your food delivery assistant. How can I help you today? You can ask me to:\n\n• Find restaurants\n• Track your order\n• Recommend dishes\n• Help with account issues',
      isUser: false,
      timestamp: DateTime.now(),
      quickReplies: ['Find restaurants near me', 'Track my order', 'Recommend something'],
    ));
    notifyListeners();
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    _messages.add(userMessage);
    _isTyping = true;
    notifyListeners();

    final result = await _chatbotService.sendMessage(text);
    _isTyping = false;

    if (result.success && result.data != null) {
      _messages.add(result.data!);
    } else {
      _messages.add(ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: 'Sorry, I couldn\'t process your request. Please try again.',
        isUser: false,
        timestamp: DateTime.now(),
        quickReplies: ['Try again', 'Talk to human'],
      ));
    }

    notifyListeners();
  }

  void addChatbotMessage(ChatMessage message) {
    _messages.add(message);
    notifyListeners();
  }
}
