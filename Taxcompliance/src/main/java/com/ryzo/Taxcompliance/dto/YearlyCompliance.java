package com.ryzo.Taxcompliance.dto;

import lombok.Builder;
import lombok.Data;
import lombok.AllArgsConstructor;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class YearlyCompliance {
    private String year;
    private long totalFilings;
    private long onTimeFilings;
    private long lateFilings;
    private long nonFilings;
    private double complianceRate;
    private long totalSubscriptions;
    private long premiumSubscriptions;
}
