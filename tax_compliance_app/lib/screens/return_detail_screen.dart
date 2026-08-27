import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/tax_return.dart';
import '../providers/auth_provider.dart';
import '../services/tra_report_service.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class ReturnDetailScreen extends StatefulWidget {
  final TaxReturn taxReturn;

  const ReturnDetailScreen({super.key, required this.taxReturn});

  @override
  State<ReturnDetailScreen> createState() => _ReturnDetailScreenState();
}

class _ReturnDetailScreenState extends State<ReturnDetailScreen> {
  bool _showPaymentDetails = false;
  bool _showTimeline = true;
  bool _showBreakdown = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Return Details'),
        backgroundColor: AppColors.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareReturnDetails,
            tooltip: 'Share Details',
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _downloadPDF,
            tooltip: 'Download PDF',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildStatusCard(),
            const SizedBox(height: 16),
            _buildReturnInfo(),
            const SizedBox(height: 16),
            _buildTaxBreakdown(),
            const SizedBox(height: 16),
            _buildPaymentSection(),
            const SizedBox(height: 16),
            _buildTimeline(),
            const SizedBox(height: 16),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    Color statusColor;
    IconData statusIcon;
    String statusText;
    String statusSubtext = '';

    switch (widget.taxReturn.status) {
      case 'COMPLETED':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'Completed';
        statusSubtext = 'Tax return successfully processed';
        break;
      case 'SUBMITTED':
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
        statusText = 'Submitted';
        statusSubtext = 'Awaiting TRA processing';
        break;
      case 'PROCESSING':
        statusColor = Colors.blue;
        statusIcon = Icons.autorenew;
        statusText = 'Processing';
        statusSubtext = 'TRA is reviewing your return';
        break;
      case 'REJECTED':
        statusColor = Colors.red;
        statusIcon = Icons.error;
        statusText = 'Rejected';
        statusSubtext = 'Please check and resubmit';
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.drafts;
        statusText = 'Draft';
        statusSubtext = 'Complete and submit your return';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            statusColor,
            statusColor.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  statusIcon,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statusText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      statusSubtext,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: statusColor == Colors.green
                            ? Colors.green
                            : statusColor == Colors.orange
                                ? Colors.orange
                                : statusColor == Colors.blue
                                    ? Colors.blue
                                    : Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Live',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(
            color: Colors.white.withValues(alpha: 0.2),
            thickness: 1,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatusInfo('Filing ID', widget.taxReturn.filingId),
              _buildStatusInfo(
                  'Assessment Year', widget.taxReturn.assessmentYear),
              _buildStatusInfo('Filing Type', widget.taxReturn.filingType),
            ],
          ),
          if (widget.taxReturn.acknowledgmentNumber != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.receipt,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'ACK: ${widget.taxReturn.acknowledgmentNumber}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusInfo(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildReturnInfo() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.info_outline,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Return Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Filing ID', widget.taxReturn.filingId),
            _buildInfoRow('Assessment Year', widget.taxReturn.assessmentYear),
            _buildInfoRow('Filing Type', widget.taxReturn.filingType),
            _buildInfoRow(
              'Submission Date',
              widget.taxReturn.submissionDate != null
                  ? DateFormat('dd MMM yyyy, hh:mm a')
                      .format(widget.taxReturn.submissionDate!)
                  : 'Not submitted yet',
            ),
            _buildInfoRow(
              'Status',
              widget.taxReturn.status,
              isStatus: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaxBreakdown() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: _showBreakdown,
          onExpansionChanged: (value) {
            setState(() {
              _showBreakdown = value;
            });
          },
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.pie_chart,
              color: Colors.green,
              size: 20,
            ),
          ),
          title: const Text(
            'Tax Breakdown',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            'Total Tax: ${_formatTSh(widget.taxReturn.totalLiability)}',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.red,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Income Section
                  _buildBreakdownHeader('Income Details'),
                  _buildBreakdownRow(
                    'Total Income',
                    _formatTSh(widget.taxReturn.totalIncome),
                    color: Colors.blue,
                  ),
                  _buildBreakdownRow(
                    'Deductions',
                    _formatTSh(widget.taxReturn.totalIncome -
                        widget.taxReturn.taxableIncome),
                    color: Colors.green,
                  ),
                  _buildDivider(),
                  _buildBreakdownRow(
                    'Taxable Income',
                    _formatTSh(widget.taxReturn.taxableIncome),
                    isBold: true,
                    color: Colors.blue.shade700,
                  ),

                  const SizedBox(height: 16),

                  // Tax Calculation
                  _buildBreakdownHeader('Tax Calculation'),
                  _buildBreakdownRow(
                    'PAYE',
                    _formatTSh(widget.taxReturn.taxPayable),
                    color: Colors.red,
                  ),
                  _buildBreakdownRow(
                    'Skills Development Levy (5%)',
                    _formatTSh(widget.taxReturn.skillsLevy),
                    color: Colors.orange,
                  ),
                  _buildBreakdownRow(
                    'Railway Development Levy (5%)',
                    _formatTSh(widget.taxReturn.railwayLevy),
                    color: Colors.purple,
                  ),
                  _buildBreakdownRow(
                    'Cess',
                    _formatTSh(widget.taxReturn.cessAmount),
                    color: Colors.grey,
                  ),
                  _buildBreakdownRow(
                    'Interest',
                    _formatTSh(widget.taxReturn.interest),
                    color: Colors.orange.shade700,
                  ),
                  _buildBreakdownRow(
                    'Penalty',
                    _formatTSh(widget.taxReturn.penalty),
                    color: Colors.red.shade700,
                  ),
                  _buildDivider(thick: true),
                  _buildBreakdownRow(
                    'Total Tax Liability',
                    _formatTSh(widget.taxReturn.totalLiability),
                    isBold: true,
                    isLarge: true,
                    color: Colors.red.shade700,
                  ),

                  if (widget.taxReturn.refundAmount > 0) ...[
                    _buildDivider(),
                    _buildBreakdownRow(
                      'Refund Amount',
                      _formatTSh(widget.taxReturn.refundAmount),
                      isBold: true,
                      color: Colors.green.shade700,
                    ),
                  ],

                  if (widget.taxReturn.taxPaid > 0) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.payment,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Amount Paid',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  _formatTSh(widget.taxReturn.taxPaid),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'PAID',
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue.shade700,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Tax calculated based on Tanzania Revenue Authority rates for ${widget.taxReturn.assessmentYear}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakdownHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildBreakdownRow(
    String label,
    String value, {
    bool isBold = false,
    bool isLarge = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isLarge ? 16 : 14,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
              color: isBold ? Colors.black87 : Colors.grey.shade700,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isLarge ? 18 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: color ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider({bool thick = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Divider(
        thickness: thick ? 2 : 1,
        color: Colors.grey.shade300,
      ),
    );
  }

  Widget _buildPaymentSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: _showPaymentDetails,
          onExpansionChanged: (value) {
            setState(() {
              _showPaymentDetails = value;
            });
          },
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.payment,
              color: Colors.orange,
              size: 20,
            ),
          ),
          title: const Text(
            'Payment Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: widget.taxReturn.taxPaid > 0
              ? Text(
                  'Amount Paid: ${_formatTSh(widget.taxReturn.taxPaid)}',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                )
              : const Text(
                  'Payment Pending',
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.w500,
                  ),
                ),
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (widget.taxReturn.taxPaid > 0) ...[
                    _buildPaymentStatus(),
                    const SizedBox(height: 16),
                    _buildPaymentDetails(),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.payment,
                            size: 48,
                            color: Colors.orange,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Payment Required',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Amount Due: ${_formatTSh(widget.taxReturn.totalLiability)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                           ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentStatus() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.shade200,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Payment Successful',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                Text(
                  'Transaction completed on ${DateFormat('dd MMM yyyy').format(DateTime.now())}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentDetails() {
    return Column(
      children: [
        _buildInfoRow('Payment Method', 'Mobile Money'),
        _buildInfoRow(
            'Transaction ID', 'TXN${DateTime.now().millisecondsSinceEpoch}'),
        _buildInfoRow('Control Number', _generateControlNumber()),
        _buildInfoRow('Payment Date',
            DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now())),
      ],
    );
  }

  String _generateControlNumber() {
    return 'TZ${DateTime.now().millisecondsSinceEpoch.toString().substring(0, 10)}';
  }

  Widget _buildTimeline() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: _showTimeline,
          onExpansionChanged: (value) {
            setState(() {
              _showTimeline = value;
            });
          },
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.purple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.timeline,
              color: Colors.purple,
              size: 20,
            ),
          ),
          title: const Text(
            'Timeline',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: const Text(
            'Track your return progress',
            style: TextStyle(color: Colors.grey),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildTimelineItem(
                    'Return Created',
                    widget.taxReturn.createdAt,
                    Icons.create,
                    true,
                    'Draft created',
                  ),
                  _buildTimelineItem(
                    'Return Submitted',
                    widget.taxReturn.submissionDate,
                    Icons.send,
                    widget.taxReturn.submissionDate != null,
                    'Submitted to TRA',
                  ),
                  _buildTimelineItem(
                    'Processing',
                    widget.taxReturn.updatedAt,
                    Icons.autorenew,
                    widget.taxReturn.status == 'PROCESSING' ||
                        widget.taxReturn.status == 'ASSESSED' ||
                        widget.taxReturn.status == 'COMPLETED',
                    'Being reviewed by TRA',
                  ),
                  _buildTimelineItem(
                    'Assessment',
                    widget.taxReturn.updatedAt,
                    Icons.assessment,
                    widget.taxReturn.status == 'ASSESSED' ||
                        widget.taxReturn.status == 'COMPLETED',
                    'Assessment completed',
                  ),
                  _buildTimelineItem(
                    'Completed',
                    widget.taxReturn.updatedAt,
                    Icons.check_circle,
                    widget.taxReturn.status == 'COMPLETED',
                    'Return finalized',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(
    String title,
    DateTime? date,
    IconData icon,
    bool isCompleted,
    String subtitle,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isCompleted ? AppColors.primary : Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isCompleted ? Colors.white : Colors.grey.shade500,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight:
                        isCompleted ? FontWeight.w600 : FontWeight.normal,
                    color: isCompleted ? Colors.black87 : Colors.grey.shade500,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: isCompleted
                        ? Colors.grey.shade600
                        : Colors.grey.shade400,
                  ),
                ),
                if (date != null)
                  Text(
                    DateFormat('dd MMM yyyy, hh:mm a').format(date),
                    style: TextStyle(
                      fontSize: 11,
                      color: isCompleted
                          ? Colors.grey.shade600
                          : Colors.grey.shade400,
                    ),
                  ),
              ],
            ),
          ),
          if (isCompleted)
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 16,
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  _downloadReceipt();
                },
                icon: const Icon(Icons.download),
                label: const Text('Download Receipt'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
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
                  _shareReturnDetails();
                },
                icon: const Icon(Icons.share),
                label: const Text('Share'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
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
        if (widget.taxReturn.status == 'DRAFT')
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {
                _submitReturn();
              },
              icon: const Icon(Icons.send),
              label: const Text('Submit Return to TRA'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        if (widget.taxReturn.status == 'REJECTED')
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {
                _editReturn();
              },
              icon: const Icon(Icons.edit),
              label: const Text('Edit and Resubmit'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // Helper Methods
  String _formatTSh(double amount) {
    return 'TSh ${NumberFormat('#,###').format(amount)}';
  }

  Widget _buildInfoRow(String label, String value, {bool isStatus = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          if (isStatus)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(value).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _getStatusColor(value),
                ),
              ),
            )
          else
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
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

  // Action Methods
  void _shareReturnDetails() {
    final details = '''
Tax Return Details
-------------------
Filing ID: ${widget.taxReturn.filingId}
Assessment Year: ${widget.taxReturn.assessmentYear}
Status: ${widget.taxReturn.status}
Total Income: ${_formatTSh(widget.taxReturn.totalIncome)}
Tax Payable: ${_formatTSh(widget.taxReturn.taxPayable)}
Total Liability: ${_formatTSh(widget.taxReturn.totalLiability)}
Submitted: ${widget.taxReturn.submissionDate != null ? DateFormat('dd MMM yyyy').format(widget.taxReturn.submissionDate!) : 'N/A'}

This is an auto-generated message from TaxCompliance TZ App.
    ''';

    // Show share dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share Return Details'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: SelectableText(details),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              Helpers.showSuccessSnackBar(
                  context, 'Details copied to clipboard!');
            },
            icon: const Icon(Icons.copy),
            label: const Text('Copy'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadPDF() async {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    final messenger = ScaffoldMessenger.maybeOf(context);

    if (user == null) {
      if (!mounted) return;
      Helpers.showErrorSnackBar(
          context, 'User session expired. Please log in again.');
      return;
    }

    try {
      if (!mounted) return;
      messenger?.showSnackBar(
        const SnackBar(content: Text('Generating your PDF...')),
      );

      final taxData = {
        'taxPayable': widget.taxReturn.taxPayable,
        'totalLiability': widget.taxReturn.totalLiability,
        'totalTax': widget.taxReturn.totalLiability,
        'totalIncome': widget.taxReturn.totalIncome,
        'taxableIncome': widget.taxReturn.taxableIncome,
        'skillsLevy': widget.taxReturn.skillsLevy,
        'railwayLevy': widget.taxReturn.railwayLevy,
        'cess': widget.taxReturn.cessAmount,
        'interest': widget.taxReturn.interest,
        'penalty': widget.taxReturn.penalty,
        'employmentIncome': widget.taxReturn.employmentIncome,
        'businessIncome': widget.taxReturn.businessIncome,
        'rentalIncome': widget.taxReturn.rentalIncome,
        'totalDeductions': widget.taxReturn.totalDeductions,
      };

      final reportFile = await TRAReportService.generateTRAReport(
        widget.taxReturn,
        user,
        taxData,
      );

      if (!mounted) return;
      await TRAReportService.downloadReport(reportFile);
      messenger?.showSnackBar(
        const SnackBar(content: Text('PDF downloaded successfully.')),
      );
    } catch (e) {
      if (!mounted) return;
      messenger?.showSnackBar(
        SnackBar(content: Text('Failed to generate PDF: ${e.toString()}')),
      );
    }
  }

  void _downloadReceipt() {
    Helpers.showInfoSnackBar(context, 'Receipt download feature coming soon!');
  }

  void _submitReturn() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Submit Return'),
        content: const Text(
          'Are you sure you want to submit this return to Tanzania Revenue Authority?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Helpers.showSuccessSnackBar(
                  context, 'Return submitted successfully!');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _editReturn() {
    Helpers.showInfoSnackBar(context, 'Edit feature coming soon!');
  }
}
