import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SearchResultCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final String type;
  final VoidCallback onTap;
  final Widget? trailing;

  const SearchResultCard({
    super.key,
    required this.data,
    required this.type,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _getTitle(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildStatusBadge(),
                ],
              ),
              const SizedBox(height: 8),

              // Details
              _buildDetails(),
              const SizedBox(height: 8),

              // Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: _buildFooter()),
                  if (trailing != null) trailing!,
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTitle() {
    switch (type) {
      case 'tax_return':
        return data['filingId'] ?? 'Tax Return';
      case 'payment':
        return data['paymentReference'] ?? 'Payment';
      case 'tax_rule':
        return data['ruleName'] ?? 'Tax Rule';
      case 'user':
        return data['fullName'] ?? 'User';
      default:
        return 'Result';
    }
  }

  Widget _buildStatusBadge() {
    String status = data['status'] ?? data['paymentStatus'] ?? 'N/A';
    Color color;

    switch (status.toUpperCase()) {
      case 'COMPLETED':
        color = Colors.green;
        break;
      case 'SUBMITTED':
      case 'PROCESSING':
        color = Colors.orange;
        break;
      case 'REJECTED':
        color = Colors.red;
        break;
      case 'FAILED':
        color = Colors.red;
        break;
      case 'PENDING':
        color = Colors.blue;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildDetails() {
    switch (type) {
      case 'tax_return':
        return Column(
          children: [
            _buildDetailRow('TIN', data['tinNumber'] ?? 'N/A'),
            _buildDetailRow('Year', data['assessmentYear'] ?? 'N/A'),
            _buildDetailRow('Amount',
                'TSh ${NumberFormat('#,###').format(data['totalLiability'] ?? 0)}'),
          ],
        );
      case 'payment':
        return Column(
          children: [
            _buildDetailRow('Control No.', data['controlNumber'] ?? 'N/A'),
            _buildDetailRow('Method', data['paymentMethod'] ?? 'N/A'),
            _buildDetailRow('Amount',
                'TSh ${NumberFormat('#,###').format(data['amount'] ?? 0)}'),
          ],
        );
      case 'tax_rule':
        return Column(
          children: [
            _buildDetailRow('Code', data['ruleCode'] ?? 'N/A'),
            _buildDetailRow('Type', data['ruleType'] ?? 'N/A'),
            _buildDetailRow('Rate', '${data['taxRate'] ?? 0}%'),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    final date =
        data['createdAt'] ?? data['submissionDate'] ?? data['paymentDate'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (date != null)
          Text(
            DateFormat('dd MMM yyyy').format(DateTime.parse(date.toString())),
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade500,
            ),
          ),
        const Icon(
          Icons.arrow_forward_ios,
          size: 12,
          color: Colors.grey,
        ),
      ],
    );
  }
}
