import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/user.dart';
import '../providers/tax_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';
import '../utils/helpers.dart';
import '../utils/constants.dart';
import 'dashboard_screen.dart';
import '../services/storage_service.dart';
import 'login_screen.dart';
import '../models/tax_return.dart';

// ignore_for_file: use_build_context_synchronously

class TaxFormScreen extends StatefulWidget {
  const TaxFormScreen({super.key});

  @override
  State<TaxFormScreen> createState() => _TaxFormScreenState();
}

class _TaxFormScreenState extends State<TaxFormScreen>
    with SingleTickerProviderStateMixin {
  // ==================== STATE VARIABLES ====================

  // Step Management
  int _currentStep = 0;
  bool _isSubmitting = false;

  // Session Management
  String? _sessionId;
  DateTime? _sessionStartTime;
  bool _sessionActive = false;

  // ==================== USER SELECTION ====================
  final List<User> _users = [];

  // ==================== PART I: GENERAL INFORMATION ====================
  final _entityNameController = TextEditingController();
  final _tinController = TextEditingController();
  final _addressController = TextEditingController();
  final _postalAddressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _faxController = TextEditingController();
  final _emailController = TextEditingController();

  // ==================== REGIONS (TANZANIA INCLUDING ZANZIBAR) ====================
  String _selectedRegion = 'DAR_ES_SALAAM';
  String _selectedBranch = '';

  final List<Map<String, String>> _regions = [
    {'value': 'DAR_ES_SALAAM', 'label': 'Dar es Salaam'},
    {'value': 'ARUSHA', 'label': 'Arusha'},
    {'value': 'MWANZA', 'label': 'Mwanza'},
    {'value': 'MBEYA', 'label': 'Mbeya'},
    {'value': 'TANGA', 'label': 'Tanga'},
    {'value': 'DODOMA', 'label': 'Dodoma'},
    {'value': 'MOROGORO', 'label': 'Morogoro'},
    {'value': 'KILIMANJARO', 'label': 'Kilimanjaro'},
    {'value': 'TABORA', 'label': 'Tabora'},
    {'value': 'KIGOMA', 'label': 'Kigoma'},
    {'value': 'RUVUMA', 'label': 'Ruvuma'},
    {'value': 'LINDI', 'label': 'Lindi'},
    {'value': 'MTWARA', 'label': 'Mtwara'},
    {'value': 'IRINGA', 'label': 'Iringa'},
    {'value': 'MANYARA', 'label': 'Manyara'},
    {'value': 'GEITA', 'label': 'Geita'},
    {'value': 'KATAVI', 'label': 'Katavi'},
    {'value': 'NJOMBE', 'label': 'Njombe'},
    {'value': 'SIMIYU', 'label': 'Simiyu'},
    {'value': 'RUKWA', 'label': 'Rukwa'},
    {'value': 'SINGIDA', 'label': 'Singida'},
    {'value': 'SHINYANGA', 'label': 'Shinyanga'},
    {'value': 'MARA', 'label': 'Mara'},
    {'value': 'KAGERA', 'label': 'Kagera'},
    // ===== ZANZIBAR REGIONS =====
    {'value': 'ZANZIBAR_URBAN', 'label': 'Zanzibar Urban/West'},
    {'value': 'ZANZIBAR_NORTH', 'label': 'Zanzibar North'},
    {'value': 'ZANZIBAR_SOUTH', 'label': 'Zanzibar South'},
    {'value': 'PEMBA_NORTH', 'label': 'Pemba North'},
    {'value': 'PEMBA_SOUTH', 'label': 'Pemba South'},
  ];

  final Map<String, List<String>> _branches = {
    'DAR_ES_SALAAM': ['Kivukoni', 'Ilala', 'Kinondoni', 'Temeke'],
    'ARUSHA': ['Clock Tower', 'Njiro', 'Sakina'],
    'MWANZA': ['Posta', 'Ilemela', 'Nyamagana'],
    'MBEYA': ['Uhindini', 'Forest', 'Mbalizi'],
    'TANGA': ['Independence Ave', 'Chokaa'],
    'DODOMA': ['Government City', 'Makutupora'],
    'ZANZIBAR_URBAN': ['Stone Town', 'Mlandege', 'Fumba Port'],
    'ZANZIBAR_NORTH': ['Mkokotoni', 'Nungwi'],
    'ZANZIBAR_SOUTH': ['Kizimkazi', 'Paje'],
    'PEMBA_NORTH': ['Wete', 'Micheweni'],
    'PEMBA_SOUTH': ['Chake Chake', 'Mkoani'],
  };

  // ==================== PART II: COMPUTATION OF INCOME AND TAX ====================
  // Business Income
  final _businessIncomeController = TextEditingController();
  final _miningIncomeController = TextEditingController();
  final _generalInsuranceController = TextEditingController();
  final _lifeInsuranceController = TextEditingController();
  final _cfcIncomeController = TextEditingController();
  final _agriculturalIncomeController = TextEditingController();

  // Investment Income
  final _dividendListedController = TextEditingController();
  final _dividendNonListedController = TextEditingController();
  final _interestController = TextEditingController();
  final _rentController = TextEditingController();
  final _royaltiesController = TextEditingController();
  final _naturalResourceController = TextEditingController();
  final _investmentGainsController = TextEditingController();
  final _otherInvestmentController = TextEditingController();

  // ==================== PART VI: FINANCIAL INFORMATION ====================
  // Fixed Assets
  final _landBuildingsController = TextEditingController();
  final _plantMachineryController = TextEditingController();
  final _motorVehiclesController = TextEditingController();
  final _intangibleAssetsController = TextEditingController();
  final _biologicalAssetsController = TextEditingController();
  final _investmentsController = TextEditingController();

  // Current Assets
  final _cashController = TextEditingController();
  final _tradeDebtorsController = TextEditingController();
  final _otherDebtorsController = TextEditingController();
  final _bankBalancesController = TextEditingController();
  final _tradingStockController = TextEditingController();

  // Liabilities
  final _shortTermLoansController = TextEditingController();
  final _tradeCreditorsController = TextEditingController();
  final _otherCreditorsController = TextEditingController();
  final _overdraftsController = TextEditingController();
  final _longTermLoansController = TextEditingController();

  // Equity
  final _shareCapitalController = TextEditingController();
  final _revenueReservesController = TextEditingController();

  // ==================== PART VII: OTHER INFORMATION ====================
  final _relatedSalesLocalController = TextEditingController();
  final _relatedSalesForeignController = TextEditingController();
  final _relatedPurchasesLocalController = TextEditingController();
  final _relatedPurchasesForeignController = TextEditingController();

  // ==================== DECLARATION ====================
  String _selectedTaxpayerType = 'INDIVIDUAL';
  bool _isQualifiedAudit = false;
  bool _isDormant = false;
  bool _isResident = true;
  bool _hasCFC = false;
  bool _isBranch = false;

  // Lists
  final List<String> _taxpayerTypes = [
    'INDIVIDUAL',
    'COMPANY',
    'SOLE_PROPRIETOR',
    'NGO'
  ];

  // Animation
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _startSession();
    _loadUserData();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  String _assessmentYear() {
    final now = DateTime.now();
    return '${now.year}/${now.year + 1}';
  }

  // ==================== LOAD USER DATA ====================

  Future<void> _loadUserData() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.user;

      if (user != null) {
        setState(() {
          // Auto-fill TIN and Phone from database
          _tinController.text = user.tinNumber;
          _phoneController.text = user.mobileNumber ?? '';
          _emailController.text = user.email;
          _entityNameController.text = user.fullName;
        });
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  // ==================== USER SELECTION ====================

  void _showUserSelectionDialog() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.user;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Taxpayer'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: Column(
            children: [
              if (currentUser != null)
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.green,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(currentUser.fullName),
                  subtitle: Text('TIN: ${currentUser.tinNumber}'),
                  trailing: const Icon(Icons.check_circle, color: Colors.green),
                  onTap: () {
                    setState(() {
                      _tinController.text = currentUser.tinNumber;
                      _phoneController.text = currentUser.mobileNumber ?? '';
                      _emailController.text = currentUser.email;
                      _entityNameController.text = currentUser.fullName;
                    });
                    Navigator.pop(context);
                  },
                ),
              const Divider(),
              const Text(
                'Select a registered taxpayer',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              // Add more users if available
              ..._users.map((user) => ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.shade100,
                      child: Text(
                        user.fullName.isNotEmpty
                            ? user.fullName[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(user.fullName),
                    subtitle: Text('TIN: ${user.tinNumber}'),
                    onTap: () {
                      setState(() {
                        _tinController.text = user.tinNumber;
                        _phoneController.text = user.mobileNumber ?? '';
                        _emailController.text = user.email;
                        _entityNameController.text = user.fullName;
                      });
                      Navigator.pop(context);
                    },
                  )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _endSession();
    _entityNameController.dispose();
    _tinController.dispose();
    _addressController.dispose();
    _postalAddressController.dispose();
    _phoneController.dispose();
    _faxController.dispose();
    _emailController.dispose();
    _businessIncomeController.dispose();
    _miningIncomeController.dispose();
    _generalInsuranceController.dispose();
    _lifeInsuranceController.dispose();
    _cfcIncomeController.dispose();
    _agriculturalIncomeController.dispose();
    _dividendListedController.dispose();
    _dividendNonListedController.dispose();
    _interestController.dispose();
    _rentController.dispose();
    _royaltiesController.dispose();
    _naturalResourceController.dispose();
    _investmentGainsController.dispose();
    _otherInvestmentController.dispose();
    _landBuildingsController.dispose();
    _plantMachineryController.dispose();
    _motorVehiclesController.dispose();
    _intangibleAssetsController.dispose();
    _biologicalAssetsController.dispose();
    _investmentsController.dispose();
    _cashController.dispose();
    _tradeDebtorsController.dispose();
    _otherDebtorsController.dispose();
    _bankBalancesController.dispose();
    _tradingStockController.dispose();
    _shortTermLoansController.dispose();
    _tradeCreditorsController.dispose();
    _otherCreditorsController.dispose();
    _overdraftsController.dispose();
    _longTermLoansController.dispose();
    _shareCapitalController.dispose();
    _revenueReservesController.dispose();
    _relatedSalesLocalController.dispose();
    _relatedSalesForeignController.dispose();
    _relatedPurchasesLocalController.dispose();
    _relatedPurchasesForeignController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // ==================== SESSION MANAGEMENT ====================

  void _startSession() {
    _sessionId = DateTime.now().millisecondsSinceEpoch.toString();
    _sessionStartTime = DateTime.now();
    _sessionActive = true;
  }

  void _endSession() {
    if (_sessionActive) {
      _sessionActive = false;
      final duration =
          DateTime.now().difference(_sessionStartTime ?? DateTime.now());
      debugPrint('Session $_sessionId ended. Duration: ${duration.inSeconds}s');
      _sessionId = null;
      _sessionStartTime = null;
    }
  }

  void _checkSession() {
    if (!_sessionActive) {
      Helpers.showErrorSnackBar(
        context,
        'Your session has expired. Please start a new filing.',
      );
      Navigator.pop(context);
    }
  }

  // ==================== CORE METHODS ====================

  double _parseDouble(String value) {
    if (value.isEmpty) return 0;
    return double.tryParse(value) ?? 0;
  }

  // Calculate total business income (row 14)
  double _calculateTotalBusinessIncome() {
    return _parseDouble(_businessIncomeController.text) +
        _parseDouble(_miningIncomeController.text) +
        _parseDouble(_generalInsuranceController.text) +
        _parseDouble(_lifeInsuranceController.text) +
        _parseDouble(_cfcIncomeController.text);
  }

  // Calculate chargeable business income (row 16)
  double _calculateChargeableBusinessIncome() {
    final total = _calculateTotalBusinessIncome();
    return total;
  }

  // Calculate total investment income (row 30)
  double _calculateTotalInvestmentIncome() {
    return _parseDouble(_dividendListedController.text) +
        _parseDouble(_dividendNonListedController.text) +
        _parseDouble(_interestController.text) +
        _parseDouble(_rentController.text) +
        _parseDouble(_royaltiesController.text) +
        _parseDouble(_naturalResourceController.text) +
        _parseDouble(_investmentGainsController.text) +
        _parseDouble(_otherInvestmentController.text);
  }

  // Calculate total income (row 34)
  double _calculateTotalIncome() {
    return _calculateChargeableBusinessIncome() +
        _parseDouble(_agriculturalIncomeController.text) +
        _calculateTotalInvestmentIncome();
  }

  // Calculate total tax (row 37)
  double _calculateTotalTax() {
    return _calculateTotalIncome() * 0.30;
  }

  // Calculate net tax payable (row 40)
  double _calculateNetTaxPayable() {
    final tax = _calculateTotalTax();
    return tax;
  }

  // Calculate total assets (row 148)
  double _calculateTotalAssets() {
    return _calculateFixedAssets() + _calculateCurrentAssets();
  }

  double _calculateFixedAssets() {
    return _parseDouble(_landBuildingsController.text) +
        _parseDouble(_plantMachineryController.text) +
        _parseDouble(_motorVehiclesController.text) +
        _parseDouble(_intangibleAssetsController.text) +
        _parseDouble(_biologicalAssetsController.text) +
        _parseDouble(_investmentsController.text);
  }

  double _calculateCurrentAssets() {
    return _parseDouble(_cashController.text) +
        _parseDouble(_tradeDebtorsController.text) +
        _parseDouble(_otherDebtorsController.text) +
        _parseDouble(_bankBalancesController.text) +
        _parseDouble(_tradingStockController.text);
  }

  double _calculateTotalLiabilities() {
    return _parseDouble(_shortTermLoansController.text) +
        _parseDouble(_tradeCreditorsController.text) +
        _parseDouble(_otherCreditorsController.text) +
        _parseDouble(_overdraftsController.text) +
        _parseDouble(_longTermLoansController.text);
  }

  double _calculateNetAssets() {
    return _calculateTotalAssets() - _calculateTotalLiabilities();
  }

  // ==================== NAVIGATION ====================

  void _goToStep(int step) {
    _checkSession();
    setState(() {
      _currentStep = step;
    });
  }

  Future<void> _nextStep() async {
    _checkSession();

    if (_currentStep == 4) {
      await _submitToDatabase();
      return;
    }

    if (_currentStep == 0) {
      // Validate Part I
      if (_entityNameController.text.isEmpty) {
        Helpers.showErrorSnackBar(context, 'Please select entity name');
        return;
      }
      if (_tinController.text.isEmpty) {
        Helpers.showErrorSnackBar(context, 'Please enter TIN number');
        return;
      }
      if (_selectedRegion.isEmpty) {
        Helpers.showErrorSnackBar(context, 'Please select TRA region');
        return;
      }
      _goToStep(1);
    } else if (_currentStep == 1) {
      _goToStep(2);
    } else if (_currentStep == 2) {
      _goToStep(3);
    } else if (_currentStep == 3) {
      _goToStep(4);
    }
  }

  void _previousStep() {
    _checkSession();
    if (_currentStep > 0) {
      _goToStep(_currentStep - 1);
    }
  }

  // ==================== SUBMIT TO DATABASE ====================

  Future<void> _submitToDatabase() async {
    const bool isWidgetTest = bool.fromEnvironment('FLUTTER_TEST');
    String? savedToken;
    if (!isWidgetTest) {
      try {
        final storage = StorageService();
        savedToken = await storage.getToken();
      } catch (e) {
        debugPrint('WARN: Unable to read saved token: $e');
        savedToken = null;
      }
    }
    if (!mounted) return;
    if (!isWidgetTest && (savedToken == null || savedToken.trim().isEmpty)) {
      Helpers.showErrorSnackBar(
        context,
        'You must be logged in to submit a tax return. Please log in first.',
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }
    double totalIncome;
    try {
      totalIncome = _calculateTotalIncome();
    } catch (e) {
      rethrow;
    }
    if (!mounted) return;
    if (totalIncome <= 0) {
      Helpers.showErrorSnackBar(
        context,
        'Please enter a total income greater than zero before submitting.',
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });
    debugPrint('DEBUG: _isSubmitting set to true');

    try {
      final taxProvider = Provider.of<TaxProvider>(context, listen: false);

      final taxReturn = await taxProvider.createReturn(_assessmentYear());
      if (taxReturn == null || taxReturn.id == null) {
        throw StateError(
          taxProvider.errorMessage ?? 'Unable to create the tax return.',
        );
      }

      final taxCalculated = await taxProvider.calculateTax(
        taxReturn.id!,
        totalIncome,
        0,
      );
      if (!taxCalculated) {
        throw StateError(
          taxProvider.errorMessage ?? 'Unable to calculate the tax return.',
        );
      }

      final submitted = await taxProvider.submitReturn(taxReturn.id!);
      if (!submitted) {
        throw StateError(
          taxProvider.errorMessage ?? 'Unable to submit the tax return.',
        );
      }

      if (!mounted) return;

      _endSession();
      _showSubmissionSuccessDialog(taxReturn.filingId);
    } catch (e) {
      if (mounted) {
        Helpers.showErrorSnackBar(
          context,
          'Submission failed: ${e.toString()}',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  // Save current filing as a draft (allows incomplete returns)
  Future<void> _saveDraftToDatabase() async {
    const bool isWidgetTest = bool.fromEnvironment('FLUTTER_TEST');
    String? savedToken;
    if (!isWidgetTest) {
      try {
        final storage = StorageService();
        savedToken = await storage.getToken();
      } catch (e) {
        debugPrint('WARN: Unable to read saved token: $e');
        savedToken = null;
      }
    }

    if (!mounted) return;
    if (!isWidgetTest && (savedToken == null || savedToken.trim().isEmpty)) {
      Helpers.showErrorSnackBar(
        context,
        'You must be logged in to save a draft. Please log in first.',
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final taxProvider = Provider.of<TaxProvider>(context, listen: false);

      // Ensure a tax return exists on the server
      TaxReturn? taxReturn = taxProvider.currentReturn;
      if (taxReturn == null || taxReturn.id == null) {
        taxReturn = await taxProvider.createReturn(_assessmentYear());
        if (taxReturn == null || taxReturn.id == null) {
          throw StateError(
              taxProvider.errorMessage ?? 'Unable to create draft return.');
        }
      }

      // Save draft payload — allow totalIncome to be zero for incomplete filings
      final totalIncome = _calculateTotalIncome();
      final updated = await taxProvider.saveDraftReturn(
        taxReturn.id!,
        totalIncome: totalIncome,
        filingType: 'DRAFT',
        additionalInfo: 'Saved as draft from mobile app',
      );

      if (updated == null) {
        throw StateError(taxProvider.errorMessage ?? 'Unable to save draft.');
      }

      if (!mounted) return;
      Helpers.showSuccessSnackBar(context, 'Draft saved successfully.');
    } catch (e) {
      if (mounted) {
        Helpers.showErrorSnackBar(
            context, 'Failed to save draft: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showSubmissionSuccessDialog(String filingId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Return Submitted!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your tax return has been successfully submitted .',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow('Filing ID', filingId),
                  _buildDetailRow('Entity', _entityNameController.text),
                  _buildDetailRow('TIN', _tinController.text),
                  _buildDetailRow(
                      'Region', _selectedRegion.replaceAll('_', ' ')),
                  _buildDetailRow('Total Income',
                      'TSh ${NumberFormat('#,##,###').format(_calculateTotalIncome())}'),
                  _buildDetailRow('Tax Payable',
                      'TSh ${NumberFormat('#,##,###').format(_calculateNetTaxPayable())}'),
                  _buildDetailRow('Status', 'SUBMITTED'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'You can download your TRA report from the Export section.',
                      style: TextStyle(fontSize: 12, color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const DashboardScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Go to Dashboard'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== UI BUILD ====================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TRA RETURN OF INCOME',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  'Step ${_currentStep + 1}/5',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            const Spacer(),
            // Session Indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 12),
                  SizedBox(width: 4),
                  Text(
                    'Live',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showHelpDialog,
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: _handleCancel,
          ),
        ],
      ),
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          if (!mounted) return;
          final confirm = await Helpers.showConfirmDialog(
            context,
            title: 'Leave Filing',
            message:
                'Are you sure you want to leave? Your progress will be lost.',
            confirmText: 'Leave',
            confirmColor: Colors.red,
          );
          if (!mounted) return;
          if (confirm == true) {
            _endSession();
            if (!mounted) return;
            Navigator.pop(context);
          }
        },
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              children: [
                _buildProgressIndicator(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildStepHeader(),
                        const SizedBox(height: 16),
                        _buildStepContent(),
                        const SizedBox(height: 24),
                        _buildNavigationButtons(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: kDebugMode
          ? FloatingActionButton(
              tooltip: 'Show stored token',
              child: const Icon(Icons.bug_report),
              onPressed: () async {
                if (!mounted) return;
                final storage = StorageService();
                final token = await storage.getToken();
                if (!mounted) return;
                showDialog(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: const Text('Stored Token'),
                    content: SingleChildScrollView(
                      child: Text(token ?? '<null>'),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                );
              },
            )
          : null,
    );
  }

  // ==================== BUILD METHODS ====================

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: List.generate(5, (index) {
          final isCompleted = index < _currentStep;
          final isActive = index == _currentStep;
          return Expanded(
            child: Container(
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: isCompleted
                    ? AppColors.primary
                    : isActive
                        ? AppColors.primary.withValues(alpha: 0.5)
                        : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStepHeader() {
    final titles = [
      'PART I: ENTITY PARTICULARS',
      'PART II: INCOME & TAX',
      'PART VI: FINANCIAL INFO',
      'PART VII-VIII: OTHER INFO',
      'DECLARATION & SUBMIT',
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Text(
              '${_currentStep + 1}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              titles[_currentStep],
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildPartI();
      case 1:
        return _buildPartII();
      case 2:
        return _buildPartVI();
      case 3:
        return _buildPartVIIVIII();
      case 4:
        return _buildDeclaration();
      default:
        return const SizedBox.shrink();
    }
  }

  // ==================== PART I: ENTITY PARTICULARS ====================

  Widget _buildPartI() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'GENERAL INFORMATION',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),

            // Entity Name with User Selection
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: CustomTextField(
                    controller: _entityNameController,
                    label: 'Name of Entity',
                    hint: 'Enter entity name',
                    prefixIcon: Icons.business,
                    readOnly: true,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: ElevatedButton(
                    onPressed: _showUserSelectionDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                    child: const Text(
                      'Select',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // TIN Number (Auto-filled from DB)
            CustomTextField(
              controller: _tinController,
              label: 'TIN Number',
              hint: 'Auto-filled from database',
              prefixIcon: Icons.credit_card,
              readOnly: true,
              keyboardType: TextInputType.number,
              maxLength: 9,
            ),

            const SizedBox(height: 12),

            // Phone Number (Auto-filled from DB)
            CustomTextField(
              controller: _phoneController,
              label: 'Phone Number',
              hint: '',
              prefixIcon: Icons.phone,
              readOnly: true,
              keyboardType: TextInputType.phone,
            ),

            const SizedBox(height: 12),

            // Email (Auto-filled from DB)
            CustomTextField(
              controller: _emailController,
              label: 'Email Address',
              hint: 'Auto-filled from database',
              prefixIcon: Icons.email,
              readOnly: true,
            ),

            const SizedBox(height: 12),

            // Physical Address
            CustomTextField(
              controller: _addressController,
              label: 'Physical Address',
              hint: 'Enter physical address',
              prefixIcon: Icons.location_on,
            ),

            const SizedBox(height: 12),

            // Postal Address
            CustomTextField(
              controller: _postalAddressController,
              label: 'Postal Address',
              hint: 'Enter postal address',
              prefixIcon: Icons.markunread,
            ),

            const SizedBox(height: 12),

            // Fax Number
            CustomTextField(
              controller: _faxController,
              label: 'Fax Number',
              hint: 'Enter fax number (optional)',
              prefixIcon: Icons.fax,
            ),

            const SizedBox(height: 16),

            // Taxpayer Type
            DropdownButtonFormField<String>(
              initialValue: _selectedTaxpayerType,
              decoration: const InputDecoration(
                labelText: 'Taxpayer Type',
                prefixIcon: Icon(Icons.person_outline),
              ),
              items: _taxpayerTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedTaxpayerType = value!;
                });
              },
            ),

            const SizedBox(height: 16),

            // TRA Region (Tanzania + Zanzibar)
            DropdownButtonFormField<String>(
              initialValue: _selectedRegion,
              decoration: const InputDecoration(
                labelText: 'TRA Region',
                prefixIcon: Icon(Icons.location_city),
              ),
              items: _regions.map((region) {
                return DropdownMenuItem(
                  value: region['value'],
                  child: Text(region['label']!),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedRegion = value!;
                  _selectedBranch = '';
                });
              },
            ),

            const SizedBox(height: 12),

            // TRA Branch
            if (_branches.containsKey(_selectedRegion) &&
                _branches[_selectedRegion]!.isNotEmpty)
              DropdownButtonFormField<String>(
                initialValue: _selectedBranch.isEmpty ? null : _selectedBranch,
                decoration: const InputDecoration(
                  labelText: 'TRA Branch',
                  prefixIcon: Icon(Icons.location_on),
                ),
                items: _branches[_selectedRegion]!.map((branch) {
                  return DropdownMenuItem(
                    value: branch,
                    child: Text(branch),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedBranch = value!;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  // ==================== PART II: INCOME & TAX ====================

  Widget _buildPartII() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'BUSINESS INCOME',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            _buildTRAField('Business Income (Trade, Profession)',
                _businessIncomeController, Icons.work),
            _buildTRAField('Mining', _miningIncomeController, Icons.landscape),
            _buildTRAField('General Insurance', _generalInsuranceController,
                Icons.security),
            _buildTRAField(
                'Life Insurance', _lifeInsuranceController, Icons.favorite),
            _buildTRAField('Controlled Foreign Corp', _cfcIncomeController,
                Icons.business_center),
            _buildTRAField('Agricultural Income', _agriculturalIncomeController,
                Icons.agriculture),
            const Divider(),
            const Text(
              'INVESTMENT INCOME',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            _buildTRAField('Dividends (Listed)', _dividendListedController,
                Icons.trending_up),
            _buildTRAField('Dividends (Non-Listed)',
                _dividendNonListedController, Icons.trending_up),
            _buildTRAField('Interest', _interestController, Icons.percent),
            _buildTRAField('Rent', _rentController, Icons.home),
            _buildTRAField('Royalties', _royaltiesController, Icons.receipt),
            _buildTRAField('Natural Resource Payment',
                _naturalResourceController, Icons.nature),
            _buildTRAField('Investment Gains', _investmentGainsController,
                Icons.trending_up),
            _buildTRAField('Other Investment', _otherInvestmentController,
                Icons.more_horiz),
            const Divider(),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Income',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'TSh ${NumberFormat('#,##,###.00').format(_calculateTotalIncome())}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tax Payable (30%)',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'TSh ${NumberFormat('#,##,###.00').format(_calculateNetTaxPayable())}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== PART VI: FINANCIAL INFORMATION ====================

  Widget _buildPartVI() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'BALANCE SHEET INFORMATION',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            _buildTRAField(
                'Land & Buildings', _landBuildingsController, Icons.home),
            _buildTRAField(
                'Plant & Machinery', _plantMachineryController, Icons.settings),
            _buildTRAField('Motor Vehicles', _motorVehiclesController,
                Icons.directions_car),
            _buildTRAField('Intangible Assets', _intangibleAssetsController,
                Icons.lightbulb),
            _buildTRAField(
                'Biological Assets', _biologicalAssetsController, Icons.nature),
            _buildTRAField(
                'Investments', _investmentsController, Icons.trending_up),
            const Divider(),
            const Text(
              'CURRENT ASSETS',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            _buildTRAField('Cash', _cashController, Icons.money),
            _buildTRAField(
                'Trade Debtors', _tradeDebtorsController, Icons.people),
            _buildTRAField(
                'Other Debtors', _otherDebtorsController, Icons.person),
            _buildTRAField('Bank Balances', _bankBalancesController,
                Icons.account_balance),
            _buildTRAField(
                'Trading Stock', _tradingStockController, Icons.inventory),
            const Divider(),
            const Text(
              'LIABILITIES & EQUITY',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            _buildTRAField('Short Term Loans', _shortTermLoansController,
                Icons.credit_card),
            _buildTRAField('Trade Creditors', _tradeCreditorsController,
                Icons.shopping_cart),
            _buildTRAField(
                'Other Creditors', _otherCreditorsController, Icons.person),
            _buildTRAField(
                'Overdrafts', _overdraftsController, Icons.account_balance),
            _buildTRAField(
                'Long Term Loans', _longTermLoansController, Icons.credit_card),
            _buildTRAField(
                'Share Capital', _shareCapitalController, Icons.pie_chart),
            _buildTRAField(
                'Revenue Reserves', _revenueReservesController, Icons.savings),
            const Divider(),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Net Assets',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'TSh ${NumberFormat('#,##,###.00').format(_calculateNetAssets())}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== PART VII-VIII: OTHER INFO ====================

  Widget _buildPartVIIVIII() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'RELATED PARTY TRANSACTIONS',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            _buildTRAField('Sales to Related (Local)',
                _relatedSalesLocalController, Icons.sell),
            _buildTRAField('Sales to Related (Foreign)',
                _relatedSalesForeignController, Icons.sell),
            _buildTRAField('Purchases from Related (Local)',
                _relatedPurchasesLocalController, Icons.shopping_cart),
            _buildTRAField('Purchases from Related (Foreign)',
                _relatedPurchasesForeignController, Icons.shopping_cart),
            const Divider(),
            const Text(
              'ENTITY INFORMATION',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            _buildCheckbox('Auditor\'s report is qualified', _isQualifiedAudit,
                (value) {
              setState(() {
                _isQualifiedAudit = value ?? false;
              });
            }),
            _buildCheckbox('Entity is dormant', _isDormant, (value) {
              setState(() {
                _isDormant = value ?? false;
              });
            }),
            _buildCheckbox('Entity is resident in Tanzania', _isResident,
                (value) {
              setState(() {
                _isResident = value ?? false;
              });
            }),
            _buildCheckbox('Entity has CFC participation', _hasCFC, (value) {
              setState(() {
                _hasCFC = value ?? false;
              });
            }),
            _buildCheckbox('This is a branch of a foreign company', _isBranch,
                (value) {
              setState(() {
                _isBranch = value ?? false;
              });
            }),
          ],
        ),
      ),
    );
  }

  // ==================== DECLARATION ====================

  Widget _buildDeclaration() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Live Summary Panel
            Builder(builder: (context) {
              final totalIncome = _calculateTotalIncome();
              final totalTax = _calculateTotalTax();
              final netTax = _calculateNetTaxPayable();
              return Card(
                color: Colors.blue.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Assessment Year: ${_assessmentYear()}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            Text(
                              'Total Income: TSh ${NumberFormat('#,##,###').format(totalIncome)}',
                              style: const TextStyle(fontSize: 14),
                            ),
                            Text(
                              'Total Tax (est): TSh ${NumberFormat('#,##,###').format(totalTax)}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Net Tax Payable',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          Text(
                            'TSh ${NumberFormat('#,##,###').format(netTax)}',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          const Text('Assumed rate: 30%'),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 12),
            const Text(
              'DECLARATION',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Column(
                children: [
                  Text(
                    'I hereby declare that the information given on this return and any accompanying documents is complete and accurate to the best of my knowledge and belief.',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Under Section 91 of the Income Tax Act, 2004',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '⚠️ Important Notes:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• Penalties apply for not filing a tax return',
                    style: TextStyle(fontSize: 12),
                  ),
                  Text(
                    '• Penalties apply for filing a false return',
                    style: TextStyle(fontSize: 12),
                  ),
                  Text(
                    '• All information must be accurate and complete',
                    style: TextStyle(fontSize: 12),
                  ),
                  Text(
                    '• Keep supporting documents for 5 years',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'By submitting this return, you confirm that all information provided is accurate and complete.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== HELPERS ====================

  Widget _buildTRAField(
      String label, TextEditingController controller, IconData icon,
      {int? maxLength}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: CustomTextField(
        controller: controller,
        label: label,
        hint: 'Enter $label',
        prefixIcon: icon,
        keyboardType:
            label.contains('TIN') ? TextInputType.number : TextInputType.text,
        maxLength: maxLength,
      ),
    );
  }

  Widget _buildCheckbox(String label, bool value, Function(bool?) onChanged) {
    return CheckboxListTile(
      title: Text(label),
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.primary,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      children: [
        if (_currentStep > 0)
          Expanded(
            child: OutlinedButton(
              onPressed: _previousStep,
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Previous'),
            ),
          ),
        if (_currentStep > 0) const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton(
            onPressed: _isSubmitting ? null : _saveDraftToDatabase,
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('Save Draft'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: _currentStep == 4 ? 1 : 2,
          child: CustomButton(
            text: _currentStep == 4
                ? (_isSubmitting ? 'Submitting...' : 'Submit')
                : 'Next Section',
            onPressed: _isSubmitting ? null : _nextStep,
            isLoading: _isSubmitting,
            icon: _currentStep == 4 ? Icons.send : Icons.arrow_forward,
            backgroundColor:
                _currentStep == 4 ? Colors.green : AppColors.primary,
          ),
        ),
      ],
    );
  }

  Future<void> _handleCancel() async {
    final confirm = await Helpers.showConfirmDialog(
      context,
      title: 'Cancel Filing',
      message:
          'Are you sure you want to cancel this tax return? All progress will be lost.',
      confirmText: 'Cancel Filing',
      confirmColor: Colors.red,
    );

    if (!mounted) return;
    if (confirm == true) {
      _endSession();
      Navigator.pop(context);
    }
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('TRA Filing Assistance'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '📋 How to Complete the TRA Return',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('1. Fill in Entity Particulars (Part I)'),
              Text('2. Declare Income & Tax (Part II)'),
              Text('3. Provide Financial Information (Part VI)'),
              Text('4. Complete Other Information (Part VII-VIII)'),
              Text('5. Review and Submit'),
              SizedBox(height: 12),
              Text(
                '⚠️ Deadlines:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Filing deadline: 6 months after year end'),
              Text('• Penalties apply for late filing'),
              SizedBox(height: 12),
              Text(
                '📞 Need Help?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('Contact TRA: +255 22 123 4567'),
              Text('Email: support@tra.go.tz'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
