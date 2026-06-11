class ChatMessage {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final List<String> quickReplies;
  final Map<String, dynamic>? metadata;

  ChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.quickReplies = const [],
    this.metadata,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      content: json['content'] as String? ?? '',
      isUser: json['is_user'] as bool? ?? false,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
      quickReplies: (json['quick_replies'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'content': content,
        'is_user': isUser,
        'timestamp': timestamp.toIso8601String(),
        'quick_replies': quickReplies,
        'metadata': metadata,
      };
}
