import 'dart:io';
import 'constants.dart';

class FileValidator {
  /// Validates a file.
  ///
  /// [fileSizeBytes] should be supplied when the size cannot be read from
  /// disk (e.g. on web, where only the raw bytes are available).
  /// [fileName] should be supplied when the file has no real filesystem path
  /// (e.g. web uploads) so the extension can still be validated.
  static FileValidationResult validateFile(
    File file, {
    int? fileSizeBytes,
    String? fileName,
  }) {
    final errors = <String>[];
    final warnings = <String>[];

    // Get file info
    final resolvedName = fileName ?? file.path.split('/').last;
    final extension = resolvedName.split('.').last.toLowerCase();
    int fileSize = fileSizeBytes ?? 0;

    if (fileSizeBytes == null) {
      try {
        fileSize = file.lengthSync();
      } catch (e) {
        warnings.add('File size check not available');
      }
    }

    // Check file extension
    if (!AppConstants.allowedFileExtensions.contains(extension)) {
      errors.add(
          'File type .$extension is not allowed. Allowed types: ${AppConstants.allowedFileExtensions.join(', ')}');
    }

    // Check file size
    if (fileSize > AppConstants.maxFileSizeBytes) {
      errors.add(
          'File size exceeds ${AppConstants.maxFileSizeMB.toStringAsFixed(0)}MB limit');
    }

    // Check file name length
    if (resolvedName.length > 100) {
      errors.add('File name is too long (maximum 100 characters)');
    }

    return FileValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
      fileSize: fileSize,
      fileExtension: extension,
      fileName: resolvedName,
    );
  }
}

class FileValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;
  final int fileSize;
  final String fileExtension;
  final String fileName;

  FileValidationResult({
    required this.isValid,
    required this.errors,
    required this.warnings,
    required this.fileSize,
    required this.fileExtension,
    required this.fileName,
  });

  String get fileSizeFormatted {
    if (fileSize < 1024) return '${fileSize}B';
    if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)}KB';
    }
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}
