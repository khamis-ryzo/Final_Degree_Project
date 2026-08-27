import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/tax_return.dart';
import '../models/user.dart';

/// A generated PDF that can be downloaded, shared, or printed on any platform.
///
/// Keeping the PDF in memory avoids file-system plugins on Flutter web, where
/// browser downloads do not have an application documents directory.
class GeneratedTaxReport {
  const GeneratedTaxReport({
    required this.bytes,
    required this.fileName,
  });

  final Uint8List bytes;
  final String fileName;
}

class TRAReportService {
  static final DateFormat _dateFormat = DateFormat('dd MMM yyyy');
  static final DateFormat _timeFormat = DateFormat('hh:mm a');
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'sw_TZ',
    symbol: 'TSh ',
    decimalDigits: 2,
  );

  /// Generate complete tax report PDF
  static Future<GeneratedTaxReport> generateTaxReport(
    TaxReturn taxReturn,
    User user,
    Map<String, dynamic> calculationDetails,
  ) async {
    final pdf = _buildPdfDocument(
      taxReturn: taxReturn,
      user: user,
      calculationDetails: calculationDetails,
    );
    return _buildReport(pdf, 'Tax_Report', taxReturn.filingId);
  }

  /// Alias used across screens for generating the TRA report PDF.
  static Future<GeneratedTaxReport> generateTRAReport(
    TaxReturn taxReturn,
    User user,
    Map<String, dynamic> calculationDetails,
  ) {
    return generateTaxReport(taxReturn, user, calculationDetails);
  }

  /// Generate an entity tax report with extended data (used by result screen).
  static Future<GeneratedTaxReport> generateEntityTaxReport({
    required TaxReturn taxReturn,
    required User user,
    required Map<String, dynamic> taxData,
    required num taxPayable,
    required num totalLiability,
  }) async {
    final mergedData = <String, dynamic>{
      ...taxData,
      'taxPayable': taxPayable.toDouble(),
      'totalLiability': totalLiability.toDouble(),
      'totalTax': totalLiability.toDouble(),
    };
    final pdf = _buildPdfDocument(
      taxReturn: taxReturn,
      user: user,
      calculationDetails: mergedData,
    );
    return _buildReport(pdf, 'TRA_Return', taxReturn.filingId);
  }

  /// Downloads the report on web and opens the platform's share/save flow on
  /// supported native platforms.
  static Future<void> downloadReport(GeneratedTaxReport report) async {
    await Printing.sharePdf(
      bytes: report.bytes,
      filename: report.fileName,
    );
  }

  static pw.Document _buildPdfDocument({
    required TaxReturn taxReturn,
    required User user,
    required Map<String, dynamic> calculationDetails,
  }) {
    final pdf = pw.Document();


    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: _buildHeader,
        footer: _buildFooter,
        build: (pw.Context context) {
          return [
            // ==================== SECTION 1: HEADER ====================
            _buildReportHeader(taxReturn: taxReturn),
            pw.SizedBox(height: 16),

            // ==================== SECTION 2: TAXPAYER INFORMATION ====================
            _buildSectionTitle('SECTION A: TAXPAYER INFORMATION'),
            pw.SizedBox(height: 8),
            _buildTaxpayerInfo(user),
            pw.SizedBox(height: 16),

            // ==================== SECTION 3: RETURN INFORMATION ====================
            _buildSectionTitle('SECTION B: RETURN INFORMATION'),
            pw.SizedBox(height: 8),
            _buildReturnInfo(taxReturn),
            pw.SizedBox(height: 16),

            // ==================== SECTION 4: INCOME DETAILS ====================
            _buildSectionTitle('SECTION C: INCOME DETAILS'),
            pw.SizedBox(height: 8),
            _buildIncomeDetails(taxReturn),
            pw.SizedBox(height: 16),

            // ==================== SECTION 5: DEDUCTIONS & RELIEFS ====================
            _buildSectionTitle('SECTION D: DEDUCTIONS & RELIEFS'),
            pw.SizedBox(height: 8),
            _buildDeductions(taxReturn),
            pw.SizedBox(height: 16),

            // ==================== SECTION 6: TAX CALCULATION ====================
            _buildSectionTitle('SECTION E: TAX CALCULATION'),
            pw.SizedBox(height: 8),
            _buildTaxCalculation(taxReturn, calculationDetails),
            pw.SizedBox(height: 16),

            // ==================== SECTION 7: PAYMENT DETAILS ====================
            _buildSectionTitle('SECTION F: PAYMENT DETAILS'),
            pw.SizedBox(height: 8),
            _buildPaymentDetails(taxReturn),
            pw.SizedBox(height: 16),

            // ==================== SECTION 8: DECLARATION ====================
            _buildSectionTitle('SECTION G: DECLARATION'),
            pw.SizedBox(height: 8),
            _buildDeclaration(user),
            pw.SizedBox(height: 16),

            // ==================== SECTION 9: SUMMARY ====================
            _buildSectionTitle('SECTION H: SUMMARY STATEMENT'),
            pw.SizedBox(height: 8),
            _buildSummary(taxReturn),
            pw.SizedBox(height: 16),

            // ==================== SECTION 10: TRA USE ONLY ====================
            _buildTRAUseOnly(),
          ];
        },
      ),
    );
    return pdf;
  }

  /// Serialize the PDF in memory. Non-alphanumeric characters in
  /// [rawFilingId] are sanitized so the downloaded name is always safe.
  static Future<GeneratedTaxReport> _buildReport(
    pw.Document pdf,
    String prefix,
    String rawFilingId,
  ) async {
    final bytes = await pdf.save();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final safeId = rawFilingId.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    return GeneratedTaxReport(
      bytes: bytes,
      fileName: '${prefix}_${safeId}_$timestamp.pdf',
    );
  }

  // ==================== HEADER BUILDER ====================

  static pw.Widget _buildHeader(pw.Context context) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 16),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'TAX COMPLIANCE SYSTEM',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey700,
                ),
              ),
              pw.Text(
                'Tax Report',
                style: const pw.TextStyle(
                  fontSize: 8,
                  color: PdfColors.grey500,
                ),
              ),
            ],
          ),
          pw.Text(
            'Page ${context.pageNumber}',
            style: const pw.TextStyle(
              fontSize: 8,
              color: PdfColors.grey500,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 16),
      child: pw.Column(
        children: [
          pw.Divider(),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Generated on: ${_dateFormat.format(DateTime.now())} at ${_timeFormat.format(DateTime.now())}',
                style: const pw.TextStyle(
                  fontSize: 7,
                  color: PdfColors.grey500,
                ),
              ),
              pw.Text(
                '© Tax Compliance System',
                style: const pw.TextStyle(
                  fontSize: 7,
                  color: PdfColors.grey500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== SECTION BUILDERS ====================

  static pw.Widget _buildReportHeader({required TaxReturn taxReturn}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue700,
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            'TAX COMPLIANCE SYSTEM',
            style: pw.TextStyle(
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Tax Return Report',
            style: const pw.TextStyle(
              fontSize: 14,
              color: PdfColors.white,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Filing ID: ${taxReturn.filingId}',
            style: const pw.TextStyle(
              fontSize: 10,
              color: PdfColors.white,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSectionTitle(String title) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: pw.BorderRadius.circular(2),
      ),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 11,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.blue900,
        ),
      ),
    );
  }

  // ==================== SECTION A: TAXPAYER INFORMATION ====================

  static pw.Widget _buildTaxpayerInfo(User user) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Full Name', user.fullName),
          _buildInfoRow('TIN Number', user.tinNumber),
          _buildInfoRow('Email Address', user.email),
          _buildInfoRow('Mobile Number', user.mobileNumber ?? 'N/A'),
          _buildInfoRow('Taxpayer Type', user.taxpayerType ?? 'Individual'),
          _buildInfoRow('Business Name', user.businessName ?? 'N/A'),
          _buildInfoRow('Business Sector', user.businessSector ?? 'N/A'),
          _buildInfoRow('TRA Region', user.traRegion ?? 'N/A'),
          _buildInfoRow('TRA Branch', user.traBranch ?? 'N/A'),
          _buildInfoRow(
              'VAT Registration', user.isVatRegistered == true ? 'Yes' : 'No'),
        ],
      ),
    );
  }

  // ==================== SECTION B: RETURN INFORMATION ====================

  static pw.Widget _buildReturnInfo(TaxReturn taxReturn) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Filing ID', taxReturn.filingId),
          _buildInfoRow('Assessment Year', taxReturn.assessmentYear),
          _buildInfoRow('Filing Type', taxReturn.filingType),
          _buildInfoRow('Filing Date', _dateFormat.format(DateTime.now())),
          _buildInfoRow('Status', taxReturn.status),
          _buildInfoRow(
              'Submission Date',
              taxReturn.submissionDate != null
                  ? _dateFormat.format(taxReturn.submissionDate!)
                  : 'Not Submitted'),
          _buildInfoRow('Acknowledgment Number',
              taxReturn.acknowledgmentNumber ?? 'Pending'),
          _buildInfoRow(
              'Control Number', taxReturn.controlNumber ?? 'Not Generated'),
        ],
      ),
    );
  }

  // ==================== SECTION C: INCOME DETAILS ====================

  static pw.Widget _buildIncomeDetails(TaxReturn taxReturn) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _buildTable([
            ['Income Source', 'Amount (TSh)'],
            ['Employment Income', _formatCurrency(taxReturn.employmentIncome)],
            ['Business Income', _formatCurrency(taxReturn.businessIncome)],
            ['Rental Income', _formatCurrency(taxReturn.rentalIncome)],
            [
              'Agricultural Income',
              _formatCurrency(taxReturn.agriculturalIncome)
            ],
            ['Capital Gains', _formatCurrency(taxReturn.capitalGains)],
            ['Interest Income', _formatCurrency(taxReturn.interestIncome)],
            ['Dividend Income', _formatCurrency(taxReturn.dividendIncome)],
            ['Other Income', _formatCurrency(taxReturn.otherIncome)],
            [''],
            ['TOTAL INCOME', _formatCurrency(taxReturn.totalIncome)],
          ]),
        ],
      ),
    );
  }

  // ==================== SECTION D: DEDUCTIONS & RELIEFS ====================

  static pw.Widget _buildDeductions(TaxReturn taxReturn) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _buildTable([
            ['Deduction Type', 'Amount (TSh)'],
            ['Personal Relief', _formatCurrency(taxReturn.personalRelief)],
            ['Pension Relief', _formatCurrency(taxReturn.pensionRelief)],
            ['Insurance Relief', _formatCurrency(taxReturn.insuranceRelief)],
            ['Medical Expenses', _formatCurrency(taxReturn.medicalExpenses)],
            [
              'Charitable Donations',
              _formatCurrency(taxReturn.charitableDonations)
            ],
            [
              'Education Expenses',
              _formatCurrency(taxReturn.educationExpenses)
            ],
            ['Mortgage Interest', _formatCurrency(taxReturn.mortgageInterest)],
            ['Business Expenses', _formatCurrency(taxReturn.businessExpenses)],
            ['Other Deductions', _formatCurrency(taxReturn.otherDeductions)],
            [''],
            ['TOTAL DEDUCTIONS', _formatCurrency(taxReturn.totalDeductions)],
          ]),
        ],
      ),
    );
  }

  // ==================== SECTION E: TAX CALCULATION ====================

  static pw.Widget _buildTaxCalculation(
    TaxReturn taxReturn,
    Map<String, dynamic> calculationDetails,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Taxable Income:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text(_formatCurrency(taxReturn.taxableIncome)),
            ],
          ),
          pw.Divider(),
          _buildTable([
            ['Item', 'Amount (TSh)'],
            [
              'PAYE Tax',
              _formatCurrency(calculationDetails['taxPayable'] ?? 0)
            ],
            [
              'Skills Development Levy (5%)',
              _formatCurrency(calculationDetails['skillsLevy'] ?? 0)
            ],
            [
              'Railway Development Levy (5%)',
              _formatCurrency(calculationDetails['railwayLevy'] ?? 0)
            ],
            ['Cess (4%)', _formatCurrency(calculationDetails['cess'] ?? 0)],
            ['Interest', _formatCurrency(calculationDetails['interest'] ?? 0)],
            ['Penalty', _formatCurrency(calculationDetails['penalty'] ?? 0)],
            [''],
            [
              'TOTAL TAX LIABILITY',
              _formatCurrency(calculationDetails['totalLiability'] ?? 0)
            ],
          ]),
        ],
      ),
    );
  }

  // ==================== SECTION F: PAYMENT DETAILS ====================

  static pw.Widget _buildPaymentDetails(TaxReturn taxReturn) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _buildInfoRow(
              'Control Number', taxReturn.controlNumber ?? 'Not Generated'),
          _buildInfoRow('Payment Method', taxReturn.paymentMethod ?? 'N/A'),
          _buildInfoRow('Transaction ID', taxReturn.transactionId ?? 'N/A'),
          _buildInfoRow(
              'Payment Date',
              taxReturn.paymentDate != null
                  ? _dateFormat.format(taxReturn.paymentDate!)
                  : 'N/A'),
          _buildInfoRow('Amount Paid', _formatCurrency(taxReturn.taxPaid)),
          _buildInfoRow('Balance Due', _formatCurrency(taxReturn.balanceDue)),
          _buildInfoRow(
              'Refund Amount', _formatCurrency(taxReturn.refundAmount)),
        ],
      ),
    );
  }

  // ==================== SECTION G: DECLARATION ====================

  static pw.Widget _buildDeclaration(User user) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'I, ${user.fullName}, hereby declare that the information provided in this tax return is true and correct to the best of my knowledge and belief.',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'I understand that providing false information may result in penalties as per the Tanzania Revenue Authority regulations.',
            style: const pw.TextStyle(
              fontSize: 10,
              color: PdfColors.red700,
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Signature: ____________________'),
                  pw.SizedBox(height: 10),
                  pw.Text('Date: ____________________'),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('TIN: ${user.tinNumber}'),
                  pw.SizedBox(height: 10),
                  pw.Text('Place: ____________________'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== SECTION H: SUMMARY ====================

  static pw.Widget _buildSummary(TaxReturn taxReturn) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.green50,
        border: pw.Border.all(color: PdfColors.green300),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'TAX SUMMARY STATEMENT',
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.green800,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Total Income:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text(_formatCurrency(taxReturn.totalIncome)),
            ],
          ),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Total Deductions:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text(_formatCurrency(taxReturn.totalDeductions)),
            ],
          ),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Taxable Income:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text(_formatCurrency(taxReturn.taxableIncome)),
            ],
          ),
          pw.Divider(),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Total Tax Liability:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text(_formatCurrency(taxReturn.totalLiability)),
            ],
          ),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Tax Paid:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text(_formatCurrency(taxReturn.taxPaid)),
            ],
          ),
          pw.Divider(),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Balance Due / Refund:',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: taxReturn.refundAmount > 0
                      ? PdfColors.green700
                      : PdfColors.red700,
                ),
              ),
              pw.Text(
                taxReturn.refundAmount > 0
                    ? '${_formatCurrency(taxReturn.refundAmount)} (Refund)'
                    : '${_formatCurrency(taxReturn.balanceDue)} (Due)',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: taxReturn.refundAmount > 0
                      ? PdfColors.green700
                      : PdfColors.red700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== TRA USE ONLY ====================

  static pw.Widget _buildTRAUseOnly() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(
            color: PdfColors.red300, style: pw.BorderStyle.dashed),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'SECTION I: TRA USE ONLY',
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.red800,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Assessment Officer:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text('____________________'),
            ],
          ),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Assessment Date:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text('____________________'),
            ],
          ),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Assessment Notes:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text('____________________'),
            ],
          ),
          pw.SizedBox(height: 12),
          pw.Text(
            'TRA STAMP',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.red300,
            ),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ==================== HELPER METHODS ====================

  static pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 150,
            child: pw.Text(
              label,
              style: const pw.TextStyle(
                fontSize: 9,
                color: PdfColors.grey700,
              ),
            ),
          ),
          pw.Text(
            ': ',
            style: const pw.TextStyle(
              fontSize: 9,
              color: PdfColors.grey700,
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 9,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildTable(List<List<String>> data) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
      children: data.map((row) {
        final isHeader = data.indexOf(row) == 0;
        final isTotal = row[0].startsWith('TOTAL') || row[0] == '';
        return pw.TableRow(
          decoration: isHeader
              ? const pw.BoxDecoration(color: PdfColors.blue100)
              : isTotal
                  ? const pw.BoxDecoration(color: PdfColors.grey100)
                  : null,
          children: row.map((cell) {
            return pw.Padding(
              padding: const pw.EdgeInsets.all(6),
              child: pw.Text(
                cell,
                style: pw.TextStyle(
                  fontSize: 9,
                  fontWeight: isHeader || isTotal
                      ? pw.FontWeight.bold
                      : pw.FontWeight.normal,
                  color: isHeader
                      ? PdfColors.blue900
                      : (isTotal ? PdfColors.blue800 : PdfColors.black),
                ),
                textAlign: row.indexOf(cell) == 0
                    ? pw.TextAlign.left
                    : pw.TextAlign.right,
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }

  static String _formatCurrency(double? amount) {
    if (amount == null || amount == 0) return '0.00';
    return _currencyFormat.format(amount);
  }

  // ==================== SHARE & PRINT ====================

  static Future<void> shareReport(GeneratedTaxReport report) async {
    await Printing.sharePdf(
      bytes: report.bytes,
      filename: report.fileName,
    );
  }

  static Future<void> printReport(GeneratedTaxReport report) async {
    await Printing.layoutPdf(
      name: report.fileName,
      onLayout: (_) async => report.bytes,
    );
  }

  static Future<void> openReport(GeneratedTaxReport report) {
    return downloadReport(report);
  }
}
