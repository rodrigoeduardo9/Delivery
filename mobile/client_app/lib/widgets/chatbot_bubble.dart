import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/chat_message.dart';
import '../config/theme.dart';
import '../utils/formatters.dart';
import 'loading_shimmer.dart';

class ChatbotBubble extends StatelessWidget {
  final ChatMessage message;
  final ValueChanged<String>? onQuickReply;

  const ChatbotBubble({
    super.key,
    required this.message,
    this.onQuickReply,
  });

  @override
  Widget build(BuildContext context) {
    if (message.isUser) {
      return _buildUserBubble();
    }
    return _buildBotBubble();
  }

  Widget _buildUserBubble() {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(left: 60, top: 4, bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.primary,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
          ),
        ),
        child: Text(
          message.content,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildBotBubble() {
    final metadata = message.metadata;

    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(right: 60, top: 4, bottom: 4),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Text(
              message.content,
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
            ),
          ),
          if (metadata != null && metadata['type'] == 'restaurant' && metadata['data'] != null)
            _buildRestaurantCard(metadata['data'] as Map<String, dynamic>),
          if (message.quickReplies.isNotEmpty)
            _buildQuickReplies(),
        ],
      ),
    );
  }

  Widget _buildRestaurantCard(Map<String, dynamic> data) {
    return Container(
      width: 260,
      margin: const EdgeInsets.only(right: 60, top: 4),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (data['image_url'] != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: CachedNetworkImage(
                imageUrl: data['image_url'] as String,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (_, __) => const ShimmerWidget(height: 120),
                errorWidget: (_, __, ___) => Container(
                  color: AppTheme.divider,
                  height: 120,
                  child: const Icon(Icons.restaurant, color: AppTheme.textHint),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['name'] as String? ?? '',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                if (data['rating'] != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Rating: ${(data['rating'] as num).toStringAsFixed(1)}',
                    style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                  ),
                ],
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {},
                    child: const Text('View Restaurant'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickReplies() {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Wrap(
        spacing: 6,
        runSpacing: 4,
        children: message.quickReplies.map((reply) => ActionChip(
          label: Text(reply, style: const TextStyle(fontSize: 12)),
          onPressed: () => onQuickReply?.call(reply),
          backgroundColor: AppTheme.primary.withOpacity(0.1),
          side: BorderSide(color: AppTheme.primary.withOpacity(0.3)),
          labelStyle: const TextStyle(color: AppTheme.primary),
        )).toList(),
      ),
    );
  }
}
