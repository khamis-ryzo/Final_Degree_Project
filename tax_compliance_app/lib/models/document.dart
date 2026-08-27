import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Document {
  final String id;
  final String fileName;
  final String filePath;
  final String fileType;
  final double fileSize;
  final String documentType;
  final String? description;
  final DateTime uploadDate;
  final String taxReturnId;
  final String userId;
  final String status; // PENDING, VERIFIED, REJECTED
  final String? verificationNotes;
  final String? uploadedBy;
  final Map<String, dynamic>? metadata;

  Document({
    required this.id,
    required this.fileName,
    required this.filePath,
    required this.fileType,
    required this.fileSize,
    required this.documentType,
    this.description,
    required this.uploadDate,
    required this.taxReturnId,
    required this.userId,
    this.status = 'PENDING',
    this.verificationNotes,
    this.uploadedBy,
    this.metadata,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      fileName: json['fileName'] ?? '',
      filePath: json['filePath'] ?? '',
      fileType: json['fileType'] ?? '',
      fileSize: (json['fileSize'] ?? 0).toDouble(),
      documentType: json['documentType'] ?? '',
      description: json['description'],
      uploadDate: DateTime.parse(
          json['uploadDate'] ?? DateTime.now().toIso8601String()),
      taxReturnId: json['taxReturnId'] ?? '',
      userId: json['userId'] ?? '',
      status: json['status'] ?? 'PENDING',
      verificationNotes: json['verificationNotes'],
      uploadedBy: json['uploadedBy'],
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fileName': fileName,
      'filePath': filePath,
      'fileType': fileType,
      'fileSize': fileSize,
      'documentType': documentType,
      'description': description,
      'uploadDate': uploadDate.toIso8601String(),
      'taxReturnId': taxReturnId,
      'userId': userId,
      'status': status,
      'verificationNotes': verificationNotes,
      'uploadedBy': uploadedBy,
      'metadata': metadata,
    };
  }

  String get formattedFileSize {
    if (fileSize < 1024) {
      return '${fileSize.toStringAsFixed(0)} B';
    }
    if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    }
    if (fileSize < 1024 * 1024 * 1024) {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(fileSize / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  String get formattedUploadDate {
    return DateFormat('dd MMM yyyy, hh:mm a').format(uploadDate);
  }

  IconData get fileIcon {
    switch (fileType.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'zip':
      case 'rar':
        return Icons.folder_zip;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color get statusColor {
    switch (status) {
      case 'VERIFIED':
        return Colors.green;
      case 'REJECTED':
        return Colors.red;
      case 'PENDING':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String get statusDisplay {
    switch (status) {
      case 'VERIFIED':
        return 'Verified';
      case 'REJECTED':
        return 'Rejected';
      case 'PENDING':
        return 'Pending Verification';
      default:
        return 'Unknown';
    }
  }
}

// Document Type Enum
enum DocumentType {
  income('Income'),
  businessRegistration('Business Registration'),
  taxClearance('Tax Clearance'),
  passportPhoto('Passport Photo'),
  tinCertificate('TIN Certificate'),
  payslip('Payslip'),
  bankStatement('Bank Statement'),
  rentalAgreement('Rental Agreement'),
  invoice('Invoice'),
  receipt('Receipt'),
  other('Other');

  final String displayName;
  const DocumentType(this.displayName);

  static DocumentType fromString(String value) {
    return DocumentType.values.firstWhere(
      (e) => e.toString().split('.').last == value,
      orElse: () => DocumentType.other,
    );
  }

  static List<String> get allValues =>
      DocumentType.values.map((e) => e.toString().split('.').last).toList();

  static List<Map<String, String>> get dropdownItems => DocumentType.values
      .map((e) => {
            'value': e.toString().split('.').last,
            'label': e.displayName,
          })
      .toList();
}
