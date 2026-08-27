package com.ryzo.Taxcompliance.dto;

import lombok.Builder;
import lombok.Data;
import lombok.AllArgsConstructor;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AssessmentSummary {
    private long totalAssessments;
    private long completedAssessments;
    private long inProgressAssessments;
    private long pendingAssessments;
    private long demandsRaised;
    private long demandsSettled;
}
