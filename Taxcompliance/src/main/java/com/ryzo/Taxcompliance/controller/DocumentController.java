package com.ryzo.Taxcompliance.controller;

import com.ryzo.Taxcompliance.dto.request.DocumentSearchRequest;
import com.ryzo.Taxcompliance.entity.Document;
import com.ryzo.Taxcompliance.entity.User;
import com.ryzo.Taxcompliance.service.DocumentService;
import com.ryzo.Taxcompliance.service.StorageService;
import com.ryzo.Taxcompliance.service.UserService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import jakarta.validation.Valid;
import java.net.MalformedURLException;
import java.io.File;
import java.util.List;
import java.util.Map;
import java.util.Objects;

@RestController
@RequestMapping("/api/documents")
@RequiredArgsConstructor
@Slf4j
public class DocumentController {

    private final DocumentService documentService;
    private final StorageService storageService;
    private final UserService userService;

    /**
     * Upload document
     */
    @PostMapping("/upload")
    public ResponseEntity<Document> uploadDocument(
            @RequestParam("file") MultipartFile file,
            @RequestParam("documentType") String documentType,
            @RequestParam("taxReturnId") String taxReturnId,
            @RequestParam("userId") Long userId,
            @RequestParam(value = "description", required = false) String description) {

        log.info("Uploading document - User: {}, Type: {}, TaxReturn: {}", userId, documentType, taxReturnId);

        // Validate file
        if (!storageService.isValidFile(file)) {
            throw new RuntimeException("Invalid file. Please check file size and type.");
        }

        User user = userService.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));
        Document document = documentService.uploadDocument(file, user, taxReturnId, documentType, description);

        return ResponseEntity.ok(document);
    }

    /**
     * Get documents for tax return
     */
    @GetMapping("/tax-return/{taxReturnId}")
    public ResponseEntity<List<Document>> getDocumentsForTaxReturn(@PathVariable String taxReturnId) {
        log.info("Getting documents for tax return: {}", taxReturnId);

        List<Document> documents = documentService.getDocumentsForTaxReturn(taxReturnId);
        return ResponseEntity.ok(documents);
    }

    /**
     * Get documents by user
     */
    @GetMapping("/user/{userId}")
    public ResponseEntity<List<Document>> getDocumentsByUser(@PathVariable Long userId) {
        log.info("Getting documents for user: {}", userId);

        List<Document> documents = documentService.getDocumentsByUser(userId);
        return ResponseEntity.ok(documents);
    }

    /**
     * Search documents by file name (full or partial)
     */
    @PostMapping("/search")
    public ResponseEntity<Page<Document>> searchDocuments(
            @Valid @RequestBody DocumentSearchRequest request,
            Pageable pageable) {
        log.info("Searching documents with query: {}", request.getSearchTerm());

        Page<Document> documents = documentService.searchDocuments(request, pageable);
        return ResponseEntity.ok(documents);
    }

    /**
     * Search documents by user name (full or partial)
     */
    @GetMapping("/search/by-name")
    public ResponseEntity<List<Document>> searchByUserName(
            @RequestParam String name,
            @RequestParam(required = false) String matchType) {
        log.info("Searching documents by user name: {}, match type: {}", name, matchType);

        List<Document> documents = documentService.searchByUserName(name, matchType);
        return ResponseEntity.ok(documents);
    }

    /**
     * Download document
     */
    @GetMapping("/download/{documentId}")
    public ResponseEntity<Resource> downloadDocument(@PathVariable Long documentId) {
        log.info("Downloading document: {}", documentId);

        Document document = documentService.getDocumentById(documentId);
        String filePath = document.getFilePath();

        try {
            File storedFile = storageService.getFile(filePath);
            java.net.URI storedUri = storedFile.toURI();
            Resource resource = new UrlResource(storedUri);

            if (resource.exists() && resource.isReadable()) {
                String mimeType = Objects.requireNonNullElse(
                        storageService.getMimeType(filePath),
                        MediaType.APPLICATION_OCTET_STREAM_VALUE);

                return ResponseEntity.ok()
                        .contentType(MediaType.parseMediaType(mimeType))
                        .header(HttpHeaders.CONTENT_DISPOSITION,
                                "attachment; filename=\"" + document.getFileName() + "\"")
                        .body(resource);
            } else {
                throw new RuntimeException("File not found");
            }
        } catch (MalformedURLException e) {
            throw new RuntimeException("Error downloading file", e);
        }
    }

    /**
     * Delete document
     */
    @DeleteMapping("/{documentId}")
    public ResponseEntity<Void> deleteDocument(@PathVariable Long documentId) {
        log.info("Deleting document: {}", documentId);

        documentService.deleteDocument(documentId);
        return ResponseEntity.noContent().build();
    }

    /**
     * Get document statistics
     */
    @GetMapping("/stats")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Map<String, Object>> getDocumentStats() {
        log.info("Getting document statistics");

        Map<String, Object> stats = documentService.getDocumentStatistics();
        return ResponseEntity.ok(stats);
    }

    /**
     * Get document by control number
     */
    @GetMapping("/control/{controlNumber}")
    public ResponseEntity<List<Document>> getDocumentsByControlNumber(@PathVariable String controlNumber) {
        log.info("Getting documents by control number: {}", controlNumber);

        List<Document> documents = documentService.getDocumentsByControlNumber(controlNumber);
        return ResponseEntity.ok(documents);
    }
}
