import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';

class AdminReportsScreen extends StatelessWidget {
  const AdminReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final adminProvider = Provider.of<AdminProvider>(context);
    final stats = adminProvider.stats;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        elevation: 0,
        title: Text(
          'Reports',
          style: TextStyle(color: Colors.grey.shade900),
        ),
      ),
      body: stats == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'System Overview',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _ReportCard(
                  title: 'Revenue Report',
                  icon: Icons.attach_money,
                  color: Colors.green,
                  onTap: () => _showSummary(
                    context,
                    'Revenue Report',
                    'Total Revenue: ${stats.formattedRevenue}\n'
                        'Pending Amount: ${stats.formattedPendingAmount}',
                  ),
                ),
                const SizedBox(height: 12),
                _ReportCard(
                  title: 'Tax Returns Report',
                  icon: Icons.assignment,
                  color: Colors.blue,
                  onTap: () => _showSummary(
                    context,
                    'Tax Returns Report',
                    'Total Returns: ${stats.totalReturns}\n'
                        'Completed: ${stats.completedReturns}\n'
                        'Pending: ${stats.pendingReturns}',
                  ),
                ),
                const SizedBox(height: 12),
                _ReportCard(
                  title: 'User Report',
                  icon: Icons.people,
                  color: Colors.orange,
                  onTap: () => _showSummary(
                    context,
                    'User Report',
                    'Total Users: ${stats.totalUsers}\n'
                        'Active Users: ${stats.activeUsers}',
                  ),
                ),
                const SizedBox(height: 12),
                _ReportCard(
                  title: 'Tax Rules Report',
                  icon: Icons.rule,
                  color: Colors.purple,
                  onTap: () => _showSummary(
                    context,
                    'Tax Rules Report',
                    'Total Rules: ${stats.totalTaxRules}\n'
                        'Active Rules: ${stats.activeTaxRules}',
                  ),
                ),
                const SizedBox(height: 12),
                _ReportCard(
                  title: 'Documents Report',
                  icon: Icons.folder_open,
                  color: Colors.teal,
                  onTap: () => _showSummary(
                    context,
                    'Documents Report',
                    'Total Documents: ${stats.totalDocuments}\n'
                        'Pending Documents: ${stats.pendingDocuments}',
                  ),
                ),
              ],
            ),
    );
  }

  void _showSummary(BuildContext context, String title, String body) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ReportCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}
