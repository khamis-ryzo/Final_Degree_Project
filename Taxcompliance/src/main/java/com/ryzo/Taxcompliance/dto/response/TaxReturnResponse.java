package com.ryzo.Taxcompliance.dto.response;

import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDate;

@Data
public class TaxReturnResponse {
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
}
