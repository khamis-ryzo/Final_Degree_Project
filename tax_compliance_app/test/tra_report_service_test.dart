import 'package:flutter_test/flutter_test.dart';
import 'package:tax_compliance_app/models/tax_return.dart';
import 'package:tax_compliance_app/models/user.dart';
import 'package:tax_compliance_app/services/tra_report_service.dart';

void main() {
  test(
      'generateEntityTaxReport creates a portable PDF with a safe filename',
      () async {
    final taxReturn = TaxReturn(
      filingId: 'TR-2024/2025-123-ABC',
      userId: 42,
      tinNumber: '123456789',
      assessmentYear: '2024/2025',
      filingType: 'ORIGINAL',
      totalIncome: 5000000,
      totalDeductions: 500000,
      taxableIncome: 4500000,
      taxPayable: 200000,
      totalLiability: 200000,
    );

    final user = User(
      username: 'demo',
      email: 'demo@example.com',
      tinNumber: '123456789',
      fullName: 'Demo User',
      mobileNumber: '255712345678',
    );

    final report = await TRAReportService.generateEntityTaxReport(
      taxReturn: taxReturn,
      user: user,
      taxData: {
        'entityName': 'Demo Entity',
        'tinNumber': '123456789',
        'entityType': 'Company',
        'taxpayerType': 'RESIDENT',
        'businessSector': 'Trade',
        'traRegion': 'Dar es Salaam',
        'email': user.email,
        'phone': user.mobileNumber,
        'yearOfIncome': taxReturn.assessmentYear,
        'totalIncome': 5000000.0,
        'totalDeductions': 500000.0,
        'chargeableIncome': 4500000.0,
        'taxPayable': 200000.0,
        'amt': 0.0,
        'taxDeducted': 0.0,
        'installmentTax': 0.0,
        'netTaxPayable': 200000.0,
        'netTaxRepayable': 0.0,
        'totalBusinessIncome': 5000000.0,
        'totalInvestmentIncome': 0.0,
        'fixedAssets': 0.0,
        'currentAssets': 0.0,
        'totalAssets': 0.0,
        'currentLiabilities': 0.0,
        'longTermLiabilities': 0.0,
        'totalLiabilities': 0.0,
        'shareholdersEquity': 0.0,
        'netAssets': 0.0,
      },
      taxPayable: 200000,
      totalLiability: 200000,
    );

    expect(report.bytes, isNotEmpty);
    expect(String.fromCharCodes(report.bytes.take(4)), '%PDF');
    expect(report.fileName, startsWith('TRA_Return_'));
    expect(report.fileName, isNot(contains('/')));
    expect(report.fileName, contains('TR-2024_2025-123-ABC'));
    expect(report.fileName, endsWith('.pdf'));
  });
}
