import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tax_compliance_app/models/tax_return.dart';
import 'package:tax_compliance_app/providers/tax_provider.dart';
import 'package:tax_compliance_app/screens/tax_form_screen.dart';

class _SuccessfulTaxProvider extends TaxProvider {
  int createCalls = 0;
  int calculateCalls = 0;
  int submitCalls = 0;

  @override
  Future<TaxReturn?> createReturn(String assessmentYear) async {
    createCalls++;
    return TaxReturn(
      id: 1,
      filingId: 'TR-TEST-001',
      userId: 1,
      tinNumber: '123456789',
      assessmentYear: assessmentYear,
      filingType: 'ORIGINAL',
    );
  }

  @override
  Future<bool> calculateTax(
    int returnId,
    double totalIncome,
    double deductions,
  ) async {
    calculateCalls++;
    return true;
  }

  @override
  Future<bool> submitReturn(int returnId) async {
    submitCalls++;
    return true;
  }
}

void main() {
  testWidgets('submits a completed tax form from the declaration step',
      (tester) async {
    final taxProvider = _SuccessfulTaxProvider();
    addTearDown(taxProvider.dispose);
    tester.view.physicalSize = const Size(1200, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ChangeNotifierProvider<TaxProvider>.value(
        value: taxProvider,
        child: const MaterialApp(home: TaxFormScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Acme Ltd');
    await tester.enterText(find.byType(TextFormField).at(1), '123456789');
    var nextButton = find.text('Next Section');
    await tester.ensureVisible(nextButton);
    await tester.pumpAndSettle();
    await tester.tap(nextButton);
    await tester.pumpAndSettle();

    final labelFinder = find.text('Business Income (Trade, Profession)');
    final incomeFieldFinder =
        find.ancestor(of: labelFinder, matching: find.byType(TextFormField));
    // Debug: check that the label and field are found
    debugPrint(
        'DEBUG: labelFound=${tester.any(labelFinder)}, incomeFieldFound=${tester.any(incomeFieldFinder)}');
    await tester.enterText(incomeFieldFinder.first, '1000000');
    for (var step = 0; step < 3; step++) {
      nextButton = find.text('Next Section');
      await tester.ensureVisible(nextButton);
      await tester.pumpAndSettle();
      await tester.tap(nextButton);
      await tester.pumpAndSettle();
    }

    final submitButton = find.text('Submit to TRA');
    await tester.ensureVisible(submitButton);
    await tester.pumpAndSettle();
    await tester.tap(submitButton);
    await tester.pumpAndSettle();

    // Debug output
    debugPrint(
        'DEBUG: createCalls=${taxProvider.createCalls}, calculateCalls=${taxProvider.calculateCalls}, submitCalls=${taxProvider.submitCalls}');

    expect(taxProvider.createCalls, 1);
    expect(taxProvider.calculateCalls, 1);
    expect(taxProvider.submitCalls, 1);
    expect(find.text('TRA Return Submitted!'), findsOneWidget);
  });
}
