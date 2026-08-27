package com.ryzo.Taxcompliance.dto.response;

import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class SubscriptionResponse {
    private Long id;
    private Long userId;
    private String username;
    private String fullName;
    private String plan;          // FREE, PREMIUM
    private String billingCycle;  // NONE, MONTHLY, YEARLY
    private String status;        // ACTIVE, EXPIRED, CANCELLED
    private LocalDate startDate;
    private LocalDate expiryDate;
    private Boolean autoRenew;
    private Long daysRemaining;
    private LocalDateTime createdAt;
    private String message;
}
