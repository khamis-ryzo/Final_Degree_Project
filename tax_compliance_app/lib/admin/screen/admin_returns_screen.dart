import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/tax_return.dart';
import '../providers/admin_provider.dart';

class AdminReturnsScreen extends StatelessWidget {
  const AdminReturnsScreen({super.key});

  static const List<String> _statuses = [
    'DRAFT',
    'SUBMITTED',
    'PROCESSING',
    'ASSESSED',
    'COMPLETED',
    'REJECTED',
  ];

  @override
  Widget build(BuildContext context) {
    final adminProvider = Provider.of<AdminProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        elevation: 0,
        title: Text(
          'Tax Returns',
          style: TextStyle(color: Colors.grey.shade900),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilters(context, adminProvider),
          ),
          if (adminProvider.searchQuery.isNotEmpty ||
              adminProvider.selectedStatus != 'All' ||
              adminProvider.selectedYear != 'All')
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: adminProvider.clearFilters,
              tooltip: 'Clear filters',
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by Filing ID or TIN',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: adminProvider.setSearchQuery,
            ),
          ),
          Expanded(
            child: adminProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : adminProvider.allReturns.isEmpty
                    ? const Center(child: Text('No returns found'))
                    : RefreshIndicator(
                        onRefresh: adminProvider.loadAdminData,
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          itemCount: adminProvider.allReturns.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final taxReturn = adminProvider.allReturns[index];
                            return _ReturnCard(taxReturn: taxReturn);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  void _showFilters(BuildContext context, AdminProvider provider) {
    showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Filter Returns'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: provider.selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                  ),
                  items: ['All', ..._statuses]
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      provider.setStatusFilter(value);
                      Navigator.pop(context);
                    }
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: provider.selectedYear,
                  decoration: const InputDecoration(
                    labelText: 'Assessment Year',
                    border: OutlineInputBorder(),
                  ),
                  items: ['All', '2024/2025', '2023/2024', '2022/2023']
                      .map((y) => DropdownMenuItem(value: y, child: Text(y)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      provider.setYearFilter(value);
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ReturnCard extends StatelessWidget {
  final TaxReturn taxReturn;

  const _ReturnCard({required this.taxReturn});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AdminProvider>(context, listen: false);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: taxReturn.statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  taxReturn.statusDisplayName,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: taxReturn.statusColor,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                taxReturn.filingId,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.badge_outlined,
                  size: 16, color: Colors.grey.shade500),
              const SizedBox(width: 8),
              Text(
                'TIN: ${taxReturn.tinNumber}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.calendar_today_outlined,
                  size: 16, color: Colors.grey.shade500),
              const SizedBox(width: 8),
              Text(
                'Year: ${taxReturn.assessmentYear}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.payments_outlined,
                  size: 16, color: Colors.grey.shade500),
              const SizedBox(width: 8),
              Text(
                'Liability: ${taxReturn.formattedTotalLiability}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          if (taxReturn.submissionDate != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.event_note_outlined,
                    size: 16, color: Colors.grey.shade500),
                const SizedBox(width: 8),
                Text(
                  'Submitted: ${DateFormat('dd MMM yyyy').format(taxReturn.submissionDate!)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => _showStatusDialog(context, provider),
                child: const Text('Update Status'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showStatusDialog(
      BuildContext context, AdminProvider provider) async {
    final selected = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Update Return Status'),
        children: [
          for (final status in AdminReturnsScreen._statuses)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, status),
              child: Text(
                status
                    .split('_')
                    .map((w) => w[0] + w.substring(1).toLowerCase())
                    .join(' '),
              ),
            ),
        ],
      ),
    );

    if (selected != null && taxReturn.id != null) {
      await provider.updateReturnStatus(taxReturn.id!, selected);
    }
  }
}
