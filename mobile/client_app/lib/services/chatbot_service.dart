import '../models/api_response.dart';
import '../models/chat_message.dart';
import 'api_service.dart';
import '../config/api_config.dart';

class ChatbotService {
  final ApiService _api = ApiService();

  Future<ApiResponse<List<ChatMessage>>> getConversations() async {
    try {
      final data = await _api.get(ApiConfig.chatbotConversations);
      return ApiResponse.fromJson(data as Map<String, dynamic>,
          (d) => (d as List).map((e) => ChatMessage.fromJson(e as Map<String, dynamic>)).toList());
    } on ApiException catch (e) {
      return ApiResponse<List<ChatMessage>>(success: false, message: e.message, errors: e.errors);
    }
  }

  Future<ApiResponse<ChatMessage>> sendMessage(String message) async {
    try {
      final data = await _api.post(ApiConfig.chatbotSend, body: {
        'message': message,
      });
      return ApiResponse.fromJson(data as Map<String, dynamic>,
          (d) => ChatMessage.fromJson(d as Map<String, dynamic>));
    } on ApiException catch (e) {
      return ApiResponse<ChatMessage>(success: false, message: e.message, errors: e.errors);
    }
  }
}
