import 'package:flutter/material.dart';
import '../models/tax_calculation.dart';
import '../models/tax_return.dart';
import '../models/tax_rule.dart';
import '../services/tax_service.dart';
import '../services/tax_rule_service.dart';
import '../utils/logger.dart';

class TaxProvider extends ChangeNotifier {
  final TaxService _taxService = TaxService();
  final TaxRuleService _taxRuleService = TaxRuleService();

  List<TaxReturn> _returns = [];
  TaxReturn? _currentReturn;
  TaxCalculationResponse? _calculationResult;
  List<TaxRule> _taxRules = [];

  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  // Filters
  String _selectedStatus = 'All';
  String _selectedYear = 'All';
  String _searchQuery = '';

  // Getters
  List<TaxReturn> get returns => _filteredReturns;
  TaxReturn? get currentReturn => _currentReturn;
  TaxCalculationResponse? get calculationResult => _calculationResult;
  List<TaxRule> get taxRules => _taxRules;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;

  // Statistics
  int get totalReturns => _returns.length;
  int get completedReturns =>
      _returns.where((r) => r.status == 'COMPLETED').length;
  int get pendingReturns => _returns.where((r) => r.status == 'DRAFT').length;
  int get submittedReturns =>
      _returns.where((r) => r.status == 'SUBMITTED').length;
  double get totalTaxPaid => _returns.fold(0.0, (sum, r) => sum + r.taxPayable);
  double get totalRefund =>
      _returns.fold(0.0, (sum, r) => sum + r.refundAmount);

  // Filter getters
  String get selectedStatus => _selectedStatus;
  String get selectedYear => _selectedYear;
  String get searchQuery => _searchQuery;

  List<TaxReturn> get _filteredReturns {
    var filtered = _returns;

    // Filter by status
    if (_selectedStatus != 'All') {
      filtered = filtered.where((r) => r.status == _selectedStatus).toList();
    }

    // Filter by year
    if (_selectedYear != 'All') {
      filtered =
          filtered.where((r) => r.assessmentYear == _selectedYear).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((r) =>
              r.filingId.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              r.acknowledgmentNumber
                      ?.toLowerCase()
                      .contains(_searchQuery.toLowerCase()) ==
                  true)
          .toList();
    }

    // Sort by date (newest first)
    filtered.sort((a, b) => (b.createdAt ?? DateTime.now())
        .compareTo(a.createdAt ?? DateTime.now()));

    return filtered;
  }

  List<String> get availableYears {
    final years = _returns.map((r) => r.assessmentYear).toSet().toList();
    years.sort((a, b) => b.compareTo(a));
    return years;
  }

  // Load user's tax returns
  Future<void> loadReturns() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      AppLogger.info('Loading tax returns');
      _returns = await _taxService.getUserReturns();
      _isLoading = false;
      notifyListeners();
      AppLogger.info('Loaded ${_returns.length} tax returns');
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      AppLogger.error('Error loading tax returns', e);
    }
  }

  Future<List<TaxReturn>> loadReturnsForUserId(int userId) async {
    try {
      final returns = await _taxService.getUserReturnsByUserId(userId);
      _returns = returns;
      notifyListeners();
      return returns;
    } catch (e) {
      AppLogger.error('Error loading tax returns for user $userId', e);
      _errorMessage = e.toString();
      notifyListeners();
      return [];
    }
  }

  // Create new tax return
  Future<TaxReturn?> createReturn(String assessmentYear) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      AppLogger.info('Creating new tax return for year: $assessmentYear');
      final taxReturn = await _taxService.createTaxReturn(assessmentYear);
      _currentReturn = taxReturn;
      _isLoading = false;
      notifyListeners();
      AppLogger.info('Tax return created with ID: ${taxReturn.filingId}');
      return taxReturn;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      AppLogger.error('Error creating tax return', e);
      return null;
    }
  }

  // Calculate tax for a return
  Future<bool> calculateTax(
      int returnId, double totalIncome, double deductions) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      AppLogger.info('Calculating tax for return ID: $returnId');

      final request = TaxCalculationRequest(
        totalIncome: totalIncome,
        deductions: deductions,
      );

      _calculationResult = await _taxService.calculateTax(returnId, request);
      _currentReturn = await _taxService.getReturnById(returnId);

      _isLoading = false;
      notifyListeners();

      AppLogger.info(
          'Tax calculation completed. Total tax: ${_calculationResult?.totalTax}');
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      AppLogger.error('Error calculating tax', e);
      return false;
    }
  }

  Future<TaxReturn?> updateTaxReturn(
    int returnId,
    Map<String, dynamic> payload,
  ) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedReturn = await _taxService.updateTaxReturn(returnId, payload);
      _currentReturn = updatedReturn;
      _isSubmitting = false;
      notifyListeners();
      return updatedReturn;
    } catch (e) {
      _errorMessage = e.toString();
      _isSubmitting = false;
      notifyListeners();
      AppLogger.error('Error updating tax return', e);
      return null;
    }
  }

  Future<TaxReturn?> saveDraftReturn(
    int returnId, {
    required double totalIncome,
    double deductions = 0.0,
    String filingType = 'ORIGINAL',
    String? additionalInfo,
  }) async {
    return updateTaxReturn(
      returnId,
      TaxService.buildSubmissionPayload(
        totalIncome: totalIncome,
        deductions: deductions,
        filingType: filingType,
        additionalInfo: additionalInfo,
      ),
    );
  }

  // Submit tax return
  Future<bool> submitReturn(int returnId) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      AppLogger.info('Submitting tax return ID: $returnId');

      await _taxService.submitTaxReturn(returnId);
      await loadReturns(); // Refresh the list

      _currentReturn = null;
      _calculationResult = null;

      _isSubmitting = false;
      notifyListeners();

      AppLogger.info('Tax return submitted successfully');
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isSubmitting = false;
      notifyListeners();
      AppLogger.error('Error submitting tax return', e);
      return false;
    }
  }

  // Get return by ID
  Future<TaxReturn?> getReturnById(int returnId) async {
    try {
      AppLogger.info('Getting return by ID: $returnId');
      return await _taxService.getReturnById(returnId);
    } catch (e) {
      AppLogger.error('Error getting return by ID', e);
      return null;
    }
  }

  // Get return by filing ID
  Future<TaxReturn?> getReturnByFilingId(String filingId) async {
    try {
      AppLogger.info('Getting return by filing ID: $filingId');
      return await _taxService.getReturnByFilingId(filingId);
    } catch (e) {
      AppLogger.error('Error getting return by filing ID', e);
      return null;
    }
  }

  // Load tax rules
  Future<void> loadTaxRules() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      AppLogger.info('Loading tax rules');
      _taxRules = await _taxRuleService.getAllRules();
      _isLoading = false;
      notifyListeners();
      AppLogger.info('Loaded ${_taxRules.length} tax rules');
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      AppLogger.error('Error loading tax rules', e);
    }
  }

  // Filter methods
  void setStatusFilter(String status) {
    _selectedStatus = status;
    notifyListeners();
  }

  void setYearFilter(String year) {
    _selectedYear = year;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearFilters() {
    _selectedStatus = 'All';
    _selectedYear = 'All';
    _searchQuery = '';
    notifyListeners();
  }

  // Clear current return
  void clearCurrentReturn() {
    _currentReturn = null;
    _calculationResult = null;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Refresh all data
  Future<void> refreshAllData() async {
    await Future.wait([
      loadReturns(),
      loadTaxRules(),
    ]);
  }
}
