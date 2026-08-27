import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppColors {
  static const Color primary = Color(0xFF1A73E8);
}

class AssistanceChat extends StatefulWidget {
  final Function(String) onSendMessage;

  const AssistanceChat({super.key, required this.onSendMessage});

  @override
  State<AssistanceChat> createState() => _AssistanceChatState();
}

class _AssistanceChatState extends State<AssistanceChat> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Add welcome messages
    _messages.add(ChatMessage(
      text: '👋 Hello! I\'m your Tax Filing Assistant.',
      isUser: false,
      timestamp: DateTime.now(),
    ));
    _messages.add(ChatMessage(
      text: 'I can help you with:\n'
          '• Understanding TIN and registration\n'
          '• PAYE tax calculations\n'
          '• VAT registration and filing\n'
          '• Eligible deductions\n'
          '• Filing deadlines and penalties\n'
          '• Payment methods (M-Pesa, Bank, etc.)\n\n'
          'What would you like to know?',
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final message = _messageController.text.trim();
    setState(() {
      _messages.add(ChatMessage(
        text: message,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _messageController.clear();
    });

    widget.onSendMessage(message);

    // Auto-scroll to bottom
    _scrollToBottom();

    // Simulate AI response
    Future.delayed(const Duration(milliseconds: 500), () {
      final response = _getAutoResponse(message);
      setState(() {
        _messages.add(ChatMessage(
          text: response,
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });
      _scrollToBottom();
    });
  }

  String _getAutoResponse(String message) {
    final lower = message.toLowerCase();

    if (lower.contains('tin') || lower.contains('tax id')) {
      return '📋 **TIN (Taxpayer Identification Number)**\n\n'
          '• A unique 9-digit number issued by TRA\n'
          '• Required for all tax transactions\n'
          '• Format: 123456789\n'
          '• Can be obtained from TRA offices or online\n'
          '• Keep your TIN ready for filing';
    }

    if (lower.contains('paye') || lower.contains('pay as you earn')) {
      return '💰 **PAYE (Pay As You Earn)**\n\n'
          'PAYE rates for Tanzania 2024:\n'
          '• TSh 0 - 270,000: 0%\n'
          '• TSh 270,001 - 520,000: 8%\n'
          '• TSh 520,001 - 760,000: 20%\n'
          '• TSh 760,001 - 1,000,000: 25%\n'
          '• TSh 1,000,001 - 10,000,000: 30%\n'
          '• Above TSh 10,000,000: 35%\n\n'
          'Personal relief: TSh 270,000 annually';
    }

    if (lower.contains('vat')) {
      return '📊 **VAT (Value Added Tax)**\n\n'
          '• Rate: 18%\n'
          '• Registration threshold: TSh 10,000,000 annual turnover\n'
          '• Filing: Monthly returns\n'
          '• Due date: 20th of following month\n'
          '• Penalties for late filing apply';
    }

    if (lower.contains('deduction') || lower.contains('relief')) {
      return '📝 **Tax Deductions & Relief**\n\n'
          'Common deductions you can claim:\n'
          '• Pension contributions\n'
          '• Insurance premiums (Life, Health)\n'
          '• Medical expenses\n'
          '• Charitable donations\n'
          '• Education expenses\n'
          '• Mortgage interest\n'
          '• Business expenses\n'
          '• Personal Relief: TSh 270,000';
    }

    if (lower.contains('deadline') || lower.contains('due')) {
      return '📅 **Filing Deadlines**\n\n'
          '• Individual returns: 30th June\n'
          '• Corporate returns: 31st December\n'
          '• VAT returns: 20th of each month\n'
          '• PAYE returns: 15th of each month\n\n'
          '⚠️ Late filing attracts penalties and interest';
    }

    if (lower.contains('payment') ||
        lower.contains('pay') ||
        lower.contains('mpesa')) {
      return '💳 **Payment Methods**\n\n'
          'You can pay taxes through:\n'
          '• M-Pesa (dial *150*00#)\n'
          '• Tigo Pesa (dial *150*01#)\n'
          '• Airtel Money (dial *150*02#)\n'
          '• Bank Transfer (any commercial bank)\n'
          '• TRA Office (cash or card)\n'
          '• Online Banking\n\n'
          'Use your Control Number for all payments';
    }

    if (lower.contains('penalty') || lower.contains('late')) {
      return '⚠️ **Penalties for Late Filing**\n\n'
          '• Late filing penalty: 5% per month\n'
          '• Late payment interest: 0.01% per day\n'
          '• Maximum penalty: 100% of tax due\n'
          '• Additional penalties for false declarations\n\n'
          'File on time to avoid penalties!';
    }

    if (lower.contains('hello') ||
        lower.contains('hi') ||
        lower.contains('hey')) {
      return '👋 Hello! How can I help you with your tax filing today?\n\n'
          'You can ask me about:\n'
          '• TIN registration\n'
          '• PAYE calculations\n'
          '• VAT filing\n'
          '• Deductions and relief\n'
          '• Deadlines\n'
          '• Payment methods';
    }

    if (lower.contains('help') || lower.contains('support')) {
      return '📞 **Support Options**\n\n'
          '• TRA Call Center: +255 22 123 4567\n'
          '• Email: support@tra.go.tz\n'
          '• WhatsApp: +255 712 345 678\n'
          '• Visit any TRA office near you\n'
          '• Live chat: Available Mon-Fri 8am-5pm';
    }

    return '🤖 I\'m not sure about that. Could you rephrase your question?\n\n'
        'I can help with:\n'
        '• TIN, PAYE, VAT\n'
        '• Deductions and relief\n'
        '• Deadlines and penalties\n'
        '• Payment methods\n'
        '• General tax questions';
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 20,
                  child: Icon(
                    Icons.assistant,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tax Filing Assistant',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Online • Ready to help',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),

          // Quick Actions
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildQuickAction('TIN', () {
                    _messageController.text = 'What is TIN?';
                    _sendMessage();
                  }),
                  _buildQuickAction('PAYE', () {
                    _messageController.text = 'How does PAYE work?';
                    _sendMessage();
                  }),
                  _buildQuickAction('VAT', () {
                    _messageController.text = 'VAT rates and filing';
                    _sendMessage();
                  }),
                  _buildQuickAction('Deductions', () {
                    _messageController.text = 'What deductions can I claim?';
                    _sendMessage();
                  }),
                  _buildQuickAction('Deadline', () {
                    _messageController.text = 'What is the filing deadline?';
                    _sendMessage();
                  }),
                  _buildQuickAction('Payment', () {
                    _messageController.text = 'How to pay taxes?';
                    _sendMessage();
                  }),
                ],
              ),
            ),
          ),

          // Input
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type your question...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: IconButton(
                    icon: const Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.isUser;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser)
            const CircleAvatar(
              backgroundColor: AppColors.primary,
              radius: 16,
              child: Icon(
                Icons.assistant,
                color: Colors.white,
                size: 16,
              ),
            ),
          if (!isUser) const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUser ? AppColors.primary : Colors.grey.shade100,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(12),
                  topRight: const Radius.circular(12),
                  bottomLeft: isUser ? const Radius.circular(12) : Radius.zero,
                  bottomRight: isUser ? Radius.zero : const Radius.circular(12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: isUser ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('hh:mm a').format(message.timestamp),
                    style: TextStyle(
                      fontSize: 10,
                      color: isUser ? Colors.white70 : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
          if (isUser)
            const CircleAvatar(
              backgroundColor: AppColors.primary,
              radius: 16,
              child: Icon(
                Icons.person,
                color: Colors.white,
                size: 16,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ActionChip(
        label: Text(label),
        onPressed: onTap,
        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
        labelStyle: const TextStyle(color: AppColors.primary),
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}
