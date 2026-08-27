import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';

class AdvancedSearchWidget extends StatefulWidget {
  final Function(Map<String, dynamic>) onApply;
  final VoidCallback onClear;

  const AdvancedSearchWidget({
    super.key,
    required this.onApply,
    required this.onClear,
  });

  @override
  State<AdvancedSearchWidget> createState() => _AdvancedSearchWidgetState();
}

class _AdvancedSearchWidgetState extends State<AdvancedSearchWidget> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _dateFromController = TextEditingController();
  final _dateToController = TextEditingController();
  final _amountMinController = TextEditingController();
  final _amountMaxController = TextEditingController();

  // Dropdown values
  String? _selectedStatus;
  String? _selectedType;
  String? _selectedYear;
  String? _selectedPaymentMethod;

  // Lists
  final List<String> _statuses = [
    'All',
    'DRAFT',
    'SUBMITTED',
    'PROCESSING',
    'ASSESSED',
    'COMPLETED',
    'REJECTED',
  ];
  final List<String> _types = ['All', 'ORIGINAL', 'REVISED', 'BELATED'];
  final List<String> _years = [
    'All',
    '2024/2025',
    '2023/2024',
    '2022/2023',
    '2021/2022'
  ];
  final List<String> _paymentMethods = [
    'All',
    'MPESA',
    'TIGOPESA',
    'AIRTEL_MONEY',
    'HALOPESA',
    'BANK_TRANSFER',
    'CASH',
    'CARD',
  ];

  @override
  void dispose() {
    _dateFromController.dispose();
    _dateToController.dispose();
    _amountMinController.dispose();
    _amountMaxController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final filters = <String, dynamic>{};

      if (_selectedStatus != null && _selectedStatus != 'All') {
        filters['status'] = _selectedStatus;
      }
      if (_selectedType != null && _selectedType != 'All') {
        filters['filingType'] = _selectedType;
      }
      if (_selectedYear != null && _selectedYear != 'All') {
        filters['assessmentYear'] = _selectedYear;
      }
      if (_selectedPaymentMethod != null && _selectedPaymentMethod != 'All') {
        filters['paymentMethod'] = _selectedPaymentMethod;
      }
      if (_dateFromController.text.isNotEmpty) {
        filters['dateFrom'] = _dateFromController.text;
      }
      if (_dateToController.text.isNotEmpty) {
        filters['dateTo'] = _dateToController.text;
      }
      if (_amountMinController.text.isNotEmpty) {
        filters['amountMin'] = double.tryParse(_amountMinController.text);
      }
      if (_amountMaxController.text.isNotEmpty) {
        filters['amountMax'] = double.tryParse(_amountMaxController.text);
      }

      widget.onApply(filters);
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedStatus = null;
      _selectedType = null;
      _selectedYear = null;
      _selectedPaymentMethod = null;
      _dateFromController.clear();
      _dateToController.clear();
      _amountMinController.clear();
      _amountMaxController.clear();
    });
    widget.onClear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Advanced Search',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: _clearFilters,
                  child: const Text(
                    'Clear All',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
            const Divider(),

            // Status & Type
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      prefixIcon: Icon(Icons.label),
                    ),
                    items: _statuses.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(status),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedStatus = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Filing Type',
                      prefixIcon: Icon(Icons.type_specimen),
                    ),
                    items: _types.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedType = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Year & Payment Method
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedYear,
                    decoration: const InputDecoration(
                      labelText: 'Assessment Year',
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    items: _years.map((year) {
                      return DropdownMenuItem(
                        value: year,
                        child: Text(year),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedYear = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedPaymentMethod,
                    decoration: const InputDecoration(
                      labelText: 'Payment Method',
                      prefixIcon: Icon(Icons.payment),
                    ),
                    items: _paymentMethods.map((method) {
                      return DropdownMenuItem(
                        value: method,
                        child: Text(method),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedPaymentMethod = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Date Range
            Row(
              children: [
                Expanded(
                  child: _buildDateField(
                    controller: _dateFromController,
                    label: 'Date From',
                    onTap: () => _selectDate(_dateFromController),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDateField(
                    controller: _dateToController,
                    label: 'Date To',
                    onTap: () => _selectDate(_dateToController),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Amount Range
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _amountMinController,
                    label: 'Min Amount (TSh)',
                    hint: '0',
                    prefixIcon: Icons.attach_money,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomTextField(
                    controller: _amountMaxController,
                    label: 'Max Amount (TSh)',
                    hint: '1000000',
                    prefixIcon: Icons.attach_money,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Apply & Cancel Buttons
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Apply Filters',
                    onPressed: _applyFilters,
                    backgroundColor: const Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    text: 'Cancel',
                    onPressed: () {
                      _clearFilters();
                    },
                    isOutlined: true,
                    backgroundColor: Colors.grey.shade300,
                    textColor: Colors.black87,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AbsorbPointer(
        child: CustomTextField(
          controller: controller,
          label: label,
          hint: 'Select date',
          prefixIcon: Icons.date_range,
          readOnly: true,
        ),
      ),
    );
  }

  Future<void> _selectDate(TextEditingController controller) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2E7D32),
              onPrimary: Colors.white,
              onSurface: Color(0xFF2E7D32),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      controller.text =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    }
  }
}
