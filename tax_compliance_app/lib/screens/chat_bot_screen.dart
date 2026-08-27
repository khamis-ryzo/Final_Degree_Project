import 'package:flutter/material.dart';
import '../widgets/chat_bot_widget.dart';
import '../utils/constants.dart';

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({super.key});

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  String _selectedTopic = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Tax Assistant'),
        backgroundColor: AppColors.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                // Reset chat - would need to rebuild the chat widget
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Topic indicator
          if (_selectedTopic.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              color: AppColors.primary.withValues(alpha: 0.1),
              child: Row(
                children: [
                  const Icon(
                    Icons.topic,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Topic: $_selectedTopic',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    onPressed: () {
                      setState(() {
                        _selectedTopic = '';
                      });
                    },
                  ),
                ],
              ),
            ),

          // Chat Bot
          Expanded(
            child: ChatBotWidget(
              onTopicSelected: (topic) {
                setState(() {
                  _selectedTopic = topic;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
