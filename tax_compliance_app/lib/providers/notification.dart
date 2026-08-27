import 'package:flutter/material.dart';

class AppNotification {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  bool isRead;
  final String? payload;
  final NotificationType type;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    this.isRead = false,
    this.payload,
    required this.type,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      timestamp: DateTime.parse(json['timestamp']),
      isRead: json['isRead'] ?? false,
      payload: json['payload'],
      type: NotificationType.fromString(json['type']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'payload': payload,
      'type': type.value,
    };
  }

  String get formattedTime {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 7) {
      return '${difference.inDays ~/ 7}w ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  IconData get icon {
    switch (type) {
      case NotificationType.taxReminder:
        return Icons.notifications_active;
      case NotificationType.taxFiling:
        return Icons.request_quote;
      case NotificationType.refund:
        return Icons.currency_rupee;
      case NotificationType.assessment:
        return Icons.assessment;
      case NotificationType.general:
        return Icons.notifications;
    }
  }

  Color get color {
    switch (type) {
      case NotificationType.taxReminder:
        return Colors.orange;
      case NotificationType.taxFiling:
        return Colors.green;
      case NotificationType.refund:
        return Colors.blue;
      case NotificationType.assessment:
        return Colors.purple;
      case NotificationType.general:
        return Colors.grey;
    }
  }
}

enum NotificationType {
  taxReminder('tax_reminder'),
  taxFiling('tax_filing'),
  refund('refund'),
  assessment('assessment'),
  general('general');

  final String value;
  const NotificationType(this.value);

  static NotificationType fromString(String value) {
    switch (value) {
      case 'tax_reminder':
        return NotificationType.taxReminder;
      case 'tax_filing':
        return NotificationType.taxFiling;
      case 'refund':
        return NotificationType.refund;
      case 'assessment':
        return NotificationType.assessment;
      default:
        return NotificationType.general;
    }
  }
}