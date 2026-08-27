package com.ryzo.Taxcompliance.service;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class TaxSummary {
    private Integer year;
    private String taxpayerType;
    private BigDecimal grossIncome;
    private BigDecimal paye;
    private BigDecimal skillsLevy;
    private BigDecimal railwayLevy;
    private BigDecimal cess;
    private BigDecimal totalTax;
    private BigDecimal netTax;
}
