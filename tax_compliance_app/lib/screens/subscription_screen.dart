import 'package:flutter/material.dart';
import '../models/subscription.dart';
import '../services/subscription_service.dart';
import '../utils/helpers.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  static const double monthlyFee = 5000;
  static const double yearlyFee = 50000;

  final SubscriptionService _subscriptionService = SubscriptionService();

  Subscription? _subscription;
  bool _isLoading = true;
  bool _isProcessing = false;
  String _selectedCycle = 'MONTHLY';
  final bool _autoRenew = false;
  String _lastPaymentMethod = 'M-Pesa';

  @override
  void initState() {
    super.initState();
    _loadSubscription();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadSubscription() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final subscription = await _subscriptionService.getMySubscription();
      if (!mounted) return;
      setState(() {
        _subscription = subscription;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      Helpers.showErrorSnackBar(context, 'Failed to load subscription: $e');
    }
  }

  double get _selectedFee =>
      _selectedCycle == 'MONTHLY' ? monthlyFee : yearlyFee;

  Future<void> _startCheckout() async {
    final result = await showModalBottomSheet<(Subscription, String)>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => _SubscriptionPaymentSheet(
        cycle: _selectedCycle,
        fee: _selectedFee,
        onSubscribe: (billingCycle) => _subscriptionService.subscribe(
          SubscriptionRequest(
            plan: 'PREMIUM',
            billingCycle: billingCycle,
            autoRenew: _autoRenew,
          ),
        ),
      ),
    );
    if (result != null && mounted) {
      final (subscription, providerName) = result;
      _lastPaymentMethod = providerName;
      setState(() {
        _subscription = subscription;
      });
      _showPaymentSuccessDialog();
    }
  }

  void _showPaymentSuccessDialog() {
    final controlNumber =
        'TZ${DateTime.now().millisecondsSinceEpoch.toString().substring(0, 10)}';
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Subscription Active!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _successRow('Plan', 'Premium (${_selectedCycle == 'MONTHLY' ? 'Monthly' : 'Yearly'})'),
            const Divider(),
            _successRow('Amount Paid', 'TSh ${_selectedFee.toStringAsFixed(0)}'),
            const Divider(),
            _successRow('Control Number', controlNumber),
            const Divider(),
            _successRow('Payment Method', _paymentMethodName),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Please save this control number for your records',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
            ),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  String get _paymentMethodName => _lastPaymentMethod;

  Widget _successRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmCancel() async {
    final confirmed = await Helpers.showConfirmDialog(
      context,
      title: 'Cancel Subscription',
      message: 'Are you sure you want to cancel your Premium subscription? '
          'You will lose premium features immediately.',
      confirmText: 'Cancel Subscription',
      confirmColor: Colors.red,
    );
    if (confirmed != true || !mounted) return;

    setState(() {
      _isProcessing = true;
    });
    try {
      final subscription = await _subscriptionService.cancel();
      if (!mounted) return;
      setState(() {
        _subscription = subscription;
        _isProcessing = false;
      });
      Helpers.showSuccessSnackBar(context, 'Subscription cancelled');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
      });
      Helpers.showErrorSnackBar(context, 'Failed to cancel subscription: $e');
    }
  }

  Future<void> _downgradeToFree() async {
    final confirmed = await Helpers.showConfirmDialog(
      context,
      title: 'Downgrade to Free',
      message: 'Switch to the Free plan? You will lose premium features at '
          'the end of the current billing period.',
      confirmText: 'Downgrade',
      confirmColor: Colors.orange,
    );
    if (confirmed != true || !mounted) return;

    setState(() {
      _isProcessing = true;
    });
    try {
      final subscription = await _subscriptionService.subscribe(
        SubscriptionRequest(plan: 'FREE'),
      );
      if (!mounted) return;
      setState(() {
        _subscription = subscription;
        _isProcessing = false;
      });
      Helpers.showSuccessSnackBar(context, 'Downgraded to Free plan');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
      });
      Helpers.showErrorSnackBar(context, 'Failed to downgrade plan: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Subscription'),
        backgroundColor: const Color(0xFF1976D2),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSubscription,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(),
    );
  }

  Widget _buildBody() {
    final subscription = _subscription;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (subscription != null) ...[
            _buildCurrentPlanCard(subscription),
            const SizedBox(height: 20),
          ],
          _buildPlansHeader(),
          const SizedBox(height: 8),
          _buildPlanCard(
            title: 'Free',
            fee: 0,
            features: const [
              'Basic tax calculation',
              'Single return filing',
              'Email support',
            ],
            isSelected: subscription != null &&
                !subscription.isPremium &&
                subscription.isActive,
            isPremium: false,
            onTap: subscription != null && subscription.isPremium
                ? _downgradeToFree
                : null,
          ),
          const SizedBox(height: 12),
          _buildPlanCard(
            title: 'Premium Monthly',
            fee: monthlyFee,
            features: const [
              'Unlimited tax calculations',
              'Priority TRA processing',
              'Advanced tax assistant',
              'Document storage & sharing',
            ],
            isSelected: subscription != null &&
                subscription.isPremium &&
                subscription.billingCycle == 'MONTHLY',
            isPremium: true,
            onTap: () {
              setState(() {
                _selectedCycle = 'MONTHLY';
              });
              _startCheckout();
            },
          ),
          const SizedBox(height: 12),
          _buildPlanCard(
            title: 'Premium Yearly',
            fee: yearlyFee,
            features: const [
              'Everything in Premium Monthly',
              'Save 2 months (TSh 10,000)',
              'Best value',
            ],
            isSelected: subscription != null &&
                subscription.isPremium &&
                subscription.billingCycle == 'YEARLY',
            isPremium: true,
            onTap: () {
              setState(() {
                _selectedCycle = 'YEARLY';
              });
              _startCheckout();
            },
          ),
          if (subscription != null &&
              subscription.isPremium &&
              subscription.isActive) ...[
            const SizedBox(height: 24),
            CustomButton(
              text: 'Cancel Subscription',
              onPressed: _isProcessing ? null : _confirmCancel,
              isLoading: _isProcessing,
              isOutlined: true,
              backgroundColor: Colors.red,
              textColor: Colors.red,
              height: 52,
            ),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildCurrentPlanCard(Subscription subscription) {
    final isPremium = subscription.isPremium;
    final color = isPremium
        ? const Color(0xFF1976D2)
        : Colors.grey.shade700;
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withValues(alpha: 0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isPremium ? Icons.workspace_premium : Icons.person_outline,
                  color: Colors.white,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subscription.planDisplayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subscription.statusDisplayName,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _planMetric('Billing Cycle', subscription.cycleDisplayName),
                _planMetric('Days Remaining',
                    subscription.daysRemaining >= 0
                        ? '${subscription.daysRemaining}'
                        : 'N/A'),
                if (subscription.expiryDate != null)
                  _planMetric(
                    'Expiry',
                    '${subscription.expiryDate!.day}/${subscription.expiryDate!.month}/${subscription.expiryDate!.year}',
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _planMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildPlansHeader() {
    return const Text(
      'Choose Your Plan',
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildPlanCard({
    required String title,
    required double fee,
    required List<String> features,
    required bool isSelected,
    required bool isPremium,
    required VoidCallback? onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected
              ? (isPremium ? const Color(0xFF1976D2) : Colors.grey)
              : Colors.grey.shade200,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isPremium ? const Color(0xFF1976D2) : null,
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: isPremium
                          ? const Color(0xFF1976D2)
                          : Colors.grey,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                fee == 0
                    ? 'Free forever'
                    : 'TSh ${fee.toStringAsFixed(0)}'
                        '${title.contains('Yearly') ? ' / year' : ' / month'}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ...features.map((feature) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check,
                          size: 18,
                          color: isPremium
                              ? const Color(0xFF1976D2)
                              : Colors.green,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            feature,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
              if (onTap != null && !isSelected) ...[
                const SizedBox(height: 12),
                CustomButton(
                  text: fee == 0 ? 'Current Plan' : 'Choose $title',
                  onPressed: onTap,
                  backgroundColor: isPremium
                      ? const Color(0xFF1976D2)
                      : Colors.grey.shade600,
                  height: 44,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SubscriptionPaymentSheet extends StatefulWidget {
  final String cycle;
  final double fee;
  final Future<Subscription> Function(String billingCycle) onSubscribe;

  const _SubscriptionPaymentSheet({
    required this.cycle,
    required this.fee,
    required this.onSubscribe,
  });

  @override
  State<_SubscriptionPaymentSheet> createState() =>
      _SubscriptionPaymentSheetState();
}

class _SubscriptionPaymentSheetState extends State<_SubscriptionPaymentSheet> {
  static const _providers = [
    ('M-Pesa', Icons.phone_android),
    ('Tigo Pesa', Icons.phone_iphone),
    ('Airtel Money', Icons.money),
    ('HaloPesa', Icons.account_balance_wallet),
  ];

  String _selectedProvider = _providers.first.$1;
  final _mobileController = TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _mobileController.dispose();
    super.dispose();
  }

  Future<void> _processPayment() async {
    if (!Helpers.isValidTanzanianMobile(_mobileController.text)) {
      Helpers.showErrorSnackBar(
          context, 'Please enter a valid Tanzanian mobile number');
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      final subscription = await widget.onSubscribe(widget.cycle);
      if (!mounted) return;
      Navigator.pop(context, (subscription, _selectedProvider));
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
      });
      Helpers.showErrorSnackBar(
          context, 'Payment failed. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Payment Details',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Upgrade to Premium (${widget.cycle == 'MONTHLY' ? 'Monthly' : 'Yearly'})',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          _buildPaymentMethodSelector(),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _mobileController,
            label: 'Mobile Number',
            hint: 'Enter mobile number (e.g., 0712345678)',
            prefixIcon: Icons.phone_android,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Amount',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              Text(
                'TSh ${widget.fee.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1976D2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          CustomButton(
            text: 'Pay Now - TSh ${widget.fee.toStringAsFixed(0)}',
            onPressed: _isProcessing ? null : _processPayment,
            isLoading: _isProcessing,
            icon: Icons.payment,
            backgroundColor: const Color(0xFF1976D2),
            height: 56,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _providers.map((provider) {
        final isSelected = _selectedProvider == provider.$1;
        return FilterChip(
          label: Text(provider.$1),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _selectedProvider = provider.$1;
            });
          },
          selectedColor: Colors.blue.withValues(alpha: 0.2),
          checkmarkColor: const Color(0xFF1976D2),
          avatar: Icon(
            provider.$2,
            color: isSelected ? const Color(0xFF1976D2) : Colors.grey,
            size: 16,
          ),
        );
      }).toList(),
    );
  }
}
