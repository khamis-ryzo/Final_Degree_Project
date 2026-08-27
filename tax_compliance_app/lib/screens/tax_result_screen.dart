import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/tax_calculation.dart';
import '../models/tax_return.dart';
import '../providers/auth_provider.dart';
import '../services/tra_report_service.dart';
import '../widgets/custom_button.dart';
import '../utils/helpers.dart';
import '../utils/constants.dart';
// import 'dashboard_screen.dart'; // removed unused import

class TaxResultScreen extends StatefulWidget {
  final TaxReturn taxReturn;
  final TaxCalculationResponse calculationResult;
  final GeneratedTaxReport? report;

  const TaxResultScreen({
    super.key,
    required this.taxReturn,
    required this.calculationResult,
    this.report,
  });

  @override
  State<TaxResultScreen> createState() => _TaxResultScreenState();
}

class _TaxResultScreenState extends State<TaxResultScreen> {
  bool _isDownloading = false;
  bool _isSharing = false;
  GeneratedTaxReport? _report;

  @override
  void initState() {
    super.initState();
    _report = widget.report;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tax Calculation Result'),
        backgroundColor: AppColors.primary,
        actions: [
          // Download Button
          IconButton(
            icon: _isDownloading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.download),
            onPressed: _isDownloading ? null : _handleDownloadReport,
            tooltip: 'Download Report',
          ),
          // Share Button
          IconButton(
            icon: _isSharing
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.share),
            onPressed: _isSharing ? null : _handleShareReport,
            tooltip: 'Share Report',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSuccessHeader(),
            const SizedBox(height: 20),
            _buildTaxSummary(),
            const SizedBox(height: 20),
            _buildTaxCalculation(),
            const SizedBox(height: 20),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF43A047), Color(0xFF2E7D32)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.check_circle,
            color: Colors.white,
            size: 60,
          ),
          const SizedBox(height: 12),
          const Text(
            'Tax Calculation Complete!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Filing ID: ${widget.taxReturn.filingId}',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          if (_report != null) const SizedBox(height: 8),
          if (_report != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                '📄 Report Generated',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTaxSummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tax Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildSummaryRow(
                'Assessment Year', widget.taxReturn.assessmentYear),
            _buildSummaryRow('Filing Type', widget.taxReturn.filingType),
            _buildDivider(),
            _buildSummaryRow(
              'Total Income',
              'TSh ${NumberFormat('#,##,###').format(widget.taxReturn.totalIncome)}',
            ),
            _buildSummaryRow(
              'Total Deductions',
              'TSh ${NumberFormat('#,##,###').format(widget.taxReturn.deductions)}',
            ),
            _buildSummaryRow(
              'Taxable Income',
              'TSh ${NumberFormat('#,##,###').format(widget.calculationResult.taxableIncome)}',
              isBold: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaxCalculation() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tax Calculation',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildSummaryRow(
              'PAYE Tax',
              'TSh ${NumberFormat('#,##,###').format(widget.calculationResult.taxPayable)}',
            ),
            _buildSummaryRow(
              'Cess (4%)',
              'TSh ${NumberFormat('#,##,###').format(widget.calculationResult.cess)}',
            ),
            _buildDivider(),
            _buildSummaryRow(
              'Total Tax Liability',
              'TSh ${NumberFormat('#,##,###').format(widget.calculationResult.totalTax)}',
              isBold: true,
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: CustomButton(
                text: 'Download Report',
                onPressed: _isDownloading ? null : _handleDownloadReport,
                isLoading: _isDownloading,
                icon: Icons.download,
                backgroundColor: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isSharing ? null : _handleShareReport,
                icon: const Icon(Icons.share),
                label: const Text('Share Report'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  if (_report != null) {
                    TRAReportService.printReport(_report!);
                  } else {
                    Helpers.showInfoSnackBar(
                        context, 'Please generate the report first');
                  }
                },
                icon: const Icon(Icons.print),
                label: const Text('Print'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.edit),
          label: const Text('Go Back and Edit'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value,
      {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Divider(),
    );
  }

  // ==================== HANDLE METHODS ====================

  Future<void> _handleDownloadReport() async {
    setState(() {
      _isDownloading = true;
    });

    try {
      final report = await _ensureReport();

      // Download the report
      await TRAReportService.downloadReport(report);

      if (mounted) {
        Helpers.showSuccessSnackBar(
          context,
          'Report downloaded successfully!',
        );
      }
    } catch (e) {
      if (mounted) {
        Helpers.showErrorSnackBar(
          context,
          'Failed to download report: ${e.toString()}',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  Future<void> _handleShareReport() async {
    setState(() {
      _isSharing = true;
    });

    try {
      final report = await _ensureReport();

      await TRAReportService.shareReport(report);
    } catch (e) {
      if (mounted) {
        Helpers.showErrorSnackBar(
          context,
          'Failed to share report: ${e.toString()}',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSharing = false;
        });
      }
    }
  }

  Future<GeneratedTaxReport> _ensureReport() async {
    final existingReport = _report;
    if (existingReport != null) return existingReport;

    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user == null) {
      throw StateError('You must be signed in to generate a tax report.');
    }

    final report = await TRAReportService.generateEntityTaxReport(
      taxReturn: widget.taxReturn,
      user: user,
      taxData: {
        'totalIncome': widget.taxReturn.totalIncome,
        'totalDeductions': widget.taxReturn.deductions,
        'chargeableIncome': widget.calculationResult.taxableIncome,
        'taxPayable': widget.calculationResult.taxPayable,
        'cess': widget.calculationResult.cess,
        'totalLiability': widget.calculationResult.totalTax,
      },
      taxPayable: widget.calculationResult.taxPayable,
      totalLiability: widget.calculationResult.totalTax,
    );

    if (mounted) {
      setState(() => _report = report);
    }
    return report;
  }
}
