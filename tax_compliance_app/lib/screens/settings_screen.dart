import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/helpers.dart';
import '../utils/constants.dart';
import '../widgets/tanzanian_flag.dart';
import 'login_screen.dart';
import 'subscription_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _autoSyncEnabled = true;
  bool _biometricEnabled = false;
  String _selectedLanguage = 'English';
  String _selectedCurrency = 'TSh';
  String _selectedDateFormat = 'DD/MM/YYYY';

  final List<String> _languages = ['English', 'Swahili', 'French'];
  final List<String> _currencies = ['TSh', 'USD', 'EUR', 'KES'];
  final List<String> _dateFormats = ['DD/MM/YYYY', 'MM/DD/YYYY', 'YYYY/MM/DD'];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _autoSyncEnabled = prefs.getBool('auto_sync_enabled') ?? true;
      _biometricEnabled = prefs.getBool('biometric_enabled') ?? false;
      _selectedLanguage = prefs.getString('language') ?? 'English';
      _selectedCurrency = prefs.getString('currency') ?? 'TSh';
      _selectedDateFormat = prefs.getString('date_format') ?? 'DD/MM/YYYY';
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppColors.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSettings,
            tooltip: 'Refresh Settings',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Tanzanian Flag Header
          _buildTanzanianHeader(),
          const SizedBox(height: 16),

          // Profile Section
          _buildSectionHeader('Profile', Icons.person_outline),
          const SizedBox(height: 8),
          _buildProfileTile(authProvider),

          const SizedBox(height: 16),

          // Appearance Section
          _buildSectionHeader('Appearance', Icons.palette),
          const SizedBox(height: 8),
          _buildThemeTile(themeProvider),
          _buildDivider(),
          _buildLanguageTile(),
          _buildDivider(),
          _buildCurrencyTile(),
          _buildDivider(),
          _buildDateFormatTile(),

          const SizedBox(height: 16),

          // Preferences Section
          _buildSectionHeader('Preferences', Icons.tune),
          const SizedBox(height: 8),
          _buildNotificationTile(),
          _buildDivider(),
          _buildAutoSyncTile(),
          _buildDivider(),
          _buildBiometricTile(),

          const SizedBox(height: 16),

          // Tanzania Specific Section
          _buildSectionHeader('Tanzania Services', Icons.flag),
          const SizedBox(height: 8),
          _buildSubscriptionTile(),
          _buildDivider(),
          _buildMobileMoneyTile(),
          _buildDivider(),
          _buildTaxCalculatorTile(),
          _buildDivider(),
          _buildTRAInfoTile(),

          const SizedBox(height: 16),

          // Support Section
          _buildSectionHeader('Support', Icons.help_outline),
          const SizedBox(height: 8),
          _buildHelpTile(),
          _buildDivider(),
          _buildPrivacyTile(),
          _buildDivider(),
          _buildTermsTile(),
          _buildDivider(),
          _buildFeedbackTile(),

          const SizedBox(height: 16),

          // About Section
          _buildSectionHeader('About', Icons.info_outline),
          const SizedBox(height: 8),
          _buildAboutTile(),
          _buildDivider(),
          _buildVersionTile(),

          const SizedBox(height: 24),

          // Logout Button
          _buildLogoutButton(authProvider),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildTanzanianHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1A73E8),
            Color(0xFF0D47A1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const TanzanianFlag(width: 50, height: 35),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TaxCompliance TZ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Tanzania Revenue Authority',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
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
            child: const Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 14,
                ),
                SizedBox(width: 4),
                Text(
                  'Live',
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

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 18),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTile(AuthProvider authProvider) {
    final userDisplayName = authProvider.user?.email ?? '';
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary,
          child: Text(
            userDisplayName.isNotEmpty ? userDisplayName[0].toUpperCase() : '?',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(userDisplayName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(authProvider.user?.email ?? ''),
            Text(
              'TIN: ${authProvider.user?.tinNumber ?? ''}',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.edit, color: AppColors.primary),
          onPressed: () {
            Navigator.pushNamed(context, '/profile');
          },
        ),
        onTap: () {
          Navigator.pushNamed(context, '/profile');
        },
      ),
    );
  }

  Widget _buildSubscriptionTile() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: const Icon(Icons.workspace_premium, color: AppColors.primary),
        title: const Text('My Subscription'),
        subtitle: const Text('Manage Free / Premium plan'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const SubscriptionScreen(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildThemeTile(ThemeProvider themeProvider) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: const Icon(Icons.dark_mode, color: AppColors.primary),
        title: const Text('Dark Mode'),
        subtitle: const Text('Switch between light and dark theme'),
        trailing: Switch(
          value: themeProvider.isDarkMode,
          onChanged: (_) => themeProvider.toggleTheme(),
          activeThumbColor: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildLanguageTile() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: const Icon(Icons.language, color: AppColors.primary),
        title: const Text('Language'),
        subtitle: Text('Current: $_selectedLanguage'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          _showSelectionDialog(
            title: 'Select Language',
            items: _languages,
            selected: _selectedLanguage,
            onSelected: (value) {
              setState(() {
                _selectedLanguage = value;
                _saveSetting('language', value);
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildCurrencyTile() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: const Icon(Icons.attach_money, color: AppColors.primary),
        title: const Text('Currency'),
        subtitle: Text('Current: $_selectedCurrency'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          _showSelectionDialog(
            title: 'Select Currency',
            items: _currencies,
            selected: _selectedCurrency,
            onSelected: (value) {
              setState(() {
                _selectedCurrency = value;
                _saveSetting('currency', value);
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildDateFormatTile() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: const Icon(Icons.calendar_today, color: AppColors.primary),
        title: const Text('Date Format'),
        subtitle: Text('Current: $_selectedDateFormat'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          _showSelectionDialog(
            title: 'Select Date Format',
            items: _dateFormats,
            selected: _selectedDateFormat,
            onSelected: (value) {
              setState(() {
                _selectedDateFormat = value;
                _saveSetting('date_format', value);
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildNotificationTile() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: const Icon(Icons.notifications, color: AppColors.primary),
        title: const Text('Push Notifications'),
        subtitle: const Text('Receive tax reminders and updates'),
        trailing: Switch(
          value: _notificationsEnabled,
          onChanged: (value) {
            setState(() {
              _notificationsEnabled = value;
              _saveSetting('notifications_enabled', value);
            });
          },
          activeThumbColor: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildAutoSyncTile() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: const Icon(Icons.sync, color: AppColors.primary),
        title: const Text('Auto Sync'),
        subtitle: const Text('Automatically sync tax data'),
        trailing: Switch(
          value: _autoSyncEnabled,
          onChanged: (value) {
            setState(() {
              _autoSyncEnabled = value;
              _saveSetting('auto_sync_enabled', value);
            });
          },
          activeThumbColor: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildBiometricTile() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: const Icon(Icons.fingerprint, color: AppColors.primary),
        title: const Text('Biometric Login'),
        subtitle: const Text('Use fingerprint or face ID'),
        trailing: Switch(
          value: _biometricEnabled,
          onChanged: (value) {
            setState(() {
              _biometricEnabled = value;
              _saveSetting('biometric_enabled', value);
            });
          },
          activeThumbColor: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildMobileMoneyTile() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: const Icon(Icons.phone_android, color: AppColors.primary),
        title: const Text('Mobile Money Settings'),
        subtitle: const Text('M-Pesa, Tigo Pesa, Airtel Money'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          _showMobileMoneyDialog();
        },
      ),
    );
  }

  Widget _buildTaxCalculatorTile() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: const Icon(Icons.calculate, color: AppColors.primary),
        title: const Text('Tax Calculator'),
        subtitle: const Text('Calculate PAYE, VAT, SDL, RDL'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          _showTaxCalculatorDialog();
        },
      ),
    );
  }

  Widget _buildTRAInfoTile() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: const Icon(Icons.business, color: AppColors.primary),
        title: const Text('TRA Offices'),
        subtitle: const Text('Find TRA offices near you'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          _showTRAOfficesDialog();
        },
      ),
    );
  }

  Widget _buildHelpTile() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: const Icon(Icons.help_outline, color: AppColors.primary),
        title: const Text('Help & Support'),
        subtitle: const Text('Get help with using the app'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          _showHelpDialog();
        },
      ),
    );
  }

  Widget _buildPrivacyTile() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading:
            const Icon(Icons.privacy_tip_outlined, color: AppColors.primary),
        title: const Text('Privacy Policy'),
        subtitle: const Text('Read our privacy policy'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          _showPrivacyDialog();
        },
      ),
    );
  }

  Widget _buildTermsTile() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading:
            const Icon(Icons.description_outlined, color: AppColors.primary),
        title: const Text('Terms & Conditions'),
        subtitle: const Text('Read terms and conditions'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          _showTermsDialog();
        },
      ),
    );
  }

  Widget _buildFeedbackTile() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: const Icon(Icons.feedback_outlined, color: AppColors.primary),
        title: const Text('Send Feedback'),
        subtitle: const Text('Help us improve the app'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          _showFeedbackDialog();
        },
      ),
    );
  }

  Widget _buildAboutTile() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: const Icon(Icons.info_outline, color: AppColors.primary),
        title: const Text('About'),
        subtitle: const Text('TaxCompliance TZ App'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          _showAboutDialog();
        },
      ),
    );
  }

  Widget _buildVersionTile() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: const ListTile(
        leading: Icon(Icons.code, color: AppColors.primary),
        title: Text('Version'),
        subtitle: Text('1.0.0'),
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Divider(height: 1),
    );
  }

  Widget _buildLogoutButton(AuthProvider authProvider) {
    return SizedBox(
      height: 50,
      child: ElevatedButton.icon(
        onPressed: () async {
          final confirm = await Helpers.showConfirmDialog(
            context,
            title: 'Logout',
            message: 'Are you sure you want to logout?',
            confirmText: 'Logout',
          );
          if (confirm == true) {
            await authProvider.logout();
            if (!mounted) return;
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (_) => false,
            );
          }
        },
        icon: const Icon(Icons.logout),
        label: const Text('Logout'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade700,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // Dialog Methods

  void _showSelectionDialog({
    required String title,
    required List<String> items,
    required String selected,
    required Function(String) onSelected,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: items.map((item) {
            return ListTile(
              title: Text(item),
              leading: Icon(
                item == selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: item == selected ? AppColors.primary : Colors.grey,
              ),
              onTap: () {
                Navigator.pop(context);
                onSelected(item);
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showMobileMoneyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mobile Money Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildProviderTile('M-Pesa', 'Vodacom', Colors.green),
            _buildProviderTile('Tigo Pesa', 'Tigo', Colors.blue),
            _buildProviderTile('Airtel Money', 'Airtel', Colors.red),
            _buildProviderTile('Halopesa', 'Halotel', Colors.teal),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderTile(String name, String network, Color color) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.2),
        child: Icon(Icons.phone_android, color: color),
      ),
      title: Text(name),
      subtitle: Text(network),
      trailing: Switch(
        value: true,
        onChanged: (_) {},
        activeThumbColor: AppColors.primary,
      ),
    );
  }

  void _showTaxCalculatorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tax Calculator'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTaxCalcRow('PAYE Rate', '8% - 35%'),
              _buildTaxCalcRow('VAT Rate', '18%'),
              _buildTaxCalcRow('Skills Levy', '5%'),
              _buildTaxCalcRow('Railway Levy', '5%'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Use the "File Return" feature to calculate your exact tax',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildTaxCalcRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  void _showTRAOfficesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('TRA Offices'),
        content: const SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.location_on, color: Colors.red),
                title: Text('Dar es Salaam'),
                subtitle: Text('TRA Headquarters, Kivukoni'),
              ),
              ListTile(
                leading: Icon(Icons.location_on, color: Colors.blue),
                title: Text('Arusha'),
                subtitle: Text('TRA Office, Clock Tower'),
              ),
              ListTile(
                leading: Icon(Icons.location_on, color: Colors.green),
                title: Text('Mwanza'),
                subtitle: Text('TRA Office, Posta Area'),
              ),
              ListTile(
                leading: Icon(Icons.location_on, color: Colors.orange),
                title: Text('Mbeya'),
                subtitle: Text('TRA Office, Uhindini'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: const SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: Icon(Icons.phone, color: AppColors.primary),
                title: Text('Call Support'),
                subtitle: Text('+255 22 123 4567'),
              ),
              ListTile(
                leading: Icon(Icons.email, color: AppColors.primary),
                title: Text('Email Support'),
                subtitle: Text('support@taxcompliance.co.tz'),
              ),
              ListTile(
                leading: Icon(Icons.chat, color: AppColors.primary),
                title: Text('Live Chat'),
                subtitle: Text('Available 8am - 5pm'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SizedBox(
          width: double.maxFinite,
          child: Text(
            'Your data is protected under the Tanzania Personal Data Protection Act. '
            'We collect only necessary information for tax compliance purposes and '
            'do not share your data with third parties without your consent.',
            style: TextStyle(height: 1.5),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms & Conditions'),
        content: const SizedBox(
          width: double.maxFinite,
          child: Text(
            'By using this app, you agree to comply with the Tanzania Revenue Authority '
            'regulations. You are responsible for the accuracy of the information provided. '
            'The app is for informational purposes and does not substitute official TRA advice.',
            style: TextStyle(height: 1.5),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showFeedbackDialog() {
    final feedbackController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Feedback'),
        content: TextField(
          controller: feedbackController,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Please share your feedback...',
            border: OutlineInputBorder(),
          ),
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
                  context, 'Thank you for your feedback!');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About TaxCompliance TZ'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.request_quote, size: 60, color: AppColors.primary),
            SizedBox(height: 16),
            Text(
              'TaxCompliance TZ',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Simplified Tax Filing for Tanzanians',
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 16),
            Text(
              'Version 1.0.0\n'
              '© 2024 TaxCompliance TZ\n'
              'Made with ❤️ in Tanzania',
              textAlign: TextAlign.center,
              style: TextStyle(height: 1.5),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TanzanianFlag(width: 40, height: 25),
                SizedBox(width: 8),
                Text('🇹🇿'),
              ],
            ),
          ],
        ),
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
