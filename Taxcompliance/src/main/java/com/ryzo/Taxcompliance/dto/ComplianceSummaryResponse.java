package com.ryzo.Taxcompliance.dto;


import lombok.Builder;
import lombok.Data;
import lombok.AllArgsConstructor;
import lombok.NoArgsConstructor;
import java.util.Map;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ComplianceSummaryResponse {
    private OverallCompliance overall;
    private Map<String, YearlyCompliance> yearlyBreakdown;
    private TDSCompliance tdsCompliance;
    private AssessmentSummary assessmentSummary;
}
