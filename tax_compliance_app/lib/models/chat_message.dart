import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final MessageType type;
  final Map<String, dynamic>? metadata;
  final List<QuickReply>? quickReplies;
  final String? imageUrl;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.type = MessageType.text,
    this.metadata,
    this.quickReplies,
    this.imageUrl,
  });

  factory ChatMessage.user(String text) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
      type: MessageType.text,
    );
  }

  factory ChatMessage.bot(String text, {List<QuickReply>? quickReplies}) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isUser: false,
      timestamp: DateTime.now(),
      type: MessageType.text,
      quickReplies: quickReplies,
    );
  }

  String get formattedTime {
    return DateFormat('hh:mm a').format(timestamp);
  }

  String get formattedDate {
    return DateFormat('dd MMM yyyy').format(timestamp);
  }
}

enum MessageType {
  text,
  image,
  file,
  link,
  quickReply,
  loading,
  error,
}

class QuickReply {
  final String label;
  final String value;
  final IconData? icon;

  QuickReply({
    required this.label,
    required this.value,
    this.icon,
  });

  // Predefined quick replies for tax topics
  static List<QuickReply> get taxTopics => [
    QuickReply(label: '📋 File Return', value: 'How do I file my tax return?'),
    QuickReply(label: '💰 PAYE', value: 'How is PAYE calculated in Tanzania?'),
    QuickReply(label: '📊 VAT', value: 'What is the VAT rate in Tanzania?'),
    QuickReply(label: '📅 Deadline', value: 'When is the filing deadline?'),
    QuickReply(label: '💳 Payment', value: 'How can I pay my taxes?'),
    QuickReply(label: '📄 TIN', value: 'How do I get a TIN number?'),
  ];

  static List<QuickReply> get helpTopics => [
    QuickReply(label: '📞 Contact', value: 'How can I contact TRA?'),
    QuickReply(label: '📝 Documents', value: 'What documents do I need?'),
    QuickReply(label: '⚠️ Penalties', value: 'What are the penalties for late filing?'),
    QuickReply(label: '🔄 Resubmit', value: 'How do I resubmit a return?'),
  ];

  static List<QuickReply> get paymentMethods => [
    QuickReply(label: '📱 M-Pesa', value: 'How to pay using M-Pesa?'),
    QuickReply(label: '📱 Tigo Pesa', value: 'How to pay using Tigo Pesa?'),
    QuickReply(label: '📱 Airtel Money', value: 'How to pay using Airtel Money?'),
    QuickReply(label: '🏦 Bank', value: 'How to pay via bank transfer?'),
  ];
}