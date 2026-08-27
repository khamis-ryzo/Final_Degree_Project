import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class TaxReturn {
  // Basic Information
  final int? id;
  final String filingId;
  final int userId;
  final String tinNumber; // Taxpayer Identification Number (Tanzania)
  final String assessmentYear; // e.g., "2024/2025"
  final String filingType; // ORIGINAL, REVISED, BELATED
  final String taxpayerType; // INDIVIDUAL, COMPANY, SOLE_PROPRIETOR, NGO

  // Income Details (Tanzania)
  final double employmentIncome; // Income from employment (PAYE)
  final double businessIncome; // Business/Professional income
  final double rentalIncome; // Rental income
  final double agriculturalIncome; // Agricultural income
  final double capitalGains; // Capital gains
  final double interestIncome; // Interest income
  final double dividendIncome; // Dividend income
  final double otherIncome; // Other income
  final double totalIncome; // Sum of all income

  // Deductions (Tanzania)
  final double personalRelief; // Personal relief - TSh 270,000 per year
  final double pensionRelief; // Pension contributions relief
  final double insuranceRelief; // Insurance premiums relief
  final double medicalExpenses; // Medical expenses
  final double charitableDonations; // Charitable donations
  final double educationExpenses; // Education expenses
  final double mortgageInterest; // Mortgage interest
  final double businessExpenses; // Business expenses
  final double otherDeductions; // Other deductions
  final double totalDeductions; // Sum of all deductions

  double get deductions => totalDeductions;

  // Tax Calculation Results (Tanzania)
  final double taxableIncome; // Total income - Total deductions
  final double taxPayable; // PAYE tax calculated
  final double skillsLevy; // Skills Development Levy (5% of taxable income)
  final double railwayLevy; // Railway Development Levy (5% of taxable income)
  final double vatPayable; // VAT (18% of taxable supply)
  final double withholdingTax; // Withholding tax
  final double corporateTax; // Corporate income tax (if applicable)
  final double cessAmount; // Cess (if applicable)
  final double interest; // Interest on late payment
  final double penalty; // Penalty for late filing
  final double totalLiability; // Total tax liability

  // Payment Information (Tanzania)
  final double taxPaid; // Amount already paid
  final double refundAmount; // Refund due (if tax paid > liability)
  final double balanceDue; // Balance due (if liability > tax paid)
  final String? controlNumber; // TRA Control Number
  final String?
      paymentMethod; // MPESA, TIGOPESA, AIRTEL_MONEY, BANK, CASH, CARD
  final String? transactionId; // Payment transaction ID
  final String? bankName; // Bank name (if bank transfer)
  final String? mobileNumber; // Mobile number (if mobile money)
  final DateTime? paymentDate; // Date of payment
  final String? paymentStatus; // PENDING, COMPLETED, FAILED, REFUNDED

  // Status Information
  final String
      status; // DRAFT, SUBMITTED, PROCESSING, ASSESSED, COMPLETED, REJECTED
  final DateTime? submissionDate; // Date submitted to TRA
  final String? acknowledgmentNumber; // TRA acknowledgment number
  final String? assessmentOfficer; // TRA officer assigned
  final String? assessmentNotes; // Notes from TRA

  // Additional Information
  final bool isVATRegistered; // Whether taxpayer is VAT registered
  final bool hasPAYE; // Whether taxpayer has PAYE
  final bool hasWithholdingTax; // Whether taxpayer has withholding tax
  final int? numberOfEmployees; // Number of employees (if business)
  final String? businessType; // Type of business
  final String?
      businessSector; // Sector of business (Agriculture, Mining, Manufacturing, etc.)
  final String? traRegion; // TRA region (Dar es Salaam, Arusha, etc.)
  final String? traBranch; // TRA branch office

  // Timestamps
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? assessedAt;
  final DateTime? completedAt;

  TaxReturn({
    this.id,
    required this.filingId,
    required this.userId,
    required this.tinNumber,
    required this.assessmentYear,
    required this.filingType,
    this.taxpayerType = 'INDIVIDUAL',
    this.employmentIncome = 0.0,
    this.businessIncome = 0.0,
    this.rentalIncome = 0.0,
    this.agriculturalIncome = 0.0,
    this.capitalGains = 0.0,
    this.interestIncome = 0.0,
    this.dividendIncome = 0.0,
    this.otherIncome = 0.0,
    this.totalIncome = 0.0,
    this.personalRelief = 270000.0, // TSh 270,000 Tanzania
    this.pensionRelief = 0.0,
    this.insuranceRelief = 0.0,
    this.medicalExpenses = 0.0,
    this.charitableDonations = 0.0,
    this.educationExpenses = 0.0,
    this.mortgageInterest = 0.0,
    this.businessExpenses = 0.0,
    this.otherDeductions = 0.0,
    this.totalDeductions = 0.0,
    this.taxableIncome = 0.0,
    this.taxPayable = 0.0,
    this.skillsLevy = 0.0,
    this.railwayLevy = 0.0,
    this.vatPayable = 0.0,
    this.withholdingTax = 0.0,
    this.corporateTax = 0.0,
    this.cessAmount = 0.0,
    this.interest = 0.0,
    this.penalty = 0.0,
    this.totalLiability = 0.0,
    this.taxPaid = 0.0,
    this.refundAmount = 0.0,
    this.balanceDue = 0.0,
    this.controlNumber,
    this.paymentMethod,
    this.transactionId,
    this.bankName,
    this.mobileNumber,
    this.paymentDate,
    this.paymentStatus,
    this.status = 'DRAFT',
    this.submissionDate,
    this.acknowledgmentNumber,
    this.assessmentOfficer,
    this.assessmentNotes,
    this.isVATRegistered = false,
    this.hasPAYE = false,
    this.hasWithholdingTax = false,
    this.numberOfEmployees,
    this.businessType,
    this.businessSector,
    this.traRegion,
    this.traBranch,
    this.createdAt,
    this.updatedAt,
    this.assessedAt,
    this.completedAt,
  });

  factory TaxReturn.fromJson(Map<String, dynamic> json) {
    return TaxReturn(
      id: json['id'],
      filingId: json['filingId'] ?? '',
      userId: json['userId'] ?? 0,
      tinNumber: json['tinNumber'] ?? '',
      assessmentYear: json['assessmentYear'] ?? '',
      filingType: json['filingType'] ?? 'ORIGINAL',
      taxpayerType: json['taxpayerType'] ?? 'INDIVIDUAL',
      employmentIncome: _toDouble(json['employmentIncome']),
      businessIncome: _toDouble(json['businessIncome']),
      rentalIncome: _toDouble(json['rentalIncome']),
      agriculturalIncome: _toDouble(json['agriculturalIncome']),
      capitalGains: _toDouble(json['capitalGains']),
      interestIncome: _toDouble(json['interestIncome']),
      dividendIncome: _toDouble(json['dividendIncome']),
      otherIncome: _toDouble(json['otherIncome']),
      totalIncome: _toDouble(json['totalIncome']),
      personalRelief: json['personalRelief'] != null
          ? _toDouble(json['personalRelief'])
          : 270000.0,
      pensionRelief: _toDouble(json['pensionRelief']),
      insuranceRelief: _toDouble(json['insuranceRelief']),
      medicalExpenses: _toDouble(json['medicalExpenses']),
      charitableDonations: _toDouble(json['charitableDonations']),
      educationExpenses: _toDouble(json['educationExpenses']),
      mortgageInterest: _toDouble(json['mortgageInterest']),
      businessExpenses: _toDouble(json['businessExpenses']),
      otherDeductions: _toDouble(json['otherDeductions']),
      totalDeductions: _toDouble(json['totalDeductions']),
      taxableIncome: _toDouble(json['taxableIncome']),
      taxPayable: _toDouble(json['taxPayable']),
      skillsLevy: _toDouble(json['skillsLevy']),
      railwayLevy: _toDouble(json['railwayLevy']),
      vatPayable: _toDouble(json['vatPayable']),
      withholdingTax: _toDouble(json['withholdingTax']),
      corporateTax: _toDouble(json['corporateTax']),
      cessAmount: _toDouble(json['cessAmount']),
      interest: _toDouble(json['interest']),
      penalty: _toDouble(json['penalty']),
      totalLiability: _toDouble(json['totalLiability']),
      taxPaid: _toDouble(json['taxPaid']),
      refundAmount: _toDouble(json['refundAmount']),
      balanceDue: _toDouble(json['balanceDue']),
      controlNumber: json['controlNumber'],
      paymentMethod: json['paymentMethod'],
      transactionId: json['transactionId'],
      bankName: json['bankName'],
      mobileNumber: json['mobileNumber'],
      paymentDate: json['paymentDate'] != null
          ? DateTime.parse(json['paymentDate'])
          : null,
      paymentStatus: json['paymentStatus'],
      status: json['status'] ?? 'DRAFT',
      submissionDate: json['submissionDate'] != null
          ? DateTime.parse(json['submissionDate'])
          : null,
      acknowledgmentNumber: json['acknowledgmentNumber'],
      assessmentOfficer: json['assessmentOfficer'],
      assessmentNotes: json['assessmentNotes'],
      isVATRegistered: json['isVATRegistered'] ?? false,
      hasPAYE: json['hasPAYE'] ?? false,
      hasWithholdingTax: json['hasWithholdingTax'] ?? false,
      numberOfEmployees: json['numberOfEmployees'],
      businessType: json['businessType'],
      businessSector: json['businessSector'],
      traRegion: json['traRegion'],
      traBranch: json['traBranch'],
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      assessedAt: json['assessedAt'] != null
          ? DateTime.parse(json['assessedAt'])
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'filingId': filingId,
      'userId': userId,
      'tinNumber': tinNumber,
      'assessmentYear': assessmentYear,
      'filingType': filingType,
      'taxpayerType': taxpayerType,
      'employmentIncome': employmentIncome,
      'businessIncome': businessIncome,
      'rentalIncome': rentalIncome,
      'agriculturalIncome': agriculturalIncome,
      'capitalGains': capitalGains,
      'interestIncome': interestIncome,
      'dividendIncome': dividendIncome,
      'otherIncome': otherIncome,
      'totalIncome': totalIncome,
      'personalRelief': personalRelief,
      'pensionRelief': pensionRelief,
      'insuranceRelief': insuranceRelief,
      'medicalExpenses': medicalExpenses,
      'charitableDonations': charitableDonations,
      'educationExpenses': educationExpenses,
      'mortgageInterest': mortgageInterest,
      'businessExpenses': businessExpenses,
      'otherDeductions': otherDeductions,
      'totalDeductions': totalDeductions,
      'taxableIncome': taxableIncome,
      'taxPayable': taxPayable,
      'skillsLevy': skillsLevy,
      'railwayLevy': railwayLevy,
      'vatPayable': vatPayable,
      'withholdingTax': withholdingTax,
      'corporateTax': corporateTax,
      'cessAmount': cessAmount,
      'interest': interest,
      'penalty': penalty,
      'totalLiability': totalLiability,
      'taxPaid': taxPaid,
      'refundAmount': refundAmount,
      'balanceDue': balanceDue,
      'controlNumber': controlNumber,
      'paymentMethod': paymentMethod,
      'transactionId': transactionId,
      'bankName': bankName,
      'mobileNumber': mobileNumber,
      'paymentDate': paymentDate?.toIso8601String(),
      'paymentStatus': paymentStatus,
      'status': status,
      'submissionDate': submissionDate?.toIso8601String(),
      'acknowledgmentNumber': acknowledgmentNumber,
      'assessmentOfficer': assessmentOfficer,
      'assessmentNotes': assessmentNotes,
      'isVATRegistered': isVATRegistered,
      'hasPAYE': hasPAYE,
      'hasWithholdingTax': hasWithholdingTax,
      'numberOfEmployees': numberOfEmployees,
      'businessType': businessType,
      'businessSector': businessSector,
      'traRegion': traRegion,
      'traBranch': traBranch,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'assessedAt': assessedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  // Helper Getters for Display
  String get formattedTotalIncome => _formatTSh(totalIncome);
  String get formattedTaxPayable => _formatTSh(taxPayable);
  String get formattedTotalLiability => _formatTSh(totalLiability);
  String get formattedTaxPaid => _formatTSh(taxPaid);
  String get formattedRefund => _formatTSh(refundAmount);
  String get formattedBalanceDue => _formatTSh(balanceDue);
  String get formattedSkillsLevy => _formatTSh(skillsLevy);
  String get formattedRailwayLevy => _formatTSh(railwayLevy);
  String get formattedVat => _formatTSh(vatPayable);
  String get formattedWithholdingTax => _formatTSh(withholdingTax);
  String get formattedCorporateTax => _formatTSh(corporateTax);
  String get formattedCess => _formatTSh(cessAmount);
  String get formattedInterest => _formatTSh(interest);
  String get formattedPenalty => _formatTSh(penalty);

  String _formatTSh(double amount) {
    return 'TSh ${NumberFormat('#,###').format(amount)}';
  }

  Color get statusColor {
    switch (status) {
      case 'COMPLETED':
        return Colors.green;
      case 'SUBMITTED':
        return Colors.orange;
      case 'PROCESSING':
        return Colors.blue;
      case 'ASSESSED':
        return Colors.purple;
      case 'REJECTED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String get statusDisplayName {
    switch (status) {
      case 'COMPLETED':
        return 'Completed';
      case 'SUBMITTED':
        return 'Submitted';
      case 'PROCESSING':
        return 'Processing';
      case 'ASSESSED':
        return 'Assessed';
      case 'REJECTED':
        return 'Rejected';
      default:
        return 'Draft';
    }
  }

  String get paymentMethodDisplay {
    switch (paymentMethod) {
      case 'MPESA':
        return 'M-Pesa';
      case 'TIGOPESA':
        return 'Tigo Pesa';
      case 'AIRTEL_MONEY':
        return 'Airtel Money';
      case 'BANK':
        return 'Bank Transfer';
      case 'CASH':
        return 'Cash';
      case 'CARD':
        return 'Card';
      default:
        return 'N/A';
    }
  }

  bool get isComplete => status == 'COMPLETED';
  bool get isSubmitted =>
      status == 'SUBMITTED' || status == 'PROCESSING' || status == 'ASSESSED';
  bool get isDraft => status == 'DRAFT';
  bool get isRejected => status == 'REJECTED';
  bool get requiresPayment => balanceDue > 0 && status != 'COMPLETED';
  bool get hasRefund => refundAmount > 0;
}

// Tax Calculation Helper for Tanzania
class TanzaniaTaxCalculator {
  // PAYE Tax Slabs for Tanzania (2024)
  static const List<TaxSlab> _payeSlabs = [
    TaxSlab(0, 270000, 0.0), // 0%
    TaxSlab(270001, 520000, 0.08), // 8%
    TaxSlab(520001, 760000, 0.20), // 20%
    TaxSlab(760001, 1000000, 0.25), // 25%
    TaxSlab(1000001, 10000000, 0.30), // 30%
    TaxSlab(10000001, double.infinity, 0.35), // 35%
  ];

  static double calculatePAYE(double annualIncome) {
    double tax = 0;
    double remaining = annualIncome;

    for (var slab in _payeSlabs) {
      if (remaining > slab.min) {
        final taxable =
            remaining > slab.max ? slab.max - slab.min : remaining - slab.min;
        tax += taxable * slab.rate;
        if (remaining > slab.max) {
          remaining -= slab.max - slab.min;
        } else {
          break;
        }
      }
    }

    // Personal Relief (TSh 270,000 per year)
    tax -= 270000;
    if (tax < 0) tax = 0;

    return tax;
  }

  static double calculateSkillsLevy(double taxableIncome) {
    return taxableIncome * 0.05; // 5%
  }

  static double calculateRailwayLevy(double taxableIncome) {
    return taxableIncome * 0.05; // 5%
  }

  static double calculateVAT(double amount, {bool inclusive = true}) {
    if (inclusive) {
      return amount * (0.18 / 1.18);
    } else {
      return amount * 0.18;
    }
  }

  static double calculateWithholdingTax(double amount, double rate) {
    return amount * rate;
  }

  static double calculateCorporateTax(double profit, {bool isSmall = true}) {
    if (isSmall) {
      return profit * 0.30; // Small companies 30%
    } else {
      return profit * 0.35; // Large companies 35%
    }
  }

  static double calculateInterest(double amount, int daysLate) {
    const dailyRate = 0.0001; // 0.01% per day
    return amount * dailyRate * daysLate;
  }

  static double calculatePenalty(double amount, int monthsLate) {
    const monthlyRate = 0.05; // 5% per month
    return amount * monthlyRate * monthsLate;
  }
}

class TaxSlab {
  final double min;
  final double max;
  final double rate;

  const TaxSlab(this.min, this.max, this.rate);
}

// Tanzanian Tax Types Enum
enum TanzaniaTaxType {
  paye('PAYE'),
  vat('VAT'),
  skillsLevy('Skills Development Levy'),
  railwayLevy('Railway Development Levy'),
  withholdingTax('Withholding Tax'),
  corporateTax('Corporate Income Tax'),
  cess('Cess'),
  interest('Interest'),
  penalty('Penalty');

  final String displayName;
  const TanzaniaTaxType(this.displayName);
}

// Tanzanian Business Sectors
enum TanzaniaBusinessSector {
  agriculture('Agriculture'),
  mining('Mining'),
  manufacturing('Manufacturing'),
  construction('Construction'),
  transport('Transport & Logistics'),
  tourism('Tourism & Hospitality'),
  trade('Trade & Commerce'),
  finance('Financial Services'),
  technology('Technology'),
  education('Education'),
  health('Healthcare'),
  realEstate('Real Estate'),
  energy('Energy'),
  telecommunication('Telecommunications'),
  other('Other');

  final String displayName;
  const TanzaniaBusinessSector(this.displayName);
}

// Tanzanian TRA Regions
enum TanzaniaTRARegion {
  darEsSalaam('Dar es Salaam'),
  arusha('Arusha'),
  mwanza('Mwanza'),
  mbeya('Mbeya'),
  tanga('Tanga'),
  dodoma('Dodoma'),
  morogoro('Morogoro'),
  kilimanjaro('Kilimanjaro'),
  tabora('Tabora'),
  kigoma('Kigoma'),
  ruvuma('Ruvuma'),
  lindi('Lindi'),
  mtwara('Mtwara'),
  iringa('Iringa'),
  manyara('Manyara'),
  geita('Geita'),
  katavi('Katavi'),
  njombe('Njombe'),
  simiyu('Simiyu'),
  rukwa('Rukwa'),
  singida('Singida'),
  shinyanga('Shinyanga'),
  mara('Mara'),
  kagera('Kagera'),
  pemba('Pemba'),
  zanzibar('Zanzibar');

  final String displayName;
  const TanzaniaTRARegion(this.displayName);
}
