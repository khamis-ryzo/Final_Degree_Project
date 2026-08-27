package com.ryzo.Taxcompliance.dto;

import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ComplianceStats {
    private double overallComplianceRate;
    private long onTimeFilings;
    private long lateFilings;
    private long pendingAssessments;
    private long completedAssessments;
}
