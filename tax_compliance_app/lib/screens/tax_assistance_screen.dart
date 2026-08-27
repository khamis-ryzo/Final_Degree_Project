import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/tax_provider.dart';
import '../providers/auth_provider.dart';
import '../services/tax_assistance_service.dart';
import '../services/tra_report_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';
import '../utils/helpers.dart';
import '../utils/constants.dart';
import 'tax_result_screen.dart';

class TaxAssistanceScreen extends StatefulWidget {
  const TaxAssistanceScreen({super.key});

  @override
  State<TaxAssistanceScreen> createState() => _TaxAssistanceScreenState();
}

class _TaxAssistanceScreenState extends State<TaxAssistanceScreen> {
  int _currentStep = 0;

  // Controllers for income fields
  final _employmentIncomeController = TextEditingController();
  final _businessIncomeController = TextEditingController();
  final _rentalIncomeController = TextEditingController();
  final _agriculturalIncomeController = TextEditingController();
  final _capitalGainsController = TextEditingController();
  final _interestIncomeController = TextEditingController();
  final _dividendIncomeController = TextEditingController();
  final _otherIncomeController = TextEditingController();

  // Controllers for deduction fields
  final _pensionReliefController = TextEditingController();
  final _insuranceReliefController = TextEditingController();
  final _medicalExpensesController = TextEditingController();
  final _charitableDonationsController = TextEditingController();
  final _educationExpensesController = TextEditingController();
  final _mortgageInterestController = TextEditingController();
  final _businessExpensesController = TextEditingController();
  final _otherDeductionsController = TextEditingController();

  // Dropdown values
  String _selectedAssessmentYear = '2024/2025';
  String _selectedFilingType = 'ORIGINAL';

  // State flags
  bool _hasBusinessIncome = false;
  bool _hasRentalIncome = false;
  bool _hasAgriculturalIncome = false;
  bool _hasCapitalGains = false;
  bool _hasInvestmentIncome = false;

  // Validation
  FilingValidationResult? _validationResult;
  bool _isCalculating = false;

  final List<String> _assessmentYears = [
    '2024/2025',
    '2023/2024',
    '2022/2023',
    '2021/2022',
  ];

  final List<String> _filingTypes = ['ORIGINAL', 'REVISED', 'BELATED'];

  @override
  void dispose() {
    _employmentIncomeController.dispose();
    _businessIncomeController.dispose();
    _rentalIncomeController.dispose();
    _agriculturalIncomeController.dispose();
    _capitalGainsController.dispose();
    _interestIncomeController.dispose();
    _dividendIncomeController.dispose();
    _otherIncomeController.dispose();
    _pensionReliefController.dispose();
    _insuranceReliefController.dispose();
    _medicalExpensesController.dispose();
    _charitableDonationsController.dispose();
    _educationExpensesController.dispose();
    _mortgageInterestController.dispose();
    _businessExpensesController.dispose();
    _otherDeductionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final steps = TaxAssistanceService.getFilingSteps();
    final currentStepData = steps[_currentStep];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Filing Assistant'),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Step ${_currentStep + 1}/${steps.length}',
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Progress Indicator
          _buildProgressIndicator(steps.length),

          // Step Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildStepHeader(currentStepData),
                  const SizedBox(height: 16),
                  _buildStepContent(currentStepData),
                  const SizedBox(height: 24),
                  _buildNavigationButtons(steps.length),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(int totalSteps) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: List.generate(totalSteps, (index) {
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

  Widget _buildStepHeader(FilingStep step) {
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
            child: Icon(step.icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  step.description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent(FilingStep step) {
    switch (step.id) {
      case 1:
        return _buildPersonalInfoStep();
      case 2:
        return _buildIncomeStep();
      case 3:
        return _buildDeductionStep();
      case 4:
        return _buildCalculationStep();
      case 5:
        return _buildPaymentStep();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildPersonalInfoStep() {
    final user = Provider.of<AuthProvider>(context).user;

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
            _buildInfoDisplay('Full Name', user?.fullName ?? 'N/A'),
            _buildInfoDisplay('TIN Number', user?.tinNumber ?? 'N/A'),
            _buildInfoDisplay('Email', user?.email ?? 'N/A'),
            _buildInfoDisplay('Mobile', user?.mobileNumber ?? 'N/A'),
            const Divider(),
            DropdownButtonFormField<String>(
              initialValue: _selectedAssessmentYear,
              decoration: const InputDecoration(
                labelText: 'Assessment Year',
                prefixIcon: Icon(Icons.calendar_today),
              ),
              items: _assessmentYears.map((year) {
                return DropdownMenuItem(
                  value: year,
                  child: Text(year),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedAssessmentYear = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedFilingType,
              decoration: const InputDecoration(
                labelText: 'Filing Type',
                prefixIcon: Icon(Icons.description),
              ),
              items: _filingTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedFilingType = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            _buildAssistanceTips([
              'Ensure your TIN number is correct',
              'Select the correct assessment year',
              'Choose the right filing type',
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomeStep() {
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
              'Declare Your Income',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Enter all your income sources for the assessment year',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),

            // Employment Income (Required)
            _buildIncomeField(
              controller: _employmentIncomeController,
              label: 'Employment Income',
              hint: 'Enter your annual salary',
              icon: Icons.work_outline,
              required: true,
              fieldName: 'employmentIncome',
            ),

            // Business Income
            SwitchListTile(
              title: const Text('Have Business/Professional Income?'),
              value: _hasBusinessIncome,
              onChanged: (value) {
                setState(() {
                  _hasBusinessIncome = value;
                  if (!value) _businessIncomeController.clear();
                });
              },
              activeThumbColor: AppColors.primary,
            ),
            if (_hasBusinessIncome)
              _buildIncomeField(
                controller: _businessIncomeController,
                label: 'Business Income',
                hint: 'Enter business/professional income',
                icon: Icons.business_center,
                required: true,
                fieldName: 'businessIncome',
              ),

            // Rental Income
            SwitchListTile(
              title: const Text('Have Rental Income?'),
              value: _hasRentalIncome,
              onChanged: (value) {
                setState(() {
                  _hasRentalIncome = value;
                  if (!value) _rentalIncomeController.clear();
                });
              },
              activeThumbColor: AppColors.primary,
            ),
            if (_hasRentalIncome)
              _buildIncomeField(
                controller: _rentalIncomeController,
                label: 'Rental Income',
                hint: 'Enter rental income from properties',
                icon: Icons.home_work,
                required: true,
                fieldName: 'rentalIncome',
              ),

            // Agricultural Income
            SwitchListTile(
              title: const Text('Have Agricultural Income?'),
              value: _hasAgriculturalIncome,
              onChanged: (value) {
                setState(() {
                  _hasAgriculturalIncome = value;
                  if (!value) _agriculturalIncomeController.clear();
                });
              },
              activeThumbColor: AppColors.primary,
            ),
            if (_hasAgriculturalIncome)
              _buildIncomeField(
                controller: _agriculturalIncomeController,
                label: 'Agricultural Income',
                hint: 'Enter farming/agricultural income',
                icon: Icons.agriculture,
                required: true,
                fieldName: 'agriculturalIncome',
              ),

            // Capital Gains
            SwitchListTile(
              title: const Text('Have Capital Gains?'),
              value: _hasCapitalGains,
              onChanged: (value) {
                setState(() {
                  _hasCapitalGains = value;
                  if (!value) _capitalGainsController.clear();
                });
              },
              activeThumbColor: AppColors.primary,
            ),
            if (_hasCapitalGains)
              _buildIncomeField(
                controller: _capitalGainsController,
                label: 'Capital Gains',
                hint: 'Enter capital gains from assets',
                icon: Icons.trending_up,
                required: true,
                fieldName: 'capitalGains',
              ),

            // Investment Income
            SwitchListTile(
              title: const Text('Have Investment Income?'),
              value: _hasInvestmentIncome,
              onChanged: (value) {
                setState(() {
                  _hasInvestmentIncome = value;
                  if (!value) {
                    _interestIncomeController.clear();
                    _dividendIncomeController.clear();
                  }
                });
              },
              activeThumbColor: AppColors.primary,
            ),
            if (_hasInvestmentIncome) ...[
              _buildIncomeField(
                controller: _interestIncomeController,
                label: 'Interest Income',
                hint: 'Enter interest from savings/investments',
                icon: Icons.savings,
                required: true,
                fieldName: 'interestIncome',
              ),
              const SizedBox(height: 8),
              _buildIncomeField(
                controller: _dividendIncomeController,
                label: 'Dividend Income',
                hint: 'Enter dividends from shares',
                icon: Icons.trending_up,
                required: true,
                fieldName: 'dividendIncome',
              ),
            ],

            const Divider(),
            _buildIncomeField(
              controller: _otherIncomeController,
              label: 'Other Income',
              hint: 'Enter any other income not listed',
              icon: Icons.more_horiz,
              required: false,
              fieldName: 'otherIncome',
            ),

            const SizedBox(height: 16),
            _buildAssistanceTips([
              'Include all income from all sources',
              'Ensure amounts are accurate',
              'Keep all income documents for verification',
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildDeductionStep() {
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
              'Claim Deductions & Reliefs',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Enter all eligible deductions to reduce your tax liability',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            _buildDeductionField(
              controller: _pensionReliefController,
              label: 'Pension Contributions',
              hint: 'Enter pension contributions',
              icon: Icons.savings,
              fieldName: 'pensionRelief',
            ),
            _buildDeductionField(
              controller: _insuranceReliefController,
              label: 'Insurance Premiums',
              hint: 'Enter insurance premiums paid',
              icon: Icons.security,
              fieldName: 'insuranceRelief',
            ),
            _buildDeductionField(
              controller: _medicalExpensesController,
              label: 'Medical Expenses',
              hint: 'Enter medical expenses (max TSh 100,000)',
              icon: Icons.medical_services,
              fieldName: 'medicalExpenses',
            ),
            _buildDeductionField(
              controller: _charitableDonationsController,
              label: 'Charitable Donations',
              hint: 'Enter donations to registered charities',
              icon: Icons.favorite,
              fieldName: 'charitableDonations',
            ),
            _buildDeductionField(
              controller: _educationExpensesController,
              label: 'Education Expenses',
              hint: 'Enter education/tuition expenses',
              icon: Icons.school,
              fieldName: 'educationExpenses',
            ),
            _buildDeductionField(
              controller: _mortgageInterestController,
              label: 'Mortgage Interest',
              hint: 'Enter mortgage interest paid',
              icon: Icons.home,
              fieldName: 'mortgageInterest',
            ),
            if (_hasBusinessIncome)
              _buildDeductionField(
                controller: _businessExpensesController,
                label: 'Business Expenses',
                hint: 'Enter business expenses claimed',
                icon: Icons.business_center,
                fieldName: 'businessExpenses',
              ),
            const Divider(),
            _buildDeductionField(
              controller: _otherDeductionsController,
              label: 'Other Deductions',
              hint: 'Enter any other deductions',
              icon: Icons.more_horiz,
              fieldName: 'otherDeductions',
            ),
            const SizedBox(height: 16),
            _buildAssistanceTips([
              'Personal Relief of TSh 270,000 is automatically applied',
              'Keep receipts for all deductions claimed',
              'Ensure all donations are to registered organizations',
              'Medical expenses require documentation',
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculationStep() {
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
              'Review & Validate',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Review your filing data before proceeding to submission',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            _buildSummaryRow('Income Summary'),
            const Divider(),
            _buildSummaryItem(
                'Employment Income', _employmentIncomeController.text),
            if (_hasBusinessIncome)
              _buildSummaryItem(
                  'Business Income', _businessIncomeController.text),
            if (_hasRentalIncome)
              _buildSummaryItem('Rental Income', _rentalIncomeController.text),
            if (_hasAgriculturalIncome)
              _buildSummaryItem(
                  'Agricultural Income', _agriculturalIncomeController.text),
            if (_hasCapitalGains)
              _buildSummaryItem('Capital Gains', _capitalGainsController.text),
            if (_hasInvestmentIncome) ...[
              _buildSummaryItem(
                  'Interest Income', _interestIncomeController.text),
              _buildSummaryItem(
                  'Dividend Income', _dividendIncomeController.text),
            ],
            _buildSummaryItem('Other Income', _otherIncomeController.text),
            const SizedBox(height: 12),
            _buildSummaryRow('Deductions Summary'),
            const Divider(),
            _buildSummaryItem('Pension Relief', _pensionReliefController.text),
            _buildSummaryItem(
                'Insurance Relief', _insuranceReliefController.text),
            _buildSummaryItem(
                'Medical Expenses', _medicalExpensesController.text),
            _buildSummaryItem(
                'Charitable Donations', _charitableDonationsController.text),
            _buildSummaryItem(
                'Education Expenses', _educationExpensesController.text),
            _buildSummaryItem(
                'Mortgage Interest', _mortgageInterestController.text),
            if (_hasBusinessIncome)
              _buildSummaryItem(
                  'Business Expenses', _businessExpensesController.text),
            _buildSummaryItem(
                'Other Deductions', _otherDeductionsController.text),
            if (_validationResult != null) ...[
              const SizedBox(height: 16),
              _buildValidationResult(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentStep() {
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
              'Payment & Submission',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Complete your payment and submit your return to TRA',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.payment, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Payment Options',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildPaymentOption(
                      'M-Pesa', 'Dial *150*00#', Icons.phone_android),
                  _buildPaymentOption(
                      'Tigo Pesa', 'Dial *150*01#', Icons.phone_android),
                  _buildPaymentOption(
                      'Airtel Money', 'Dial *150*02#', Icons.phone_android),
                  _buildPaymentOption('Bank Transfer', 'Any commercial bank',
                      Icons.account_balance),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildAssistanceTips([
              'Control number is generated after payment',
              'Keep your payment receipt for reference',
              'Acknowledgment number is sent to your email',
              'Submission deadline is 30th June',
            ]),
          ],
        ),
      ),
    );
  }

  // ==================== HELPER WIDGETS ====================

  Widget _buildIncomeField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool required = false,
    required String fieldName,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextField(
            controller: controller,
            label: label,
            hint: hint,
            prefixIcon: icon,
            keyboardType: TextInputType.number,
            validator: required
                ? (value) {
                    if (value == null || value.isEmpty) {
                      return '$label is required';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid amount';
                    }
                    return null;
                  }
                : null,
            onTap: () {
              // Show assistance when field is tapped
              _showFieldAssistance(fieldName);
            },
          ),
          const SizedBox(height: 4),
          Text(
            TaxAssistanceService.getFieldAssistance(fieldName),
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeductionField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required String fieldName,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextField(
            controller: controller,
            label: label,
            hint: hint,
            prefixIcon: icon,
            keyboardType: TextInputType.number,
            onTap: () {
              _showFieldAssistance(fieldName);
            },
          ),
          const SizedBox(height: 4),
          Text(
            TaxAssistanceService.getFieldAssistance(fieldName),
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoDisplay(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
              ),
            ),
          ),
          Text(': ', style: TextStyle(color: Colors.grey.shade600)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssistanceTips(List<String> tips) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.amber.shade700),
              const SizedBox(width: 8),
              Text(
                '💡 Tips',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.amber.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...tips.map((tip) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ', style: TextStyle(color: Colors.amber.shade700)),
                    Expanded(
                      child: Text(
                        tip,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.amber.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    final amount = double.tryParse(value) ?? 0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13),
          ),
          Text(
            'TSh ${NumberFormat('#,###.00').format(amount)}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: amount > 0 ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(String name, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.blue.shade700),
          const SizedBox(width: 8),
          Text(
            '$name: $description',
            style: TextStyle(
              fontSize: 12,
              color: Colors.blue.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValidationResult() {
    if (_validationResult == null) return const SizedBox.shrink();

    final result = _validationResult!;
    List<Widget> widgets = [];

    if (result.errors.isNotEmpty) {
      widgets
          .add(_buildValidationSection('❌ Errors', result.errors, Colors.red));
    }
    if (result.warnings.isNotEmpty) {
      widgets.add(_buildValidationSection(
          '⚠️ Warnings', result.warnings, Colors.orange));
    }
    if (result.suggestions.isNotEmpty) {
      widgets.add(_buildValidationSection(
          '💡 Suggestions', result.suggestions, Colors.blue));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        Row(
          children: [
            Icon(
              result.isValid ? Icons.check_circle : Icons.error,
              color: result.isValid ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 8),
            Text(
              result.isValid
                  ? '✅ All validations passed!'
                  : '❌ Please fix the errors',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: result.isValid ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
        ...widgets,
      ],
    );
  }

  Widget _buildValidationSection(
      String title, List<String> items, Color color) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ', style: TextStyle(color: color)),
                    Expanded(
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: 12,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  void _showFieldAssistance(String fieldName) {
    final assistance = TaxAssistanceService.getFieldAssistance(fieldName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.help_outline, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Field Assistance'),
          ],
        ),
        content: Text(assistance),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  // ==================== NAVIGATION ====================

  Widget _buildNavigationButtons(int totalSteps) {
    return Row(
      children: [
        if (_currentStep > 0)
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                setState(() {
                  _currentStep--;
                });
              },
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
          flex: 2,
          child: CustomButton(
            text:
                _currentStep == totalSteps - 1 ? 'Submit to TRA' : 'Next Step',
            onPressed: _isCalculating ? null : _handleNextStep,
            isLoading: _isCalculating,
            icon: _currentStep == totalSteps - 1
                ? Icons.send
                : Icons.arrow_forward,
            backgroundColor: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Future<void> _handleNextStep() async {
    if (_currentStep == 0) {
      // Validate personal info
      setState(() {
        _currentStep++;
      });
    } else if (_currentStep == 1) {
      // Validate income
      final totalIncome = _parseDouble(_employmentIncomeController.text) +
          (_hasBusinessIncome
              ? _parseDouble(_businessIncomeController.text)
              : 0) +
          (_hasRentalIncome ? _parseDouble(_rentalIncomeController.text) : 0) +
          (_hasAgriculturalIncome
              ? _parseDouble(_agriculturalIncomeController.text)
              : 0) +
          (_hasCapitalGains ? _parseDouble(_capitalGainsController.text) : 0) +
          (_hasInvestmentIncome
              ? _parseDouble(_interestIncomeController.text)
              : 0) +
          (_hasInvestmentIncome
              ? _parseDouble(_dividendIncomeController.text)
              : 0) +
          _parseDouble(_otherIncomeController.text);

      if (totalIncome <= 0) {
        Helpers.showErrorSnackBar(context, 'Please enter your income details');
        return;
      }
      setState(() {
        _currentStep++;
      });
    } else if (_currentStep == 2) {
      // Validate deductions
      setState(() {
        _currentStep++;
      });
    } else if (_currentStep == 3) {
      // Validate and calculate
      await _validateAndCalculate();
    } else if (_currentStep == 4) {
      // Submit to TRA
      await _submitToTRA();
    }
  }

  Future<void> _validateAndCalculate() async {
    setState(() {
      _isCalculating = true;
    });

    try {
      // Prepare filing data
      final Map<String, dynamic> filingData = {
        'tinNumber':
            Provider.of<AuthProvider>(context, listen: false).user?.tinNumber,
        'employmentIncome': _parseDouble(_employmentIncomeController.text),
        'businessIncome': _parseDouble(_businessIncomeController.text),
        'rentalIncome': _parseDouble(_rentalIncomeController.text),
        'agriculturalIncome': _parseDouble(_agriculturalIncomeController.text),
        'capitalGains': _parseDouble(_capitalGainsController.text),
        'interestIncome': _parseDouble(_interestIncomeController.text),
        'dividendIncome': _parseDouble(_dividendIncomeController.text),
        'otherIncome': _parseDouble(_otherIncomeController.text),
        'totalIncome': _calculateTotalIncome(),
        'pensionRelief': _parseDouble(_pensionReliefController.text),
        'insuranceRelief': _parseDouble(_insuranceReliefController.text),
        'medicalExpenses': _parseDouble(_medicalExpensesController.text),
        'charitableDonations':
            _parseDouble(_charitableDonationsController.text),
        'educationExpenses': _parseDouble(_educationExpensesController.text),
        'mortgageInterest': _parseDouble(_mortgageInterestController.text),
        'businessExpenses': _parseDouble(_businessExpensesController.text),
        'otherDeductions': _parseDouble(_otherDeductionsController.text),
        'totalDeductions': _calculateTotalDeductions(),
      };

      // Validate filing data
      final result = TaxAssistanceService.validateFiling(filingData);
      setState(() {
        _validationResult = result;
      });

      if (!result.isValid) {
        Helpers.showErrorSnackBar(
          context,
          'Please fix the errors before proceeding',
        );
        setState(() {
          _isCalculating = false;
        });
        return;
      }

      // Calculate tax
      final taxProvider = Provider.of<TaxProvider>(context, listen: false);
      final user = Provider.of<AuthProvider>(context, listen: false).user;

      // Create tax return
      final taxReturn = await taxProvider.createReturn(_selectedAssessmentYear);

      if (taxReturn != null) {
        // Calculate tax
        final success = await taxProvider.calculateTax(
          taxReturn.id!,
          filingData['totalIncome'],
          filingData['totalDeductions'],
        );

        if (success && mounted) {
          // Generate TRA Report
          final report = await TRAReportService.generateTRAReport(
            taxReturn,
            user!,
            {
              'taxPayable': taxProvider.calculationResult?.taxPayable ?? 0,
              'skillsLevy': taxProvider.calculationResult?.skillsLevy ?? 0,
              'railwayLevy': taxProvider.calculationResult?.railwayLevy ?? 0,
              'cess': taxProvider.calculationResult?.cess ?? 0,
              'totalLiability': taxProvider.calculationResult?.totalTax ?? 0,
            },
          );

          if (!mounted) return;

          // Navigate to result screen with report
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TaxResultScreen(
                taxReturn: taxReturn,
                calculationResult: taxProvider.calculationResult!,
                report: report,
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      Helpers.showErrorSnackBar(context, 'Error: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isCalculating = false;
        });
      }
    }
  }

  Future<void> _submitToTRA() async {
    final confirm = await Helpers.showConfirmDialog(
      context,
      title: 'Submit to TRA',
      message:
          'Are you sure you want to submit this tax return to Tanzania Revenue Authority?',
      confirmText: 'Submit',
    );

    if (confirm == true) {
      if (!mounted) return;
      try {
        final taxProvider = Provider.of<TaxProvider>(context, listen: false);
        final success =
            await taxProvider.submitReturn(taxProvider.currentReturn!.id!);

        if (success && mounted) {
          Helpers.showSuccessSnackBar(
            context,
            'Tax return submitted to TRA successfully!',
          );
          Navigator.pop(context);
        } else if (mounted) {
          Helpers.showErrorSnackBar(
            context,
            taxProvider.errorMessage ?? 'Submission failed',
          );
        }
      } catch (e) {
        if (!mounted) return;
        Helpers.showErrorSnackBar(context, 'Error: ${e.toString()}');
      }
    }
  }

  double _parseDouble(String value) {
    if (value.isEmpty) return 0;
    return double.tryParse(value) ?? 0;
  }

  double _calculateTotalIncome() {
    return _parseDouble(_employmentIncomeController.text) +
        (_hasBusinessIncome
            ? _parseDouble(_businessIncomeController.text)
            : 0) +
        (_hasRentalIncome ? _parseDouble(_rentalIncomeController.text) : 0) +
        (_hasAgriculturalIncome
            ? _parseDouble(_agriculturalIncomeController.text)
            : 0) +
        (_hasCapitalGains ? _parseDouble(_capitalGainsController.text) : 0) +
        (_hasInvestmentIncome
            ? _parseDouble(_interestIncomeController.text)
            : 0) +
        (_hasInvestmentIncome
            ? _parseDouble(_dividendIncomeController.text)
            : 0) +
        _parseDouble(_otherIncomeController.text);
  }

  double _calculateTotalDeductions() {
    return _parseDouble(_pensionReliefController.text) +
        _parseDouble(_insuranceReliefController.text) +
        _parseDouble(_medicalExpensesController.text) +
        _parseDouble(_charitableDonationsController.text) +
        _parseDouble(_educationExpensesController.text) +
        _parseDouble(_mortgageInterestController.text) +
        _parseDouble(_businessExpensesController.text) +
        _parseDouble(_otherDeductionsController.text);
  }
}
