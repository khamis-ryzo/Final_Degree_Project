import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../models/document.dart';
import '../services/document_service.dart';
import '../utils/constants.dart';
import '../utils/file_validator.dart' as file_validator;
import '../utils/helpers.dart';
import 'custom_button.dart';
import 'custom_textfield.dart';

class DocumentUploadWidget extends StatefulWidget {
  final String taxReturnId;
  final String userId;
  final Function(Document) onDocumentUploaded;

  const DocumentUploadWidget({
    super.key,
    required this.taxReturnId,
    required this.userId,
    required this.onDocumentUploaded,
  });

  @override
  State<DocumentUploadWidget> createState() => _DocumentUploadWidgetState();
}

class _DocumentUploadWidgetState extends State<DocumentUploadWidget> {
  bool _isUploading = false;
  String? _selectedDocumentType;
  final TextEditingController _descriptionController = TextEditingController();
  File? _selectedFile;
  Uint8List? _selectedFileBytes;
  String? _selectedFileName;
  file_validator.FileValidationResult? _validationResult;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      final pickerResult = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: AppConstants.allowedFileExtensions,
      );

      if (!mounted) return;
      if (pickerResult == null) return;
      final pickedFile = pickerResult.files.first;
      // On web FilePicker returns bytes and name; on mobile returns a path
      if (kIsWeb) {
        final bytes = pickedFile.bytes;
        if (bytes == null) return;
        final name = pickedFile.name;
        final validation = file_validator.FileValidator.validateFile(
          File(''),
          fileSizeBytes: bytes.lengthInBytes,
          fileName: name,
        );

        if (!mounted) return;
        setState(() {
          _selectedFileBytes = bytes;
          _selectedFileName = name;
          _validationResult = validation;
        });

        if (!validation.isValid) {
          if (!mounted) return;
          Helpers.showErrorSnackBar(
            context,
            'File validation failed: ${validation.errors.join(', ')}',
          );
        }
      } else if (pickedFile.path != null) {
        final file = File(pickedFile.path!);
        final validation = file_validator.FileValidator.validateFile(file);

        if (!mounted) return;
        setState(() {
          _selectedFile = file;
          _selectedFileBytes = null;
          _selectedFileName = null;
          _validationResult = validation;
        });

        if (!validation.isValid) {
          if (!mounted) return;
          Helpers.showErrorSnackBar(
            context,
            'File validation failed: ${validation.errors.join(', ')}',
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      Helpers.showErrorSnackBar(context, 'Failed to pick file: $e');
    }
  }

  Future<void> _uploadDocument() async {
    if (_selectedFile == null && _selectedFileBytes == null) {
      Helpers.showErrorSnackBar(context, 'Please select a file');
      return;
    }

    if (_selectedDocumentType == null) {
      Helpers.showErrorSnackBar(context, 'Please select document type');
      return;
    }

    if (_validationResult != null && !_validationResult!.isValid) {
      Helpers.showErrorSnackBar(
          context, 'File is invalid. Please select another file.');
      return;
    }

    try {
      final document = await DocumentService.uploadDocument(
        file: _selectedFile,
        documentType: _selectedDocumentType!,
        taxReturnId: widget.taxReturnId,
        userId: widget.userId,
        description: _descriptionController.text.isNotEmpty
            ? _descriptionController.text
            : null,
        metadata: {
          'fileSize': _selectedFile != null
              ? _selectedFile!.lengthSync()
              : (_selectedFileBytes?.lengthInBytes ?? 0),
          'fileExtension': _validationResult?.fileExtension,
        },
        fileBytes: _selectedFileBytes,
        fileName: _selectedFileName,
      );

      if (!mounted) return;
      setState(() {
        _isUploading = false;
        _selectedFile = null;
        _selectedFileBytes = null;
        _selectedFileName = null;
        _selectedDocumentType = null;
        _descriptionController.clear();
        _validationResult = null;
      });

      widget.onDocumentUploaded(document);
      Helpers.showSuccessSnackBar(context, 'Document uploaded successfully!');

      // Show preview
      _showUploadSuccessDialog(document);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isUploading = false;
      });
      Helpers.showErrorSnackBar(context, 'Upload failed: ${e.toString()}');
    }
  }

  void _showUploadSuccessDialog(Document document) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Upload Successful!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('File Name', document.fileName),
            _buildInfoRow('Document Type', document.documentType),
            _buildInfoRow('File Size', document.formattedFileSize),
            _buildInfoRow('Status', document.statusDisplay),
            _buildInfoRow('Uploaded', document.formattedUploadDate),
            if (document.description != null)
              _buildInfoRow('Description', document.description!),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              // Preview document
            },
            icon: const Icon(Icons.visibility),
            label: const Text('Preview'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Row(
              children: [
                Icon(Icons.upload_file, color: AppColors.primary),
                SizedBox(width: 8),
                Text(
                  'Upload Supporting Document',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // File Selection
            InkWell(
              onTap: _isUploading ? null : _pickFile,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _selectedFile != null
                        ? Colors.green
                        : Colors.grey.shade300,
                    style: BorderStyle.solid,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: _selectedFile != null
                      ? Colors.green.withValues(alpha: 0.05)
                      : Colors.grey.shade50,
                ),
                child: _selectedFile != null
                    ? _buildFilePreview()
                    : _buildDropArea(),
              ),
            ),

            const SizedBox(height: 16),

            // Document Type
            DropdownButtonFormField<String>(
              initialValue: _selectedDocumentType,
              decoration: const InputDecoration(
                labelText: 'Document Type',
                prefixIcon: Icon(Icons.label),
              ),
              items: DocumentType.dropdownItems.map((item) {
                return DropdownMenuItem(
                  value: item['value'],
                  child: Text(item['label']!),
                );
              }).toList(),
              onChanged: _isUploading
                  ? null
                  : (value) {
                      setState(() {
                        _selectedDocumentType = value;
                      });
                    },
            ),

            const SizedBox(height: 12),

            // Description
            CustomTextField(
              controller: _descriptionController,
              label: 'Description (Optional)',
              hint: 'Enter a description for this document',
              prefixIcon: Icons.description,
              readOnly: _isUploading,
            ),

            // Validation Results
            if (_validationResult != null &&
                _validationResult!.warnings.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _validationResult!.warnings.map((warning) {
                      return Row(
                        children: [
                          Icon(Icons.warning,
                              color: Colors.orange.shade700, size: 16),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              warning,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange.shade700,
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Upload Button
            CustomButton(
              text: _isUploading ? 'Uploading...' : 'Upload Document',
              onPressed: _isUploading ? null : _uploadDocument,
              isLoading: _isUploading,
              icon: Icons.cloud_upload,
              backgroundColor: AppColors.primary,
            ),

            // Allowed file types
            const SizedBox(height: 8),
            Text(
              'Allowed file types: ${AppConstants.allowedFileExtensions.join(', ')}',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade500,
              ),
            ),
            Text(
              'Maximum file size: ${AppConstants.maxFileSizeMB.toStringAsFixed(0)}MB',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropArea() {
    return Column(
      children: [
        Icon(
          Icons.cloud_upload,
          size: 48,
          color: Colors.grey.shade400,
        ),
        const SizedBox(height: 8),
        Text(
          'Tap to select file',
          style: TextStyle(
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          'or drag and drop',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade400,
          ),
        ),
      ],
    );
  }

  Widget _buildFilePreview() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _validationResult != null
                ? _getFileIcon(_validationResult!.fileExtension)
                : Icons.insert_drive_file,
            color: AppColors.primary,
            size: 32,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _selectedFile!.path.split('/').last,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                _validationResult?.fileSizeFormatted ?? '0KB',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close, color: Colors.red),
          onPressed: () {
            setState(() {
              _selectedFile = null;
              _validationResult = null;
            });
          },
        ),
      ],
    );
  }

  IconData _getFileIcon(String extension) {
    switch (extension.toLowerCase()) {
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
}
