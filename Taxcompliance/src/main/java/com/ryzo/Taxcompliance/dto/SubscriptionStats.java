package com.ryzo.Taxcompliance.dto;

import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.math.BigDecimal;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class SubscriptionStats {
    private long totalSubscriptions;
    private long activeSubscriptions;
    private long premiumSubscriptions;
    private long freeSubscriptions;
    private long expiredSubscriptions;
    private long expiringThisMonth;
    private BigDecimal estimatedMonthlyRevenue;
}
