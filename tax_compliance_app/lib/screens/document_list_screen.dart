import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../models/document.dart';
import '../services/document_service.dart';
import '../widgets/document_card.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';
import '../utils/helpers.dart';
import '../utils/constants.dart';
import '../providers/auth_provider.dart';

class DocumentListScreen extends StatefulWidget {
  final String taxReturnId;

  const DocumentListScreen({super.key, required this.taxReturnId});

  @override
  State<DocumentListScreen> createState() => _DocumentListScreenState();
}

class _DocumentListScreenState extends State<DocumentListScreen> {
  List<Document> _documents = [];
  bool _isLoading = true;
  bool _isUploading = false;
  String? _errorMessage;
  bool _isSearching = false;
  List<Document> _filteredDocuments = [];

  // Upload state
  File? _selectedFile;
  Uint8List? _selectedFileBytes;
  String? _selectedFileName;
  String? _selectedDocumentType;
  final TextEditingController _descriptionController = TextEditingController();

  final List<Map<String, String>> _documentTypes = [
    {'value': 'income', 'label': 'Income Proof'},
    {'value': 'businessRegistration', 'label': 'Business Registration'},
    {'value': 'taxClearance', 'label': 'Tax Clearance Certificate'},
    {'value': 'tinCertificate', 'label': 'TIN Certificate'},
    {'value': 'payslip', 'label': 'Payslip'},
    {'value': 'bankStatement', 'label': 'Bank Statement'},
    {'value': 'rentalAgreement', 'label': 'Rental Agreement'},
    {'value': 'invoice', 'label': 'Invoice'},
    {'value': 'receipt', 'label': 'Receipt'},
    {'value': 'other', 'label': 'Other'},
  ];

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadDocuments() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final docs =
          await DocumentService.getDocumentsForTaxReturn(widget.taxReturnId);
      setState(() {
        _documents = docs;
        _filteredDocuments = docs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  void _filterDocuments(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredDocuments = _documents;
      } else {
        _filteredDocuments = _documents
            .where((doc) =>
                doc.fileName.toLowerCase().contains(query.toLowerCase()) ||
                doc.documentType.toLowerCase().contains(query.toLowerCase()) ||
                doc.description?.toLowerCase().contains(query.toLowerCase()) ==
                    true)
            .toList();
      }
    });
  }

  Future<void> _pickDocumentFile() async {
    try {
      final pickerResult = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'pdf',
          'jpg',
          'jpeg',
          'png',
          'doc',
          'docx',
          'xls',
          'xlsx'
        ],
      );

      if (!mounted) return;
      if (pickerResult == null) return;
      final file = pickerResult.files.first;
      if (kIsWeb) {
        final bytes = file.bytes;
        if (bytes == null) return;
        setState(() {
          _selectedFileBytes = bytes;
          _selectedFileName = file.name;
          _selectedFile = null;
        });
      } else if (file.path != null) {
        setState(() {
          _selectedFile = File(file.path!);
          _selectedFileBytes = null;
          _selectedFileName = null;
        });
      }
    } catch (e) {
      if (!mounted) return;
      Helpers.showErrorSnackBar(context, 'Failed to pick file: $e');
    }
  }

  Future<void> _uploadDocument() async {
    if (_selectedFile == null) {
      Helpers.showErrorSnackBar(context, 'Please select a file');
      return;
    }

    if (_selectedDocumentType == null) {
      Helpers.showErrorSnackBar(context, 'Please select document type');
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final user = Provider.of<AuthProvider>(context, listen: false).user;

      final document = await DocumentService.uploadDocument(
        file: _selectedFile,
        documentType: _selectedDocumentType!,
        taxReturnId: widget.taxReturnId,
        userId: user?.id?.toString() ?? '1',
        description: _descriptionController.text.isNotEmpty
            ? _descriptionController.text
            : null,
        metadata: {
          'fileSize': _selectedFile != null
              ? _selectedFile!.lengthSync()
              : (_selectedFileBytes?.lengthInBytes ?? 0),
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
        _documents.insert(0, document);
        _filteredDocuments.insert(0, document);
      });

      Helpers.showSuccessSnackBar(context, 'Document uploaded successfully!');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isUploading = false;
      });
      Helpers.showErrorSnackBar(context, 'Upload failed: ${e.toString()}');
    }
  }

  Future<void> _deleteDocument(Document document) async {
    final confirm = await Helpers.showConfirmDialog(
      context,
      title: 'Delete Document',
      message: 'Are you sure you want to delete "${document.fileName}"?',
      confirmText: 'Delete',
    );

    if (confirm == true) {
      if (!mounted) return;
      try {
        await DocumentService.deleteDocument(document.id);
        if (!mounted) return;
        setState(() {
          _documents.removeWhere((d) => d.id == document.id);
          _filteredDocuments.removeWhere((d) => d.id == document.id);
        });
        Helpers.showSuccessSnackBar(context, 'Document deleted successfully');
      } catch (e) {
        if (!mounted) return;
        Helpers.showErrorSnackBar(context, 'Failed to delete: $e');
      }
    }
  }

  void _previewDocument(Document document) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  document.fileName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      document.fileIcon,
                      size: 80,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      document.fileName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${document.formattedFileSize} • ${document.fileType.toUpperCase()}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      document.formattedUploadDate,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: document.statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: document.statusColor),
                      ),
                      child: Text(
                        document.statusDisplay,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: document.statusColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _downloadDocument(document);
                          },
                          icon: const Icon(Icons.download),
                          label: const Text('Download'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            // Share document
                          },
                          icon: const Icon(Icons.share),
                          label: const Text('Share'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadDocument(Document document) async {
    try {
      Helpers.showLoadingDialog(context);
      final file = await DocumentService.downloadDocument(document);
      if (!mounted) return;
      Helpers.hideLoadingDialog(context);
      Helpers.showSuccessSnackBar(
        context,
        'Document downloaded: ${file.path.split('/').last}',
      );
    } catch (e) {
      if (!mounted) return;
      Helpers.hideLoadingDialog(context);
      Helpers.showErrorSnackBar(context, 'Failed to download: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Supporting Documents'),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
              });
            },
            tooltip: 'Search',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDocuments,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          if (_isSearching)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey.shade50,
              child: TextField(
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search documents...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _isSearching = false;
                        _filterDocuments('');
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: _filterDocuments,
              ),
            ),

          // Upload Document Section
          _buildUploadSection(),

          // Document List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline,
                                size: 48, color: Colors.red),
                            const SizedBox(height: 8),
                            Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadDocuments,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _filteredDocuments.isEmpty
                        ? _buildEmptyState()
                        : RefreshIndicator(
                            onRefresh: _loadDocuments,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _filteredDocuments.length,
                              itemBuilder: (context, index) {
                                final document = _filteredDocuments[index];
                                return DocumentCard(
                                  document: document,
                                  onDelete: () => _deleteDocument(document),
                                  onPreview: () => _previewDocument(document),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Upload New Document',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // Document Type Dropdown
          DropdownButtonFormField<String>(
            initialValue: _selectedDocumentType,
            decoration: const InputDecoration(
              labelText: 'Document Type',
              prefixIcon: Icon(Icons.label),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ),
            items: _documentTypes.map((item) {
              return DropdownMenuItem(
                value: item['value'],
                child: Text(item['label']!),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedDocumentType = value;
              });
            },
          ),
          const SizedBox(height: 8),

          // File Selection
          InkWell(
            onTap: _isUploading ? null : _pickDocumentFile,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
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

          const SizedBox(height: 8),

          // Description
          CustomTextField(
            controller: _descriptionController,
            label: 'Description (Optional)',
            hint: 'Enter a description for this document',
            prefixIcon: Icons.description,
            readOnly: _isUploading,
          ),

          const SizedBox(height: 12),

          // Upload Button
          CustomButton(
            text: _isUploading ? 'Uploading...' : 'Upload Document',
            onPressed: _isUploading ? null : _uploadDocument,
            isLoading: _isUploading,
            icon: Icons.cloud_upload,
            backgroundColor: AppColors.primary,
          ),

          const SizedBox(height: 4),
          Text(
            'Allowed: PDF, JPG, PNG, DOC, XLS (Max 10MB)',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropArea() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.cloud_upload,
          size: 24,
          color: Colors.grey.shade400,
        ),
        const SizedBox(width: 8),
        Text(
          'Tap to select file',
          style: TextStyle(
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildFilePreview() {
    return Row(
      children: [
        const Icon(
          Icons.insert_drive_file,
          color: AppColors.primary,
          size: 32,
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
                '${(_selectedFile!.lengthSync() / 1024).toStringAsFixed(1)} KB',
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
            });
          },
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No documents uploaded yet',
            style: TextStyle(color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            'Upload supporting documents for your tax return',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
