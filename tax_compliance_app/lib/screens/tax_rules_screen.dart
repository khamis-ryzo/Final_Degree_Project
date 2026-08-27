import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/tax_rule.dart';
import '../providers/tax_provider.dart';

class TaxRulesScreen extends StatefulWidget {
  const TaxRulesScreen({super.key});

  @override
  State<TaxRulesScreen> createState() => _TaxRulesScreenState();
}

class _TaxRulesScreenState extends State<TaxRulesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadRules();
    });
  }

  Future<void> _loadRules() async {
    final taxProvider = Provider.of<TaxProvider>(context, listen: false);
    if (taxProvider.taxRules.isEmpty) {
      await taxProvider.loadTaxRules();
    }
  }

  @override
  Widget build(BuildContext context) {
    final taxProvider = Provider.of<TaxProvider>(context);
    final rules = taxProvider.taxRules;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tax Rules'),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: taxProvider.loadTaxRules,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: taxProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : rules.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadRules,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: rules.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final rule = rules[index];
                      return _buildRuleCard(rule);
                    },
                  ),
                ),
    );
  }

  Widget _buildRuleCard(TaxRule rule) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: rule.ruleTypeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              rule.ruleTypeIcon,
              color: rule.ruleTypeColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rule.ruleName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${rule.ruleCode}  •  ${rule.ruleTypeDisplay}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _ruleValue(rule),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: (rule.isActive ? Colors.green : Colors.grey)
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              rule.isActive ? 'Active' : 'Inactive',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: rule.isActive ? Colors.green : Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _ruleValue(TaxRule rule) {
    if (rule.taxRate != null) {
      return 'Rate: ${rule.taxRate!.toStringAsFixed(2)}%';
    }
    if (rule.flatAmount != null) {
      return 'Flat: TSh ${rule.flatAmount!.toStringAsFixed(0)}';
    }
    if (rule.minIncome != null || rule.maxIncome != null) {
      return 'Income: ${rule.incomeRange}';
    }
    return 'Applicable: ${rule.applicableYearRange}';
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.rule, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No tax rules available',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
