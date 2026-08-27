package com.ryzo.Taxcompliance.dto;

import lombok.Builder;
import lombok.Data;
import lombok.AllArgsConstructor;
import lombok.NoArgsConstructor;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TaxReturnResponseDTO {
    private Long id;
    private String filingId;
    private Long userId;
    private String assessmentYear;
    private String filingType;
    private BigDecimal totalIncome;
    private BigDecimal deductions;
    private BigDecimal taxableIncome;
    private BigDecimal taxPayable;
    private BigDecimal interest;
    private BigDecimal penalty;
    private BigDecimal totalLiability;
    private String status;
    private LocalDate submissionDate;
    private String acknowledgmentNumber;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private UserSummaryDTO user;
}
