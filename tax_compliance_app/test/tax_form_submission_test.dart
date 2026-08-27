import 'package:flutter_test/flutter_test.dart';
import 'package:tax_compliance_app/services/tax_service.dart';

void main() {
  test(
      'buildSubmissionPayload serializes final tax form values for backend save',
      () {
    final payload = TaxService.buildSubmissionPayload(
      totalIncome: 25000000,
      deductions: 5000000,
      filingType: 'ORIGINAL',
      additionalInfo: 'Submitted from final review step',
    );

    expect(payload['totalIncome'], 25000000);
    expect(payload['deductions'], 5000000);
    expect(payload['filingType'], 'ORIGINAL');
    expect(payload['additionalInfo'], 'Submitted from final review step');
  });

  test('parseTaxReturnListResponse accepts both paged and plain list payloads',
      () {
    final paged = {
      'content': [
        {
          'id': 1,
          'filingId': 'TR-2024-001',
          'userId': 7,
          'tinNumber': '123456789',
          'assessmentYear': '2024/2025',
          'filingType': 'ORIGINAL',
          'status': 'DRAFT',
          'totalIncome': 25000000,
          'deductions': 5000000,
          'taxableIncome': 20000000,
          'taxPayable': 1800000,
          'interest': 0,
          'penalty': 0,
          'totalLiability': 1800000,
        }
      ]
    };

    final plain = [
      {
        'id': 2,
        'filingId': 'TR-2024-002',
        'userId': 7,
        'tinNumber': '123456789',
        'assessmentYear': '2024/2025',
        'filingType': 'ORIGINAL',
        'status': 'SUBMITTED',
        'totalIncome': 32000000,
        'deductions': 7000000,
        'taxableIncome': 25000000,
        'taxPayable': 2200000,
        'interest': 0,
        'penalty': 0,
        'totalLiability': 2200000,
      }
    ];

    final pagedReturns = TaxService.parseTaxReturnListResponse(paged);
    final plainReturns = TaxService.parseTaxReturnListResponse(plain);

    expect(pagedReturns.length, 1);
    expect(plainReturns.length, 1);
    expect(pagedReturns.first.filingId, 'TR-2024-001');
    expect(plainReturns.first.filingId, 'TR-2024-002');
  });
}
