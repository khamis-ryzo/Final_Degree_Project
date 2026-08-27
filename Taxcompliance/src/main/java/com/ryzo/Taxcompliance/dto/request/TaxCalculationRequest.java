package com.ryzo.Taxcompliance.dto.request;

import lombok.Data;
import java.math.BigDecimal;

@Data
public class TaxCalculationRequest {
    private BigDecimal totalIncome;
    private BigDecimal deductions;
    private Long returnId;
}
