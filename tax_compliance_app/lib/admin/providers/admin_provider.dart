import 'package:flutter/material.dart';
import '../models/admin_stats.dart';
import '../models/admin_user.dart';
import '../../models/tax_return.dart';
import '../../models/user.dart';
import '../../models/tax_rule.dart';

class AdminProvider extends ChangeNotifier {
  // Admin authentication
  bool _isAdminAuthenticated = false;
  String? _adminToken;
  User? _adminUser;

  // Data
  AdminStats? _stats;
  List<AdminUser> _users = [];
  List<TaxReturn> _allReturns = [];
  List<TaxRule> _allTaxRules = [];

  // Filtering
  String _selectedStatus = 'All';
  String _selectedYear = 'All';
  String _searchQuery = '';

  // Loading states
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _errorMessage;

  // Getters
  bool get isAdminAuthenticated => _isAdminAuthenticated;
  String? get adminToken => _adminToken;
  User? get adminUser => _adminUser;
  AdminStats? get stats => _stats;
  List<AdminUser> get users => _users;
  List<TaxReturn> get allReturns => _filteredReturns;
  List<TaxRule> get allTaxRules => _allTaxRules;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get errorMessage => _errorMessage;

  // Filter getters
  String get selectedStatus => _selectedStatus;
  String get selectedYear => _selectedYear;
  String get searchQuery => _searchQuery;

  List<TaxReturn> get _filteredReturns {
    var filtered = _allReturns;

    if (_selectedStatus != 'All') {
      filtered = filtered.where((r) => r.status == _selectedStatus).toList();
    }

    if (_selectedYear != 'All') {
      filtered =
          filtered.where((r) => r.assessmentYear == _selectedYear).toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((r) =>
              r.filingId.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              r.tinNumber.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    return filtered;
  }

  // Admin login
  Future<bool> adminLogin(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // For demo: hardcoded admin credentials
      if (username == 'admin' && password == 'admin123') {
        _isAdminAuthenticated = true;
        _adminToken = 'admin_token_12345';
        _adminUser = User(
          id: 999,
          username: 'admin',
          email: 'admin@taxcompliance.co.tz',
          tinNumber: 'ADMIN123456',
          fullName: 'System Administrator',
          role: 'ROLE_ADMIN',
          isActive: true,
          createdAt: DateTime.now().toIso8601String(),
        );
        _isLoading = false;
        notifyListeners();
        await loadAdminData();
        return true;
      } else {
        _errorMessage = 'Invalid admin credentials';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Admin logout
  Future<void> adminLogout() async {
    _isAdminAuthenticated = false;
    _adminToken = null;
    _adminUser = null;
    _stats = null;
    _users = [];
    _allReturns = [];
    _allTaxRules = [];
    notifyListeners();
  }

  // Load admin data
  Future<void> loadAdminData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API calls
      await Future.delayed(const Duration(seconds: 1));

      _stats = _generateMockStats();
      _users = _generateMockUsers();
      _allReturns = _generateMockReturns();
      _allTaxRules = _generateMockTaxRules();

      _isLoading = false;
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // ==================== USER MANAGEMENT ====================

  Future<bool> toggleUserStatus(int userId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final index = _users.indexWhere((u) => u.id == userId);
      if (index != -1) {
        final user = _users[index];
        _users[index] = AdminUser(
          id: user.id,
          username: user.username,
          email: user.email,
          fullName: user.fullName,
          tinNumber: user.tinNumber,
          role: user.role,
          isActive: !user.isActive,
          emailVerified: user.emailVerified,
          mobileNumber: user.mobileNumber,
          lastLogin: user.lastLogin,
          createdAt: user.createdAt,
          updatedAt: DateTime.now(),
        );
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteUser(int userId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      _users.removeWhere((u) => u.id == userId);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  // ==================== TAX RETURN MANAGEMENT ====================

  Future<bool> updateReturnStatus(int returnId, String status) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final index = _allReturns.indexWhere((r) => r.id == returnId);
      if (index != -1) {
        final return_ = _allReturns[index];
        _allReturns[index] = TaxReturn(
          id: return_.id,
          filingId: return_.filingId,
          userId: return_.userId,
          tinNumber: return_.tinNumber,
          assessmentYear: return_.assessmentYear,
          filingType: return_.filingType,
          employmentIncome: return_.employmentIncome,
          businessIncome: return_.businessIncome,
          rentalIncome: return_.rentalIncome,
          agriculturalIncome: return_.agriculturalIncome,
          capitalGains: return_.capitalGains,
          interestIncome: return_.interestIncome,
          dividendIncome: return_.dividendIncome,
          otherIncome: return_.otherIncome,
          totalIncome: return_.totalIncome,
          personalRelief: return_.personalRelief,
          pensionRelief: return_.pensionRelief,
          insuranceRelief: return_.insuranceRelief,
          medicalExpenses: return_.medicalExpenses,
          charitableDonations: return_.charitableDonations,
          educationExpenses: return_.educationExpenses,
          mortgageInterest: return_.mortgageInterest,
          businessExpenses: return_.businessExpenses,
          otherDeductions: return_.otherDeductions,
          totalDeductions: return_.totalDeductions,
          taxableIncome: return_.taxableIncome,
          taxPayable: return_.taxPayable,
          skillsLevy: return_.skillsLevy,
          railwayLevy: return_.railwayLevy,
          vatPayable: return_.vatPayable,
          withholdingTax: return_.withholdingTax,
          corporateTax: return_.corporateTax,
          cessAmount: return_.cessAmount,
          interest: return_.interest,
          penalty: return_.penalty,
          totalLiability: return_.totalLiability,
          taxPaid: return_.taxPaid,
          refundAmount: return_.refundAmount,
          balanceDue: return_.balanceDue,
          controlNumber: return_.controlNumber,
          paymentMethod: return_.paymentMethod,
          transactionId: return_.transactionId,
          bankName: return_.bankName,
          mobileNumber: return_.mobileNumber,
          paymentDate: return_.paymentDate,
          paymentStatus: return_.paymentStatus,
          status: status,
          submissionDate: return_.submissionDate,
          acknowledgmentNumber: return_.acknowledgmentNumber,
          assessmentOfficer: return_.assessmentOfficer,
          assessmentNotes: return_.assessmentNotes,
          businessSector: return_.businessSector,
          numberOfEmployees: return_.numberOfEmployees,
          isVATRegistered: return_.isVATRegistered,
          hasPAYE: return_.hasPAYE,
          hasWithholdingTax: return_.hasWithholdingTax,
          traRegion: return_.traRegion,
          traBranch: return_.traBranch,
          createdAt: return_.createdAt,
          updatedAt: DateTime.now(),
          assessedAt: return_.assessedAt,
          completedAt: return_.completedAt,
        );
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // ==================== TAX RULE MANAGEMENT ====================

  Future<bool> toggleTaxRuleStatus(int ruleId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final index = _allTaxRules.indexWhere((r) => r.id == ruleId);
      if (index != -1) {
        final rule = _allTaxRules[index];
        _allTaxRules[index] = TaxRule(
          id: rule.id,
          ruleCode: rule.ruleCode,
          ruleName: rule.ruleName,
          ruleType: rule.ruleType,
          minIncome: rule.minIncome,
          maxIncome: rule.maxIncome,
          taxRate: rule.taxRate,
          flatAmount: rule.flatAmount,
          percentageOf: rule.percentageOf,
          maxLimit: rule.maxLimit,
          applicableFromYear: rule.applicableFromYear,
          applicableToYear: rule.applicableToYear,
          isActive: !rule.isActive,
          conditions: rule.conditions,
          priority: rule.priority,
          createdAt: rule.createdAt,
          updatedAt: DateTime.now(),
        );
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // ==================== FILTERING ====================

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

  // ==================== MOCK DATA GENERATORS ====================

  AdminStats _generateMockStats() {
    return AdminStats(
      totalUsers: 1247,
      activeUsers: 987,
      totalReturns: 2345,
      pendingReturns: 156,
      completedReturns: 2189,
      totalRevenue: 452876500.0,
      pendingAmount: 34567000.0,
      totalTaxRules: 24,
      activeTaxRules: 18,
      totalDocuments: 876,
      pendingDocuments: 45,
    );
  }

  List<AdminUser> _generateMockUsers() {
    return [
      AdminUser(
        id: 1,
        username: 'john_doe',
        email: 'john@example.com',
        fullName: 'John Doe',
        tinNumber: '123456789',
        role: 'ROLE_USER',
        isActive: true,
        emailVerified: true,
        mobileNumber: '+255712345678',
        lastLogin: DateTime.now().subtract(const Duration(hours: 2)),
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      AdminUser(
        id: 2,
        username: 'jane_smith',
        email: 'jane@example.com',
        fullName: 'Jane Smith',
        tinNumber: '987654321',
        role: 'ROLE_USER',
        isActive: true,
        emailVerified: true,
        mobileNumber: '+255765432109',
        lastLogin: DateTime.now().subtract(const Duration(days: 1)),
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      AdminUser(
        id: 3,
        username: 'mike_johnson',
        email: 'mike@example.com',
        fullName: 'Mike Johnson',
        tinNumber: '456789123',
        role: 'ROLE_USER',
        isActive: false,
        emailVerified: false,
        mobileNumber: '+255765432109',
        lastLogin: null,
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        updatedAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
    ];
  }

  List<TaxReturn> _generateMockReturns() {
    return [
      TaxReturn(
        id: 1,
        filingId: 'TR-2024-001',
        userId: 1,
        tinNumber: '123456789',
        assessmentYear: '2024/2025',
        filingType: 'ORIGINAL',
        totalIncome: 1200000,
        totalDeductions: 270000,
        taxableIncome: 930000,
        taxPayable: 116000,
        totalLiability: 232000,
        status: 'COMPLETED',
        employmentIncome: 1200000,
        businessIncome: 0,
        rentalIncome: 0,
        agriculturalIncome: 0,
        capitalGains: 0,
        interestIncome: 0,
        dividendIncome: 0,
        otherIncome: 0,
        personalRelief: 270000,
        pensionRelief: 0,
        insuranceRelief: 0,
        medicalExpenses: 0,
        charitableDonations: 0,
        educationExpenses: 0,
        mortgageInterest: 0,
        businessExpenses: 0,
        otherDeductions: 0,
        skillsLevy: 46500,
        railwayLevy: 46500,
        vatPayable: 0,
        withholdingTax: 0,
        corporateTax: 0,
        cessAmount: 0,
        interest: 0,
        penalty: 0,
        taxPaid: 232000,
        refundAmount: 0,
        balanceDue: 0,
        controlNumber: 'TZ20240701123456',
        paymentMethod: 'MPESA',
        transactionId: 'TXN12345',
        bankName: null,
        mobileNumber: '+255712345678',
        paymentDate: DateTime.now().subtract(const Duration(days: 10)),
        paymentStatus: 'COMPLETED',
        submissionDate: DateTime.now().subtract(const Duration(days: 12)),
        acknowledgmentNumber: 'ACK-2024-001',
        assessmentOfficer: null,
        assessmentNotes: null,
        businessSector: null,
        numberOfEmployees: null,
        isVATRegistered: false,
        hasPAYE: false,
        hasWithholdingTax: false,
        traRegion: 'DAR_ES_SALAAM',
        traBranch: null,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now().subtract(const Duration(days: 10)),
        assessedAt: DateTime.now().subtract(const Duration(days: 11)),
        completedAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
    ];
  }

  List<TaxRule> _generateMockTaxRules() {
    return [
      TaxRule(
        id: 1,
        ruleCode: 'PAYE_0',
        ruleName: 'PAYE 0% Slab',
        ruleType: 'PAYE',
        minIncome: 0,
        maxIncome: 270000,
        taxRate: 0,
        flatAmount: null,
        applicableFromYear: 2024,
        applicableToYear: 2025,
        isActive: true,
        conditions: null,
        priority: 1,
        createdAt: DateTime.now().subtract(const Duration(days: 100)),
        updatedAt: DateTime.now().subtract(const Duration(days: 50)),
      ),
      TaxRule(
        id: 2,
        ruleCode: 'VAT_18',
        ruleName: 'Value Added Tax',
        ruleType: 'VAT',
        minIncome: null,
        maxIncome: null,
        taxRate: 18,
        flatAmount: null,
        applicableFromYear: 2024,
        applicableToYear: 2025,
        isActive: true,
        conditions: null,
        priority: 1,
        createdAt: DateTime.now().subtract(const Duration(days: 100)),
        updatedAt: DateTime.now().subtract(const Duration(days: 50)),
      ),
    ];
  }
}
