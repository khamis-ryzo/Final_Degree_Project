import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class Helpers {
  // Show snackbar
  static void showSnackBar(
    BuildContext context,
    String message, {
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor ?? Colors.green,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  static void showErrorSnackBar(BuildContext context, String message) {
    showSnackBar(context, message, backgroundColor: Colors.red);
  }

  static void showSuccessSnackBar(BuildContext context, String message) {
    showSnackBar(context, message, backgroundColor: Colors.green);
  }

  static void showInfoSnackBar(BuildContext context, String message) {
    showSnackBar(context, message, backgroundColor: Colors.blue);
  }

  static void showWarningSnackBar(BuildContext context, String message) {
    showSnackBar(context, message, backgroundColor: Colors.orange);
  }

  // Format Tanzanian Shillings
  static String formatTSh(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'sw_TZ',
      symbol: 'TSh ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  static String formatTShWithDecimals(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'sw_TZ',
      symbol: 'TSh ',
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  // Format Tanzanian mobile number
  static String formatMobileNumber(String phone) {
    String cleaned = phone.replaceAll(RegExp(r'\D'), '');

    if (cleaned.startsWith('255') && cleaned.length == 12) {
      return '+${cleaned.substring(0, 3)} ${cleaned.substring(3, 6)} ${cleaned.substring(6, 9)} ${cleaned.substring(9, 12)}';
    } else if (cleaned.startsWith('0') && cleaned.length == 10) {
      return '+255 ${cleaned.substring(1, 4)} ${cleaned.substring(4, 7)} ${cleaned.substring(7, 10)}';
    } else if (cleaned.length == 9 && cleaned.startsWith('7')) {
      return '+255 ${cleaned.substring(0, 3)} ${cleaned.substring(3, 6)} ${cleaned.substring(6, 9)}';
    } else {
      return phone;
    }
  }

  // Validate Tanzanian mobile number
  static bool isValidTanzanianMobile(String phone) {
    String cleaned = phone.replaceAll(RegExp(r'\D'), '');

    if (cleaned.length == 12 && cleaned.startsWith('255')) {
      return true;
    } else if (cleaned.length == 10 && cleaned.startsWith('0')) {
      return true;
    } else if (cleaned.length == 9 && cleaned.startsWith('7')) {
      return true;
    }
    return false;
  }

  // Copy text to clipboard
  static Future<void> copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }

  // Show confirmation dialog
  static Future<bool?> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    Color? confirmColor,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor ?? Colors.red,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  // Show loading dialog
  static void showLoadingDialog(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Card(
          margin: const EdgeInsets.all(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1A73E8)),
                ),
                if (message != null) ...[
                  const SizedBox(height: 16),
                  Text(message),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  static void hideLoadingDialog(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  // Get current tax year (Tanzania)
  static String getCurrentTaxYear() {
    final now = DateTime.now();
    final year = now.year;
    if (now.month >= 7) {
      return '$year/${(year + 1).toString().substring(2)}';
    } else {
      return '${year - 1}/${year.toString().substring(2)}';
    }
  }

  // Calculate PAYE tax (Tanzania)
  static double calculatePAYE(double monthlyIncome) {
    final annualIncome = monthlyIncome * 12;
    final taxSlabs = [
      [0, 270000, 0.0],
      [270001, 520000, 0.08],
      [520001, 760000, 0.20],
      [760001, 1000000, 0.25],
      [1000001, 10000000, 0.30],
      [10000001, double.infinity, 0.35],
    ];

    double totalTax = 0;
    double remainingIncome = annualIncome;

    for (var slab in taxSlabs) {
      final min = slab[0] as double;
      final max = slab[1] as double;
      final rate = slab[2] as double;

      if (remainingIncome > min) {
        final taxable =
            remainingIncome > max ? max - min : remainingIncome - min;
        totalTax += taxable * rate;

        if (remainingIncome > max) {
          remainingIncome -= max - min;
        } else {
          break;
        }
      }
    }

    // Personal relief (TSh 270,000 per year)
    totalTax -= 270000;
    if (totalTax < 0) totalTax = 0;

    return totalTax / 12; // Monthly tax
  }

  // Calculate VAT (Tanzania)
  static double calculateVAT(double amount, {bool inclusive = true}) {
    if (inclusive) {
      // VAT inclusive
      return amount * (0.18 / 1.18);
    } else {
      // VAT exclusive
      return amount * 0.18;
    }
  }

  // Calculate Skills Development Levy (Tanzania)
  static double calculateSkillsLevy(double amount) {
    return amount * 0.05; // 5%
  }

  // Calculate Railway Development Levy (Tanzania)
  static double calculateRailwayLevy(double amount) {
    return amount * 0.05; // 5%
  }
}
