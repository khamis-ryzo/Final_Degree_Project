package com.ryzo.Taxcompliance.entity;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import jakarta.persistence.*;
import jakarta.validation.constraints.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "documents")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Document {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "file_name", nullable = false)
    @NotBlank(message = "File name is required")
    private String fileName;

    @Column(name = "file_path", nullable = false)
    @NotBlank(message = "File path is required")
    private String filePath;

    @Column(name = "file_type", nullable = false)
    @NotBlank(message = "File type is required")
    private String fileType;

    @Column(name = "file_size", nullable = false)
    @NotNull(message = "File size is required")
    private Long fileSize;

    @Column(name = "document_type", nullable = false)
    @NotBlank(message = "Document type is required")
    private String documentType;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Column(name = "tax_return_id", nullable = false)
    @NotBlank(message = "Tax return ID is required")
    private String taxReturnId;

    @Column(name = "user_id", nullable = false)
    private Long userId;

    @Column(name = "control_number")
    private String controlNumber;

    @Column(name = "status")
    private String status = "PENDING"; // PENDING, VERIFIED, REJECTED

    @Column(name = "verification_notes")
    private String verificationNotes;

    @Column(name = "is_verified")
    private Boolean isVerified = false;

    @Column(name = "verified_by")
    private Long verifiedBy;

    @Column(name = "verified_at")
    private LocalDateTime verifiedAt;

    @Column(name = "uploaded_by")
    private Long uploadedBy;

    @Column(name = "uploaded_by_name")
    private String uploadedByName;

    @Column(name = "user_name")
    private String userName; // For search by name

    @Column(name = "tin_number")
    private String tinNumber; // For search by TIN

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @Column(columnDefinition = "TEXT")
    private String metadata;

    // ==================== HELPER METHODS ====================

    public boolean isImage() {
        String type = fileType.toLowerCase();
        return type.equals("jpg") || type.equals("jpeg") ||
                type.equals("png") || type.equals("gif") ||
                type.equals("bmp") || type.equals("webp");
    }

    public boolean isPDF() {
        return fileType.toLowerCase().equals("pdf");
    }

    public String getFileSizeDisplay() {
        if (fileSize < 1024) return fileSize + " B";
        if (fileSize < 1024 * 1024) return String.format("%.1f KB", fileSize / 1024.0);
        if (fileSize < 1024 * 1024 * 1024) return String.format("%.1f MB", fileSize / (1024.0 * 1024));
        return String.format("%.1f GB", fileSize / (1024.0 * 1024 * 1024));
    }

    public String getStatusDisplay() {
        switch (status) {
            case "VERIFIED":
                return "Verified";
            case "REJECTED":
                return "Rejected";
            default:
                return "Pending";
        }
    }
}