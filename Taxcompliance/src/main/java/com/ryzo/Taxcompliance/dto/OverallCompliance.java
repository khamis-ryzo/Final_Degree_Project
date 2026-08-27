package com.ryzo.Taxcompliance.dto;

import lombok.Builder;
import lombok.Data;
import lombok.AllArgsConstructor;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class OverallCompliance {
    private double filingComplianceRate;
    private double subscriptionComplianceRate;
    private double assessmentComplianceRate;
    private long totalTaxpayers;
    private long compliantTaxpayers;
    private long nonCompliantTaxpayers;
}
