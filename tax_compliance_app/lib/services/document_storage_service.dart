import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:intl/intl.dart';

class DocumentStorageService {
  static final DocumentStorageService _instance =
      DocumentStorageService._internal();
  factory DocumentStorageService() => _instance;

  DocumentStorageService._internal();

  // Storage directories
  String? _basePath;

  Future<String> get _storagePath async {
    if (_basePath != null) return _basePath!;

    final directory = await getApplicationDocumentsDirectory();
    final storagePath = path.join(directory.path, 'documents');
    _basePath = storagePath;

    // Create directory if it doesn't exist
    final dir = Directory(storagePath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    return storagePath;
  }

  /// Save document locally
  Future<String> saveDocument({
    required File file,
    required String userId,
    required String taxReturnId,
    required String documentType,
    String? description,
  }) async {
    final storagePath = await _storagePath;

    // Create directory structure: {storagePath}/{userId}/{taxReturnId}/{documentType}/
    final docDir = path.join(storagePath, userId, taxReturnId, documentType);
    final directory = Directory(docDir);

    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    // Generate unique filename
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final extension = path.extension(file.path);
    final baseName = path.basenameWithoutExtension(file.path);
    final newFileName = '$baseName$timestamp$extension';

    // Copy file to storage
    final newFilePath = path.join(docDir, newFileName);
    await file.copy(newFilePath);

    // Return relative path
    return path.join(userId, taxReturnId, documentType, newFileName);
  }

  /// Get document file
  Future<File?> getDocument(String relativePath) async {
    try {
      final storagePath = await _storagePath;
      final fullPath = path.join(storagePath, relativePath);
      final file = File(fullPath);

      if (await file.exists()) {
        return file;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Delete document
  Future<bool> deleteDocument(String relativePath) async {
    try {
      final storagePath = await _storagePath;
      final fullPath = path.join(storagePath, relativePath);
      final file = File(fullPath);

      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Search documents by file name (partial or full)
  Future<List<String>> searchDocumentsByFileName(String searchTerm) async {
    final storagePath = await _storagePath;
    final results = <String>[];

    try {
      final dir = Directory(storagePath);
      await for (var entity in dir.list(recursive: true, followLinks: false)) {
        if (entity is File) {
          final fileName = path.basename(entity.path);
          if (fileName.toLowerCase().contains(searchTerm.toLowerCase())) {
            // Get relative path
            final relativePath = path.relative(entity.path, from: storagePath);
            results.add(relativePath);
          }
        }
      }
    } catch (e) {
      // Handle error
    }

    return results;
  }

  /// Search documents by user name (full or partial)
  Future<List<String>> searchDocumentsByUserName(String userName) async {
    final storagePath = await _storagePath;
    final results = <String>[];

    try {
      final dir = Directory(storagePath);
      await for (var entity in dir.list(recursive: true, followLinks: false)) {
        if (entity is File) {
          final relativePath = path.relative(entity.path, from: storagePath);
          // Check if path contains user ID or name pattern
          // This is a simplified version - in production, you'd have a database
          if (relativePath.toLowerCase().contains(userName.toLowerCase())) {
            results.add(relativePath);
          }
        }
      }
    } catch (e) {
      // Handle error
    }

    return results;
  }

  /// Get all documents for a user
  Future<List<String>> getDocumentsForUser(String userId) async {
    final storagePath = await _storagePath;
    final userDir = path.join(storagePath, userId);
    final results = <String>[];

    try {
      final dir = Directory(userDir);
      if (!await dir.exists()) return results;

      await for (var entity in dir.list(recursive: true, followLinks: false)) {
        if (entity is File) {
          final relativePath = path.relative(entity.path, from: storagePath);
          results.add(relativePath);
        }
      }
    } catch (e) {
      // Handle error
    }

    return results;
  }

  /// Get documents for a tax return
  Future<List<String>> getDocumentsForTaxReturn(
      String userId, String taxReturnId) async {
    final storagePath = await _storagePath;
    final returnDir = path.join(storagePath, userId, taxReturnId);
    final results = <String>[];

    try {
      final dir = Directory(returnDir);
      if (!await dir.exists()) return results;

      await for (var entity in dir.list(recursive: true, followLinks: false)) {
        if (entity is File) {
          final relativePath = path.relative(entity.path, from: storagePath);
          results.add(relativePath);
        }
      }
    } catch (e) {
      // Handle error
    }

    return results;
  }

  /// Get file size display
  String getFileSizeDisplay(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Get file extension
  String getFileExtension(String fileName) {
    final ext = path.extension(fileName);
    return ext.isNotEmpty ? ext.substring(1).toLowerCase() : '';
  }

  /// Check if file is allowed
  bool isAllowedFileType(String fileName) {
    final allowedExtensions = [
      'pdf',
      'jpg',
      'jpeg',
      'png',
      'doc',
      'docx',
      'xls',
      'xlsx'
    ];
    final extension = getFileExtension(fileName);
    return allowedExtensions.contains(extension);
  }

  /// Get file icon based on type
  IconData getFileIcon(String fileName) {
    final extension = getFileExtension(fileName);
    switch (extension) {
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
      default:
        return Icons.insert_drive_file;
    }
  }

  /// Get file color based on type
  Color getFileColor(String fileName) {
    final extension = getFileExtension(fileName);
    switch (extension) {
      case 'pdf':
        return Colors.red;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Colors.purple;
      case 'doc':
      case 'docx':
        return Colors.blue;
      case 'xls':
      case 'xlsx':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  /// Clean up temporary files
  Future<void> cleanupTempFiles() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final tempPath = tempDir.path;
      final dir = Directory(tempPath);

      if (await dir.exists()) {
        await for (var entity in dir.list()) {
          if (entity is File) {
            // Delete files older than 24 hours
            final stat = await entity.stat();
            final age = DateTime.now().difference(stat.modified);
            if (age.inHours > 24) {
              await entity.delete();
            }
          }
        }
      }
    } catch (e) {
      // Handle error
    }
  }
}
