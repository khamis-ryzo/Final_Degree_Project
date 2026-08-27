import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_html/html.dart' as html;
import 'dart:io' as io;
import '../services/api_service.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/user.dart';
import '../providers/tax_provider.dart';
import '../providers/auth_provider.dart';
import '../services/excel_service.dart';
import '../utils/helpers.dart';
import '../utils/constants.dart';
import 'tax_form_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';
import 'tax_rules_screen.dart';
import 'settings_screen.dart';
import 'chat_bot_screen.dart';
import 'document_list_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  String? _selectedTaxReturnId;

  final List<Widget> _pages = [
    const DashboardContent(),
    const HistoryScreen(),
    const TaxFormScreen(),
    const TaxRulesScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final taxProvider = Provider.of<TaxProvider>(context);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final compact = screenWidth < 400;
    final showTinPill = screenWidth >= 460;
    final showNotifications = screenWidth >= 400;

    // Get the most recent tax return for document upload
    if (taxProvider.returns.isNotEmpty) {
      _selectedTaxReturnId = taxProvider.returns.first.filingId;
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TAX COMPLIANCE',
              style: TextStyle(
                fontSize: compact ? 12 : 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            if (!compact)
              const Text(
                'AND FILING ASSISTANCE',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.5,
                ),
              ),
          ],
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        actions: [
          // TIN Display
          if (showTinPill)
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                final user = authProvider.user;
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.verified,
                        color: Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'TIN: ${user?.tinNumber ?? 'N/A'}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          if (showTinPill) const SizedBox(width: 4),
          // Document Upload Button
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: () {
              _navigateToDocumentUpload();
            },
            tooltip: 'Upload Documents',
          ),
          // Chat Bot Button
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChatBotScreen()),
              );
            },
            tooltip: 'Tax Assistant',
          ),
          // Notifications
          if (showNotifications)
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {
                Helpers.showInfoSnackBar(context, 'Notifications coming soon!');
              },
              tooltip: 'Notifications',
            ),
          // Menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'export':
                  _showExportDialog();
                  break;
                case 'settings':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                  break;
                case 'profile':
                  setState(() {
                    _selectedIndex = 4;
                  });
                  break;
                case 'logout':
                  _handleLogout();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.download, size: 20),
                    SizedBox(width: 8),
                    Text('Export Data'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person, size: 20),
                    SizedBox(width: 8),
                    Text('Profile'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings, size: 20),
                    SizedBox(width: 8),
                    Text('Settings'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 20, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Logout', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: Colors.white.withValues(alpha: 0.1),
            height: 1,
          ),
        ),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.note_add_outlined),
            activeIcon: Icon(Icons.note_add),
            label: 'File Return',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.rule_outlined),
            activeIcon: Icon(Icons.rule),
            label: 'Rules',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          setState(() {
            _selectedIndex = 2;
          });
        },
        icon: const Icon(Icons.add),
        label: const Text('File Return'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _navigateToDocumentUpload() {
    if (_selectedTaxReturnId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DocumentListScreen(
            taxReturnId: _selectedTaxReturnId!,
          ),
        ),
      );
    } else {
      Helpers.showInfoSnackBar(
        context,
        'Please file a tax return first before uploading documents.',
      );
    }
  }

  void _showExportDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Export Data',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildExportOption(
                icon: Icons.assignment,
                title: 'Tax Returns',
                subtitle: 'Export all tax returns',
                color: Colors.blue,
                onTap: () async {
                  Navigator.pop(context);
                  await _handleExport('tax_returns');
                },
              ),
              const SizedBox(height: 12),
              _buildExportOption(
                icon: Icons.rule,
                title: 'Tax Rules',
                subtitle: 'Export all tax rules',
                color: Colors.purple,
                onTap: () async {
                  Navigator.pop(context);
                  await _handleExport('tax_rules');
                },
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExportOption({
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

  Future<void> _handleExport(String type) async {
    try {
      String filePath = '';

      switch (type) {
        case 'tax_returns':
          // Download Excel from backend export endpoint
          final bytes = await ApiService()
              .downloadBinary('/export/tax-returns?format=excel&withUser=true');
          final timestamp =
              DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
          final fileName = 'tax_returns_$timestamp.xlsx';

          if (kIsWeb) {
            final blob = html.Blob([bytes]);
            final url = html.Url.createObjectUrlFromBlob(blob);
            final anchor =
                html.document.createElement('a') as html.AnchorElement;
            anchor.href = url;
            anchor.download = fileName;
            anchor.click();
            html.Url.revokeObjectUrl(url);
            filePath = fileName;
          } else {
            final directory = await getApplicationDocumentsDirectory();
            final path = '${directory.path}/$fileName';
            final file = io.File(path);
            await file.writeAsBytes(bytes);
            filePath = path;
          }
          break;

        case 'tax_rules':
          final taxProvider = Provider.of<TaxProvider>(context, listen: false);
          final rules = taxProvider.taxRules.map((r) => r.toJson()).toList();
          filePath = await ExcelService.exportTaxRules(rules);
          break;

        default:
          Helpers.showErrorSnackBar(context, 'Invalid export type');
          return;
      }

      if (mounted) {
        _showExportSuccessDialog(filePath);
      }
    } catch (e) {
      if (mounted) {
        Helpers.showErrorSnackBar(context, 'Export failed: $e');
      }
    }
  }

  void _showExportSuccessDialog(String filePath) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Successful!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 48,
            ),
            const SizedBox(height: 12),
            const Text(
              'File saved successfully!',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'File Size: ${ExcelService.getFileSize(filePath)}',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              await ExcelService.shareExcelFile(filePath);
            },
            icon: const Icon(Icons.share),
            label: const Text('Share'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  void _handleLogout() async {
    final confirm = await Helpers.showConfirmDialog(
      context,
      title: 'Logout',
      message: 'Are you sure you want to logout?',
      confirmText: 'Logout',
    );

    if (confirm == true) {
      if (!mounted) return;
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.logout();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }
}

// ==================== DASHBOARD CONTENT ====================

class DashboardContent extends StatefulWidget {
  const DashboardContent({super.key});

  @override
  State<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadData();
    });
  }

  Future<void> _loadData() async {
    final taxProvider = Provider.of<TaxProvider>(context, listen: false);
    await taxProvider.loadReturns();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final taxProvider = Provider.of<TaxProvider>(context);

    final returns = taxProvider.returns;
    final totalTax = returns.fold(0.0, (sum, r) => sum + r.totalLiability);
    final completedReturns =
        returns.where((r) => r.status == 'COMPLETED').length;
    final pendingReturns = returns.where((r) => r.status == 'DRAFT').length;

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeCard(user),
            const SizedBox(height: 20),
            _buildTINSummaryCard(user),
            const SizedBox(height: 20),
            _buildStatsGrid(totalTax, completedReturns, pendingReturns),
            const SizedBox(height: 20),
            _buildDocumentUploadBanner(),
            const SizedBox(height: 20),
            _buildQuickActions(context),
            const SizedBox(height: 20),
            _buildTaxChart(taxProvider),
            const SizedBox(height: 20),
            _buildRecentReturns(taxProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(User? user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: Colors.white,
            child: Text(
              user?.fullName.isNotEmpty == true
                  ? user!.fullName[0].toUpperCase()
                  : 'U',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, ${user?.fullName ?? 'User'}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.verified,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        'TIN: ${user?.tinNumber ?? 'Not Registered'}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'Active',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTINSummaryCard(User? user) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.credit_card,
              color: Colors.blue,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Taxpayer Identification Number',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.tinNumber ?? 'Not Registered',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    user?.tinNumber != null
                        ? '✓ Verified'
                        : '⚠️ Not Registered',
                    style: TextStyle(
                      fontSize: 10,
                      color: user?.tinNumber != null
                          ? Colors.green
                          : Colors.orange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (user?.tinNumber != null)
            IconButton(
              icon: const Icon(Icons.copy, color: Colors.blue),
              onPressed: () {
                // Copy TIN to clipboard
                Helpers.copyToClipboard(user!.tinNumber);
                Helpers.showSuccessSnackBar(
                    context, 'TIN copied to clipboard!');
              },
              tooltip: 'Copy TIN',
            ),
        ],
      ),
    );
  }

  Widget _buildDocumentUploadBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade700, Colors.blue.shade900],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.upload_file,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Upload Supporting Documents',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Add receipts, certificates, and other documents',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: _navigateToDocumentUpload,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.blue.shade700,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Upload'),
          ),
        ],
      ),
    );
  }

  void _navigateToDocumentUpload() {
    final taxProvider = Provider.of<TaxProvider>(context, listen: false);
    if (taxProvider.returns.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DocumentListScreen(
            taxReturnId: taxProvider.returns.first.filingId,
          ),
        ),
      );
    } else {
      Helpers.showInfoSnackBar(
        context,
        'Please file a tax return first before uploading documents.',
      );
    }
  }

  Widget _buildStatsGrid(
      double totalTax, int completedReturns, int pendingReturns) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    // Use a smaller aspect ratio on small screens so cards are taller
    final childAspect = screenWidth < 400 ? 1.0 : 1.6;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: childAspect,
      children: [
        _buildStatCard(
          'Total Tax',
          'TSh ${NumberFormat('#,###').format(totalTax)}',
          Icons.calculate,
          Colors.red,
          'Total tax liability',
        ),
        _buildStatCard(
          'Returns Filed',
          '$completedReturns',
          Icons.assignment,
          Colors.blue,
          'Completed returns',
        ),
        _buildStatCard(
          'Pending Returns',
          '$pendingReturns',
          Icons.pending,
          Colors.orange,
          'Awaiting filing',
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color, String subtitle) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final compact = screenWidth < 400;

    return Container(
      padding: EdgeInsets.all(compact ? 10 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(compact ? 6 : 8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: compact ? 18 : 20),
          ),
          SizedBox(height: compact ? 6 : 8),
          Flexible(
            fit: FlexFit.loose,
            child: Text(
              value,
              style: TextStyle(
                fontSize: compact ? 16 : 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Flexible(
            fit: FlexFit.loose,
            child: Text(
              title,
              style: TextStyle(
                fontSize: compact ? 11 : 12,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          if (subtitle.isNotEmpty)
            Flexible(
              fit: FlexFit.loose,
              child: Text(
                subtitle,
                style: TextStyle(
                  fontSize: compact ? 9 : 10,
                  color: Colors.grey.shade400,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.note_add,
                label: 'File Return',
                color: AppColors.primary,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TaxFormScreen()),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                icon: Icons.upload_file,
                label: 'Documents',
                color: Colors.blue,
                onTap: _navigateToDocumentUpload,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.history,
                label: 'History',
                color: Colors.purple,
                onTap: () {
                  final dashboardState =
                      context.findAncestorStateOfType<_DashboardScreenState>();
                  if (dashboardState != null) {
                    dashboardState.setState(() {
                      dashboardState._selectedIndex = 1;
                    });
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                icon: Icons.chat,
                label: 'Tax Assistant',
                color: Colors.teal,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ChatBotScreen()),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                icon: Icons.download,
                label: 'Export Data',
                color: Colors.brown,
                onTap: () {
                  // Show export options
                  final dashboardState =
                      context.findAncestorStateOfType<_DashboardScreenState>();
                  if (dashboardState != null) {
                    dashboardState._showExportDialog();
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaxChart(TaxProvider taxProvider) {
    final returns = taxProvider.returns;
    if (returns.isEmpty) {
      return const SizedBox.shrink();
    }

    final Map<String, double> yearlyData = {};
    for (var r in returns) {
      final year = r.assessmentYear;
      yearlyData[year] = (yearlyData[year] ?? 0) + r.totalLiability;
    }

    final entries = yearlyData.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    if (entries.isEmpty) return const SizedBox.shrink();

    final maxValue =
        entries.map((e) => e.value).reduce((a, b) => a > b ? a : b);

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
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tax Trends',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Annual Tax Liability',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxValue * 1.2,
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 60,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            'TSh ${(value / 1000).toStringAsFixed(0)}K',
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < entries.length) {
                            return Text(
                              entries[index].key,
                              style: const TextStyle(fontSize: 10),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey.shade300, width: 0.5),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.shade200,
                        strokeWidth: 0.5,
                      );
                    },
                  ),
                  barGroups: entries.asMap().entries.map((entry) {
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          // `entries.asMap().entries` yields a map entry whose value
                          // is itself the yearly-data map entry. Use that inner value
                          // for the chart height rather than casting the MapEntry.
                          toY: entry.value.value,
                          color: Colors.green,
                          width: 24,
                          borderRadius: BorderRadius.circular(4),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF43A047), Color(0xFF2E7D32)],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentReturns(TaxProvider taxProvider) {
    final returns = taxProvider.returns.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Recent Returns',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            TextButton(
              onPressed: () {
                // Navigate to full history
                final dashboardState =
                    context.findAncestorStateOfType<_DashboardScreenState>();
                if (dashboardState != null) {
                  dashboardState.setState(() {
                    dashboardState._selectedIndex = 1;
                  });
                }
              },
              child: const Text(
                'View All',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (returns.isEmpty)
          Container(
            padding: const EdgeInsets.all(40),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.folder_open,
                  size: 60,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 12),
                Text(
                  'No tax returns filed yet',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    final dashboardState = context
                        .findAncestorStateOfType<_DashboardScreenState>();
                    if (dashboardState != null) {
                      dashboardState.setState(() {
                        dashboardState._selectedIndex = 2;
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('File Your First Return'),
                ),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: returns.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final r = returns[index];
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: r.statusColor,
                    child: Text(
                      r.status[0],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  title: Text(
                    r.filingId,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Row(
                    children: [
                      Text(
                        r.assessmentYear,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade400,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        r.status,
                        style: TextStyle(
                          fontSize: 12,
                          color: r.statusColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'TSh ${NumberFormat('#,###').format(r.totalLiability)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      if (r.submissionDate != null)
                        Text(
                          DateFormat('dd MMM yyyy').format(r.submissionDate!),
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade500,
                          ),
                        ),
                    ],
                  ),
                  onTap: () {
                    // Navigate to return detail
                  },
                ),
              );
            },
          ),
      ],
    );
  }
}
