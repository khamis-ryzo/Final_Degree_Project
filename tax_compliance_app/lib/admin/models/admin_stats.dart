class AdminStats {
  final int totalUsers;
  final int activeUsers;
  final int totalReturns;
  final int pendingReturns;
  final int completedReturns;
  final double totalRevenue;
  final double pendingAmount;
  final int totalTaxRules;
  final int activeTaxRules;
  final int totalDocuments;
  final int pendingDocuments;

  AdminStats({
    required this.totalUsers,
    required this.activeUsers,
    required this.totalReturns,
    required this.pendingReturns,
    required this.completedReturns,
    required this.totalRevenue,
    required this.pendingAmount,
    required this.totalTaxRules,
    required this.activeTaxRules,
    required this.totalDocuments,
    required this.pendingDocuments,
  });

  factory AdminStats.fromJson(Map<String, dynamic> json) {
    return AdminStats(
      totalUsers: json['totalUsers'] ?? 0,
      activeUsers: json['activeUsers'] ?? 0,
      totalReturns: json['totalReturns'] ?? 0,
      pendingReturns: json['pendingReturns'] ?? 0,
      completedReturns: json['completedReturns'] ?? 0,
      totalRevenue: json['totalRevenue']?.toDouble() ?? 0.0,
      pendingAmount: json['pendingAmount']?.toDouble() ?? 0.0,
      totalTaxRules: json['totalTaxRules'] ?? 0,
      activeTaxRules: json['activeTaxRules'] ?? 0,
      totalDocuments: json['totalDocuments'] ?? 0,
      pendingDocuments: json['pendingDocuments'] ?? 0,
    );
  }

  String get formattedRevenue {
    return 'TSh ${_formatNumber(totalRevenue)}';
  }

  String get formattedPendingAmount {
    return 'TSh ${_formatNumber(pendingAmount)}';
  }

  String _formatNumber(double value) {
    return value.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]},',
        );
  }
}
