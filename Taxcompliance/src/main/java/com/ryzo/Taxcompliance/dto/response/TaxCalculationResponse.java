package com.ryzo.Taxcompliance.dto.response;

import com.ryzo.Taxcompliance.dto.TaxBreakdownDTO;
import lombok.Builder;
import lombok.Data;
import lombok.AllArgsConstructor;
import lombok.NoArgsConstructor;
import java.math.BigDecimal;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TaxCalculationResponse {
    private Long returnId;
    private String filingId;
    private String assessmentYear;
    private BigDecimal totalIncome;
    private BigDecimal deductions;
    private BigDecimal taxableIncome;
    private BigDecimal taxPayable;
    private BigDecimal cess;
    private BigDecimal surcharge;
    private BigDecimal interest;
    private BigDecimal penalty;
    private BigDecimal totalLiability;
    private String status;
    private String message;

    // Detailed breakdown
    private TaxBreakdownDTO breakdown;
}
