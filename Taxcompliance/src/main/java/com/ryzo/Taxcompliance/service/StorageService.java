package com.ryzo.Taxcompliance.service;


import com.ryzo.Taxcompliance.entity.User;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Objects;
import java.util.UUID;

@Service
@Slf4j
public class StorageService {

    @Value("${document.storage.path}")
    private String storagePath;

    @Value("${document.temp.path}")
    private String tempPath;

    @Value("${file.max-size}")
    private long maxFileSize;

    @Value("${file.allowed-extensions}")
    private String allowedExtensions;

    /**
     * Store document for a user's tax return
     */
    public String storeDocument(MultipartFile file, User user, String taxReturnId, String documentType) throws IOException {
        // Create directory structure: {storagePath}/users/{userId}/{taxReturnId}/{documentType}/
        String userDir = String.format("users/%d", user.getId());
        String returnDir = String.format("%s/%s", userDir, taxReturnId);
        String typeDir = String.format("%s/%s", returnDir, documentType);

        Path fullPath = Paths.get(storagePath, typeDir);

        // Create directories if they don't exist
        if (!Files.exists(fullPath)) {
            Files.createDirectories(fullPath);
        }

        // Generate unique filename
        String originalFileName = file.getOriginalFilename();
        String extension = getFileExtension(originalFileName);
        String timestamp = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMdd_HHmmss"));
        String uniqueId = UUID.randomUUID().toString().substring(0, 8);
        String storedFileName = String.format("%s_%s_%s.%s",
                user.getTinNumber(),
                timestamp,
                uniqueId,
                extension
        );

        // Full path to stored file
        Path filePath = fullPath.resolve(storedFileName);
        File destination = Objects.requireNonNull(filePath.toFile(), "Storage destination file must not be null");

        // Save file
        file.transferTo(destination);

        log.info("Document stored at: {}", filePath);

        // Return relative path for database storage
        return Paths.get(typeDir, storedFileName).toString();
    }

    /**
     * Delete document
     */
    public boolean deleteDocument(String filePath) {
        try {
            Path path = Paths.get(storagePath, filePath);
            File file = path.toFile();
            if (file.exists()) {
                boolean deleted = file.delete();
                log.info("Document deleted: {}, success: {}", filePath, deleted);
                return deleted;
            }
            return false;
        } catch (Exception e) {
            log.error("Error deleting document: {}", e.getMessage());
            return false;
        }
    }

    /**
     * Get file by path
     */
    public File getFile(String filePath) {
        Path path = Paths.get(storagePath, filePath);
        return Objects.requireNonNull(path.toFile(), "Resolved storage file must not be null");
    }

    /**
     * Validate file
     */
    public boolean isValidFile(MultipartFile file) {
        // Check file size
        if (file.getSize() > maxFileSize) {
            log.warn("File too large: {}", file.getSize());
            return false;
        }

        // Check file extension
        String extension = getFileExtension(file.getOriginalFilename());
        if (!allowedExtensions.contains(extension.toLowerCase())) {
            log.warn("Invalid file extension: {}", extension);
            return false;
        }

        return true;
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

    /**
     * Get MIME type
     */
    public String getMimeType(String filePath) {
        try {
            Path path = Paths.get(storagePath, filePath);
            return Files.probeContentType(path);
        } catch (IOException e) {
            return "application/octet-stream";
        }
    }

    /**
     * Clean up temporary files
     */
    public void cleanupTempFiles() {
        try {
            Path tempDir = Paths.get(tempPath);
            if (Files.exists(tempDir)) {
                Files.walk(tempDir)
                        .filter(Files::isRegularFile)
                        .forEach(path -> {
                            try {
                                Files.delete(path);
                            } catch (IOException e) {
                                log.error("Error deleting temp file: {}", path);
                            }
                        });
            }
        } catch (IOException e) {
            log.error("Error cleaning temp files: {}", e.getMessage());
        }
    }
}
