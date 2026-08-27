import 'package:flutter/material.dart';

class ExcelExportWidget extends StatelessWidget {
  final Function(String) onExport;

  const ExcelExportWidget({super.key, required this.onExport});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Export Data to Excel',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Select the type of data you want to export',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _buildExportOption(
            context,
            icon: Icons.assignment,
            title: 'Tax Returns',
            subtitle: 'Export all tax returns',
            color: Colors.blue,
            onTap: () => onExport('tax_returns'),
          ),
          const SizedBox(height: 12),
          _buildExportOption(
            context,
            icon: Icons.payment,
            title: 'Payments',
            subtitle: 'Export all payment records',
            color: Colors.green,
            onTap: () => onExport('payments'),
          ),
          const SizedBox(height: 12),
          _buildExportOption(
            context,
            icon: Icons.rule,
            title: 'Tax Rules',
            subtitle: 'Export all tax rules',
            color: Colors.purple,
            onTap: () => onExport('tax_rules'),
          ),
          const SizedBox(height: 12),
          _buildExportOption(
            context,
            icon: Icons.person,
            title: 'User Profile',
            subtitle: 'Export your profile data',
            color: Colors.orange,
            onTap: () => onExport('user_profile'),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildExportOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
