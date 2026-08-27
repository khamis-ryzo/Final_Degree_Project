import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/logger.dart';

class DashboardProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  int _selectedIndex = 0;
  DateTime? _lastSyncTime;
  bool _isRefreshing = false;

  double _totalTaxPaid = 0;
  double _pendingTax = 0;
  double _totalRefund = 0;
  int _completedReturns = 0;
  int _pendingReturns = 0;

  int get selectedIndex => _selectedIndex;
  DateTime? get lastSyncTime => _lastSyncTime;
  bool get isRefreshing => _isRefreshing;

  double get totalTaxPaid => _totalTaxPaid;
  double get pendingTax => _pendingTax;
  double get totalRefund => _totalRefund;
  int get completedReturns => _completedReturns;
  int get pendingReturns => _pendingReturns;
  double get totalSavings => _totalTaxPaid - _pendingTax;

  void setSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  Future<void> refreshDashboard() async {
    _isRefreshing = true;
    notifyListeners();

    try {
      AppLogger.info('Refreshing dashboard data');

      final summary = await _apiService.get('/users/dashboard-summary');

      _totalTaxPaid = (summary['totalPaid'] ?? 0).toDouble();
      _pendingTax = (summary['pendingTax'] ?? 0).toDouble();
      _totalRefund = (summary['totalRefund'] ?? 0).toDouble();
      _completedReturns = (summary['completedReturns'] ?? 0).toInt();
      _pendingReturns = (summary['pendingReturns'] ?? 0).toInt();

      _lastSyncTime = DateTime.now();
      _isRefreshing = false;
      notifyListeners();

      AppLogger.info('Dashboard refreshed successfully');
    } catch (e) {
      AppLogger.error('Error refreshing dashboard', e);
      _isRefreshing = false;
      notifyListeners();
    }
  }

  void updateStats({
    double? totalTaxPaid,
    double? pendingTax,
    double? totalRefund,
    int? completedReturns,
    int? pendingReturns,
  }) {
    if (totalTaxPaid != null) _totalTaxPaid = totalTaxPaid;
    if (pendingTax != null) _pendingTax = pendingTax;
    if (totalRefund != null) _totalRefund = totalRefund;
    if (completedReturns != null) _completedReturns = completedReturns;
    if (pendingReturns != null) _pendingReturns = pendingReturns;

    notifyListeners();
  }

  void clearStats() {
    _totalTaxPaid = 0;
    _pendingTax = 0;
    _totalRefund = 0;
    _completedReturns = 0;
    _pendingReturns = 0;
    notifyListeners();
  }
}
