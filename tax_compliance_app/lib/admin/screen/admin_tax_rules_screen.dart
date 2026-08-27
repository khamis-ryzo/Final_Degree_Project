import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/tax_rule.dart';
import '../providers/admin_provider.dart';

class AdminTaxRulesScreen extends StatelessWidget {
  const AdminTaxRulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final adminProvider = Provider.of<AdminProvider>(context);

    if (adminProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final rules = adminProvider.allTaxRules;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        elevation: 0,
        title: Text(
          'Tax Rules',
          style: TextStyle(color: Colors.grey.shade900),
        ),
      ),
      body: rules.isEmpty
          ? const Center(child: Text('No tax rules found'))
          : RefreshIndicator(
              onRefresh: adminProvider.loadAdminData,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: rules.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final rule = rules[index];
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
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
                        Switch(
                          value: rule.isActive,
                          activeThumbColor: Colors.green,
                          onChanged: (_) =>
                              adminProvider.toggleTaxRuleStatus(rule.id!),
                        ),
                      ],
                    ),
                  );
                },
              ),
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
      return rule.incomeRange;
    }
    return 'Applicable: ${rule.applicableYearRange}';
  }
}
