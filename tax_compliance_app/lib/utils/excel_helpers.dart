import 'dart:io';
import 'package:intl/intl.dart';

class ExcelHelpers {
  // Format currency for Excel
  static String formatCurrency(double amount) {
    return NumberFormat.currency(
      locale: 'sw_TZ',
      symbol: 'TSh ',
      decimalDigits: 2,
    ).format(amount);
  }

  // Format date for Excel
  static String formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  // Format date and time for Excel
  static String formatDateTime(DateTime? date) {
    if (date == null) return '';
    return DateFormat('dd/MM/yyyy HH:mm:ss').format(date);
  }

  // Validate Excel file
  static bool isValidExcelFile(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();
    return extension == 'xlsx' || extension == 'xls';
  }

  // Get file size
  static String getFileSize(String filePath) {
    try {
      final file = File(filePath);
      final size = file.lengthSync();

      if (size < 1024) return '$size B';
      if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
      if (size < 1024 * 1024 * 1024) {
        return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
      }
      return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    } catch (e) {
      return 'Unknown';
    }
  }

  // Clean Excel data (remove empty rows)
  static List<List<dynamic>> cleanExcelData(List<List<dynamic>> data) {
    return data
        .where((row) =>
            row.any((cell) => cell != null && cell.toString().isNotEmpty))
        .toList();
  }

  // Convert Excel data to Map
  static List<Map<String, dynamic>> excelToMap(
    List<List<dynamic>> data,
    List<String> headers,
  ) {
    final result = <Map<String, dynamic>>[];

    for (int i = 1; i < data.length; i++) {
      final row = data[i];
      final map = <String, dynamic>{};

      for (int j = 0; j < headers.length && j < row.length; j++) {
        map[headers[j]] = row[j];
      }

      if (map.isNotEmpty) {
        result.add(map);
      }
    }

    return result;
  }

  // Generate Excel summary statistics
  static Map<String, dynamic> generateExcelSummary(
      List<Map<String, dynamic>> data) {
    if (data.isEmpty) {
      return {
        'total': 0,
        'sum': 0,
        'average': 0,
        'min': 0,
        'max': 0,
        'count': 0,
      };
    }

    final numericFields = [
      'totalIncome',
      'taxPayable',
      'totalLiability',
      'taxPaid',
      'refundAmount'
    ];
    final summary = <String, dynamic>{};

    for (var field in numericFields) {
      if (data.first.containsKey(field)) {
        final values = data.map((row) => (row[field] ?? 0) as num).toList();
        final total = values.fold(0.0, (sum, val) => sum + val.toDouble());

        summary[field] = {
          'sum': total,
          'average': data.isNotEmpty ? total / data.length : 0,
          'min': values.isNotEmpty ? values.reduce((a, b) => a < b ? a : b) : 0,
          'max': values.isNotEmpty ? values.reduce((a, b) => a > b ? a : b) : 0,
          'count': data.length,
        };
      }
    }

    summary['totalRecords'] = data.length;
    return summary;
  }
}
