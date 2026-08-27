class Subscription {
  final int? id;
  final int? userId;
  final String? username;
  final String? fullName;
  final String plan;
  final String billingCycle;
  final String status;
  final DateTime? startDate;
  final DateTime? expiryDate;
  final bool autoRenew;
  final int daysRemaining;
  final DateTime? createdAt;
  final String? message;

  Subscription({
    this.id,
    this.userId,
    this.username,
    this.fullName,
    required this.plan,
    required this.billingCycle,
    required this.status,
    this.startDate,
    this.expiryDate,
    required this.autoRenew,
    this.daysRemaining = -1,
    this.createdAt,
    this.message,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'],
      userId: json['userId'],
      username: json['username'],
      fullName: json['fullName'],
      plan: json['plan'] ?? 'FREE',
      billingCycle: json['billingCycle'] ?? 'NONE',
      status: json['status'] ?? 'ACTIVE',
      startDate: json['startDate'] != null
          ? DateTime.tryParse(json['startDate'].toString())
          : null,
      expiryDate: json['expiryDate'] != null
          ? DateTime.tryParse(json['expiryDate'].toString())
          : null,
      autoRenew: json['autoRenew'] ?? false,
      daysRemaining: (json['daysRemaining'] as num?)?.toInt() ?? -1,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      message: json['message'],
    );
  }

  bool get isPremium => plan == 'PREMIUM';
  bool get isActive => status == 'ACTIVE';
  bool get isExpired => status == 'EXPIRED';
  bool get isCancelled => status == 'CANCELLED';

  String get planDisplayName => isPremium ? 'Premium' : 'Free';

  String get statusDisplayName {
    switch (status) {
      case 'ACTIVE':
        return 'Active';
      case 'EXPIRED':
        return 'Expired';
      case 'CANCELLED':
        return 'Cancelled';
      default:
        return status;
    }
  }

  String get cycleDisplayName {
    switch (billingCycle) {
      case 'MONTHLY':
        return 'Monthly';
      case 'YEARLY':
        return 'Yearly';
      default:
        return 'N/A';
    }
  }
}

class SubscriptionRequest {
  final String plan;
  final String billingCycle;
  final bool autoRenew;

  SubscriptionRequest({
    required this.plan,
    this.billingCycle = 'MONTHLY',
    this.autoRenew = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'plan': plan,
      'billingCycle': billingCycle,
      'autoRenew': autoRenew,
    };
  }
}
