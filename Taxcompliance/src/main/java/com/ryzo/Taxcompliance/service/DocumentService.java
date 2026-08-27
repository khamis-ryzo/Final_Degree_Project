package com.ryzo.Taxcompliance.service;


import com.ryzo.Taxcompliance.dto.request.DocumentSearchRequest;
import com.ryzo.Taxcompliance.entity.Document;
import com.ryzo.Taxcompliance.entity.User;
import com.ryzo.Taxcompliance.repository.DocumentRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;

@Service
@RequiredArgsConstructor
@Slf4j
public class DocumentService {

    private final DocumentRepository documentRepository;
    private final StorageService storageService;

    /**
     * Upload document with user name and TIN for search
     */
    @Transactional
    public Document uploadDocument(MultipartFile file, User user, String taxReturnId, String documentType, String description) {
        try {
            // Store file
            String filePath = storageService.storeDocument(file, user, taxReturnId, documentType);

            // Create document record
            Document document = new Document();
            document.setFileName(file.getOriginalFilename());
            document.setFilePath(filePath);
            document.setFileType(getFileExtension(file.getOriginalFilename()));
            document.setFileSize(file.getSize());
            document.setDocumentType(documentType);
            document.setDescription(description);
            document.setTaxReturnId(taxReturnId);
            document.setUserId(user.getId());
            document.setUserName(user.getFullName()); // Store for search by name
            document.setTinNumber(user.getTinNumber()); // Store for search by TIN
            document.setUploadedBy(user.getId());
            document.setUploadedByName(user.getFullName());
            document.setStatus("PENDING");

            // TaxReturn does not expose control number directly in current model.
            // Keep document.controlNumber nullly provided.

            // Store metadata
            Map<String, Object> metadata = new HashMap<>();
            metadata.put("originalName", file.getOriginalFilename());
            metadata.put("contentType", file.getContentType());
            document.setMetadata(metadata.toString());

            return documentRepository.save(document);
        } catch (Exception e) {
            log.error("Error uploading document: {}", e.getMessage());
            throw new RuntimeException("Failed to upload document", e);
        }
    }

    /**
     * Search documents by file name and/or additional criteria
     */
    public Page<Document> searchDocuments(DocumentSearchRequest request, Pageable pageable) {
        String searchTerm = request.getSearchTerm();
        String matchType = request.getMatchType() != null ? request.getMatchType() : "CONTAINS";

        boolean hasSearchTerm = searchTerm != null && !searchTerm.isEmpty();
        boolean hasFilters = isNotBlank(request.getDocumentType())
                || isNotBlank(request.getStatus())
                || isNotBlank(request.getUserFullName())
                || isNotBlank(request.getTinNumber())
                || isNotBlank(request.getTaxReturnId())
                || isNotBlank(request.getControlNumber());

        // Search by file name only
        if (hasSearchTerm && !hasFilters) {
            switch (matchType.toUpperCase()) {
                case "EXACT":
                    return documentRepository.findByFileNameExact(searchTerm, pageable);
                case "STARTS_WITH":
                    return documentRepository.findByFileNameStartsWith(searchTerm, pageable);
                case "ENDS_WITH":
                    return documentRepository.findByFileNameEndsWith(searchTerm, pageable);
                default:
                    return documentRepository.findByFileNameContaining(searchTerm, pageable);
            }
        }

        if (!hasSearchTerm && !hasFilters) {
            return documentRepository.findAll(pageable);
        }

        Pageable nonNullPageable = Objects.requireNonNull(pageable, "pageable");

        // Search by multiple criteria
        return documentRepository.searchDocuments(
                hasSearchTerm ? searchTerm : null,
                request.getUserFullName(),
                request.getTinNumber(),
                request.getDocumentType(),
                request.getStatus(),
                request.getTaxReturnId(),
                request.getControlNumber(),
                nonNullPageable);
    }

    /**
     * Search documents by user name (full or partial)
     */
    public List<Document> searchByUserName(String name, String matchType) {
        if (name == null || name.isEmpty()) {
            return documentRepository.findAll();
        }

        String type = matchType != null ? matchType.toUpperCase() : "CONTAINS";

        List<Document> documents = switch (type) {
            case "EXACT" -> documentRepository.findByUserNameExact(name);
            case "STARTS_WITH" -> documentRepository.findByUserNameStartsWith(name);
            case "ENDS_WITH" -> documentRepository.findByUserNameEndsWith(name);
            default -> documentRepository.findByUserNameContaining(name);
        };

        // Search by TIN if the input looks like a TIN
        if (name.matches("^[0-9]{9}$")) {
            documents = new ArrayList<>(documents);
            documents.addAll(documentRepository.findByTinNumber(name));
        }

        return documents.stream().distinct().toList();
    }

    private boolean isNotBlank(String value) {
        return value != null && !value.isEmpty();
    }

    /**
     * Get documents by tax return
     */
    public List<Document> getDocumentsForTaxReturn(String taxReturnId) {
        return documentRepository.findByTaxReturnId(taxReturnId);
    }

    /**
     * Get documents by user
     */
    public List<Document> getDocumentsByUser(Long userId) {
        return documentRepository.findByUserId(userId);
    }

    /**
     * Get document by ID
     */
    public Document getDocumentById(Long documentId) {
        return documentRepository.findById(Objects.requireNonNull(documentId))
                .orElseThrow(() -> new RuntimeException("Document not found"));
    }

    /**
     * Delete document
     */
    @Transactional
    public void deleteDocument(Long documentId) {
        Document document = getDocumentById(documentId);

        // Delete file from storage
        storageService.deleteDocument(document.getFilePath());

        // Delete from database
        documentRepository.delete(document);
    }

    /**
     * Verify document (Admin)
     */
    @Transactional
    public Document verifyDocument(Long documentId, boolean verified, String notes) {
        Document document = getDocumentById(documentId);
        document.setIsVerified(verified);
        document.setStatus(verified ? "VERIFIED" : "REJECTED");
        document.setVerificationNotes(notes);
        document.setVerifiedAt(LocalDateTime.now());

        return documentRepository.save(document);
    }

    /**
     * Get documents by control number
     */
    public List<Document> getDocumentsByControlNumber(String controlNumber) {
        return documentRepository.findByControlNumber(controlNumber);
    }

    /**
     * Get document statistics
     */
    public Map<String, Object> getDocumentStatistics() {
        Map<String, Object> stats = new HashMap<>();

        stats.put("totalDocuments", documentRepository.count());
        stats.put("pendingDocuments", documentRepository.countByStatus("PENDING"));
        stats.put("verifiedDocuments", documentRepository.countByIsVerified(true));
        stats.put("rejectedDocuments", documentRepository.countByStatus("REJECTED"));

        // Documents by type
        Map<String, Long> byType = new HashMap<>();
        for (String type : documentRepository.findDistinctDocumentTypes()) {
            byType.put(type, documentRepository.countByDocumentType(type));
        }
        stats.put("documentsByType", byType);

        return stats;
    }

    /**
     * Get file extension
     */
    private String getFileExtension(String fileName) {
        if (fileName == null) return "";
        int lastDot = fileName.lastIndexOf('.');
        if (lastDot == -1) return "";
        return fileName.substring(lastDot + 1);
    }
}