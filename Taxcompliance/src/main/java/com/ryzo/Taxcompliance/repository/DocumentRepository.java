package com.ryzo.Taxcompliance.repository;


import com.ryzo.Taxcompliance.entity.Document;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface DocumentRepository extends JpaRepository<Document, Long> {

    // ==================== SEARCH BY FILE NAME ====================

    Page<Document> findByFileNameContaining(String fileName, Pageable pageable);

    @Query("SELECT d FROM Document d WHERE LOWER(d.fileName) = LOWER(:fileName)")
    Page<Document> findByFileNameExact(@Param("fileName") String fileName, Pageable pageable);

    Page<Document> findByFileNameStartsWith(String fileName, Pageable pageable);

    Page<Document> findByFileNameEndsWith(String fileName, Pageable pageable);

    // ==================== SEARCH BY USER NAME ====================

    @Query("SELECT d FROM Document d WHERE LOWER(d.userName) = LOWER(:userName)")
    List<Document> findByUserNameExact(@Param("userName") String userName);

    @Query("SELECT d FROM Document d WHERE LOWER(d.userName) LIKE LOWER(CONCAT('%', :userName, '%'))")
    List<Document> findByUserNameContaining(@Param("userName") String userName);

    @Query("SELECT d FROM Document d WHERE LOWER(d.userName) LIKE LOWER(CONCAT(:userName, '%'))")
    List<Document> findByUserNameStartsWith(@Param("userName") String userName);

    @Query("SELECT d FROM Document d WHERE LOWER(d.userName) LIKE LOWER(CONCAT('%', :userName))")
    List<Document> findByUserNameEndsWith(@Param("userName") String userName);

    // ==================== SEARCH BY TIN ====================

    @Query("SELECT d FROM Document d WHERE d.tinNumber = :tinNumber")
    List<Document> findByTinNumber(@Param("tinNumber") String tinNumber);

    @Query("SELECT d FROM Document d WHERE d.tinNumber LIKE CONCAT(:tinNumber, '%')")
    List<Document> findByTinNumberStartsWith(@Param("tinNumber") String tinNumber);

    // ==================== OTHER SEARCH METHODS ====================

    List<Document> findByUserId(Long userId);

    List<Document> findByTaxReturnId(String taxReturnId);

    List<Document> findByControlNumber(String controlNumber);

    List<Document> findByDocumentType(String documentType);

    @Query("SELECT DISTINCT d.documentType FROM Document d")
    List<String> findDistinctDocumentTypes();

    // ==================== STATISTICS ====================

    long countByStatus(String status);

    long countByIsVerified(boolean isVerified);

    long countByDocumentType(String documentType);

    // ==================== SEARCH WITH MULTIPLE CRITERIA ====================

    @Query("SELECT d FROM Document d WHERE " +
            "(COALESCE(:fileName, NULL) IS NULL OR d.fileName LIKE CONCAT('%', :fileName, '%')) AND " +
            "(COALESCE(:userName, NULL) IS NULL OR d.userName LIKE CONCAT('%', :userName, '%')) AND " +
            "(COALESCE(:tinNumber, NULL) IS NULL OR d.tinNumber = :tinNumber) AND " +
            "(COALESCE(:documentType, NULL) IS NULL OR d.documentType = :documentType) AND " +
            "(COALESCE(:status, NULL) IS NULL OR d.status = :status) AND " +
            "(COALESCE(:taxReturnId, NULL) IS NULL OR d.taxReturnId = :taxReturnId) AND " +
            "(COALESCE(:controlNumber, NULL) IS NULL OR d.controlNumber = :controlNumber)")
    Page<Document> searchDocuments(
            @Param("fileName") String fileName,
            @Param("userName") String userName,
            @Param("tinNumber") String tinNumber,
            @Param("documentType") String documentType,
            @Param("status") String status,
            @Param("taxReturnId") String taxReturnId,
            @Param("controlNumber") String controlNumber,
            Pageable pageable);
}
