import 'package:flutter/material.dart';

class TaxRule {
  final int? id;
  final String ruleCode;
  final String ruleName;
  final String ruleType;
  final int? applicableFromYear;
  final int? applicableToYear;
  final double? minIncome;
  final double? maxIncome;
  final double? taxRate;
  final double? flatAmount;
  final String? percentageOf;
  final double? maxLimit;
  final String? conditions;
  final int priority;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TaxRule({
    this.id,
    required this.ruleCode,
    required this.ruleName,
    required this.ruleType,
    this.applicableFromYear,
    this.applicableToYear,
    this.minIncome,
    this.maxIncome,
    this.taxRate,
    this.flatAmount,
    this.percentageOf,
    this.maxLimit,
    this.conditions,
    required this.priority,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory TaxRule.fromJson(Map<String, dynamic> json) {
    return TaxRule(
      id: json['id'],
      ruleCode: json['ruleCode'] ?? '',
      ruleName: json['ruleName'] ?? '',
      ruleType: json['ruleType'] ?? '',
      applicableFromYear: json['applicableFromYear'],
      applicableToYear: json['applicableToYear'],
      minIncome: json['minIncome']?.toDouble(),
      maxIncome: json['maxIncome']?.toDouble(),
      taxRate: json['taxRate']?.toDouble(),
      flatAmount: json['flatAmount']?.toDouble(),
      percentageOf: json['percentageOf'],
      maxLimit: json['maxLimit']?.toDouble(),
      conditions: json['conditions'],
      priority: json['priority'] ?? 0,
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ruleCode': ruleCode,
      'ruleName': ruleName,
      'ruleType': ruleType,
      'applicableFromYear': applicableFromYear,
      'applicableToYear': applicableToYear,
      'minIncome': minIncome,
      'maxIncome': maxIncome,
      'taxRate': taxRate,
      'flatAmount': flatAmount,
      'percentageOf': percentageOf,
      'maxLimit': maxLimit,
      'conditions': conditions,
      'priority': priority,
      'isActive': isActive,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Helper properties for UI
  String get ruleTypeDisplay {
    switch (ruleType) {
      case 'TAX_SLAB':
        return 'Tax Slab';
      case 'DEDUCTION':
        return 'Deduction';
      case 'CESS':
        return 'Cess';
      case 'SURCHARGE':
        return 'Surcharge';
      case 'INTEREST':
        return 'Interest';
      default:
        return ruleType;
    }
  }

  Color get ruleTypeColor {
    switch (ruleType) {
      case 'TAX_SLAB':
        return Colors.blue;
      case 'DEDUCTION':
        return Colors.green;
      case 'CESS':
        return Colors.orange;
      case 'SURCHARGE':
        return Colors.red;
      case 'INTEREST':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData get ruleTypeIcon {
    switch (ruleType) {
      case 'TAX_SLAB':
        return Icons.pie_chart;
      case 'DEDUCTION':
        return Icons.card_giftcard;
      case 'CESS':
        return Icons.percent;
      case 'SURCHARGE':
        return Icons.add_circle;
      case 'INTEREST':
        return Icons.trending_up;
      default:
        return Icons.rule;
    }
  }

  String get formattedTaxRate {
    if (taxRate != null) {
      return '${taxRate!.toStringAsFixed(2)}%';
    }
    return 'N/A';
  }

  String get formattedFlatAmount {
    if (flatAmount != null) {
      return '₹${flatAmount!.toStringAsFixed(2)}';
    }
    return 'N/A';
  }

  String get incomeRange {
    final min = minIncome != null ? '₹${minIncome!.toStringAsFixed(0)}' : '0';
    final max = maxIncome != null ? '₹${maxIncome!.toStringAsFixed(0)}' : '∞';
    return '$min - $max';
  }

  String get applicableYearRange {
    if (applicableFromYear != null && applicableToYear != null) {
      return 'FY ${applicableFromYear!}-${(applicableToYear! % 100).toString().padLeft(2, '0')}';
    }
    return 'All Years';
  }

  String get ruleDescription {
    switch (ruleType) {
      case 'TAX_SLAB':
        return 'Income between $incomeRange is taxed at $formattedTaxRate';
      case 'DEDUCTION':
        if (flatAmount != null) {
          return 'Flat deduction of $formattedFlatAmount';
        } else if (percentageOf == 'INCOME') {
          return '$formattedTaxRate of income (Max: ${maxLimit != null ? '₹${maxLimit!.toStringAsFixed(0)}' : 'No limit'})';
        }
        return '$ruleName - $formattedTaxRate';
      case 'CESS':
        return '$formattedTaxRate on total tax payable';
      default:
        return ruleName;
    }
  }

  // Method to calculate tax based on this rule
  double calculate(double amount) {
    switch (ruleType) {
      case 'TAX_SLAB':
        if (taxRate != null) {
          double taxableAmount = 0;
          if (minIncome != null && amount > minIncome!) {
            if (maxIncome != null) {
              taxableAmount = amount > maxIncome! 
                  ? maxIncome! - minIncome! 
                  : amount - minIncome!;
            } else {
              taxableAmount = amount - minIncome!;
            }
          }
          return taxableAmount * (taxRate! / 100);
        }
        return 0;

      case 'DEDUCTION':
        if (flatAmount != null) {
          return flatAmount!;
        } else if (taxRate != null && percentageOf == 'INCOME') {
          double deduction = amount * (taxRate! / 100);
          if (maxLimit != null && deduction > maxLimit!) {
            deduction = maxLimit!;
          }
          return deduction;
        }
        return 0;

      case 'CESS':
        if (taxRate != null) {
          return amount * (taxRate! / 100);
        }
        return 0;

      default:
        return 0;
    }
  }

  // Check if this rule applies to given income
  bool appliesTo(double income, int year) {
    if (!isActive) return false;
    
    // Check year applicability
    if (applicableFromYear != null && year < applicableFromYear!) return false;
    if (applicableToYear != null && year > applicableToYear!) return false;
    
    // Check income range for tax slabs
    if (ruleType == 'TAX_SLAB') {
      if (minIncome != null && income <= minIncome!) return false;
      if (maxIncome != null && income > maxIncome!) return false;
    }
    
    return true;
  }

  @override
  String toString() {
    return 'TaxRule{ruleCode: $ruleCode, ruleName: $ruleName, ruleType: $ruleType}';
  }
}

// Extension for List of TaxRules
extension TaxRuleListExtension on List<TaxRule> {
  List<TaxRule> get activeRules => where((rule) => rule.isActive).toList();
  
  List<TaxRule> getByType(String type) => 
      where((rule) => rule.ruleType == type).toList();
  
  List<TaxRule> get taxSlabs => getByType('TAX_SLAB')
    ..sort((a, b) => (a.minIncome ?? 0).compareTo(b.minIncome ?? 0));
  
  List<TaxRule> get deductions => getByType('DEDUCTION')
    ..sort((a, b) => a.priority.compareTo(b.priority));
  
  List<TaxRule> get cessRules => getByType('CESS');
  
  List<TaxRule> get surchargeRules => getByType('SURCHARGE');
  
  double calculateTotalTax(double taxableIncome, int year) {
    double totalTax = 0;
    final applicableSlabs = taxSlabs.where((slab) => slab.appliesTo(taxableIncome, year));
    
    for (var slab in applicableSlabs) {
      totalTax += slab.calculate(taxableIncome);
    }
    
    return totalTax;
  }
  
  double calculateTotalDeductions(double income, int year) {
    double totalDeductions = 0;
    final applicableDeductions = deductions.where((ded) => ded.appliesTo(income, year));
    
    for (var deduction in applicableDeductions) {
      totalDeductions += deduction.calculate(income);
    }
    
    return totalDeductions;
  }
  
  double calculateCess(double taxAmount, int year) {
    double totalCess = 0;
    final applicableCess = cessRules.where((cess) => cess.appliesTo(taxAmount, year));
    
    for (var cess in applicableCess) {
      totalCess += cess.calculate(taxAmount);
    }
    
    return totalCess;
  }
}