import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_file/open_file.dart';

class PDFExportService {
  static const String _currency = 'TSh';

  // ==================== EXPORT TAX RETURN TO PDF ====================
  static Future<File> exportTaxReturnToPDF({
    required Map<String, dynamic> taxReturn,
    required Map<String, dynamic> user,
    required Map<String, dynamic> calculation,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader('TAX RETURN REPORT'),
              pw.SizedBox(height: 20),
              _buildTaxpayerInfo(user),
              pw.SizedBox(height: 20),
              _buildReturnInfo(taxReturn),
              pw.SizedBox(height: 20),
              _buildIncomeDetails(taxReturn),
              pw.SizedBox(height: 20),
              _buildTaxCalculation(calculation),
              pw.SizedBox(height: 20),
              _buildDeclaration(user),
              pw.SizedBox(height: 20),
              _buildFooter(),
            ],
          );
        },
      ),
    );

    final bytes = await pdf.save();
    return await _savePDF(bytes, 'Tax_Return_${taxReturn['filingId']}');
  }

  // ==================== EXPORT TAX SUMMARY TO PDF ====================
  static Future<File> exportTaxSummaryToPDF({
    required Map<String, dynamic> summary,
    required List<Map<String, dynamic>> returns,
    required Map<String, dynamic> user,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader('TAX SUMMARY REPORT'),
              pw.SizedBox(height: 20),
              _buildTaxpayerInfo(user),
              pw.SizedBox(height: 20),
              _buildSummaryStats(summary),
              pw.SizedBox(height: 20),
              _buildReturnsTable(returns),
              pw.SizedBox(height: 20),
              _buildFooter(),
            ],
          );
        },
      ),
    );

    final bytes = await pdf.save();
    return await _savePDF(
        bytes, 'Tax_Summary_${DateTime.now().millisecondsSinceEpoch}');
  }

  // ==================== EXPORT PAYMENTS TO PDF ====================
  static Future<File> exportPaymentsToPDF({
    required List<Map<String, dynamic>> payments,
    required Map<String, dynamic> user,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader('PAYMENT HISTORY REPORT'),
              pw.SizedBox(height: 20),
              _buildTaxpayerInfo(user),
              pw.SizedBox(height: 20),
              _buildPaymentsTable(payments),
              pw.SizedBox(height: 20),
              _buildPaymentSummary(payments),
              pw.SizedBox(height: 20),
              _buildFooter(),
            ],
          );
        },
      ),
    );

    final bytes = await pdf.save();
    return await _savePDF(
        bytes, 'Payment_History_${DateTime.now().millisecondsSinceEpoch}');
  }

  // ==================== EXPORT TAX RULES TO PDF ====================
  static Future<File> exportTaxRulesToPDF({
    required List<Map<String, dynamic>> rules,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader('TAX RULES REPORT'),
              pw.SizedBox(height: 20),
              _buildRulesTable(rules),
              pw.SizedBox(height: 20),
              _buildFooter(),
            ],
          );
        },
      ),
    );

    final bytes = await pdf.save();
    return await _savePDF(
        bytes, 'Tax_Rules_${DateTime.now().millisecondsSinceEpoch}');
  }

  // ==================== EXPORT USER PROFILE TO PDF ====================
  static Future<File> exportUserProfileToPDF({
    required Map<String, dynamic> user,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader('USER PROFILE REPORT'),
              pw.SizedBox(height: 20),
              _buildUserProfile(user),
              pw.SizedBox(height: 20),
              _buildFooter(),
            ],
          );
        },
      ),
    );

    final bytes = await pdf.save();
    return await _savePDF(bytes, 'User_Profile_${user['username']}');
  }

  // ==================== GENERATE RECEIPT PDF ====================
  static Future<File> generateReceiptPDF({
    required Map<String, dynamic> payment,
    required Map<String, dynamic> user,
    required Map<String, dynamic> taxReturn,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildReceiptHeader(payment),
              pw.SizedBox(height: 20),
              _buildTaxpayerInfo(user),
              pw.SizedBox(height: 20),
              _buildPaymentDetails(payment, taxReturn),
              pw.SizedBox(height: 20),
              _buildReceiptFooter(),
              pw.SizedBox(height: 20),
              _buildFooter(),
            ],
          );
        },
      ),
    );

    final bytes = await pdf.save();
    return await _savePDF(bytes, 'Receipt_${payment['controlNumber']}');
  }

  // ==================== HELPER BUILD METHODS ====================

  static pw.Widget _buildHeader(String title) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'TANZANIA REVENUE AUTHORITY',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue900,
              ),
            ),
            pw.Container(
              width: 60,
              height: 60,
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.blue900, width: 2),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Center(
                child: pw.Text(
                  'TRA',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue900,
                  ),
                ),
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Divider(),
        pw.SizedBox(height: 8),
        pw.Center(
          child: pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue800,
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildTaxpayerInfo(Map<String, dynamic> user) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'TAXPAYER INFORMATION',
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue700,
          ),
        ),
        pw.SizedBox(height: 8),
        _buildInfoRow('Full Name', user['fullName'] ?? 'N/A'),
        _buildInfoRow('TIN Number', user['tinNumber'] ?? 'N/A'),
        _buildInfoRow('Email', user['email'] ?? 'N/A'),
        _buildInfoRow('Mobile', user['mobileNumber'] ?? 'N/A'),
        _buildInfoRow('Taxpayer Type', user['taxpayerType'] ?? 'Individual'),
      ],
    );
  }

  static pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 120,
            child: pw.Text(
              label,
              style: const pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey700,
              ),
            ),
          ),
          pw.Text(
            ': ',
            style: const pw.TextStyle(
              fontSize: 10,
              color: PdfColors.grey700,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildReturnInfo(Map<String, dynamic> taxReturn) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'RETURN INFORMATION',
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue700,
          ),
        ),
        pw.SizedBox(height: 8),
        _buildInfoRow('Filing ID', taxReturn['filingId'] ?? 'N/A'),
        _buildInfoRow('Assessment Year', taxReturn['assessmentYear'] ?? 'N/A'),
        _buildInfoRow('Filing Type', taxReturn['filingType'] ?? 'N/A'),
        _buildInfoRow('Status', taxReturn['status'] ?? 'N/A'),
        _buildInfoRow(
            'Submission Date',
            taxReturn['submissionDate'] != null
                ? DateFormat('dd MMM yyyy')
                    .format(DateTime.parse(taxReturn['submissionDate']))
                : 'Not Submitted'),
      ],
    );
  }

  static pw.Widget _buildIncomeDetails(Map<String, dynamic> taxReturn) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'INCOME & TAX DETAILS',
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue700,
          ),
        ),
        pw.SizedBox(height: 8),
        _buildTable([
          ['Description', 'Amount (TSh)'],
          ['Total Income', _formatCurrency(taxReturn['totalIncome'] ?? 0)],
          ['Deductions', _formatCurrency(taxReturn['deductions'] ?? 0)],
          ['Taxable Income', _formatCurrency(taxReturn['taxableIncome'] ?? 0)],
        ]),
      ],
    );
  }

  static pw.Widget _buildTaxCalculation(Map<String, dynamic> calculation) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'TAX CALCULATION',
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue700,
          ),
        ),
        pw.SizedBox(height: 8),
        _buildTable([
          ['Item', 'Amount (TSh)'],
          ['Tax Payable', _formatCurrency(calculation['taxPayable'] ?? 0)],
          ['Skills Levy (5%)', _formatCurrency(calculation['skillsLevy'] ?? 0)],
          [
            'Railway Levy (5%)',
            _formatCurrency(calculation['railwayLevy'] ?? 0)
          ],
          ['Cess (4%)', _formatCurrency(calculation['cess'] ?? 0)],
          ['', ''],
          [
            'TOTAL TAX LIABILITY',
            _formatCurrency(calculation['totalLiability'] ?? 0)
          ],
        ]),
      ],
    );
  }

  static pw.Widget _buildDeclaration(Map<String, dynamic> user) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'DECLARATION',
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue700,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Container(
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey400),
            borderRadius: pw.BorderRadius.circular(4),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'I, ${user['fullName'] ?? 'N/A'}, hereby declare that the information provided in this tax return is true and correct to the best of my knowledge and belief.',
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
                      pw.Text('TIN: ${user['tinNumber'] ?? 'N/A'}'),
                      pw.SizedBox(height: 10),
                      pw.Text('Place: ____________________'),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildFooter() {
    return pw.Column(
      children: [
        pw.Divider(),
        pw.SizedBox(height: 8),
        pw.Text(
          'This is a computer-generated document. No signature is required.',
          style: const pw.TextStyle(
            fontSize: 8,
            color: PdfColors.grey600,
          ),
        ),
        pw.Text(
          'Tanzania Revenue Authority - Tax Compliance System',
          style: const pw.TextStyle(
            fontSize: 8,
            color: PdfColors.grey600,
          ),
        ),
        pw.Text(
          'Generated on: ${DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now())}',
          style: const pw.TextStyle(
            fontSize: 8,
            color: PdfColors.grey600,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildTable(List<List<String>> data) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
      children: data.map((row) {
        final isHeader = data.indexOf(row) == 0;
        final isTotal = row[0].startsWith('TOTAL') ||
            row[0].isEmpty && data.indexOf(row) > 0;
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

  static pw.Widget _buildSummaryStats(Map<String, dynamic> summary) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'SUMMARY STATISTICS',
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue700,
          ),
        ),
        pw.SizedBox(height: 8),
        _buildInfoRow('Total Returns', '${summary['totalReturns'] ?? 0}'),
        _buildInfoRow(
            'Completed Returns', '${summary['completedReturns'] ?? 0}'),
        _buildInfoRow('Total Tax', _formatCurrency(summary['totalTax'] ?? 0)),
        _buildInfoRow('Total Paid', _formatCurrency(summary['totalPaid'] ?? 0)),
        _buildInfoRow(
            'Total Refund', _formatCurrency(summary['totalRefund'] ?? 0)),
      ],
    );
  }

  static pw.Widget _buildReturnsTable(List<Map<String, dynamic>> returns) {
    final headers = ['Filing ID', 'Year', 'Income', 'Tax', 'Status'];

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'RETURN HISTORY',
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue700,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.blue100),
              children: headers.map((header) {
                return pw.Padding(
                  padding: const pw.EdgeInsets.all(6),
                  child: pw.Text(
                    header,
                    style: pw.TextStyle(
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue900,
                    ),
                  ),
                );
              }).toList(),
            ),
            ...returns.take(10).map((item) {
              return pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(
                      item['filingId'] ?? 'N/A',
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(
                      item['assessmentYear'] ?? 'N/A',
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(
                      _formatCurrency(item['totalIncome'] ?? 0),
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(
                      _formatCurrency(item['totalLiability'] ?? 0),
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(
                      item['status'] ?? 'N/A',
                      style: pw.TextStyle(
                        fontSize: 8,
                        color: item['status'] == 'COMPLETED'
                            ? PdfColors.green
                            : PdfColors.orange,
                      ),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
        if (returns.length > 10)
          pw.Padding(
            padding: const pw.EdgeInsets.only(top: 8),
            child: pw.Text(
              '... and ${returns.length - 10} more returns',
              style: const pw.TextStyle(
                fontSize: 8,
                color: PdfColors.grey600,
              ),
            ),
          ),
      ],
    );
  }

  static pw.Widget _buildPaymentsTable(List<Map<String, dynamic>> payments) {
    final headers = [
      'Reference',
      'Control No.',
      'Amount',
      'Method',
      'Status',
      'Date'
    ];

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'PAYMENT HISTORY',
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue700,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.blue100),
              children: headers.map((header) {
                return pw.Padding(
                  padding: const pw.EdgeInsets.all(6),
                  child: pw.Text(
                    header,
                    style: pw.TextStyle(
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue900,
                    ),
                  ),
                );
              }).toList(),
            ),
            ...payments.take(10).map((item) {
              return pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(
                      item['paymentReference'] ?? 'N/A',
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(
                      item['controlNumber'] ?? 'N/A',
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(
                      _formatCurrency(item['amount'] ?? 0),
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(
                      item['paymentMethod'] ?? 'N/A',
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(
                      item['paymentStatus'] ?? 'N/A',
                      style: pw.TextStyle(
                        fontSize: 8,
                        color: item['paymentStatus'] == 'COMPLETED'
                            ? PdfColors.green
                            : PdfColors.orange,
                      ),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(
                      item['paymentDate'] != null
                          ? DateFormat('dd MMM yyyy')
                              .format(DateTime.parse(item['paymentDate']))
                          : 'N/A',
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildPaymentSummary(List<Map<String, dynamic>> payments) {
    final totalAmount =
        payments.fold(0.0, (sum, p) => sum + (p['amount'] ?? 0));
    final totalCompleted = payments
        .where((p) => p['paymentStatus'] == 'COMPLETED')
        .fold(0.0, (sum, p) => sum + (p['amount'] ?? 0));
    final totalPending = payments
        .where((p) => p['paymentStatus'] == 'PENDING')
        .fold(0.0, (sum, p) => sum + (p['amount'] ?? 0));

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'PAYMENT SUMMARY',
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue700,
          ),
        ),
        pw.SizedBox(height: 8),
        _buildInfoRow('Total Payments', '${payments.length}'),
        _buildInfoRow('Total Amount', _formatCurrency(totalAmount)),
        _buildInfoRow('Completed', _formatCurrency(totalCompleted)),
        _buildInfoRow('Pending', _formatCurrency(totalPending)),
      ],
    );
  }

  static pw.Widget _buildRulesTable(List<Map<String, dynamic>> rules) {
    final headers = ['Code', 'Name', 'Type', 'Rate', 'Active'];

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'TAX RULES',
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue700,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.blue100),
              children: headers.map((header) {
                return pw.Padding(
                  padding: const pw.EdgeInsets.all(6),
                  child: pw.Text(
                    header,
                    style: pw.TextStyle(
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue900,
                    ),
                  ),
                );
              }).toList(),
            ),
            ...rules.map((item) {
              return pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(
                      item['ruleCode'] ?? 'N/A',
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(
                      item['ruleName'] ?? 'N/A',
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(
                      item['ruleType'] ?? 'N/A',
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(
                      '${item['taxRate'] ?? 0}%',
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(
                      item['isActive'] == true ? '✓' : '✗',
                      style: pw.TextStyle(
                        fontSize: 8,
                        color: item['isActive'] == true
                            ? PdfColors.green
                            : PdfColors.red,
                      ),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildUserProfile(Map<String, dynamic> user) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'PROFILE INFORMATION',
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue700,
          ),
        ),
        pw.SizedBox(height: 8),
        _buildInfoRow('Username', user['username'] ?? 'N/A'),
        _buildInfoRow('Full Name', user['fullName'] ?? 'N/A'),
        _buildInfoRow('Email', user['email'] ?? 'N/A'),
        _buildInfoRow('TIN Number', user['tinNumber'] ?? 'N/A'),
        _buildInfoRow('Mobile Number', user['mobileNumber'] ?? 'N/A'),
        _buildInfoRow('Taxpayer Type', user['taxpayerType'] ?? 'N/A'),
        _buildInfoRow('Business Name', user['businessName'] ?? 'N/A'),
        _buildInfoRow('Business Sector', user['businessSector'] ?? 'N/A'),
        _buildInfoRow('Role', user['role'] ?? 'N/A'),
        _buildInfoRow(
            'Status', user['isActive'] == true ? 'Active' : 'Inactive'),
        _buildInfoRow(
            'Registered',
            user['createdAt'] != null
                ? DateFormat('dd MMM yyyy')
                    .format(DateTime.parse(user['createdAt']))
                : 'N/A'),
      ],
    );
  }

  static pw.Widget _buildReceiptHeader(Map<String, dynamic> payment) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Center(
          child: pw.Text(
            'TAX PAYMENT RECEIPT',
            style: pw.TextStyle(
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Center(
          child: pw.Text(
            'Control Number: ${payment['controlNumber'] ?? 'N/A'}',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildPaymentDetails(
      Map<String, dynamic> payment, Map<String, dynamic> taxReturn) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'PAYMENT DETAILS',
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue700,
          ),
        ),
        pw.SizedBox(height: 8),
        _buildInfoRow(
            'Payment Reference', payment['paymentReference'] ?? 'N/A'),
        _buildInfoRow('Control Number', payment['controlNumber'] ?? 'N/A'),
        _buildInfoRow('Amount', _formatCurrency(payment['amount'] ?? 0)),
        _buildInfoRow('Payment Method', payment['paymentMethod'] ?? 'N/A'),
        _buildInfoRow('Status', payment['paymentStatus'] ?? 'N/A'),
        _buildInfoRow('Transaction ID', payment['transactionId'] ?? 'N/A'),
        _buildInfoRow(
            'Payment Date',
            payment['paymentDate'] != null
                ? DateFormat('dd MMM yyyy HH:mm')
                    .format(DateTime.parse(payment['paymentDate']))
                : 'N/A'),
        _buildInfoRow('Tax Return', taxReturn['filingId'] ?? 'N/A'),
        _buildInfoRow('Assessment Year', taxReturn['assessmentYear'] ?? 'N/A'),
      ],
    );
  }

  static pw.Widget _buildReceiptFooter() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            'This receipt is a confirmation of your tax payment.',
            style: const pw.TextStyle(fontSize: 10),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Please keep this receipt for your records.',
            style: const pw.TextStyle(
              fontSize: 10,
              color: PdfColors.grey700,
            ),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'For verification, visit: https://verify.tra.go.tz',
            style: const pw.TextStyle(
              fontSize: 10,
              color: PdfColors.blue700,
            ),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ==================== HELPER FUNCTIONS ====================

  static String _formatCurrency(double amount) {
    return '$_currency ${NumberFormat('#,##,###.00').format(amount)}';
  }

  static Future<File> _savePDF(List<int> bytes, String name) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = '${name.replaceAll(' ', '_')}.pdf';
      final filePath = '${directory.path}/$fileName';

      final file = File(filePath);
      await file.writeAsBytes(bytes);

      return file;
    } catch (e) {
      throw Exception('Failed to save PDF: $e');
    }
  }

  // ==================== SHARE/OPEN/PRINT FUNCTIONS ====================

  static Future<void> sharePDF(File file) async {
    try {
      await Share.shareXFiles(
        [XFile(file.path)],
        text: '📄 Tax Compliance Report',
        subject: 'Tax Report',
      );
    } catch (e) {
      throw Exception('Failed to share PDF: $e');
    }
  }

  static Future<void> openPDF(File file) async {
    try {
      await OpenFile.open(file.path);
    } catch (e) {
      throw Exception('Failed to open PDF: $e');
    }
  }

  static Future<void> printPDF(File file) async {
    try {
      final bytes = await file.readAsBytes();
      await Printing.sharePdf(
        bytes: bytes,
        filename: file.path.split('/').last,
      );
    } catch (e) {
      throw Exception('Failed to print PDF: $e');
    }
  }

  static Future<void> deletePDF(File file) async {
    try {
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete PDF: $e');
    }
  }
}
