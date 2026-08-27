package com.ryzo.Taxcompliance.dto;

import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AdminDashboardResponse {
    private UserStats userStats;
    private TaxReturnStats taxReturnStats;
    private SubscriptionStats subscriptionStats;
    private ComplianceStats complianceStats;
    private SystemStats systemStats;
}
