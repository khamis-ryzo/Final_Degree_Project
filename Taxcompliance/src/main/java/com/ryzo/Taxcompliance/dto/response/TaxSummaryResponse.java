package com.ryzo.Taxcompliance.dto.response;

import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDate;

@Data
public class TaxSummaryResponse {
    private String assessmentYear;
    private BigDecimal totalIncome;
    private BigDecimal deductions;
    private BigDecimal taxableIncome;
    private BigDecimal taxPayable;
    private BigDecimal totalLiability;
    private String filingStatus;
    private LocalDate dueDate;
    private String message;
}
