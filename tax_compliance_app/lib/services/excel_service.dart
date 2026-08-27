import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_file/open_file.dart';
import 'package:intl/intl.dart';

class ExcelService {
  // ==================== EXPORT FUNCTIONS ====================

  static Future<String> exportTaxReturns(
      List<Map<String, dynamic>> taxReturns) async {
    try {
      final excel = Excel.createExcel();

      final summarySheet = excel['Summary'];
      final returnsSheet = excel['Tax Returns'];
      final statsSheet = excel['Statistics'];

      // ===== SUMMARY SHEET =====
      summarySheet.updateCell(
          CellIndex.indexByString('A1'), 'TAX RETURNS REPORT',
          cellStyle: CellStyle(
              fontSize: 16,
              fontColorHex: 'FFFFFFFF',
              backgroundColorHex: 'FF2E7D32'));

      summarySheet.updateCell(CellIndex.indexByString('A3'), 'Generated On:');
      summarySheet.updateCell(CellIndex.indexByString('B3'),
          DateFormat('dd MMM yyyy HH:mm:ss').format(DateTime.now()));

      final totalReturns = taxReturns.length;
      final totalTax = taxReturns.fold(
          0.0, (sum, item) => sum + (item['totalLiability'] ?? 0));
      final totalPaid =
          taxReturns.fold(0.0, (sum, item) => sum + (item['taxPaid'] ?? 0));
      final totalRefund = taxReturns.fold(
          0.0, (sum, item) => sum + (item['refundAmount'] ?? 0));

      summarySheet.updateCell(CellIndex.indexByString('A5'), 'Total Returns:');
      summarySheet.updateCell(CellIndex.indexByString('B5'), totalReturns);
      summarySheet.updateCell(
          CellIndex.indexByString('A6'), 'Total Tax Liability:');
      summarySheet.updateCell(CellIndex.indexByString('B6'), totalTax);
      summarySheet.updateCell(CellIndex.indexByString('A7'), 'Total Tax Paid:');
      summarySheet.updateCell(CellIndex.indexByString('B7'), totalPaid);
      summarySheet.updateCell(CellIndex.indexByString('A8'), 'Total Refund:');
      summarySheet.updateCell(CellIndex.indexByString('B8'), totalRefund);

      // ===== TAX RETURNS SHEET =====
      final headers = [
        'Filing ID',
        'TIN Number',
        'Assessment Year',
        'Filing Type',
        'Total Income',
        'Deductions',
        'Taxable Income',
        'Tax Payable',
        'Skills Levy',
        'Railway Levy',
        'Total Liability',
        'Tax Paid',
        'Refund',
        'Status',
        'Submission Date',
        'Acknowledgment'
      ];

      for (int i = 0; i < headers.length; i++) {
        final col = String.fromCharCode(65 + i);
        returnsSheet.updateCell(CellIndex.indexByString('$col${1}'), headers[i],
            cellStyle: CellStyle(
                fontColorHex: 'FFFFFFFF', backgroundColorHex: 'FF2E7D32'));
        returnsSheet.setColWidth(i, 18);
      }

      for (int row = 0; row < taxReturns.length; row++) {
        final data = taxReturns[row];
        final rowNum = row + 2;

        returnsSheet.updateCell(
            CellIndex.indexByString('A$rowNum'), data['filingId'] ?? '');
        returnsSheet.updateCell(
            CellIndex.indexByString('B$rowNum'), data['tinNumber'] ?? '');
        returnsSheet.updateCell(
            CellIndex.indexByString('C$rowNum'), data['assessmentYear'] ?? '');
        returnsSheet.updateCell(
            CellIndex.indexByString('D$rowNum'), data['filingType'] ?? '');
        returnsSheet.updateCell(
            CellIndex.indexByString('E$rowNum'), data['totalIncome'] ?? 0);
        returnsSheet.updateCell(
            CellIndex.indexByString('F$rowNum'), data['deductions'] ?? 0);
        returnsSheet.updateCell(
            CellIndex.indexByString('G$rowNum'), data['taxableIncome'] ?? 0);
        returnsSheet.updateCell(
            CellIndex.indexByString('H$rowNum'), data['taxPayable'] ?? 0);
        returnsSheet.updateCell(
            CellIndex.indexByString('I$rowNum'), data['skillsLevy'] ?? 0);
        returnsSheet.updateCell(
            CellIndex.indexByString('J$rowNum'), data['railwayLevy'] ?? 0);
        returnsSheet.updateCell(
            CellIndex.indexByString('K$rowNum'), data['totalLiability'] ?? 0);
        returnsSheet.updateCell(
            CellIndex.indexByString('L$rowNum'), data['taxPaid'] ?? 0);
        returnsSheet.updateCell(
            CellIndex.indexByString('M$rowNum'), data['refundAmount'] ?? 0);
        returnsSheet.updateCell(
            CellIndex.indexByString('N$rowNum'), data['status'] ?? '');
        returnsSheet.updateCell(
            CellIndex.indexByString('O$rowNum'), data['submissionDate'] ?? '');
        returnsSheet.updateCell(CellIndex.indexByString('P$rowNum'),
            data['acknowledgmentNumber'] ?? '');

        final status = data['status']?.toString().toUpperCase() ?? '';
        Color cellColor;
        if (status == 'COMPLETED') {
          cellColor = Colors.green;
        } else if (status == 'SUBMITTED' || status == 'PROCESSING') {
          cellColor = Colors.orange;
        } else if (status == 'REJECTED') {
          cellColor = Colors.red;
        } else {
          cellColor = Colors.grey;
        }

        returnsSheet.updateCell(
            CellIndex.indexByString('N$rowNum'), data['status'] ?? '',
            cellStyle: CellStyle(
                fontColorHex: 'FFFFFFFF',
                backgroundColorHex:
                    'FF${cellColor.toARGB32().toRadixString(16).substring(2)}'));
      }

      // ===== STATISTICS SHEET =====
      statsSheet.updateCell(
          CellIndex.indexByString('A1'), 'Tax Returns Statistics',
          cellStyle: CellStyle(
              fontSize: 14,
              fontColorHex: 'FFFFFFFF',
              backgroundColorHex: 'FF2E7D32'));

      final statusCount = <String, int>{};
      for (var item in taxReturns) {
        final status = item['status']?.toString().toUpperCase() ?? 'UNKNOWN';
        statusCount[status] = (statusCount[status] ?? 0) + 1;
      }

      int rowIndex = 3;
      statsSheet.updateCell(CellIndex.indexByString('A$rowIndex'), 'Status');
      statsSheet.updateCell(CellIndex.indexByString('B$rowIndex'), 'Count');
      statsSheet.updateCell(
          CellIndex.indexByString('C$rowIndex'), 'Percentage');
      rowIndex++;

      statusCount.forEach((status, count) {
        final percentage = (count / totalReturns * 100).toStringAsFixed(1);
        statsSheet.updateCell(CellIndex.indexByString('A$rowIndex'), status);
        statsSheet.updateCell(CellIndex.indexByString('B$rowIndex'), count);
        statsSheet.updateCell(
            CellIndex.indexByString('C$rowIndex'), '$percentage%');
        rowIndex++;
      });

      final yearlyData = <String, Map<String, double>>{};
      for (var item in taxReturns) {
        final year = item['assessmentYear']?.toString() ?? 'Unknown';
        yearlyData.putIfAbsent(
            year, () => {'total': 0, 'paid': 0, 'refund': 0});
        yearlyData[year]!['total'] =
            (yearlyData[year]!['total'] ?? 0) + (item['totalLiability'] ?? 0);
        yearlyData[year]!['paid'] =
            (yearlyData[year]!['paid'] ?? 0) + (item['taxPaid'] ?? 0);
        yearlyData[year]!['refund'] =
            (yearlyData[year]!['refund'] ?? 0) + (item['refundAmount'] ?? 0);
      }

      rowIndex += 2;
      statsSheet.updateCell(
          CellIndex.indexByString('A$rowIndex'), 'Yearly Summary',
          cellStyle: CellStyle(
              fontSize: 12,
              fontColorHex: 'FFFFFFFF',
              backgroundColorHex: 'FF2E7D32'));
      rowIndex++;

      statsSheet.updateCell(CellIndex.indexByString('A$rowIndex'), 'Year');
      statsSheet.updateCell(CellIndex.indexByString('B$rowIndex'), 'Total Tax');
      statsSheet.updateCell(CellIndex.indexByString('C$rowIndex'), 'Paid');
      statsSheet.updateCell(CellIndex.indexByString('D$rowIndex'), 'Refund');
      rowIndex++;

      yearlyData.forEach((year, data) {
        statsSheet.updateCell(CellIndex.indexByString('A$rowIndex'), year);
        statsSheet.updateCell(
            CellIndex.indexByString('B$rowIndex'), data['total']);
        statsSheet.updateCell(
            CellIndex.indexByString('C$rowIndex'), data['paid']);
        statsSheet.updateCell(
            CellIndex.indexByString('D$rowIndex'), data['refund']);
        rowIndex++;
      });

      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          'Tax_Returns_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx';
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(excel.encode()!);
      return filePath;
    } catch (e) {
      throw Exception('Failed to export: $e');
    }
  }

  // Export Tax Rules to Excel
  static Future<String> exportTaxRules(
      List<Map<String, dynamic>> taxRules) async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel['Tax Rules'];

      final headers = [
        'Rule Code',
        'Rule Name',
        'Rule Type',
        'Min Income',
        'Max Income',
        'Tax Rate (%)',
        'Flat Amount',
        'Percentage (%)',
        'Priority',
        'Applicable From',
        'Applicable To',
        'Is Active'
      ];

      for (int i = 0; i < headers.length; i++) {
        final col = String.fromCharCode(65 + i);
        sheet.updateCell(CellIndex.indexByString('$col${1}'), headers[i],
            cellStyle: CellStyle(
                fontColorHex: 'FFFFFFFF', backgroundColorHex: 'FF2E7D32'));
        sheet.setColWidth(i, 16);
      }

      for (int row = 0; row < taxRules.length; row++) {
        final data = taxRules[row];
        final rowNum = row + 2;

        sheet.updateCell(
            CellIndex.indexByString('A$rowNum'), data['ruleCode'] ?? '');
        sheet.updateCell(
            CellIndex.indexByString('B$rowNum'), data['ruleName'] ?? '');
        sheet.updateCell(
            CellIndex.indexByString('C$rowNum'), data['ruleType'] ?? '');
        sheet.updateCell(
            CellIndex.indexByString('D$rowNum'), data['minIncome'] ?? 0);
        sheet.updateCell(
            CellIndex.indexByString('E$rowNum'), data['maxIncome'] ?? 0);
        sheet.updateCell(
            CellIndex.indexByString('F$rowNum'), data['taxRate'] ?? 0);
        sheet.updateCell(
            CellIndex.indexByString('G$rowNum'), data['flatAmount'] ?? 0);
        sheet.updateCell(
            CellIndex.indexByString('H$rowNum'), data['percentage'] ?? 0);
        sheet.updateCell(
            CellIndex.indexByString('I$rowNum'), data['priority'] ?? 0);
        sheet.updateCell(CellIndex.indexByString('J$rowNum'),
            data['applicableFromYear'] ?? '');
        sheet.updateCell(CellIndex.indexByString('K$rowNum'),
            data['applicableToYear'] ?? '');
        sheet.updateCell(CellIndex.indexByString('L$rowNum'),
            data['isActive'] == true ? 'Yes' : 'No');
      }

      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          'Tax_Rules_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx';
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(excel.encode()!);
      return filePath;
    } catch (e) {
      throw Exception('Failed to export tax rules: $e');
    }
  }

  // Export User Profile to Excel
  static Future<String> exportUserProfile(Map<String, dynamic> userData) async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel['User Profile'];

      final fields = [
        ['Field', 'Value'],
        ['Username', userData['username'] ?? ''],
        ['Full Name', userData['fullName'] ?? ''],
        ['Email', userData['email'] ?? ''],
        ['TIN Number', userData['tinNumber'] ?? ''],
        ['Mobile Number', userData['mobileNumber'] ?? ''],
        ['Taxpayer Type', userData['taxpayerType'] ?? ''],
        ['Business Name', userData['businessName'] ?? ''],
        ['Business Sector', userData['businessSector'] ?? ''],
        ['TRA Region', userData['traRegion'] ?? ''],
        [
          'Is VAT Registered',
          userData['isVatRegistered'] == true ? 'Yes' : 'No'
        ],
        ['Has PAYE', userData['hasPaye'] == true ? 'Yes' : 'No'],
        ['Role', userData['role'] ?? ''],
        [
          'Account Status',
          userData['isActive'] == true ? 'Active' : 'Inactive'
        ],
        ['Created At', userData['createdAt'] ?? ''],
        ['Last Login', userData['lastLogin'] ?? ''],
      ];

      for (int row = 0; row < fields.length; row++) {
        sheet.updateCell(
            CellIndex.indexByString('A${row + 1}'), fields[row][0]);
        sheet.updateCell(
            CellIndex.indexByString('B${row + 1}'), fields[row][1]);

        if (row == 0) {
          sheet.updateCell(
              CellIndex.indexByString('A${row + 1}'), fields[row][0],
              cellStyle: CellStyle(
                  fontColorHex: 'FFFFFFFF', backgroundColorHex: 'FF2E7D32'));
          sheet.updateCell(
              CellIndex.indexByString('B${row + 1}'), fields[row][1],
              cellStyle: CellStyle(
                  fontColorHex: 'FFFFFFFF', backgroundColorHex: 'FF2E7D32'));
        }
      }

      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          'User_Profile_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx';
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(excel.encode()!);
      return filePath;
    } catch (e) {
      throw Exception('Failed to export user profile: $e');
    }
  }

  // ==================== IMPORT FUNCTIONS ====================

  static Future<List<Map<String, dynamic>>> importTaxReturns(
      String filePath) async {
    try {
      final bytes = await File(filePath).readAsBytes();
      final excel = Excel.decodeBytes(bytes);

      Sheet? sheet = excel.tables['Tax Returns'];
      if (sheet == null && excel.tables.isNotEmpty) {
        sheet = excel.tables.values.first;
      }

      if (sheet == null) {
        throw Exception('No data found in the file');
      }

      final data = <Map<String, dynamic>>[];

      final headers = <String>[];
      if (sheet.rows.isNotEmpty) {
        for (int i = 0; i < sheet.rows.first.length; i++) {
          final value = sheet.rows.first[i]?.value;
          headers.add(value?.toString().trim() ?? 'Column$i');
        }
      }

      final fieldMapping = {
        'Filing ID': 'filingId',
        'TIN Number': 'tinNumber',
        'Assessment Year': 'assessmentYear',
        'Filing Type': 'filingType',
        'Total Income': 'totalIncome',
        'Deductions': 'deductions',
        'Taxable Income': 'taxableIncome',
        'Tax Payable': 'taxPayable',
        'Skills Levy': 'skillsLevy',
        'Railway Levy': 'railwayLevy',
        'Total Liability': 'totalLiability',
        'Tax Paid': 'taxPaid',
        'Refund': 'refundAmount',
        'Status': 'status',
        'Submission Date': 'submissionDate',
        'Acknowledgment': 'acknowledgmentNumber'
      };

      for (int rowIndex = 1; rowIndex < sheet.rows.length; rowIndex++) {
        final row = sheet.rows[rowIndex];
        final rowData = <String, dynamic>{};

        for (int colIndex = 0;
            colIndex < row.length && colIndex < headers.length;
            colIndex++) {
          final rawValue = row[colIndex]?.value;
          final header = headers[colIndex];

          String? fieldName = header;
          if (fieldMapping.containsKey(header)) {
            fieldName = fieldMapping[header];
          }

          if (fieldName != null) {
            final value = _parseValue(rawValue, fieldName);
            rowData[fieldName] = value;
          }
        }

        if (rowData.isNotEmpty) {
          data.add(rowData);
        }
      }

      return data;
    } catch (e) {
      throw Exception('Failed to import tax returns: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> importTaxRules(
      String filePath) async {
    try {
      final bytes = await File(filePath).readAsBytes();
      final excel = Excel.decodeBytes(bytes);

      Sheet? sheet = excel.tables['Tax Rules'];
      if (sheet == null && excel.tables.isNotEmpty) {
        sheet = excel.tables.values.first;
      }

      if (sheet == null) {
        throw Exception('No data found in the file');
      }

      final data = <Map<String, dynamic>>[];

      final headers = <String>[];
      if (sheet.rows.isNotEmpty) {
        for (int i = 0; i < sheet.rows.first.length; i++) {
          final value = sheet.rows.first[i]?.value;
          headers.add(value?.toString().trim() ?? 'Column$i');
        }
      }

      final fieldMapping = {
        'Rule Code': 'ruleCode',
        'Rule Name': 'ruleName',
        'Rule Type': 'ruleType',
        'Min Income': 'minIncome',
        'Max Income': 'maxIncome',
        'Tax Rate (%)': 'taxRate',
        'Flat Amount': 'flatAmount',
        'Percentage (%)': 'percentage',
        'Priority': 'priority',
        'Applicable From': 'applicableFromYear',
        'Applicable To': 'applicableToYear',
        'Is Active': 'isActive'
      };

      for (int rowIndex = 1; rowIndex < sheet.rows.length; rowIndex++) {
        final row = sheet.rows[rowIndex];
        final rowData = <String, dynamic>{};

        for (int colIndex = 0;
            colIndex < row.length && colIndex < headers.length;
            colIndex++) {
          final rawValue = row[colIndex]?.value;
          final header = headers[colIndex];

          String? fieldName = header;
          if (fieldMapping.containsKey(header)) {
            fieldName = fieldMapping[header];
          }

          if (fieldName != null) {
            final value = _parseValue(rawValue, fieldName);
            rowData[fieldName] = value;
          }
        }

        if (rowData.isNotEmpty) {
          data.add(rowData);
        }
      }

      return data;
    } catch (e) {
      throw Exception('Failed to import tax rules: $e');
    }
  }

  // ==================== HELPER FUNCTIONS ====================

  static dynamic _parseValue(dynamic rawValue, String fieldName) {
    if (rawValue == null) {
      if (fieldName.contains('Income') ||
          fieldName.contains('Tax') ||
          fieldName.contains('Amount') ||
          fieldName.contains('Levy') ||
          fieldName.contains('Liability') ||
          fieldName.contains('Refund') ||
          fieldName.contains('Paid') ||
          fieldName.contains('Deductions')) {
        return 0.0;
      }
      return '';
    }

    if (fieldName.contains('Income') ||
        fieldName.contains('Tax') ||
        fieldName.contains('Amount') ||
        fieldName.contains('Levy') ||
        fieldName.contains('Liability') ||
        fieldName.contains('Refund') ||
        fieldName.contains('Paid') ||
        fieldName.contains('Deductions') ||
        fieldName.contains('Rate') ||
        fieldName.contains('Priority')) {
      if (rawValue is num) return rawValue.toDouble();
      if (rawValue is String) {
        final cleaned = rawValue.replaceAll(RegExp(r'[^0-9.]'), '');
        return double.tryParse(cleaned) ?? 0.0;
      }
      return 0.0;
    }

    if (fieldName == 'isActive') {
      if (rawValue is bool) return rawValue;
      if (rawValue is String) {
        return rawValue.toLowerCase() == 'yes' ||
            rawValue.toLowerCase() == 'true' ||
            rawValue.toLowerCase() == 'active';
      }
      return false;
    }

    if (fieldName.contains('Year')) {
      if (rawValue is int) return rawValue;
      if (rawValue is String) {
        final year = int.tryParse(rawValue.replaceAll(RegExp(r'[^0-9]'), ''));
        return year ?? 0;
      }
      return 0;
    }

    return rawValue.toString();
  }

  // ==================== SHARE & OPEN FUNCTIONS ====================

  static Future<void> shareExcelFile(String filePath) async {
    await Share.shareXFiles(
      [XFile(filePath)],
      text: 'Tax Compliance Data Export',
      subject: 'Tax Returns Export',
    );
  }

  static Future<void> openExcelFile(String filePath) async {
    await OpenFile.open(filePath);
  }

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

  static Future<void> deleteExcelFile(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  static Future<String> generateTemplate(String templateType) async {
    try {
      final excel = Excel.createExcel();
      final Sheet sheet = excel['Template'];

      if (templateType == 'tax_returns') {
        final headers = [
          'TIN Number',
          'Assessment Year',
          'Filing Type',
          'Employment Income',
          'Business Income',
          'Rental Income',
          'Capital Gains',
          'Other Income',
          'Deductions'
        ];

        for (int i = 0; i < headers.length; i++) {
          final col = String.fromCharCode(65 + i);
          sheet.updateCell(CellIndex.indexByString('$col${1}'), headers[i],
              cellStyle: CellStyle(
                  fontColorHex: 'FFFFFFFF', backgroundColorHex: 'FF2E7D32'));
          sheet.setColWidth(i, 18);
        }

        const sampleData = [
          [
            '1234567890',
            '2024/2025',
            'ORIGINAL',
            '1200000',
            '0',
            '0',
            '0',
            '0',
            '270000'
          ],
          [
            '1234567890',
            '2023/2024',
            'ORIGINAL',
            '1000000',
            '500000',
            '0',
            '0',
            '0',
            '270000'
          ],
        ];

        for (int row = 0; row < sampleData.length; row++) {
          for (int col = 0; col < sampleData[row].length; col++) {
            sheet.updateCell(
                CellIndex.indexByString(
                    '${String.fromCharCode(65 + col)}${row + 2}'),
                sampleData[row][col]);
          }
        }
      } else if (templateType == 'tax_rules') {
        final headers = [
          'Rule Code',
          'Rule Name',
          'Rule Type',
          'Min Income',
          'Max Income',
          'Tax Rate (%)',
          'Flat Amount',
          'Percentage (%)',
          'Applicable From',
          'Applicable To',
          'Priority'
        ];

        for (int i = 0; i < headers.length; i++) {
          final col = String.fromCharCode(65 + i);
          sheet.updateCell(CellIndex.indexByString('$col${1}'), headers[i],
              cellStyle: CellStyle(
                  fontColorHex: 'FFFFFFFF', backgroundColorHex: 'FF2E7D32'));
          sheet.setColWidth(i, 16);
        }

        const sampleData = [
          [
            'PAYE_0',
            'PAYE 0% Slab',
            'PAYE',
            '0',
            '270000',
            '0',
            '',
            '',
            '2024',
            '2025',
            '1'
          ],
          [
            'PAYE_8',
            'PAYE 8% Slab',
            'PAYE',
            '270001',
            '520000',
            '8',
            '',
            '',
            '2024',
            '2025',
            '2'
          ],
        ];

        for (int row = 0; row < sampleData.length; row++) {
          for (int col = 0; col < sampleData[row].length; col++) {
            sheet.updateCell(
                CellIndex.indexByString(
                    '${String.fromCharCode(65 + col)}${row + 2}'),
                sampleData[row][col]);
          }
        }
      }

      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          'Template_${templateType}_${DateFormat('yyyyMMdd').format(DateTime.now())}.xlsx';
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(excel.encode()!);
      return filePath;
    } catch (e) {
      throw Exception('Failed to generate template: $e');
    }
  }
}
