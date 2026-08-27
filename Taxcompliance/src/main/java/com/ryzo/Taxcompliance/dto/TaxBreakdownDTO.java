package com.ryzo.Taxcompliance.dto;

import lombok.Builder;
import lombok.Data;
import lombok.AllArgsConstructor;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TaxBreakdownDTO {
    private List<SlabBreakdown> slabContributions;
    private Map<String, BigDecimal> deductionDetails;
    private BigDecimal rebateUnder87A;
    private BigDecimal healthAndEducationCess;
    private BigDecimal totalTaxBeforeCess;
}
