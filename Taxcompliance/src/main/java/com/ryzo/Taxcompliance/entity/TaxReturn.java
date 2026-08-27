package com.ryzo.Taxcompliance.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "tax_return", indexes = {
        @Index(name = "idx_user_id", columnList = "user_id"),
        @Index(name = "idx_status", columnList = "status"),
        @Index(name = "idx_assessment_year", columnList = "assessment_year")
})
@Data
@NoArgsConstructor
@AllArgsConstructor
public class TaxReturn {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "filing_id", nullable = false, unique = true, length = 40)
    private String filingId; // Format: TR-YYYY-XXXXX

    @Column(name = "user_id", nullable = false)
    private Long userId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", insertable = false, updatable = false)
    private User user;

    @Column(name = "assessment_year", nullable = false, length = 9)
    private String assessmentYear; // e.g., "2024-25"

    @Column(name = "filing_type", nullable = false)
    private String filingType; // ORIGINAL, REVISED, BELATED

    @Column(name = "total_income", nullable = false, precision = 15, scale = 2)
    private BigDecimal totalIncome;

    @Column(name = "deductions", precision = 15, scale = 2)
    private BigDecimal deductions = BigDecimal.ZERO;

    @Column(name = "taxable_income", nullable = false, precision = 15, scale = 2)
    private BigDecimal taxableIncome;

    @Column(name = "tax_payable", nullable = false, precision = 15, scale = 2)
    private BigDecimal taxPayable;

    @Column(name = "interest", precision = 15, scale = 2)
    private BigDecimal interest = BigDecimal.ZERO;

    @Column(name = "penalty", precision = 15, scale = 2)
    private BigDecimal penalty = BigDecimal.ZERO;

    @Column(name = "total_liability", nullable = false, precision = 15, scale = 2)
    private BigDecimal totalLiability;

    @Column(name = "tax_paid", precision = 15, scale = 2)
    private BigDecimal taxPaid = BigDecimal.ZERO;

    @Column(name = "refund_amount", precision = 15, scale = 2)
    private BigDecimal refundAmount = BigDecimal.ZERO;

    @Column(name = "status", nullable = false)
    private String status; // DRAFT, SUBMITTED, PROCESSING, ASSESSED, COMPLETED, REJECTED

    @Column(name = "submission_date")
    private LocalDate submissionDate;

    @Column(name = "acknowledgment_number", length = 30)
    private String acknowledgmentNumber;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
        if (status == null) status = "DRAFT";
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}