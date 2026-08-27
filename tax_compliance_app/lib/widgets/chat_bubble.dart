import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../utils/constants.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final bool showTime;
  final void Function(String)? onQuickReply;

  const ChatBubble({
    super.key,
    required this.message,
    this.showTime = true,
    this.onQuickReply,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) _buildBotAvatar(),
          if (!message.isUser) const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: message.isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: message.isUser
                        ? AppColors.primary
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: message.isUser
                          ? const Radius.circular(16)
                          : Radius.zero,
                      bottomRight: message.isUser
                          ? Radius.zero
                          : const Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Message text with markdown-like formatting
                      Text(
                        message.text,
                        style: TextStyle(
                          color: message.isUser ? Colors.white : Colors.black87,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),

                      // Quick Replies
                      if (message.quickReplies != null &&
                          message.quickReplies!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: message.quickReplies!.map((reply) {
                              return ActionChip(
                                label: Text(
                                  reply.label,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                onPressed: () {
                                  onQuickReply?.call(reply.value);
                                },
                                backgroundColor: Colors.white,
                                side: BorderSide(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.3),
                                ),
                                shape: StadiumBorder(
                                  side: BorderSide(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.3),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                    ],
                  ),
                ),
                if (showTime)
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 4,
                      left: 8,
                      right: 8,
                    ),
                    child: Text(
                      message.formattedTime,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (message.isUser) const SizedBox(width: 8),
          if (message.isUser) _buildUserAvatar(),
        ],
      ),
    );
  }

  Widget _buildBotAvatar() {
    return const CircleAvatar(
      radius: 18,
      backgroundColor: AppColors.primary,
      child: Icon(
        Icons.assistant,
        color: Colors.white,
        size: 20,
      ),
    );
  }

  Widget _buildUserAvatar() {
    return CircleAvatar(
      radius: 18,
      backgroundColor: Colors.grey.shade300,
      child: const Icon(
        Icons.person,
        color: Colors.white,
        size: 20,
      ),
    );
  }
}
