import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import '../models/document.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class DocumentService {
  static const String baseUrl = 'http://localhost:8080/api';

  // Upload document (Web-compatible)
  static Future<Document> uploadDocument({
    File? file,
    required String documentType,
    required String taxReturnId,
    required String userId,
    String? description,
    Map<String, dynamic>? metadata,
    Uint8List? fileBytes,
    String? fileName,
  }) async {
    try {
      // For web, we'll simulate upload
      if (kIsWeb) {
        // Read file as bytes (either provided or from File if available)
        final bytes = fileBytes ??
            (file != null ? await file.readAsBytes() : Uint8List(0));
        final resolvedName = fileName ??
            (file != null ? file.path.split('/').last : 'upload.bin');

        // Simulate API call
        await Future.delayed(const Duration(seconds: 1));

        // Create mock document
        return Document(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          fileName: resolvedName,
          filePath: resolvedName,
          fileType: resolvedName.split('.').last,
          fileSize: bytes.length.toDouble(),
          documentType: documentType,
          description: description,
          uploadDate: DateTime.now(),
          taxReturnId: taxReturnId,
          userId: userId,
          status: 'PENDING',
        );
      }

      // For mobile/desktop - real upload
      if (file == null) {
        throw Exception('No file provided for upload');
      }
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/documents/upload'),
      );

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path,
          filename: file.path.split('/').last,
        ),
      );

      request.fields.addAll({
        'documentType': documentType,
        'taxReturnId': taxReturnId,
        'userId': userId,
        'description': description ?? '',
        'metadata': jsonEncode(metadata ?? {}),
      });

      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(responseData);
        return Document.fromJson(data);
      } else {
        throw Exception('Upload failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to upload document: $e');
    }
  }

  // Get documents for tax return
  static Future<List<Document>> getDocumentsForTaxReturn(
      String taxReturnId) async {
    try {
      if (kIsWeb) {
        // For web, return mock data
        return _getMockDocuments();
      }

      final response = await http.get(
        Uri.parse('$baseUrl/documents/tax-return/$taxReturnId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return data.map((json) => Document.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch documents');
      }
    } catch (e) {
      return _getMockDocuments();
    }
  }

  // Get documents by user
  static Future<List<Document>> getDocumentsByUser(String userId) async {
    try {
      if (kIsWeb) {
        return _getMockDocuments();
      }

      final response = await http.get(
        Uri.parse('$baseUrl/documents/user/$userId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return data.map((json) => Document.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch documents');
      }
    } catch (e) {
      return _getMockDocuments();
    }
  }

  // Delete document
  static Future<void> deleteDocument(String documentId) async {
    try {
      if (kIsWeb) {
        // For web, just simulate deletion
        await Future.delayed(const Duration(milliseconds: 500));
        return;
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/documents/$documentId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete document');
      }
    } catch (e) {
      throw Exception('Failed to delete document: $e');
    }
  }

  // Download document
  static Future<File> downloadDocument(Document document) async {
    try {
      if (kIsWeb) {
        // For web, create a mock file
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/${document.fileName}';
        final file = File(filePath);
        await file.writeAsString('Mock document content');
        return file;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/documents/download/${document.id}'),
      );

      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/${document.fileName}';
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        return file;
      } else {
        throw Exception('Failed to download document');
      }
    } catch (e) {
      throw Exception('Failed to download document: $e');
    }
  }

  // Mock data for web demo
  static List<Document> _getMockDocuments() {
    return [
      Document(
        id: '1',
        fileName: 'Employment_Letter_2024.pdf',
        filePath: '/documents/1.pdf',
        fileType: 'pdf',
        fileSize: 1024 * 1024 * 2.5,
        documentType: 'income',
        description: 'Employment confirmation letter from employer',
        uploadDate: DateTime.now().subtract(const Duration(days: 2)),
        taxReturnId: 'TR-2024-001',
        userId: '1',
        status: 'VERIFIED',
        verificationNotes: 'Document verified by TRA',
      ),
      Document(
        id: '2',
        fileName: 'TIN_Certificate.png',
        filePath: '/documents/2.png',
        fileType: 'png',
        fileSize: 1024 * 512,
        documentType: 'tinCertificate',
        description: 'TIN registration certificate',
        uploadDate: DateTime.now().subtract(const Duration(days: 5)),
        taxReturnId: 'TR-2024-001',
        userId: '1',
        status: 'PENDING',
      ),
    ];
  }
}
