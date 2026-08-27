import '../models/tax_rule.dart';
import 'api_service.dart';

class TaxRuleService {
  final ApiService _apiService = ApiService();

  Future<List<TaxRule>> getAllRules() async {
    try {
      final response = await _apiService.get('/tax-rules');
      final List<dynamic> rules =
          (response is List) ? response : (response['content'] ?? []);
      return rules.map((json) => TaxRule.fromJson(json)).toList();
    } catch (e) {
      return _getMockTaxRules();
    }
  }

  List<TaxRule> _getMockTaxRules() {
    return [
      TaxRule(
        id: 1,
        ruleCode: 'PAYE_0',
        ruleName: 'PAYE 0% Slab',
        ruleType: 'TAX_SLAB',
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
        ruleCode: 'PAYE_8',
        ruleName: 'PAYE 8% Slab',
        ruleType: 'TAX_SLAB',
        minIncome: 270001,
        maxIncome: 520000,
        taxRate: 8,
        flatAmount: null,
        applicableFromYear: 2024,
        applicableToYear: 2025,
        isActive: true,
        conditions: null,
        priority: 2,
        createdAt: DateTime.now().subtract(const Duration(days: 100)),
        updatedAt: DateTime.now().subtract(const Duration(days: 50)),
      ),
      TaxRule(
        id: 3,
        ruleCode: 'VAT_18',
        ruleName: 'Value Added Tax',
        ruleType: 'DEDUCTION',
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
