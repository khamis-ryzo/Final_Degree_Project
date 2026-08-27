package com.ryzo.Taxcompliance.repository;


import com.ryzo.Taxcompliance.entity.TaxReturn;
import com.ryzo.Taxcompliance.dto.response.TaxReturnWithUserDTO;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

@Repository
public interface TaxReturnRepository extends JpaRepository<TaxReturn, Long> {

    @Query("SELECT new com.ryzo.Taxcompliance.dto.response.TaxReturnWithUserDTO(" +
            "t.id, t.filingId, t.assessmentYear, t.filingType, " +
            "t.totalIncome, t.deductions, t.taxableIncome, t.taxPayable, " +
            "t.interest, t.penalty, t.totalLiability, t.taxPaid, " +
            "t.refundAmount, t.status, t.submissionDate, t.acknowledgmentNumber, " +
            "p.fullName, p.mobileNumber, p.tinNumber, p.email) " +
            "FROM TaxReturn t JOIN t.user p WHERE p.id = :userId")
    Page<TaxReturnWithUserDTO> findTaxReturnsWithUserByUserId(@Param("userId") Long userId, Pageable pageable);

    Optional<TaxReturn> findByFilingId(String filingId);

    List<TaxReturn> findByUserId(Long userId);

    Page<TaxReturn> findByUserId(Long userId, Pageable pageable);

    List<TaxReturn> findByUserIdAndStatus(Long userId, String status);

    Optional<TaxReturn> findByUserIdAndAssessmentYear(Long userId, String assessmentYear);

    @Query("SELECT t FROM TaxReturn t WHERE t.userId = :userId AND t.assessmentYear = :year AND t.status = 'SUBMITTED'")
    Optional<TaxReturn> findSubmittedReturnByYear(@Param("userId") Long userId, @Param("year") String year);

    boolean existsByUserIdAndAssessmentYearAndStatusNot(Long userId, String assessmentYear, String status);

    List<TaxReturn> findByStatus(String status);

    Page<TaxReturn> findByStatus(String status, Pageable pageable);

    List<TaxReturn> findByAssessmentYear(String assessmentYear);

    Page<TaxReturn> findByAssessmentYear(String assessmentYear, Pageable pageable);

    List<TaxReturn> findByStatusAndAssessmentYear(String status, String assessmentYear);

    Page<TaxReturn> findByStatusAndAssessmentYear(String status, String assessmentYear, Pageable pageable);

    long countByStatus(String status);

    long countByCreatedAtAfter(java.time.LocalDateTime since);

    @Query("SELECT COALESCE(SUM(t.totalLiability), 0) FROM TaxReturn t")
    java.math.BigDecimal sumTotalLiability();
}
